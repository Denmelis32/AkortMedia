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

  // Глобальное уведомление об изменениях
  void _notifyGlobalListeners() {
    _safeNotifyListeners();
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

    print('✅ Initialized post state for $postId');
  }




  // Массовая инициализация состояний
  void updatePostState(String postId, PostInteractionState newState) {
    _postStates[postId] = newState;
    _cacheTimestamps[postId] = DateTime.now();

    // Принудительно синхронизируем всех слушателей
    forceSyncPost(postId);

    print('✅ Post state updated and synced: $postId');
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

    // Создаем новое состояние
    final newState = state.copyWith(
      isLiked: newIsLiked,
      likesCount: newLikesCount,
    );

    // Обновляем с принудительной синхронизацией
    updatePostState(postId, newState);

    // Вызываем колбэк
    if (_onLikeCallback != null) {
      _onLikeCallback!(postId, newIsLiked, newLikesCount);
    }

    print('❤️ Like toggled and synced for $postId: $newIsLiked ($newLikesCount likes)');
  }



  void bulkUpdatePostStates(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) return;

    int updatedCount = 0;
    for (final post in posts) {
      final postId = post['id']?.toString() ?? '';
      if (postId.isNotEmpty) {
        _postStates[postId] = PostInteractionState(
          postId: postId,
          isLiked: post['isLiked'] ?? false,
          isBookmarked: post['isBookmarked'] ?? false,
          isReposted: post['isReposted'] ?? false,
          likesCount: post['likes'] ?? 0,
          repostsCount: post['reposts'] ?? 0,
          comments: List<Map<String, dynamic>>.from(post['comments'] ?? []),
        );
        _cacheTimestamps[postId] = DateTime.now();
        updatedCount++;
      }
    }

    _safeNotifyListeners();
    print('✅ Bulk updated $updatedCount post states');
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
    _notifyGlobalListeners();

    // Вызываем колбэк
    if (_onBookmarkCallback != null) {
      _onBookmarkCallback!(postId, newIsBookmarked);
    }

    print('🔖 Bookmark toggled for $postId: $newIsBookmarked');
  }

  // РЕПОСТЫ
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
    _notifyGlobalListeners();

    // Вызываем колбэк
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

    print('🔄 Repost toggled for $postId: $newIsReposted ($newRepostsCount reposts)');
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
    _notifyGlobalListeners();

    // Вызываем колбэк
    if (_onCommentCallback != null) {
      _onCommentCallback!(postId, newComment);
    }

    print('💬 Comment added to $postId by $author');
  }

  Future<void> removeComment(String postId, String commentId) async {
    final state = _postStates[postId];
    if (state == null) return;

    final updatedComments = state.comments.where((comment) => comment['id'] != commentId).toList();

    _postStates[postId] = state.copyWith(comments: updatedComments);
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();
    _notifyGlobalListeners();

    // Вызываем колбэк
    if (_onCommentRemovalCallback != null) {
      _onCommentRemovalCallback!(postId, commentId);
    }

    print('🗑️ Comment $commentId removed from $postId');
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
    _notifyGlobalListeners();

    print('🔄 Repost state updated for $postId: $isReposted ($repostsCount reposts)');
  }

  // ОБНОВЛЕНИЕ КОММЕНТАРИЕВ
  void updateComments(String postId, List<Map<String, dynamic>> comments) {
    final state = _postStates[postId];
    if (state == null) return;

    _postStates[postId] = state.copyWith(comments: comments);
    _cacheTimestamps[postId] = DateTime.now();
    _safeNotifyListeners();
    _notifyGlobalListeners();

    print('💬 Updated comments for $postId: ${comments.length} comments');
  }

  // СИНХРОНИЗАЦИЯ С ВНЕШНИМ СОСТОЯНИЕМ
  void syncWithExternalState(Map<String, dynamic> externalState) {
    final postId = externalState['id']?.toString() ?? '';
    if (postId.isEmpty) return;

    final currentState = _postStates[postId];
    if (currentState != null) {
      _postStates[postId] = currentState.copyWith(
        isLiked: externalState['isLiked'] ?? currentState.isLiked,
        isBookmarked: externalState['isBookmarked'] ?? currentState.isBookmarked,
        likesCount: externalState['likes'] ?? currentState.likesCount,
        comments: List<Map<String, dynamic>>.from(externalState['comments'] ?? currentState.comments),
      );
      _cacheTimestamps[postId] = DateTime.now();
      _safeNotifyListeners();
      _notifyGlobalListeners();
    }
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

  // ПОДПИСКА НА ИЗМЕНЕНИЯ
  VoidCallback? addPostListener(String postId, VoidCallback listener) {
    addListener(listener);
    return () => removeListener(listener);
  }

  void removePostListener(VoidCallback listener) {
    removeListener(listener);
  }

  // ГЛОБАЛЬНЫЕ СЛУШАТЕЛИ
  void addGlobalChangeListener(VoidCallback listener) {
    addListener(listener);
  }

  void removeGlobalChangeListener(VoidCallback listener) {
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

  // ПОЛУЧЕНИЕ КОММЕНТАРИЕВ
  List<Map<String, dynamic>> getComments(String postId) {
    return _postStates[postId]?.comments ?? [];
  }

  // ПРОВЕРКА ПУСТОТЫ
  bool get isEmpty => _postStates.isEmpty;

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
  void forceSyncPost(String postId) {
    final state = _postStates[postId];
    if (state != null) {
      print('🔄 FORCE SYNC: Notifying all listeners for $postId');
      _safeNotifyListeners();

      // Дополнительно уведомляем глобальных слушателей
      _notifyGlobalListeners();
    }
  }
}