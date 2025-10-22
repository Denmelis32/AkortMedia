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
    // Настройка колбэков для координатора взаимодействий
    _interactionCoordinator.setCallbacks(
      onLike: _handleLike,
      onBookmark: _handleBookmark,
      onRepost: _handleRepost,
      onComment: _handleComment,
      onCommentRemoval: _handleCommentRemoval,
    );

    // Настройка менеджера репостов
    _repostManager.initialize(
      onRepostStateChanged: _safeNotifyListeners,
      onRepostUpdated: _handleRepostUpdate,
    );

    // Настройка менеджера профилей
    _profileManager.setOnProfileUpdated(_safeNotifyListeners);
  }

  // Обработчики событий взаимодействий
  void _handleLike(String postId, bool isLiked, int likesCount) {
    if (_isDisposed) return;
    _interactionCoordinator.syncPostState(postId);
  }

  void _handleBookmark(String postId, bool isBookmarked) {
    if (_isDisposed) return;
    _interactionCoordinator.syncPostState(postId);
  }

  void _handleRepost(String postId, bool isReposted, int repostsCount, String userId, String userName) {
    if (_isDisposed) return;

    _interactionCoordinator.syncPostState(postId);

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
    _interactionCoordinator.syncPostState(postId);
    addCommentToNews(postId, comment);
  }

  void _handleCommentRemoval(String postId, String commentId) {
    if (_isDisposed) return;
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

  // Основные методы работы с новостями
  Future<void> loadNews() async {
    if (_isDisposed) return;

    _setLoading(true);

    try {
      final cachedNews = await _storageHandler.loadNews();

      if (cachedNews.isNotEmpty) {
        await _processCachedNews(cachedNews);
      } else {
        await _createInitialNews();
      }
    } catch (e) {
      print('❌ Error loading news: $e');
      _setError('Ошибка загрузки данных');
      await _createInitialNews();
    } finally {
      _setLoading(false);
      await _performFinalSyncAndCleanup();
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
    await _storageHandler.saveNews(_news);
  }

  Future<void> _createInitialNews() async {
    final mockNews = _dataProcessor.getMockNews();

    _safeOperation(() {
      _news = mockNews;
      _safeNotifyListeners();
    });

    _interactionCoordinator.initializeInteractions(mockNews);
    await _storageHandler.saveNews(_news);
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

  Future<void> addNews(Map<String, dynamic> newsItem, {BuildContext? context}) async {
    if (_isDisposed) return;

    try {
      final processedItem = await _dataProcessor.prepareNewsItem(
        newsItem: newsItem,
        profileManager: _profileManager,
      );

      _safeOperation(() {
        _news.insert(0, processedItem);
        _safeNotifyListeners();
      });

      await _storageHandler.saveNews(_news);
      _interactionCoordinator.initializePostState(processedItem);

      _showSuccessMessage(context, processedItem);
    } catch (e) {
      print('❌ Error adding news: $e');
      _showErrorMessage(context, e);
    }
  }

  void setCurrentUser(String userId, String userName, String userEmail) {
    _profileManager.setCurrentUser(userId, userName, userEmail);
    print('✅ NewsProvider: Current user set - $userName ($userId)');
  }

  Future<void> updateProfileImageUrl(String? url) async {
    await _profileManager.updateProfileImageUrl(url);
  }

  Future<void> updateProfileImageFile(File? file) async {
    await _profileManager.updateProfileImageFile(file);
  }

  Future<void> updateCoverImageUrl(String? url) async {
    await _profileManager.updateCoverImageUrl(url);
  }

  Future<void> updateCoverImageFile(File? file) async {
    await _profileManager.updateCoverImageFile(file);
  }

  void toggleRepost(int index, String currentUserId, String currentUserName) {
    _repostManager.toggleRepost(
      newsProvider: this,
      originalIndex: index,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
  }

  // Методы синхронизации
  void syncPostStateFromInteractionManager(String postId) {
    _interactionCoordinator.syncPostState(postId);
  }

  void syncAllPostsFromInteractionManager() {
    _interactionCoordinator.syncAllPosts(_news);
  }

  void forceSyncPost(String postId) {
    syncPostStateFromInteractionManager(postId);
  }

  void forceSyncAllPosts() {
    syncAllPostsFromInteractionManager();
  }

  // Вспомогательные методы
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

  // Методы управления состоянием
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

      final cachedNews = await _storageHandler.loadNews();
      if (cachedNews.isEmpty) {
        await _createInitialNews();
      } else {
        await _processCachedNews(cachedNews);
      }

      print('✅ Data persistence ensured');
    } catch (e) {
      print('❌ Error ensuring data persistence: $e');
      await _createInitialNews();
    }
  }

  // Методы поиска
  int findNewsIndexById(String newsId) {
    return _dataProcessor.findNewsIndexById(_news, newsId);
  }

  bool containsNews(String newsId) {
    return _dataProcessor.containsNews(_news, newsId);
  }

  // Методы профиля
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

  // Методы тегов
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

  // Методы обновления статусов
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

  // Методы обновления новостей
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

  Map<String, String> _ensureStringStringMap(dynamic map) {
    if (map is Map<String, String>) {
      return map;
    }
    if (map is Map) {
      return map.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {'tag1': 'Новый тег'};
  }

  // Остальные методы работы с новостями
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

  void removeNews(int index) async {
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

  // Геттеры для доступа к менеджерам
  UserProfileManager get profileManager => _profileManager;
  InteractionCoordinator get interactionCoordinator => _interactionCoordinator;
  RepostManager get repostManager => _repostManager;
  NewsDataProcessor get dataProcessor => _dataProcessor;
  interaction_service.InteractionManager get interactionManager => _interactionCoordinator.interactionManager;

  // Делегированные методы для UserProfileManager
  String getUserAvatarUrl(String userId, String userName) {
    return _profileManager.getUserAvatarUrl(userId, userName);
  }

  UserProfile? getUserProfile(String userId) {
    return _profileManager.getUserProfile(userId);
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Очищаем колбэки
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