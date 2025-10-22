// lib/services/content_manager.dart
import 'package:flutter/foundation.dart';
import '../providers/news_providers/news_provider.dart';
import '../providers/channel_posts_provider.dart';
import '../providers/articles_provider.dart';

class ContentManager {
  static final ContentManager _instance = ContentManager._internal();
  factory ContentManager() => _instance;
  ContentManager._internal();

  // Флаг для отслеживания создания контента
  bool _isCreatingContent = false;

  // Кэш для быстрого доступа к контенту
  final Map<String, Map<String, dynamic>> _contentCache = {};

  // Проверка валидности провайдеров
  bool _isProviderValid(ChangeNotifier provider) {
    return provider.hasListeners && !_isProviderDisposed(provider);
  }

  // Безопасная проверка disposed состояния
  bool _isProviderDisposed(ChangeNotifier provider) {
    try {
      // Пытаемся получить доступ к свойствам провайдера
      if (provider is NewsProvider) {
        return provider.isDisposed;
      }
      // Для других провайдеров используем общий подход
      return !provider.hasListeners;
    } catch (e) {
      // Если возникает ошибка при доступе, вероятно провайдер disposed
      return true;
    }
  }

  // Безопасное выполнение операций с провайдером
  void _safeProviderOperation(String operation, Function() action) {
    try {
      action();
    } catch (e) {
      print('❌ Error during $operation: $e');
      rethrow;
    }
  }

  // Обновление кэша
  void _updateCache(String contentId, Map<String, dynamic> content) {
    _contentCache[contentId] = Map<String, dynamic>.from(content);
  }

  // Очистка кэша
  void _clearCache() {
    _contentCache.clear();
  }

  // Получение из кэша
  Map<String, dynamic>? _getFromCache(String contentId) {
    return _contentCache[contentId];
  }

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

    // Проверка валидности провайдеров
    if (!_isProviderValid(newsProvider)) {
      print('❌ NewsProvider is not valid (disposed)');
      return;
    }

    if (isChannelPost && channelPostsProvider != null && !_isProviderValid(channelPostsProvider)) {
      print('❌ ChannelPostsProvider is not valid (disposed)');
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

      // Валидация данных
      if (!validateContentData(preparedPost, contentType: isChannelPost ? 'channel_post' : 'post')) {
        print('❌ Content validation failed');
        return;
      }

      // Добавляем только в NewsProvider для обычных постов
      // Или в ChannelPostsProvider для канальных постов
      if (isChannelPost && channelPostsProvider != null && channelId != null) {
        final channelIdInt = int.tryParse(channelId) ?? 0;
        if (channelIdInt > 0) {
          _safeProviderOperation('channel post creation', () {
            channelPostsProvider.addPostToChannel(channelIdInt, preparedPost);
          });
          print('✅ Channel post created in ChannelPostsProvider: $uniqueId for channel $channelId');
        } else {
          print('❌ Invalid channel ID: $channelId');
        }
      } else {
        // Для обычных постов
        await newsProvider.addNews(preparedPost);
        print('✅ Regular post created in NewsProvider: $uniqueId');
      }

      // Обновляем кэш
      _updateCache(uniqueId, preparedPost);

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
      // Проверка валидности провайдеров
      if (!_isProviderValid(newsProvider)) {
        print('❌ NewsProvider is not valid (disposed)');
        return;
      }

      switch (contentType) {
        case 'post':
          _safeProviderOperation('post deletion', () {
            final index = newsProvider.findNewsIndexById(contentId);
            if (index != -1) {
              newsProvider.removeNews(index);
              _contentCache.remove(contentId); // Удаляем из кэша
              print('✅ Post deleted from NewsProvider: $contentId');
            } else {
              print('❌ Post not found in NewsProvider: $contentId');
            }
          });
          break;

        case 'channel_post':
          if (channelPostsProvider != null && channelId != null) {
            if (!_isProviderValid(channelPostsProvider)) {
              print('❌ ChannelPostsProvider is not valid (disposed)');
              return;
            }

            _safeProviderOperation('channel post deletion', () {
              final channelIdInt = int.tryParse(channelId) ?? 0;
              if (channelIdInt > 0) {
                channelPostsProvider.removePost(channelIdInt, contentId);
                _contentCache.remove(contentId); // Удаляем из кэша
                print('✅ Channel post deleted from ChannelPostsProvider: $contentId');
              } else {
                print('❌ Invalid channel ID for deletion: $channelId');
              }
            });
          } else {
            print('❌ ChannelPostsProvider or channelId not provided for channel post deletion');
          }
          break;

        case 'article':
          if (articlesProvider != null) {
            if (!_isProviderValid(articlesProvider)) {
              print('❌ ArticlesProvider is not valid (disposed)');
              return;
            }

            _safeProviderOperation('article deletion', () {
              // TODO: Implement article deletion when ArticlesProvider is available
              _contentCache.remove(contentId); // Удаляем из кэша
              print('⚠️ Article deletion not implemented yet');
            });
          }
          break;

        default:
          print('❌ Unknown content type: $contentType');
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
      // Проверка валидности провайдеров
      if (!_isProviderValid(newsProvider)) {
        print('❌ NewsProvider is not valid (disposed)');
        return;
      }

      switch (contentType) {
        case 'post':
          _safeProviderOperation('post update', () {
            final index = newsProvider.findNewsIndexById(contentId);
            if (index != -1) {
              newsProvider.updateNews(index, updates);
              _updateCache(contentId, {...newsProvider.news[index], ...updates});
              print('✅ Post updated in NewsProvider: $contentId');
            } else {
              print('❌ Post not found in NewsProvider: $contentId');
            }
          });
          break;

        case 'channel_post':
          if (channelPostsProvider != null && channelId != null) {
            if (!_isProviderValid(channelPostsProvider)) {
              print('❌ ChannelPostsProvider is not valid (disposed)');
              return;
            }

            _safeProviderOperation('channel post update', () {
              final channelIdInt = int.tryParse(channelId) ?? 0;
              if (channelIdInt > 0) {
                channelPostsProvider.updatePost(channelIdInt, contentId, updates);
                // Обновляем кэш
                final updatedPost = channelPostsProvider.getPostFromChannel(channelIdInt, contentId);
                if (updatedPost != null) {
                  _updateCache(contentId, updatedPost);
                }
                print('✅ Channel post updated in ChannelPostsProvider: $contentId');
              } else {
                print('❌ Invalid channel ID for update: $channelId');
              }
            });
          } else {
            print('❌ ChannelPostsProvider or channelId not provided for channel post update');
          }
          break;

        case 'article':
          if (articlesProvider != null) {
            if (!_isProviderValid(articlesProvider)) {
              print('❌ ArticlesProvider is not valid (disposed)');
              return;
            }

            _safeProviderOperation('article update', () {
              // TODO: Implement article update when ArticlesProvider is available
              print('⚠️ Article update not implemented yet');
            });
          }
          break;

        default:
          print('❌ Unknown content type: $contentType');
          break;
      }

    } catch (e) {
      print('❌ Error updating content: $e');
      rethrow;
    }
  }

  // Получение контента по ID (с кэшированием)
  Map<String, dynamic>? getContentById({
    required String contentId,
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    required String contentType,
    String? channelId,
  }) {
    // Сначала проверяем кэш
    final cachedContent = _getFromCache(contentId);
    if (cachedContent != null) {
      print('📦 Using cached content: $contentId');
      return cachedContent;
    }

    try {
      // Проверка валидности провайдеров
      if (!_isProviderValid(newsProvider)) {
        print('❌ NewsProvider is not valid (disposed)');
        return null;
      }

      Map<String, dynamic>? result;

      switch (contentType) {
        case 'post':
          result = _safeProviderOperationWithResult('get post', () {
            final index = newsProvider.findNewsIndexById(contentId);
            if (index != -1) {
              final content = Map<String, dynamic>.from(newsProvider.news[index]);
              _updateCache(contentId, content); // Кэшируем результат
              return content;
            }
            return null;
          });
          break;

        case 'channel_post':
          if (channelPostsProvider != null && channelId != null) {
            if (!_isProviderValid(channelPostsProvider)) {
              print('❌ ChannelPostsProvider is not valid (disposed)');
              return null;
            }

            result = _safeProviderOperationWithResult('get channel post', () {
              final channelIdInt = int.tryParse(channelId) ?? 0;
              if (channelIdInt > 0) {
                final content = channelPostsProvider.getPostFromChannel(channelIdInt, contentId);
                if (content != null) {
                  _updateCache(contentId, content); // Кэшируем результат
                }
                return content;
              }
              return null;
            });
          }
          break;

        case 'article':
          if (articlesProvider != null) {
            if (!_isProviderValid(articlesProvider)) {
              print('❌ ArticlesProvider is not valid (disposed)');
              return null;
            }

            result = _safeProviderOperationWithResult('get article', () {
              final article = articlesProvider.articles.firstWhere(
                    (article) => article['id'] == contentId,
                orElse: () => {},
              );
              if (article.isNotEmpty) {
                final content = Map<String, dynamic>.from(article);
                _updateCache(contentId, content); // Кэшируем результат
                return content;
              }
              return null;
            });
          }
          break;

        default:
          print('❌ Unknown content type: $contentType');
          break;
      }

      if (result == null) {
        print('❌ Content not found: $contentId (type: $contentType)');
      }

      return result;
    } catch (e) {
      print('❌ Error getting content: $e');
      return null;
    }
  }

  // Вспомогательный метод для безопасного выполнения операций с возвратом результата
  T? _safeProviderOperationWithResult<T>(String operation, T? Function() action) {
    try {
      return action();
    } catch (e) {
      print('❌ Error during $operation: $e');
      return null;
    }
  }

  // НОВЫЙ МЕТОД: Получение всех постов канала
  List<Map<String, dynamic>> getChannelPosts({
    required ChannelPostsProvider channelPostsProvider,
    required int channelId,
  }) {
    if (!_isProviderValid(channelPostsProvider)) {
      print('❌ ChannelPostsProvider is not valid (disposed)');
      return [];
    }

    return _safeProviderOperationWithResult('get channel posts', () {
      return channelPostsProvider.getChannelPosts(channelId);
    }) ?? [];
  }

  // НОВЫЙ МЕТОД: Поиск контента
  List<Map<String, dynamic>> searchContent({
    required String query,
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    List<String> contentTypes = const ['post', 'article', 'channel_post'],
  }) {
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    try {
      // Проверка валидности основного провайдера
      if (!_isProviderValid(newsProvider)) {
        print('❌ NewsProvider is not valid (disposed)');
        return results;
      }

      if (contentTypes.contains('post')) {
        _safeProviderOperation('post search', () {
          results.addAll(
              newsProvider.news.where((post) {
                final title = post['title']?.toString().toLowerCase() ?? '';
                final description = post['description']?.toString().toLowerCase() ?? '';
                final content = post['content']?.toString().toLowerCase() ?? '';
                return title.contains(lowerQuery) ||
                    description.contains(lowerQuery) ||
                    content.contains(lowerQuery);
              }).map((post) => {
                ...Map<String, dynamic>.from(post),
                'content_type': 'post'
              })
          );
        });
      }

      if (contentTypes.contains('article') && articlesProvider != null) {
        if (_isProviderValid(articlesProvider)) {
          _safeProviderOperation('article search', () {
            results.addAll(
                articlesProvider.articles.where((article) {
                  final title = article['title']?.toString().toLowerCase() ?? '';
                  final description = article['description']?.toString().toLowerCase() ?? '';
                  final content = article['content']?.toString().toLowerCase() ?? '';
                  return title.contains(lowerQuery) ||
                      description.contains(lowerQuery) ||
                      content.contains(lowerQuery);
                }).map((article) => {
                  ...Map<String, dynamic>.from(article),
                  'content_type': 'article'
                })
            );
          });
        }
      }

      if (contentTypes.contains('channel_post') && channelPostsProvider != null) {
        if (_isProviderValid(channelPostsProvider)) {
          _safeProviderOperation('channel post search', () {
            final allChannelPosts = channelPostsProvider.getAllPosts();
            results.addAll(
                allChannelPosts.where((post) {
                  final title = post['title']?.toString().toLowerCase() ?? '';
                  final description = post['description']?.toString().toLowerCase() ?? '';
                  final content = post['content']?.toString().toLowerCase() ?? '';
                  return title.contains(lowerQuery) ||
                      description.contains(lowerQuery) ||
                      content.contains(lowerQuery);
                }).map((post) => {
                  ...Map<String, dynamic>.from(post),
                  'content_type': 'channel_post'
                })
            );
          });
        }
      }

    } catch (e) {
      print('❌ Error searching content: $e');
    }

    return results;
  }

  // НОВЫЙ МЕТОД: Получение статистики контента
  Map<String, int> getContentStats({
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
  }) {
    final stats = <String, int>{
      'posts': 0,
      'articles': 0,
      'channel_posts': 0,
    };

    try {
      // Проверка валидности провайдеров
      if (_isProviderValid(newsProvider)) {
        stats['posts'] = newsProvider.news.length;
      }

      if (articlesProvider != null && _isProviderValid(articlesProvider)) {
        stats['articles'] = articlesProvider.articles.length;
      }

      if (channelPostsProvider != null && _isProviderValid(channelPostsProvider)) {
        stats['channel_posts'] = channelPostsProvider.getTotalPostsCount();
      }

      stats['total'] = stats.values.fold(0, (sum, value) => sum + value);

    } catch (e) {
      print('❌ Error getting content stats: $e');
    }

    return stats;
  }

  // НОВЫЙ МЕТОД: Очистка всего контента (для тестирования)
  Future<void> clearAllContent({
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
  }) async {
    try {
      // Проверка валидности провайдеров
      if (!_isProviderValid(newsProvider)) {
        print('❌ NewsProvider is not valid (disposed)');
        return;
      }

      // Очищаем новости
      _safeProviderOperation('clear news', () {
        while (newsProvider.news.isNotEmpty) {
          newsProvider.removeNews(0);
        }
      });

      // Очищаем посты каналов
      if (channelPostsProvider != null && _isProviderValid(channelPostsProvider)) {
        _safeProviderOperation('clear channel posts', () {
          channelPostsProvider.clearAllPosts();
        });
      }

      // Очищаем статьи
      if (articlesProvider != null && _isProviderValid(articlesProvider)) {
        _safeProviderOperation('clear articles', () {
          // TODO: Implement articles clearing when ArticlesProvider is available
          print('⚠️ Articles clearing not implemented yet');
        });
      }

      // Очищаем кэш
      _clearCache();

      print('✅ All content cleared successfully');
    } catch (e) {
      print('❌ Error clearing all content: $e');
      rethrow;
    }
  }

  // НОВЫЙ МЕТОД: Валидация данных контента
  bool validateContentData(Map<String, dynamic> data, {String contentType = 'post'}) {
    try {
      // Обязательные поля для всех типов контента
      if (data['title'] == null || data['title'].toString().trim().isEmpty) {
        print('❌ Content validation failed: Title is required');
        return false;
      }

      if (data['description'] == null || data['description'].toString().trim().isEmpty) {
        print('❌ Content validation failed: Description is required');
        return false;
      }

      // Дополнительные проверки в зависимости от типа контента
      switch (contentType) {
        case 'post':
          if (data['content'] == null || data['content'].toString().trim().isEmpty) {
            print('❌ Post validation failed: Content is required');
            return false;
          }
          break;

        case 'article':
          if (data['content'] == null || data['content'].toString().trim().isEmpty) {
            print('❌ Article validation failed: Content is required');
            return false;
          }
          if (data['category'] == null || data['category'].toString().trim().isEmpty) {
            print('❌ Article validation failed: Category is required');
            return false;
          }
          break;

        case 'channel_post':
          if (data['channel_id'] == null) {
            print('❌ Channel post validation failed: Channel ID is required');
            return false;
          }
          break;
      }

      return true;
    } catch (e) {
      print('❌ Content validation error: $e');
      return false;
    }
  }

  // НОВЫЙ МЕТОД: Проверка существования контента
  bool contentExists({
    required String contentId,
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    required String contentType,
    String? channelId,
  }) {
    return getContentById(
      contentId: contentId,
      newsProvider: newsProvider,
      channelPostsProvider: channelPostsProvider,
      articlesProvider: articlesProvider,
      contentType: contentType,
      channelId: channelId,
    ) != null;
  }

  // НОВЫЙ МЕТОД: Получение общего количества контента
  int getTotalContentCount({
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
  }) {
    final stats = getContentStats(
      newsProvider: newsProvider,
      channelPostsProvider: channelPostsProvider,
      articlesProvider: articlesProvider,
    );
    return stats['total'] ?? 0;
  }

  // НОВЫЙ МЕТОД: Получение популярного контента
  List<Map<String, dynamic>> getPopularContent({
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    int minLikes = 10,
    int limit = 10,
  }) {
    final allContent = <Map<String, dynamic>>[];

    try {
      if (_isProviderValid(newsProvider)) {
        allContent.addAll(
            newsProvider.news.where((post) => (post['likes'] ?? 0) >= minLikes)
                .map((post) => {...Map<String, dynamic>.from(post), 'content_type': 'post'})
        );
      }

      if (channelPostsProvider != null && _isProviderValid(channelPostsProvider)) {
        final popularChannelPosts = channelPostsProvider.getAllPosts()
            .where((post) => (post['likes'] ?? 0) >= minLikes)
            .map((post) => {...Map<String, dynamic>.from(post), 'content_type': 'channel_post'});
        allContent.addAll(popularChannelPosts);
      }

      // Сортируем по количеству лайков
      allContent.sort((a, b) => (b['likes'] ?? 0).compareTo(a['likes'] ?? 0));

      // Ограничиваем количество
      return allContent.take(limit).toList();
    } catch (e) {
      print('❌ Error getting popular content: $e');
      return [];
    }
  }

  // НОВЫЙ МЕТОД: Получение свежего контента
  List<Map<String, dynamic>> getRecentContent({
    required NewsProvider newsProvider,
    ChannelPostsProvider? channelPostsProvider,
    ArticlesProvider? articlesProvider,
    int hours = 24,
    int limit = 20,
  }) {
    final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
    final allContent = <Map<String, dynamic>>[];

    try {
      if (_isProviderValid(newsProvider)) {
        allContent.addAll(
            newsProvider.news.where((post) {
              final createdAt = DateTime.tryParse(post['created_at'] ?? '');
              return createdAt != null && createdAt.isAfter(cutoffTime);
            }).map((post) => {...Map<String, dynamic>.from(post), 'content_type': 'post'})
        );
      }

      if (channelPostsProvider != null && _isProviderValid(channelPostsProvider)) {
        final recentChannelPosts = channelPostsProvider.getAllPosts()
            .where((post) {
          final createdAt = DateTime.tryParse(post['created_at'] ?? '');
          return createdAt != null && createdAt.isAfter(cutoffTime);
        })
            .map((post) => {...Map<String, dynamic>.from(post), 'content_type': 'channel_post'});
        allContent.addAll(recentChannelPosts);
      }

      // Сортируем по дате (сначала новые)
      allContent.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      // Ограничиваем количество
      return allContent.take(limit).toList();
    } catch (e) {
      print('❌ Error getting recent content: $e');
      return [];
    }
  }

  // НОВЫЙ МЕТОД: Очистка устаревшего кэша
  void clearExpiredCache({int maxAgeHours = 1}) {
    final cutoffTime = DateTime.now().subtract(Duration(hours: maxAgeHours));
    final keysToRemove = <String>[];

    _contentCache.forEach((key, value) {
      final cachedAt = value['_cached_at'];
      if (cachedAt is String) {
        final cacheTime = DateTime.tryParse(cachedAt);
        if (cacheTime == null || cacheTime.isBefore(cutoffTime)) {
          keysToRemove.add(key);
        }
      }
    });

    for (final key in keysToRemove) {
      _contentCache.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      print('🧹 Cleared ${keysToRemove.length} expired cache entries');
    }
  }
}