// lib/providers/news_providers/news_provider.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'user_profile_manager.dart';
import 'interaction_coordinator.dart';
import 'repost_manager.dart';
import 'news_data_processor.dart';
import 'news_storage_handler.dart';
import '../../services/storage_service.dart';
import '../../services/interaction_manager.dart' as interaction_service;
import '../../services/api_service.dart';

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDisposed = false;

  // Менеджеры
  final UserProfileManager _profileManager;
  final InteractionCoordinator _interactionCoordinator;
  final RepostManager _repostManager;
  final NewsDataProcessor _dataProcessor;
  final NewsStorageHandler _storageHandler;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDisposed => _isDisposed;
  bool get mounted => !_isDisposed;

  // Делегированные геттеры
  String? get profileImageUrl => _profileManager.profileImageUrl;
  File? get profileImageFile => _profileManager.profileImageFile;
  String? get coverImageUrl => _profileManager.coverImageUrl;
  File? get coverImageFile => _profileManager.coverImageFile;
  String? get currentUserId => _profileManager.currentUserId;

  // 🎯 ГЕТТЕР ДЛЯ INTERACTION MANAGER
  interaction_service.InteractionManager get interactionManager => _interactionCoordinator.interactionManager;

  NewsProvider({
    required UserProfileManager profileManager,
    required InteractionCoordinator interactionCoordinator,
    required RepostManager repostManager,
    required NewsDataProcessor dataProcessor,
    required NewsStorageHandler storageHandler,
  }) : _profileManager = profileManager,
        _interactionCoordinator = interactionCoordinator,
        _repostManager = repostManager,
        _dataProcessor = dataProcessor,
        _storageHandler = storageHandler {
    _initialize();
  }

  void _initialize() {
    _setupManagers();
    print('✅ NewsProvider initialized with all managers');
  }

  void _setupManagers() {
    _interactionCoordinator.setCallbacks(
      onLike: _handleLike,
      onBookmark: _handleBookmark,
      onRepost: _handleRepost,
      onComment: _handleComment,
      onCommentRemoval: _handleCommentRemoval,
    );

    _repostManager.initialize(
      onRepostStateChanged: _safeNotifyListeners,
      onRepostUpdated: _handleRepostUpdate,
    );

    _profileManager.setOnProfileUpdated(_safeNotifyListeners);
  }

  // 🎯 ОБРАБОТЧИКИ СОБЫТИЙ
  void _handleLike(String postId, bool isLiked, int likesCount) {
    if (_isDisposed) return;

    _safeOperation(() async {
      try {
        await ApiService.toggleLikeNews(postId, isLiked);
        print('✅ Like updated on server: $postId - $isLiked');
      } catch (e) {
        print('❌ Error updating like on server: $e');
        _interactionCoordinator.syncPostState(postId);
      }
    });
  }

  void _handleBookmark(String postId, bool isBookmarked) {
    if (_isDisposed) return;

    _safeOperation(() async {
      try {
        await ApiService.toggleBookmarkNews(postId, isBookmarked);
        print('✅ Bookmark updated on server: $postId - $isBookmarked');
      } catch (e) {
        print('❌ Error updating bookmark on server: $e');
        _interactionCoordinator.syncPostState(postId);
      }
    });
  }

  void _handleRepost(String postId, bool isReposted, int repostsCount, String userId, String userName) {
    if (_isDisposed) return;

    _safeOperation(() async {
      try {
        await ApiService.toggleRepostNews(postId, isReposted);
        print('✅ Repost updated on server: $postId - $isReposted');
      } catch (e) {
        print('❌ Error updating repost on server: $e');
        _interactionCoordinator.syncPostState(postId);
      }
    });

    if (isReposted) {
      final index = _dataProcessor.findNewsIndexById(_news, postId);
      if (index != -1) {
        _repostManager.createRepost(
          newsProvider: this,
          originalIndex: index,
          currentUserId: userId,
          currentUserName: userName,
        );
      }
    } else {
      final repostId = _repostManager.getRepostIdForOriginal(this, postId, userId);
      if (repostId != null) {
        _repostManager.cancelRepost(
          newsProvider: this,
          repostId: repostId,
          currentUserId: userId,
        );
      }
    }
  }

  void _handleComment(String postId, Map<String, dynamic> comment) {
    if (_isDisposed) return;

    _safeOperation(() async {
      try {
        await ApiService.addComment(postId, comment);
        print('✅ Comment added on server: $postId');
      } catch (e) {
        print('❌ Error adding comment on server: $e');
      }
    });

    _interactionCoordinator.syncPostState(postId);
    addCommentToNews(postId, comment);
  }

  void _handleCommentRemoval(String postId, String commentId) {
    if (_isDisposed) return;

    _safeOperation(() async {
      try {
        await ApiService.deleteComment(postId, commentId);
        print('✅ Comment deleted on server: $postId - $commentId');
      } catch (e) {
        print('❌ Error deleting comment on server: $e');
      }
    });

    _interactionCoordinator.syncPostState(postId);
    final index = _dataProcessor.findNewsIndexById(_news, postId);
    if (index != -1) {
      removeCommentFromNews(index, commentId);
    }
  }

  void _handleRepostUpdate(String postId, bool isReposted, int repostsCount) {
    final index = _dataProcessor.findNewsIndexById(_news, postId);
    if (index != -1) {
      updateNewsRepostStatus(index, isReposted, repostsCount);
    }
  }

  // 🎯 ОСНОВНЫЕ МЕТОДЫ РАБОТЫ С НОВОСТЯМИ
  Future<void> loadNews() async {
    if (_isDisposed) return;

    _setLoading(true);
    _setError(null);

    try {
      print('🔄 Loading news from server...');

      final serverNews = await ApiService.getNews();

      if (serverNews.isNotEmpty) {
        await _processServerNews(serverNews);
      } else {
        await _loadLocalNewsAsFallback();
      }
    } catch (e) {
      print('❌ Error loading news from server: $e');
      _setError('Ошибка загрузки данных с сервера');
      await _loadLocalNewsAsFallback();
    } finally {
      _setLoading(false);
      await _performFinalSyncAndCleanup();
    }
  }

  Future<void> _processServerNews(List<dynamic> serverNews) async {
    final processedNews = await _dataProcessor.processNewsData(
      news: serverNews,
      profileManager: _profileManager,
    );

    _safeOperation(() {
      _news = processedNews;
      _safeNotifyListeners();
    });

    await _storageHandler.saveNews(_news);
    _interactionCoordinator.initializeInteractions(processedNews);

    print('✅ Processed ${processedNews.length} news items from server');
  }

  Future<void> _loadLocalNewsAsFallback() async {
    try {
      print('🔄 Loading local news as fallback...');
      final cachedNews = await _storageHandler.loadNews();

      if (cachedNews.isNotEmpty) {
        await _processCachedNews(cachedNews);
        _setError('Используются локальные данные (проблемы с сетью)');
      } else {
        _safeOperation(() {
          _news = [];
          _safeNotifyListeners();
        });
        print('ℹ️ No cached news found, initializing with empty list');
      }
    } catch (e) {
      print('❌ Error loading local news: $e');
      _safeOperation(() {
        _news = [];
        _safeNotifyListeners();
      });
    }
  }

  Future<void> _processCachedNews(List<dynamic> cachedNews) async {
    final processedNews = await _dataProcessor.processNewsData(
      news: cachedNews,
      profileManager: _profileManager,
    );

    _safeOperation(() {
      _news = processedNews;
      _safeNotifyListeners();
    });

    _interactionCoordinator.initializeInteractions(processedNews);
    print('✅ Processed ${processedNews.length} cached news items');
  }

  Future<void> _performFinalSyncAndCleanup() async {
    _interactionCoordinator.syncAllPosts(_news);
    await _cleanupRepostCommentDuplicates();
    _dataProcessor.fixRepostCommentsDuplication(_news);
    print('✅ Final sync and cleanup completed');
  }

  Future<void> _cleanupRepostCommentDuplicates() async {
    try {
      int cleanedCount = 0;

      for (int i = 0; i < _news.length; i++) {
        final newsItem = Map<String, dynamic>.from(_news[i]);
        final isRepost = newsItem['is_repost'] == true;
        final repostComment = newsItem['repost_comment']?.toString() ?? '';
        final comments = List<dynamic>.from(newsItem['comments'] ?? []);

        if (isRepost && repostComment.isNotEmpty && comments.isNotEmpty) {
          print('❌ [CLEANUP] Found duplication in repost: ${newsItem['id']}');

          final cleanItem = {
            ...newsItem,
            'comments': [],
          };

          _news[i] = cleanItem;
          cleanedCount++;

          final postId = newsItem['id'].toString();
          _interactionCoordinator.updateComments(postId, []);
        }
      }

      if (cleanedCount > 0) {
        await _storageHandler.saveNews(_news);
        _safeNotifyListeners();
        print('🎉 [CLEANUP] Cleaned $cleanedCount reposts with comment duplication');
      }
    } catch (e) {
      print('❌ [CLEANUP] Error cleaning repost duplicates: $e');
    }
  }

  // 🎯 СОЗДАНИЕ НОВОСТИ
  Future<void> addNews(Map<String, dynamic> newsItem, {BuildContext? context}) async {
    if (_isDisposed) return;

    try {
      final processedItem = await _dataProcessor.prepareNewsItem(
        newsItem: newsItem,
        profileManager: _profileManager,
      );

      print('🔄 Sending news to server...');
      final serverNews = await ApiService.createNews(processedItem);

      _safeOperation(() {
        _news.insert(0, serverNews);
        _safeNotifyListeners();
      });

      await _storageHandler.saveNews(_news);
      _interactionCoordinator.initializePostState(serverNews);

      _showSuccessMessage(context, serverNews);
      print('✅ News created on server: ${serverNews['id']}');

    } catch (e) {
      print('❌ Error creating news on server: $e');
      _createNewsLocally(newsItem, context, e);
    }
  }

  void _createNewsLocally(Map<String, dynamic> newsItem, BuildContext? context, dynamic error) {
    try {
      final localNewsItem = {
        ...newsItem,
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'created_at': DateTime.now().toIso8601String(),
      };

      _safeOperation(() {
        _news.insert(0, localNewsItem);
        _safeNotifyListeners();
      });

      _storageHandler.saveNews(_news);
      _interactionCoordinator.initializePostState(localNewsItem);

      _showSuccessMessage(context, localNewsItem);
      print('✅ News created locally: ${localNewsItem['id']}');

    } catch (localError) {
      print('❌ Error creating local news: $localError');
      _showErrorMessage(context, error);
    }
  }

  void setCurrentUser(String userId, String userName, String userEmail) {
    _profileManager.setCurrentUser(userId, userName, userEmail);
    print('✅ NewsProvider: Current user set - $userName ($userId)');
  }

  // 🎯 МЕТОДЫ ПРОФИЛЯ
  Future<void> updateProfileImageUrl(String? url) async {
    try {
      await _profileManager.updateProfileImageUrl(url);
    } catch (e) {
      print('❌ Error updating profile image: $e');
    }
  }

  Future<void> updateProfileImageFile(File? file) async {
    try {
      await _profileManager.updateProfileImageFile(file);
    } catch (e) {
      print('❌ Error updating profile image file: $e');
    }
  }

  Future<void> updateCoverImageUrl(String? url) async {
    try {
      await _profileManager.updateCoverImageUrl(url);
    } catch (e) {
      print('❌ Error updating cover image: $e');
    }
  }

  Future<void> updateCoverImageFile(File? file) async {
    try {
      await _profileManager.updateCoverImageFile(file);
    } catch (e) {
      print('❌ Error updating cover image file: $e');
    }
  }

  void toggleRepost(int index, String currentUserId, String currentUserName) {
    _repostManager.toggleRepost(
      newsProvider: this,
      originalIndex: index,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
  }

  // 🎯 МЕТОДЫ СИНХРОНИЗАЦИИ
  void syncPostStateFromInteractionManager(String postId) {
    _interactionCoordinator.syncPostState(postId);
  }

  void syncAllPostsFromInteractionManager() {
    _interactionCoordinator.syncAllPosts(_news);
  }

  void forceSyncPost(String postId) {
    _safeOperation(() {
      try {
        _interactionCoordinator.syncPostState(postId);
        print('✅ Force synced post: $postId');
      } catch (e) {
        print('❌ Error force syncing post: $e');
      }
    });
  }

  void forceSyncAllPosts() {
    _safeOperation(() {
      try {
        _interactionCoordinator.syncAllPosts(_news);
        print('✅ Force synced all posts');
      } catch (e) {
        print('❌ Error force syncing all posts: $e');
      }
    });
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  void _setLoading(bool loading) {
    _safeOperation(() {
      _isLoading = loading;
      _safeNotifyListeners();
    });
  }

  void _setError(String? message) {
    _safeOperation(() {
      _errorMessage = message;
      _safeNotifyListeners();
    });
  }

  void _safeNotifyListeners() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();
    }
  }

  void _safeOperation(Function() operation) {
    if (_isDisposed) {
      print('⚠️ NewsProvider is disposed, skipping operation');
      return;
    }
    operation();
  }

  void _showSuccessMessage(BuildContext? context, Map<String, dynamic> newsItem) {
    if (context != null && mounted) {
      final isRepost = newsItem['is_repost'] == true;
      final repostComment = newsItem['repost_comment']?.toString() ?? '';
      final message = isRepost
          ? (repostComment.isNotEmpty ? 'Репост с комментарием создан!' : 'Репост создан!')
          : 'Пост создан!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorMessage(BuildContext? context, dynamic error) {
    if (context != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при создании поста: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🎯 МЕТОДЫ УПРАВЛЕНИЯ СОСТОЯНИЕМ
  void setLoading(bool loading) {
    _setLoading(loading);
  }

  void setError(String? message) {
    _setError(message);
  }

  void clearData() {
    _safeOperation(() {
      _news = [];
      _isLoading = false;
      _errorMessage = null;
      _safeNotifyListeners();
    });
    _storageHandler.removeAllData();
  }

  Future<void> ensureDataPersistence() async {
    if (_isDisposed) return;

    try {
      await _profileManager.loadProfileData();

      final hasConnection = await ApiService.checkConnection();

      if (hasConnection) {
        await loadNews();
      } else {
        await _loadLocalNewsAsFallback();
      }

      print('✅ Data persistence ensured (online: $hasConnection)');
    } catch (e) {
      print('❌ Error ensuring data persistence: $e');
      _safeOperation(() {
        _news = [];
        _safeNotifyListeners();
      });
    }
  }

  // 🎯 МЕТОДЫ РАБОТЫ С КОММЕНТАРИЯМИ
  void addCommentToNews(String newsId, Map<String, dynamic> comment) {
    _safeOperation(() {
      final index = _dataProcessor.findNewsIndexById(_news, newsId);
      if (index != -1) {
        final newsItem = _news[index];

        if (newsItem['comments'] == null) {
          newsItem['comments'] = [];
        }

        final completeComment = {
          ...comment,
          'time': comment['time'] ?? DateTime.now().toIso8601String(),
        };

        (newsItem['comments'] as List).insert(0, completeComment);
        _safeNotifyListeners();
        _storageHandler.saveNews(_news);

        print('✅ Комментарий добавлен к новости $newsId');
      }
    });
  }

  void removeCommentFromNews(int index, String commentId) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index];

        if (newsItem['comments'] != null) {
          final commentsList = newsItem['comments'] as List;
          final initialLength = commentsList.length;

          commentsList.removeWhere((comment) => comment['id'] == commentId);

          if (commentsList.length < initialLength) {
            _safeNotifyListeners();
            _storageHandler.saveNews(_news);
            print('✅ Комментарий $commentId удален');
          }
        }
      }
    });
  }

  // 🎯 МЕТОДЫ ОБНОВЛЕНИЯ СТАТУСОВ
  void updateNewsRepostStatus(int index, bool isReposted, int repostsCount) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        _news[index]['isReposted'] = isReposted;
        _news[index]['reposts'] = repostsCount;
        _safeNotifyListeners();
        _storageHandler.saveNews(_news);
      }
    });
  }

  void updateNewsLikeStatus(int index, bool isLiked, int likesCount) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index];
        final newsId = newsItem['id'].toString();

        _news[index] = {
          ...newsItem,
          'isLiked': isLiked,
          'likes': likesCount,
        };

        _safeNotifyListeners();
        _storageHandler.saveNews(_news);

        if (isLiked) {
          StorageService.addLike(newsId);
        } else {
          StorageService.removeLike(newsId);
        }
      }
    });
  }

  void updateNewsBookmarkStatus(int index, bool isBookmarked) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index];
        final newsId = newsItem['id'].toString();

        _news[index] = {
          ...newsItem,
          'isBookmarked': isBookmarked,
        };

        _safeNotifyListeners();
        _storageHandler.saveNews(_news);

        if (isBookmarked) {
          StorageService.addBookmark(newsId);
        } else {
          StorageService.removeBookmark(newsId);
        }
      }
    });
  }

  void updateNewsFollowStatus(int index, bool isFollowing) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index];
        final newsId = newsItem['id'].toString();

        _news[index] = {
          ...newsItem,
          'isFollowing': isFollowing,
        };

        _safeNotifyListeners();
        _storageHandler.saveNews(_news);

        if (isFollowing) {
          if (_profileManager.currentUserId != null) {
            StorageService.addFollow(_profileManager.currentUserId!, newsId);
          }
        } else {
          if (_profileManager.currentUserId != null) {
            StorageService.removeFollow(_profileManager.currentUserId!, newsId);
          }
        }
      }
    });
  }

  // 🎯 МЕТОДЫ ОБНОВЛЕНИЯ НОВОСТЕЙ
  void updateNews(int index, Map<String, dynamic> updatedNews) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final originalNews = _news[index];
        final preservedFields = {
          'id': originalNews['id'],
          'author_name': originalNews['author_name'],
          'created_at': originalNews['created_at'],
          'likes': originalNews['likes'],
          'comments': originalNews['comments'],
          'isLiked': originalNews['isLiked'],
          'isBookmarked': originalNews['isBookmarked'],
          'isFollowing': originalNews['isFollowing'],
          'tag_color': originalNews['tag_color'],
        };

        _news[index] = {
          ...preservedFields,
          ...updatedNews,
          'hashtags': _dataProcessor.parseHashtags(updatedNews['hashtags'] ?? originalNews['hashtags']),
          'user_tags': updatedNews['user_tags'] ?? originalNews['user_tags'],
        };

        _safeNotifyListeners();
        _storageHandler.saveNews(_news);
      }
    });
  }

  void updateNewsUserTag(int index, String tagId, String newTagName, {Color? color}) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index];
        final newsId = newsItem['id'].toString();

        final updatedUserTags = {
          ..._ensureStringStringMap(newsItem['user_tags'] ?? {}),
          tagId: newTagName,
        };

        final tagColor = color ?? Color(newsItem['tag_color'] ?? _dataProcessor.generateColorFromId(newsId).value);

        final updatedNews = {
          ...newsItem,
          'user_tags': updatedUserTags,
          'tag_color': tagColor.value,
        };

        _news[index] = updatedNews;
        _safeNotifyListeners();

        StorageService.updateUserTag(newsId, tagId, newTagName, color: tagColor.value);
        _storageHandler.saveNews(_news);
      }
    });
  }

  void removeNews(int index) {
    if (_isDisposed) return;

    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index];
        final newsId = newsItem['id'].toString();

        _storageHandler.removeNewsData(newsId);
        _news.removeAt(index);
        _safeNotifyListeners();
        _storageHandler.saveNews(_news);
      }
    });
  }

  // 🎯 МЕТОДЫ ПОИСКА
  int findNewsIndexById(String newsId) {
    return _dataProcessor.findNewsIndexById(_news, newsId);
  }

  bool containsNews(String newsId) {
    return _dataProcessor.containsNews(_news, newsId);
  }

  // 🎯 МЕТОДЫ ПРОФИЛЯ
  Future<void> loadProfileData() async {
    await _profileManager.loadProfileData();
  }

  dynamic getCurrentProfileImage() {
    return _profileManager.getCurrentProfileImage();
  }

  dynamic getCurrentCoverImage() {
    return _profileManager.getCurrentCoverImage();
  }

  Future<void> removeCoverImage() async {
    await _profileManager.removeCoverImage();
  }

  // 🎯 МЕТОДЫ ТЕГОВ
  Future<void> loadUserTags() async {
    if (_isDisposed) return;

    try {
      final userData = await _storageHandler.loadUserData();
      final userTags = userData['userTags'];

      _safeOperation(() {
        for (var i = 0; i < _news.length; i++) {
          final newsItem = _news[i];
          final newsId = newsItem['id'].toString();

          if (userTags.containsKey(newsId)) {
            final newsTags = userTags[newsId]!;
            Map<String, String> updatedUserTags = {'tag1': 'Новый тег'};

            if (newsTags['tags'] is Map) {
              final tagsMap = newsTags['tags'] as Map;
              updatedUserTags = tagsMap.map((key, value) =>
                  MapEntry(key.toString(), value.toString())
              );
            }

            _dataProcessor.updateNewsTags(_news, i, updatedUserTags);
          }
        }
        _safeNotifyListeners();
      });
    } catch (e) {
      print('❌ Error loading user tags: $e');
    }
  }

  void refreshAllPostsUserTags() {
    _safeOperation(() {
      _safeNotifyListeners();
    });
    print('✅ All posts refreshed for new tags display');
  }

  // 🎯 МЕТОДЫ ДЛЯ ПОЛЬЗОВАТЕЛЕЙ
  String getUserAvatarUrl(String userId, String userName) {
    return _profileManager.getUserAvatarUrl(userId, userName);
  }

  UserProfile? getUserProfile(String userId) {
    return _profileManager.getUserProfile(userId);
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЙ МЕТОД
  Map<String, String> _ensureStringStringMap(dynamic map) {
    if (map is Map<String, String>) {
      return map;
    }
    if (map is Map) {
      return map.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {'tag1': 'Новый тег'};
  }

  // 🎯 ДЕЛЕГИРОВАННЫЕ МЕТОДЫ ДЛЯ ДОСТУПА К МЕНЕДЖЕРАМ
  UserProfileManager get profileManager => _profileManager;
  InteractionCoordinator get interactionCoordinator => _interactionCoordinator;
  RepostManager get repostManager => _repostManager;
  NewsDataProcessor get dataProcessor => _dataProcessor;

  @override
  void dispose() {
    _isDisposed = true;

    _interactionCoordinator.setCallbacks(
      onLike: null,
      onBookmark: null,
      onRepost: null,
      onComment: null,
      onCommentRemoval: null,
    );

    _repostManager.dispose();
    _profileManager.setOnProfileUpdated(null);

    _news.clear();
    super.dispose();

    print('✅ NewsProvider disposed');
  }
}