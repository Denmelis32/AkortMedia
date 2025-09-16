// providers/articles_provider.dart
import 'package:flutter/foundation.dart';

class ArticlesProvider with ChangeNotifier {
  // Существующие статьи (если есть)
  final List<Map<String, dynamic>> _articles = [];

  // Статьи по каналам
  final Map<int, List<Map<String, dynamic>>> _channelArticles = {};

  // Методы для общих статей (если нужны)
  List<Map<String, dynamic>> get articles => _articles;

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

  void clearAllChannelArticles() {
    _channelArticles.clear();
    notifyListeners();
  }

  void clearAll() {
    _articles.clear();
    _channelArticles.clear();
    notifyListeners();
  }
}