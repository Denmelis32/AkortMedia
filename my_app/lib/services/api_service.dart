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
          'isLiked': news['isLiked'] ?? false,
          'isBookmarked': news['isBookmarked'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('API Error (getNews): $e');
      throw Exception('Не удалось загрузить новости: $e');
    }
  }

  // Создание новости
  static Future<dynamic> createNews(Map<String, dynamic> newsData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/news'),
        headers: headers,
        body: json.encode(newsData),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ Ошибка (createNews): $e');
      throw Exception('Не удалось создать новость: $e');
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
      throw Exception('Не удалось обновить лайк: $e');
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
      throw Exception('Не удалось обновить закладку: $e');
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
          'isBookmarked': true,
        };
      }).toList();
    } catch (e) {
      print('API Error (getBookmarks): $e');
      throw Exception('Не удалось загрузить закладки: $e');
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
      throw Exception('Не удалось добавить комментарий: $e');
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
      throw Exception('Не удалось удалить комментарий: $e');
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
      throw Exception('Не удалось обновить новость: $e');
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
      throw Exception('Не удалось удалить новость: $e');
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
      throw Exception('Не удалось выполнить поиск: $e');
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
      throw Exception('Не удалось загрузить новости по фильтру: $e');
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
      throw Exception('Не удалось загрузить данные пользователя: $e');
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
      throw Exception('Не удалось обновить профиль: $e');
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
      throw Exception('Не удалось загрузить новости по хештегу: $e');
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
      throw Exception('Не удалось загрузить посты канала: $e');
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
      throw Exception('Не удалось загрузить статистику: $e');
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
      throw Exception('Не удалось обновить тег: $e');
    }
  }

  // ========== ПРОВЕРКА ПОДКЛЮЧЕНИЯ ==========
  static Future<bool> checkConnection() async {
    try {
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