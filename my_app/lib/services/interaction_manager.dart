import 'package:flutter/foundation.dart';
import 'dart:collection';

// ВЫНОСИМ КЛАСС НА УРОВЕНЬ ФАЙЛА
class PostInteractionState {
  final String postId;
  bool isLiked;
  bool isBookmarked;
  bool isReposted;
  int likesCount;
  int repostsCount;
  List<Map<String, dynamic>> comments;
  DateTime lastUpdated;

  PostInteractionState({
    required this.postId,
    required this.isLiked,
    required this.isBookmarked,
    required this.isReposted,
    required this.likesCount,
    required this.repostsCount,
    required this.comments,
  }) : lastUpdated = DateTime.now();

  // Конвертация в Map для удобства
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'isReposted': isReposted,
      'likesCount': likesCount,
      'repostsCount': repostsCount,
      'comments': List<Map<String, dynamic>>.from(comments),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Создание из Map
  static PostInteractionState fromMap(Map<String, dynamic> map) {
    return PostInteractionState(
      postId: map['postId'] ?? '',
      isLiked: map['isLiked'] ?? false,
      isBookmarked: map['isBookmarked'] ?? false,
      isReposted: map['isReposted'] ?? false,
      likesCount: map['likesCount'] ?? 0,
      repostsCount: map['repostsCount'] ?? 0,
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
    );
  }
}

class InteractionManager with ChangeNotifier {
  static final InteractionManager _instance = InteractionManager._internal();
  factory InteractionManager() => _instance;
  InteractionManager._internal();

  // Хранилище состояний постов
  final Map<String, PostInteractionState> _postStates = {};

  // Кэш для быстрого доступа
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 10);

  bool _isDisposed = false;

  // КОЛБЭКИ ДЛЯ СВЯЗИ С NEWS PROVIDER
  Function(String, bool, int)? _onLikeCallback;
  Function(String, bool)? _onBookmarkCallback;
  Function(String, bool, int, String, String)? _onRepostCallback; // Добавлены параметры для репоста
  Function(String, Map<String, dynamic>)? _onCommentCallback;
  Function(String, String)? _onCommentRemovalCallback;

  // Установка колбэков
  void setCallbacks({
    Function(String, bool, int)? onLike,
    Function(String, bool)? onBookmark,
    Function(String, bool, int, String, String)? onRepost,
    Function(String, Map<String, dynamic>)? onComment,
    Function(String, String)? onCommentRemoval,
  }) {
    _onLikeCallback = onLike;
    _onBookmarkCallback = onBookmark;
    _onRepostCallback = onRepost;
    _onCommentCallback = onComment;
    _onCommentRemovalCallback = onCommentRemoval;
  }

  // Безопасное уведомление слушателей
  void _safeNotifyListeners() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Проверка доступности провайдера
  bool get isDisposed => _isDisposed;

  // Безопасное выполнение операций
  void _safeOperation(Function operation) {
    if (!_isDisposed) {
      operation();
    }
  }

  // Инициализация состояния поста
  void initializePostState({
    required String postId,
    bool isLiked = false,
    bool isBookmarked = false,
    bool isReposted = false,
    int likesCount = 0,
    int repostsCount = 0,
    List<Map<String, dynamic>> comments = const [],
  }) {
    if (!_postStates.containsKey(postId)) {
      _postStates[postId] = PostInteractionState(
        postId: postId,
        isLiked: isLiked,
        isBookmarked: isBookmarked,
        isReposted: isReposted,
        likesCount: likesCount,
        repostsCount: repostsCount,
        comments: List<Map<String, dynamic>>.from(comments),
      );
      _cacheTimestamps[postId] = DateTime.now();
    }
  }

  // Получение состояния поста
  PostInteractionState? getPostState(String postId) {
    // Проверяем актуальность кэша
    final timestamp = _cacheTimestamps[postId];
    if (timestamp != null && DateTime.now().difference(timestamp) > _cacheDuration) {
      // Кэш устарел, можно обновить данные
      _refreshPostState(postId);
    }

    return _postStates[postId];
  }

  // Обновление состояния поста (принудительное)
  Future<void> _refreshPostState(String postId) async {
    // Здесь можно добавить логику загрузки актуальных данных с сервера
    _cacheTimestamps[postId] = DateTime.now();
    notifyListeners();
  }

  // ЛАЙКИ
  Future<void> toggleLike(String postId) async {
    final state = _postStates[postId];
    if (state != null) {
      state.isLiked = !state.isLiked;
      state.likesCount += state.isLiked ? 1 : -1;
      state.lastUpdated = DateTime.now();

      _cacheTimestamps[postId] = DateTime.now();
      _safeNotifyListeners();

      // Вызываем колбэк для NewsProvider
      if (_onLikeCallback != null) {
        _onLikeCallback!(postId, state.isLiked, state.likesCount);
      }

      // Синхронизация с сервером
      await _syncLikeWithServer(postId, state.isLiked, state.likesCount);
    }
  }

  Future<void> _syncLikeWithServer(String postId, bool isLiked, int likesCount) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing like for post $postId: $isLiked ($likesCount likes)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing like: $e');
      }
    }
  }

  // ЗАКЛАДКИ
  Future<void> toggleBookmark(String postId) async {
    final state = _postStates[postId];
    if (state != null) {
      state.isBookmarked = !state.isBookmarked;
      state.lastUpdated = DateTime.now();

      _cacheTimestamps[postId] = DateTime.now();
      _safeNotifyListeners();

      // Вызываем колбэк для NewsProvider
      if (_onBookmarkCallback != null) {
        _onBookmarkCallback!(postId, state.isBookmarked);
      }

      await _syncBookmarkWithServer(postId, state.isBookmarked);
    }
  }

  Future<void> _syncBookmarkWithServer(String postId, bool isBookmarked) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing bookmark for post $postId: $isBookmarked');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing bookmark: $e');
      }
    }
  }

  // ИСПРАВЛЕННЫЙ МЕТОД ДЛЯ РЕПОСТОВ
  Future<void> toggleRepost(
      String postId, {
        String? currentUserId,
        String? currentUserName,
      }) async {
    final state = _postStates[postId];
    if (state != null) {
      final wasReposted = state.isReposted;

      // Обновляем состояние только если оно изменилось
      if (wasReposted != !state.isReposted) {
        state.isReposted = !state.isReposted;
        state.repostsCount += state.isReposted ? 1 : -1;
        state.lastUpdated = DateTime.now();

        _cacheTimestamps[postId] = DateTime.now();
        _safeNotifyListeners();

        // ВАЖНО: Вызываем колбэк только один раз
        if (_onRepostCallback != null) {
          print('🔄 InteractionManager: Calling repost callback for $postId');
          _onRepostCallback!(
              postId,
              state.isReposted,
              state.repostsCount,
              currentUserId ?? '',
              currentUserName ?? ''
          );
        }
      }
    }
  }
  // ДОБАВЛЕННЫЙ МЕТОД ДЛЯ СИНХРОНИЗАЦИИ РЕПОСТОВ
  Future<void> _syncRepostWithServer(String postId, bool isReposted, int repostsCount) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing repost for post $postId: $isReposted ($repostsCount reposts)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing repost: $e');
      }
    }
  }

  // Альтернативный метод для совместимости со старым кодом
  Future<void> toggleRepostSimple(String postId) async {
    await toggleRepost(postId);
  }

  // КОММЕНТАРИИ
  Future<void> addComment({
    required String postId,
    required String text,
    required String author,
    required String authorAvatar,
  }) async {
    final state = _postStates[postId];
    if (state != null) {
      final newComment = {
        'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
        'text': text,
        'author': author,
        'author_avatar': authorAvatar,
        'time': DateTime.now().toIso8601String(),
        'likes': 0,
        'isLiked': false,
      };

      state.comments.insert(0, newComment);
      state.lastUpdated = DateTime.now();

      _cacheTimestamps[postId] = DateTime.now();
      _safeNotifyListeners();

      // Вызываем колбэк для NewsProvider
      if (_onCommentCallback != null) {
        _onCommentCallback!(postId, newComment);
      }

      await _syncCommentWithServer(postId, newComment);
    }
  }

  Future<void> removeComment(String postId, String commentId) async {
    final state = _postStates[postId];
    if (state != null) {
      state.comments.removeWhere((comment) => comment['id'] == commentId);
      state.lastUpdated = DateTime.now();

      _cacheTimestamps[postId] = DateTime.now();
      _safeNotifyListeners();

      // Вызываем колбэк для NewsProvider
      if (_onCommentRemovalCallback != null) {
        _onCommentRemovalCallback!(postId, commentId);
      }

      await _syncCommentRemovalWithServer(postId, commentId);
    }
  }

  Future<void> toggleCommentLike(String postId, String commentId) async {
    final state = _postStates[postId];
    if (state != null) {
      final comment = state.comments.firstWhere(
            (c) => c['id'] == commentId,
        orElse: () => {},
      );

      if (comment.isNotEmpty) {
        final isLiked = comment['isLiked'] ?? false;
        final likes = comment['likes'] ?? 0;

        comment['isLiked'] = !isLiked;
        comment['likes'] = likes + (isLiked ? -1 : 1);
        state.lastUpdated = DateTime.now();

        _cacheTimestamps[postId] = DateTime.now();
        _safeNotifyListeners();

        await _syncCommentLikeWithServer(postId, commentId, !isLiked);
      }
    }
  }

  Future<void> _syncCommentWithServer(String postId, Map<String, dynamic> comment) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing comment for post $postId: ${comment['text']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing comment: $e');
      }
    }
  }

  Future<void> _syncCommentRemovalWithServer(String postId, String commentId) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing comment removal for post $postId: $commentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing comment removal: $e');
      }
    }
  }

  Future<void> _syncCommentLikeWithServer(String postId, String commentId, bool isLiked) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing comment like for post $postId, comment $commentId: $isLiked');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing comment like: $e');
      }
    }
  }

  // МАССОВОЕ ОБНОВЛЕНИЕ (для инициализации из провайдеров)
  void bulkUpdatePostStates(List<Map<String, dynamic>> posts) {
    for (final post in posts) {
      final postId = post['id']?.toString() ?? '';
      if (postId.isNotEmpty) {
        initializePostState(
          postId: postId,
          isLiked: post['isLiked'] ?? false,
          isBookmarked: post['isBookmarked'] ?? false,
          isReposted: post['isReposted'] ?? false,
          likesCount: post['likes'] ?? 0,
          repostsCount: post['reposts'] ?? 0,
          comments: List<Map<String, dynamic>>.from(post['comments'] ?? []),
        );
      }
    }
    _safeNotifyListeners();
  }

  // ОБНОВЛЕНИЕ ОДНОГО ПОСТА
  void updatePostState(Map<String, dynamic> post) {
    final postId = post['id']?.toString() ?? '';
    if (postId.isNotEmpty) {
      initializePostState(
        postId: postId,
        isLiked: post['isLiked'] ?? false,
        isBookmarked: post['isBookmarked'] ?? false,
        isReposted: post['isReposted'] ?? false,
        likesCount: post['likes'] ?? 0,
        repostsCount: post['reposts'] ?? 0,
        comments: List<Map<String, dynamic>>.from(post['comments'] ?? []),
      );
      _safeNotifyListeners();
    }
  }

  // ОБНОВЛЕНИЕ СОСТОЯНИЯ РЕПОСТА (для синхронизации с NewsProvider)
  void updateRepostState(String postId, bool isReposted, int repostsCount) {
    final state = _postStates[postId];
    if (state != null) {
      state.isReposted = isReposted;
      state.repostsCount = repostsCount;
      state.lastUpdated = DateTime.now();

      _cacheTimestamps[postId] = DateTime.now();
      _safeNotifyListeners();
    }
  }

  // СТАТИСТИКА
  Map<String, dynamic> getStats() {
    final totalPosts = _postStates.length;
    final totalLikes = _postStates.values.fold<int>(0, (sum, state) => sum + state.likesCount);
    final totalComments = _postStates.values.fold<int>(0, (sum, state) => sum + state.comments.length);
    final totalReposts = _postStates.values.fold<int>(0, (sum, state) => sum + state.repostsCount);
    final likedPosts = _postStates.values.where((state) => state.isLiked).length;
    final bookmarkedPosts = _postStates.values.where((state) => state.isBookmarked).length;
    final repostedPosts = _postStates.values.where((state) => state.isReposted).length;

    return {
      'totalPosts': totalPosts,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'totalReposts': totalReposts,
      'likedPosts': likedPosts,
      'bookmarkedPosts': bookmarkedPosts,
      'repostedPosts': repostedPosts,
    };
  }

  // ПОЛУЧЕНИЕ РЕПОСТНУТЫХ ПОСТОВ
  List<String> getRepostedPostIds() {
    return _postStates.entries
        .where((entry) => entry.value.isReposted)
        .map((entry) => entry.key)
        .toList();
  }

  // ОЧИСТКА КЭША
  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredPosts = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheDuration)
        .map((entry) => entry.key)
        .toList();

    for (final postId in expiredPosts) {
      _cacheTimestamps.remove(postId);
    }

    if (expiredPosts.isNotEmpty && kDebugMode) {
      print('🧹 Cleared ${expiredPosts.length} expired cache entries');
    }
  }

  // ПОЛНАЯ ОЧИСТКА (для тестирования)
  void clearAll() {
    _postStates.clear();
    _cacheTimestamps.clear();
    _safeNotifyListeners();
  }

  // ПОДПИСКА НА ИЗМЕНЕНИЯ КОНКРЕТНОГО ПОСТА
  VoidCallback? addPostListener(String postId, VoidCallback listener) {
    addListener(listener);
    return () => removeListener(listener);
  }

  void removePostListener(VoidCallback listener) {
    removeListener(listener);
  }

  // ПРОВЕРКА СУЩЕСТВОВАНИЯ СОСТОЯНИЯ
  bool hasPostState(String postId) {
    return _postStates.containsKey(postId);
  }

  // ПОЛУЧЕНИЕ ВСЕХ СОСТОЯНИЙ (для отладки)
  Map<String, PostInteractionState> getAllStates() {
    return Map.from(_postStates);
  }

  // ДОБАВЛЕННЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С РЕПОСТАМИ

  // Проверка, является ли пост репостнутым
  bool isPostReposted(String postId) {
    return _postStates[postId]?.isReposted ?? false;
  }

  // Получение количества репостов
  int getRepostCount(String postId) {
    return _postStates[postId]?.repostsCount ?? 0;
  }

  // Принудительное обновление состояния репоста
  void forceUpdateRepost(String postId, bool isReposted, int repostsCount) {
    final state = _postStates[postId];
    if (state != null) {
      state.isReposted = isReposted;
      state.repostsCount = repostsCount;
      state.lastUpdated = DateTime.now();
      _safeNotifyListeners();
    } else {
      initializePostState(
        postId: postId,
        isReposted: isReposted,
        repostsCount: repostsCount,
      );
    }
  }

  // Синхронизация с внешним состоянием (при загрузке данных)
  void syncWithExternalState(Map<String, dynamic> externalState) {
    final postId = externalState['id']?.toString() ?? '';
    if (postId.isNotEmpty) {
      initializePostState(
        postId: postId,
        isLiked: externalState['isLiked'] ?? false,
        isBookmarked: externalState['isBookmarked'] ?? false,
        isReposted: externalState['isReposted'] ?? false,
        likesCount: externalState['likes'] ?? 0,
        repostsCount: externalState['reposts'] ?? 0,
        comments: List<Map<String, dynamic>>.from(externalState['comments'] ?? []),
      );
    }
  }
}