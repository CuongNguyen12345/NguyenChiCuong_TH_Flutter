import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../models/playback_state_model.dart';
import '../models/song_model.dart';

typedef AudioCommandCallback = Future<void> Function();

class AudioPlayerService extends audio_service.BaseAudioHandler
    with audio_service.SeekHandler {
  AudioPlayerService() {
    _eventSub = _audioPlayer.playbackEventStream
        .map(_transformEvent)
        .listen(playbackState.add);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<audio_service.PlaybackState>? _eventSub;

  AudioCommandCallback? onSkipToNextRequested;
  AudioCommandCallback? onSkipToPreviousRequested;

  AudioPlayer get player => _audioPlayer;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _audioPlayer.processingStateStream;

  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;
  double get volume => _audioPlayer.volume;
  double get speed => _audioPlayer.speed;

  Stream<PlaybackStateModel> get playbackStateStream {
    return Rx.combineLatest3<
      Duration,
      Duration?,
      PlayerState,
      PlaybackStateModel
    >(
      positionStream,
      durationStream,
      playerStateStream,
      (position, duration, playerState) => PlaybackStateModel(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: playerState.playing,
        isBuffering:
            playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      ),
    );
  }

  Future<void> configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<Duration?> loadSong(SongModel song) async {
    Object? uriError;
    try {
      mediaItem.add(_mediaItemFor(song));
      final parsedUri = song.sourceUri == null
          ? null
          : Uri.tryParse(song.sourceUri!);
      if (parsedUri != null && parsedUri.hasScheme) {
        try {
          final duration = await _audioPlayer.setAudioSource(
            AudioSource.uri(parsedUri),
          );
          _updateMediaItemDuration(song, duration);
          return duration;
        } catch (error) {
          uriError = error;
        }
      }
      final duration = await _audioPlayer.setFilePath(song.filePath);
      _updateMediaItemDuration(song, duration);
      return duration;
    } catch (error) {
      final details = uriError == null
          ? error.toString()
          : 'uri failed: $uriError; file path failed: $error';
      throw Exception('Error loading audio: $details');
    }
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() => _audioPlayer.stop();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> skipToNext() async {
    await onSkipToNextRequested?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    await onSkipToPreviousRequested?.call();
  }

  @override
  Future<void> onTaskRemoved() => stop();

  Future<void> setVolume(double volume) =>
      _audioPlayer.setVolume(volume.clamp(0, 1).toDouble());

  Future<void> setSpeed(double speed) =>
      _audioPlayer.setSpeed(speed.clamp(0.5, 2).toDouble());

  audio_service.MediaItem _mediaItemFor(SongModel song, {Duration? duration}) {
    final artUri = song.albumArt == null ? null : Uri.file(song.albumArt!);
    return audio_service.MediaItem(
      id: song.sourceUri ?? song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: duration ?? song.duration,
      artUri: artUri,
      extras: {
        'songId': song.id,
        'filePath': song.filePath,
        if (song.sourceUri != null) 'sourceUri': song.sourceUri,
      },
    );
  }

  void _updateMediaItemDuration(SongModel song, Duration? duration) {
    if (duration != null && duration > Duration.zero) {
      mediaItem.add(_mediaItemFor(song, duration: duration));
    }
  }

  audio_service.PlaybackState _transformEvent(PlaybackEvent event) {
    return audio_service.PlaybackState(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        if (_audioPlayer.playing)
          audio_service.MediaControl.pause
        else
          audio_service.MediaControl.play,
        audio_service.MediaControl.stop,
        audio_service.MediaControl.skipToNext,
      ],
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: audio_service.AudioProcessingState.idle,
        ProcessingState.loading: audio_service.AudioProcessingState.loading,
        ProcessingState.buffering: audio_service.AudioProcessingState.buffering,
        ProcessingState.ready: audio_service.AudioProcessingState.ready,
        ProcessingState.completed:
            audio_service.AudioProcessingState.completed,
      }[_audioPlayer.processingState]!,
      playing: _audioPlayer.playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'dispose') {
      await _eventSub?.cancel();
      await _audioPlayer.dispose();
    }
  }

  void dispose() {
    unawaited(_eventSub?.cancel());
    _audioPlayer.dispose();
  }
}
