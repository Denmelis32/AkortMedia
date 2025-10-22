class MediaItem {
  final String id;
  final String url;
  final String fileName;
  final DateTime uploadTime;
  final String? author;

  MediaItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.uploadTime,
    this.author,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
      uploadTime: DateTime.parse(json['uploadTime'] ?? DateTime.now().toString()),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'uploadTime': uploadTime.toIso8601String(),
      'author': author,
    };
  }
}