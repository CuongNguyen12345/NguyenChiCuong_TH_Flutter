import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/music_library_service.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/song_tile.dart';

class AllSongsScreen extends StatelessWidget {
  const AllSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return RefreshIndicator(
          onRefresh: audioProvider.loadLibrary,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'All songs',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Import audio files',
                            onPressed: audioProvider.pickLocalFiles,
                            icon: const Icon(Icons.add_rounded),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'Refresh library',
                            onPressed: audioProvider.loadLibrary,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${audioProvider.allSongs.length} songs in library',
                        style: const TextStyle(color: AppColors.mutedText),
                      ),
                      if (!audioProvider.hasPermission)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.lock_open_rounded,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Storage/audio permission is needed to scan songs. You can still import files manually.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (audioProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            audioProvider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      if (audioProvider.recentSongs.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _RecentlyPlayed(provider: audioProvider),
                      ],
                      const SizedBox(height: 12),
                      _LibraryControls(provider: audioProvider),
                    ],
                  ),
                ),
              ),
              if (audioProvider.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (audioProvider.visibleSongs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyLibrary(onImport: audioProvider.pickLocalFiles),
                )
              else
                SliverList.builder(
                  itemCount: audioProvider.visibleSongs.length,
                  itemBuilder: (context, index) {
                    final song = audioProvider.visibleSongs[index];
                    return SongTile(
                      song: song,
                      isActive: audioProvider.currentSong?.id == song.id,
                      onTap: () => audioProvider.playSong(
                        song,
                        queue: audioProvider.visibleSongs,
                      ),
                      onAddToPlaylist: () => _showAddToPlaylist(context, song),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylist(BuildContext context, SongModel song) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      showDragHandle: true,
      builder: (context) {
        return Consumer<PlaylistProvider>(
          builder: (context, playlistProvider, child) {
            final playlists = playlistProvider.playlists;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to playlist',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (playlists.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('Create a playlist first.'),
                      )
                    else
                      ...playlists.map(
                        (playlist) => ListTile(
                          leading: const Icon(Icons.queue_music_rounded),
                          title: Text(playlist.name),
                          subtitle: Text('${playlist.songIds.length} songs'),
                          onTap: () async {
                            await playlistProvider.addSong(playlist.id, song);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RecentlyPlayed extends StatelessWidget {
  const _RecentlyPlayed({required this.provider});

  final AudioProvider provider;

  @override
  Widget build(BuildContext context) {
    final songs = provider.recentSongs.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recently played', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final song = songs[index];
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => provider.playSong(song, queue: songs),
                child: SizedBox(
                  width: 112,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AlbumArt(song: song, size: 84, borderRadius: 8),
                      const SizedBox(height: 8),
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LibraryControls extends StatelessWidget {
  const _LibraryControls({required this.provider});

  final AudioProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: provider.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Search title, artist or album',
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterMenu(
                      label: _sortLabel(provider.sortMode),
                      icon: Icons.sort_rounded,
                      items: SongSortMode.values
                          .map(
                            (mode) => PopupMenuItem<SongSortMode>(
                              value: mode,
                              child: Text(_sortLabel(mode)),
                            ),
                          )
                          .toList(),
                      onSelected: provider.setSortMode,
                    ),
                    const SizedBox(width: 8),
                    _FilterMenu<String?>(
                      label: provider.artistFilter ?? 'Artist',
                      icon: Icons.person_rounded,
                      items: [
                        const PopupMenuItem<String?>(
                          value: null,
                          child: Text('All artists'),
                        ),
                        ...provider.artists.map(
                          (artist) => PopupMenuItem<String?>(
                            value: artist,
                            child: Text(artist),
                          ),
                        ),
                      ],
                      onSelected: provider.setArtistFilter,
                    ),
                    const SizedBox(width: 8),
                    _FilterMenu<String?>(
                      label: provider.albumFilter ?? 'Album',
                      icon: Icons.album_rounded,
                      items: [
                        const PopupMenuItem<String?>(
                          value: null,
                          child: Text('All albums'),
                        ),
                        ...provider.albums.map(
                          (album) => PopupMenuItem<String?>(
                            value: album,
                            child: Text(album),
                          ),
                        ),
                      ],
                      onSelected: provider.setAlbumFilter,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Clear filters',
              onPressed: provider.clearFilters,
              icon: const Icon(Icons.filter_alt_off_rounded),
            ),
          ],
        ),
      ],
    );
  }

  String _sortLabel(SongSortMode mode) {
    switch (mode) {
      case SongSortMode.artist:
        return 'Artist';
      case SongSortMode.album:
        return 'Album';
      case SongSortMode.dateAdded:
        return 'Date added';
      case SongSortMode.title:
        return 'Title';
    }
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.icon,
    required this.items,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      color: AppColors.card,
      onSelected: onSelected,
      itemBuilder: (context) => items,
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        backgroundColor: AppColors.card,
        side: BorderSide.none,
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_music_rounded,
            size: 72,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text('No songs found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Import local audio files or grant storage permission to scan the device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedText),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Import files'),
          ),
        ],
      ),
    );
  }
}
