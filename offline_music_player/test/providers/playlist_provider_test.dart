import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PlaylistProvider', () {
    late PlaylistProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = PlaylistProvider();
      await provider.loadPlaylists();
    });

    test('creates a playlist with trimmed name', () async {
      await provider.createPlaylist('  Favorites  ');

      expect(provider.playlists, hasLength(1));
      expect(provider.playlists.first.name, 'Favorites');
    });

    test('ignores empty playlist names', () async {
      await provider.createPlaylist('   ');

      expect(provider.playlists, isEmpty);
    });

    test('renames and deletes a playlist', () async {
      await provider.createPlaylist('Old');
      final playlistId = provider.playlists.first.id;

      await provider.renamePlaylist(playlistId, 'New');
      expect(provider.playlists.first.name, 'New');

      await provider.deletePlaylist(playlistId);
      expect(provider.playlists, isEmpty);
    });

    test('adds, removes and prevents duplicate songs', () async {
      await provider.createPlaylist('Favorites');
      final playlistId = provider.playlists.first.id;
      const song = SongModel(
        id: 's1',
        title: 'Song One',
        artist: 'Artist',
        filePath: '/music/song_one.mp3',
      );

      await provider.addSong(playlistId, song);
      await provider.addSong(playlistId, song);

      expect(provider.playlists.first.songIds, ['s1']);

      await provider.removeSong(playlistId, song.id);
      expect(provider.playlists.first.songIds, isEmpty);
    });

    test('reorders songs in a playlist', () async {
      await provider.createPlaylist('Queue');
      final playlistId = provider.playlists.first.id;
      const songs = [
        SongModel(
          id: 's1',
          title: 'One',
          artist: 'Artist',
          filePath: '/music/one.mp3',
        ),
        SongModel(
          id: 's2',
          title: 'Two',
          artist: 'Artist',
          filePath: '/music/two.mp3',
        ),
        SongModel(
          id: 's3',
          title: 'Three',
          artist: 'Artist',
          filePath: '/music/three.mp3',
        ),
      ];

      for (final song in songs) {
        await provider.addSong(playlistId, song);
      }
      await provider.moveSong(playlistId, 0, 3);

      expect(provider.playlists.first.songIds, ['s2', 's3', 's1']);
    });
  });
}
