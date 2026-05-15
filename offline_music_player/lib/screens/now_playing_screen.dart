import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final song = provider.currentSong;
        return Scaffold(
          appBar: AppBar(title: const Text('Now Playing'), centerTitle: true),
          body: song == null
              ? const Center(child: Text('Choose a song to start playback.'))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: AlbumArt(
                              song: song,
                              size:
                                  MediaQuery.sizeOf(context).shortestSide *
                                  0.72,
                              borderRadius: 8,
                            ),
                          ),
                        ),
                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${song.artist} - ${song.album ?? AppText.unknownAlbum}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 28),
                        StreamBuilder<PlaybackStateModel>(
                          stream: provider.playbackStateStream,
                          builder: (context, snapshot) {
                            final state =
                                snapshot.data ??
                                const PlaybackStateModel(
                                  position: Duration.zero,
                                  duration: Duration.zero,
                                  isPlaying: false,
                                );
                            return ProgressBar(
                              position: state.position,
                              duration: state.duration,
                              onSeek: provider.seek,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        PlayerControls(provider: provider),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
