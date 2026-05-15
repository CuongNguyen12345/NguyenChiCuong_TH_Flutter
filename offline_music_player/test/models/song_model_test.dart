import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/utils/constants.dart';

void main() {
  group('SongModel', () {
    test('serializes and restores all metadata fields', () {
      final song = SongModel(
        id: '42',
        title: 'Over the Horizon',
        artist: 'Samsung',
        album: 'Device Sounds',
        filePath: '/music/over_the_horizon.mp3',
        sourceUri: 'content://media/external/audio/media/42',
        duration: const Duration(minutes: 3, seconds: 12),
        albumArt: '/art/cover.jpg',
        fileSize: 4096,
        dateAdded: DateTime(2026, 5, 16),
      );

      final restored = SongModel.fromJson(song.toJson());

      expect(restored.id, song.id);
      expect(restored.title, song.title);
      expect(restored.artist, song.artist);
      expect(restored.album, song.album);
      expect(restored.filePath, song.filePath);
      expect(restored.sourceUri, song.sourceUri);
      expect(restored.duration, song.duration);
      expect(restored.albumArt, song.albumArt);
      expect(restored.fileSize, song.fileSize);
      expect(restored.dateAdded, song.dateAdded);
    });

    test('uses safe fallback values when json metadata is missing', () {
      final song = SongModel.fromJson({
        'id': '1',
        'title': 'Untitled',
        'filePath': '/music/untitled.mp3',
      });

      expect(song.artist, AppText.unknownArtist);
      expect(song.album, isNull);
      expect(song.duration, isNull);
    });

    test('creates readable metadata from a file path', () {
      final song = SongModel.fromFilePath(r'C:\Music\my_song_name.mp3');

      expect(song.id, r'C:\Music\my_song_name.mp3');
      expect(song.title, contains('my song name'));
      expect(song.artist, AppText.unknownArtist);
      expect(song.album, AppText.unknownAlbum);
    });
  });
}
