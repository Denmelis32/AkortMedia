

class Article {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime publishDate;
  final String category;
  final String imageUrl;
  final int readTime; // в минутах
  final int views;
  final int likes;
  final List<String> likedBy;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.publishDate,
    required this.category,
    this.imageUrl = '',
    this.readTime = 5,
    this.views = 0,
    this.likes = 0,
    this.likedBy = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'publishDate': publishDate.toIso8601String(),
      'category': category,
      'imageUrl': imageUrl,
      'readTime': readTime,
      'views': views,
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      publishDate: DateTime.parse(json['publishDate']),
      category: json['category'],
      imageUrl: json['imageUrl'],
      readTime: json['readTime'],
      views: json['views'],
      likes: json['likes'],
      likedBy: List<String>.from(json['likedBy']),
    );
  }

  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    DateTime? publishDate,
    String? category,
    String? imageUrl,
    int? readTime,
    int? views,
    int? likes,
    List<String>? likedBy,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      publishDate: publishDate ?? this.publishDate,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      readTime: readTime ?? this.readTime,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}// TODO Implement this library.