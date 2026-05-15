import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart' as audio_query;

import '../utils/constants.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final String? sourceUri;
  final Duration? duration;
  final String? albumArt;
  final int? fileSize;
  final DateTime? dateAdded;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.sourceUri,
    this.duration,
    this.albumArt,
    this.fileSize,
    this.dateAdded,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String? ?? AppText.unknownArtist,
      album: json['album'] as String?,
      filePath: json['filePath'] as String,
      sourceUri: json['sourceUri'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(milliseconds: json['duration'] as int),
      albumArt: json['albumArt'] as String?,
      fileSize: json['fileSize'] as int?,
      dateAdded: json['dateAdded'] == null
          ? null
          : DateTime.tryParse(json['dateAdded'] as String),
    );
  }

  factory SongModel.fromAudioQuery(audio_query.SongModel audioModel) {
    final seconds = audioModel.dateAdded;
    return SongModel(
      id: audioModel.id.toString(),
      title: _cleanTitle(audioModel.title, audioModel.displayNameWOExt),
      artist: _cleanValue(audioModel.artist, AppText.unknownArtist),
      album: _cleanValue(audioModel.album, AppText.unknownAlbum),
      filePath: audioModel.data,
      sourceUri: audioModel.uri ?? _fallbackMediaUri(audioModel.id),
      duration: Duration(milliseconds: audioModel.duration ?? 0),
      fileSize: audioModel.size,
      dateAdded: seconds == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
    );
  }

  factory SongModel.fromFilePath(String filePath) {
    final file = File(filePath);
    final stat = file.existsSync() ? file.statSync() : null;
    final rawName = file.uri.pathSegments.isEmpty
        ? filePath
        : file.uri.pathSegments.last;
    final title = rawName
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .replaceAll('_', ' ');

    return SongModel(
      id: filePath,
      title: title.isEmpty ? 'Local audio' : title,
      artist: AppText.unknownArtist,
      album: AppText.unknownAlbum,
      filePath: filePath,
      fileSize: stat?.size,
      dateAdded: stat?.modified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'sourceUri': sourceUri,
      'duration': duration?.inMilliseconds,
      'albumArt': albumArt,
      'fileSize': fileSize,
      'dateAdded': dateAdded?.toIso8601String(),
    };
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    String? sourceUri,
    Duration? duration,
    String? albumArt,
    int? fileSize,
    DateTime? dateAdded,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      sourceUri: sourceUri ?? this.sourceUri,
      duration: duration ?? this.duration,
      albumArt: albumArt ?? this.albumArt,
      fileSize: fileSize ?? this.fileSize,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  static String _cleanTitle(String? title, String fallback) {
    final value = title?.trim();
    if (value == null || value.isEmpty || value == '<unknown>') {
      return fallback;
    }
    return value;
  }

  static String _cleanValue(String? value, String fallback) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty || cleaned == '<unknown>') {
      return fallback;
    }
    return cleaned;
  }

  static String _fallbackMediaUri(int id) {
    return 'content://media/external/audio/media/$id';
  }
}
