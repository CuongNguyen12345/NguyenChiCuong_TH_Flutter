import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isActive = false,
    this.onAddToPlaylist,
    this.onRemove,
  });

  final SongModel song;
  final VoidCallback onTap;
  final bool isActive;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AlbumArt(song: song, size: 54, borderRadius: 6),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.text,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${song.artist} - ${song.album ?? AppText.unknownAlbum}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.mutedText),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (song.duration != null)
            Text(
              formatDuration(song.duration!),
              style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          PopupMenuButton<String>(
            tooltip: 'Song options',
            color: AppColors.card,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.mutedText,
            ),
            onSelected: (value) {
              if (value == 'playlist') {
                onAddToPlaylist?.call();
              }
              if (value == 'remove') {
                onRemove?.call();
              }
              if (value == 'info') {
                _showInfo(context);
              }
            },
            itemBuilder: (context) => [
              if (onAddToPlaylist != null)
                const PopupMenuItem(
                  value: 'playlist',
                  child: Text('Add to playlist'),
                ),
              if (onRemove != null)
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove from playlist'),
                ),
              const PopupMenuItem(value: 'info', child: Text('Song info')),
            ],
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _InfoRow(label: 'Artist', value: song.artist),
                _InfoRow(
                  label: 'Album',
                  value: song.album ?? AppText.unknownAlbum,
                ),
                _InfoRow(
                  label: 'Duration',
                  value: song.duration == null
                      ? '--:--'
                      : formatDuration(song.duration!),
                ),
                _InfoRow(label: 'Path', value: song.filePath),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppColors.mutedText),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
