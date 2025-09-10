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

  // GET запрос для новостей
  static Future<List<dynamic>> getNews() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final newsList = json.decode(response.body);
        // Убедимся, что у всех новостей есть поле hashtags
        for (var news in newsList) {
          if (!news.containsKey('hashtags')) {
            news['hashtags'] = [];
          }
        }
        return newsList;
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // POST запрос для создания новости
  static Future<dynamic> createNews(Map<String, dynamic> newsData) async {
    try {
      final headers = await _getHeaders();

      // Убедимся, что хештеги есть в данных
      if (!newsData.containsKey('hashtags')) {
        newsData['hashtags'] = [];
      }

      final response = await http.post(
        Uri.parse('$baseUrl/news'),
        headers: headers,
        body: json.encode(newsData),
      );

      if (response.statusCode == 201) {
        final newNews = json.decode(response.body);
        // Убедимся, что в ответе есть хештеги
        if (!newNews.containsKey('hashtags')) {
          newNews['hashtags'] = newsData['hashtags'] ?? [];
        }
        return newNews;
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация для создания новостей');
      } else {
        throw Exception('Failed to create news: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Добавить лайк к новости
  static Future<void> likeNews(String newsId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/like'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to like news: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Убрать лайк с новости
  static Future<void> unlikeNews(String newsId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/unlike'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unlike news: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Добавить комментарий
  static Future<void> addComment(String newsId, Map<String, dynamic> comment) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/comments'),
        headers: headers,
        body: json.encode(comment),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Обновить новость
  static Future<dynamic> updateNews(String newsId, Map<String, dynamic> newsData) async {
    try {
      final headers = await _getHeaders();

      // Убедимся, что хештеги есть в данных
      if (!newsData.containsKey('hashtags')) {
        newsData['hashtags'] = [];
      }

      final response = await http.put(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: headers,
        body: json.encode(newsData),
      );

      if (response.statusCode == 200) {
        final updatedNews = json.decode(response.body);
        // Убедимся, что в ответе есть хештеги
        if (!updatedNews.containsKey('hashtags')) {
          updatedNews['hashtags'] = newsData['hashtags'] ?? [];
        }
        return updatedNews;
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация для редактирования новостей');
      } else {
        throw Exception('Failed to update news: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
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

      if (response.statusCode != 200) {
        throw Exception('Failed to delete news: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Получить пользователя по ID
  static Future<dynamic> getUser(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Обновить профиль пользователя
  static Future<dynamic> updateProfile(Map<String, dynamic> userData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Дополнительный метод для получения новостей по хештегу
  static Future<List<dynamic>> getNewsByHashtag(String hashtag) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/news?hashtag=${Uri.encodeComponent(hashtag)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final newsList = json.decode(response.body);
        // Убедимся, что у всех новостей есть поле hashtags
        for (var news in newsList) {
          if (!news.containsKey('hashtags')) {
            news['hashtags'] = [];
          }
        }
        return newsList;
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else {
        throw Exception('Failed to load news by hashtag: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
}