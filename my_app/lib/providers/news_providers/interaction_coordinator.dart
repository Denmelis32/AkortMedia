// lib/providers/news_providers/interaction_coordinator.dart
import 'package:flutter/foundation.dart';
import '../../services/interaction_manager.dart';

class InteractionCoordinator {
  final InteractionManager _interactionManager;

  Function(String, bool, int)? onLike;
  Function(String, bool)? onBookmark;
  Function(String, bool, int, String, String)? onRepost;
  Function(String, Map<String, dynamic>)? onComment;
  Function(String, String)? onCommentRemoval;

  InteractionCoordinator()
      : _interactionManager = InteractionManager();

  void setCallbacks({
    Function(String, bool, int)? onLike,
    Function(String, bool)? onBookmark,
    Function(String, bool, int, String, String)? onRepost,
    Function(String, Map<String, dynamic>)? onComment,
    Function(String, String)? onCommentRemoval,
  }) {
    this.onLike = onLike;
    this.onBookmark = onBookmark;
    this.onRepost = onRepost;
    this.onComment = onComment;
    this.onCommentRemoval = onCommentRemoval;

    _initializeInteractionManager();
  }

  void _initializeInteractionManager() {
    _interactionManager.setCallbacks(
      onLike: (postId, isLiked, likesCount) {
        onLike?.call(postId, isLiked, likesCount);
      },
      onBookmark: (postId, isBookmarked) {
        onBookmark?.call(postId, isBookmarked);
      },
      onRepost: (postId, isReposted, repostsCount, userId, userName) {
        onRepost?.call(postId, isReposted, repostsCount, userId, userName);
      },
      onComment: (postId, comment) {
        onComment?.call(postId, comment);
      },
      onCommentRemoval: (postId, commentId) {
        onCommentRemoval?.call(postId, commentId);
      },
    );
  }

  void initializeInteractions(List<dynamic> newsList) {
    final List<Map<String, dynamic>> newsMapList = newsList.map((item) {
      if (item is Map<String, dynamic>) {
        final isRepost = item['is_repost'] == true;
        final repostComment = item['repost_comment']?.toString() ?? '';
        final comments = List<dynamic>.from(item['comments'] ?? []);

        if (isRepost && repostComment.isNotEmpty && comments.isNotEmpty) {
          return {
            ...item,
            'comments': [],
          };
        }
        return item;
      } else {
        return {'id': item.toString(), 'isLiked': false, 'isBookmarked': false};
      }
    }).toList();

    _interactionManager.bulkUpdatePostStates(newsMapList);
    print('✅ Interactions initialized for ${newsMapList.length} posts');
  }

  void initializePostState(Map<String, dynamic> newsItem) {
    _interactionManager.initializePostState(
      postId: newsItem['id'].toString(),
      isLiked: newsItem['isLiked'] ?? false,
      isBookmarked: newsItem['isBookmarked'] ?? false,
      isReposted: newsItem['isReposted'] ?? false,
      likesCount: newsItem['likes'] ?? 0,
      repostsCount: newsItem['reposts'] ?? 0,
      comments: List<Map<String, dynamic>>.from(newsItem['comments'] ?? []),
    );
  }

  void syncPostState(String postId) {
    final interactionState = _interactionManager.getPostState(postId);
    if (interactionState == null) {
      print('⚠️ No interaction state found for post: $postId');
      return;
    }

    print('🔄 Syncing post state: $postId');
    print('   Likes: ${interactionState.likesCount}, Liked: ${interactionState.isLiked}');
    print('   Bookmarks: ${interactionState.isBookmarked}');
    print('   Reposts: ${interactionState.repostsCount}, Reposted: ${interactionState.isReposted}');
    print('   Comments: ${interactionState.comments.length}');
  }

  void syncAllPosts(List<dynamic> news) {
    print('🔄 Starting full sync of all posts');
    int syncedCount = 0;

    for (final postId in _interactionManager.getAllPostIds()) {
      final index = _findNewsIndexById(news, postId);
      if (index != -1) {
        syncPostState(postId);
        syncedCount++;
      }
    }

    print('✅ Full sync completed: $syncedCount posts synchronized');
  }

  int _findNewsIndexById(List<dynamic> news, String postId) {
    return news.indexWhere((item) => item['id'].toString() == postId);
  }

  void updateComments(String postId, List<dynamic> comments) {
    // Приводим тип к List<Map<String, dynamic>>
    final typedComments = comments.cast<Map<String, dynamic>>();
    _interactionManager.updateComments(postId, typedComments);
  }

  InteractionManager get interactionManager => _interactionManager;

  void dispose() {
    _interactionManager.setCallbacks(
      onLike: null,
      onBookmark: null,
      onRepost: null,
      onComment: null,
      onCommentRemoval: null,
    );
  }
}