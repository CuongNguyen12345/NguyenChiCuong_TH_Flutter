class PlaylistModel {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImage;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverImage,
  });

  factory PlaylistModel.create(String name) {
    final now = DateTime.now();
    return PlaylistModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      songIds: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      songIds: List<String>.from(json['songIds'] as List<dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      coverImage: json['coverImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coverImage': coverImage,
    };
  }

  PlaylistModel copyWith({
    String? name,
    List<String>? songIds,
    DateTime? updatedAt,
    String? coverImage,
  }) {
    return PlaylistModel(
      id: id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      coverImage: coverImage ?? this.coverImage,
    );
  }
}
