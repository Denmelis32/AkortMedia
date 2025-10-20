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
      // БЕЗОПАСНОЕ ПОЛУЧЕНИЕ ОРИГИНАЛЬНОЙ НОВОСТИ
      if (originalIndex < 0 || originalIndex >= newsProvider.news.length) {
        print('❌ [DEBUG] Invalid original index: $originalIndex');
        return;
      }

      final originalNews = Map<String, dynamic>.from(newsProvider.news[originalIndex]);
      final originalNewsId = originalNews['id']?.toString();

      if (originalNewsId == null || originalNewsId.isEmpty) {
        print('❌ [DEBUG] Original news ID is null or empty');
        return;
      }

      print('🔄 [DEBUG] Starting repost creation:');
      print('   Original news ID: $originalNewsId');
      print('   Current user: $currentUserName ($currentUserId)');
      print('   Is channel post: ${originalNews['is_channel_post']}');
      print('   Channel name: ${originalNews['channel_name']}');
      print('   Original index: $originalIndex');
      print('   Total news count: ${newsProvider.news.length}');

      // ПРОВЕРЯЕМ ДАННЫЕ ОРИГИНАЛЬНОЙ НОВОСТИ
      print('🔍 [DEBUG] Original news data:');
      print('   ID: ${originalNews['id']}');
      print('   Title: ${originalNews['title']}');
      print('   Author: ${originalNews['author_name']}');
      print('   Has channel data: ${originalNews.containsKey('channel_name')}');
      print('   Channel ID: ${originalNews['channel_id']}');

      // Проверяем, не существует ли уже репост
      final existingRepostId = getRepostIdForOriginal(newsProvider, originalNewsId, currentUserId);
      if (existingRepostId != null) {
        print('⚠️ [DEBUG] Repost already exists: $existingRepostId');
        return;
      }

      // СОЗДАЕМ УНИКАЛЬНЫЙ ID ДЛЯ РЕПОСТА
      final repostId = 'repost-${DateTime.now().millisecondsSinceEpoch}-$currentUserId';
      print('✅ [DEBUG] Generated repost ID: $repostId');

      // ПОЛУЧАЕМ АВАТАР ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ
      final currentUserAvatar = _getCurrentUserAvatarUrl(newsProvider, currentUserId);
      print('✅ [DEBUG] Current user avatar: $currentUserAvatar');

      // СОЗДАЕМ ДАННЫЕ РЕПОСТА
      final repostData = await _createRepostData(
        originalNews: originalNews,
        repostId: repostId,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
      );

      // ПОДРОБНАЯ ОТЛАДКА ДАННЫХ РЕПОСТА
      _debugRepostData(repostData);

      // ПРОВЕРЯЕМ КРИТИЧЕСКИЕ ПОЛЯ ПЕРЕД ДОБАВЛЕНИЕМ
      final criticalFields = ['id', 'original_post_id', 'reposted_by', 'author_name', 'is_repost'];
      bool hasAllCriticalFields = true;

      for (final field in criticalFields) {
        if (!repostData.containsKey(field) || repostData[field] == null) {
          print('❌ [DEBUG] MISSING CRITICAL FIELD: $field');
          hasAllCriticalFields = false;
        }
      }

      if (!hasAllCriticalFields) {
        print('❌ [DEBUG] Cannot create repost - missing critical fields');
        return;
      }

      // ДОБАВЛЯЕМ РЕПОСТ В ПРОВАЙДЕР
      print('🔄 [DEBUG] Adding repost to provider...');
      _addRepostToProvider(newsProvider, repostData);

      // ВЫЗЫВАЕМ ПРОВЕРКУ СРАЗУ ПОСЛЕ ДОБАВЛЕНИЯ
      _verifyRepostCreation(newsProvider, repostId);

      // СОХРАНЯЕМ ИНФОРМАЦИЮ О РЕПОСТЕ
      print('🔄 [DEBUG] Saving repost info...');
      await _saveRepostInfo(currentUserId, repostId, originalNewsId);

      // ОБНОВЛЯЕМ СОСТОЯНИЕ В INTERACTION MANAGER
      print('🔄 [DEBUG] Updating interaction manager...');
      _updateInteractionManager(originalNewsId, true);

      // УВЕДОМЛЯЕМ UI ОБ ИЗМЕНЕНИИ
      print('🔄 [DEBUG] Notifying UI...');
      _notifyRepostStateChanged();

      // ОЧИЩАЕМ ВОЗМОЖНЫЕ ДУБЛИКАТЫ ПОСЛЕ СОЗДАНИЯ РЕПОСТА
      print('🔄 [DEBUG] Cleaning up duplicates...');
      await cleanupDuplicateRepostComments(newsProvider);

      // ФИНАЛЬНАЯ ПРОВЕРКА
      final finalIndex = newsProvider.findNewsIndexById(repostId);
      if (finalIndex != -1) {
        final finalRepost = Map<String, dynamic>.from(newsProvider.news[finalIndex]);
        print('🎉 [DEBUG] Repost successfully created and verified:');
        print('   Final index: $finalIndex');
        print('   Final ID: ${finalRepost['id']}');
        print('   Is repost: ${finalRepost['is_repost']}');
        print('   Author: ${finalRepost['author_name']}');
      } else {
        print('❌ [DEBUG] Repost not found after creation!');
      }

      print('✅ [DEBUG] Repost creation completed successfully: $repostId');

    } catch (e, stackTrace) {
      print('❌ [DEBUG] Error creating repost: $e');
      print('❌ [DEBUG] Stack trace: $stackTrace');
      print('❌ [DEBUG] Error context:');
      print('   Original index: $originalIndex');
      print('   Current user: $currentUserName ($currentUserId)');
      print('   News provider length: ${newsProvider.news.length}');
      rethrow;
    }
  }

  // Метод для детальной отладки данных репоста
  void _debugRepostData(Map<String, dynamic> repostData) {
    print('🔍 [DEBUG] === REPOST DATA DEBUG INFO ===');

    // ОСНОВНЫЕ ПОЛЯ
    print('📋 BASIC FIELDS:');
    print('   ID: ${repostData['id']}');
    print('   Original Post ID: ${repostData['original_post_id']}');
    print('   Is Repost: ${repostData['is_repost']}');
    print('   Reposted By: ${repostData['reposted_by']}');
    print('   Reposted By Name: ${repostData['reposted_by_name']}');
    print('   Author Name: ${repostData['author_name']}');
    print('   Author Avatar: ${repostData['author_avatar']}');

    // ДАННЫЕ ОРИГИНАЛЬНОГО ПОСТА
    print('📋 ORIGINAL POST DATA:');
    print('   Original Author: ${repostData['original_author_name']}');
    print('   Original Author Avatar: ${repostData['original_author_avatar']}');
    print('   Original Channel: ${repostData['original_channel_name']}');
    print('   Original Channel ID: ${repostData['original_channel_id']}');
    print('   Original Channel Avatar: ${repostData['original_channel_avatar']}'); // ✅ УБРАТЬ ДУБЛИКАТ
    print('   Is Original Channel Post: ${repostData['is_original_channel_post']}');

    // КОНТЕНТ
    print('📋 CONTENT:');
    print('   Title: "${repostData['title']}"');
    print('   Description: "${repostData['description']?.toString().length} chars"');
    print('   Image: ${repostData['image']}');
    print('   Hashtags: ${repostData['hashtags']}');

    // МЕТАДАННЫЕ
    print('📋 METADATA:');
    print('   Created At: ${repostData['created_at']}');
    print('   Reposted At: ${repostData['reposted_at']}');
    print('   Likes: ${repostData['likes']}');
    print('   Comments Count: ${(repostData['comments'] as List).length}');
    print('   Repost Comment: "${repostData['repost_comment']}"');
    print('   Tag Color: ${repostData['tag_color']}');
    print('   Is Channel Post: ${repostData['is_channel_post']}');
    print('   Content Type: ${repostData['content_type']}');

    // ПРОВЕРКА ОБЯЗАТЕЛЬНЫХ ПОЛЕЙ
    print('🔍 REQUIRED FIELDS CHECK:');
    final requiredFields = {
      'id': 'string',
      'original_post_id': 'string',
      'is_repost': 'boolean',
      'reposted_by': 'string',
      'reposted_by_name': 'string',
      'author_name': 'string',
      'comments': 'list'
    };

    bool allFieldsValid = true;
    requiredFields.forEach((field, type) {
      final hasField = repostData.containsKey(field);
      final fieldValue = repostData[field];
      final isValid = hasField && fieldValue != null;

      if (isValid) {
        print('   ✅ $field: $fieldValue');
      } else {
        print('   ❌ $field: MISSING OR NULL');
        allFieldsValid = false;
      }
    });

    print('📊 VALIDATION RESULT: ${allFieldsValid ? "PASSED" : "FAILED"}');
    print('🔍 [DEBUG] === END REPOST DATA DEBUG ===');
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
    try {
      final originalAuthorName = originalNews['author_name']?.toString() ?? 'Пользователь';
      final originalAuthorAvatar = originalNews['author_avatar']?.toString() ?? '';
      final originalChannelName = originalNews['channel_name']?.toString() ?? '';
      final isOriginalChannelPost = originalNews['is_channel_post'] == true;
      final originalChannelId = originalNews['channel_id']?.toString() ?? '';
      final originalChannelAvatar = originalNews['channel_avatar']?.toString() ?? '';

      print('🔄 [DEBUG] Creating regular repost data:');
      print('   Original author: $originalAuthorName');
      print('   Original channel: $originalChannelName');
      print('   Is channel post: $isOriginalChannelPost');
      print('   Channel ID: $originalChannelId');

      // БАЗОВЫЕ ДАННЫЕ РЕПОСТА
      final repostData = {
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
        'original_channel_id': originalChannelId,
        'original_channel_avatar': originalChannelAvatar, // ✅ УБРАТЬ ДУБЛИКАТ
        'is_original_channel_post': isOriginalChannelPost,

        // Контент поста (копируем из оригинала)
        'title': originalNews['title']?.toString() ?? '',
        'description': originalNews['description']?.toString() ?? '',
        'image': originalNews['image']?.toString() ?? '',
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

      // ДОБАВЛЯЕМ ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ ДЛЯ КАНАЛЬНЫХ ПОСТОВ
      if (isOriginalChannelPost) {
        repostData.addAll({
          'original_created_at': originalNews['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          'channel_subscribers': originalNews['channel_subscribers'] ?? 0,
          'channel_videos': originalNews['channel_videos'] ?? 0,
        });
      }

      print('✅ [DEBUG] Repost data created successfully');
      print('   Has all required fields: ${repostData.containsKey('original_channel_id')}');

      return repostData;

    } catch (e) {
      print('❌ [DEBUG] Error creating repost data: $e');
      rethrow;
    }
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
    try {
      final originalAuthorName = originalNews['author_name']?.toString() ?? 'Пользователь';
      final originalAuthorAvatar = originalNews['author_avatar']?.toString() ?? '';
      final originalChannelName = originalNews['channel_name']?.toString() ?? '';
      final isOriginalChannelPost = originalNews['is_channel_post'] == true;
      final originalChannelId = originalNews['channel_id']?.toString() ?? '';
      final originalChannelAvatar = originalNews['channel_avatar']?.toString() ?? '';

      print('🔄 [DEBUG] Creating repost with comment data:');
      print('   Comment: "$comment"');
      print('   Comment length: ${comment.length}');
      print('   Is channel post: $isOriginalChannelPost');

      // БАЗОВЫЕ ДАННЫЕ РЕПОСТА С КОММЕНТАРИЕМ
      final repostData = {
        'id': repostId,
        'original_post_id': originalNews['id'].toString(),
        'is_repost': true,
        'reposted_by': currentUserId,
        'reposted_by_name': currentUserName,
        'reposted_at': DateTime.now().toIso8601String(),
        'repost_comment': comment, // ВАЖНО: комментарий репоста

        // Данные оригинального поста
        'original_author_name': originalAuthorName,
        'original_author_avatar': originalAuthorAvatar,
        'original_channel_name': originalChannelName,
        'original_channel_id': originalChannelId,
        'original_channel_avatar': originalChannelAvatar,
        'is_original_channel_post': isOriginalChannelPost,

        // Контент поста
        'title': originalNews['title']?.toString() ?? '',
        'description': originalNews['description']?.toString() ?? '',
        'image': originalNews['image']?.toString() ?? '',
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

      // ДОБАВЛЯЕМ ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ ДЛЯ КАНАЛЬНЫХ ПОСТОВ
      if (isOriginalChannelPost) {
        repostData.addAll({
          'original_created_at': originalNews['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          'channel_subscribers': originalNews['channel_subscribers'] ?? 0,
          'channel_videos': originalNews['channel_videos'] ?? 0,
        });
      }

      print('✅ [DEBUG] Repost with comment data created successfully');
      print('   repost_comment field: "${repostData['repost_comment']}"');

      return repostData;

    } catch (e) {
      print('❌ [DEBUG] Error creating repost with comment data: $e');
      rethrow;
    }
  }

  // УДАЛИТЬ ДУБЛИРУЮЩИЙСЯ МЕТОД - ОСТАВИТЬ ТОЛЬКО ОДИН ИЗ НИХ
  /*
  // Вспомогательный метод для безопасного копирования данных поста
  Map<String, dynamic> _safeCopyNewsData(Map<String, dynamic> originalNews) {
    final copiedData = <String, dynamic>{};

    // Копируем все поля с проверкой на null
    originalNews.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          copiedData[key] = List.from(value);
        } else if (value is Map) {
          copiedData[key] = Map<String, dynamic>.from(value);
        } else {
          copiedData[key] = value;
        }
      } else {
        // Устанавливаем значения по умолчанию для null полей
        copiedData[key] = _getDefaultValueForKey(key);
      }
    });

    return copiedData;
  }

  // Метод для получения значений по умолчанию
  dynamic _getDefaultValueForKey(String key) {
    switch (key) {
      case 'title':
      case 'description':
      case 'author_name':
      case 'author_avatar':
      case 'channel_name':
      case 'channel_avatar':
      case 'original_author_name':
      case 'original_author_avatar':
      case 'original_channel_name':
      case 'original_channel_avatar':
        return '';
      case 'likes':
      case 'reposts':
      case 'channel_subscribers':
      case 'channel_videos':
        return 0;
      case 'isLiked':
      case 'isBookmarked':
      case 'isFollowing':
      case 'is_repost':
      case 'is_channel_post':
      case 'is_original_channel_post':
        return false;
      case 'hashtags':
      case 'comments':
        return [];
      case 'user_tags':
        return <String, String>{};
      default:
        return null;
    }
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
  */

  void _addRepostToProvider(NewsProvider newsProvider, Map<String, dynamic> repostData) {
    try {
      final repostId = repostData['id'].toString();
      final isRepost = repostData['is_repost'] == true;
      final repostComment = repostData['repost_comment']?.toString() ?? '';

      print('🔄 [REPOST MANAGER] _addRepostToProvider called');
      print('   Repost ID: $repostId');
      print('   Is repost: $isRepost');
      print('   Repost comment: "$repostComment"');
      print('   Comments array: ${repostData['comments']}');

      // ВАЛИДАЦИЯ ОБЯЗАТЕЛЬНЫХ ПОЛЕЙ
      final requiredFields = ['id', 'original_post_id', 'reposted_by', 'reposted_by_name', 'author_name', 'repost_comment'];
      for (final field in requiredFields) {
        if (!repostData.containsKey(field)) {
          print('❌ [REPOST MANAGER] Missing field: $field');
        } else if (repostData[field] == null) {
          print('⚠️ [REPOST MANAGER] Field $field is null');
        } else {
          print('✅ [REPOST MANAGER] Field $field: ${repostData[field]}');
        }
      }

      // ВАЖНОЕ ИСПРАВЛЕНИЕ: Сохраняем оригинальные данные, включая комментарий
      final cleanRepostData = {
        ...repostData, // Сохраняем ВСЕ оригинальные данные
        'comments': [], // ТОЛЬКО комментарии принудительно очищаем
      };

      // ПРОВЕРКА ДАННЫХ ПЕРЕД ДОБАВЛЕНИЕМ
      print('🔄 [REPOST MANAGER] Final repost data before adding:');
      print('   repost_comment: "${cleanRepostData['repost_comment']}"');
      print('   comments array: ${cleanRepostData['comments']}');
      print('   comments array length: ${(cleanRepostData['comments'] as List).length}');

      // Проверяем существование перед добавлением
      if (newsProvider.containsNews(repostId)) {
        print('❌ [REPOST MANAGER] Repost with ID $repostId already exists!');
        return;
      }

      // Добавляем через провайдер
      print('🔄 [REPOST MANAGER] Calling newsProvider.addNews...');
      newsProvider.addNews(cleanRepostData);
      print('✅ [REPOST MANAGER] Repost successfully added to provider');

    } catch (e) {
      print('❌ [REPOST MANAGER] Error adding repost to provider: $e');
      rethrow;
    }
  }

  // УДАЛИТЬ ДУБЛИРУЮЩИЙСЯ МЕТОД - ОСТАВИТЬ ТОЛЬКО ОДИН cleanupDuplicateRepostComments
  /*
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
  */

  // Метод для создания репоста с комментарием
  Future<void> createRepostWithComment({
    required NewsProvider newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
    required String comment,
  }) async {
    try {
      // БЕЗОПАСНОЕ ПОЛУЧЕНИЕ ОРИГИНАЛЬНОЙ НОВОСТИ
      if (originalIndex < 0 || originalIndex >= newsProvider.news.length) {
        print('❌ [DEBUG] Invalid original index: $originalIndex');
        return;
      }

      final originalNews = Map<String, dynamic>.from(newsProvider.news[originalIndex]);
      final originalNewsId = originalNews['id']?.toString();

      if (originalNewsId == null || originalNewsId.isEmpty) {
        print('❌ [DEBUG] Original news ID is null or empty');
        return;
      }

      print('🔄 [DEBUG] Starting repost with comment creation:');
      print('   Original news ID: $originalNewsId');
      print('   Comment: "$comment"');
      print('   Current user: $currentUserName ($currentUserId)');

      // Проверяем, не существует ли уже репост
      final existingRepostId = getRepostIdForOriginal(newsProvider, originalNewsId, currentUserId);
      if (existingRepostId != null) {
        print('⚠️ [DEBUG] Repost already exists: $existingRepostId');
        // Обновляем комментарий существующего репоста
        await _updateExistingRepostComment(newsProvider, existingRepostId, comment);
        await cleanupDuplicateRepostComments(newsProvider);
        return;
      }

      // СОЗДАЕМ УНИКАЛЬНЫЙ ID ДЛЯ РЕПОСТА
      final repostId = 'repost-${DateTime.now().millisecondsSinceEpoch}-$currentUserId';
      print('✅ [DEBUG] Generated repost ID: $repostId');

      // ПОЛУЧАЕМ АВАТАР ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ
      final currentUserAvatar = _getCurrentUserAvatarUrl(newsProvider, currentUserId);
      print('✅ [DEBUG] Current user avatar: $currentUserAvatar');

      // СОЗДАЕМ ДАННЫЕ РЕПОСТА С КОММЕНТАРИЕМ
      final repostData = await _createRepostDataWithComment(
        originalNews: originalNews,
        repostId: repostId,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
        comment: comment,
      );

      // ДОБАВЛЯЕМ РЕПОСТ В ПРОВАЙДЕР
      print('🔄 [DEBUG] Adding repost with comment to provider...');
      _addRepostToProvider(newsProvider, repostData);

      // ВЫЗЫВАЕМ ПРОВЕРКУ СРАЗУ ПОСЛЕ ДОБАВЛЕНИЯ
      _verifyRepostCreation(newsProvider, repostId);

      // СОХРАНЯЕМ ИНФОРМАЦИЮ О РЕПОСТЕ
      print('🔄 [DEBUG] Saving repost info...');
      await _saveRepostInfo(currentUserId, repostId, originalNewsId);

      // ОБНОВЛЯЕМ СОСТОЯНИЕ В INTERACTION MANAGER
      print('🔄 [DEBUG] Updating interaction manager...');
      _updateInteractionManager(originalNewsId, true);

      // УВЕДОМЛЯЕМ UI ОБ ИЗМЕНЕНИИ
      print('🔄 [DEBUG] Notifying UI...');
      _notifyRepostStateChanged();

      // ОЧИЩАЕМ ВОЗМОЖНЫЕ ДУБЛИКАТЫ ПОСЛЕ СОЗДАНИЯ РЕПОСТА
      print('🔄 [DEBUG] Cleaning up duplicates...');
      await cleanupDuplicateRepostComments(newsProvider);

      // ФИНАЛЬНАЯ ПРОВЕРКА
      final finalIndex = newsProvider.findNewsIndexById(repostId);
      if (finalIndex != -1) {
        final finalRepost = Map<String, dynamic>.from(newsProvider.news[finalIndex]);
        print('🎉 [DEBUG] Repost with comment successfully created and verified:');
        print('   Final index: $finalIndex');
        print('   Final ID: ${finalRepost['id']}');
        print('   Is repost: ${finalRepost['is_repost']}');
        print('   Author: ${finalRepost['author_name']}');
        print('   Repost comment: "${finalRepost['repost_comment']}"');
      } else {
        print('❌ [DEBUG] Repost not found after creation!');
      }

      print('✅ [DEBUG] Repost with comment creation completed successfully: $repostId');

    } catch (e, stackTrace) {
      print('❌ [DEBUG] Error creating repost with comment: $e');
      print('❌ [DEBUG] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Метод для обновления комментария существующего репоста
  Future<void> _updateExistingRepostComment(NewsProvider newsProvider, String repostId, String comment) async {
    try {
      final repostIndex = newsProvider.news.indexWhere((item) => item['id'].toString() == repostId);
      if (repostIndex != -1) {
        final repost = Map<String, dynamic>.from(newsProvider.news[repostIndex]);

        // Обновляем только комментарий репоста
        final updatedRepost = {
          ...repost,
          'repost_comment': comment,
        };

        // Обновляем новость в провайдере
        newsProvider.updateNews(repostIndex, updatedRepost);

        // ВЫЗЫВАЕМ ПРОВЕРКУ ПОСЛЕ ОБНОВЛЕНИЯ
        _verifyRepostCreation(newsProvider, repostId);

        print('✅ Updated comment for existing repost: $repostId');
        print('   New comment: "$comment"');
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

  // В RepostManager замените метод _updateInteractionManager:
  void _updateInteractionManager(String originalPostId, bool isReposted) {
    try {
      final interactionManager = InteractionManager();
      final currentState = interactionManager.getPostState(originalPostId);

      if (currentState != null) {
        // ✅ ИСПРАВЛЕНИЕ: Не увеличиваем счетчик здесь, так как это сделает InteractionManager
        // Просто обновляем состояние репоста
        interactionManager.updateRepostState(
          postId: originalPostId,
          isReposted: isReposted,
          repostsCount: currentState.repostsCount, // ✅ Оставляем текущее значение
        );

        print('🔄 [DEBUG] InteractionManager updated for post: $originalPostId');
        print('   Is reposted: $isReposted');
        print('   Current reposts count: ${currentState.repostsCount}');
      } else {
        print('⚠️ [DEBUG] No post state found for: $originalPostId');
      }
    } catch (e) {
      print('❌ [DEBUG] Error updating InteractionManager: $e');
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