import 'package:flutter/foundation.dart';
import 'dart:collection';

// КЛАСС СОСТОЯНИЯ ВЗАИМОДЕЙСТВИЙ ПОСТА
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

  // Копирование с обновлением
  PostInteractionState copyWith({
    bool? isLiked,
    bool? isBookmarked,
    bool? isReposted,
    int? likesCount,
    int? repostsCount,
    List<Map<String, dynamic>>? comments,
  }) {
    return PostInteractionState(
      postId: postId,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isReposted: isReposted ?? this.isReposted,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      comments: comments ?? this.comments,
    );
  }

  // Конвертация в Map
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

  @override
  String toString() {
    return 'PostInteractionState{postId: $postId, isLiked: $isLiked, isBookmarked: $isBookmarked, isReposted: $isReposted, likesCount: $likesCount, repostsCount: $repostsCount, comments: ${comments.length}}';
  }
}

// МЕНЕДЖЕР ВЗАИМОДЕЙСТВИЙ
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

  // КОЛБЭКИ ДЛЯ СВЯЗИ С ВНЕШНИМИ СИСТЕМАМИ
  Function(String, bool, int)? _onLikeCallback;
  Function(String, bool)? _onBookmarkCallback;
  Function(String, bool, int, String, String)? _onRepostCallback;
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

    print('✅ InteractionManager callbacks set');
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
    _postStates.clear();
    _cacheTimestamps.clear();
    super.dispose();
    print('🔴 InteractionManager disposed');
  }

  // Проверка доступности
  bool get isDisposed => _isDisposed;

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
    if (postId.isEmpty) {
      print('⚠️ Cannot initialize post state with empty postId');
      return;
    }

    final newState = PostInteractionState(
      postId: postId,
      isLiked: isLiked,
      isBookmarked: isBookmarked,
      isReposted: isReposted,
      likesCount: likesCount,
      repostsCount: repostsCount,
      comments: List<Map<String, dynamic>>.from(comments),
    );

    _postStates[postId] = newState;
    _cacheTimestamps[postId] = DateTime.now();

    print('✅ Initialized post state for $postId: ${newState.toString()}');
  }

  // Получение состояния поста
  PostInteractionState? getPostState(String postId) {
    if (postId.isEmpty) return null;

    // Проверяем актуальность кэша
    final timestamp = _cacheTimestamps[postId];
    if (timestamp != null && DateTime.now().difference(timestamp) > _cacheDuration) {
      _refreshPostState(postId);
    }

    return _postStates[postId];
  }

  // Обновление состояния поста
  Future<void> _refreshPostState(String postId) async {
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();
  }

  // ЛАЙКИ
  Future<void> toggleLike(String postId) async {
    final state = _postStates[postId];
    if (state == null) {
      print('⚠️ Cannot toggle like: post $postId not found');
      return;
    }

    final newIsLiked = !state.isLiked;
    final newLikesCount = state.likesCount + (newIsLiked ? 1 : -1);

    // Обновляем состояние
    _postStates[postId] = state.copyWith(
      isLiked: newIsLiked,
      likesCount: newLikesCount,
    );

    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    // Вызываем колбэк
    if (_onLikeCallback != null) {
      _onLikeCallback!(postId, newIsLiked, newLikesCount);
    }

    // Синхронизация с сервером
    await _syncLikeWithServer(postId, newIsLiked, newLikesCount);

    print('❤️ Like toggled for $postId: $newIsLiked ($newLikesCount likes)');
  }

  Future<void> _syncLikeWithServer(String postId, bool isLiked, int likesCount) async {
    try {
      // Реальная синхронизация с API
      if (kDebugMode) {
        print('🔄 Syncing like for $postId: $isLiked');
      }
    } catch (e) {
      print('❌ Error syncing like: $e');
    }
  }

  // ЗАКЛАДКИ
  Future<void> toggleBookmark(String postId) async {
    final state = _postStates[postId];
    if (state == null) {
      print('⚠️ Cannot toggle bookmark: post $postId not found');
      return;
    }

    final newIsBookmarked = !state.isBookmarked;

    // Обновляем состояние
    _postStates[postId] = state.copyWith(isBookmarked: newIsBookmarked);
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    // Вызываем колбэк
    if (_onBookmarkCallback != null) {
      _onBookmarkCallback!(postId, newIsBookmarked);
    }

    await _syncBookmarkWithServer(postId, newIsBookmarked);

    print('🔖 Bookmark toggled for $postId: $newIsBookmarked');
  }

  Future<void> _syncBookmarkWithServer(String postId, bool isBookmarked) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing bookmark for $postId: $isBookmarked');
      }
    } catch (e) {
      print('❌ Error syncing bookmark: $e');
    }
  }

  // РЕПОСТЫ - УЛУЧШЕННАЯ РЕАЛИЗАЦИЯ
  Future<void> toggleRepost({
    required String postId,
    String? currentUserId,
    String? currentUserName,
  }) async {
    final state = _postStates[postId];
    if (state == null) {
      print('⚠️ Cannot toggle repost: post $postId not found');
      return;
    }

    final newIsReposted = !state.isReposted;
    final newRepostsCount = state.repostsCount + (newIsReposted ? 1 : -1);

    // Обновляем состояние
    _postStates[postId] = state.copyWith(
      isReposted: newIsReposted,
      repostsCount: newRepostsCount,
    );

    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    // ВАЖНО: Вызываем колбэк с правильными параметрами
    if (_onRepostCallback != null) {
      print('🔄 InteractionManager: Calling repost callback for $postId');
      _onRepostCallback!(
        postId,
        newIsReposted,
        newRepostsCount,
        currentUserId ?? '',
        currentUserName ?? 'Пользователь',
      );
    }

    await _syncRepostWithServer(postId, newIsReposted, newRepostsCount);

    print('🔄 Repost toggled for $postId: $newIsReposted ($newRepostsCount reposts)');
  }

  // Альтернативный метод для совместимости
  Future<void> toggleRepostSimple(String postId) async {
    await toggleRepost(postId: postId);
  }

  Future<void> _syncRepostWithServer(String postId, bool isReposted, int repostsCount) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing repost for $postId: $isReposted');
      }
    } catch (e) {
      print('❌ Error syncing repost: $e');
    }
  }

  // КОММЕНТАРИИ
  Future<void> addComment({
    required String postId,
    required String text,
    required String author,
    required String authorAvatar,
  }) async {
    final state = _postStates[postId];
    if (state == null) {
      print('⚠️ Cannot add comment: post $postId not found');
      return;
    }

    final newComment = {
      'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
      'text': text,
      'author': author,
      'author_avatar': authorAvatar,
      'time': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'likes': 0,
      'isLiked': false,
    };

    final updatedComments = List<Map<String, dynamic>>.from(state.comments)
      ..insert(0, newComment);

    _postStates[postId] = state.copyWith(comments: updatedComments);
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    // Вызываем колбэк
    if (_onCommentCallback != null) {
      _onCommentCallback!(postId, newComment);
    }

    await _syncCommentWithServer(postId, newComment);

    print('💬 Comment added to $postId by $author');
  }

  Future<void> removeComment(String postId, String commentId) async {
    final state = _postStates[postId];
    if (state == null) return;

    final updatedComments = state.comments.where((comment) => comment['id'] != commentId).toList();

    _postStates[postId] = state.copyWith(comments: updatedComments);
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    // Вызываем колбэк
    if (_onCommentRemovalCallback != null) {
      _onCommentRemovalCallback!(postId, commentId);
    }

    await _syncCommentRemovalWithServer(postId, commentId);

    print('🗑️ Comment $commentId removed from $postId');
  }

  Future<void> toggleCommentLike(String postId, String commentId) async {
    final state = _postStates[postId];
    if (state == null) return;

    final commentIndex = state.comments.indexWhere((comment) => comment['id'] == commentId);
    if (commentIndex == -1) return;

    final updatedComments = List<Map<String, dynamic>>.from(state.comments);
    final comment = Map<String, dynamic>.from(updatedComments[commentIndex]);

    final isLiked = comment['isLiked'] ?? false;
    final likes = comment['likes'] ?? 0;

    comment['isLiked'] = !isLiked;
    comment['likes'] = likes + (isLiked ? -1 : 1);
    updatedComments[commentIndex] = comment;

    _postStates[postId] = state.copyWith(comments: updatedComments);
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    await _syncCommentLikeWithServer(postId, commentId, !isLiked);
  }

  Future<void> _syncCommentWithServer(String postId, Map<String, dynamic> comment) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing comment for $postId');
      }
    } catch (e) {
      print('❌ Error syncing comment: $e');
    }
  }

  Future<void> _syncCommentRemovalWithServer(String postId, String commentId) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing comment removal for $postId: $commentId');
      }
    } catch (e) {
      print('❌ Error syncing comment removal: $e');
    }
  }

  Future<void> _syncCommentLikeWithServer(String postId, String commentId, bool isLiked) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing comment like for $postId: $isLiked');
      }
    } catch (e) {
      print('❌ Error syncing comment like: $e');
    }
  }

  // МАССОВОЕ ОБНОВЛЕНИЕ
  void bulkUpdatePostStates(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) return;

    int updatedCount = 0;
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
        updatedCount++;
      }
    }

    _safeNotifyListeners();
    print('✅ Bulk updated $updatedCount post states');
  }

  // ОБНОВЛЕНИЕ ОДНОГО ПОСТА
  void updatePostState(Map<String, dynamic> post) {
    final postId = post['id']?.toString() ?? '';
    if (postId.isEmpty) return;

    initializePostState(
      postId: postId,
      isLiked: post['isLiked'] ?? false,
      isBookmarked: post['isBookmarked'] ?? false,
      isReposted: post['isReposted'] ?? false,
      likesCount: post['likes'] ?? 0,
      repostsCount: post['reposts'] ?? 0,
      comments: List<Map<String, dynamic>>.from(post['comments'] ?? []),
    );

    print('✅ Updated post state for $postId');
  }

  // ОБНОВЛЕНИЕ СОСТОЯНИЯ РЕПОСТА
  void updateRepostState({
    required String postId,
    required bool isReposted,
    required int repostsCount,
  }) {
    final state = _postStates[postId];
    if (state == null) {
      initializePostState(
        postId: postId,
        isReposted: isReposted,
        repostsCount: repostsCount,
      );
    } else {
      _postStates[postId] = state.copyWith(
        isReposted: isReposted,
        repostsCount: repostsCount,
      );
    }

    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    print('🔄 Repost state updated for $postId: $isReposted ($repostsCount reposts)');
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
      'cacheSize': _cacheTimestamps.length,
    };
  }

  // МЕТОДЫ ДЛЯ РАБОТЫ С РЕПОСТАМИ
  bool isPostReposted(String postId) {
    return _postStates[postId]?.isReposted ?? false;
  }

  int getRepostCount(String postId) {
    return _postStates[postId]?.repostsCount ?? 0;
  }

  List<String> getRepostedPostIds() {
    return _postStates.entries
        .where((entry) => entry.value.isReposted)
        .map((entry) => entry.key)
        .toList();
  }

  // СИНХРОНИЗАЦИЯ С ВНЕШНИМ СОСТОЯНИЕМ
  void syncWithExternalState(Map<String, dynamic> externalState) {
    final postId = externalState['id']?.toString() ?? '';
    if (postId.isEmpty) return;

    initializePostState(
      postId: postId,
      isLiked: externalState['isLiked'] ?? false,
      isBookmarked: externalState['isBookmarked'] ?? false,
      isReposted: externalState['isReposted'] ?? false,
      likesCount: externalState['likes'] ?? 0,
      repostsCount: externalState['reposts'] ?? 0,
      comments: List<Map<String, dynamic>>.from(externalState['comments'] ?? []),
    );

    print('🔄 Synced external state for $postId');
  }

  // УПРАВЛЕНИЕ КЭШЕМ
  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredPosts = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheDuration)
        .map((entry) => entry.key)
        .toList();

    for (final postId in expiredPosts) {
      _cacheTimestamps.remove(postId);
    }

    if (expiredPosts.isNotEmpty) {
      print('🧹 Cleared ${expiredPosts.length} expired cache entries');
    }
  }

  void clearAll() {
    _postStates.clear();
    _cacheTimestamps.clear();
    _safeNotifyListeners();
    print('🧹 Cleared all InteractionManager data');
  }

  // ПОДПИСКА НА ИЗМЕНЕНИЯ
  VoidCallback? addPostListener(String postId, VoidCallback listener) {
    addListener(listener);
    return () => removeListener(listener);
  }

  void removePostListener(VoidCallback listener) {
    removeListener(listener);
  }

  // ПРОВЕРКИ И УТИЛИТЫ
  bool hasPostState(String postId) {
    return _postStates.containsKey(postId);
  }

  Map<String, PostInteractionState> getAllStates() {
    return Map.from(_postStates);
  }

  int get totalPosts => _postStates.length;

  List<String> getAllPostIds() {
    return _postStates.keys.toList();
  }

  // ОБНОВЛЕНИЕ КОММЕНТАРИЕВ
  void updateComments(String postId, List<Map<String, dynamic>> comments) {
    final state = _postStates[postId];
    if (state == null) return;

    _postStates[postId] = state.copyWith(comments: comments);
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();

    print('💬 Updated comments for $postId: ${comments.length} comments');
  }

  // ПОЛУЧЕНИЕ КОММЕНТАРИЕВ
  List<Map<String, dynamic>> getComments(String postId) {
    return _postStates[postId]?.comments ?? [];
  }

  // ПРОВЕРКА ПУСТОТЫ
  bool get isEmpty => _postStates.isEmpty;
}