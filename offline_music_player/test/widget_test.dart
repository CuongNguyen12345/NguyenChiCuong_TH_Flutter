import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/utils/duration_formatter.dart';

void main() {
  test('formats short and long durations', () {
    expect(formatDuration(const Duration(minutes: 3, seconds: 7)), '03:07');
    expect(
      formatDuration(const Duration(hours: 1, minutes: 2, seconds: 9)),
      '1:02:09',
    );
  });

  test('serializes and restores song metadata', () {
    const song = SongModel(
      id: '1',
      title: 'Test Song',
      artist: 'Test Artist',
      album: 'Test Album',
      filePath: '/music/test.mp3',
      sourceUri: 'content://media/external/audio/media/1',
      duration: Duration(seconds: 185),
    );

    final restored = SongModel.fromJson(song.toJson());

    expect(restored.title, song.title);
    expect(restored.artist, song.artist);
    expect(restored.sourceUri, song.sourceUri);
    expect(restored.duration, song.duration);
  });

  test('playlist copyWith updates name and songs', () {
    final playlist = PlaylistModel.create('Favorites');
    final updated = playlist.copyWith(name: 'Road Trip', songIds: ['1', '2']);

    expect(updated.id, playlist.id);
    expect(updated.name, 'Road Trip');
    expect(updated.songIds, ['1', '2']);
  });
}
