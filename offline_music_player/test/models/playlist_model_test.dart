import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playlist_model.dart';

void main() {
  group('PlaylistModel', () {
    test('create builds an empty playlist with timestamps', () {
      final playlist = PlaylistModel.create('Favorites');

      expect(playlist.id, isNotEmpty);
      expect(playlist.name, 'Favorites');
      expect(playlist.songIds, isEmpty);
      expect(playlist.createdAt, isA<DateTime>());
      expect(playlist.updatedAt, isA<DateTime>());
    });

    test('serializes and restores playlist data', () {
      final playlist = PlaylistModel(
        id: 'p1',
        name: 'Road Trip',
        songIds: const ['s1', 's2'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        coverImage: '/covers/road.jpg',
      );

      final restored = PlaylistModel.fromJson(playlist.toJson());

      expect(restored.id, playlist.id);
      expect(restored.name, playlist.name);
      expect(restored.songIds, playlist.songIds);
      expect(restored.createdAt, playlist.createdAt);
      expect(restored.updatedAt, playlist.updatedAt);
      expect(restored.coverImage, playlist.coverImage);
    });

    test('copyWith preserves id and createdAt while updating fields', () {
      final playlist = PlaylistModel(
        id: 'p1',
        name: 'Old Name',
        songIds: const ['s1'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final updated = playlist.copyWith(name: 'New Name', songIds: ['s2']);

      expect(updated.id, playlist.id);
      expect(updated.createdAt, playlist.createdAt);
      expect(updated.name, 'New Name');
      expect(updated.songIds, ['s2']);
      expect(updated.updatedAt.isAfter(playlist.updatedAt), isTrue);
    });
  });
}
