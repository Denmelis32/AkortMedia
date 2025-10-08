import 'package:flutter/foundation.dart';

class ChannelPostsProvider with ChangeNotifier {
  final Map<int, List<Map<String, dynamic>>> _channelPostsMap = {};

  List<Map<String, dynamic>> getPostsForChannel(int channelId) {
    return _channelPostsMap[channelId] ?? [];
  }

  void addPostToChannel(int channelId, Map<String, dynamic> post) {
    if (!_channelPostsMap.containsKey(channelId)) {
      _channelPostsMap[channelId] = [];
    }

    final postWithDefaults = {
      ...post,
      'likes': post['likes'] ?? 0,
      'isLiked': post['isLiked'] ?? false,
      'isBookmarked': post['isBookmarked'] ?? false,
      'comments': post['comments'] ?? [],
      'created_at': post['created_at'] ?? DateTime.now().toIso8601String(),
    };

    _channelPostsMap[channelId]!.insert(0, postWithDefaults);
    notifyListeners();
  }

  void loadPostsForChannel(int channelId, List<Map<String, dynamic>> posts) {
    final postsWithDefaults = posts.map((post) => {
      ...post,
      'likes': post['likes'] ?? 0,
      'isLiked': post['isLiked'] ?? false,
      'isBookmarked': post['isBookmarked'] ?? false,
      'comments': post['comments'] ?? [],
      'created_at': post['created_at'] ?? DateTime.now().toIso8601String(),
    }).toList();

    _channelPostsMap[channelId] = postsWithDefaults;
    notifyListeners();
  }

  void toggleLike(String postId) {
    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id'] == postId) {
          final isCurrentlyLiked = post['isLiked'] ?? false;
          final currentLikes = (post['likes'] ?? 0) as int;

          post['isLiked'] = !isCurrentlyLiked;
          post['likes'] = isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1;

          notifyListeners();
          return;
        }
      }
    }
  }

  void toggleBookmark(String postId) {
    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id'] == postId) {
          post['isBookmarked'] = !(post['isBookmarked'] ?? false);
          notifyListeners();
          return;
        }
      }
    }
  }

  void addComment(String postId, String text) {
    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id'] == postId) {
          final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);
          final newComment = {
            'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
            'text': text,
            'author': 'Текущий пользователь',
            'author_avatar': '',
            'time': 'Только что',
            'created_at': DateTime.now().toIso8601String(),
          };

          comments.insert(0, newComment);
          post['comments'] = comments;
          notifyListeners();
          return;
        }
      }
    }
  }

  void deleteComment(String postId, String commentId) {
    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id'] == postId) {
          final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);
          post['comments'] = comments.where((comment) => comment['id'] != commentId).toList();
          notifyListeners();
          return;
        }
      }
    }
  }

  void updatePost(String postId, Map<String, dynamic> updates) {
    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id'] == postId) {
          post.addAll(updates);
          notifyListeners();
          return;
        }
      }
    }
  }

  void deletePost(String postId) {
    for (final channelPosts in _channelPostsMap.values) {
      final initialLength = channelPosts.length;
      channelPosts.removeWhere((post) => post['id'] == postId);

      if (channelPosts.length != initialLength) {
        notifyListeners();
        return;
      }
    }
  }

  Map<String, dynamic>? getPostById(String postId) {
    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        if (post['id'] == postId) {
          return post;
        }
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
          channelPosts.where((post) => post['isBookmarked'] == true)
      );
    }
    return bookmarkedPosts;
  }

  List<Map<String, dynamic>> getPopularPosts({int minLikes = 10}) {
    final popularPosts = <Map<String, dynamic>>[];
    for (final channelPosts in _channelPostsMap.values) {
      popularPosts.addAll(
          channelPosts.where((post) => ((post['likes'] ?? 0) as int) >= minLikes)
      );
    }

    popularPosts.sort((a, b) => ((b['likes'] ?? 0) as int).compareTo((a['likes'] ?? 0) as int));
    return popularPosts;
  }

  List<Map<String, dynamic>> searchPosts(String query) {
    final results = <Map<String, dynamic>>[];
    final lowercaseQuery = query.toLowerCase();

    for (final channelPosts in _channelPostsMap.values) {
      for (final post in channelPosts) {
        final title = (post['title'] ?? '').toString().toLowerCase();
        final description = (post['description'] ?? '').toString().toLowerCase();
        final hashtags = (post['hashtags'] ?? []).join(' ').toLowerCase();

        if (title.contains(lowercaseQuery) ||
            description.contains(lowercaseQuery) ||
            hashtags.contains(lowercaseQuery)) {
          results.add(post);
        }
      }
    }

    return results;
  }

  void clearPostsForChannel(int channelId) {
    if (_channelPostsMap.containsKey(channelId)) {
      _channelPostsMap[channelId]!.clear();
      notifyListeners();
    }
  }

  void clearAll() {
    _channelPostsMap.clear();
    notifyListeners();
  }

  Map<String, dynamic> getChannelStats(int channelId) {
    final posts = _channelPostsMap[channelId] ?? [];

    // Исправлено: приведение типов к int
    final totalLikes = posts.fold<int>(0, (int sum, post) => sum + ((post['likes'] ?? 0) as int));
    final totalComments = posts.fold<int>(0, (int sum, post) => sum + ((post['comments'] ?? []).length as int));
    final bookmarkedCount = posts.where((post) => post['isBookmarked'] == true).length;

    return {
      'postCount': posts.length,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'bookmarkedCount': bookmarkedCount,
      'averageLikes': posts.isEmpty ? 0 : totalLikes / posts.length,
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
}