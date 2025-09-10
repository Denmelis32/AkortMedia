// lib/providers/news_provider.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;

  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Пробуем загрузить из API
      _news = await ApiService.getNews();
      // Сохраняем в кэш
      await StorageService.saveNews(_news);
    } catch (e) {
      print('API Error: $e');
      // Fallback: пробуем загрузить из кэша
      _news = await StorageService.loadNews();

      // Если в кэше пусто, используем mock данные с хештегами
      if (_news.isEmpty) {
        _news = [
          {
            "id": "1",
            "title": "Манчестер Сити выиграл Лигу Чемпионов",
            "description": "Манчестер Сити в драматичном матче обыграл Интер со счетом 1:0",
            "image": "⚽",
            "likes": 45,
            "author_name": "Администратор",
            "created_at": "2025-09-09T16:33:18.417Z",
            "comments": [],
            "hashtags": ["#футбол", "#лигачемпионов"]
          }
        ];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void addNews(Map<String, dynamic> newsItem) {
    // Убедимся, что хештеги есть в новом посте
    if (!newsItem.containsKey('hashtags')) {
      newsItem['hashtags'] = [];
    }

    _news.insert(0, newsItem);
    notifyListeners();
    // Сохраняем в кэш при добавлении
    StorageService.saveNews(_news);
  }

  // НОВЫЙ МЕТОД ДЛЯ ОБНОВЛЕНИЯ НОВОСТИ
  void updateNews(int index, Map<String, dynamic> updatedNews) {
    if (index >= 0 && index < _news.length) {
      // Сохраняем комментарии из старой новости, если они есть
      if (_news[index]['comments'] != null) {
        updatedNews['comments'] = _news[index]['comments'];
      }

      // Сохраняем лайки из старой новости, если они есть
      if (_news[index]['likes'] != null) {
        updatedNews['likes'] = _news[index]['likes'];
      }

      // Сохраняем ID из старой новости
      if (_news[index]['id'] != null) {
        updatedNews['id'] = _news[index]['id'];
      }

      // Сохраняем автора из старой новости
      if (_news[index]['author_name'] != null) {
        updatedNews['author_name'] = _news[index]['author_name'];
      }

      // Сохраняем дату создания из старой новости
      if (_news[index]['created_at'] != null) {
        updatedNews['created_at'] = _news[index]['created_at'];
      }

      // Обновляем новость
      _news[index] = updatedNews;
      notifyListeners();

      // Сохраняем в кэш
      StorageService.saveNews(_news);
    }
  }

  void updateNewsLikes(int index, int newLikes) {
    _news[index]['likes'] = newLikes;
    notifyListeners();
    StorageService.saveNews(_news);
  }

  void addCommentToNews(int index, Map<String, dynamic> comment) {
    if (_news[index]['comments'] == null) {
      _news[index]['comments'] = [];
    }
    _news[index]['comments'].add(comment);
    notifyListeners();
    StorageService.saveNews(_news);
  }

  void removeNews(int index) async {
    if (index >= 0 && index < _news.length) {
      final news = _news[index];

      try {
        // Убеждаемся, что ID преобразован в строку
        await ApiService.deleteNews(news['id'].toString());
      } catch (e) {
        print('API delete error: $e');
        // Продолжаем даже если API запрос не удался
      }

      _news.removeAt(index);
      notifyListeners();
      // Сохраняем изменения в кэш
      StorageService.saveNews(_news);
    }
  }

  void updateNewsHashtags(int index, List<String> hashtags) {
    if (index >= 0 && index < _news.length) {
      _news[index]['hashtags'] = hashtags;
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }
}