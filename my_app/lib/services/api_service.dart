import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net';
  static const int timeoutSeconds = 10;

  static String? _cachedToken;

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString('auth_token');
      return _cachedToken;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Akort-Media-App/1.0',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('success') && data['success'] == true) {
          return data.containsKey('data') ? data['data'] : data;
        } else if (data.containsKey('error')) {
          throw HttpException(data['error'] ?? 'Unknown error');
        }
        return data;
      } catch (e) {
        throw HttpException('Invalid response format');
      }
    } else {
      _handleErrorResponse(response);
    }
  }

  static void _handleErrorResponse(http.Response response) {
    switch (response.statusCode) {
      case 400: throw HttpException('Bad request');
      case 401: throw HttpException('Authentication required');
      case 403: throw HttpException('Access denied');
      case 404: throw HttpException('Resource not found');
      case 429: throw HttpException('Too many requests');
      case 500: throw HttpException('Internal server error');
      case 502: throw HttpException('Bad gateway');
      case 503: throw HttpException('Service unavailable');
      default: throw HttpException('HTTP ${response.statusCode}');
    }
  }

  // 🟢 АВТОРИЗАЦИЯ И РЕГИСТРАЦИЯ
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('token')) {
        await AuthService.saveToken(result['token']);
        if (result.containsKey('user')) {
          await AuthService.saveUser(Map<String, dynamic>.from(result['user']));
        }
        _cachedToken = result['token']; // Кэшируем токен
      }

      return result is Map<String, dynamic> ? result : {'success': true};
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('token')) {
        await AuthService.saveToken(result['token']);
        if (result.containsKey('user')) {
          await AuthService.saveUser(Map<String, dynamic>.from(result['user']));
        }
        _cachedToken = result['token']; // Кэшируем токен
      }

      return result is Map<String, dynamic> ? result : {'success': true};
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  // 🟢 НОВОСТИ
  static Future<List<dynamic>> getNews({
    int page = 0,
    int limit = 20,
    String? authorId,
    bool refresh = false,
  }) async {
    try {
      final headers = await _getHeaders();

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (authorId != null) 'authorId': authorId,
        if (refresh) 'refresh': 'true',
      };

      final uri = Uri.parse('$baseUrl/getNews').replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      List<dynamic> newsList = [];

      if (result is Map && result.containsKey('news')) {
        newsList = result['news'] is List ? result['news'] : [];
      } else if (result is List) {
        newsList = result;
      }

      final formattedNews = newsList.map((news) {
        return _formatNewsItem(news);
      }).toList();

      return formattedNews;
    } catch (e) {
      print('❌ getNews error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createNews(Map<String, dynamic> newsData) async {
    try {
      if (newsData['content'] == null || newsData['content'].toString().trim().isEmpty) {
        throw HttpException('Content is required');
      }

      final preparedData = {
        'title': newsData['title']?.toString().trim() ?? 'Без названия',
        'content': newsData['content'].toString().trim(),
        'author_name': newsData['author_name']?.toString() ?? 'Пользователь',
        'author_avatar': newsData['author_avatar']?.toString() ?? '',
        'hashtags': newsData['hashtags'] is List ? newsData['hashtags'] : [],
      };

      final headers = await _getHeaders();

      final response = await http
          .post(
        Uri.parse('$baseUrl/createNews'),
        headers: headers,
        body: json.encode(preparedData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      dynamic createdNews;

      if (result is Map) {
        createdNews = result.containsKey('news') ? result['news'] : result;
      } else {
        createdNews = result;
      }

      if (createdNews != null) {
        return _formatNewsItem(createdNews);
      }

      throw Exception('Failed to create news');
    } catch (e) {
      print('❌ Create news error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateNews(String newsId, Map<String, dynamic> updateData) async {
    try {
      final headers = await _getHeaders();

      final requestData = {
        'newsId': newsId,
        'updateData': {
          if (updateData['title'] != null) 'title': updateData['title'],
          if (updateData['content'] != null) 'content': updateData['content'],
          if (updateData['hashtags'] != null) 'hashtags': updateData['hashtags'],
        },
      };

      final response = await http
          .post(
        Uri.parse('$baseUrl/updateNews'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      return _formatNewsItem(result);
    } catch (e) {
      print('❌ Update news error: $e');
      rethrow;
    }
  }

  static Future<bool> deleteNews(String newsId) async {
    try {
      final headers = await _getHeaders();
      final requestData = {'newsId': newsId};

      final response = await http
          .post(
        Uri.parse('$baseUrl/deleteNews'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      _handleResponse(response);
      return true;
    } catch (e) {
      print('❌ Delete news error: $e');
      rethrow;
    }
  }

  // 🟢 СОЦИАЛЬНЫЕ ВЗАИМОДЕЙСТВИЯ
  static Future<Map<String, dynamic>> likeNews(String newsId) async {
    return _handleAction('like', newsId);
  }

  static Future<Map<String, dynamic>> unlikeNews(String newsId) async {
    return _handleAction('unlike', newsId);
  }

  static Future<Map<String, dynamic>> bookmarkNews(String newsId) async {
    return _handleAction('bookmark', newsId);
  }

  static Future<Map<String, dynamic>> unbookmarkNews(String newsId) async {
    return _handleAction('unbookmark', newsId);
  }

  static Future<Map<String, dynamic>> repostNews(String newsId) async {
    return _handleAction('repost', newsId);
  }

  static Future<Map<String, dynamic>> unrepostNews(String newsId) async {
    return _handleAction('unrepost', newsId);
  }

  static Future<Map<String, dynamic>> checkLike(String newsId) async {
    return _handleAction('check_like', newsId);
  }

  static Future<Map<String, dynamic>> _handleAction(String action, String newsId) async {
    try {
      final headers = await _getHeaders();
      final requestData = {'action': action, 'newsId': newsId};

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: 5));

      final result = _handleResponse(response);
      return _ensureStringMap(result);
    } catch (e) {
      print('❌ Action $action error: $e');
      rethrow;
    }
  }

  // 🟢 КОММЕНТАРИИ - ОБНОВЛЕННЫЙ МЕТОД
  static Future<Map<String, dynamic>> addComment(
      String newsId, String text, String userName) async {
    try {
      final headers = await _getHeaders();
      final requestData = {
        'action': 'comment',
        'newsId': newsId,
        'text': text.trim(),
        'author_name': userName,
      };

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: 5));

      final result = _handleResponse(response);
      dynamic commentData;

      if (result is Map && result.containsKey('comment')) {
        commentData = result['comment'];
      } else {
        commentData = result;
      }

      return _formatComment(commentData);
    } catch (e) {
      print('❌ Add comment error: $e');
      rethrow;
    }
  }

  // 🟢 ПОЛУЧЕНИЕ КОММЕНТАРИЕВ - ОБНОВЛЕННЫЙ МЕТОД
  static Future<List<dynamic>> getComments(String newsId) async {
    try {
      final headers = await _getHeaders();

      final response = await http
          .get(
        Uri.parse('$baseUrl/getComments?newsId=$newsId'),
        headers: headers,
      )
          .timeout(const Duration(seconds: 5));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('comments')) {
        final comments = result['comments'] is List ? result['comments'] : [];
        return comments.map((comment) => _formatComment(comment)).toList();
      }

      print('✅ Got empty comments list from server');
      return [];
    } catch (e) {
      print('❌ Get comments error, returning empty list: $e');
      // 🎯 ВОЗВРАЩАЕМ ПУСТОЙ СПИСОК ВМЕСТО ОШИБКИ
      return [];
    }
  }

  // 🟢 ПОДПИСКИ
  static Future<Map<String, dynamic>> followUser(String targetUserId) async {
    try {
      final headers = await _getHeaders();
      final requestData = {'targetUserId': targetUserId};

      final response = await http
          .post(
        Uri.parse('$baseUrl/follow'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: 5));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Follow user error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(String targetUserId) async {
    try {
      final headers = await _getHeaders();
      final requestData = {'targetUserId': targetUserId};

      final response = await http
          .post(
        Uri.parse('$baseUrl/unfollow'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: 5));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Unfollow user error: $e');
      rethrow;
    }
  }

  // 🟢 ПОЛЬЗОВАТЕЛИ
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/getUserProfile').replace(queryParameters: {
        'userId': userId,
      });

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      return _formatUserProfile(result);
    } catch (e) {
      print('❌ Get user profile error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserByPath(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      return _formatUserProfile(result);
    } catch (e) {
      print('❌ Get user by path error: $e');
      rethrow;
    }
  }

  // 🟢 ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ
  static Future<List<dynamic>> getUserLikes() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('$baseUrl/user/likes'),
        headers: headers,
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('likes')) {
        return result['likes'] is List ? result['likes'] : [];
      }

      return [];
    } catch (e) {
      print('❌ Get user likes error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getUserBookmarks() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('$baseUrl/user/bookmarks'),
        headers: headers,
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('bookmarks')) {
        return result['bookmarks'] is List ? result['bookmarks'] : [];
      }

      return [];
    } catch (e) {
      print('❌ Get user bookmarks error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getUserReposts() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('$baseUrl/user/reposts'),
        headers: headers,
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('reposts')) {
        return result['reposts'] is List ? result['reposts'] : [];
      }

      return [];
    } catch (e) {
      print('❌ Get user reposts error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getUserFollowing() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('$baseUrl/user/following'),
        headers: headers,
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('following')) {
        return result['following'] is List ? result['following'] : [];
      }

      return [];
    } catch (e) {
      print('❌ Get user following error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getUserFollowers() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('$baseUrl/user/followers'),
        headers: headers,
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('followers')) {
        return result['followers'] is List ? result['followers'] : [];
      }

      return [];
    } catch (e) {
      print('❌ Get user followers error: $e');
      return [];
    }
  }

  // 🟢 СИСТЕМНЫЕ ФУНКЦИИ
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getSystemMetrics() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
        Uri.parse('$baseUrl/metrics'),
        headers: headers,
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Get metrics error: $e');
      rethrow;
    }
  }

  // 🟢 ФОРМАТИРОВАНИЕ ДАННЫХ
  static Map<String, dynamic> _formatNewsItem(dynamic news) {
    final newsMap = _ensureStringMap(news);

    return {
      'id': _getSafeString(newsMap['id']),
      'title': _getSafeString(newsMap['title']) ?? 'Без названия',
      'content': _getSafeString(newsMap['content']) ?? '',
      'author_name': _getSafeString(newsMap['author_name']) ?? 'Автор',
      'author_id': _getSafeString(newsMap['author_id']) ?? 'unknown',
      'author_avatar': _getSafeString(newsMap['author_avatar']) ?? '',
      'hashtags': _parseList(newsMap['hashtags']),

      'created_at': _parseDateTime(newsMap['created_at']).toIso8601String(),
      'updated_at': _parseDateTime(newsMap['updated_at']).toIso8601String(),

      'likes_count': _parseInt(newsMap['likes_count']) ?? 0,
      'reposts_count': _parseInt(newsMap['reposts_count']) ?? 0,
      'comments_count': _parseInt(newsMap['comments_count']) ?? 0,
      'bookmarks_count': _parseInt(newsMap['bookmarks_count']) ?? 0,

      'is_deleted': _getSafeBool(newsMap['is_deleted']) ?? false,
      'is_repost': _getSafeBool(newsMap['is_repost']) ?? false,
      'original_author_id': _getSafeString(newsMap['original_author_id']) ?? _getSafeString(newsMap['author_id']),

      'isLiked': _getSafeBool(newsMap['isLiked']) ?? false,
      'isBookmarked': _getSafeBool(newsMap['isBookmarked']) ?? false,
      'isReposted': _getSafeBool(newsMap['isReposted']) ?? false,

      'source': 'YDB_HYPER_OPTIMIZED'
    };
  }

  // 🟢 УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ДЕЙСТВИЙ
  static Future<Map<String, dynamic>> action(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(data),
      )
          .timeout(const Duration(seconds: 5));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Action error: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _formatUserProfile(dynamic user) {
    final userMap = _ensureStringMap(user);

    return {
      'id': _getSafeString(userMap['id']),
      'name': _getSafeString(userMap['name']) ?? 'Пользователь',
      'email': _getSafeString(userMap['email']) ?? '',
      'avatar': _getSafeString(userMap['avatar']) ?? '',
      'created_at': _parseDateTime(userMap['created_at']).toIso8601String(),
      'updated_at': _parseDateTime(userMap['updated_at']).toIso8601String(),
    };
  }

  static Map<String, dynamic> _formatComment(dynamic comment) {
    final commentMap = _ensureStringMap(comment);

    return {
      'id': _getSafeString(commentMap['id']),
      'text': _getSafeString(commentMap['content'] ?? commentMap['text']),
      'author_name': _getSafeString(commentMap['user_name'] ?? commentMap['author_name']) ?? 'Пользователь',
      'author_id': _getSafeString(commentMap['user_id'] ?? commentMap['author_id']),
      'news_id': _getSafeString(commentMap['news_id']),
      'created_at': _parseDateTime(commentMap['created_at'] ?? commentMap['timestamp']).toIso8601String(),
    };
  }

  // 🟢 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  static DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        final parsed = DateTime.tryParse(dateValue);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static Map<String, dynamic> _ensureStringMap(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map<dynamic, dynamic>) return data.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  static String _getSafeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static bool _getSafeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }

  static List<dynamic> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is String) {
      try {
        final parsed = json.decode(value);
        if (parsed is List) return parsed;
      } catch (e) {
        return value.isNotEmpty ? [value] : [];
      }
    }
    return [];
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