// lib/pages/cards_page/models/discussion.dart
class Discussion {
  final String id;
  final String title;
  final String author;
  final DateTime createdAt;
  final int commentsCount;
  final int likes;
  final bool isPinned;

  Discussion({
    required this.id,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.commentsCount,
    required this.likes,
    this.isPinned = false,
  });
}