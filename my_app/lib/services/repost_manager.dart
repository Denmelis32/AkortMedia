// lib/services/repost_manager.dart
import 'package:flutter/material.dart';
import 'package:my_app/providers/news_provider.dart';
import 'package:my_app/services/storage_service.dart';
import 'package:my_app/services/interaction_manager.dart';

class RepostManager {
  static final RepostManager _instance = RepostManager._internal();
  factory RepostManager() => _instance;
  RepostManager._internal();

  // Колбэки для обновления UI
  VoidCallback? _onRepostStateChanged;
  Function(String, bool, int)? _onRepostUpdated;

  // Инициализация менеджера
  void initialize({
    VoidCallback? onRepostStateChanged,
    Function(String, bool, int)? onRepostUpdated,
  }) {
    _onRepostStateChanged = onRepostStateChanged;
    _onRepostUpdated = onRepostUpdated;
    print('✅ RepostManager initialized');
  }

  // Основной метод для создания репоста
  Future<void> createRepost({
    required NewsProvider newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
  }) async {
    try {
      final originalNews = Map<String, dynamic>.from(newsProvider.news[originalIndex]);
      final originalNewsId = originalNews['id'].toString();

      print('🔄 [DEBUG] Starting repost creation:');
      print('   Original news ID: $originalNewsId');
      print('   Current user: $currentUserName ($currentUserId)');

      // Проверяем, не существует ли уже репост
      final existingRepostId = getRepostIdForOriginal(newsProvider, originalNewsId, currentUserId);
      if (existingRepostId != null) {
        print('⚠️ [DEBUG] Repost already exists: $existingRepostId');
        return;
      }

      // Создаем уникальный ID для репоста
      final repostId = 'repost-${DateTime.now().millisecondsSinceEpoch}-$currentUserId';

      // Получаем аватар текущего пользователя
      final currentUserAvatar = _getCurrentUserAvatarUrl(newsProvider, currentUserId);

      // Создаем данные репоста
      final repostData = await _createRepostData(
        originalNews: originalNews,
        repostId: repostId,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
      );

      // Детальная проверка данных перед добавлением
      print('🔄 [DEBUG] Repost data before adding:');
      print('   repost_comment: "${repostData['repost_comment']}"');
      print('   comments count: ${(repostData['comments'] as List).length}');
      print('   comments: ${repostData['comments']}');

      // Добавляем репост в провайдер
      _addRepostToProvider(newsProvider, repostData);

      // ВЫЗЫВАЕМ ПРОВЕРКУ СРАЗУ ПОСЛЕ ДОБАВЛЕНИЯ
      _verifyRepostCreation(newsProvider, repostId);

      // Сохраняем информацию о репосте
      await _saveRepostInfo(currentUserId, repostId, originalNewsId);

      // Обновляем состояние в InteractionManager
      _updateInteractionManager(originalNewsId, true);

      // Уведомляем UI об изменении
      _notifyRepostStateChanged();

      // Очищаем возможные дубликаты после создания репоста
      await cleanupDuplicateRepostComments(newsProvider);

      print('✅ [DEBUG] Repost successfully created: $repostId');

    } catch (e) {
      print('❌ [DEBUG] Error creating repost: $e');
      rethrow;
    }
  }

  // Метод для отмены репоста
  Future<void> cancelRepost({
    required NewsProvider newsProvider,
    required String repostId,
    required String currentUserId,
  }) async {
    try {
      // Находим индекс репоста
      final repostIndex = newsProvider.news.indexWhere((item) =>
      item['id'].toString() == repostId &&
          item['is_repost'] == true);

      if (repostIndex != -1) {
        // Получаем original_post_id перед удалением
        final originalPostId = newsProvider.news[repostIndex]['original_post_id']?.toString();

        // Удаляем репост из провайдера
        newsProvider.removeNews(repostIndex);

        // Удаляем из хранилища
        await StorageService.removeRepost(currentUserId, repostId);

        // Обновляем состояние в InteractionManager
        if (originalPostId != null) {
          _updateInteractionManager(originalPostId, false);
        }

        // Уведомляем UI об изменении
        _notifyRepostStateChanged();

        // Очищаем возможные дубликаты после отмены репоста
        await cleanupDuplicateRepostComments(newsProvider);

        print('✅ Репост отменен: $repostId');
      }
    } catch (e) {
      print('❌ Ошибка при отмене репоста: $e');
      rethrow;
    }
  }

  // Переключение состояния репоста (создать/отменить)
  Future<void> toggleRepost({
    required NewsProvider newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
  }) async {
    try {
      final originalNews = Map<String, dynamic>.from(newsProvider.news[originalIndex]);
      final originalNewsId = originalNews['id'].toString();

      print('🔄 [DEBUG] Toggling repost for: $originalNewsId');

      // Проверяем, не делал ли уже пользователь репост этой новости
      final existingRepostId = getRepostIdForOriginal(newsProvider, originalNewsId, currentUserId);

      if (existingRepostId != null) {
        // Отменяем существующий репост
        print('🔄 [DEBUG] Canceling existing repost: $existingRepostId');
        await cancelRepost(
          newsProvider: newsProvider,
          repostId: existingRepostId,
          currentUserId: currentUserId,
        );
      } else {
        // Создаем новый репост
        print('🔄 [DEBUG] Creating new repost');
        await createRepost(
          newsProvider: newsProvider,
          originalIndex: originalIndex,
          currentUserId: currentUserId,
          currentUserName: currentUserName,
        );
      }
    } catch (e) {
      print('❌ [DEBUG] Error toggling repost: $e');
      rethrow;
    }
  }

  // НОВЫЙ МЕТОД: Получение ID репоста для оригинального поста
  String? getRepostIdForOriginal(NewsProvider newsProvider, String originalNewsId, String userId) {
    try {
      final repost = newsProvider.news.firstWhere((item) {
        final newsItem = Map<String, dynamic>.from(item);
        return newsItem['is_repost'] == true &&
            newsItem['reposted_by'] == userId &&
            newsItem['original_post_id'] == originalNewsId;
      });

      return repost['id'].toString();
    } catch (e) {
      return null;
    }
  }

  // Получение репостов пользователя
  List<dynamic> getUserReposts(NewsProvider newsProvider, String userId) {
    return newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['is_repost'] == true &&
          newsItem['reposted_by'] == userId;
    }).toList();
  }

  // Проверка, является ли пост репостом пользователя
  bool isNewsRepostedByUser(NewsProvider newsProvider, String newsId, String userId) {
    return newsProvider.news.any((item) {
      final newsItem = Map<String, dynamic>.from(item);
      final isRepost = newsItem['is_repost'] == true;
      final isRepostedByUser = newsItem['reposted_by'] == userId;
      final isOriginalPost = newsItem['original_post_id'] == newsId;

      return isRepost && isRepostedByUser && isOriginalPost;
    });
  }

  // Вспомогательные методы

  String _getCurrentUserAvatarUrl(NewsProvider newsProvider, String userId) {
    final userProfile = newsProvider.getUserProfile(userId);

    if (userProfile?.profileImageFile != null) {
      return userProfile!.profileImageFile!.path;
    } else if (userProfile?.profileImageUrl != null &&
        userProfile!.profileImageUrl!.isNotEmpty) {
      return userProfile.profileImageUrl!;
    } else {
      return _getFallbackAvatarUrl(userProfile?.userName ?? 'Пользователь');
    }
  }

  String _getFallbackAvatarUrl(String userName) {
    final avatars = [
      'assets/images/ava_news/ava1.png',
      'assets/images/ava_news/ava2.png',
      'assets/images/ava_news/ava3.png',
      'assets/images/ava_news/ava4.png',
      'assets/images/ava_news/ava5.png',
      'assets/images/ava_news/ava6.png',
      'assets/images/ava_news/ava7.png',
      'assets/images/ava_news/ava8.png',
      'assets/images/ava_news/ava9.png',
      'assets/images/ava_news/ava10.png',
      'assets/images/ava_news/ava11.png',
      'assets/images/ava_news/ava12.png',
    ];

    final index = userName.hashCode.abs() % avatars.length;
    return avatars[index];
  }

  // ОСНОВНОЙ МЕТОД ДЛЯ СОЗДАНИЯ ДАННЫХ РЕПОСТА
  Future<Map<String, dynamic>> _createRepostData({
    required Map<String, dynamic> originalNews,
    required String repostId,
    required String currentUserId,
    required String currentUserName,
    required String currentUserAvatar,
  }) async {
    final originalAuthorName = originalNews['author_name']?.toString() ?? 'Пользователь';
    final originalAuthorAvatar = originalNews['author_avatar']?.toString() ?? '';
    final originalChannelName = originalNews['channel_name']?.toString() ?? '';
    final isOriginalChannelPost = originalNews['is_channel_post'] == true;

    print('🔄 [DEBUG] Creating regular repost data:');
    print('   Original author: $originalAuthorName');
    print('   Original channel: $originalChannelName');
    print('   Is channel post: $isOriginalChannelPost');

    return {
      'id': repostId,
      'original_post_id': originalNews['id'].toString(),
      'is_repost': true,
      'reposted_by': currentUserId,
      'reposted_by_name': currentUserName,
      'reposted_at': DateTime.now().toIso8601String(),

      // Данные оригинального поста
      'original_author_name': originalAuthorName,
      'original_author_avatar': originalAuthorAvatar,
      'original_channel_name': originalChannelName,
      'is_original_channel_post': isOriginalChannelPost,

      // Контент поста (копируем из оригинала)
      'title': originalNews['title'] ?? '',
      'description': originalNews['description'] ?? '',
      'image': originalNews['image'] ?? '',
      'hashtags': List<String>.from(originalNews['hashtags'] ?? []),

      // Автор репоста (текущий пользователь)
      'author_name': currentUserName,
      'author_avatar': currentUserAvatar,

      // Метаданные
      'created_at': DateTime.now().toIso8601String(),
      'likes': 0,
      'comments': [], // ВАЖНО: пустой массив комментариев
      'user_tags': <String, String>{},
      'isLiked': false,
      'isBookmarked': false,
      'isFollowing': false,
      'tag_color': _generateColorFromId(repostId).value,
      'is_channel_post': false, // Репост всегда обычный пост
      'content_type': 'repost',

      // Для обычных репостов комментарий репоста пустой
      'repost_comment': '',
    };
  }

  // МЕТОД ДЛЯ СОЗДАНИЯ ДАННЫХ РЕПОСТА С КОММЕНТАРИЕМ
  Future<Map<String, dynamic>> _createRepostDataWithComment({
    required Map<String, dynamic> originalNews,
    required String repostId,
    required String currentUserId,
    required String currentUserName,
    required String currentUserAvatar,
    required String comment,
  }) async {
    final originalAuthorName = originalNews['author_name']?.toString() ?? 'Пользователь';
    final originalAuthorAvatar = originalNews['author_avatar']?.toString() ?? '';
    final originalChannelName = originalNews['channel_name']?.toString() ?? '';
    final isOriginalChannelPost = originalNews['is_channel_post'] == true;

    print('🔄 [DEBUG] Creating repost with comment data:');
    print('   Comment: "$comment"');
    print('   Comment length: ${comment.length}');

    // ВАЖНОЕ ИСПРАВЛЕНИЕ: Гарантируем пустой массив комментариев
    return {
      'id': repostId,
      'original_post_id': originalNews['id'].toString(),
      'is_repost': true,
      'reposted_by': currentUserId,
      'reposted_by_name': currentUserName,
      'reposted_at': DateTime.now().toIso8601String(),
      'repost_comment': comment, // ТОЛЬКО здесь

      // Данные оригинального поста
      'original_author_name': originalAuthorName,
      'original_author_avatar': originalAuthorAvatar,
      'original_channel_name': originalChannelName,
      'is_original_channel_post': isOriginalChannelPost,

      // Контент поста
      'title': originalNews['title'] ?? '',
      'description': originalNews['description'] ?? '',
      'image': originalNews['image'] ?? '',
      'hashtags': List<String>.from(originalNews['hashtags'] ?? []),

      // Автор репоста (текущий пользователь)
      'author_name': currentUserName,
      'author_avatar': currentUserAvatar,

      'created_at': DateTime.now().toIso8601String(),
      'likes': 0,
      'comments': [], // ВАЖНО: ПУСТОЙ массив обычных комментариев
      'user_tags': <String, String>{},
      'isLiked': false,
      'isBookmarked': false,
      'isFollowing': false,
      'tag_color': _generateColorFromId(repostId).value,
      'is_channel_post': false,
      'content_type': 'repost',
    };
  }

  // Вспомогательный метод для определения типа контента
  String _getContentTypeFromNews(Map<String, dynamic> news) {
    final title = (news['title']?.toString() ?? '').toLowerCase();
    final description = (news['description']?.toString() ?? '').toLowerCase();

    if (title.contains('важн') || title.contains('срочн')) return 'important';
    if (title.contains('новость') || description.contains('новость')) return 'news';
    if (title.contains('спорт') || description.contains('спорт')) return 'sports';
    if (title.contains('техн') || description.contains('техн')) return 'tech';
    if (title.contains('развлеч') || description.contains('развлеч')) return 'entertainment';
    if (title.contains('образован') || description.contains('образован')) return 'education';

    return 'general';
  }

  void _addRepostToProvider(NewsProvider newsProvider, Map<String, dynamic> repostData) {
    try {
      final repostId = repostData['id'].toString();
      final isRepost = repostData['is_repost'] == true;
      final repostComment = repostData['repost_comment']?.toString() ?? '';

      print('🔄 [DEBUG] Adding repost to provider:');
      print('   Repost ID: $repostId');
      print('   Is repost: $isRepost');
      print('   Repost comment: "$repostComment"');
      print('   Comments array: ${repostData['comments']}');

      // ВАЖНОЕ ИСПРАВЛЕНИЕ: Принудительно очищаем комментарии для репостов
      final cleanRepostData = {
        ...repostData,
        'comments': [], // ГАРАНТИРУЕМ пустой массив для всех репостов
      };

      // Дополнительная проверка для репостов с комментариями
      if (isRepost && repostComment.isNotEmpty) {
        print('✅ [DEBUG] Ensuring empty comments for repost with comment');
        cleanRepostData['comments'] = [];
      }

      print('🔄 [DEBUG] Clean repost data:');
      print('   Comments array: ${cleanRepostData['comments']}');
      print('   Comments array length: ${(cleanRepostData['comments'] as List).length}');

      // Проверяем существование перед добавлением
      if (newsProvider.containsNews(repostId)) {
        print('❌ [DEBUG] Repost with ID $repostId already exists!');
        return;
      }

      // Добавляем через провайдер
      newsProvider.addNews(cleanRepostData);
      print('✅ [DEBUG] Repost successfully added to provider');

    } catch (e) {
      print('❌ [DEBUG] Error adding repost to provider: $e');
      rethrow;
    }
  }


  // В RepostManager добавьте метод для очистки существующих дубликатов
  Future<void> cleanupExistingRepostDuplicates(NewsProvider newsProvider) async {
    try {
      int cleanedCount = 0;

      for (int i = 0; i < newsProvider.news.length; i++) {
        final newsItem = Map<String, dynamic>.from(newsProvider.news[i]);

        if (newsItem['is_repost'] == true) {
          final repostComment = newsItem['repost_comment']?.toString() ?? '';
          final comments = List<Map<String, dynamic>>.from(newsItem['comments'] ?? []);

          // Если есть комментарий репоста И обычные комментарии - очищаем
          if (repostComment.isNotEmpty && comments.isNotEmpty) {
            print('❌ [CLEANUP] Found duplication in repost: ${newsItem['id']}');
            print('   Repost comment: "$repostComment"');
            print('   Regular comments: ${comments.length}');

            final cleanItem = {
              ...newsItem,
              'comments': [], // Очищаем обычные комментарии
            };

            newsProvider.updateNews(i, cleanItem);
            cleanedCount++;
            print('✅ [CLEANUP] Cleaned repost: ${newsItem['id']}');
          }
        }
      }

      if (cleanedCount > 0) {
        print('🎉 [CLEANUP] Cleaned $cleanedCount reposts with duplication');
      }
    } catch (e) {
      print('❌ [CLEANUP] Error cleaning duplicates: $e');
    }
  }

  // Метод для создания репоста с комментарием
  Future<void> createRepostWithComment({
    required NewsProvider newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
    required String comment,
  }) async {
    try {
      final originalNews = Map<String, dynamic>.from(newsProvider.news[originalIndex]);
      final originalNewsId = originalNews['id'].toString();

      print('🔄 [DEBUG] Starting repost with comment creation');
      print('   Original ID: $originalNewsId');
      print('   Comment: "$comment"');

      // Проверяем существующий репост
      final existingRepostId = getRepostIdForOriginal(newsProvider, originalNewsId, currentUserId);
      if (existingRepostId != null) {
        print('⚠️ [DEBUG] Repost already exists: $existingRepostId');
        await _updateExistingRepostComment(newsProvider, existingRepostId, comment);
        await cleanupDuplicateRepostComments(newsProvider);
        return;
      }

      // Создаем новый репост
      final repostId = 'repost-${DateTime.now().millisecondsSinceEpoch}-$currentUserId';
      final currentUserAvatar = _getCurrentUserAvatarUrl(newsProvider, currentUserId);

      final repostData = await _createRepostDataWithComment(
        originalNews: originalNews,
        repostId: repostId,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
        comment: comment,
      );

      // ДОБАВЛЯЕМ репост в провайдер
      _addRepostToProvider(newsProvider, repostData);

      // ВЫЗЫВАЕМ ПРОВЕРКУ СРАЗУ ПОСЛЕ ДОБАВЛЕНИЯ
      _verifyRepostCreation(newsProvider, repostId);

      await _saveRepostInfo(currentUserId, repostId, originalNewsId);
      _updateInteractionManager(originalNewsId, true);
      _notifyRepostStateChanged();
      await cleanupDuplicateRepostComments(newsProvider);

      print('✅ [DEBUG] Repost with comment created: $repostId');

    } catch (e) {
      print('❌ [DEBUG] Error creating repost with comment: $e');
      rethrow;
    }
  }

  // Метод для обновления комментария существующего репоста
  Future<void> _updateExistingRepostComment(NewsProvider newsProvider, String repostId, String comment) async {
    try {
      final repostIndex = newsProvider.news.indexWhere((item) => item['id'].toString() == repostId);
      if (repostIndex != -1) {
        final repost = Map<String, dynamic>.from(newsProvider.news[repostIndex]);

        // ВАЖНОЕ ИСПРАВЛЕНИЕ: Обновляем ТОЛЬКО комментарий репоста, не трогая обычные комментарии
        final updatedRepost = {
          ...repost,
          'repost_comment': comment, // Обновляем только комментарий репоста
          // Обычные комментарии остаются без изменений
        };

        // Обновляем новость в провайдере
        newsProvider.updateNews(repostIndex, updatedRepost);

        // ВЫЗЫВАЕМ ПРОВЕРКУ ПОСЛЕ ОБНОВЛЕНИЯ
        _verifyRepostCreation(newsProvider, repostId);

        print('✅ Updated comment for existing repost: $repostId');
        print('   New comment: "$comment"');
        print('   Regular comments count: ${(updatedRepost['comments'] as List).length}');
      }
    } catch (e) {
      print('❌ Error updating existing repost comment: $e');
    }
  }

  // Метод для очистки дублирующихся комментариев
  Future<void> cleanupDuplicateRepostComments(NewsProvider newsProvider) async {
    try {
      int cleanedCount = 0;
      int fixedCount = 0;

      for (int i = 0; i < newsProvider.news.length; i++) {
        final newsItem = Map<String, dynamic>.from(newsProvider.news[i]);

        // Проверяем только репосты
        if (newsItem['is_repost'] == true) {
          final repostComment = newsItem['repost_comment']?.toString();
          final comments = List<Map<String, dynamic>>.from(newsItem['comments'] ?? []);

          print('🔄 [DEBUG] Checking repost: ${newsItem['id']}');
          print('   Repost comment: "$repostComment"');
          print('   Comments count: ${comments.length}');

          // Если есть комментарий репоста И обычные комментарии - это дублирование
          if (repostComment != null && repostComment.isNotEmpty && comments.isNotEmpty) {
            print('❌ [DEBUG] Found duplication in repost: ${newsItem['id']}');
            print('   Will clean ${comments.length} comments');

            // Очищаем обычные комментарии
            final updatedNews = {
              ...newsItem,
              'comments': [], // Полностью очищаем
            };

            newsProvider.updateNews(i, updatedNews);
            cleanedCount += comments.length;
            fixedCount++;

            print('✅ [DEBUG] Cleaned repost: ${newsItem['id']}');
          }

          // Дополнительная проверка: ищем комментарии, совпадающие с repost_comment
          final duplicateComments = comments.where((comment) {
            final commentText = comment['text']?.toString() ?? '';
            return commentText == repostComment;
          }).toList();

          if (duplicateComments.isNotEmpty) {
            print('❌ [DEBUG] Found ${duplicateComments.length} exact duplicates');

            final cleanedComments = comments.where((comment) {
              final commentText = comment['text']?.toString() ?? '';
              return commentText != repostComment;
            }).toList();

            if (cleanedComments.length < comments.length) {
              final updatedNews = {
                ...newsItem,
                'comments': cleanedComments,
              };

              newsProvider.updateNews(i, updatedNews);
              cleanedCount += (comments.length - cleanedComments.length);
              fixedCount++;

              print('✅ [DEBUG] Removed ${comments.length - cleanedComments.length} exact duplicates');
            }
          }
        }
      }

      if (cleanedCount > 0 || fixedCount > 0) {
        print('🎉 [DEBUG] Cleanup completed:');
        print('   Fixed reposts: $fixedCount');
        print('   Removed comments: $cleanedCount');
      } else {
        print('✅ [DEBUG] No duplicates found');
      }
    } catch (e) {
      print('❌ [DEBUG] Error cleaning duplicate repost comments: $e');
    }
  }

  // Метод для проверки создания репоста
  void _verifyRepostCreation(NewsProvider newsProvider, String repostId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = newsProvider.findNewsIndexById(repostId);
      if (index != -1) {
        final repost = Map<String, dynamic>.from(newsProvider.news[index]);
        print('🔍 [VERIFICATION] Repost verification:');
        print('   ID: ${repost['id']}');
        print('   repost_comment: "${repost['repost_comment']}"');
        print('   comments count: ${(repost['comments'] as List).length}');
        print('   comments: ${repost['comments']}');

        // Проверяем на дублирование
        final repostComment = repost['repost_comment']?.toString();
        final comments = List<Map<String, dynamic>>.from(repost['comments'] ?? []);

        if (repostComment != null && repostComment.isNotEmpty && comments.isNotEmpty) {
          print('❌ [VERIFICATION] DUPLICATION DETECTED!');

          // Немедленно исправляем
          final cleanRepost = {
            ...repost,
            'comments': [],
          };
          newsProvider.updateNews(index, cleanRepost);
          print('✅ [VERIFICATION] Immediately fixed duplication');
        } else {
          print('✅ [VERIFICATION] No duplication detected');
        }
      }
    });
  }

  void _showRepostUpdateSuccessSnackBar(String comment) {
    // Этот метод нужно будет вызвать из UI контекста
    print('✅ Repost comment updated: "$comment"');
  }

  Future<void> _saveRepostInfo(String userId, String repostId, String originalNewsId) async {
    await StorageService.addRepost(userId, repostId, originalNewsId);
  }

  void _updateInteractionManager(String originalPostId, bool isReposted) {
    final interactionManager = InteractionManager();
    final currentState = interactionManager.getPostState(originalPostId);

    if (currentState != null) {
      interactionManager.updateRepostState(
        postId: originalPostId,
        isReposted: isReposted,
        repostsCount: isReposted ? currentState.repostsCount + 1 : currentState.repostsCount - 1,
      );
    }
  }

  void _notifyRepostStateChanged() {
    _onRepostStateChanged?.call();
    _onRepostUpdated?.call('', false, 0); // Заглушка, можно адаптировать под конкретные нужды
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

  // Очистка ресурсов
  void dispose() {
    _onRepostStateChanged = null;
    _onRepostUpdated = null;
    print('🔴 RepostManager disposed');
  }
}