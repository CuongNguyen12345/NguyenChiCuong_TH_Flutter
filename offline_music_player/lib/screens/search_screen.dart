import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: TextField(
                controller: _controller,
                autofocus: false,
                onChanged: provider.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: provider.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _controller.clear();
                            provider.search('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  hintText: 'Search songs, artists, albums',
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.visibleSongs.isEmpty
                  ? const Center(child: Text('No matching songs.'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: provider.visibleSongs.length,
                      itemBuilder: (context, index) {
                        final SongModel song = provider.visibleSongs[index];
                        return SongTile(
                          song: song,
                          isActive: provider.currentSong?.id == song.id,
                          onTap: () => provider.playSong(
                            song,
                            queue: provider.visibleSongs,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
