class NewsPost {
  final String id;
  final String userName;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  NewsPost({
    required this.id,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.likedBy = const [],
  });

  // Метод для преобразования в JSON (для сохранения)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  // Метод для создания из JSON (для загрузки)
  factory NewsPost.fromJson(Map<String, dynamic> json) {
    return NewsPost(
      id: json['id'],
      userName: json['userName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'],
      likedBy: List<String>.from(json['likedBy']),
    );
  }

  // Метод для копирования с изменениями
  NewsPost copyWith({
    String? id,
    String? userName,
    String? content,
    DateTime? timestamp,
    int? likes,
    List<String>? likedBy,
  }) {
    return NewsPost(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}