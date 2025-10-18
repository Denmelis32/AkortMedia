import 'package:flutter/foundation.dart';

import '../services/interaction_manager.dart';

class ChannelPostsProvider with ChangeNotifier {
  final Map<int, List<Map<String, dynamic>>> _channelPostsMap = {};

  // === ОСНОВНЫЕ МЕТОДЫ ДОСТУПА К ДАННЫМ ===

  List<Map<String, dynamic>> getPostsForChannel(int channelId) {
    return _channelPostsMap[channelId] ?? [];
  }

  // Синоним для совместимости
  List<Map<String, dynamic>> getChannelPosts(int channelId) {
    return getPostsForChannel(channelId);
  }

  // === ДОБАВЛЕНИЕ И ОБНОВЛЕНИЕ ПОСТОВ ===

  void addPostToChannel(int channelId, Map<String, dynamic> post) {
    if (!_channelPostsMap.containsKey(channelId)) {
      _channelPostsMap[channelId] = [];
    }

    // Проверка на дубликаты
    final postId = post['id']?.toString();
    if (postId != null) {
      final existingPostIndex = _channelPostsMap[channelId]!.indexWhere(
              (p) => p['id']?.toString() == postId
      );

      if (existingPostIndex != -1) {
        print('⚠️ Post with ID $postId already exists in channel $channelId, updating instead');
        _updateExistingPost(channelId, existingPostIndex, post);
        return;
      }
    }

    final postWithDefaults = _preparePostData(post, channelId);
    _channelPostsMap[channelId]!.insert(0, postWithDefaults);
    notifyListeners();

    print('✅ Post added to channel $channelId. Total posts: ${_channelPostsMap[channelId]!.length}');
  }

  // Синоним для совместимости с ContentManager
  void addPost(int channelId, Map<String, dynamic> post) {
    addPostToChannel(channelId, post);
  }

  void _updateExistingPost(int channelId, int index, Map<String, dynamic> updates) {
    final existingPost = _channelPostsMap[channelId]![index];
    _channelPostsMap[channelId]![index] = {
      ...existingPost,
      ...updates,
      // Сохраняем важные поля
      'id': existingPost['id'],
      'created_at': existingPost['created_at'],
      'channel_id': existingPost['channel_id'],
    };
    notifyListeners();
  }

  void updatePost(int channelId, String postId, Map<String, dynamic> updates) {
    final posts = _channelPostsMap[channelId];
    if (posts != null) {
      final index = posts.indexWhere((post) => post['id']?.toString() == postId);
      if (index != -1) {
        _updateExistingPost(channelId, index, updates);
        print('✅ Post $postId updated in channel $channelId');
      } else {
        print('❌ Post $postId not found in channel $channelId for update');
      }
    } else {
      print('❌ Channel $channelId not found for post update');
    }
  }

  void loadPostsForChannel(int channelId, List<Map<String, dynamic>> posts) {
    final postsWithDefaults = posts.map((post) =>
        _preparePostData(post, channelId)
    ).toList();

    _channelPostsMap[channelId] = postsWithDefaults;
    notifyListeners();

    print('📥 Loaded ${postsWithDefaults.length} posts for channel $channelId');
  }

  // === ВЗАИМОДЕЙСТВИЯ С ПОСТАМИ ===

  void toggleLike(String postId) {
    bool found = false;

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id']?.toString() == postId) {
          final isCurrentlyLiked = _getBoolValue(post['isLiked']);
          final currentLikes = _getIntValue(post['likes']);

          post['isLiked'] = !isCurrentlyLiked;
          post['likes'] = isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1;

          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      notifyListeners();
      print('❤️ Like toggled for post $postId');
    } else {
      print('❌ Post $postId not found for like toggle');
    }
  }

  void toggleBookmark(String postId) {
    bool found = false;

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id']?.toString() == postId) {
          post['isBookmarked'] = !_getBoolValue(post['isBookmarked']);
          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      notifyListeners();
      print('🔖 Bookmark toggled for post $postId');
    } else {
      print('❌ Post $postId not found for bookmark toggle');
    }
  }

  // === КОММЕНТАРИИ ===

  void addComment(String postId, String text, {String? userName, String? userAvatar}) {
    bool found = false;

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id']?.toString() == postId) {
          final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);
          final newComment = {
            'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
            'text': text,
            'author': userName ?? 'Текущий пользователь',
            'author_avatar': userAvatar ?? '',
            'time': 'Только что',
            'created_at': DateTime.now().toIso8601String(),
          };

          comments.insert(0, newComment);
          post['comments'] = comments;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      notifyListeners();
      print('💬 Comment added to post $postId');
    } else {
      print('❌ Post $postId not found for adding comment');
    }
  }

  void addCommentToPost(String postId, Map<String, dynamic> comment) {
    bool found = false;

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id']?.toString() == postId) {
          final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);
          comments.insert(0, {
            ...comment,
            'id': comment['id'] ?? 'comment_${DateTime.now().millisecondsSinceEpoch}',
            'created_at': comment['created_at'] ?? DateTime.now().toIso8601String(),
          });

          post['comments'] = comments;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      notifyListeners();
      print('💬 Comment object added to post $postId');
    }
  }

  void deleteComment(String postId, String commentId) {
    bool found = false;

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id']?.toString() == postId) {
          final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);
          final initialLength = comments.length;
          post['comments'] = comments.where((comment) => comment['id'] != commentId).toList();

          if (comments.length != initialLength) {
            found = true;
          }
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      notifyListeners();
      print('🗑️ Comment $commentId deleted from post $postId');
    } else {
      print('❌ Comment $commentId not found in post $postId');
    }
  }

  // === УДАЛЕНИЕ ПОСТОВ ===

  void deletePost(String postId, [int? channelId]) {
    bool found = false;

    if (channelId != null && _channelPostsMap.containsKey(channelId)) {
      final initialLength = _channelPostsMap[channelId]!.length;
      _channelPostsMap[channelId]!.removeWhere((post) => post['id']?.toString() == postId);

      if (_channelPostsMap[channelId]!.length != initialLength) {
        found = true;
        print('🗑️ Post $postId deleted from channel $channelId');
      }
    } else {
      for (final channelPosts in _channelPostsMap.values) {
        final initialLength = channelPosts.length;
        channelPosts.removeWhere((post) => post['id']?.toString() == postId);

        if (channelPosts.length != initialLength) {
          found = true;
          print('🗑️ Post $postId deleted from channel');
          break;
        }
      }
    }

    if (found) {
      notifyListeners();
    } else {
      print('❌ Post $postId not found for deletion');
    }
  }

  void removePost(int channelId, String postId) {
    deletePost(postId, channelId);
  }

  // === ПОИСК И ФИЛЬТРАЦИЯ ===

  Map<String, dynamic>? getPostById(String postId) {
    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id']?.toString() == postId) {
          return post;
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? getPostFromChannel(int channelId, String postId) {
    final channelPosts = _channelPostsMap[channelId];
    if (channelPosts != null) {
      try {
        return channelPosts.firstWhere(
              (post) => post['id']?.toString() == postId,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> searchPosts(String query) {
    if (query.isEmpty) return getAllPosts();

    final results = <Map<String, dynamic>>[];
    final lowercaseQuery = query.toLowerCase().trim();

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        final title = (post['title'] ?? '').toString().toLowerCase();
        final description = (post['description'] ?? '').toString().toLowerCase();
        final content = (post['content'] ?? '').toString().toLowerCase();
        final hashtags = (post['hashtags'] is List
            ? (post['hashtags'] as List).join(' ').toLowerCase()
            : '');

        if (title.contains(lowercaseQuery) ||
            description.contains(lowercaseQuery) ||
            content.contains(lowercaseQuery) ||
            hashtags.contains(lowercaseQuery)) {
          results.add(post);
        }
      }
    }

    return results;
  }

  List<Map<String, dynamic>> searchByHashtag(String hashtag) {
    final cleanHashtag = hashtag.replaceAll('#', '').toLowerCase().trim();
    if (cleanHashtag.isEmpty) return [];

    final results = <Map<String, dynamic>>[];

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        final hashtags = post['hashtags'] is List
            ? (post['hashtags'] as List).map((tag) => tag.toString().toLowerCase()).toList()
            : [];

        if (hashtags.any((tag) => tag.contains(cleanHashtag))) {
          results.add(post);
        }
      }
    }

    return results;
  }

  // === ПОЛУЧЕНИЕ СПИСКОВ ПОСТОВ ===

  List<Map<String, dynamic>> getAllPosts() {
    final allPosts = <Map<String, dynamic>>[];
    for (final channelPosts in _channelPostsMap.values) {
      allPosts.addAll(channelPosts);
    }
    return allPosts;
  }

  List<Map<String, dynamic>> getBookmarkedPosts() {
    final bookmarkedPosts = <Map<String, dynamic>>[];
    for (final channelPosts in _channelPostsMap.values) {
      bookmarkedPosts.addAll(
          channelPosts.where((post) => _getBoolValue(post['isBookmarked']))
      );
    }
    return bookmarkedPosts;
  }

  List<Map<String, dynamic>> getPopularPosts({int minLikes = 10}) {
    final popularPosts = <Map<String, dynamic>>[];
    for (final channelPosts in _channelPostsMap.values) {
      popularPosts.addAll(
          channelPosts.where((post) => _getIntValue(post['likes']) >= minLikes)
      );
    }

    popularPosts.sort((a, b) => _getIntValue(b['likes']).compareTo(_getIntValue(a['likes'])));
    return popularPosts;
  }

  List<Map<String, dynamic>> getRecentPosts({int limit = 10}) {
    final allPosts = getAllPosts();

    allPosts.sort((a, b) {
      final dateA = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
      final dateB = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
      return dateB.compareTo(dateA);
    });

    return allPosts.take(limit).toList();
  }

  List<Map<String, dynamic>> getPostsFromPeriod(DateTime start, DateTime end) {
    final allPosts = getAllPosts();

    return allPosts.where((post) {
      try {
        final postDate = DateTime.parse(post['created_at'] ?? '');
        return postDate.isAfter(start) && postDate.isBefore(end);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // === СТАТИСТИКА И АНАЛИТИКА ===

  int getPostCountForChannel(int channelId) {
    return _channelPostsMap[channelId]?.length ?? 0;
  }

  int getTotalPostsCount() {
    return _channelPostsMap.values.fold<int>(0, (sum, posts) => sum + posts.length);
  }

  Map<String, dynamic> getChannelStats(int channelId) {
    final posts = _channelPostsMap[channelId] ?? [];

    final totalLikes = posts.fold<int>(0, (int sum, post) => sum + _getIntValue(post['likes']));
    final totalComments = posts.fold<int>(0, (int sum, post) => sum + (post['comments'] is List ? (post['comments'] as List).length : 0));
    final bookmarkedCount = posts.where((post) => _getBoolValue(post['isBookmarked'])).length;

    return {
      'postCount': posts.length,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'bookmarkedCount': bookmarkedCount,
      'averageLikes': posts.isEmpty ? 0.0 : totalLikes / posts.length,
      'engagementRate': posts.isEmpty ? 0.0 : (totalLikes + totalComments) / posts.length,
    };
  }

  Map<int, List<Map<String, dynamic>>> getAllChannelPosts() {
    return Map.from(_channelPostsMap);
  }

  int getChannelCount() {
    return _channelPostsMap.length;
  }

  // === ВАЛИДАЦИЯ И ПРОВЕРКИ ===

  bool containsPost(String postId) {
    return getPostById(postId) != null;
  }

  int getPostIndexInChannel(int channelId, String postId) {
    final posts = _channelPostsMap[channelId];
    if (posts != null) {
      return posts.indexWhere((post) => post['id']?.toString() == postId);
    }
    return -1;
  }

  bool channelExists(int channelId) {
    return _channelPostsMap.containsKey(channelId);
  }

  // === ОЧИСТКА ДАННЫХ ===

  void clearPostsForChannel(int channelId) {
    if (_channelPostsMap.containsKey(channelId)) {
      final count = _channelPostsMap[channelId]!.length;
      _channelPostsMap[channelId]!.clear();
      notifyListeners();
      print('🧹 Cleared $count posts from channel $channelId');
    }
  }

  void initializeChannelInteractions(int channelId) {
    final interactionManager = InteractionManager();
    final posts = getChannelPosts(channelId);
    interactionManager.bulkUpdatePostStates(posts);
  }


  void clearAllPosts() {
    final totalPosts = getTotalPostsCount();
    _channelPostsMap.clear();
    notifyListeners();
    print('🧹 Cleared all $totalPosts posts from all channels');
  }

  // Синоним для совместимости
  void clearAll() {
    clearAllPosts();
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  Map<String, dynamic> _preparePostData(Map<String, dynamic> post, int channelId) {
    return {
      ...post,
      'id': post['id']?.toString() ?? 'post_${DateTime.now().millisecondsSinceEpoch}_$channelId',
      'likes': _getIntValue(post['likes']),
      'isLiked': _getBoolValue(post['isLiked']),
      'isBookmarked': _getBoolValue(post['isBookmarked']),
      'comments': List<Map<String, dynamic>>.from(post['comments'] ?? []),
      'hashtags': List<String>.from(post['hashtags'] ?? []),
      'created_at': post['created_at'] ?? DateTime.now().toIso8601String(),
      'channel_id': channelId,
    };
  }

  int _getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  @override
  void dispose() {
    _channelPostsMap.clear();
    super.dispose();
  }
}