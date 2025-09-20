// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5001/api';

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
        };
      }).toList();
    } catch (e) {
      print('API Error (getNews): $e');
      rethrow;
    }
  }

  static Future<dynamic> createNews(Map<String, dynamic> newsData) async {
    try {
      print('🔄 Отправка данных на сервер...');

      // ИМИТАЦИЯ УСПЕШНОГО ОТВЕТА СЕРВЕРА
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки

      return {
        "id": "server-${DateTime.now().millisecondsSinceEpoch}",
        "title": newsData['title'],
        "description": newsData['description'],
        "hashtags": newsData['hashtags'] ?? [],
        "likes": 0,
        "author_name": "Текущий пользователь",
        "created_at": DateTime.now().toIso8601String(),
        "comments": [],
        "user_tags": {},
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
          'isBookmarked': true, // Помечаем как закладку
        };
      }).toList();
    } catch (e) {
      print('API Error (getBookmarks): $e');
      rethrow;
    }
  }

  // Добавить комментарий
  static Future<dynamic> addComment(String newsId, Map<String, dynamic> comment) async {
    try {
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
      rethrow;
    }
  }

  // Получить новости по фильтру
  static Future<List<dynamic>> getNewsByFilter(String filter) async {
    try {
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
      rethrow;
    }
  }

  // ========== ПОЛЬЗОВАТЕЛИ ==========
  static Future<dynamic> getUser(String userId) async {
    try {
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
      rethrow;
    }
  }

  // ========== КАНАЛЫ ==========
  static Future<List<Map<String, dynamic>>> getChannelPosts(String channelId) async {
    try {
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
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createChannelPost(Map<String, dynamic> postData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/channels/${postData['channel_id']}/posts'),
        headers: headers,
        body: json.encode(postData),
      );

      final newPost = _handleResponse(response);
      return {
        "id": newPost['id'] ?? "channel-post-${DateTime.now().millisecondsSinceEpoch}",
        "title": newPost['title'] ?? postData['title'],
        "description": newPost['description'] ?? postData['description'],
        "hashtags": newPost['hashtags'] is List ? newPost['hashtags'] : (postData['hashtags'] ?? []),
        "likes": newPost['likes'] ?? 0,
        "author_name": newPost['author_name'] ?? "Администратор канала",
        "created_at": newPost['created_at'] ?? DateTime.now().toIso8601String(),
        "channel_id": newPost['channel_id'] ?? postData['channel_id'],
        "isLiked": false,
        "isBookmarked": false,
      };
    } catch (e) {
      print('API Error (createChannelPost): $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getChannelArticles(String channelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/channels/$channelId/articles'),
        headers: headers,
      );

      final articlesList = _handleResponse(response) as List<dynamic>;
      return articlesList.map((article) {
        return {
          'id': article['id'] ?? 'unknown-id',
          'title': article['title'] ?? '',
          'description': article['description'] ?? '',
          'content': article['content'] ?? '',
          'emoji': article['emoji'] ?? '📝',
          'category': article['category'] ?? 'Общая',
          'views': article['views'] ?? 0,
          'likes': article['likes'] ?? 0,
          'author': article['author'] ?? 'Неизвестный автор',
          'publish_date': article['publish_date'] ?? DateTime.now().toIso8601String(),
          'image_url': article['image_url'] ?? 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop',
          'channel_id': article['channel_id'] ?? channelId,
          'channel_name': article['channel_name'] ?? 'Неизвестный канал',
          'isLiked': article['isLiked'] ?? false,
          'isBookmarked': article['isBookmarked'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('API Error (getChannelArticles): $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createChannelArticle(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/channels/${data['channel_id']}/articles'),
        headers: headers,
        body: json.encode(data),
      );

      final newArticle = _handleResponse(response);
      return {
        'id': newArticle['id'] ?? 'article-${DateTime.now().millisecondsSinceEpoch}',
        'title': newArticle['title'] ?? data['title'],
        'description': newArticle['description'] ?? data['description'],
        'content': newArticle['content'] ?? data['content'],
        'emoji': newArticle['emoji'] ?? data['emoji'] ?? '📝',
        'category': newArticle['category'] ?? data['category'] ?? 'Общая',
        'views': newArticle['views'] ?? 0,
        'likes': newArticle['likes'] ?? 0,
        'author': newArticle['author'] ?? 'Администратор канала',
        'publish_date': newArticle['publish_date'] ?? DateTime.now().toIso8601String(),
        'image_url': newArticle['image_url'] ?? 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop',
        'channel_id': newArticle['channel_id'] ?? data['channel_id'],
        'channel_name': newArticle['channel_name'] ?? 'Название канала',
        'isLiked': false,
        'isBookmarked': false,
      };
    } catch (e) {
      print('API Error (createChannelArticle): $e');
      rethrow;
    }
  }

  // ========== СТАТИСТИКА ==========
  static Future<Map<String, dynamic>> getNewsStats(String newsId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news/$newsId/stats'),
        headers: headers,
      );

      return _handleResponse(response) ?? {};
    } catch (e) {
      print('API Error (getNewsStats): $e');
      rethrow;
    }
  }

  // ========== УПРАВЛЕНИЕ ПОЛЬЗОВАТЕЛЬСКИМИ ТЕГАМИ ==========
  static Future<void> updateUserTag(String newsId, String tagId, String tagName, {int? color}) async {
    try {
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
}