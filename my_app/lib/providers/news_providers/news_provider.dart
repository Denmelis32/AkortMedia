import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../user_provider.dart';

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _serverAvailable = true;
  bool _isRefreshing = false;
  DateTime? _lastUpdate;

  // 🆕 ПАГИНАЦИЯ
  int _currentPage = 0;
  int _itemsPerPage = 20;
  bool _hasMoreNews = true;
  bool _isLoadingMore = false;

  final UserProvider userProvider;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get serverAvailable => _serverAvailable;
  DateTime? get lastUpdate => _lastUpdate;

  // 🆕 ГЕТТЕРЫ ДЛЯ ПАГИНАЦИИ
  bool get hasMoreNews => _hasMoreNews;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext get context => navigatorKey.currentState!.context;

  NewsProvider({required this.userProvider}) {
    _initialize();
  }

  void _initialize() async {
    print('✅ NewsProvider initialized with UserProvider: ${userProvider.userName}');
    await loadNews();
  }

  // 🆕 ОСНОВНОЙ МЕТОД ЗАГРУЗКИ С ПАГИНАЦИЕЙ
  Future<void> loadNews({bool refresh = false}) async {
    try {
      if (refresh) {
        _resetPagination();
        _news.clear();
        print('🔄 Refresh requested - resetting pagination');
      }

      if (!_hasMoreNews) {
        print('⏹️ No more news available');
        return;
      }

      _setLoading(true);
      _setError(null);

      print('🌐 Loading news page $_currentPage ($_itemsPerPage items) for user: ${userProvider.userName}');

      _serverAvailable = await ApiService.testConnection();
      print('🔗 Server available: $_serverAvailable');

      if (_serverAvailable) {
        if (userProvider.isLoggedIn) {
          print('👤 Pre-syncing user data...');
          await userProvider.syncWithServer();
        }

        // 🆕 ЗАГРУЗКА С ПАГИНАЦИЕЙ
        final news = await ApiService.getNews(
            page: _currentPage,
            limit: _itemsPerPage
        );

        await _processServerNews(news, refresh: refresh);
      } else {
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

  // 🆕 ЗАГРУЗКА СЛЕДУЮЩЕЙ СТРАНИЦЫ
  Future<void> loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreNews || _isLoading) {
      print('⏹️ Skip loadMore: isLoadingMore=$_isLoadingMore, hasMore=$_hasMoreNews, isLoading=$_isLoading');
      return;
    }

    try {
      _isLoadingMore = true;
      _safeNotifyListeners();

      print('📄 Loading more news... Page ${_currentPage + 1}');

      _serverAvailable = await ApiService.testConnection();

      if (_serverAvailable) {
        final news = await ApiService.getNews(
            page: _currentPage,
            limit: _itemsPerPage
        );

        await _processServerNews(news, refresh: false);
      } else {
        print('⚠️ Server unavailable during loadMore');
      }

    } catch (e) {
      print('❌ Load more news error: $e');
    } finally {
      _isLoadingMore = false;
      _safeNotifyListeners();
    }
  }

  // 🆕 ОБРАБОТКА НОВОСТЕЙ С ПАГИНАЦИЕЙ
  Future<void> _processServerNews(List<dynamic> serverNews, {bool refresh = false}) async {
    try {
      print('🔄 Processing ${serverNews.length} news items from YDB');

      if (serverNews.isEmpty) {
        _hasMoreNews = false;
        print('⏹️ No more news available - server returned empty list');

        if (refresh && _news.isEmpty) {
          _setError('Новостей пока нет');
        }
        return;
      }
      _correctPostTimes(serverNews);
      // Проверяем, есть ли еще новости
      if (serverNews.length < _itemsPerPage) {
        _hasMoreNews = false;
        print('⏹️ Last page reached - fewer items than requested');
      }

      _validateAndFixPostTimes();

      final List<Map<String, dynamic>> updatedNews = [];

      for (final item in serverNews) {
        try {
          final safeItem = _ensureSafeTypes(item);
          final processedItem = await _processSingleNewsItem(safeItem);
          updatedNews.add(processedItem);
        } catch (e) {
          print('❌ Error processing news item: $e');
          continue;
        }
      }

      // Сортировка по времени (новые сначала)
      updatedNews.sort((a, b) {
        final timeA = DateTime.parse(a['created_at']);
        final timeB = DateTime.parse(b['created_at']);
        return timeB.compareTo(timeA);
      });

      if (refresh) {
        _news = updatedNews;
      } else {
        _news.addAll(updatedNews);
      }

      _currentPage++;
      _lastUpdate = DateTime.now();

      await _saveNewsToLocal(_news);
      _safeNotifyListeners();

      print('✅ Processed ${updatedNews.length} news items. Total: ${_news.length}, Has more: $_hasMoreNews');

    } catch (e) {
      print('❌ Error processing news from YDB: $e');
      if (refresh) {
        _news = <Map<String, dynamic>>[];
        await _saveNewsToLocal(_news);
        _safeNotifyListeners();
      }
    }
  }

  // 🆕 ПРИОРИТЕТНАЯ ЗАГРУЗКА НОВЫХ ПОСТОВ (ДЛЯ ОБНОВЛЕНИЯ)
  Future<void> loadLatestNews() async {
    try {
      print('🆕 Loading latest news with priority...');

      _resetPagination();

      final news = await ApiService.getNews(page: 0, limit: _itemsPerPage);

      await _processServerNews(news, refresh: true);
      print('✅ Latest news loaded: ${_news.length} items');

    } catch (e) {
      print('❌ Error loading latest news: $e');
    }
  }

  // 🆕 СБРОС ПАГИНАЦИИ
  void _resetPagination() {
    _currentPage = 0;
    _hasMoreNews = true;
    _isLoadingMore = false;
    print('🔄 Pagination reset');
  }

  Future<void> refreshNews() async {
    if (_isRefreshing) return;

    try {
      _setRefreshing(true);
      print('🔄 Manual refresh triggered for user: ${userProvider.userId}');

      _serverAvailable = await ApiService.testConnection();

      if (_serverAvailable) {
        await loadLatestNews();
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

  DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue == null) return DateTime.now();

      if (dateValue is String) {
        final parsed = DateTime.tryParse(dateValue);
        if (parsed != null && parsed.year > 2000) {
          return parsed;
        }

        final timestamp = int.tryParse(dateValue);
        if (timestamp != null) {
          return _parseTimestamp(timestamp);
        }
      }

      if (dateValue is int) {
        return _parseTimestamp(dateValue);
      }

      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }


  DateTime _parseTimestamp(int timestamp) {
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

  Future<void> _syncSinglePost(String postId) async {
    try {
      if (!_serverAvailable) return;

      print('🔄 Syncing single post: $postId');
      await refreshNews();
    } catch (e) {
      print('❌ Sync single post error: $e');
    }
  }

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

      _showSnackBar(!isLiked ? 'Лайк добавлен!' : 'Лайк удален',
          !isLiked ? Colors.red : Colors.grey);

      if (_serverAvailable) {
        try {
          if (!isLiked) {
            await ApiService.likeNews(postId);
            await _syncSinglePost(postId);
          } else {
            await ApiService.unlikeNews(postId);
            await _syncSinglePost(postId);
          }
        } catch (e) {
          _showSnackBar('Действие сохранено локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Toggle like error: $e');
    }
  }

  Future<void> toggleBookmark(String postId) async {
    final int index = _findNewsIndexById(postId);
    if (index == -1) return;

    try {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isBookmarked = _getSafeBool(post['isBookmarked']);

      _news[index] = <String, dynamic>{
        ...post,
        'isBookmarked': !isBookmarked,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar(!isBookmarked ? 'В закладках!' : 'Убрано из закладок',
          !isBookmarked ? Colors.amber : Colors.grey);

      if (_serverAvailable) {
        try {
          if (!isBookmarked) {
            await ApiService.bookmarkNews(postId);
            await _syncSinglePost(postId);
          } else {
            await ApiService.unbookmarkNews(postId);
            await _syncSinglePost(postId);
          }
        } catch (e) {
          _showSnackBar('Действие сохранено локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Toggle bookmark error: $e');
    }
  }

  Future<void> toggleRepost(String postId) async {
    final int index = _findNewsIndexById(postId);
    if (index == -1) return;

    try {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isReposted = _getSafeBool(post['isReposted']);
      final int currentReposts = _getSafeInt(post['reposts_count'] ?? post['reposts']);

      final bool newRepostedState = !isReposted;
      final int newRepostsCount = newRepostedState ? currentReposts + 1 : currentReposts - 1;

      _news[index] = <String, dynamic>{
        ...post,
        'isReposted': newRepostedState,
        'reposts_count': newRepostsCount,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar(newRepostedState ? 'Репост выполнен!' : 'Репост отменен',
          newRepostedState ? Colors.green : Colors.grey);

      if (_serverAvailable) {
        try {
          if (newRepostedState) {
            await ApiService.repostNews(postId);
            await _syncSinglePost(postId);
          } else {
            await ApiService.unrepostNews(postId);
            await _syncSinglePost(postId);
          }
        } catch (e) {
          _showSnackBar('Репост сохранен локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Toggle repost error: $e');
    }
  }

  Future<void> toggleFollow(String authorId) async {
    try {
      print('👥 Toggle follow in YDB: $authorId');

      final authorPosts = _news.where((post) {
        final safePost = _ensureSafeTypes(post);
        return safePost['author_id'] == authorId;
      }).toList();

      final bool isCurrentlyFollowing = authorPosts.isNotEmpty
          ? _getSafeBool(authorPosts.first['isFollowing'])
          : false;

      final bool newFollowingState = !isCurrentlyFollowing;

      for (int i = 0; i < _news.length; i++) {
        final post = _ensureSafeTypes(_news[i]);
        if (post['author_id'] == authorId) {
          _news[i] = <String, dynamic>{
            ...post,
            'isFollowing': newFollowingState,
          };
        }
      }

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar(newFollowingState ? 'Подписка оформлена!' : 'Вы отписались',
          newFollowingState ? Colors.green : Colors.grey);

      if (_serverAvailable) {
        try {
          if (newFollowingState) {
            await _followUser(authorId);
          } else {
            await _unfollowUser(authorId);
          }
          await _syncAuthorPosts(authorId);
        } catch (e) {
          _showSnackBar('Действие сохранено локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Toggle follow error: $e');
    }
  }

  Future<void> _followUser(String authorId) async {
    try {
      final token = await ApiService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final requestData = {'targetUserId': authorId};

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/follow'),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: ApiService.timeoutSeconds));

      _handleHttpResponse(response);
      print('✅ User followed successfully in YDB: $authorId');
    } catch (e) {
      print('❌ Follow user error: $e');
      rethrow;
    }
  }

  Future<void> _unfollowUser(String authorId) async {
    try {
      final token = await ApiService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final requestData = {'targetUserId': authorId};

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/unfollow'),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: ApiService.timeoutSeconds));

      _handleHttpResponse(response);
      print('✅ User unfollowed successfully in YDB: $authorId');
    } catch (e) {
      print('❌ Unfollow user error: $e');
      rethrow;
    }
  }

  Future<void> addNews(Map<String, dynamic> newsData) async {
    try {
      if (!userProvider.isLoggedIn) {
        throw Exception('Для создания поста необходимо войти в систему');
      }

      final String content = _getSafeString(newsData['content'] ?? '');
      if (content.isEmpty) {
        throw Exception('Описание поста обязательно для заполнения');
      }

      await userProvider.syncWithServer();

      print('🎯 Creating post in YDB as: ${userProvider.userName}');

      final String authorName = userProvider.userName.isNotEmpty
          ? userProvider.userName
          : 'Пользователь';

      // 🆕 ГАРАНТИРУЕМ ТЕКУЩЕЕ ВРЕМЯ ДЛЯ НОВОГО ПОСТА
      final currentTime = DateTime.now();
      final currentTimeString = currentTime.toIso8601String();

      final Map<String, dynamic> authorData = {
        'author_id': userProvider.userId,
        'author_name': authorName,
        'author_avatar': userProvider.profileImageUrl ?? '',
      };

      final Map<String, dynamic> completeNewsData = <String, dynamic>{
        'title': _getSafeString(newsData['title'] ?? ''),
        'content': content,
        'hashtags': _parseList(newsData['hashtags']),
        ...authorData,
        // 🆕 ОТПРАВЛЯЕМ ТЕКУЩЕЕ ВРЕМЯ НА СЕРВЕР
        'created_at': currentTimeString,
        'updated_at': currentTimeString,
      };

      Map<String, dynamic> createdNews;

      try {
        print('🌐 Creating news on YDB server...');
        createdNews = await ApiService.createNews(completeNewsData);
        print('✅ News created on YDB server: ${createdNews['id']}');
      } catch (serverError) {
        print('❌ YDB Server creation failed: $serverError');
        throw Exception('Не удалось создать пост на сервере: ${serverError.toString()}');
      }

      final Map<String, dynamic> safeNews = _ensureSafeTypes(createdNews);

      // 🆕 ИСПОЛЬЗУЕМ ДАННЫЕ ОТ СЕРВЕРА, НО С ПРАВИЛЬНЫМ ПАРСИНГОМ ВРЕМЕНИ
      final Map<String, dynamic> formattedNews = {
        'id': _getSafeString(safeNews['id']),
        'title': _getSafeString(safeNews['title'] ?? ''),
        'content': _getSafeString(safeNews['content'] ?? content),
        'author_id': _getSafeString(safeNews['author_id'] ?? userProvider.userId),
        'author_name': _getSafeString(safeNews['author_name'] ?? authorName),
        'author_avatar': _getSafeString(safeNews['author_avatar'] ?? ''),
        'hashtags': _parseList(safeNews['hashtags']),
        'likes_count': _getSafeInt(safeNews['likes_count'] ?? 0),
        'comments_count': _getSafeInt(safeNews['comments_count'] ?? 0),
        'reposts_count': _getSafeInt(safeNews['reposts_count'] ?? 0),
        'bookmarks_count': _getSafeInt(safeNews['bookmarks_count'] ?? 0),
        'share_count': _getSafeInt(safeNews['share_count'] ?? 0),
        'isLiked': false,
        'isBookmarked': false,
        'isReposted': false,
        'isFollowing': false,
        'is_repost': false,
        'original_author_id': _getSafeString(safeNews['original_author_id'] ?? userProvider.userId),
        // 🆕 ПРАВИЛЬНО ПАРСИМ ВРЕМЯ ОТ СЕРВЕРА
        'created_at': _parseDateTime(safeNews['created_at']).toIso8601String(),
        'updated_at': _parseDateTime(safeNews['updated_at']).toIso8601String(),
        'comments': [],
        'source': 'YDB',
      };

      // 🆕 ДОБАВЛЯЕМ В НАЧАЛО СПИСКА И НЕМЕДЛЕННО ОБНОВЛЯЕМ
      _news.insert(0, formattedNews);
      _safeNotifyListeners();

      await _saveNewsToLocal(_news);

      // 🆕 НЕМЕДЛЕННОЕ ОБНОВЛЕНИЕ СЧЕТЧИКОВ
      userProvider.updateStats(<String, int>{
        'posts': (userProvider.stats['posts'] ?? 0) + 1,
      });

      print('✅ Post created successfully in YDB with correct time');

    } catch (e) {
      print('❌ Error creating news in YDB: $e');
      throw Exception('Ошибка создания поста в базе данных: ${e.toString()}');
    }
  }


  // 🆕 МЕТОД ДЛЯ КОРРЕКЦИИ ВРЕМЕНИ В СУЩЕСТВУЮЩИХ ПОСТАХ
  void _correctPostTimes(List<dynamic> posts) {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(Duration(hours: 1));

    for (int i = 0; i < posts.length; i++) {
      final post = _ensureSafeTypes(posts[i]);
      final createdAt = _parseDateTime(post['created_at']);

      // 🆕 ЕСЛИ ПОСТ СОЗДАН В ТЕЧЕНИЕ ПОСЛЕДНЕГО ЧАСА, ДЕЛАЕМ ЕГО "ТОЛЬКО ЧТО"
      if (createdAt.isAfter(oneHourAgo) && createdAt.isBefore(now)) {
        posts[i] = {
          ...post,
          'created_at': now.toIso8601String(),
        };
        print('🕒 Corrected post time to "just now": ${post['id']}');
      }
    }
  }

  void _handleHttpResponse(http.Response response) {
    print('🔧 HTTP Response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('success') && data['success'] == true) {
          return;
        } else if (data.containsKey('error')) {
          throw HttpException(data['error'] ?? 'Unknown error');
        }

        return;
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        throw HttpException('Invalid response format');
      }
    } else {
      _handleHttpErrorResponse(response);
    }
  }

  void _handleHttpErrorResponse(http.Response response) {
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
        throw HttpException('HTTP ${response.statusCode}');
    }
  }

  Future<void> shareNews(String postId) async {
    try {
      print('🔗 Sharing news: $postId');

      final int index = _findNewsIndexById(postId);
      if (index != -1) {
        final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
        final int currentShares = _getSafeInt(post['share_count']);

        _news[index] = <String, dynamic>{
          ...post,
          'share_count': currentShares + 1,
        };

        _safeNotifyListeners();
        await _saveNewsToLocal(_news);
      }

      _showSnackBar('Поделились постом!', Colors.blue);

      if (_serverAvailable) {
        try {
          await _shareNewsOnServer(postId);
          await _syncSinglePost(postId);
          print('✅ Share sent to YDB: $postId');
        } catch (e) {
          print('❌ Share sync error with YDB: $e');
          _showSnackBar('Шаринг сохранен локально', Colors.orange);
        }
      }

    } catch (e) {
      print('❌ Share error: $e');
      throw Exception('Не удалось поделиться постом: ${e.toString()}');
    }
  }

  Future<void> _shareNewsOnServer(String postId) async {
    try {
      final token = await ApiService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final requestData = {'newsId': postId};

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/share'),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: ApiService.timeoutSeconds));

      _handleHttpResponse(response);
      print('✅ News shared successfully in YDB: $postId');
    } catch (e) {
      print('❌ Share news error: $e');
      rethrow;
    }
  }

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

      _news[index] = <String, dynamic>{
        ...post,
        'comments_count': currentCommentsCount + 1,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar('Комментарий добавлен!', Colors.green);

      if (_serverAvailable) {
        try {
          await ApiService.addComment(
            postId,
            text,
            userProvider.userName.isNotEmpty ? userProvider.userName : 'Пользователь',
          );

          await _syncSinglePost(postId);
          print('✅ Comment added successfully to YDB: $postId');
        } catch (e) {
          print('❌ Comment sync error with YDB: $e');
          _showSnackBar('Комментарий сохранен локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Add comment error: $e');
      throw Exception('Ошибка при добавлении комментария: ${e.toString()}');
    }
  }

  Future<void> deleteNews(String postId) async {
    try {
      final int index = _findNewsIndexById(postId);
      if (index == -1) {
        throw Exception('Пост не найден');
      }

      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);

      if (post['author_id'] != userProvider.userId) {
        throw Exception('Вы можете удалять только свои посты');
      }

      // 🎯 СОХРАНЯЕМ ПОСТ ДЛЯ ВОЗМОЖНОГО ВОССТАНОВЛЕНИЯ
      final Map<String, dynamic> deletedPost = post;

      // 🎯 ОПТИМИСТИЧЕСКОЕ УДАЛЕНИЕ
      _news.removeAt(index);
      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      // 🎯 ПРОВЕРЯЕМ mounted ПЕРЕД ПОКАЗОМ SNACKBAR
      if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
        _showSnackBar('Пост удален!', Colors.green);
      }

      // 🎯 СИНХРОНИЗАЦИЯ С СЕРВЕРОМ
      if (_serverAvailable) {
        try {
          await ApiService.deleteNews(postId);
          print('✅ Post deleted from YDB: $postId');
        } catch (e) {
          print('❌ Delete from YDB failed: $e');
          // 🎯 ВОССТАНАВЛИВАЕМ ПОСТ ПРИ ОШИБКЕ
          _news.insert(index, deletedPost);
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);

          // 🎯 ПРОВЕРЯЕМ mounted ПЕРЕД ПОКАЗОМ ОШИБКИ
          if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
            _showSnackBar('Ошибка удаления на сервере', Colors.red);
          }
          rethrow;
        }
      }

      userProvider.updateStats(<String, int>{
        'posts': (userProvider.stats['posts'] ?? 1) - 1,
      });

      print('✅ Post deleted successfully: $postId');

    } catch (e) {
      print('❌ Error deleting news: $e');
      throw Exception('Ошибка удаления поста: ${e.toString()}');
    }
  }

  Future<void> updateNews(String postId, Map<String, dynamic> updateData) async {
    try {
      final int index = _findNewsIndexById(postId);
      if (index == -1) {
        throw Exception('Пост не найден');
      }

      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);

      if (post['author_id'] != userProvider.userId) {
        throw Exception('Вы можете редактировать только свои посты');
      }

      // 🎯 ПОДГОТОВКА ДАННЫХ ДЛЯ ОБНОВЛЕНИЯ
      final Map<String, dynamic> preparedUpdateData = {
        'title': updateData['title']?.toString() ?? post['title'],
        'content': updateData['content']?.toString() ?? post['content'],
        'hashtags': updateData['hashtags'] is List ? updateData['hashtags'] : _parseList(updateData['hashtags']),
      };

      print('✏️ Updating news: $postId with data: $preparedUpdateData');

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ
      final Map<String, dynamic> updatedPost = {
        ...post,
        ...preparedUpdateData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      _news[index] = updatedPost;
      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar('Пост обновлен!', Colors.green);

      // 🎯 СИНХРОНИЗАЦИЯ С СЕРВЕРОМ
      if (_serverAvailable) {
        try {
          // 🎯 ПРАВИЛЬНЫЙ ВЫЗОВ API
          await ApiService.updateNews(postId, preparedUpdateData);

          // 🎯 ПЕРЕЗАГРУЖАЕМ ДАННЫЕ ДЛЯ ПОДТВЕРЖДЕНИЯ
          await _syncSinglePost(postId);

          print('✅ Post updated successfully in YDB: $postId');
        } catch (e) {
          print('❌ Update in YDB failed: $e');
          // 🎯 ВОССТАНАВЛИВАЕМ ПРЕЖНЕЕ СОСТОЯНИЕ ПРИ ОШИБКЕ
          _news[index] = post;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);

          _showSnackBar('Ошибка синхронизации с сервером', Colors.red);
          rethrow;
        }
      }

    } catch (e) {
      print('❌ Error updating news: $e');
      throw Exception('Ошибка редактирования поста: ${e.toString()}');
    }
  }

  Future<void> _updateNewsOnServer(String postId, Map<String, dynamic> updateData) async {
    try {
      final token = await ApiService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // 🎯 ПОДГОТАВЛИВАЕМ ДАННЫЕ ДЛЯ ОБНОВЛЕНИЯ
      final requestData = {
        'newsId': postId,
        'updateData': {
          'title': updateData['title'],
          'content': updateData['content'],
          'hashtags': updateData['hashtags'],
        },
      };

      print('🔗 Updating news on server: $postId');
      print('📦 Update data: $requestData');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/updateNews'),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: ApiService.timeoutSeconds));

      // 🎯 ПРАВИЛЬНО ОБРАБАТЫВАЕМ ОТВЕТ
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('success') && data['success'] == true) {
          print('✅ News updated successfully on server');
          return;
        } else {
          throw HttpException(data['error'] ?? 'Unknown error');
        }
      } else {
        _handleHttpErrorResponse(response);
      }
    } catch (e) {
      print('❌ Update news error: $e');
      rethrow;
    }
  }

  Future<void> _syncAuthorPosts(String authorId) async {
    try {
      if (!_serverAvailable) return;

      print('🔄 Syncing author posts: $authorId');
      await refreshNews();
    } catch (e) {
      print('❌ Sync author posts error: $e');
    }
  }

  Future<Map<String, dynamic>> _processSingleNewsItem(dynamic item) async {
    final safeItem = _ensureSafeTypes(item);

    final id = _getSafeString(safeItem['id']);
    final content = _getSafeString(safeItem['content']);
    final createdAt = _parseDateTime(safeItem['created_at']);
    final updatedAt = _parseDateTime(safeItem['updated_at']);

    final authorName = _getSafeString(safeItem['author_name']);
    final finalAuthorName = authorName.isNotEmpty ? authorName : 'Автор';

    return <String, dynamic>{
      'id': id,
      'title': _getSafeString(safeItem['title']),
      'content': content.isNotEmpty ? content : 'Нет описания',
      'author_id': _getSafeString(safeItem['author_id']) ?? 'unknown',
      'author_name': finalAuthorName,
      'author_avatar': _getSafeString(safeItem['author_avatar']) ?? '',
      'hashtags': _parseList(safeItem['hashtags']),
      'is_repost': _getSafeBool(safeItem['is_repost']),
      'original_author_id': _getSafeString(safeItem['original_author_id']),

      'likes_count': _getSafeInt(safeItem['likes_count'] ?? safeItem['likes']),
      'comments_count': _getSafeInt(safeItem['comments_count']),
      'reposts_count': _getSafeInt(safeItem['reposts_count'] ?? safeItem['reposts']),
      'bookmarks_count': _getSafeInt(safeItem['bookmarks_count']),
      'share_count': _getSafeInt(safeItem['share_count']),

      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      'isLiked': _getSafeBool(safeItem['isLiked']),
      'isBookmarked': _getSafeBool(safeItem['isBookmarked']),
      'isReposted': _getSafeBool(safeItem['isReposted']),
      'isFollowing': _getSafeBool(safeItem['isFollowing']),

      'comments': [],
      'source': 'YDB',
    };
  }

  Future<void> _loadLocalNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedNews = prefs.getString('cached_news');

      if (cachedNews != null) {
        final decodedNews = json.decode(cachedNews);
        if (decodedNews is List) {
          _news = decodedNews.map((item) {
            final safeItem = _ensureSafeTypes(item);
            final createdAt = _parseDateTime(safeItem['created_at']);
            final updatedAt = _parseDateTime(safeItem['updated_at']);

            return {
              ...safeItem,
              'created_at': createdAt.toIso8601String(),
              'updated_at': updatedAt.toIso8601String(),
            };
          }).toList();

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

  int _findNewsIndexById(String newsId) {
    return _news.indexWhere((news) {
      try {
        final Map<String, dynamic> safeNews = _ensureSafeTypes(news);
        final id = safeNews['id']?.toString();
        return id == newsId && id != null && id.isNotEmpty;
      } catch (e) {
        return false;
      }
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (navigatorKey.currentState != null &&
        navigatorKey.currentState!.mounted &&
        navigatorKey.currentContext != null &&
        ScaffoldMessenger.of(navigatorKey.currentContext!).mounted) {
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void clearError() {
    _setError(null);
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  void _setRefreshing(bool refreshing) {
    if (_isRefreshing != refreshing) {
      _isRefreshing = refreshing;
      _safeNotifyListeners();
    }
  }

  void _setError(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  void _validateAndFixPostTimes() {
    final now = DateTime.now();

    for (int i = 0; i < _news.length; i++) {
      final post = _ensureSafeTypes(_news[i]);
      final createdAt = DateTime.parse(_getSafeString(post['created_at']));

      // 🎯 ЕСЛИ ПОСТ БУДУЩЕГО ИЛИ ОЧЕНЬ СТАРЫЙ - ИСПРАВЛЯЕМ
      if (createdAt.isAfter(now.add(Duration(hours: 1))) ||
          createdAt.isBefore(DateTime(2020))) {
        print('⚠️ Fixing invalid post time: ${post['id']}');
        _news[i] = {
          ...post,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
      }
    }
  }

  void updateServerStatus(bool available) {
    if (_serverAvailable != available) {
      _serverAvailable = available;
      _safeNotifyListeners();
    }
  }

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