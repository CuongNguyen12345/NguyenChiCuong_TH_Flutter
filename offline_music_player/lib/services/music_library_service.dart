import 'package:file_picker/file_picker.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;

import '../models/song_model.dart';

enum SongSortMode { title, artist, album, dateAdded }

class MusicLibraryService {
  final audio_query.OnAudioQuery _audioQuery = audio_query.OnAudioQuery();

  Future<List<SongModel>> loadDeviceSongs({
    SongSortMode sortMode = SongSortMode.title,
  }) async {
    final songs = await _audioQuery.querySongs(
      sortType: _mapSortType(sortMode),
      orderType: audio_query.OrderType.ASC_OR_SMALLER,
      uriType: audio_query.UriType.EXTERNAL,
      ignoreCase: true,
    );
    return songs
        .where((song) => song.data.isNotEmpty)
        .map(SongModel.fromAudioQuery)
        .toList();
  }

  Future<List<SongModel>> pickAudioFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'm4a', 'aac', 'wav', 'flac', 'ogg'],
    );

    if (result == null) {
      return const [];
    }

    return result.paths
        .whereType<String>()
        .map(SongModel.fromFilePath)
        .toList(growable: false);
  }

  audio_query.SongSortType _mapSortType(SongSortMode sortMode) {
    switch (sortMode) {
      case SongSortMode.artist:
        return audio_query.SongSortType.ARTIST;
      case SongSortMode.album:
        return audio_query.SongSortType.ALBUM;
      case SongSortMode.dateAdded:
        return audio_query.SongSortType.DATE_ADDED;
      case SongSortMode.title:
        return audio_query.SongSortType.TITLE;
    }
  }
}
