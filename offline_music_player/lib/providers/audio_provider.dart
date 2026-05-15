import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/playback_state_model.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/music_library_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';

enum PlayerRepeatMode { off, all, one }

class AudioProvider extends ChangeNotifier {
  AudioProvider({
    AudioPlayerService? audioService,
    MusicLibraryService? libraryService,
    PermissionService? permissionService,
    StorageService? storageService,
  }) : _audioService = audioService ?? AudioPlayerService(),
       _libraryService = libraryService ?? MusicLibraryService(),
       _permissionService = permissionService ?? PermissionService(),
       _storageService = storageService ?? StorageService() {
    _audioService.onSkipToNextRequested = next;
    _audioService.onSkipToPreviousRequested = previous;
    _completionSub = _audioService.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        unawaited(_handleSongCompleted());
      }
    });
    _positionSub = _audioService.positionStream.listen((_) {
      if (_currentSong == null || !_audioService.isPlaying) {
        return;
      }
      final now = DateTime.now();
      if (now.difference(_lastPositionPersistedAt).inSeconds >= 5) {
        _lastPositionPersistedAt = now;
        unawaited(_persistPlayback());
      }
    });
  }

  final AudioPlayerService _audioService;
  final MusicLibraryService _libraryService;
  final PermissionService _permissionService;
  final StorageService _storageService;
  final Random _random = Random();

  StreamSubscription<ProcessingState>? _completionSub;
  StreamSubscription<Duration>? _positionSub;
  DateTime _lastPositionPersistedAt = DateTime.fromMillisecondsSinceEpoch(0);
  List<SongModel> _allSongs = [];
  List<SongModel> _queue = [];
  List<String> _recentSongIds = [];
  SongModel? _currentSong;
  int _currentIndex = -1;
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _shuffleEnabled = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;
  SongSortMode _sortMode = SongSortMode.title;
  String _searchQuery = '';
  String? _artistFilter;
  String? _albumFilter;
  String? _errorMessage;
  double _volume = 1;
  double _speed = 1;

  List<SongModel> get allSongs => List.unmodifiable(_allSongs);
  List<SongModel> get queue => List.unmodifiable(_queue);
  List<SongModel> get recentSongs =>
      _recentSongIds.map(_songById).whereType<SongModel>().toList();
  SongModel? get currentSong => _currentSong;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  bool get isShuffleEnabled => _shuffleEnabled;
  PlayerRepeatMode get repeatMode => _repeatMode;
  SongSortMode get sortMode => _sortMode;
  String get searchQuery => _searchQuery;
  String? get artistFilter => _artistFilter;
  String? get albumFilter => _albumFilter;
  String? get errorMessage => _errorMessage;
  double get volume => _volume;
  double get speed => _speed;
  bool get isPlaying => _audioService.isPlaying;

  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<PlaybackStateModel> get playbackStateStream =>
      _audioService.playbackStateStream;

  List<String> get artists {
    final values = _allSongs.map((song) => song.artist).toSet().toList()
      ..sort();
    return values;
  }

  List<String> get albums {
    final values =
        _allSongs.map((song) => song.album).whereType<String>().toSet().toList()
          ..sort();
    return values;
  }

  List<SongModel> get visibleSongs {
    Iterable<SongModel> songs = _allSongs;
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      songs = songs.where(
        (song) =>
            song.title.toLowerCase().contains(query) ||
            song.artist.toLowerCase().contains(query) ||
            (song.album ?? '').toLowerCase().contains(query),
      );
    }
    if (_artistFilter != null) {
      songs = songs.where((song) => song.artist == _artistFilter);
    }
    if (_albumFilter != null) {
      songs = songs.where((song) => song.album == _albumFilter);
    }
    return songs.toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _audioService.configureSession();
    await _restoreSettings();
    await loadLibrary();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLibrary() async {
    try {
      _hasPermission = await _permissionService.requestStoragePermission();
      final savedSongs = await _storageService.getSongs();
      final deviceSongs = _hasPermission
          ? await _libraryService.loadDeviceSongs(sortMode: _sortMode)
          : <SongModel>[];
      _allSongs = _mergeSongs(savedSongs, deviceSongs);
      _sortSongs();
      _queue = List.of(_allSongs);
      await _storageService.saveSongs(_allSongs);
      await _restoreLastSong();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Cannot load music library: $error';
    }
    notifyListeners();
  }

  Future<void> pickLocalFiles() async {
    try {
      final pickedSongs = await _libraryService.pickAudioFiles();
      if (pickedSongs.isEmpty) {
        return;
      }
      _allSongs = _mergeSongs(_allSongs, pickedSongs);
      _sortSongs();
      _queue = List.of(_allSongs);
      await _storageService.saveSongs(_allSongs);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Cannot import files: $error';
    }
    notifyListeners();
  }

  Future<void> playSong(SongModel song, {List<SongModel>? queue}) async {
    final nextQueue = queue == null || queue.isEmpty ? _allSongs : queue;
    final nextIndex = nextQueue.indexWhere((item) => item.id == song.id);
    _queue = List.of(nextQueue);
    _currentIndex = nextIndex >= 0 ? nextIndex : 0;
    _currentSong = song;
    _errorMessage = null;
    notifyListeners();

    try {
      final detectedDuration = await _audioService.loadSong(song);
      if (detectedDuration != null && song.duration == null) {
        _currentSong = song.copyWith(duration: detectedDuration);
      }
      await _audioService.setVolume(_volume);
      await _audioService.setSpeed(_speed);
      await _audioService.play();
      await _rememberCurrentSong();
    } catch (error) {
      _errorMessage = 'Cannot play "${song.title}": $error';
      notifyListeners();
    }
  }

  Future<void> playPause() async {
    if (_currentSong == null) {
      if (_allSongs.isNotEmpty) {
        await playSong(_allSongs.first, queue: _allSongs);
      }
      return;
    }

    if (_audioService.isPlaying) {
      await _audioService.pause();
      await _persistPlayback();
    } else {
      await _audioService.play();
    }
  }

  Future<void> stop() async {
    await _audioService.stop();
    await _persistPlayback();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    await _persistPlayback();
  }

  Future<void> next() async {
    if (_queue.isEmpty) {
      return;
    }
    if (_shuffleEnabled && _queue.length > 1) {
      var index = _currentIndex;
      while (index == _currentIndex) {
        index = _random.nextInt(_queue.length);
      }
      await playSong(_queue[index], queue: _queue);
      return;
    }
    final nextIndex = _currentIndex + 1;
    if (nextIndex < _queue.length) {
      await playSong(_queue[nextIndex], queue: _queue);
    } else if (_repeatMode == PlayerRepeatMode.all) {
      await playSong(_queue.first, queue: _queue);
    } else {
      await stop();
    }
  }

  Future<void> previous() async {
    if (_queue.isEmpty) {
      return;
    }
    if (_audioService.currentPosition > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    final previousIndex = _currentIndex - 1;
    if (previousIndex >= 0) {
      await playSong(_queue[previousIndex], queue: _queue);
    } else if (_repeatMode == PlayerRepeatMode.all) {
      await playSong(_queue.last, queue: _queue);
    }
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    await _persistPlayback();
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_repeatMode) {
      case PlayerRepeatMode.off:
        _repeatMode = PlayerRepeatMode.all;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.off;
    }
    await _persistPlayback();
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0, 1).toDouble();
    await _audioService.setVolume(_volume);
    await _persistPlayback();
    notifyListeners();
  }

  Future<void> setSpeed(double value) async {
    _speed = value.clamp(0.5, 2).toDouble();
    await _audioService.setSpeed(_speed);
    await _persistPlayback();
    notifyListeners();
  }

  Future<void> setSortMode(SongSortMode mode) async {
    _sortMode = mode;
    _sortSongs();
    _queue = List.of(_allSongs);
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setArtistFilter(String? artist) {
    _artistFilter = artist;
    notifyListeners();
  }

  void setAlbumFilter(String? album) {
    _albumFilter = album;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _artistFilter = null;
    _albumFilter = null;
    notifyListeners();
  }

  List<SongModel> songsByIds(List<String> ids) {
    return ids.map(_songById).whereType<SongModel>().toList();
  }

  Future<void> _handleSongCompleted() async {
    if (_repeatMode == PlayerRepeatMode.one) {
      await seek(Duration.zero);
      await _audioService.play();
      return;
    }
    await next();
  }

  Future<void> _restoreSettings() async {
    final state = await _storageService.getPlaybackState();
    _shuffleEnabled = state['shuffle'] as bool? ?? false;
    _repeatMode = PlayerRepeatMode.values.firstWhere(
      (mode) => mode.name == state['repeatMode'],
      orElse: () => PlayerRepeatMode.off,
    );
    _volume = state['volume'] as double? ?? 1;
    _speed = state['speed'] as double? ?? 1;
    _recentSongIds = await _storageService.getRecentSongs();
    await _audioService.setVolume(_volume);
    await _audioService.setSpeed(_speed);
  }

  Future<void> _restoreLastSong() async {
    if (_allSongs.isEmpty) {
      return;
    }
    final state = await _storageService.getPlaybackState();
    final songId = state['songId'] as String?;
    final position = state['position'] as Duration? ?? Duration.zero;
    if (songId == null) {
      return;
    }
    final song = _songById(songId);
    if (song == null) {
      return;
    }
    _currentSong = song;
    _currentIndex = _allSongs.indexWhere((item) => item.id == song.id);
    try {
      await _audioService.loadSong(song);
      if (position > Duration.zero) {
        await _audioService.seek(position);
      }
    } catch (_) {
      // The file may have moved; keep the library usable and let the user pick another song.
    }
  }

  Future<void> _rememberCurrentSong() async {
    final song = _currentSong;
    if (song == null) {
      return;
    }
    _recentSongIds = [song.id, ..._recentSongIds.where((id) => id != song.id)];
    await _storageService.saveRecentSongs(_recentSongIds);
    await _persistPlayback();
  }

  Future<void> _persistPlayback() {
    return _storageService.savePlaybackState(
      songId: _currentSong?.id,
      position: _audioService.currentPosition,
      shuffle: _shuffleEnabled,
      repeatMode: _repeatMode.name,
      volume: _volume,
      speed: _speed,
    );
  }

  List<SongModel> _mergeSongs(List<SongModel> first, List<SongModel> second) {
    final byPath = <String, SongModel>{};
    for (final song in [...first, ...second]) {
      byPath[song.filePath] = song;
    }
    return byPath.values.toList();
  }

  SongModel? _songById(String id) {
    for (final song in _allSongs) {
      if (song.id == id) {
        return song;
      }
    }
    return null;
  }

  void _sortSongs() {
    _allSongs.sort((a, b) {
      switch (_sortMode) {
        case SongSortMode.artist:
          return a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
        case SongSortMode.album:
          return (a.album ?? '').toLowerCase().compareTo(
            (b.album ?? '').toLowerCase(),
          );
        case SongSortMode.dateAdded:
          return (b.dateAdded ?? DateTime(1970)).compareTo(
            a.dateAdded ?? DateTime(1970),
          );
        case SongSortMode.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    unawaited(_completionSub?.cancel());
    unawaited(_positionSub?.cancel());
    _audioService.dispose();
    super.dispose();
  }
}
