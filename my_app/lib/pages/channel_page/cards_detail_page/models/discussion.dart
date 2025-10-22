// lib/pages/cards_detail_page/models/discussion.dart
class Discussion {
  final String id;
  final String title;
  final String author;
  final DateTime createdAt;
  final int commentsCount;
  final int likes;
  final bool isPinned;
  final String? previewText; // Добавлено
  final String? category; // Добавлено
  final bool? isResolved; // Добавлено
  final bool? isClosed; // Добавлено

  Discussion({
    required this.id,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.commentsCount,
    required this.likes,
    this.isPinned = false,
    this.previewText, // Добавлено
    this.category, // Добавлено
    this.isResolved, // Добавлено
    this.isClosed, // Добавлено
  });
}