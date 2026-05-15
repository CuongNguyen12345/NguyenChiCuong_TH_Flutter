import 'dart:io';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/song_model.dart';
import '../utils/color_extractor.dart';
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.song,
    this.size = 56,
    this.borderRadius = 8,
  });

  final SongModel? song;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final currentSong = song;
    final color = ColorExtractor.colorFromText(currentSong?.title ?? 'music');

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, AppColors.card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildArtwork(currentSong),
      ),
    );
  }

  Widget _buildArtwork(SongModel? currentSong) {
    if (currentSong?.albumArt != null) {
      final file = File(currentSong!.albumArt!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
        );
      }
    }
    final mediaStoreId = int.tryParse(currentSong?.id ?? '');
    if (mediaStoreId != null) {
      return QueryArtworkWidget(
        id: mediaStoreId,
        type: ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkFit: BoxFit.cover,
        artworkBorder: BorderRadius.circular(borderRadius),
        keepOldArtwork: true,
        nullArtworkWidget: _fallbackIcon(),
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
      );
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Icon(
      Icons.music_note_rounded,
      color: Colors.white.withValues(alpha: 0.92),
      size: size * 0.44,
    );
  }
}
