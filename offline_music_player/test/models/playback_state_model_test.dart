import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playback_state_model.dart';

void main() {
  group('PlaybackStateModel', () {
    test('calculates progress between zero and one', () {
      const state = PlaybackStateModel(
        position: Duration(seconds: 30),
        duration: Duration(seconds: 120),
        isPlaying: true,
      );

      expect(state.progress, 0.25);
    });

    test('returns zero progress when duration is unknown', () {
      const state = PlaybackStateModel(
        position: Duration(seconds: 30),
        duration: Duration.zero,
        isPlaying: false,
      );

      expect(state.progress, 0);
    });

    test('clamps progress when position passes duration', () {
      const state = PlaybackStateModel(
        position: Duration(seconds: 90),
        duration: Duration(seconds: 60),
        isPlaying: true,
      );

      expect(state.progress, 1);
    });
  });
}
