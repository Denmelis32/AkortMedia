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

  // Получение постов канала
  static Future<List<Map<String, dynamic>>> getChannelPosts(String channelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/channels/$channelId/posts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> postsList = json.decode(response.body);
        // Преобразуем в List<Map<String, dynamic>> и убедимся, что есть все необходимые поля
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
          };
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация для просмотра постов канала');
      } else {
        throw Exception('Failed to load channel posts: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Создание поста канала
  static Future<Map<String, dynamic>> createChannelPost(Map<String, dynamic> postData) async {
    try {
      final headers = await _getHeaders();

      // Убедимся, что хештеги есть в данных
      if (!postData.containsKey('hashtags')) {
        postData['hashtags'] = [];
      }

      final response = await http.post(
        Uri.parse('$baseUrl/channels/${postData['channel_id']}/posts'),
        headers: headers,
        body: json.encode(postData),
      );

      if (response.statusCode == 201) {
        final newPost = json.decode(response.body);
        return {
          "id": newPost['id'] ?? "channel-post-${DateTime.now().millisecondsSinceEpoch}",
          "title": newPost['title'] ?? postData['title'],
          "description": newPost['description'] ?? postData['description'],
          "hashtags": newPost['hashtags'] is List ? newPost['hashtags'] : (postData['hashtags'] ?? []),
          "likes": newPost['likes'] ?? 0,
          "author_name": newPost['author_name'] ?? "Администратор канала",
          "created_at": newPost['created_at'] ?? DateTime.now().toIso8601String(),
          "channel_id": newPost['channel_id'] ?? postData['channel_id'],
        };
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация для создания постов канала');
      } else {
        throw Exception('Failed to create channel post: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Получение статей канала
  static Future<List<Map<String, dynamic>>> getChannelArticles(String channelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/channels/$channelId/articles'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> articlesList = json.decode(response.body);
        // Преобразуем в List<Map<String, dynamic>> и убедимся, что есть все необходимые поля
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
          };
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация для просмотра статей канала');
      } else {
        throw Exception('Failed to load channel articles: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Создание статьи канала
  static Future<Map<String, dynamic>> createChannelArticle(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/channels/${data['channel_id']}/articles'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final newArticle = json.decode(response.body);
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
        };
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация для создания статей канала');
      } else {
        throw Exception('Failed to create channel article: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
}