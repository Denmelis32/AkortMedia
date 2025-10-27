import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  // ✅ РАБОЧИЙ URL
  static const String baseUrl = 'https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net';
  static const int timeoutSeconds = 15;

  // 🎯 ПОЛУЧЕНИЕ ТОКЕНА
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('🔑 getToken: ${token != null ? 'Token found' : 'No token'}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // 🎯 СИНХРОНИЗАЦИЯ ВЗАИМОДЕЙСТВИЙ ПОЛЬЗОВАТЕЛЯ
  static Future<List<String>> syncUserLikes() async {
    try {
      print('❤️ Syncing user likes...');
      final userLikes = await getUserLikes();
      print('✅ User likes synced: ${userLikes.length} items');
      return userLikes;
    } catch (e) {
      print('❌ Error syncing user likes: $e');
      return [];
    }
  }

  static Future<List<String>> syncUserBookmarks() async {
    try {
      print('🔖 Syncing user bookmarks...');
      final userBookmarks = await getUserBookmarks();
      print('✅ User bookmarks synced: ${userBookmarks.length} items');
      return userBookmarks;
    } catch (e) {
      print('❌ Error syncing user bookmarks: $e');
      return [];
    }
  }

  static Future<List<String>> syncUserReposts() async {
    try {
      print('🔁 Syncing user reposts...');
      final userReposts = await getUserReposts();
      print('✅ User reposts synced: ${userReposts.length} items');
      return userReposts;
    } catch (e) {
      print('❌ Error syncing user reposts: $e');
      return [];
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
      print('🔑 Token included in headers: ${token.substring(0, min(token.length, 20))}...');
    } else {
      print('⚠️ No token available');
    }

    return headers;
  }

  static int min(int a, int b) => a < b ? a : b;

  // 🎯 ПРОВЕРКА ПОДКЛЮЧЕНИЯ
  static Future<bool> testConnection() async {
    try {
      print('🔗 Testing connection to: $baseUrl');
      final response = await http
          .get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(Duration(seconds: 10));

      print('🔗 Connection test: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // 🎯 ОБРАБОТКА ОТВЕТОВ
  static dynamic _handleResponse(http.Response response) {
    print('🔧 API Response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true, 'message': 'Operation completed'};
      }

      try {
        final data = json.decode(response.body);

        if (data is Map) {
          if (data.containsKey('success') && data['success'] == true) {
            return data.containsKey('data') ? data['data'] : data;
          } else if (data.containsKey('error')) {
            throw HttpException(data['error'] ?? 'Unknown error');
          }
        }

        return data;
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        throw HttpException('Invalid response format');
      }
    } else if (response.statusCode == 401) {
      throw HttpException('Authentication required');
    } else if (response.statusCode == 403) {
      throw HttpException('Access denied');
    } else if (response.statusCode == 404) {
      throw HttpException('Resource not found');
    } else if (response.statusCode >= 500) {
      throw HttpException('Server error: ${response.statusCode}');
    } else {
      throw HttpException('HTTP ${response.statusCode}');
    }
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
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      // 🎯 СОХРАНЯЕМ ТОКЕН
      if (result is Map && result.containsKey('token')) {
        await AuthService.saveToken(result['token']);
        if (result.containsKey('user')) {
          await AuthService.saveUser(Map<String, dynamic>.from(result['user']));
        }
        print('✅ Login successful, token saved');
      }

      return result is Map<String, dynamic> ? result : {'success': true};
    } catch (e) {
      print('❌ API Error (login): $e');
      throw Exception('Ошибка входа: ${e.toString()}');
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
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is Map && result.containsKey('token')) {
        await AuthService.saveToken(result['token']);
        if (result.containsKey('user')) {
          await AuthService.saveUser(Map<String, dynamic>.from(result['user']));
        }
      }

      return result is Map<String, dynamic> ? result : {'success': true};
    } catch (e) {
      print('❌ API Error (register): $e');
      throw Exception('Ошибка регистрации: ${e.toString()}');
    }
  }

  // ========== НОВОСТИ ==========

  static Future<List<dynamic>> getNews({int limit = 50}) async {
    try {
      print('🌐 Loading news from API...');

      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/getNews?limit=$limit');

      print('📤 Request: GET $uri');

      final response = await _retryRequest(() => http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: timeoutSeconds)));

      final result = _handleResponse(response);

      List<dynamic> newsList = [];

      if (result is List) {
        newsList = result;
        print('✅ Direct list with ${newsList.length} items');
      } else if (result is Map) {
        if (result.containsKey('data') && result['data'] is List) {
          newsList = result['data'];
          print('✅ Data list with ${newsList.length} items');
        } else {
          newsList = [result];
          print('✅ Single item wrapped in list');
        }
      }

      // 🎯 ФИЛЬТРАЦИЯ И ФОРМАТИРОВАНИЕ
      final formattedNews = newsList.map((news) {
        return _formatNewsItem(news);
      }).toList();

      print('✅ FINAL: Loaded ${formattedNews.length} news items');

      return formattedNews;
    } catch (e) {
      print('❌ API Error (getNews): $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createNews(Map<String, dynamic> newsData) async {
    try {
      print('🌐 Creating news: ${newsData['title']}');
      print('👤 Author data in API call:');
      print('   - author_name: ${newsData['author_name']}');
      print('   - author_id: ${newsData['author_id']}');

      final headers = await _getHeaders();

      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await http
              .post(
            Uri.parse('$baseUrl/createNews'),
            headers: headers,
            body: json.encode(newsData),
          )
              .timeout(Duration(seconds: timeoutSeconds));

          print('🔧 API Response attempt $attempt: ${response.statusCode}');
          print('📦 Response body: ${response.body}');

          if (response.statusCode == 201 || response.statusCode == 200) {
            final result = _handleResponse(response);
            dynamic createdNews;

            if (result is Map) {
              if (result.containsKey('news')) {
                createdNews = result['news'];
              } else if (result.containsKey('data')) {
                createdNews = result['data'];
              } else {
                createdNews = result;
              }
            } else {
              createdNews = result;
            }

            if (createdNews != null) {
              final formattedNews = _formatNewsItem(createdNews);
              print('✅ News created: ${formattedNews['id']}');
              print('👤 Final author name: ${formattedNews['author_name']}');
              return formattedNews;
            }
          } else if (response.statusCode >= 500) {
            print('🔄 Server error, retrying...');
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: attempt * 2));
              continue;
            }
          }

          break;
        } catch (e) {
          print('❌ API Error attempt $attempt (createNews): $e');
          if (attempt == 3) rethrow;
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }

      throw Exception('Failed to create news after 3 attempts');
    } catch (e) {
      print('❌ API Error (createNews): $e');
      throw Exception('Не удалось создать пост: ${e.toString()}');
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

  // 🎯 ДОБАВЛЕННЫЕ МЕТОДЫ ДЛЯ РЕПОСТОВ
  static Future<Map<String, dynamic>> repostNews(String newsId) async {
    return _handleUniversalAction('repost', newsId);
  }

  static Future<Map<String, dynamic>> unrepostNews(String newsId) async {
    return _handleUniversalAction('unrepost', newsId);
  }

  static Future<Map<String, dynamic>> _handleUniversalAction(String action, String newsId) async {
    try {
      print('🎯 API $action: $newsId');

      final headers = await _getHeaders();
      final requestData = {
        'action': action,
        'newsId': newsId,
      };

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);
      final resultMap = _ensureStringMap(result);

      print('✅ $action successful for news: $newsId');
      return resultMap;
    } catch (e) {
      print('❌ API Error ($action): $e');
      throw Exception('Не удалось выполнить действие: $action');
    }
  }

  // ========== КОММЕНТАРИИ ==========

  static Future<List<dynamic>> getComments(String newsId) async {
    try {
      print('💬 Getting comments for news: $newsId');

      final headers = await _getHeaders();
      final requestData = {
        'action': 'getComments',
        'newsId': newsId,
      };

      final response = await http
          .post(
        Uri.parse('$baseUrl/action'),
        headers: headers,
        body: json.encode(requestData),
      )
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      print('🔍 Raw comments response: $result');

      List<dynamic> comments = [];

      if (result is Map && result.containsKey('comments') && result['comments'] is List) {
        comments = (result['comments'] as List).map((comment) => _formatComment(comment)).toList();
      } else if (result is List) {
        comments = result.map((comment) => _formatComment(comment)).toList();
      }

      print('✅ Found ${comments.length} comments for news: $newsId');

      // 🎯 ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ДАННЫХ
      for (int i = 0; i < comments.length; i++) {
        final comment = comments[i];
        print('📝 Comment $i: ${comment['author_name']} - "${comment['text']}"');
      }

      return comments;
    } catch (e) {
      print('❌ API Error (getComments): $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addComment(
      String newsId,
      String text,
      String userName,
      ) async {
    try {
      print('💬 Adding comment to news: $newsId');

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
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      dynamic commentData;
      if (result is Map && result.containsKey('comment')) {
        commentData = result['comment'];
      } else {
        commentData = result;
      }

      return _formatComment(commentData);
    } catch (e) {
      print('❌ API Error (addComment): $e');
      rethrow;
    }
  }

  // ========== ПОЛЬЗОВАТЕЛЬСКИЕ ВЗАИМОДЕЙСТВИЯ ==========

  static Future<List<String>> getUserLikes() async {
    try {
      print('❤️ Getting user likes...');
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/user/likes'), headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is List) {
        return result.map((item) => item.toString()).toList();
      } else if (result is Map && result.containsKey('data')) {
        return List<String>.from(result['data'] ?? []);
      }

      return [];
    } catch (e) {
      print('❌ API Error (getUserLikes): $e');
      return [];
    }
  }

  static Future<List<String>> getUserBookmarks() async {
    try {
      print('🔖 Getting user bookmarks...');
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/user/bookmarks'), headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is List) {
        return result.map((item) => item.toString()).toList();
      } else if (result is Map && result.containsKey('data')) {
        return List<String>.from(result['data'] ?? []);
      }

      return [];
    } catch (e) {
      print('❌ API Error (getUserBookmarks): $e');
      return [];
    }
  }

  static Future<List<String>> getUserReposts() async {
    try {
      print('🔁 Getting user reposts...');
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/user/reposts'), headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      final result = _handleResponse(response);

      if (result is List) {
        return result.map((item) => item.toString()).toList();
      } else if (result is Map && result.containsKey('data')) {
        return List<String>.from(result['data'] ?? []);
      }

      return [];
    } catch (e) {
      print('❌ API Error (getUserReposts): $e');
      return [];
    }
  }

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

  static Map<String, dynamic> _formatNewsItem(dynamic news) {
    final newsMap = _ensureStringMap(news);

    // 🎯 ПРАВИЛЬНОЕ ИМЯ АВТОРА - если нет в данных, используем "Неизвестный автор"
    final authorName = _getSafeString(newsMap['author_name']);
    final finalAuthorName = authorName.isNotEmpty ? authorName : 'Неизвестный автор';

    return {
      'id': _getSafeString(newsMap['id']),
      'title': _getSafeString(newsMap['title']) ?? 'Без названия',
      'content': _getSafeString(newsMap['content']) ?? '',
      'author_name': finalAuthorName, // ✅ ПРАВИЛЬНОЕ ИМЯ
      'author_id': _getSafeString(newsMap['author_id']) ?? 'unknown',
      'author_avatar': _getSafeString(newsMap['author_avatar']) ?? '',
      'hashtags': _parseList(newsMap['hashtags']),
      'created_at': _getSafeString(newsMap['created_at']) ?? DateTime.now().toIso8601String(),
      'updated_at': _getSafeString(newsMap['updated_at']) ?? DateTime.now().toIso8601String(),

      'likes': _parseInt(newsMap['likes']) ?? 0,
      'likes_count': _parseInt(newsMap['likes_count']) ?? _parseInt(newsMap['likes']) ?? 0,
      'reposts': _parseInt(newsMap['reposts']) ?? 0,
      'reposts_count': _parseInt(newsMap['reposts_count']) ?? _parseInt(newsMap['reposts']) ?? 0,
      'comments_count': _parseInt(newsMap['comments_count']) ?? 0,
      'bookmarks_count': _parseInt(newsMap['bookmarks_count']) ?? 0,

      'isLiked': newsMap['isLiked'] == true,
      'isBookmarked': newsMap['isBookmarked'] == true,
      'isReposted': newsMap['isReposted'] == true,

      'comments': [],
      'source': newsMap['source'] ?? 'API'
    };
  }

  static List<dynamic> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is String) {
      try {
        // Пробуем распарсить как JSON
        final parsed = json.decode(value);
        if (parsed is List) return parsed;
      } catch (e) {
        // Если это строка с хештегами через запятую
        if (value.contains(',')) {
          return value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
        }
        // Если это одиночный хештег
        return value.isNotEmpty ? [value] : [];
      }
    }
    return [];
  }

  static Map<String, dynamic> _formatComment(dynamic comment) {
    final commentMap = _ensureStringMap(comment);

    print('🔍 RAW COMMENT DATA: $commentMap');

    // 🎯 ПРАВИЛЬНЫЙ ПАРСИНГ КОММЕНТАРИЕВ
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
      'content': text, // Дублируем для совместимости
      'author_name': authorName,
      'author_avatar': commentMap['author_avatar']?.toString() ?? '',
      'author_id': commentMap['author_id']?.toString() ?? commentMap['user_id']?.toString() ?? 'unknown',
      'news_id': commentMap['news_id']?.toString() ?? 'unknown',
      'timestamp': commentMap['timestamp']?.toString() ??
          commentMap['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
    };

    print('✅ PARSED COMMENT: $authorName - "$text"');

    return result;
  }

  static Future<dynamic> _retryRequest(Future<http.Response> Function() request,
      {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await request();
        if (response.statusCode < 500) {
          return response;
        }
        print('🔄 Retry ${i + 1}/$maxRetries for server error');
        await Future.delayed(Duration(seconds: 1 * (i + 1)));
      } catch (e) {
        print('❌ Request failed, retry ${i + 1}/$maxRetries: $e');
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(Duration(seconds: 1 * (i + 1)));
      }
    }
    throw Exception('Max retries exceeded');
  }

  static Map<String, dynamic> _ensureStringMap(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map<dynamic, dynamic>) {
      return data.cast<String, dynamic>();
    }
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