import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/utils/duration_formatter.dart';

void main() {
  group('formatDuration', () {
    test('formats minutes and seconds', () {
      expect(formatDuration(const Duration(minutes: 3, seconds: 7)), '03:07');
    });

    test('formats hours, minutes and seconds', () {
      expect(
        formatDuration(const Duration(hours: 1, minutes: 2, seconds: 9)),
        '1:02:09',
      );
    });

    test('formats zero duration', () {
      expect(formatDuration(Duration.zero), '00:00');
    });
  });
}
