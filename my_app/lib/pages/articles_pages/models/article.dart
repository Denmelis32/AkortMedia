class Article {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String content;
  final int views;
  final int likes;
  final DateTime publishDate;
  final String category;
  final String author;
  final String imageUrl;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.content,
    required this.views,
    required this.likes,
    required this.publishDate,
    required this.category,
    required this.author,
    required this.imageUrl,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(publishDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}г назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}мес назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else {
      return 'только что';
    }
  }
}