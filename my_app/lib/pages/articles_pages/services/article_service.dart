import '../models/article.dart';
import '../widgets/article_card.dart';

class ArticleService {
  static const defaultImageUrl = 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop';
  static const defaultAvatarUrl = 'https://via.placeholder.com/150/007bff/ffffff?text=U';

  static AuthorLevel parseAuthorLevel(dynamic authorLevelData) {
    if (authorLevelData == null) return AuthorLevel.beginner;
    if (authorLevelData is String) {
      return authorLevelData.toLowerCase() == 'expert' ? AuthorLevel.expert : AuthorLevel.beginner;
    }
    return AuthorLevel.beginner;
  }

  static DateTime parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    try {
      if (dateData is String) return DateTime.parse(dateData);
      if (dateData is DateTime) return dateData;
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static Article articleFromMap(Map<String, dynamic> articleData) {
    return Article(
      id: articleData['id']?.toString() ?? '',
      title: articleData['title'] ?? '',
      description: articleData['description'] ?? '',
      emoji: articleData['emoji'] ?? '📝',
      content: articleData['content'] ?? '',
      views: (articleData['views'] as int?) ?? 0,
      likes: (articleData['likes'] as int?) ?? 0,
      publishDate: parseDate(articleData['publish_date']),
      category: articleData['category'] ?? 'Общее',
      author: articleData['author'] ?? 'Неизвестный автор',
      imageUrl: articleData['image_url'] ?? defaultImageUrl,
      authorLevel: parseAuthorLevel(articleData['author_level']),
    );
  }
}