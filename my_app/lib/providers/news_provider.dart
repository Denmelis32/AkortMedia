// lib/providers/news_provider.dart
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../../../services/api_service.dart';
import '../services/storage_service.dart';

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Пробуем загрузить из API
      final apiNews = await ApiService.getNews();

      // Загружаем локальные данные о лайках и закладках
      final localLikes = await StorageService.loadLikes();
      final localBookmarks = await StorageService.loadBookmarks();

      // Объединяем данные с API с локальными состояниями
      _news = apiNews.map((newsItem) {
        final newsId = newsItem['id'].toString();
        return {
          ...newsItem,
          'isLiked': localLikes.contains(newsId),
          'isBookmarked': localBookmarks.contains(newsId),
          'hashtags': newsItem['hashtags'] ?? [],
          'user_tags': newsItem['user_tags'] ?? {},
          'comments': newsItem['comments'] ?? [],
          'likes': newsItem['likes'] ?? 0,
        };
      }).toList();

      // Сохраняем в кэш
      await StorageService.saveNews(_news);
    } catch (e) {
      print('API Error: $e');
      _errorMessage = 'Ошибка загрузки данных';

      // Fallback: пробуем загрузить из кэша
      try {
        _news = await StorageService.loadNews();
        if (_news.isEmpty) {
          _news = _getMockNews();
        }
      } catch (cacheError) {
        print('Cache Error: $cacheError');
        _news = _getMockNews();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _getMockNews() {
    return [
      {
        "id": "1",
        "title": "Манчестер Сити выиграл Лигу Чемпионов",
        "description": "Манчестер Сити в драматичном матче обыграл Интер со счетом 1:0",
        "image": "⚽",
        "likes": 45,
        "author_name": "Администратор",
        "created_at": "2025-09-09T16:33:18.417Z",
        "comments": [],
        "hashtags": ["#футбол", "#лигачемпионов"],
        "user_tags": {"tag1": "Фанат Манчестера"},
        "isLiked": false,
        "isBookmarked": false,
      },
      {
        "id": "2",
        "title": "Новый сезон Formula 1",
        "description": "Начало нового сезона Formula 1 обещает быть захватывающим с новыми правилами и командами",
        "image": "🏎️",
        "likes": 23,
        "author_name": "Спортивный обозреватель",
        "created_at": "2025-09-08T10:15:30.123Z",
        "comments": [],
        "hashtags": ["#formula1", "#автоспорт"],
        "user_tags": {"tag1": "Болельщик"},
        "isLiked": false,
        "isBookmarked": false,
      }
    ];
  }

  void addNews(Map<String, dynamic> newsItem) {
    final completeNewsItem = {
      ...newsItem,
      'hashtags': newsItem['hashtags'] ?? [],
      'user_tags': newsItem['user_tags'] ?? {"tag1": "Новый тег"},
      'likes': newsItem['likes'] ?? 0,
      'comments': newsItem['comments'] ?? [],
      'isLiked': false,
      'isBookmarked': false,
      'created_at': newsItem['created_at'] ?? DateTime.now().toIso8601String(),
    };

    _news.insert(0, completeNewsItem);
    notifyListeners();
    StorageService.saveNews(_news);
  }

  void updateNews(int index, Map<String, dynamic> updatedNews) {
    if (index >= 0 && index < _news.length) {
      final originalNews = _news[index] as Map<String, dynamic>;
      final preservedFields = {
        'id': originalNews['id'],
        'author_name': originalNews['author_name'],
        'created_at': originalNews['created_at'],
        'likes': originalNews['likes'],
        'comments': originalNews['comments'],
        'isLiked': originalNews['isLiked'],
        'isBookmarked': originalNews['isBookmarked'],
      };

      _news[index] = {
        ...preservedFields,
        ...updatedNews,
        'hashtags': updatedNews['hashtags'] ?? originalNews['hashtags'],
        'user_tags': updatedNews['user_tags'] ?? originalNews['user_tags'],
      };

      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  // Обновление статуса лайка
  void updateNewsLikeStatus(int index, bool isLiked, int newLikesCount) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      _news[index] = {
        ...newsItem,
        'isLiked': isLiked,
        'likes': newLikesCount,
      };

      notifyListeners();

      // Сохраняем в локальное хранилище
      if (isLiked) {
        StorageService.addLike(newsId);
      } else {
        StorageService.removeLike(newsId);
      }

      StorageService.saveNews(_news);
    }
  }

  // Обновление статуса закладки
  void updateNewsBookmarkStatus(int index, bool isBookmarked) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      _news[index] = {
        ...newsItem,
        'isBookmarked': isBookmarked,
      };

      notifyListeners();

      // Сохраняем в локальное хранилище
      if (isBookmarked) {
        StorageService.addBookmark(newsId);
      } else {
        StorageService.removeBookmark(newsId);
      }

      StorageService.saveNews(_news);
    }
  }

  void addCommentToNews(int index, Map<String, dynamic> comment) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;

      if (newsItem['comments'] == null) {
        newsItem['comments'] = [];
      }

      newsItem['comments'].insert(0, comment);
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  void removeCommentFromNews(int index, String commentId) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;

      if (newsItem['comments'] != null) {
        newsItem['comments'].removeWhere((comment) => comment['id'] == commentId);
        notifyListeners();
        StorageService.saveNews(_news);
      }
    }
  }

  void removeNews(int index) async {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      try {
        await ApiService.deleteNews(newsId);
      } catch (e) {
        print('API delete error: $e');
      }

      // Удаляем из локальных хранилищ
      await StorageService.removeLike(newsId);
      await StorageService.removeBookmark(newsId);

      _news.removeAt(index);
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }
  Future<void> loadUserTags() async {
    try {
      final loadedTags = await StorageService.loadUserTags();

      // Обновляем теги в новостях
      for (var i = 0; i < _news.length; i++) {
        final newsItem = _news[i] as Map<String, dynamic>;
        final newsId = newsItem['id'].toString();

        if (loadedTags.containsKey(newsId)) {
          _news[i] = {
            ...newsItem,
            'user_tags': loadedTags[newsId],
          };
        }
      }

      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки тегов: $e');
    }
  }






  void updateNewsHashtags(int index, List<String> hashtags) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      _news[index] = {
        ...newsItem,
        'hashtags': hashtags,
      };
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  void updateNewsUserTag(int index, String tagId, String newTagName, {Color? color}) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      final updatedUserTags = {
        ...newsItem['user_tags'] ?? {},
        tagId: newTagName,
      };

      final updatedNews = {
        ...newsItem,
        'user_tags': updatedUserTags,
      };

      if (color != null) {
        updatedNews['tag_color'] = color.value;
        // Сохраняем цвет в отдельном хранилище
        StorageService.updateUserTag(newsId, tagId, newTagName, color: color.value);
      }

      _news[index] = updatedNews;
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  // Поиск новостей
  List<dynamic> searchNews(String query) {
    if (query.isEmpty) return _news;

    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      final title = newsItem['title']?.toString().toLowerCase() ?? '';
      final description = newsItem['description']?.toString().toLowerCase() ?? '';
      final hashtags = (newsItem['hashtags'] is List
          ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
          : '');
      final author = newsItem['author_name']?.toString().toLowerCase() ?? '';

      return title.contains(query.toLowerCase()) ||
          description.contains(query.toLowerCase()) ||
          hashtags.contains(query.toLowerCase()) ||
          author.contains(query.toLowerCase());
    }).toList();
  }

  // Получение избранных новостей
  List<dynamic> getBookmarkedNews() {
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['isBookmarked'] == true;
    }).toList();
  }

  // Получение популярных новостей (лайков > 5)
  List<dynamic> getPopularNews() {
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return (newsItem['likes'] ?? 0) > 5;
    }).toList();
  }

  // Получение моих новостей
  List<dynamic> getMyNews(String userName) {
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['author_name'] == userName;
    }).toList();
  }


  // Очистка всех данных
  Future<void> clearAllData() async {
    _news = [];
    _isLoading = false;
    _errorMessage = null;
    await StorageService.clearAllData();
    notifyListeners();
  }
}