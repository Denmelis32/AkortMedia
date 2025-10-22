// lib/providers/news_providers/repost_manager.dart
import '../../services/repost_manager.dart' as core;

class RepostManager {
  final core.RepostManager _repostManager;

  Function()? onRepostStateChanged;
  Function(String, bool, int)? onRepostUpdated;

  RepostManager() : _repostManager = core.RepostManager();

  void initialize({
    Function()? onRepostStateChanged,
    Function(String, bool, int)? onRepostUpdated,
  }) {
    this.onRepostStateChanged = onRepostStateChanged;
    this.onRepostUpdated = onRepostUpdated;

    _repostManager.initialize(
      onRepostStateChanged: onRepostStateChanged,
      onRepostUpdated: onRepostUpdated,
    );
  }

  Future<void> createRepost({
    required dynamic newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
  }) async {
    await _repostManager.createRepost(
      newsProvider: newsProvider,
      originalIndex: originalIndex,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
  }

  Future<void> cancelRepost({
    required dynamic newsProvider,
    required String repostId,
    required String currentUserId,
  }) async {
    await _repostManager.cancelRepost(
      newsProvider: newsProvider,
      repostId: repostId,
      currentUserId: currentUserId,
    );
  }

  void toggleRepost({
    required dynamic newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
  }) {
    _repostManager.toggleRepost(
      newsProvider: newsProvider,
      originalIndex: originalIndex,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
  }

  List<dynamic> getUserReposts(dynamic newsProvider, String userId) {
    return _repostManager.getUserReposts(newsProvider, userId);
  }

  bool isNewsRepostedByUser(dynamic newsProvider, String newsId, String userId) {
    return _repostManager.isNewsRepostedByUser(newsProvider, newsId, userId);
  }

  String? getRepostIdForOriginal(dynamic newsProvider, String originalNewsId, String userId) {
    return _repostManager.getRepostIdForOriginal(newsProvider, originalNewsId, userId);
  }

  void dispose() {
    _repostManager.dispose();
  }
}