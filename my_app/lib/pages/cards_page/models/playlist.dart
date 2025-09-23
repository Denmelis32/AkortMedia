// models/playlist.dart
class Playlist {
  final String id;
  final String title;
  final int videoCount;
  final String thumbnailUrl;
  final String? description;
  final DateTime? createdAt;
  final int? viewCount;
  final int? likeCount;
  final bool? isPublic;

  const Playlist({
    required this.id,
    required this.title,
    required this.videoCount,
    required this.thumbnailUrl,
    this.description,
    this.createdAt,
    this.viewCount,
    this.likeCount,
    this.isPublic = true,
  });

  // Метод для преобразования в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'videoCount': videoCount,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isPublic': isPublic,
    };
  }

  // Фабричный метод для создания из Map
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      title: map['title'],
      videoCount: map['videoCount'],
      thumbnailUrl: map['thumbnailUrl'],
      description: map['description'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      viewCount: map['viewCount'],
      likeCount: map['likeCount'],
      isPublic: map['isPublic'] ?? true,
    );
  }

  // Метод для копирования с изменениями
  Playlist copyWith({
    String? id,
    String? title,
    int? videoCount,
    String? thumbnailUrl,
    String? description,
    DateTime? createdAt,
    int? viewCount,
    int? likeCount,
    bool? isPublic,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      videoCount: videoCount ?? this.videoCount,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  String toString() {
    return 'Playlist{id: $id, title: $title, videoCount: $videoCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Playlist &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}