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
  // ОБНОВЛЕННЫЙ МЕТОД createRepost
  Future<void> createRepost({
    required NewsProvider newsProvider,
    required int originalIndex,
    required String currentUserId,
    required String currentUserName,
  }) async {
    try {
      final originalNews = Map<String, dynamic>.from(newsProvider.news[originalIndex]);
      final originalNewsId = originalNews['id'].toString();

      print('🔄 Starting repost creation:');
      print('   Original news ID: $originalNewsId');
      print('   Current user: $currentUserName ($currentUserId)');

      // Проверяем, не существует ли уже репост
      final existingRepostId = getRepostIdForOriginal(newsProvider, originalNewsId, currentUserId);
      if (existingRepostId != null) {
        print('⚠️ Repost already exists: $existingRepostId');
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

      // Логируем данные репоста для отладки
      print('📋 Repost data created:');
      print('   Repost ID: ${repostData['id']}');
      print('   Is repost: ${repostData['is_repost']}');
      print('   Reposted by: ${repostData['reposted_by_name']}');
      print('   Original author: ${repostData['original_author_name']}');
      print('   Original channel: ${repostData['original_channel_name']}');

      // Добавляем репост в провайдер
      _addRepostToProvider(newsProvider, repostData);

      // Сохраняем информацию о репосте
      await _saveRepostInfo(currentUserId, repostId, originalNewsId);

      // Обновляем состояние в InteractionManager
      _updateInteractionManager(originalNewsId, true);

      // Уведомляем UI об изменении
      _notifyRepostStateChanged();

      print('✅ Репост успешно создан: $repostId');

    } catch (e) {
      print('❌ Ошибка при создании репоста: $e');
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

      // Проверяем, не делал ли уже пользователь репост этой новости
      final existingRepostId = getRepostIdForOriginal(newsProvider, originalNewsId, currentUserId);

      if (existingRepostId != null) {
        // Отменяем существующий репост
        await cancelRepost(
          newsProvider: newsProvider,
          repostId: existingRepostId,
          currentUserId: currentUserId,
        );
      } else {
        // Создаем новый репост
        await createRepost(
          newsProvider: newsProvider,
          originalIndex: originalIndex,
          currentUserId: currentUserId,
          currentUserName: currentUserName,
        );
      }
    } catch (e) {
      print('❌ Ошибка при переключении репоста: $e');
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

  // В КЛАССЕ RepostManager, МЕТОД _createRepostData
  // В КЛАССЕ RepostManager, ОБНОВЛЕННЫЙ МЕТОД _createRepostData
  Future<Map<String, dynamic>> _createRepostData({
    required Map<String, dynamic> originalNews,
    required String repostId,
    required String currentUserId,
    required String currentUserName,
    required String currentUserAvatar,
  }) async {
    // Получаем данные оригинального автора
    final originalAuthorName = originalNews['author_name']?.toString() ?? 'Пользователь';
    final originalAuthorAvatar = originalNews['author_avatar']?.toString() ?? '';
    final originalChannelName = originalNews['channel_name']?.toString() ?? '';
    final isOriginalChannelPost = originalNews['is_channel_post'] == true;

    print('🔄 Creating repost data:');
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

      // ДАННЫЕ ОРИГИНАЛЬНОГО ПОСТА - ВАЖНО!
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
      'comments': [],
      'user_tags': <String, String>{},
      'isLiked': false,
      'isBookmarked': false,
      'isFollowing': false,
      'tag_color': _generateColorFromId(repostId).value,
      'is_channel_post': false, // Репост всегда обычный пост
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
    // Используем существующий метод addNews провайдера, но передаем context
    // Нужно получить context через другие средства или изменить метод
    newsProvider.addNews(repostData);

    // Альтернативно, можно добавить напрямую:
    // newsProvider.news.insert(0, repostData);
    // newsProvider.notifyListeners();
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