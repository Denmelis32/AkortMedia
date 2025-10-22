import 'package:flutter/foundation.dart';
import 'package:my_app/pages/articles_pages/test_articles.dart';

class ArticlesProvider with ChangeNotifier {
  // Существующие статьи (если есть)
  final List<Map<String, dynamic>> _articles = [];

  // Статьи по каналам
  final Map<int, List<Map<String, dynamic>>> _channelArticles = {};

  // Получаем все статьи: тестовые + пользовательские
  List<Map<String, dynamic>> get articles {
    // Всегда объединяем тестовые статьи с пользовательскими
    return [...TestArticles.testArticles, ..._articles];
  }

  void addArticle(Map<String, dynamic> article) {
    _articles.insert(0, article);
    notifyListeners();
  }

  void loadArticles(List<Map<String, dynamic>> articles) {
    _articles.clear();
    _articles.addAll(articles);
    notifyListeners();
  }

  // Методы для статей по каналам
  List<Map<String, dynamic>> getArticlesForChannel(int channelId) {
    return _channelArticles[channelId] ?? [];
  }

  void loadArticlesForChannel(int channelId, List<Map<String, dynamic>> articles) {
    _channelArticles[channelId] = articles;
    notifyListeners();
  }

  void addArticleToChannel(int channelId, Map<String, dynamic> article) {
    if (!_channelArticles.containsKey(channelId)) {
      _channelArticles[channelId] = [];
    }
    _channelArticles[channelId]!.insert(0, article);
    notifyListeners();
  }

  void clearArticlesForChannel(int channelId) {
    if (_channelArticles.containsKey(channelId)) {
      _channelArticles[channelId]!.clear();
      notifyListeners();
    }
  }

  void removeArticle(String articleId) {
    // Удаляем только пользовательские статьи (не тестовые)
    if (_isUserArticle(articleId)) {
      _articles.removeWhere((article) => article['id'] == articleId);
      notifyListeners();
    }
  }

  void clearAllChannelArticles() {
    _channelArticles.clear();
    notifyListeners();
  }

  void clearAll() {
    _articles.clear();
    _channelArticles.clear();
    notifyListeners();
  }

  // Вспомогательные методы
  bool _isUserArticle(String articleId) {
    // Тестовые статьи имеют ID от 1 до 13
    final testIds = List.generate(13, (index) => (index + 1).toString());
    return !testIds.contains(articleId);
  }

  // Получить только пользовательские статьи
  List<Map<String, dynamic>> get userArticles => _articles;

  // Получить только тестовые статьи
  List<Map<String, dynamic>> get testArticles => TestArticles.testArticles;
}