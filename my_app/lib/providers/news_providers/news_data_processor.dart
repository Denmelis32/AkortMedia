// lib/providers/news_providers/news_data_processor.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'user_profile_manager.dart';

class NewsDataProcessor {
  Future<List<dynamic>> processNewsData({
    required List<dynamic> news,
    required UserProfileManager profileManager,
  }) async {
    final localLikes = await StorageService.loadLikes();
    final localBookmarks = await StorageService.loadBookmarks();
    final userTags = await StorageService.loadUserTags();

    return await Future.wait(news.map((newsItem) async {
      final newsId = newsItem['id'].toString();

      // Обработка user_tags
      final Map<String, String> itemUserTags = _processUserTags(newsId, newsItem, userTags);
      final tagColor = await _getTagColor(newsId, itemUserTags);

      // Определение аватара автора
      final authorName = newsItem['author_name']?.toString() ?? 'Пользователь';
      final authorId = newsItem['author_id']?.toString() ?? '';
      final authorAvatar = profileManager.getUserAvatarUrl(authorId, authorName);

      // Обработка комментариев для репостов
      final isRepost = newsItem['is_repost'] == true;
      final repostComment = newsItem['repost_comment']?.toString() ?? '';
      final List<dynamic> finalComments = _processComments(isRepost, repostComment, newsItem);

      return {
        ...newsItem,
        'isLiked': localLikes.contains(newsId),
        'isBookmarked': localBookmarks.contains(newsId),
        'hashtags': parseHashtags(newsItem['hashtags']),
        'user_tags': itemUserTags,
        'comments': finalComments,
        'likes': newsItem['likes'] ?? 0,
        'tag_color': tagColor,
        'author_avatar': authorAvatar,
      };
    }));
  }

  // ДОБАВЬТЕ ЭТИ МЕТОДЫ:

  /// Публичный метод для парсинга хештегов
  List<String> parseHashtags(dynamic hashtags) {
    return _parseHashtags(hashtags);
  }

  /// Публичный метод для генерации цвета из ID
  Color generateColorFromId(String id) {
    return _generateColorFromId(id);
  }

  /// Публичный метод для обновления тегов новости
  void updateNewsTags(List<dynamic> news, int index, Map<String, String> userTags) {
    if (index >= 0 && index < news.length) {
      final newsItem = news[index];
      final newsId = newsItem['id'].toString();

      final tagColor = _generateColorFromId(newsId).value;

      news[index] = {
        ...newsItem,
        'user_tags': userTags,
        'tag_color': tagColor,
      };
    }
  }

  // Существующие приватные методы:

  Map<String, String> _processUserTags(String newsId, dynamic newsItem, Map<String, dynamic> userTags) {
    if (userTags.containsKey(newsId)) {
      final newsTags = userTags[newsId]!;
      if (newsTags['tags'] is Map) {
        final tagsMap = newsTags['tags'] as Map;
        return tagsMap.map((key, value) =>
            MapEntry(key.toString(), value.toString())
        );
      }
    }

    return newsItem['user_tags'] is Map
        ? (newsItem['user_tags'] as Map).map((key, value) =>
        MapEntry(key.toString(), value.toString())
    )
        : {'tag1': 'Фанат Манчестера'};
  }

  List<dynamic> _processComments(bool isRepost, String repostComment, dynamic newsItem) {
    if (isRepost && repostComment.isNotEmpty) {
      return [];
    }
    return newsItem['comments'] ?? [];
  }

  Future<Map<String, dynamic>> prepareNewsItem({
    required Map<String, dynamic> newsItem,
    required UserProfileManager profileManager,
  }) async {
    final newNewsId = newsItem['id']?.toString();
    final isRepost = newsItem['is_repost'] == true;
    final repostComment = newsItem['repost_comment']?.toString() ?? '';
    final isChannelPost = newsItem['is_channel_post'] == true;
    final authorName = newsItem['author_name']?.toString() ?? 'Пользователь';
    final channelName = newsItem['channel_name']?.toString() ?? '';

    // Создаем уникальный ID если не предоставлен
    final uniqueId = newNewsId ?? 'news-${DateTime.now().millisecondsSinceEpoch}';

    // Определяем аватар автора
    String authorAvatar;
    if (isRepost) {
      final repostedById = newsItem['reposted_by']?.toString() ?? '';
      final repostedByName = newsItem['reposted_by_name']?.toString() ?? authorName;
      authorAvatar = profileManager.getUserAvatarUrl(repostedById, repostedByName);
    } else {
      final authorId = newsItem['author_id']?.toString() ?? '';
      authorAvatar = profileManager.getUserAvatarUrl(authorId, authorName);
    }

    // Обработка комментариев
    final List<dynamic> comments = _prepareComments(isRepost, repostComment, newsItem);

    return {
      'id': uniqueId,
      'title': newsItem['title']?.toString() ?? '',
      'description': newsItem['description']?.toString() ?? '',
      'image': newsItem['image']?.toString() ?? '',
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'channel_name': channelName,
      'channel_id': newsItem['channel_id']?.toString() ?? '',
      'created_at': newsItem['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      'likes': newsItem['likes'] ?? 0,
      'comments': comments,
      'hashtags': parseHashtags(newsItem['hashtags']),

      // Данные репоста
      'is_repost': isRepost,
      'reposted_by': newsItem['reposted_by']?.toString(),
      'reposted_by_name': newsItem['reposted_by_name']?.toString(),
      'reposted_at': newsItem['reposted_at']?.toString(),
      'original_post_id': newsItem['original_post_id']?.toString(),
      'original_author_name': newsItem['original_author_name']?.toString(),
      'original_author_avatar': newsItem['original_author_avatar']?.toString(),
      'original_channel_name': newsItem['original_channel_name']?.toString(),
      'is_original_channel_post': newsItem['is_original_channel_post'] ?? false,

      // Комментарий репоста
      'repost_comment': repostComment,

      // Обычные поля
      'user_tags': newsItem['user_tags'] ?? <String, String>{},
      'isLiked': newsItem['isLiked'] ?? false,
      'isBookmarked': newsItem['isBookmarked'] ?? false,
      'isFollowing': newsItem['isFollowing'] ?? false,
      'tag_color': newsItem['tag_color'] ?? generateColorFromId(uniqueId).value,
      'is_channel_post': isChannelPost,
      'content_type': isChannelPost ? 'channel_post' : (isRepost ? 'repost' : 'regular_post'),
    };
  }

  List<dynamic> _prepareComments(bool isRepost, String repostComment, Map<String, dynamic> newsItem) {
    if (isRepost && repostComment.isNotEmpty) {
      return [];
    } else if (isRepost) {
      return [];
    } else {
      return newsItem['comments'] ?? [];
    }
  }

  List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is List) {
      return List<String>.from(hashtags).map((tag) {
        var cleanTag = tag.toString().replaceAll(RegExp(r'#'), '').trim();
        cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
        return cleanTag;
      }).where((tag) => tag.isNotEmpty).toList();
    }

    if (hashtags is String) {
      return hashtags
          .split(RegExp(r'[,\s]+'))
          .map((tag) {
        var cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
        cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
        return cleanTag;
      })
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    return [];
  }

  Future<int> _getTagColor(String newsId, Map<String, String> userTags) async {
    try {
      final storedColor = await StorageService.getTagColor(newsId);
      if (storedColor != null) return storedColor;
    } catch (e) {
      print('Error getting tag color: $e');
    }

    return _generateColorFromId(newsId).value;
  }

  Color _generateColorFromId(String id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }



  int findNewsIndexById(List<dynamic> news, String newsId) {
    return news.indexWhere((item) => item['id'].toString() == newsId);
  }

  bool containsNews(List<dynamic> news, String newsId) {
    return news.any((item) => item['id'].toString() == newsId);
  }

  void fixRepostCommentsDuplication(List<dynamic> news) {
    for (int i = 0; i < news.length; i++) {
      final newsItem = Map<String, dynamic>.from(news[i]);

      if (newsItem['is_repost'] == true && newsItem['repost_comment'] != null) {
        final repostComment = newsItem['repost_comment'].toString();
        final comments = List<Map<String, dynamic>>.from(newsItem['comments'] ?? []);

        final hasDuplicate = comments.any((comment) {
          final commentText = comment['text']?.toString() ?? '';
          return commentText == repostComment;
        });

        if (hasDuplicate) {
          news[i] = {
            ...newsItem,
            'comments': [],
          };
          print('✅ Fixed repost comments duplication: ${newsItem['id']}');
        }
      }
    }
  }
}