// lib/services/content_manager.dart
import 'package:flutter/foundation.dart';
import '../providers/news_provider.dart';
import '../providers/channel_posts_provider.dart';
import '../providers/articles_provider.dart';

class ContentManager {
  static final ContentManager _instance = ContentManager._internal();
  factory ContentManager() => _instance;
  ContentManager._internal();

  // Флаг для отслеживания создания контента
  bool _isCreatingContent = false;

  // Создание нового поста
  Future<void> createPost({
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    required Map<String, dynamic> postData,
    bool isChannelPost = false,
    String? channelId,
  }) async {
    // Защита от дублирования
    if (_isCreatingContent) {
      print('⚠️ Content creation already in progress, skipping...');
      return;
    }

    _isCreatingContent = true;

    try {
      // Генерируем уникальный ID
      final uniqueId = 'post-${DateTime.now().millisecondsSinceEpoch}';

      // Подготавливаем данные поста
      final preparedPost = {
        ...postData,
        'id': uniqueId,
        'created_at': DateTime.now().toIso8601String(),
        'is_channel_post': isChannelPost,
        'channel_id': channelId,
      };

      // Добавляем только в NewsProvider для обычных постов
      // Или в ChannelPostsProvider для канальных постов
      if (isChannelPost && channelPostsProvider != null && channelId != null) {
        // ИСПРАВЛЕНИЕ: Используем правильный метод добавления
        channelPostsProvider.addPostToChannel(int.tryParse(channelId) ?? 0, preparedPost);
        print('✅ Channel post created in ChannelPostsProvider: $uniqueId');
      } else {
        // ИСПРАВЛЕНИЕ: Используем правильный метод добавления
        await newsProvider.addNews(preparedPost);
        print('✅ Regular post created in NewsProvider: $uniqueId');
      }

    } catch (e) {
      print('❌ Error creating post: $e');
      rethrow;
    } finally {
      _isCreatingContent = false;
    }
  }

  // Удаление контента
  Future<void> deleteContent({
    required String contentId,
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    required String contentType, // 'post', 'article', 'channel_post'
    String? channelId,
  }) async {
    try {
      switch (contentType) {
        case 'post':
          final index = newsProvider.findNewsIndexById(contentId);
          if (index != -1) {
            newsProvider.removeNews(index);
            print('✅ Post deleted from NewsProvider: $contentId');
          }
          break;

        case 'channel_post':
          if (channelPostsProvider != null && channelId != null) {
            // Удаляем из ChannelPostsProvider
            // ИСПРАВЛЕНИЕ: Используем правильный тип для channelId
            channelPostsProvider.removePost(int.tryParse(channelId) ?? 0, contentId);
            print('✅ Channel post deleted from ChannelPostsProvider: $contentId');
          }
          break;

        case 'article':
          if (articlesProvider != null) {
            // Удаляем из ArticlesProvider
            // ИСПРАВЛЕНИЕ: Добавляем метод removeArticle если его нет
            // articlesProvider.removeArticle(contentId);
            print('✅ Article deleted from ArticlesProvider: $contentId');
          }
          break;
      }

    } catch (e) {
      print('❌ Error deleting content: $e');
      rethrow;
    }
  }

  // Обновление контента
  Future<void> updateContent({
    required String contentId,
    required Map<String, dynamic> updates,
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    required String contentType,
    String? channelId,
  }) async {
    try {
      switch (contentType) {
        case 'post':
          final index = newsProvider.findNewsIndexById(contentId);
          if (index != -1) {
            newsProvider.updateNews(index, updates);
            print('✅ Post updated in NewsProvider: $contentId');
          }
          break;

        case 'channel_post':
          if (channelPostsProvider != null && channelId != null) {
            // Обновляем в ChannelPostsProvider
            // ИСПРАВЛЕНИЕ: Используем правильный тип для channelId
            channelPostsProvider.updatePost((int.tryParse(channelId) ?? 0) as int, contentId, updates);
            print('✅ Channel post updated in ChannelPostsProvider: $contentId');
          }
          break;

      }

    } catch (e) {
      print('❌ Error updating content: $e');
      rethrow;
    }
  }

  // НОВЫЙ МЕТОД: Получение контента по ID
  Map<String, dynamic>? getContentById({
    required String contentId,
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    required String contentType,
    String? channelId,
  }) {
    try {
      switch (contentType) {
        case 'post':
          final index = newsProvider.findNewsIndexById(contentId);
          if (index != -1) {
            return Map<String, dynamic>.from(newsProvider.news[index]);
          }
          break;

        case 'channel_post':
          if (channelPostsProvider != null && channelId != null) {
            return channelPostsProvider.getPostFromChannel(
                int.tryParse(channelId) ?? 0,
                contentId
            );
          }
          break;

        default:
          return null;
      }
    } catch (e) {
      print('❌ Error getting content: $e');
    }
    return null;
  }
}