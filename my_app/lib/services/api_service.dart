// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'network_service.dart';

class ApiService {
  static const String baseUrl = 'https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net';

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
    print('🔧 CLOUD Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final data = json.decode(response.body);
          print('📊 Decoded data type: ${data.runtimeType}');

          // 🎯 УЛУЧШЕННЫЙ ПАРСИНГ ДЛЯ ТВОЕГО ФОРМАТА
          if (data is Map && data.containsKey('success') && data['success'] == true) {
            if (data.containsKey('data')) {
              print('✅ Using data field with ${data['data'].length} items');
              return data['data'];
            }
            if (data.containsKey('news')) {
              print('✅ Using news field with ${data['news'].length} items');
              return data['news'];
            }
          }

          // Если другой формат, возвращаем как есть
          return data;
        } catch (e) {
          print('❌ JSON Parse Error: $e');
          return [];
        }
      }
      return [];
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      throw Exception('HTTP ${response.statusCode}');
    }
  }
  // ========== АВТОРИЗАЦИЯ ==========

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ CLOUD Error (login): $e');
      throw Exception('Ошибка входа: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
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
      print('🌐 Loading news from CLOUD YDB...');
      final response = await http.get(
        Uri.parse('$baseUrl/getNews'),
        headers: await _getHeaders(),
      );

      print('🔧 Raw API Response: ${response.statusCode}');
      print('📦 Response body length: ${response.body.length}');

      final result = _handleResponse(response);
      print('🎯 Parsed result type: ${result.runtimeType}');

      List<dynamic> newsList = [];

      if (result is List) {
        newsList = result;
        print('✅ Direct list with ${newsList.length} items');
      } else if (result is Map) {
        // 🎯 ПРЕОБРАЗУЕМ В Map<String, dynamic>
        final resultMap = result is Map<String, dynamic>
            ? result
            : (result as Map<dynamic, dynamic>).cast<String, dynamic>();

        if (resultMap.containsKey('data') && resultMap['data'] is List) {
          newsList = resultMap['data'];
          print('✅ Data list with ${newsList.length} items');
        } else if (resultMap.containsKey('news') && resultMap['news'] is List) {
          newsList = resultMap['news'];
          print('✅ News list with ${newsList.length} items');
        } else if (resultMap.containsKey('items') && resultMap['items'] is List) {
          newsList = resultMap['items'];
          print('✅ Items list with ${newsList.length} items');
        }
      }

      // 🎯 ОБРАБАТЫВАЕМ КАЖДУЮ НОВОСТЬ С ПРАВИЛЬНЫМ ТИПОМ
      final formattedNews = newsList.map((news) {
        return _formatNewsItem(news);
      }).toList();

      print('✅ FINAL: Loaded ${formattedNews.length} news from YDB');

      // 🎯 ЛОГИРУЕМ ПЕРВЫЕ 2 ПОСТА ДЛЯ ДЕБАГА
      if (formattedNews.isNotEmpty) {
        print('📋 Sample posts:');
        for (int i = 0; i < formattedNews.length && i < 2; i++) {
          final post = formattedNews[i];
          print('  ${i + 1}. ${post['title']} by ${post['author_name']}');
        }
      }

      return formattedNews;
    } catch (e) {
      print('❌ YDB Error (getNews): $e');
      return [];
    }
  }

  static List<dynamic> _getMockNews() {
    return [
      {
        'id': 'mock-1',
        'title': 'Облачный сервер работает! 🚀',
        'description': 'Но возникла временная ошибка подключения',
        'author_name': 'Система',
        'author_id': 'system',
        'author_avatar': '',
        'likes': 2,
        'reposts': 0,
        'comments': [],
        'hashtags': ['резерв'],
        'created_at': DateTime.now().toIso8601String(),
        'isLiked': false,
        'isBookmarked': false,
        'isReposted': false,
        'isFollowing': false
      }
    ];
  }

  static Future<Map<String, dynamic>> createNews(Map<String, dynamic> newsData) async {
    try {
      final newsWithAuthor = {
        ...newsData,
        'author_id': newsData['author_id'] ?? 'unknown',
        'author_name': newsData['author_name'] ?? 'Пользователь',
        'author_avatar': newsData['author_avatar'] ?? '',
      };

      print('🌐 Creating news in YDB: ${newsWithAuthor['title']}');

      final response = await http.post(
        Uri.parse('$baseUrl/createNews'),
        headers: await _getHeaders(),
        body: json.encode(newsWithAuthor),
      );

      final result = _handleResponse(response);
      print('🔧 Create news result type: ${result.runtimeType}');

      dynamic createdNews;

      if (result is Map) {
        // 🎯 ПРЕОБРАЗУЕМ В Map<String, dynamic>
        final resultMap = result is Map<String, dynamic>
            ? result
            : (result as Map<dynamic, dynamic>).cast<String, dynamic>();

        if (resultMap.containsKey('news')) {
          createdNews = resultMap['news'];
        } else if (resultMap.containsKey('data')) {
          createdNews = resultMap['data'];
        } else {
          createdNews = resultMap;
        }
      } else {
        createdNews = result;
      }

      if (createdNews != null) {
        // 🎯 ОБЕСПЕЧИВАЕМ ПРАВИЛЬНЫЙ ТИП ДЛЯ _formatNewsItem
        final formattedNews = _formatNewsItem(createdNews);
        print('✅ News created in YDB: ${formattedNews['id']}');
        return formattedNews;
      } else {
        print('❌ Invalid news data received: $createdNews');
        throw Exception('Invalid news data received from server');
      }
    } catch (e) {
      print('❌ YDB Error (createNews): $e');
      throw Exception('Не удалось создать новость: $e');
    }
  }






  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      final isLoggedIn = token != null && userData != null;
      print('🔐 Login status: $isLoggedIn (token: ${token != null}, user: ${userData != null})');

      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> updateNews(String newsId, Map<String, dynamic> newsData) async {
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

      final result = _handleResponse(response);
      return result['status'] == 'OK';
    } catch (e) {
      print('❌ YDB Connection check failed: $e');
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
  static Map<String, dynamic> _formatNewsItem(dynamic news) {
    // 🎯 ПРЕОБРАЗУЕМ ЛЮБОЙ ТИП В Map<String, dynamic>
    final Map<String, dynamic> newsMap;

    if (news is Map<String, dynamic>) {
      newsMap = news;
    } else if (news is Map<dynamic, dynamic>) {
      newsMap = news.cast<String, dynamic>();
    } else {
      newsMap = {};
    }

    return {
      'id': newsMap['id']?.toString() ?? newsMap['_id']?.toString() ?? 'unknown',
      'title': newsMap['title']?.toString() ?? '',
      'description': newsMap['description']?.toString() ?? '',
      'author_name': newsMap['author_name']?.toString() ?? newsMap['author']?['name']?.toString() ?? 'Неизвестный автор',
      'author_id': newsMap['author_id']?.toString() ?? newsMap['author']?['id']?.toString() ?? '',
      'author_avatar': newsMap['author_avatar']?.toString() ?? newsMap['author']?['avatar']?.toString() ?? '',
      'hashtags': _parseHashtags(newsMap['hashtags']),
      'user_tags': _parseUserTags(newsMap['user_tags']),
      'comments': _parseComments(newsMap['comments']),
      'likes': _parseLikes(newsMap['likes']),
      'reposts': _parseInt(newsMap['reposts']) ?? 0,
      'created_at': newsMap['created_at']?.toString() ?? newsMap['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      'isLiked': newsMap['isLiked'] == true,
      'isBookmarked': newsMap['isBookmarked'] == true,
      'isFollowing': newsMap['isFollowing'] == true,
      'isReposted': newsMap['isReposted'] == true,
      'is_repost': newsMap['is_repost'] == true,
      'is_channel_post': newsMap['is_channel_post'] == true,
    };
  }
  static List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is List<String>) {
      return hashtags;
    } else if (hashtags is List<dynamic>) {
      return hashtags.map((item) => item.toString()).toList();
    }
    return [];
  }

  static Map<String, String> _parseUserTags(dynamic userTags) {
    if (userTags is Map<String, String>) {
      return userTags;
    } else if (userTags is Map<dynamic, dynamic>) {
      return userTags.cast<String, String>();
    }
    return {};
  }

  static List<dynamic> _parseComments(dynamic comments) {
    if (comments is List<dynamic>) {
      return comments;
    }
    return [];
  }

  static int _parseLikes(dynamic likes) {
    if (likes is int) {
      return likes;
    } else if (likes is List) {
      return likes.length;
    } else if (likes is String) {
      return int.tryParse(likes) ?? 0;
    }
    return 0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}


class HttpException implements Exception {
  final String message;
  final Uri? uri;
  final String? body;

  HttpException(this.message, {this.uri, this.body});

  @override
  String toString() {
    return 'HttpException: $message${uri != null ? ' ($uri)' : ''}${body != null ? ' - $body' : ''}';
  }
}