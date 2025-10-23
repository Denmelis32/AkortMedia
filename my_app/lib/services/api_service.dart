// lib/services/api_service.dart
import 'dart:convert'; // 🎯 ДОБАВЛЯЕМ ЭТОТ ИМПОРТ
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-id.apigw.yandexcloud.net';

  // 🎯 ДОБАВЛЯЕМ ПУБЛИЧНЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ ЗАГОЛОВКОВ
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // 🎯 ДОБАВЛЯЕМ ПУБЛИЧНЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ ТОКЕНА
  static Future<String?> getToken() async {
    return await AuthService.getToken();
  }

  static dynamic _handleResponse(http.Response response) {
    print('🔧 API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? json.decode(response.body) : null;
    } else {
      final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Ошибка сервера: ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  // ========== АВТОРИЗАЦИЯ ==========

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error (login): $e');
      throw Exception('Ошибка входа: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error (register): $e');
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // ========== НОВОСТИ ==========

  static Future<List<dynamic>> getNews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news'),
        headers: await _getHeaders(),
      );

      final newsList = _handleResponse(response) as List<dynamic>;
      return newsList.map((news) => _formatNewsItem(news)).toList();
    } catch (e) {
      print('❌ API Error (getNews): $e');
      throw Exception('Не удалось загрузить новости: $e');
    }
  }

  static Future<dynamic> createNews(Map<String, dynamic> newsData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/news'),
        headers: await _getHeaders(),
        body: json.encode(newsData),
      );

      final createdNews = _handleResponse(response);
      return _formatNewsItem(createdNews);
    } catch (e) {
      print('❌ API Error (createNews): $e');
      throw Exception('Не удалось создать новость: $e');
    }
  }

  // 🎯 ИСПРАВЛЯЕМ ОПЕЧАТКУ: static вместо tatic
  static Future<dynamic> updateNews(String newsId, Map<String, dynamic> newsData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: await _getHeaders(),
        body: json.encode(newsData),
      );

      final updatedNews = _handleResponse(response);
      return _formatNewsItem(updatedNews);
    } catch (e) {
      print('❌ API Error (updateNews): $e');
      throw Exception('Не удалось обновить новость: $e');
    }
  }

  // 🎯 ИСПРАВЛЯЕМ ОПЕЧАТКУ: static вместо tatic
  static Future<void> deleteNews(String newsId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      print('❌ API Error (deleteNews): $e');
      throw Exception('Не удалось удалить новость: $e');
    }
  }

  // ========== ВЗАИМОДЕЙСТВИЯ ==========

  static Future<void> toggleLikeNews(String newsId, bool isLiked) async {
    try {
      final endpoint = isLiked ? 'like' : 'unlike';
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/$endpoint'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      print('❌ API Error (toggleLikeNews): $e');
      throw Exception('Не удалось обновить лайк: $e');
    }
  }

  static Future<void> toggleBookmarkNews(String newsId, bool isBookmarked) async {
    try {
      final endpoint = isBookmarked ? 'bookmark' : 'unbookmark';
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/$endpoint'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      print('❌ API Error (toggleBookmarkNews): $e');
      throw Exception('Не удалось обновить закладку: $e');
    }
  }

  static Future<void> toggleRepostNews(String newsId, bool isReposted) async {
    try {
      final endpoint = isReposted ? 'repost' : 'unrepost';
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/$endpoint'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      print('❌ API Error (toggleRepostNews): $e');
      throw Exception('Не удалось обновить репост: $e');
    }
  }

  // ========== КОММЕНТАРИИ ==========

  static Future<dynamic> addComment(String newsId, Map<String, dynamic> comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/comments'),
        headers: await _getHeaders(),
        body: json.encode(comment),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error (addComment): $e');
      throw Exception('Не удалось добавить комментарий: $e');
    }
  }

  static Future<void> deleteComment(String newsId, String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/news/$newsId/comments/$commentId'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      print('❌ API Error (deleteComment): $e');
      throw Exception('Не удалось удалить комментарий: $e');
    }
  }

  // ========== ПРОФИЛЬ ==========

  static Future<dynamic> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(),
        body: json.encode(userData),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error (updateProfile): $e');
      throw Exception('Не удалось обновить профиль: $e');
    }
  }

  static Future<dynamic> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error (getUserProfile): $e');
      throw Exception('Не удалось загрузить профиль: $e');
    }
  }

  // ========== УТИЛИТЫ ==========

  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection check failed: $e');
      return false;
    }
  }

  static Future<List<dynamic>> searchNews(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/search?q=${Uri.encodeComponent(query)}'),
        headers: await _getHeaders(),
      );

      final newsList = _handleResponse(response) as List<dynamic>;
      return newsList.map((news) => _formatNewsItem(news)).toList();
    } catch (e) {
      print('❌ API Error (searchNews): $e');
      throw Exception('Не удалось выполнить поиск: $e');
    }
  }

  // 🎯 ФОРМАТИРОВАНИЕ НОВОСТИ ДЛЯ ЕДИНООБРАЗИЯ
  static Map<String, dynamic> _formatNewsItem(Map<String, dynamic> news) {
    return {
      'id': news['id'] ?? news['_id'] ?? 'unknown',
      'title': news['title'] ?? '',
      'description': news['description'] ?? '',
      'author_name': news['author_name'] ?? news['author']?['name'] ?? 'Неизвестный автор',
      'author_id': news['author_id'] ?? news['author']?['id'] ?? '',
      'author_avatar': news['author_avatar'] ?? news['author']?['avatar'] ?? '',
      'hashtags': news['hashtags'] ?? [],
      'user_tags': news['user_tags'] ?? {},
      'comments': news['comments'] ?? [],
      'likes': news['likes'] is int ? news['likes'] : (news['likes'] as List?)?.length ?? 0,
      'reposts': news['reposts'] ?? 0,
      'created_at': news['created_at'] ?? news['createdAt'] ?? DateTime.now().toIso8601String(),
      'isLiked': news['isLiked'] ?? false,
      'isBookmarked': news['isBookmarked'] ?? false,
      'isFollowing': news['isFollowing'] ?? false,
      'isReposted': news['isReposted'] ?? false,
      'is_repost': news['is_repost'] ?? false,
      'is_channel_post': news['is_channel_post'] ?? false,
    };
  }
}