import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../user_provider.dart';

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _serverAvailable = true;
  bool _isRefreshing = false;

  final UserProvider userProvider;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get serverAvailable => _serverAvailable;

  NewsProvider({required this.userProvider}) {
    _initialize();
  }

  void _initialize() async {
    print('✅ NewsProvider initialized with UserProvider: ${userProvider.userName}');
    await loadNews();
  }

  // 🎯 ЗАГРУЗКА ДАННЫХ ИЗ YDB
  Future<void> loadNews() async {
    try {
      _setLoading(true);
      _setError(null);

      print('🌐 Loading news from YDB for user: ${userProvider.userName}');

      // Проверка подключения
      _serverAvailable = await ApiService.testConnection();
      print('🔗 Server available: $_serverAvailable');

      if (_serverAvailable) {
        // 🎯 ПРЕЖДЕ ЧЕМ ЗАГРУЖАТЬ НОВОСТИ, СИНХРОНИЗИРУЕМ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ
        if (userProvider.isLoggedIn) {
          print('👤 Pre-syncing user data...');
          await userProvider.syncWithServer();
        }

        // Получаем данные из YDB
        final news = await ApiService.getNews(limit: 50);
        await _processServerNews(news);
      } else {
        // Автономный режим
        await _loadLocalNews();
        _setError('Сервер временно недоступен. Работаем в автономном режиме.');
      }

    } catch (e) {
      print('❌ Failed to load news from YDB: $e');
      await _loadLocalNews();
      _setError('Ошибка загрузки данных: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 🎯 ОБРАБОТКА ДАННЫХ С СЕРВЕРА
  // 🎯 ОБРАБОТКА ДАННЫХ С СЕРВЕРА
  Future<void> _processServerNews(List<dynamic> serverNews) async {
    try {
      print('🔄 Processing ${serverNews.length} news items from YDB');

      // Синхронизация пользователя
      if (userProvider.isLoggedIn) {
        print('👤 User is logged in, syncing with server...');
        await userProvider.syncWithServer();
      }

      // 🎯 ПОЛУЧАЕМ АКТУАЛЬНЫЕ ВЗАИМОДЕЙСТВИЯ ПОЛЬЗОВАТЕЛЯ
      List<String> userLikes = [];
      List<String> userBookmarks = [];
      List<String> userReposts = [];

      if (_serverAvailable && userProvider.isLoggedIn) {
        userLikes = await ApiService.syncUserLikes();
        userBookmarks = await ApiService.syncUserBookmarks();
        userReposts = await ApiService.syncUserReposts();

        print('❤️ Applying ${userLikes.length} user likes to news feed');
        print('🔖 Applying ${userBookmarks.length} user bookmarks to news feed');
        print('🔁 Applying ${userReposts.length} user reposts to news feed');
      }

      final List<Map<String, dynamic>> updatedNews = [];

      for (final item in serverNews) {
        try {
          final safeItem = _ensureSafeTypes(item);

          // Валидация данных
          final id = _getSafeString(safeItem['id']);
          final title = _getSafeString(safeItem['title']);

          // Пропускаем невалидные данные
          if (id.isEmpty || id == 'unknown') {
            print('⚠️ Skipping invalid post ID: "$id"');
            continue;
          }

          if (title.isEmpty) {
            print('⚠️ Skipping post with empty title, ID: $id');
            continue;
          }

          // 🎯 ПРОВЕРЯЕМ ВЗАИМОДЕЙСТВИЯ ПОЛЬЗОВАТЕЛЯ
          final bool isUserLiked = userLikes.contains(id);
          final bool isUserBookmarked = userBookmarks.contains(id);
          final bool isUserReposted = userReposts.contains(id);

          // 🎯 ИСПОЛЬЗУЕМ РЕАЛЬНЫЕ ДАННЫЕ ИЗ YDB
          final int serverLikesCount = _getSafeInt(safeItem['likes_count'] ?? safeItem['likes']);
          final int serverRepostsCount = _getSafeInt(safeItem['reposts_count'] ?? safeItem['reposts']);
          final int serverCommentsCount = _getSafeInt(safeItem['comments_count']);
          final int serverBookmarksCount = _getSafeInt(safeItem['bookmarks_count']);

          // 🎯 ПРАВИЛЬНОЕ ИМЯ АВТОРА - если нет в данных, используем "Неизвестный автор"
          final authorName = _getSafeString(safeItem['author_name']);
          final finalAuthorName = authorName.isNotEmpty ? authorName : 'Неизвестный автор';

          // Создаем объект с данными
          final Map<String, dynamic> newsItem = <String, dynamic>{
            'id': id,
            'title': title,
            'content': _getSafeString(safeItem['content']) ?? '',
            'author_id': _getSafeString(safeItem['author_id']) ?? 'unknown',
            'author_name': finalAuthorName, // ✅ ПРАВИЛЬНОЕ ИМЯ
            'author_avatar': _getSafeString(safeItem['author_avatar']) ?? '',
            'hashtags': _parseList(safeItem['hashtags']),
            'is_repost': _getSafeBool(safeItem['is_repost']),

            // 🎯 ОБНОВЛЕННЫЕ СТАТИСТИКИ С УЧЕТОМ РЕАЛЬНЫХ ДАННЫХ ИЗ YDB
            'likes_count': serverLikesCount,
            'comments_count': serverCommentsCount,
            'reposts_count': serverRepostsCount,
            'bookmarks_count': serverBookmarksCount,

            'created_at': safeItem['created_at'] ?? DateTime.now().toIso8601String(),
            'updated_at': safeItem['updated_at'] ?? DateTime.now().toIso8601String(),

            // 🎯 ПРАВИЛЬНЫЕ ФЛАГИ ВЗАИМОДЕЙСТВИЙ
            'isLiked': isUserLiked,
            'isBookmarked': isUserBookmarked,
            'isReposted': isUserReposted,

            'comments': [],
            'source': 'YDB',
          };

          updatedNews.add(newsItem);
          print('✅ Added post: "$title" (ID: $id) - 👤 $finalAuthorName');
          print('   Content: ${newsItem['content']}');
          print('   Hashtags: ${newsItem['hashtags']}');

        } catch (e) {
          print('❌ Error processing news item: $e');
          continue;
        }
      }

      _news = updatedNews;
      await _saveNewsToLocal(_news);
      _safeNotifyListeners();

      print('✅ Processed ${_news.length} news items from YDB with real interaction data');

    } catch (e) {
      print('❌ Error processing news from YDB: $e');
      _news = <Map<String, dynamic>>[];
      await _saveNewsToLocal(_news);
      _safeNotifyListeners();
    }
  }

  // 🎯 ОБНОВЛЕНИЕ ДАННЫХ
  Future<void> refreshNews() async {
    if (_isRefreshing) return;

    try {
      _setRefreshing(true);
      print('🔄 Manual refresh triggered for user: ${userProvider.userId}');

      _serverAvailable = await ApiService.testConnection();

      if (_serverAvailable) {
        final news = await ApiService.getNews(limit: 50);
        await _processServerNews(news);
        _setError(null);
      } else {
        _setError('Сервер недоступен. Данные могут быть неактуальны.');
      }
    } catch (e) {
      print('❌ Refresh failed: $e');
      _setError('Ошибка обновления данных: ${e.toString()}');
    } finally {
      _setRefreshing(false);
    }
  }

  // 🎯 СОЗДАНИЕ НОВОСТИ В YDB - ИСПРАВЛЕННАЯ ВЕРСИЯ
  // 🎯 СОЗДАНИЕ НОВОСТИ В YDB - ИСПРАВЛЕННАЯ ВЕРСИЯ С РЕАЛЬНЫМ ИМЕНЕМ
  Future<void> addNews(Map<String, dynamic> newsData) async {
    try {
      if (!userProvider.isLoggedIn) {
        throw Exception('Для создания поста необходимо войти в систему');
      }

      // Синхронизация
      await userProvider.syncWithServer();

      print('🎯 Creating post in YDB as: ${userProvider.userName}');

      // 🎯 ИСПОЛЬЗУЕМ РЕАЛЬНЫЕ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ ИЗ PROVIDER
      final String authorName = userProvider.userName.isNotEmpty
          ? userProvider.userName
          : 'Пользователь';

      final Map<String, dynamic> authorData = {
        'author_id': userProvider.userId,
        'author_name': authorName, // ✅ ГАРАНТИРОВАННО РЕАЛЬНОЕ ИМЯ
        'author_avatar': userProvider.profileImageUrl ?? '',
      };

      // 🎯 ПРАВИЛЬНАЯ ПОДГОТОВКА ДАННЫХ С ВСЕМИ ПОЛЯМИ
      final Map<String, dynamic> completeNewsData = <String, dynamic>{
        'title': _getSafeString(newsData['title']),
        'content': _getSafeString(newsData['content'] ?? ''),
        'hashtags': _parseList(newsData['hashtags']),
        ...authorData, // ✅ ВКЛЮЧАЕМ ДАННЫЕ АВТОРА
      };

      // Проверка обязательных полей
      if (completeNewsData['title']?.isEmpty ?? true) {
        throw Exception('Заголовок поста не может быть пустым');
      }

      print('📝 News data for YDB:');
      print('   📝 Title: ${completeNewsData['title']}');
      print('   📋 Content: ${completeNewsData['content']}');
      print('   🏷️ Hashtags: ${completeNewsData['hashtags']}');
      print('   👤 Author: ${completeNewsData['author_name']}'); // ✅ Должно показывать реальное имя
      print('   🆔 Author ID: ${completeNewsData['author_id']}');

      Map<String, dynamic> createdNews;

      // Создание на сервере
      try {
        print('🌐 Creating news on YDB server...');
        createdNews = await ApiService.createNews(completeNewsData);
        print('✅ News created on YDB server: ${createdNews['id']}');

      } catch (serverError) {
        print('❌ YDB Server creation failed: $serverError');
        throw Exception('Не удалось создать пост на сервере: ${serverError.toString()}');
      }

      // Добавление в ленту
      final Map<String, dynamic> safeNews = _ensureSafeTypes(createdNews);

      // 🎯 ДОБАВЛЯЕМ ВСЕ НЕОБХОДИМЫЕ ПОЛЯ ДЛЯ ОТОБРАЖЕНИЯ
      final Map<String, dynamic> formattedNews = {
        'id': _getSafeString(safeNews['id']),
        'title': _getSafeString(safeNews['title']),
        'content': _getSafeString(safeNews['content'] ?? ''),
        'author_id': _getSafeString(safeNews['author_id'] ?? userProvider.userId),
        'author_name': _getSafeString(safeNews['author_name'] ?? authorName), // ✅ РЕЗЕРВНОЕ ИМЯ
        'author_avatar': _getSafeString(safeNews['author_avatar'] ?? ''),
        'hashtags': _parseList(safeNews['hashtags']),
        'likes_count': _getSafeInt(safeNews['likes_count'] ?? 0),
        'comments_count': _getSafeInt(safeNews['comments_count'] ?? 0),
        'reposts_count': _getSafeInt(safeNews['reposts_count'] ?? 0),
        'bookmarks_count': _getSafeInt(safeNews['bookmarks_count'] ?? 0),
        'isLiked': false,
        'isBookmarked': false,
        'isReposted': false,
        'is_repost': false,
        'created_at': _getSafeString(safeNews['created_at'] ?? DateTime.now().toIso8601String()),
        'updated_at': _getSafeString(safeNews['updated_at'] ?? DateTime.now().toIso8601String()),
        'comments': [],
        'source': 'YDB',
      };

      _news.insert(0, formattedNews);
      await _saveNewsToLocal(_news);

      // Обновление статистики
      userProvider.updateStats(<String, int>{
        'posts': (userProvider.stats['posts'] ?? 0) + 1,
      });

      _safeNotifyListeners();
      print('✅ Post created successfully in YDB and added to feed');

    } catch (e) {
      print('❌ Error creating news in YDB: $e');
      throw Exception('Ошибка создания поста в базе данных: ${e.toString()}');
    }
  }



  // 🎯 ЛАЙКИ
  Future<void> toggleLike(String postId) async {
    final int index = _findNewsIndexById(postId);
    if (index == -1) {
      print('❌ Post not found in YDB: $postId');
      return;
    }

    try {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isLiked = _getSafeBool(post['isLiked']);
      final int currentLikes = _getSafeInt(post['likes_count'] ?? post['likes']);

      print('🎯 Toggle like in YDB: $postId, current: $isLiked, likes: $currentLikes');

      // Оптимистичное обновление
      _news[index] = <String, dynamic>{
        ...post,
        'isLiked': !isLiked,
        'likes_count': isLiked ? currentLikes - 1 : currentLikes + 1,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      if (_serverAvailable) {
        try {
          if (!isLiked) {
            await ApiService.likeNews(postId);
            print('✅ Like sent to YDB: $postId');
          } else {
            await ApiService.unlikeNews(postId);
            print('✅ Unlike sent to YDB: $postId');
          }

          await refreshNews();

        } catch (e) {
          print('❌ Like sync error with YDB: $e');
          // Откат при ошибке
          _news[index] = post;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);
          throw Exception('Не удалось синхронизировать лайк с базой данных');
        }
      }
    } catch (e) {
      print('❌ Toggle like error: $e');
      throw e;
    }
  }

  // 🎯 ЗАКЛАДКИ
  Future<void> toggleBookmark(String postId) async {
    final int index = _findNewsIndexById(postId);
    if (index == -1) {
      print('❌ Post not found in YDB: $postId');
      return;
    }

    try {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isBookmarked = _getSafeBool(post['isBookmarked']);

      print('🎯 Toggle bookmark in YDB: $postId, current: $isBookmarked');

      // Оптимистичное обновление
      _news[index] = <String, dynamic>{
        ...post,
        'isBookmarked': !isBookmarked,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      if (_serverAvailable) {
        try {
          if (!isBookmarked) {
            await ApiService.bookmarkNews(postId);
            print('✅ Bookmark sent to YDB: $postId');
          } else {
            await ApiService.unbookmarkNews(postId);
            print('✅ Unbookmark sent to YDB: $postId');
          }

          await refreshNews();

        } catch (e) {
          print('❌ Bookmark sync error with YDB: $e');
          _news[index] = post;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);
          throw Exception('Не удалось синхронизировать закладку с базой данных');
        }
      }
    } catch (e) {
      print('❌ Toggle bookmark error: $e');
      throw e;
    }
  }

  // 🎯 РЕПОСТЫ
  Future<void> toggleRepost(String postId) async {
    final int index = _findNewsIndexById(postId);
    if (index == -1) {
      print('❌ Post not found in YDB: $postId');
      return;
    }

    try {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isReposted = _getSafeBool(post['isReposted']);
      final int currentReposts = _getSafeInt(post['reposts_count'] ?? post['reposts']);

      print('🎯 Toggle repost in YDB: $postId, current: $isReposted, reposts: $currentReposts');

      // Оптимистичное обновление
      _news[index] = <String, dynamic>{
        ...post,
        'isReposted': !isReposted,
        'reposts_count': isReposted ? currentReposts - 1 : currentReposts + 1,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      if (_serverAvailable) {
        try {
          if (!isReposted) {
            await ApiService.repostNews(postId);
            print('✅ Repost sent to YDB: $postId');
          } else {
            await ApiService.unrepostNews(postId);
            print('✅ Unrepost sent to YDB: $postId');
          }

          await refreshNews();

        } catch (e) {
          print('❌ Repost sync error with YDB: $e');
          _news[index] = post;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);
          throw Exception('Не удалось синхронизировать репост с базой данных');
        }
      }
    } catch (e) {
      print('❌ Toggle repost error: $e');
      throw e;
    }
  }

  // 🎯 КОММЕНТАРИИ - ИСПРАВЛЕННАЯ ВЕРСИЯ
  // 🎯 КОММЕНТАРИИ - ИСПРАВЛЕННАЯ ВЕРСИЯ С РЕАЛЬНЫМ ИМЕНЕМ
  Future<void> addComment(String postId, String text) async {
    final int index = _findNewsIndexById(postId);
    if (index == -1) {
      print('❌ Post not found in YDB for comment: $postId');
      return;
    }

    try {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final int currentCommentsCount = _getSafeInt(post['comments_count']);

      print('💬 Adding comment to YDB post: $postId');

      // Оптимистичное обновление
      _news[index] = <String, dynamic>{
        ...post,
        'comments_count': currentCommentsCount + 1,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      if (_serverAvailable) {
        try {
          // ✅ ИСПРАВЛЕННЫЙ ВЫЗОВ - используем реальное имя пользователя
          await ApiService.addComment(
            postId,
            text,
            userProvider.userName.isNotEmpty ? userProvider.userName : 'Пользователь',
          );

          print('✅ Comment added successfully to YDB: $postId');
          await refreshNews();

        } catch (e) {
          print('❌ Comment sync error with YDB: $e');
          _news[index] = post;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);
          throw Exception('Не удалось добавить комментарий в базу данных: ${e.toString()}');
        }
      }
    } catch (e) {
      print('❌ Add comment error: $e');
      throw Exception('Ошибка при добавлении комментария: ${e.toString()}');
    }
  }

  // 🎯 ЛОКАЛЬНОЕ ХРАНИЛИЩЕ
  Future<void> _loadLocalNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedNews = prefs.getString('cached_news');

      if (cachedNews != null) {
        final decodedNews = json.decode(cachedNews);
        if (decodedNews is List) {
          _news = decodedNews.map((item) => _ensureSafeTypes(item)).toList();
          print('✅ Loaded ${_news.length} cached news items');
        } else {
          _news = <Map<String, dynamic>>[];
        }
      } else {
        _news = <Map<String, dynamic>>[];
        print('ℹ️ No cached news found');
      }
    } catch (e) {
      print('❌ Error loading local news: $e');
      _news = <Map<String, dynamic>>[];
    }
  }

  Future<void> _saveNewsToLocal(List<dynamic> news) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_news', json.encode(news));
      print('💾 Saved ${news.length} news to local storage');
    } catch (e) {
      print('❌ Error saving news to local: $e');
    }
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  Map<String, dynamic> _ensureSafeTypes(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map<dynamic, dynamic>) {
      final Map<String, dynamic> result = <String, dynamic>{};
      data.forEach((key, value) {
        final String safeKey = key.toString();
        result[safeKey] = value;
      });
      return result;
    }
    return <String, dynamic>{};
  }

  bool _getSafeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value != 0;
    return false;
  }

  int _getSafeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is bool) return value ? 1 : 0;
    return 0;
  }

  String _getSafeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  List<dynamic> _parseList(dynamic value) {
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

  Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map) return value.cast<String, dynamic>();
    if (value is String) {
      try {
        return Map<String, dynamic>.from(json.decode(value));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  int _findNewsIndexById(String newsId) {
    return _news.indexWhere((news) {
      final Map<String, dynamic> safeNews = _ensureSafeTypes(news);
      return safeNews['id']?.toString() == newsId;
    });
  }

  void clearError() {
    _setError(null);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    _safeNotifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  // 🎯 ОБНОВЛЕНИЕ СЧЕТЧИКА КОММЕНТАРИЕВ ДЛЯ КОНКРЕТНОГО ПОСТА
  void updatePostCommentsCount(String postId) {
    final int index = _findNewsIndexById(postId);
    if (index != -1) {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final int currentComments = _getSafeInt(post['comments_count']);

      _news[index] = <String, dynamic>{
        ...post,
        'comments_count': currentComments + 1,
      };

      _safeNotifyListeners();
      _saveNewsToLocal(_news);
      print('✅ Updated comments count for post: $postId');
    }
  }

  // 🎯 ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ
  Future<void> clearData() async {
    _news = <Map<String, dynamic>>[];
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_news');
      print('✅ Cleared news data');
    } catch (e) {
      print('❌ Error clearing news data: $e');
    }
  }

  List<dynamic> getPostsByAuthor(String authorId) {
    return _news.where((post) {
      final Map<String, dynamic> safePost = _ensureSafeTypes(post);
      return safePost['author_id'] == authorId;
    }).toList();
  }

  Map<String, int> getFeedStats() {
    final totalPosts = _news.length;
    final totalLikes = _news.fold(0, (sum, post) {
      final safePost = _ensureSafeTypes(post);
      return sum + _getSafeInt(safePost['likes_count']);
    });
    final totalComments = _news.fold(0, (sum, post) {
      final safePost = _ensureSafeTypes(post);
      return sum + _getSafeInt(safePost['comments_count']);
    });

    return {
      'total_posts': totalPosts,
      'total_likes': totalLikes,
      'total_comments': totalComments,
    };
  }

  bool isUserPost(String postId) {
    final post = _findPostById(postId);
    if (post == null) return false;
    final authorId = _getSafeString(post['author_id']);
    return authorId == userProvider.userId;
  }

  Map<String, dynamic>? _findPostById(String postId) {
    final index = _findNewsIndexById(postId);
    return index != -1 ? _ensureSafeTypes(_news[index]) : null;
  }

  void updateServerStatus(bool available) {
    _serverAvailable = available;
    _safeNotifyListeners();
  }
}