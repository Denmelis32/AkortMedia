import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  // 🎯 БАЗОВЫЕ КОНСТАНТЫ
  static const String baseUrl = 'https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net';
  static const int timeoutSeconds = 15;

  // 🎯 ПОЛУЧЕНИЕ ТОКЕНА
  static String? _cachedToken;
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString('auth_token');
      print('🔑 Token from storage: ${_cachedToken != null ? _cachedToken!.substring(0, 20) + '...' : 'null'}');
      return _cachedToken;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // 🎯 ЗАГОЛОВКИ
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('🔑 Adding auth token to headers');
    } else {
      print('⚠️ No auth token available');
    }

    return headers;
  }

  // 🎯 ОБРАБОТКА ОТВЕТОВ
  static dynamic _handleResponse(http.Response response) {
    print('🔧 API Response: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

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
        print('❌ JSON Parse Error: $e');
        throw HttpException('Invalid response format');
      }
    } else {
      _handleErrorResponse(response);
    }
  }

  static void _handleErrorResponse(http.Response response) {
    print('❌ HTTP Error ${response.statusCode}: ${response.body}');

    switch (response.statusCode) {
      case 401:
        throw HttpException('Authentication required');
      case 403:
        throw HttpException('Access denied');
      case 404:
        throw HttpException('Resource not found');
      case 429:
        throw HttpException('Too many requests');
      case 500:
        throw HttpException('Internal server error');
      case 502:
        throw HttpException('Bad gateway');
      case 503:
        throw HttpException('Service unavailable');
      default:
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // 🎯 ПРОВЕРКА ПОДКЛЮЧЕНИЯ
  static Future<bool> testConnection() async {
    try {
      print('🌐 Testing connection to: $baseUrl');
      final response = await http
          .get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      final isConnected = response.statusCode == 200;
      print('🔗 Connection test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
      return isConnected;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // ========== НОВОСТИ С ПАГИНАЦИЕЙ ==========

  // 🆕 ПОЛУЧЕНИЕ НОВОСТЕЙ С ПАГИНАЦИЕЙ
  static Future<List<dynamic>> getNews({
    int page = 0,
    int limit = 20,
    String? category
  }) async {
    try {
      print('🌐 Loading news from YDB API - Page: $page, Limit: $limit');

      final headers = await _getHeaders();

      // 🆕 ДОБАВЛЯЕМ ПАРАМЕТРЫ ПАГИНАЦИИ
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category
      };

      final uri = Uri.parse('$baseUrl/getNews').replace(queryParameters: queryParams);

      print('🔗 Request: GET $uri');
      print('🔑 Headers: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      List<dynamic> newsList = [];

      if (result is List) {
        newsList = result;
        print('✅ Direct list with ${newsList.length} items');
      } else if (result is Map && result.containsKey('news')) {
        newsList = result['news'] is List ? result['news'] : [];
        print('✅ News from data field: ${newsList.length} items');
      } else {
        newsList = [];
        print('⚠️ No news data received');
      }

      // 🎯 ФОРМАТИРОВАНИЕ ДЛЯ YDB
      final formattedNews = newsList.map((news) {
        return _formatNewsItem(news);
      }).toList();

      print('✅ FINAL: Loaded ${formattedNews.length} news items from YDB (Page: $page)');

      return formattedNews;
    } catch (e) {
      print('❌ getNews error: $e');
      return [];
    }
  }

  // 🎯 СОЗДАНИЕ НОВОСТИ
  static Future<Map<String, dynamic>> createNews(Map<String, dynamic> newsData) async {
    try {
      // 🎯 ПРОВЕРКА ОБЯЗАТЕЛЬНОГО ПОЛЯ
      if (newsData['content'] == null || newsData['content'].toString().trim().isEmpty) {
        throw HttpException('Описание новости обязательно для заполнения');
      }

      print('🌐 Creating news in YDB with content: ${newsData['content']?.length ?? 0} символов');

      // 🎯 ПОДГОТОВКА ДАННЫХ С ЗНАЧЕНИЯМИ ПО УМОЛЧАНИЮ ДЛЯ НЕОБЯЗАТЕЛЬНЫХ ПОЛЕЙ
      final preparedData = {
        'title': newsData['title']?.toString().trim() ?? '', // 🆕 ПУСТАЯ СТРОКА ВМЕСТО "НОВАЯ НОВОСТЬ"
        'content': newsData['content'].toString().trim(), // 🎯 ОБЯЗАТЕЛЬНОЕ ПОЛЕ
        'author_id': newsData['author_id']?.toString() ?? '',
        'author_name': newsData['author_name']?.toString() ?? 'Неизвестный автор',
        'author_avatar': newsData['author_avatar']?.toString() ?? '',
        'hashtags': newsData['hashtags'] ?? [],
      };

      final headers = await _getHeaders();

      print('🔗 Request: POST $baseUrl/createNews');
      print('📦 Data: ${json.encode(preparedData)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/createNews'),
        headers: headers,
        body: json.encode(preparedData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      print('🔧 API Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = _handleResponse(response);
        dynamic createdNews;

        if (result is Map) {
          createdNews = result.containsKey('news') ? result['news'] : result;
        } else {
          createdNews = result;
        }

        if (createdNews != null) {
          final formattedNews = _formatNewsItem(createdNews);
          return formattedNews;
        }
      }

      throw Exception('Failed to create news: ${response.body}');
    } catch (e) {
      print('❌ Create news error: $e');
      rethrow;
    }
  }

  // 🎯 УДАЛЕНИЕ НОВОСТИ
  static Future<bool> deleteNews(String newsId) async {
    try {
      print('🗑️ Deleting news from YDB: $newsId');

      final headers = await _getHeaders();
      final requestData = {'newsId': newsId};

      print('🔗 Request: POST $baseUrl/deleteNews');
      print('📦 Data: ${json.encode(requestData)}');

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

  // ========== ВЗАИМОДЕЙСТВИЯ ==========

  static Future<Map<String, dynamic>> likeNews(String newsId) async {
    return _handleUniversalAction('like', newsId);
  }

  static Future<Map<String, dynamic>> unlikeNews(String newsId) async {
    return _handleUniversalAction('unlike', newsId);
  }

  static Future<Map<String, dynamic>> bookmarkNews(String newsId) async {
    return _handleUniversalAction('bookmark', newsId);
  }

  static Future<Map<String, dynamic>> unbookmarkNews(String newsId) async {
    return _handleUniversalAction('unbookmark', newsId);
  }

  static Future<Map<String, dynamic>> repostNews(String newsId) async {
    return _handleUniversalAction('repost', newsId);
  }

  static Future<Map<String, dynamic>> unrepostNews(String newsId) async {
    return _handleUniversalAction('unrepost', newsId);
  }

  // 🆕 МЕТОДЫ ДЛЯ ПОДПИСОК
  static Future<Map<String, dynamic>> followUser(String targetUserId) async {
    try {
      print('👥 API followUser: $targetUserId');

      final headers = await _getHeaders();
      final requestData = {'targetUserId': targetUserId};

      print('🔗 Request: POST $baseUrl/follow');
      print('📦 Data: ${json.encode(requestData)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/follow'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      final resultMap = _ensureStringMap(result);

      return resultMap;
    } catch (e) {
      print('❌ followUser error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(String targetUserId) async {
    try {
      print('👥 API unfollowUser: $targetUserId');

      final headers = await _getHeaders();
      final requestData = {'targetUserId': targetUserId};

      print('🔗 Request: POST $baseUrl/unfollow');
      print('📦 Data: ${json.encode(requestData)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/unfollow'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      final resultMap = _ensureStringMap(result);

      return resultMap;
    } catch (e) {
      print('❌ unfollowUser error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _handleUniversalAction(String action, String newsId) async {
    try {
      print('🎯 API $action: $newsId');

      final headers = await _getHeaders();
      final requestData = {'action': action, 'newsId': newsId};

      print('🔗 Request: POST $baseUrl/action');
      print('📦 Data: ${json.encode(requestData)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      final resultMap = _ensureStringMap(result);

      return resultMap;
    } catch (e) {
      print('❌ Action $action error: $e');
      rethrow;
    }
  }

  // ========== КОММЕНТАРИИ ==========

  static Future<List<dynamic>> getComments(String newsId) async {
    try {
      print('💬 Getting comments from YDB for news: $newsId');

      final headers = await _getHeaders();
      final requestData = {'action': 'getComments', 'newsId': newsId};

      print('🔗 Request: POST $baseUrl/action');
      print('📦 Data: ${json.encode(requestData)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      print('🔍 Raw comments response: $result');

      List<dynamic> comments = [];

      if (result is Map && result.containsKey('comments') && result['comments'] is List) {
        comments = (result['comments'] as List).map((comment) => _formatComment(comment)).toList();
      } else if (result is List) {
        comments = result.map((comment) => _formatComment(comment)).toList();
      }

      print('✅ Found ${comments.length} comments for news: $newsId');
      return comments;
    } catch (e) {
      print('❌ Get comments error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addComment(
      String newsId, String text, String userName) async {
    try {
      print('💬 Adding comment to YDB news: $newsId');

      final headers = await _getHeaders();
      final requestData = {
        'action': 'comment',
        'newsId': newsId,
        'text': text.trim(),
        'author_name': userName,
      };

      print('🔗 Request: POST $baseUrl/action');
      print('📦 Data: ${json.encode(requestData)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

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

  // ========== ПОЛЬЗОВАТЕЛЬСКИЕ ВЗАИМОДЕЙСТВИЯ ==========

  static Future<List<String>> syncUserLikes() async {
    return _getUserInteractions('$baseUrl/user/likes');
  }

  static Future<List<String>> syncUserBookmarks() async {
    return _getUserInteractions('$baseUrl/user/bookmarks');
  }

  static Future<List<String>> syncUserReposts() async {
    return _getUserInteractions('$baseUrl/user/reposts');
  }

  static Future<List<String>> syncUserFollowing() async {
    return _getUserInteractions('$baseUrl/user/following');
  }

  static Future<List<String>> syncUserFollowers() async {
    return _getUserInteractions('$baseUrl/user/followers');
  }

  static Future<List<String>> _getUserInteractions(String url) async {
    try {
      final headers = await _getHeaders();

      print('🔗 Request: GET $url');
      print('🔑 Headers: $headers');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is List) {
        final ids = result.map((item) => item.toString()).toList();
        print('✅ Got ${ids.length} items from $url');
        return ids;
      }

      return [];
    } catch (e) {
      print('❌ Get user interactions error: $e');
      return [];
    }
  }

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

  static Map<String, dynamic> _formatNewsItem(dynamic news) {
    final newsMap = _ensureStringMap(news);

    final authorName = _getSafeString(newsMap['author_name']);
    final finalAuthorName = authorName.isNotEmpty ? authorName : 'Автор';

    // 🎯 ИСПРАВЛЕНИЕ: НЕ ГЕНЕРИРУЕМ ЗАГОЛОВОК ИЗ КОНТЕНТА
    final title = _getSafeString(newsMap['title']);
    // Оставляем заголовок как есть (может быть пустым)
    final finalTitle = title;

    final createdAt = _parseDateTime(newsMap['created_at']);
    final updatedAt = _parseDateTime(newsMap['updated_at']);

    return {
      'id': _getSafeString(newsMap['id']),
      'title': finalTitle, // 🆕 МОЖЕТ БЫТЬ ПУСТОЙ СТРОКОЙ
      'content': _getSafeString(newsMap['content']) ?? '',
      'author_name': finalAuthorName,
      'author_id': _getSafeString(newsMap['author_id']) ?? 'unknown',
      'author_avatar': _getSafeString(newsMap['author_avatar']) ?? '',
      'hashtags': _parseList(newsMap['hashtags']),

      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      'likes': _parseInt(newsMap['likes']) ?? 0,
      'likes_count': _parseInt(newsMap['likes_count']) ?? _parseInt(newsMap['likes']) ?? 0,
      'reposts': _parseInt(newsMap['reposts']) ?? 0,
      'reposts_count': _parseInt(newsMap['reposts_count']) ?? _parseInt(newsMap['reposts']) ?? 0,
      'comments_count': _parseInt(newsMap['comments_count']) ?? 0,
      'bookmarks_count': _parseInt(newsMap['bookmarks_count']) ?? 0,
      'share_count': _parseInt(newsMap['share_count']) ?? 0,

      'is_deleted': _getSafeBool(newsMap['is_deleted']) ?? false,
      'is_repost': _getSafeBool(newsMap['is_repost']) ?? false,
      'original_author_id': _getSafeString(newsMap['original_author_id']) ?? _getSafeString(newsMap['author_id']),

      'isLiked': _getSafeBool(newsMap['isLiked']) ?? false,
      'isBookmarked': _getSafeBool(newsMap['isBookmarked']) ?? false,
      'isReposted': _getSafeBool(newsMap['isReposted']) ?? false,
      'isFollowing': _getSafeBool(newsMap['isFollowing']) ?? false,

      'comments': [],
      'source': 'YDB'
    };
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue == null) {
        return DateTime.now();
      }

      if (dateValue is String) {
        // 🆕 ПРЯМОЙ ПАРСИНГ ISO СТРОКИ
        final parsed = DateTime.tryParse(dateValue);
        if (parsed != null && parsed.year > 2000) {
          // 🆕 ПРОВЕРЯЕМ ЧТО ВРЕМЯ НЕ БУДУЩЕЕ
          final now = DateTime.now();
          if (parsed.isAfter(now.add(Duration(hours: 1)))) {
            print('⚠️ Future time detected, correcting to now');
            return now;
          }
          return parsed;
        }

        // 🆕 ПРОВЕРЯЕМ MICROSECONDS ИЗ YDB
        final timestamp = int.tryParse(dateValue);
        if (timestamp != null) {
          // YDB возвращает время в микросекундах
          if (timestamp > 1000000000000000) { // Это микросекунды
            final date = DateTime.fromMicrosecondsSinceEpoch(timestamp);
            // Проверяем реалистичность даты
            if (date.year > 2000 && date.year < 2030) {
              return date;
            }
          } else if (timestamp > 1000000000000) { // Миллисекунды
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (date.year > 2000 && date.year < 2030) {
              return date;
            }
          } else if (timestamp > 1000000000) { // Секунды
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
            if (date.year > 2000 && date.year < 2030) {
              return date;
            }
          }
        }
      }

      if (dateValue is int) {
        // 🆕 ОБРАБОТКА ЧИСЛОВЫХ TIMESTAMP ИЗ YDB
        if (dateValue > 1000000000000000) { // Микросекунды
          final date = DateTime.fromMicrosecondsSinceEpoch(dateValue);
          if (date.year > 2000 && date.year < 2030) {
            return date;
          }
        } else if (dateValue > 1000000000000) { // Миллисекунды
          final date = DateTime.fromMillisecondsSinceEpoch(dateValue);
          if (date.year > 2000 && date.year < 2030) {
            return date;
          }
        } else if (dateValue > 1000000000) { // Секунды
          final date = DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
          if (date.year > 2000 && date.year < 2030) {
            return date;
          }
        }
      }

      // 🆕 ЕСЛИ НИЧЕГО НЕ СРАБОТАЛО - ТЕКУЩЕЕ ВРЕМЯ
      print('⚠️ Could not parse date: $dateValue, using current time');
      return DateTime.now();
    } catch (e) {
      print('❌ Date parsing error: $e, using current time');
      return DateTime.now();
    }
  }

  // 🎯 ОБНОВЛЕНИЕ НОВОСТИ
  static Future<Map<String, dynamic>> updateNews(String newsId, Map<String, dynamic> updateData) async {
    try {
      print('✏️ Updating news in YDB: $newsId');

      final headers = await _getHeaders();

      // 🎯 ПРАВИЛЬНАЯ СТРУКТУРА ДАННЫХ ДЛЯ СЕРВЕРА С НЕОБЯЗАТЕЛЬНЫМИ ПОЛЯМИ
      final requestData = {
        'newsId': newsId,
        'updateData': {
          if (updateData['title'] != null) 'title': updateData['title'],
          if (updateData['content'] != null) 'content': updateData['content'],
          'hashtags': updateData['hashtags'] ?? [],
        },
      };

      print('🔗 Request: POST $baseUrl/updateNews');
      print('📦 Data: ${json.encode(requestData)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/updateNews'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      print('🔧 API Response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      final result = _handleResponse(response);
      return _ensureStringMap(result);
    } catch (e) {
      print('❌ Update news error: $e');
      rethrow;
    }
  }

  static DateTime _parseTimestamp(int timestamp) {
    try {
      if (timestamp > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } else {
        return DateTime.fromMillisecondsSinceEpoch((timestamp / 1000).round());
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  static Map<String, dynamic> _formatComment(dynamic comment) {
    final commentMap = _ensureStringMap(comment);

    final text = commentMap['text'] ??
        commentMap['content'] ??
        commentMap['message'] ??
        '';

    final authorName = commentMap['author_name'] ??
        commentMap['user_name'] ??
        commentMap['author'] ??
        'Пользователь';

    final result = {
      'id': commentMap['id']?.toString() ?? 'unknown',
      'text': text,
      'content': text,
      'author_name': authorName,
      'author_avatar': commentMap['author_avatar']?.toString() ?? '',
      'author_id': commentMap['author_id']?.toString() ?? commentMap['user_id']?.toString() ?? 'unknown',
      'news_id': commentMap['news_id']?.toString() ?? 'unknown',
      'timestamp': commentMap['timestamp']?.toString() ??
          commentMap['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
    };

    return result;
  }

  // 🎯 БАЗОВЫЕ УТИЛИТЫ
  static Map<String, dynamic> _ensureStringMap(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map<dynamic, dynamic>) {
      return data.cast<String, dynamic>();
    }
    return <String, dynamic>{};
  }


  // ========== АВТОРИЗАЦИЯ ==========

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔑 Attempting login: $email');

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
        print('✅ Login successful, token saved');
      }

      return result is Map<String, dynamic> ? result : {'success': true};
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      print('🎯 Attempting registration: $name ($email)');

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
      }

      return result is Map<String, dynamic> ? result : {'success': true};
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
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
        if (value.contains(',')) {
          return value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
        }
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