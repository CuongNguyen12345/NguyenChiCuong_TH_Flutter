import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageService', () {
    late StorageService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = StorageService();
    });

    test('saves and restores songs', () async {
      const songs = [
        SongModel(
          id: 's1',
          title: 'Song One',
          artist: 'Artist',
          filePath: '/music/song_one.mp3',
          duration: Duration(seconds: 120),
        ),
      ];

      await service.saveSongs(songs);
      final restored = await service.getSongs();

      expect(restored, hasLength(1));
      expect(restored.first.title, 'Song One');
      expect(restored.first.duration, const Duration(seconds: 120));
    });

    test('saves and restores playlists', () async {
      final playlists = [
        PlaylistModel(
          id: 'p1',
          name: 'Favorites',
          songIds: const ['s1'],
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 2),
        ),
      ];

      await service.savePlaylists(playlists);
      final restored = await service.getPlaylists();

      expect(restored, hasLength(1));
      expect(restored.first.name, 'Favorites');
      expect(restored.first.songIds, ['s1']);
    });

    test('saves and restores playback state', () async {
      await service.savePlaybackState(
        songId: 's1',
        position: const Duration(seconds: 45),
        shuffle: true,
        repeatMode: 'all',
        volume: 0.7,
        speed: 1.25,
      );

      final state = await service.getPlaybackState();

      expect(state['songId'], 's1');
      expect(state['position'], const Duration(seconds: 45));
      expect(state['shuffle'], isTrue);
      expect(state['repeatMode'], 'all');
      expect(state['volume'], 0.7);
      expect(state['speed'], 1.25);
    });

    test('limits recently played songs to twenty items', () async {
      final ids = List.generate(25, (index) => 'song_$index');

      await service.saveRecentSongs(ids);
      final restored = await service.getRecentSongs();

      expect(restored, hasLength(20));
      expect(restored.first, 'song_0');
      expect(restored.last, 'song_19');
    });
  });
}
