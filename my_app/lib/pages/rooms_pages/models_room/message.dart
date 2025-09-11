class Message {
  final String id;
  final String text;
  final String author;
  final DateTime timestamp;
  final String? avatarUrl;

  Message({
    required this.id,
    required this.text,
    required this.author,
    required this.timestamp,
    this.avatarUrl,
  });
}