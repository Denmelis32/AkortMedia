// lib/providers/news_providers/repost_manager.dart
import 'package:flutter/foundation.dart';

class RepostManager with ChangeNotifier {
  final Map<String, String> _repostMapping = {}; // originalPostId -> repostId
  final Map<String, String> _repostToOriginalMapping = {}; // repostId -> originalPostId
  final Map<String, Map<String, dynamic>> _repostData = {};

  Function(String, bool, int)? _onRepostStateChanged;
  Function(String, bool, int)? _onRepostUpdated;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void initialize({
    Function(String, bool, int)? onRepostStateChanged,
    Function(String, bool, int)? onRepostUpdated,
  }) {
    _onRepostStateChanged = onRepostStateChanged;
    _onRepostUpdated = onRepostUpdated;
    _isInitialized = true;
    print('✅ RepostManager initialized');
  }

  void createRepost({
    required dynamic newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
    String? repostComment,
  }) {
    if (!_isInitialized) {
      print('❌ RepostManager not initialized');
      return;
    }

    try {
      final originalNews = newsProvider.news[originalIndex];
      final originalPostId = originalNews['id'].toString();

      // Создаем уникальный ID для репоста
      final repostId = 'repost_${originalPostId}_${DateTime.now().millisecondsSinceEpoch}';

      // Создаем данные репоста
      final repostData = {
        'id': repostId,
        'title': originalNews['title'],
        'description': originalNews['description'],
        'content': originalNews['content'],
        'author_name': currentUserName,
        'author_id': currentUserId,
        'original_author_name': originalNews['author_name'],
        'original_author_id': originalNews['author_id'],
        'original_post_id': originalPostId,
        'repost_comment': repostComment ?? '',
        'is_repost': true,
        'created_at': DateTime.now().toIso8601String(),
        'likes': 0,
        'reposts': 0,
        'comments': [],
        'isLiked': false,
        'isBookmarked': false,
        'isReposted': false,
        'hashtags': originalNews['hashtags'] ?? [],
      };

      // Сохраняем маппинги
      _repostMapping[originalPostId] = repostId;
      _repostToOriginalMapping[repostId] = originalPostId;
      _repostData[repostId] = repostData;

      // Добавляем репост в начало ленты
      newsProvider.news.insert(0, repostData);

      // Уведомляем слушателей
      newsProvider.notifyListeners();

      // Вызываем колбэки
      _onRepostStateChanged?.call(originalPostId, true, _getRepostCount(originalPostId));
      _onRepostUpdated?.call(originalPostId, true, _getRepostCount(originalPostId));

      print('✅ Repost created: $repostId for original post: $originalPostId');
    } catch (e) {
      print('❌ Error creating repost: $e');
    }
  }

  void cancelRepost({
    required dynamic newsProvider,
    required String repostId,
    required String currentUserId,
  }) {
    if (!_isInitialized) {
      print('❌ RepostManager not initialized');
      return;
    }

    try {
      final originalPostId = _repostToOriginalMapping[repostId];

      if (originalPostId != null) {
        // Удаляем репост из ленты
        final index = newsProvider.news.indexWhere((post) => post['id'] == repostId);
        if (index != -1) {
          newsProvider.news.removeAt(index);
        }

        // Очищаем маппинги
        _repostMapping.remove(originalPostId);
        _repostToOriginalMapping.remove(repostId);
        _repostData.remove(repostId);

        // Уведомляем слушателей
        newsProvider.notifyListeners();

        // Вызываем колбэки
        _onRepostStateChanged?.call(originalPostId, false, _getRepostCount(originalPostId));
        _onRepostUpdated?.call(originalPostId, false, _getRepostCount(originalPostId));

        print('✅ Repost cancelled: $repostId for original post: $originalPostId');
      } else {
        print('❌ Original post not found for repost: $repostId');
      }
    } catch (e) {
      print('❌ Error cancelling repost: $e');
    }
  }

  void toggleRepost({
    required dynamic newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
    String? repostComment,
  }) {
    final originalNews = newsProvider.news[originalIndex];
    final originalPostId = originalNews['id'].toString();

    final existingRepostId = _repostMapping[originalPostId];

    if (existingRepostId != null) {
      // Отменяем репост
      cancelRepost(
        newsProvider: newsProvider,
        repostId: existingRepostId,
        currentUserId: currentUserId,
      );
    } else {
      // Создаем репост
      createRepost(
        newsProvider: newsProvider,
        originalIndex: originalIndex,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        repostComment: repostComment,
      );
    }
  }

  String? getRepostIdForOriginal(dynamic newsProvider, String originalPostId, String currentUserId) {
    return _repostMapping[originalPostId];
  }

  bool isRepostedByUser(String originalPostId, String currentUserId) {
    return _repostMapping.containsKey(originalPostId);
  }

  int _getRepostCount(String originalPostId) {
    return _repostMapping.containsKey(originalPostId) ? 1 : 0;
  }

  Map<String, dynamic>? getRepostData(String repostId) {
    return _repostData[repostId];
  }

  Map<String, dynamic>? getOriginalPostData(dynamic newsProvider, String repostId) {
    final originalPostId = _repostToOriginalMapping[repostId];
    if (originalPostId != null) {
      final index = newsProvider.findNewsIndexById(originalPostId);
      if (index != -1) {
        return Map<String, dynamic>.from(newsProvider.news[index]);
      }
    }
    return null;
  }

  List<Map<String, dynamic>> getUserReposts(dynamic newsProvider, String userId) {
    final userReposts = newsProvider.news.where((post) {
      return post['is_repost'] == true && post['author_id'] == userId;
    }).toList();

    return userReposts.map((post) => Map<String, dynamic>.from(post)).toList();
  }

  void clearUserReposts(dynamic newsProvider, String userId) {
    final repostsToRemove = newsProvider.news.where((post) {
      return post['is_repost'] == true && post['author_id'] == userId;
    }).toList();

    for (final repost in repostsToRemove) {
      final repostId = repost['id'].toString();
      final originalPostId = _repostToOriginalMapping[repostId];

      if (originalPostId != null) {
        _repostMapping.remove(originalPostId);
        _repostToOriginalMapping.remove(repostId);
        _repostData.remove(repostId);
      }
    }

    newsProvider.news.removeWhere((post) {
      return post['is_repost'] == true && post['author_id'] == userId;
    });

    newsProvider.notifyListeners();
    print('✅ Cleared all reposts for user: $userId');
  }

  void dispose() {
    _repostMapping.clear();
    _repostToOriginalMapping.clear();
    _repostData.clear();
    _onRepostStateChanged = null;
    _onRepostUpdated = null;
    _isInitialized = false;
    print('✅ RepostManager disposed');
  }
}