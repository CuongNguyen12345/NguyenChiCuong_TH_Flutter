import 'package:flutter/foundation.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/playlist_service.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  PlaylistProvider({PlaylistService? playlistService})
    : _playlistService = playlistService ?? PlaylistService(StorageService());

  final PlaylistService _playlistService;
  List<PlaylistModel> _playlists = [];

  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);

  Future<void> loadPlaylists() async {
    _playlists = await _playlistService.loadPlaylists();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty) {
      return;
    }
    _playlists = [..._playlists, PlaylistModel.create(cleaned)];
    await _save();
  }

  Future<void> renamePlaylist(String playlistId, String name) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty) {
      return;
    }
    _playlists = _playlists
        .map(
          (playlist) => playlist.id == playlistId
              ? playlist.copyWith(name: cleaned)
              : playlist,
        )
        .toList();
    await _save();
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists = _playlists
        .where((playlist) => playlist.id != playlistId)
        .toList();
    await _save();
  }

  Future<void> addSong(String playlistId, SongModel song) async {
    _playlists = _playlists.map((playlist) {
      if (playlist.id != playlistId || playlist.songIds.contains(song.id)) {
        return playlist;
      }
      return playlist.copyWith(songIds: [...playlist.songIds, song.id]);
    }).toList();
    await _save();
  }

  Future<void> removeSong(String playlistId, String songId) async {
    _playlists = _playlists.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }
      return playlist.copyWith(
        songIds: playlist.songIds.where((id) => id != songId).toList(),
      );
    }).toList();
    await _save();
  }

  Future<void> moveSong(String playlistId, int oldIndex, int newIndex) async {
    _playlists = _playlists.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }
      final ids = [...playlist.songIds];
      final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      final songId = ids.removeAt(oldIndex);
      ids.insert(targetIndex, songId);
      return playlist.copyWith(songIds: ids);
    }).toList();
    await _save();
  }

  Future<void> _save() async {
    await _playlistService.savePlaylists(_playlists);
    notifyListeners();
  }
}
