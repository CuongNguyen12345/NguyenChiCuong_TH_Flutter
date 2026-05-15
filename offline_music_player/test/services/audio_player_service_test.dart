import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playback_state_model.dart';
import 'package:offline_music_player/services/audio_player_service.dart';

void main() {
  group('AudioPlayerService', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('starts in a stopped state', () {
      expect(service.isPlaying, isFalse);
      expect(service.currentPosition, Duration.zero);
    });

    test('clamps volume and playback speed inputs', () async {
      await service.setVolume(2);
      await service.setSpeed(3);

      expect(service.volume, 1);
      expect(service.speed, 2);
    });
  });

  group('PlaybackStateModel', () {
    test('returns zero progress for unknown duration', () {
      const state = PlaybackStateModel(
        position: Duration(seconds: 30),
        duration: Duration.zero,
        isPlaying: true,
      );

      expect(state.progress, 0);
    });

    test('clamps progress to one', () {
      const state = PlaybackStateModel(
        position: Duration(seconds: 90),
        duration: Duration(seconds: 60),
        isPlaying: true,
      );

      expect(state.progress, 1);
    });
  });
}
