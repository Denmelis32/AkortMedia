// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5001/api';
  static const bool _useMockData = true; // Флаг для использования мок-данных

  // Получение headers с токеном авторизации
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Обработка ответов API
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? json.decode(response.body) : null;
    } else if (response.statusCode == 401) {
      throw Exception('Необходима авторизация');
    } else if (response.statusCode == 404) {
      throw Exception('Ресурс не найден');
    } else if (response.statusCode >= 500) {
      throw Exception('Ошибка сервера');
    } else {
      throw Exception('Ошибка запроса: ${response.statusCode}');
    }
  }

  // GET запрос для новостей
  static Future<List<dynamic>> getNews() async {
    try {
      // Если используем мок-данные
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500)); // Имитация задержки
        return _getMockNews();
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news'),
        headers: headers,
      );

      final newsList = _handleResponse(response) as List<dynamic>;

      // Убедимся, что у всех новостей есть все необходимые поля
      return newsList.map((news) {
        return {
          ...news,
          'hashtags': news['hashtags'] ?? [],
          'user_tags': news['user_tags'] ?? {},
          'comments': news['comments'] ?? [],
          'likes': news['likes'] ?? 0,
          'isLiked': news['isLiked'] ?? false,
          'isBookmarked': news['isBookmarked'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('API Error (getNews): $e');
      // Fallback на мок-данные при ошибке
      return _getMockNews();
    }
  }

  // Мок-данные для новостей
  static List<dynamic> _getMockNews() {
    return [
      {
        "id": "1",
        "title": "Манчестер Сити выиграл Лигу Чемпионов",
        "description": "Манчестер Сити в драматичном матче обыграл Интер со счетом 1:0",
        "image": "⚽",
        "likes": 45,
        "author_name": "Администратор",
        "created_at": "2025-09-09T16:33:18.417Z",
        "comments": [
          {
            "id": "comment_1",
            "author": "Фанат",
            "text": "Отличная игра!",
            "time": "2025-09-09T17:00:00.000Z"
          }
        ],
        "hashtags": ["футбол", "лигачемпионов"],
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
        "hashtags": ["formula1", "автоспорт"],
        "user_tags": {"tag1": "Болельщик"},
        "isLiked": false,
        "isBookmarked": false,
      },
      {
        "id": "3",
        "title": "Привет",
        "description": "каваф",
        "image": "",
        "likes": 0,
        "author_name": "Маринцев",
        "created_at": DateTime.now().subtract(const Duration(minutes: 6)).toIso8601String(),
        "comments": [],
        "hashtags": ["вфывфы", "вывыфф"],
        "user_tags": {"tag1": "БУК"},
        "isLiked": false,
        "isBookmarked": false,
      }
    ];
  }

  static Future<dynamic> createNews(Map<String, dynamic> newsData) async {
    try {
      print('🔄 Отправка данных на сервер...');

      // ИМИТАЦИЯ УСПЕШНОГО ОТВЕТА СЕРВЕРА
      await Future.delayed(const Duration(seconds: 1));

      return {
        "id": "server-${DateTime.now().millisecondsSinceEpoch}",
        "title": newsData['title'],
        "description": newsData['description'],
        "hashtags": newsData['hashtags'] ?? [],
        "likes": 0,
        "author_name": "Текущий пользователь",
        "created_at": DateTime.now().toIso8601String(),
        "comments": [],
        "user_tags": {"tag1": "Новый тег"},
        "isLiked": false,
        "isBookmarked": false,
      };

    } catch (e) {
      print('❌ Ошибка (createNews): $e');
      rethrow;
    }
  }

  // Лайк/дизлайк новости
  static Future<void> toggleLikeNews(String newsId, bool isLiked) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        print('👍 Лайк обновлен для новости $newsId: $isLiked');
        return;
      }

      final headers = await _getHeaders();
      final endpoint = isLiked ? 'like' : 'unlike';

      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/$endpoint'),
        headers: headers,
      );

      _handleResponse(response);
    } catch (e) {
      print('API Error (toggleLikeNews): $e');
      rethrow;
    }
  }

  // Добавить/удалить закладку
  static Future<void> toggleBookmarkNews(String newsId, bool isBookmarked) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        print('🔖 Закладка обновлена для новости $newsId: $isBookmarked');
        return;
      }

      final headers = await _getHeaders();
      final endpoint = isBookmarked ? 'bookmark' : 'unbookmark';

      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/$endpoint'),
        headers: headers,
      );

      _handleResponse(response);
    } catch (e) {
      print('API Error (toggleBookmarkNews): $e');
      rethrow;
    }
  }

  // Получить закладки пользователя
  static Future<List<dynamic>> getBookmarks() async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        final allNews = _getMockNews();
        // Возвращаем только некоторые новости как закладки для примера
        return allNews.take(2).map((news) => {
          ...news,
          'isBookmarked': true,
        }).toList();
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/bookmarks'),
        headers: headers,
      );

      final bookmarks = _handleResponse(response) as List<dynamic>;
      return bookmarks.map((news) {
        return {
          ...news,
          'hashtags': news['hashtags'] ?? [],
          'user_tags': news['user_tags'] ?? {},
          'comments': news['comments'] ?? [],
          'likes': news['likes'] ?? 0,
          'isBookmarked': true,
        };
      }).toList();
    } catch (e) {
      print('API Error (getBookmarks): $e');
      return [];
    }
  }

  // Добавить комментарий
  static Future<dynamic> addComment(String newsId, Map<String, dynamic> comment) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        return {
          "id": "comment_${DateTime.now().millisecondsSinceEpoch}",
          "author": comment['author'] ?? "Пользователь",
          "text": comment['text'],
          "time": DateTime.now().toIso8601String(),
        };
      }

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/comments'),
        headers: headers,
        body: json.encode(comment),
      );

      return _handleResponse(response);
    } catch (e) {
      print('API Error (addComment): $e');
      rethrow;
    }
  }

  // Удалить комментарий
  static Future<void> deleteComment(String newsId, String commentId) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        print('🗑️ Комментарий удален: $commentId');
        return;
      }

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/news/$newsId/comments/$commentId'),
        headers: headers,
      );

      _handleResponse(response);
    } catch (e) {
      print('API Error (deleteComment): $e');
      rethrow;
    }
  }

  // Обновить новость
  static Future<dynamic> updateNews(String newsId, Map<String, dynamic> newsData) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return {
          "id": newsId,
          "title": newsData['title'],
          "description": newsData['description'],
          "hashtags": newsData['hashtags'] ?? [],
          "user_tags": newsData['user_tags'] ?? {"tag1": "Обновленный тег"},
          "likes": 0,
          "author_name": "Текущий пользователь",
          "created_at": DateTime.now().toIso8601String(),
          "comments": [],
          "isLiked": false,
          "isBookmarked": false,
        };
      }

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: headers,
        body: json.encode(newsData),
      );

      final updatedNews = _handleResponse(response);
      return {
        ...updatedNews,
        'hashtags': updatedNews['hashtags'] ?? newsData['hashtags'] ?? [],
        'user_tags': updatedNews['user_tags'] ?? newsData['user_tags'] ?? {},
      };
    } catch (e) {
      print('API Error (updateNews): $e');
      rethrow;
    }
  }

  // Удалить новость
  static Future<void> deleteNews(String newsId) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        print('🗑️ Новость удалена: $newsId');
        return;
      }

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: headers,
      );

      _handleResponse(response);
    } catch (e) {
      print('API Error (deleteNews): $e');
      rethrow;
    }
  }

  // Поиск новостей
  static Future<List<dynamic>> searchNews(String query) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        final allNews = _getMockNews();
        if (query.isEmpty) return allNews;

        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final description = news['description']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();

          return title.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase()) ||
              hashtags.contains(query.toLowerCase());
        }).toList();
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/search?q=${Uri.encodeComponent(query)}'),
        headers: headers,
      );

      final newsList = _handleResponse(response) as List<dynamic>;
      return newsList.map((news) {
        return {
          ...news,
          'hashtags': news['hashtags'] ?? [],
          'user_tags': news['user_tags'] ?? {},
          'comments': news['comments'] ?? [],
          'likes': news['likes'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('API Error (searchNews): $e');
      return [];
    }
  }

  // Получить новости по фильтру
  static Future<List<dynamic>> getNewsByFilter(String filter) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        final allNews = _getMockNews();

        switch (filter) {
          case 'popular':
            return allNews.where((news) => (news['likes'] ?? 0) > 10).toList();
          case 'recent':
            return allNews;
          case 'my':
            return allNews.where((news) => news['author_name'] == 'Маринцев').toList();
          default:
            return allNews;
        }
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/filter?type=$filter'),
        headers: headers,
      );

      final newsList = _handleResponse(response) as List<dynamic>;
      return newsList.map((news) {
        return {
          ...news,
          'hashtags': news['hashtags'] ?? [],
          'user_tags': news['user_tags'] ?? {},
          'comments': news['comments'] ?? [],
          'likes': news['likes'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('API Error (getNewsByFilter): $e');
      return [];
    }
  }

  // ========== ПОЛЬЗОВАТЕЛИ ==========
  static Future<dynamic> getUser(String userId) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        return {
          "id": userId,
          "name": "Текущий пользователь",
          "email": "user@example.com",
          "avatar": "",
          "created_at": "2025-01-01T00:00:00.000Z"
        };
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      print('API Error (getUser): $e');
      rethrow;
    }
  }

  static Future<dynamic> updateProfile(Map<String, dynamic> userData) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return {
          "id": "current-user",
          "name": userData['name'] ?? "Текущий пользователь",
          "email": userData['email'] ?? "user@example.com",
          "avatar": userData['avatar'] ?? "",
          "updated_at": DateTime.now().toIso8601String()
        };
      }

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
        body: json.encode(userData),
      );

      return _handleResponse(response);
    } catch (e) {
      print('API Error (updateProfile): $e');
      rethrow;
    }
  }

  // ========== ХЕШТЕГИ ==========
  static Future<List<dynamic>> getNewsByHashtag(String hashtag) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        final allNews = _getMockNews();
        return allNews.where((news) {
          final hashtags = (news['hashtags'] as List).map((h) => h.toString().toLowerCase()).toList();
          return hashtags.contains(hashtag.toLowerCase());
        }).toList();
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news?hashtag=${Uri.encodeComponent(hashtag)}'),
        headers: headers,
      );

      final newsList = _handleResponse(response) as List<dynamic>;
      return newsList.map((news) {
        return {
          ...news,
          'hashtags': news['hashtags'] ?? [],
          'user_tags': news['user_tags'] ?? {},
          'comments': news['comments'] ?? [],
          'likes': news['likes'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('API Error (getNewsByHashtag): $e');
      return [];
    }
  }

  // ========== КАНАЛЫ ==========
  static Future<List<Map<String, dynamic>>> getChannelPosts(String channelId) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return [
          {
            'id': 'channel-post-1',
            'title': 'Важное объявление',
            'description': 'У нас большие новости!',
            'hashtags': ['важное', 'объявление'],
            'likes': 15,
            'author_name': 'Администратор канала',
            'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            'channel_id': channelId,
            'isLiked': false,
            'isBookmarked': false,
          }
        ];
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/channels/$channelId/posts'),
        headers: headers,
      );

      final postsList = _handleResponse(response) as List<dynamic>;
      return postsList.map((post) {
        return {
          'id': post['id'] ?? 'unknown-id',
          'title': post['title'] ?? '',
          'description': post['description'] ?? '',
          'hashtags': post['hashtags'] is List ? post['hashtags'] : [],
          'likes': post['likes'] ?? 0,
          'author_name': post['author_name'] ?? 'Неизвестный автор',
          'created_at': post['created_at'] ?? DateTime.now().toIso8601String(),
          'channel_id': post['channel_id'] ?? channelId,
          'isLiked': post['isLiked'] ?? false,
          'isBookmarked': post['isBookmarked'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('API Error (getChannelPosts): $e');
      return [];
    }
  }

  // ========== СТАТИСТИКА ==========
  static Future<Map<String, dynamic>> getNewsStats(String newsId) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        return {
          'views': 150,
          'likes': 45,
          'comments': 3,
          'shares': 12,
        };
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/$newsId/stats'),
        headers: headers,
      );

      return _handleResponse(response) ?? {};
    } catch (e) {
      print('API Error (getNewsStats): $e');
      return {};
    }
  }

  // ========== УПРАВЛЕНИЕ ПОЛЬЗОВАТЕЛЬСКИМИ ТЕГАМИ ==========
  static Future<void> updateUserTag(String newsId, String tagId, String tagName, {int? color}) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        print('🎨 Тег обновлен: $tagName для новости $newsId');
        return;
      }

      final headers = await _getHeaders();
      final data = {
        'tag_id': tagId,
        'tag_name': tagName,
        if (color != null) 'color': color,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/news/$newsId/user-tags'),
        headers: headers,
        body: json.encode(data),
      );

      _handleResponse(response);
    } catch (e) {
      print('API Error (updateUserTag): $e');
      rethrow;
    }
  }

  // ========== ПРОВЕРКА ПОДКЛЮЧЕНИЯ ==========
  static Future<bool> checkConnection() async {
    try {
      if (_useMockData) {
        return true;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }
}