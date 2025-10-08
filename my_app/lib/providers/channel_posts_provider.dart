import 'package:flutter/foundation.dart';

class ChannelPostsProvider with ChangeNotifier {
  final Map<int, List<Map<String, dynamic>>> _channelPostsMap = {};

  List<Map<String, dynamic>> getPostsForChannel(int channelId) {
    return _channelPostsMap[channelId] ?? [];
  }

  // ИСПРАВЛЕНИЕ: Улучшенный метод добавления поста с проверкой дубликатов
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

    final postWithDefaults = {
      ...post,
      'id': postId ?? 'post_${DateTime.now().millisecondsSinceEpoch}_$channelId',
      'likes': _getIntValue(post['likes']),
      'isLiked': _getBoolValue(post['isLiked']),
      'isBookmarked': _getBoolValue(post['isBookmarked']),
      'comments': List<Map<String, dynamic>>.from(post['comments'] ?? []),
      'created_at': post['created_at'] ?? DateTime.now().toIso8601String(),
      'channel_id': channelId,
    };

    _channelPostsMap[channelId]!.insert(0, postWithDefaults);
    notifyListeners();

    print('✅ Post added to channel $channelId. Total posts: ${_channelPostsMap[channelId]!.length}');
  }

  // ИСПРАВЛЕНИЕ: Добавляем синоним метода для совместимости
  void addPost(int channelId, Map<String, dynamic> post) {
    addPostToChannel(channelId, post);
  }

  // НОВЫЙ МЕТОД: Обновление существующего поста
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

  // ИСПРАВЛЕНИЕ: Обновленный метод для обновления поста
  void updatePost(int channelId, String postId, Map<String, dynamic> updates) {
    final posts = _channelPostsMap[channelId];
    if (posts != null) {
      final index = posts.indexWhere((post) => post['id']?.toString() == postId);
      if (index != -1) {
        _updateExistingPost(channelId, index, updates);
      }
    }
  }

  void loadPostsForChannel(int channelId, List<Map<String, dynamic>> posts) {
    final postsWithDefaults = posts.map((post) => {
      ...post,
      'likes': _getIntValue(post['likes']),
      'isLiked': _getBoolValue(post['isLiked']),
      'isBookmarked': _getBoolValue(post['isBookmarked']),
      'comments': List<Map<String, dynamic>>.from(post['comments'] ?? []),
      'created_at': post['created_at'] ?? DateTime.now().toIso8601String(),
      'channel_id': channelId,
    }).toList();

    _channelPostsMap[channelId] = postsWithDefaults;
    notifyListeners();

    print('📥 Loaded ${postsWithDefaults.length} posts for channel $channelId');
  }

  // ИСПРАВЛЕНИЕ: Улучшенный toggleLike с проверкой типа
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

  // ИСПРАВЛЕНИЕ: Улучшенный toggleBookmark
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

  // ИСПРАВЛЕНИЕ: Улучшенный addComment с полными данными комментария
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

  // НОВЫЙ МЕТОД: Добавление комментария с полным объектом
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

  // ИСПРАВЛЕНИЕ: Улучшенный deletePost с указанием канала
  void deletePost(String postId, [int? channelId]) {
    bool found = false;

    if (channelId != null && _channelPostsMap.containsKey(channelId)) {
      // Удаляем из конкретного канала
      final initialLength = _channelPostsMap[channelId]!.length;
      _channelPostsMap[channelId]!.removeWhere((post) => post['id']?.toString() == postId);

      if (_channelPostsMap[channelId]!.length != initialLength) {
        found = true;
      }
    } else {
      // Ищем во всех каналах
      for (final channelPosts in _channelPostsMap.values) {
        final initialLength = channelPosts.length;
        channelPosts.removeWhere((post) => post['id']?.toString() == postId);

        if (channelPosts.length != initialLength) {
          found = true;
          break;
        }
      }
    }

    if (found) {
      notifyListeners();
      print('🗑️ Post $postId deleted');
    } else {
      print('❌ Post $postId not found for deletion');
    }
  }

  // НОВЫЙ МЕТОД: Удаление поста из конкретного канала
  void removePost(int channelId, String postId) {
    deletePost(postId, channelId);
  }

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

  // НОВЫЙ МЕТОД: Получение поста с указанием канала
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

  int getPostCountForChannel(int channelId) {
    return _channelPostsMap[channelId]?.length ?? 0;
  }

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

  // ИСПРАВЛЕНИЕ: Улучшенный поиск с поддержкой хештегов
  List<Map<String, dynamic>> searchPosts(String query) {
    if (query.isEmpty) return getAllPosts();

    final results = <Map<String, dynamic>>[];
    final lowercaseQuery = query.toLowerCase().trim();

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        final title = (post['title'] ?? '').toString().toLowerCase();
        final description = (post['description'] ?? '').toString().toLowerCase();
        final hashtags = (post['hashtags'] is List
            ? (post['hashtags'] as List).join(' ').toLowerCase()
            : '');

        if (title.contains(lowercaseQuery) ||
            description.contains(lowercaseQuery) ||
            hashtags.contains(lowercaseQuery)) {
          results.add(post);
        }
      }
    }

    return results;
  }

  // НОВЫЙ МЕТОД: Поиск по хештегам
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

  void clearPostsForChannel(int channelId) {
    if (_channelPostsMap.containsKey(channelId)) {
      final count = _channelPostsMap[channelId]!.length;
      _channelPostsMap[channelId]!.clear();
      notifyListeners();
      print('🧹 Cleared $count posts from channel $channelId');
    }
  }

  void clearAll() {
    final totalPosts = getAllPosts().length;
    _channelPostsMap.clear();
    notifyListeners();
    print('🧹 Cleared all $totalPosts posts from all channels');
  }

  // ИСПРАВЛЕНИЕ: Улучшенная статистика с безопасными вычислениями
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

  List<Map<String, dynamic>> getRecentPosts({int limit = 10}) {
    final allPosts = getAllPosts();

    allPosts.sort((a, b) {
      final dateA = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
      final dateB = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
      return dateB.compareTo(dateA);
    });

    return allPosts.take(limit).toList();
  }

  // НОВЫЙ МЕТОД: Получение постов за период
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

  // НОВЫЙ МЕТОД: Проверка существования поста
  bool containsPost(String postId) {
    return getPostById(postId) != null;
  }

  // НОВЫЙ МЕТОД: Получение индекса поста в канале
  int getPostIndexInChannel(int channelId, String postId) {
    final posts = _channelPostsMap[channelId];
    if (posts != null) {
      return posts.indexWhere((post) => post['id']?.toString() == postId);
    }
    return -1;
  }

  // Вспомогательные методы для безопасного получения значений
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

  // НОВЫЙ МЕТОД: Получение всех каналов с постами
  Map<int, List<Map<String, dynamic>>> getAllChannelPosts() {
    return Map.from(_channelPostsMap);
  }

  // НОВЫЙ МЕТОД: Получение количества каналов с постами
  int getChannelCount() {
    return _channelPostsMap.length;
  }

  // НОВЫЙ МЕТОД: Получение общего количества постов
  int getTotalPostCount() {
    return _channelPostsMap.values.fold<int>(0, (sum, posts) => sum + posts.length);
  }

  @override
  void dispose() {
    _channelPostsMap.clear();
    super.dispose();
  }
}