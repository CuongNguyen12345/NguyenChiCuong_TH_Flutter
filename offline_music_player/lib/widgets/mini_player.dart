import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../utils/constants.dart';
import 'album_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final song = provider.currentSong;
        if (song == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NowPlayingScreen(),
                ),
              );
            },
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 14,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  StreamBuilder<PlaybackStateModel>(
                    stream: provider.playbackStateStream,
                    builder: (context, snapshot) {
                      return LinearProgressIndicator(
                        minHeight: 2,
                        value: snapshot.data?.progress ?? 0,
                        backgroundColor: Colors.white10,
                        color: AppColors.primary,
                      );
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          AlbumArt(song: song, size: 52, borderRadius: 6),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<bool>(
                            stream: provider.playingStream,
                            initialData: provider.isPlaying,
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data ?? false;
                              return IconButton(
                                tooltip: isPlaying ? 'Pause' : 'Play',
                                onPressed: provider.playPause,
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: AppColors.text,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Next',
                            onPressed: provider.next,
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
