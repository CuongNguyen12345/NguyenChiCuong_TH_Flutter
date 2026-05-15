import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/playlist_card.dart';
import '../widgets/song_tile.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Playlists',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showPlaylistDialog(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.playlists.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No playlists yet.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList.builder(
                  itemCount: provider.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = provider.playlists[index];
                    return PlaylistCard(
                      playlist: playlist,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              PlaylistDetailScreen(playlistId: playlist.id),
                        ),
                      ),
                      onRename: () =>
                          _showPlaylistDialog(context, playlist: playlist),
                      onDelete: () => provider.deletePlaylist(playlist.id),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        );
      },
    );
  }

  void _showPlaylistDialog(BuildContext context, {PlaylistModel? playlist}) {
    final controller = TextEditingController(text: playlist?.name ?? '');
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(playlist == null ? 'Create playlist' : 'Rename playlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Playlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final provider = context.read<PlaylistProvider>();
                if (playlist == null) {
                  await provider.createPlaylist(controller.text);
                } else {
                  await provider.renamePlaylist(playlist.id, controller.text);
                }
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistProvider, AudioProvider>(
      builder: (context, playlistProvider, audioProvider, child) {
        final playlist = _findPlaylist(playlistProvider.playlists);
        if (playlist == null) {
          return const Scaffold(
            body: Center(child: Text('Playlist not found.')),
          );
        }
        final songs = audioProvider.songsByIds(playlist.songIds);

        return Scaffold(
          appBar: AppBar(title: Text(playlist.name)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${songs.length} songs',
                        style: const TextStyle(color: AppColors.mutedText),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: songs.isEmpty
                          ? null
                          : () => audioProvider.playSong(
                              songs.first,
                              queue: songs,
                            ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: songs.isEmpty
                    ? const Center(
                        child: Text('Add songs from the All songs screen.'),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: songs.length,
                        onReorder: (oldIndex, newIndex) {
                          playlistProvider.moveSong(
                            playlist.id,
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return SongTile(
                            key: ValueKey(song.id),
                            song: song,
                            isActive: audioProvider.currentSong?.id == song.id,
                            onTap: () =>
                                audioProvider.playSong(song, queue: songs),
                            onRemove: () => playlistProvider.removeSong(
                              playlist.id,
                              song.id,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  PlaylistModel? _findPlaylist(List<PlaylistModel> playlists) {
    for (final playlist in playlists) {
      if (playlist.id == playlistId) {
        return playlist;
      }
    }
    return null;
  }
}
