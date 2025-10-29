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

  // 🆕 УМНОЕ КЕШИРОВАНИЕ
  List<dynamic> _cachedNews = [];
  DateTime _lastCacheTime = DateTime.now();
  bool _showSyncingIndicator = false;

  // 🆕 ПАГИНАЦИЯ
  int _currentPage = 0;
  int _itemsPerPage = 20;
  bool _hasMoreNews = true;
  bool _isLoadingMore = false;

  // 🆕 ИСПРАВЛЕНИЕ: Трекер для предотвращения дублирования действий
  final Set<String> _pendingActions = {};
  final Map<String, Completer<void>> _actionCompleters = {};

  final UserProvider userProvider;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get serverAvailable => _serverAvailable;
  DateTime? get lastUpdate => _lastUpdate;
  bool get showSyncingIndicator => _showSyncingIndicator;
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

  // 🟢 ОСНОВНОЙ МЕТОД ЗАГРУЗКИ С УМНЫМ КЕШИРОВАНИЕМ
  Future<void> loadNews({bool refresh = false}) async {
    try {
      if (refresh) {
        _resetPagination();
        _showSyncingIndicator = true;
        _safeNotifyListeners();
        print('🔄 Refresh requested - keeping cached data');
      }

      if (!_hasMoreNews) {
        print('⏹️ No more news available');
        return;
      }

      _setLoading(true);

      // 🎯 ПРОВЕРКА КЕША: если есть кеш младше 5 минут - показываем сразу
      if (_cachedNews.isNotEmpty &&
          DateTime.now().difference(_lastCacheTime).inMinutes < 5 &&
          !refresh) {
        _news = List.from(_cachedNews);
        _safeNotifyListeners();
        print('⚡ Showing cached news from ${_lastCacheTime}');
      }

      print('🌐 Loading news page $_currentPage ($_itemsPerPage items)');

      _serverAvailable = await ApiService.testConnection();
      print('🔗 Server available: $_serverAvailable');

      if (_serverAvailable) {
        if (userProvider.isLoggedIn) {
          await userProvider.syncWithServer();
        }

        // 🆕 ЗАГРУЗКА С ТАЙМАУТОМ
        final news = await ApiService.getNews(
            page: _currentPage,
            limit: _itemsPerPage
        ).timeout(Duration(seconds: 7), onTimeout: () {
          print('⏰ News loading timeout, using cached data');
          return [];
        });

        await _processServerNews(news, refresh: refresh);
      } else {
        await _loadLocalNews();
        _setError('Сервер временно недоступен. Работаем в автономном режиме.');
      }

    } catch (e) {
      print('❌ Failed to load news: $e');
      await _loadLocalNews();
    } finally {
      _setLoading(false);
      _showSyncingIndicator = false;
      _safeNotifyListeners();
    }
  }

  // 🟢 УЛУЧШЕННАЯ ОБРАБОТКА НОВОСТЕЙ С YDB
  Future<void> _processServerNews(List<dynamic> serverNews, {bool refresh = false}) async {
    try {
      print('🔄 Processing ${serverNews.length} news items from YDB');

      // 🎯 ЕСЛИ СЕРВЕР ВЕРНУЛ ПУСТОЙ СПИСОК - ИСПОЛЬЗУЕМ FALLBACK
      List<dynamic> newsToProcess = serverNews;
      if (serverNews.isEmpty && _news.isEmpty) {
        print('⚠️ Server returned empty list, using fallback data');
        newsToProcess = _getFallbackNews();
      }

      if (newsToProcess.isEmpty) {
        _hasMoreNews = false;
        return;
      }

      if (newsToProcess.length < _itemsPerPage) {
        _hasMoreNews = false;
      }

      _validateAndFixPostTimes();

      final List<Map<String, dynamic>> updatedNews = [];

      for (final item in newsToProcess) {
        try {
          final safeItem = _ensureSafeTypes(item);
          final processedItem = await _processSingleNewsItem(safeItem);
          updatedNews.add(processedItem);
        } catch (e) {
          print('❌ Error processing news item: $e');
          continue;
        }
      }

      // 🎯 СОРТИРОВКА ПО ДАТЕ (НОВЫЕ СНАЧАЛА)
      updatedNews.sort((a, b) {
        final timeA = DateTime.parse(a['created_at']);
        final timeB = DateTime.parse(b['created_at']);
        return timeB.compareTo(timeA);
      });

      if (refresh || _news.isEmpty) {
        _news = updatedNews;
      } else {
        // 🎯 ИСКЛЮЧАЕМ ДУБЛИКАТЫ ПРИ ДОБАВЛЕНИИ
        final existingIds = _news.map((n) => n['id']).toSet();
        final newItems = updatedNews.where((item) => !existingIds.contains(item['id'])).toList();
        _news.addAll(newItems);
      }

      // 🎯 СОХРАНЯЕМ В КЕШ
      _cachedNews = List.from(_news);
      _lastCacheTime = DateTime.now();

      _currentPage++;
      _lastUpdate = DateTime.now();

      await _saveNewsToLocal(_news);
      _safeNotifyListeners();

      print('✅ Processed ${updatedNews.length} news items. Total: ${_news.length}');

    } catch (e) {
      print('❌ Error processing news: $e');
      if (refresh || _news.isEmpty) {
        _news = _getFallbackNews();
        await _saveNewsToLocal(_news);
        _safeNotifyListeners();
      }
    }
  }

  // 🟢 FALLBACK ДАННЫЕ ДЛЯ МГНОВЕННОГО ПОКАЗА
  List<Map<String, dynamic>> _getFallbackNews() {
    return [
      {
        'id': 'fallback_1',
        'title': 'Добро пожаловать в Akort Media!',
        'content': 'Это ваша лента новостей. Здесь будут появляться посты от пользователей, на которых вы подписаны.',
        'author_id': 'system_1',
        'author_name': 'Система',
        'author_avatar': '',
        'hashtags': ['добро пожаловать'],
        'likes_count': 0,
        'comments_count': 0,
        'reposts_count': 0,
        'bookmarks_count': 0,
        'share_count': 0,
        'isLiked': false,
        'isBookmarked': false,
        'isReposted': false,
        'isFollowing': false,
        'is_repost': false,
        'original_author_id': 'system_1',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'comments': [],
        'source': 'FALLBACK'
      },
      {
        'id': 'fallback_2',
        'title': 'Как пользоваться приложением',
        'content': '• Нажимайте + для создания поста\n• Лайкайте интересные посты\n• Комментируйте и делитесь мнением\n• Подписывайтесь на авторов',
        'author_id': 'system_2',
        'author_name': 'Помощник',
        'author_avatar': '',
        'hashtags': ['инструкция', 'помощь'],
        'likes_count': 0,
        'comments_count': 0,
        'reposts_count': 0,
        'bookmarks_count': 0,
        'share_count': 0,
        'isLiked': false,
        'isBookmarked': false,
        'isReposted': false,
        'isFollowing': false,
        'is_repost': false,
        'original_author_id': 'system_2',
        'created_at': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        'updated_at': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        'comments': [],
        'source': 'FALLBACK'
      }
    ];
  }

  // 🟢 ЗАГРУЗКА СЛЕДУЮЩЕЙ СТРАНИЦЫ
  Future<void> loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreNews || _isLoading) return;

    try {
      _isLoadingMore = true;
      _safeNotifyListeners();

      _serverAvailable = await ApiService.testConnection();

      if (_serverAvailable) {
        final news = await ApiService.getNews(
            page: _currentPage,
            limit: _itemsPerPage
        ).timeout(Duration(seconds: 7), onTimeout: () {
          return [];
        });

        await _processServerNews(news, refresh: false);
      } else {
        _hasMoreNews = false;
      }

    } catch (e) {
      print('❌ Load more news error: $e');
      _hasMoreNews = false;
    } finally {
      _isLoadingMore = false;
      _safeNotifyListeners();
    }
  }

  // 🟢 ПРИОРИТЕТНАЯ ЗАГРУЗКА НОВЫХ НОВОСТЕЙ
  Future<void> loadLatestNews() async {
    try {
      _resetPagination();

      final news = await ApiService.getNews(page: 0, limit: _itemsPerPage)
          .timeout(Duration(seconds: 5), onTimeout: () {
        return [];
      });

      await _processServerNews(news, refresh: true);

    } catch (e) {
      print('❌ Error loading latest news: $e');
    }
  }

  // 🟢 СБРОС ПАГИНАЦИИ
  void _resetPagination() {
    _currentPage = 0;
    _hasMoreNews = true;
    _isLoadingMore = false;
  }

  // 🟢 УЛУЧШЕННЫЙ REFRESH - НЕ ЧИСТИТ ДАННЫЕ
  Future<void> refreshNews() async {
    if (_isRefreshing) return;

    try {
      _isRefreshing = true;
      _showSyncingIndicator = true;
      _safeNotifyListeners();

      _serverAvailable = await ApiService.testConnection();

      if (_serverAvailable) {
        await loadLatestNews();
        _setError(null);
      } else {
        _setError('Сервер недоступен. Данные могут быть неактуальны.');
      }
    } catch (e) {
      print('❌ Refresh failed: $e');
    } finally {
      _isRefreshing = false;
      _showSyncingIndicator = false;
      _safeNotifyListeners();
    }
  }

  // 🟢 ИСПРАВЛЕННЫЙ МЕТОД ДЛЯ ЛАЙКОВ С ПРЕДОТВРАЩЕНИЕМ ДУБЛИРОВАНИЯ
  Future<void> toggleLike(String postId) async {
    // 🆕 ПРОВЕРКА: предотвращение дублирования действий
    final actionKey = 'like_$postId';
    if (_pendingActions.contains(actionKey)) {
      print('⏳ Like action already in progress for $postId, skipping');
      return;
    }

    final int index = _findNewsIndexById(postId);
    if (index == -1) {
      print('❌ Post not found for like: $postId');
      return;
    }

    try {
      // 🆕 БЛОКИРОВКА ДЕЙСТВИЯ
      _pendingActions.add(actionKey);
      final completer = Completer<void>();
      _actionCompleters[actionKey] = completer;

      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isLiked = _getSafeBool(post['isLiked']);
      final int currentLikes = _getSafeInt(post['likes_count']);

      // 🎯 СОХРАНЯЕМ ИСХОДНОЕ СОСТОЯНИЕ ДЛЯ ВОЗМОЖНОСТИ ОТКАТА
      final Map<String, dynamic> originalPost = Map<String, dynamic>.from(post);

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ
      _news[index] = <String, dynamic>{
        ...post,
        'isLiked': !isLiked,
        'likes_count': isLiked ? currentLikes - 1 : currentLikes + 1,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar(!isLiked ? 'Лайк добавлен!' : 'Лайк удален',
          !isLiked ? Colors.red : Colors.grey);

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          if (!isLiked) {
            await ApiService.likeNews(postId);
            // 🆕 ОБНОВЛЯЕМ UserProvider
            userProvider.addLike(postId);
          } else {
            await ApiService.unlikeNews(postId);
            // 🆕 ОБНОВЛЯЕМ UserProvider
            userProvider.removeLike(postId);
          }
          print('✅ Like sync with YDB successful for $postId');
        } catch (e) {
          print('❌ Like sync error: $e');

          // 🆕 ВОССТАНАВЛИВАЕМ ИСХОДНОЕ СОСТОЯНИЕ ПРИ ОШИБКЕ
          _news[index] = originalPost;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);

          _showSnackBar('Ошибка синхронизации с сервером', Colors.orange);
          rethrow;
        }
      }
    } catch (e) {
      print('❌ Toggle like error: $e');
    } finally {
      // 🆕 РАЗБЛОКИРОВКА ДЕЙСТВИЯ
      _pendingActions.remove(actionKey);
      _actionCompleters.remove(actionKey)?.complete();
    }
  }

  // 🟢 ИСПРАВЛЕННЫЙ МЕТОД ДЛЯ ЗАКЛАДОК
  Future<void> toggleBookmark(String postId) async {
    final actionKey = 'bookmark_$postId';
    if (_pendingActions.contains(actionKey)) {
      print('⏳ Bookmark action already in progress for $postId, skipping');
      return;
    }

    final int index = _findNewsIndexById(postId);
    if (index == -1) return;

    try {
      _pendingActions.add(actionKey);
      final completer = Completer<void>();
      _actionCompleters[actionKey] = completer;

      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isBookmarked = _getSafeBool(post['isBookmarked']);
      final Map<String, dynamic> originalPost = Map<String, dynamic>.from(post);

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ
      _news[index] = <String, dynamic>{
        ...post,
        'isBookmarked': !isBookmarked,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar(!isBookmarked ? 'В закладках!' : 'Убрано из закладок',
          !isBookmarked ? Colors.amber : Colors.grey);

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          if (!isBookmarked) {
            await ApiService.bookmarkNews(postId);
            userProvider.addBookmark(postId);
          } else {
            await ApiService.unbookmarkNews(postId);
            userProvider.removeBookmark(postId);
          }
          print('✅ Bookmark sync with YDB successful');
        } catch (e) {
          print('❌ Bookmark sync error: $e');

          // ОТКАТ ПРИ ОШИБКЕ
          _news[index] = originalPost;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);

          _showSnackBar('Действие сохранено локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Toggle bookmark error: $e');
    } finally {
      _pendingActions.remove(actionKey);
      _actionCompleters.remove(actionKey)?.complete();
    }
  }

  // 🟢 ИСПРАВЛЕННЫЙ МЕТОД ДЛЯ РЕПОСТОВ
  Future<void> toggleRepost(String postId) async {
    final actionKey = 'repost_$postId';
    if (_pendingActions.contains(actionKey)) {
      print('⏳ Repost action already in progress for $postId, skipping');
      return;
    }

    final int index = _findNewsIndexById(postId);
    if (index == -1) return;

    try {
      _pendingActions.add(actionKey);
      final completer = Completer<void>();
      _actionCompleters[actionKey] = completer;

      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final bool isReposted = _getSafeBool(post['isReposted']);
      final int currentReposts = _getSafeInt(post['reposts_count']);
      final Map<String, dynamic> originalPost = Map<String, dynamic>.from(post);

      final bool newRepostedState = !isReposted;
      final int newRepostsCount = newRepostedState ? currentReposts + 1 : currentReposts - 1;

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ
      _news[index] = <String, dynamic>{
        ...post,
        'isReposted': newRepostedState,
        'reposts_count': newRepostsCount,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar(newRepostedState ? 'Репост выполнен!' : 'Репост отменен',
          newRepostedState ? Colors.green : Colors.grey);

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          if (newRepostedState) {
            await ApiService.repostNews(postId);
            userProvider.addRepost(postId);
          } else {
            await ApiService.unrepostNews(postId);
            userProvider.removeRepost(postId);
          }
          print('✅ Repost sync with YDB successful');
        } catch (e) {
          print('❌ Repost sync error: $e');

          // ОТКАТ ПРИ ОШИБКЕ
          _news[index] = originalPost;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);

          _showSnackBar('Репост сохранен локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Toggle repost error: $e');
    } finally {
      _pendingActions.remove(actionKey);
      _actionCompleters.remove(actionKey)?.complete();
    }
  }

  // 🟢 ПОДПИСКИ С ИНТЕГРАЦИЕЙ YDB
  Future<void> toggleFollow(String authorId) async {
    final actionKey = 'follow_$authorId';
    if (_pendingActions.contains(actionKey)) {
      print('⏳ Follow action already in progress for $authorId, skipping');
      return;
    }

    try {
      _pendingActions.add(actionKey);
      final completer = Completer<void>();
      _actionCompleters[actionKey] = completer;

      final authorPosts = _news.where((post) {
        final safePost = _ensureSafeTypes(post);
        return safePost['author_id'] == authorId;
      }).toList();

      final bool isCurrentlyFollowing = authorPosts.isNotEmpty
          ? _getSafeBool(authorPosts.first['isFollowing'])
          : false;

      final bool newFollowingState = !isCurrentlyFollowing;

      // 🎯 СОХРАНЯЕМ ИСХОДНЫЕ СОСТОЯНИЯ ДЛЯ ВОЗМОЖНОСТИ ОТКАТА
      final List<Map<String, dynamic>> originalPosts = [];
      for (final post in _news) {
        final safePost = _ensureSafeTypes(post);
        if (safePost['author_id'] == authorId) {
          originalPosts.add(Map<String, dynamic>.from(safePost));
        }
      }

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ ВСЕХ ПОСТОВ АВТОРА
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

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          if (newFollowingState) {
            await ApiService.followUser(authorId);
            userProvider.followUser(authorId);
          } else {
            await ApiService.unfollowUser(authorId);
            userProvider.unfollowUser(authorId);
          }
          print('✅ Follow sync with YDB successful');
        } catch (e) {
          print('❌ Follow sync error: $e');

          // ОТКАТ ПРИ ОШИБКЕ
          for (int i = 0; i < _news.length; i++) {
            final post = _ensureSafeTypes(_news[i]);
            if (post['author_id'] == authorId) {
              final originalPost = originalPosts.firstWhere(
                    (p) => p['id'] == post['id'],
                orElse: () => post,
              );
              _news[i] = originalPost;
            }
          }
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);

          _showSnackBar('Действие сохранено локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Toggle follow error: $e');
    } finally {
      _pendingActions.remove(actionKey);
      _actionCompleters.remove(actionKey)?.complete();
    }
  }

  // 🟢 КОММЕНТАРИИ С ИНТЕГРАЦИЕЙ YDB
  Future<void> addComment(String postId, String text) async {
    final int index = _findNewsIndexById(postId);
    if (index == -1) return;

    try {
      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final int currentCommentsCount = _getSafeInt(post['comments_count']);

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ
      _news[index] = <String, dynamic>{
        ...post,
        'comments_count': currentCommentsCount + 1,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar('Комментарий добавлен!', Colors.green);

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          await ApiService.addComment(
            postId,
            text,
            userProvider.userName.isNotEmpty ? userProvider.userName : 'Пользователь',
          );
          print('✅ Comment sync with YDB successful');
        } catch (e) {
          print('❌ Comment sync error: $e');
          _showSnackBar('Комментарий сохранен локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Add comment error: $e');
    }
  }

  // 🟢 СОЗДАНИЕ НОВОСТИ С ИНТЕГРАЦИЕЙ YDB
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

      final String authorName = userProvider.userName.isNotEmpty
          ? userProvider.userName
          : 'Пользователь';

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
      };

      Map<String, dynamic> createdNews;

      try {
        createdNews = await ApiService.createNews(completeNewsData);
        print('✅ News created on YDB successfully');
      } catch (serverError) {
        throw Exception('Не удалось создать пост на сервере: ${serverError.toString()}');
      }

      final Map<String, dynamic> safeNews = _ensureSafeTypes(createdNews);

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
        'created_at': _parseDateTime(safeNews['created_at']).toIso8601String(),
        'updated_at': _parseDateTime(safeNews['updated_at']).toIso8601String(),
        'comments': [],
        'source': 'YDB',
      };

      // 🎯 ДОБАВЛЯЕМ В НАЧАЛО ЛЕНТЫ
      _news.insert(0, formattedNews);
      _safeNotifyListeners();

      await _saveNewsToLocal(_news);

      userProvider.updateStats(<String, int>{
        'posts': (userProvider.stats['posts'] ?? 0) + 1,
      });

      _showSnackBar('Пост опубликован!', Colors.green);

    } catch (e) {
      print('❌ Error creating news: $e');
      throw Exception('Ошибка создания поста: ${e.toString()}');
    }
  }

  // 🟢 ОБНОВЛЕНИЕ НОВОСТИ С ИНТЕГРАЦИЕЙ YDB
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

      final Map<String, dynamic> preparedUpdateData = {
        'title': updateData['title']?.toString() ?? post['title'],
        'content': updateData['content']?.toString() ?? post['content'],
        'hashtags': updateData['hashtags'] is List ? updateData['hashtags'] : _parseList(updateData['hashtags']),
      };

      final Map<String, dynamic> updatedPost = {
        ...post,
        ...preparedUpdateData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      _news[index] = updatedPost;
      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar('Пост обновлен!', Colors.green);

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          await ApiService.updateNews(postId, preparedUpdateData);
          print('✅ News update sync with YDB successful');
        } catch (e) {
          _news[index] = post; // Откатываем изменения при ошибке
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

  // 🟢 УДАЛЕНИЕ НОВОСТИ С ИНТЕГРАЦИЕЙ YDB
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

      final Map<String, dynamic> deletedPost = post;

      _news.removeAt(index);
      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
        _showSnackBar('Пост удален!', Colors.green);
      }

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          await ApiService.deleteNews(postId);
          print('✅ News delete sync with YDB successful');
        } catch (e) {
          _news.insert(index, deletedPost); // Восстанавливаем при ошибке
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);
          if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
            _showSnackBar('Ошибка удаления на сервере', Colors.red);
          }
          rethrow;
        }
      }

      userProvider.updateStats(<String, int>{
        'posts': (userProvider.stats['posts'] ?? 1) - 1,
      });

    } catch (e) {
      print('❌ Error deleting news: $e');
      throw Exception('Ошибка удаления поста: ${e.toString()}');
    }
  }

  // 🟢 ОБРАБОТКА ОДНОЙ НОВОСТИ
  Future<Map<String, dynamic>> _processSingleNewsItem(dynamic item) async {
    final safeItem = _ensureSafeTypes(item);

    final id = _getSafeString(safeItem['id']);
    final content = _getSafeString(safeItem['content']);
    final createdAt = _parseDateTime(safeItem['created_at']);
    final updatedAt = _parseDateTime(safeItem['updated_at']);

    final authorName = _getSafeString(safeItem['author_name']);
    final finalAuthorName = authorName.isNotEmpty ? authorName : 'Автор';

    // 🆕 ИСПРАВЛЕНИЕ: Синхронизация с UserProvider для актуального состояния
    final userLikedPosts = userProvider.likedPosts;
    final userBookmarkedPosts = userProvider.bookmarkedPosts;
    final userRepostedPosts = userProvider.repostedPosts;
    final userFollowing = userProvider.following;

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

      'likes_count': _getSafeInt(safeItem['likes_count']),
      'comments_count': _getSafeInt(safeItem['comments_count']),
      'reposts_count': _getSafeInt(safeItem['reposts_count']),
      'bookmarks_count': _getSafeInt(safeItem['bookmarks_count']),
      'share_count': _getSafeInt(safeItem['share_count']),

      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      // 🆕 ИСПРАВЛЕНИЕ: Используем актуальное состояние из UserProvider
      'isLiked': userLikedPosts.contains(id),
      'isBookmarked': userBookmarkedPosts.contains(id),
      'isReposted': userRepostedPosts.contains(id),
      'isFollowing': userFollowing.contains(_getSafeString(safeItem['author_id'])),

      'comments': [],
      'source': 'YDB',
    };
  }

  // 🟢 ЗАГРУЗКА ЛОКАЛЬНЫХ ДАННЫХ
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
        } else {
          _news = <Map<String, dynamic>>[];
        }
      } else {
        _news = _getFallbackNews();
      }
    } catch (e) {
      _news = _getFallbackNews();
    }
  }

  // 🟢 СОХРАНЕНИЕ ДАННЫХ ЛОКАЛЬНО
  Future<void> _saveNewsToLocal(List<dynamic> news) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_news', json.encode(news));
    } catch (e) {
      print('❌ Error saving news to local: $e');
    }
  }

  // 🟢 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        final parsed = DateTime.tryParse(dateValue);
        if (parsed != null && parsed.year > 2000) return parsed;
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
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

  void _setError(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      _safeNotifyListeners();
    }
  }

  // 🟢 МЕТОД ДЛЯ ШАРИНГА НОВОСТИ
  Future<void> shareNews(String postId) async {
    final actionKey = 'share_$postId';
    if (_pendingActions.contains(actionKey)) {
      print('⏳ Share action already in progress for $postId, skipping');
      return;
    }

    try {
      _pendingActions.add(actionKey);
      final completer = Completer<void>();
      _actionCompleters[actionKey] = completer;

      final int index = _findNewsIndexById(postId);
      if (index == -1) return;

      final Map<String, dynamic> post = _ensureSafeTypes(_news[index]);
      final int currentShareCount = _getSafeInt(post['share_count']);
      final Map<String, dynamic> originalPost = Map<String, dynamic>.from(post);

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ
      _news[index] = <String, dynamic>{
        ...post,
        'share_count': currentShareCount + 1,
      };

      _safeNotifyListeners();
      await _saveNewsToLocal(_news);

      _showSnackBar('Поделились новостью!', Colors.blue);

      // 🎯 СИНХРОНИЗАЦИЯ С YDB
      if (_serverAvailable) {
        try {
          // Используем существующий метод action для шаринга
          await ApiService.action({
            'action': 'share',
            'newsId': postId,
          });
          print('✅ Share sync with YDB successful');
        } catch (e) {
          print('❌ Share sync error: $e');

          // ОТКАТ ПРИ ОШИБКЕ
          _news[index] = originalPost;
          _safeNotifyListeners();
          await _saveNewsToLocal(_news);

          _showSnackBar('Действие сохранено локально', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ Share news error: $e');
    } finally {
      _pendingActions.remove(actionKey);
      _actionCompleters.remove(actionKey)?.complete();
    }
  }

  void _safeNotifyListeners() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  void _validateAndFixPostTimes() {
    final now = DateTime.now();
    for (int i = 0; i < _news.length; i++) {
      final post = _ensureSafeTypes(_news[i]);
      final createdAt = DateTime.parse(_getSafeString(post['created_at']));
      if (createdAt.isAfter(now.add(Duration(hours: 1))) ||
          createdAt.isBefore(DateTime(2020))) {
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
    } catch (e) {
      print('❌ Error clearing news data: $e');
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