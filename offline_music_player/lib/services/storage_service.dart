import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';

class StorageService {
  static const _playlistsKey = 'playlists';
  static const _songsKey = 'saved_songs';
  static const _lastSongIdKey = 'last_song_id';
  static const _lastPositionKey = 'last_position';
  static const _recentSongsKey = 'recent_songs';
  static const _shuffleKey = 'shuffle_enabled';
  static const _repeatKey = 'repeat_mode';
  static const _volumeKey = 'volume';
  static const _speedKey = 'speed';

  Future<void> saveSongs(List<SongModel> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final songsJson = songs.map((song) => song.toJson()).toList();
    await prefs.setString(_songsKey, json.encode(songsJson));
  }

  Future<List<SongModel>> getSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_songsKey);
    if (raw == null) {
      return const [];
    }
    final items = json.decode(raw) as List<dynamic>;
    return items
        .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = playlists
        .map((playlist) => playlist.toJson())
        .toList();
    await prefs.setString(_playlistsKey, json.encode(playlistsJson));
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistsKey);
    if (raw == null) {
      return const [];
    }
    final items = json.decode(raw) as List<dynamic>;
    return items
        .map((json) => PlaylistModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePlaybackState({
    String? songId,
    Duration? position,
    bool? shuffle,
    String? repeatMode,
    double? volume,
    double? speed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (songId != null) {
      await prefs.setString(_lastSongIdKey, songId);
    }
    if (position != null) {
      await prefs.setInt(_lastPositionKey, position.inMilliseconds);
    }
    if (shuffle != null) {
      await prefs.setBool(_shuffleKey, shuffle);
    }
    if (repeatMode != null) {
      await prefs.setString(_repeatKey, repeatMode);
    }
    if (volume != null) {
      await prefs.setDouble(_volumeKey, volume);
    }
    if (speed != null) {
      await prefs.setDouble(_speedKey, speed);
    }
  }

  Future<Map<String, Object?>> getPlaybackState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'songId': prefs.getString(_lastSongIdKey),
      'position': Duration(milliseconds: prefs.getInt(_lastPositionKey) ?? 0),
      'shuffle': prefs.getBool(_shuffleKey) ?? false,
      'repeatMode': prefs.getString(_repeatKey) ?? 'off',
      'volume': prefs.getDouble(_volumeKey) ?? 1.0,
      'speed': prefs.getDouble(_speedKey) ?? 1.0,
    };
  }

  Future<void> saveRecentSongs(List<String> songIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSongsKey, songIds.take(20).toList());
  }

  Future<List<String>> getRecentSongs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSongsKey) ?? const [];
  }
}
