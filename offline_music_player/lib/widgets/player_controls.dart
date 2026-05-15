import 'package:flutter/material.dart';

import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key, required this.provider});

  final AudioProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Shuffle',
              onPressed: provider.toggleShuffle,
              icon: Icon(
                Icons.shuffle_rounded,
                color: provider.isShuffleEnabled
                    ? AppColors.primary
                    : AppColors.mutedText,
              ),
            ),
            const SizedBox(width: 42),
            IconButton(
              tooltip: 'Stop',
              onPressed: provider.stop,
              icon: const Icon(Icons.stop_rounded, color: AppColors.mutedText),
            ),
            const SizedBox(width: 42),
            IconButton(
              tooltip: 'Repeat',
              onPressed: provider.toggleRepeat,
              icon: Icon(_repeatIcon, color: _repeatColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous',
              onPressed: provider.previous,
              icon: const Icon(Icons.skip_previous_rounded, size: 44),
            ),
            const SizedBox(width: 22),
            StreamBuilder<bool>(
              stream: provider.playingStream,
              initialData: provider.isPlaying,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return SizedBox(
                  width: 76,
                  height: 76,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: provider.playPause,
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 44,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 22),
            IconButton(
              tooltip: 'Next',
              onPressed: provider.next,
              icon: const Icon(Icons.skip_next_rounded, size: 44),
            ),
          ],
        ),
      ],
    );
  }

  IconData get _repeatIcon {
    switch (provider.repeatMode) {
      case PlayerRepeatMode.off:
      case PlayerRepeatMode.all:
        return Icons.repeat_rounded;
      case PlayerRepeatMode.one:
        return Icons.repeat_one_rounded;
    }
  }

  Color get _repeatColor {
    return provider.repeatMode == PlayerRepeatMode.off
        ? AppColors.mutedText
        : AppColors.primary;
  }
}
