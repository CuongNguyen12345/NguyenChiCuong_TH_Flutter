import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.compact = false,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: compact ? 2 : 3,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: compact ? 0 : 6,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: max,
            onChanged: duration.inMilliseconds <= 0
                ? null
                : (nextValue) {
                    onSeek(Duration(milliseconds: nextValue.round()));
                  },
          ),
        ),
        if (!compact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(position),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                Text(
                  formatDuration(duration),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
