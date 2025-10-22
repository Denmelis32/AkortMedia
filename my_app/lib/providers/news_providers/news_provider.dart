// lib/providers/news_provider.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/providers/user_tags_provider.dart';
import 'package:provider/provider.dart';
import '../../../../services/api_service.dart';
import '../../pages/news_page/mock_news_data.dart';
import '../../services/interaction_manager.dart';
import '../../services/repost_manager.dart'; // НОВЫЙ ИМПОРТ
import '../../services/storage_service.dart';

// Модель профиля пользователя
class UserProfile {
  final String id;
  final String userName;
  final String userEmail;
  String? profileImageUrl;
  File? profileImageFile;
  String? coverImageUrl;
  File? coverImageFile;
  DateTime? registrationDate;
  Map<String, int> stats;

  UserProfile({
    required this.id,
    required this.userName,
    required this.userEmail,
    this.profileImageUrl,
    this.profileImageFile,
    this.coverImageUrl,
    this.coverImageFile,
    this.registrationDate,
    this.stats = const {},
  });

  UserProfile copyWith({
    String? userName,
    String? userEmail,
    String? profileImageUrl,
    File? profileImageFile,
    String? coverImageUrl,
    File? coverImageFile,
    Map<String, int>? stats,
  }) {
    return UserProfile(
      id: id,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImageFile: profileImageFile ?? this.profileImageFile,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverImageFile: coverImageFile ?? this.coverImageFile,
      registrationDate: registrationDate,
      stats: stats ?? this.stats,
    );
  }
}

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDisposed = false;
  bool get mounted => !_isDisposed;

  // НОВЫЕ ПОЛЯ ДЛЯ ПОДДЕРЖКИ MULTIPLE USERS
  final Map<String, UserProfile> _userProfiles = {};
  String? _currentUserId;

  // МЕНЕДЖЕРЫ
  final RepostManager _repostManager = RepostManager();
  final InteractionManager _interactionManager = InteractionManager();

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDisposed => _isDisposed;

  // ГЕТТЕРЫ ДЛЯ ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ
  String? get profileImageUrl => _getCurrentUser()?.profileImageUrl;
  File? get profileImageFile => _getCurrentUser()?.profileImageFile;
  String? get coverImageUrl => _getCurrentUser()?.coverImageUrl;
  File? get coverImageFile => _getCurrentUser()?.coverImageFile;

  NewsProvider() {
    _initializeManagers();
    print('✅ NewsProvider initialized with InteractionManager & RepostManager');
  }

  // ИНИЦИАЛИЗАЦИЯ МЕНЕДЖЕРОВ
  void _initializeManagers() {
    _initializeInteractionManager();
    _initializeRepostManager();
  }

  // В классе NewsProvider - ПРАВИЛЬНЫЙ метод:
  void _initializeInteractionManager() {
    _safeOperation(() {
      _interactionManager.setCallbacks(
        onLike: (postId, isLiked, likesCount) {
          if (_isDisposed) return;

          print('🔄 NewsProvider: Like callback received - postId: $postId, isLiked: $isLiked, likesCount: $likesCount');

          // Синхронизируем состояние
          syncPostStateFromInteractionManager(postId);
        },
        onBookmark: (postId, isBookmarked) {
          if (_isDisposed) return;

          print('🔄 NewsProvider: Bookmark callback received - postId: $postId, isBookmarked: $isBookmarked');

          // Синхронизируем состояние
          syncPostStateFromInteractionManager(postId);
        },
        onRepost: (postId, isReposted, repostsCount, userId, userName) {
          if (_isDisposed) return;

          print('🔄 NewsProvider: Repost callback received - postId: $postId, isReposted: $isReposted, repostsCount: $repostsCount');

          // Синхронизируем состояние
          syncPostStateFromInteractionManager(postId);

          // Дополнительная логика для репостов
          if (isReposted) {
            final index = findNewsIndexById(postId);
            if (index != -1) {
              _repostManager.createRepost(
                newsProvider: this,
                originalIndex: index,
                currentUserId: userId,
                currentUserName: userName,
              );
            }
          } else {
            final repostId = _repostManager.getRepostIdForOriginal(this, postId, userId);
            if (repostId != null) {
              _repostManager.cancelRepost(
                newsProvider: this,
                repostId: repostId,
                currentUserId: userId,
              );
            }
          }
        },
        onComment: (postId, comment) {
          if (_isDisposed) return;

          print('🔄 NewsProvider: Comment callback received - postId: $postId');

          // Синхронизируем состояние
          syncPostStateFromInteractionManager(postId);

          // Дополнительная логика для комментариев
          addCommentToNews(postId, comment);
        },
        onCommentRemoval: (postId, commentId) {
          if (_isDisposed) return;

          print('🔄 NewsProvider: Comment removal callback received - postId: $postId, commentId: $commentId');

          // Синхронизируем состояние
          syncPostStateFromInteractionManager(postId);

          // Дополнительная логика для удаления комментариев
          final index = findNewsIndexById(postId);
          if (index != -1) {
            removeCommentFromNews(index, commentId);
          }
        },
      );

      // Выполняем первоначальную синхронизацию
      WidgetsBinding.instance.addPostFrameCallback((_) {
        syncAllPostsFromInteractionManager();
      });

      print('✅ InteractionManager callbacks initialized with full synchronization');
    });
  }






  // В класс NewsProvider добавьте:

  /// Принудительная синхронизация конкретного поста
  void forceSyncPost(String postId) {
    syncPostStateFromInteractionManager(postId);
  }

  /// Принудительная синхронизация всех постов
  void forceSyncAllPosts() {
    syncAllPostsFromInteractionManager();
  }

  /// Синхронизация при обновлении UI
  void syncOnUIUpdate() {
    if (_isDisposed) return;

    // Синхронизируем только видимые посты для производительности
    final visiblePostIds = _news.take(50).map((post) => post['id'].toString()).toList();

    for (final postId in visiblePostIds) {
      final interactionState = _interactionManager.getPostState(postId);
      if (interactionState != null) {
        final index = findNewsIndexById(postId);
        if (index != -1) {
          final currentNews = _news[index];
          if (currentNews['isLiked'] != interactionState.isLiked ||
              currentNews['likes'] != interactionState.likesCount ||
              currentNews['isBookmarked'] != interactionState.isBookmarked ||
              currentNews['comments'].length != interactionState.comments.length) {
            syncPostStateFromInteractionManager(postId);
          }
        }
      }
    }
  }


  void syncPostStateFromInteractionManager(String postId) {
    if (_isDisposed) return;

    final interactionState = _interactionManager.getPostState(postId);
    if (interactionState == null) {
      print('⚠️ No interaction state found for post: $postId');
      return;
    }

    final index = findNewsIndexById(postId);
    if (index != -1) {
      print('🔄 Syncing post state from InteractionManager: $postId');
      print('   Likes: ${interactionState.likesCount}, Liked: ${interactionState.isLiked}');
      print('   Bookmarks: ${interactionState.isBookmarked}');
      print('   Reposts: ${interactionState.repostsCount}, Reposted: ${interactionState.isReposted}');
      print('   Comments: ${interactionState.comments.length}');

      _news[index] = {
        ..._news[index],
        'isLiked': interactionState.isLiked,
        'likes': interactionState.likesCount,
        'isBookmarked': interactionState.isBookmarked,
        'isReposted': interactionState.isReposted,
        'reposts': interactionState.repostsCount,
        'comments': interactionState.comments,
      };

      _safeNotifyListeners();
      _saveNewsToStorage();

      print('✅ Successfully synced post state for: $postId');
    } else {
      print('❌ Post not found for sync: $postId');
    }
  }








  void syncAllPostsFromInteractionManager() {
    if (_isDisposed) return;

    print('🔄 Starting full sync of all posts from InteractionManager');
    int syncedCount = 0;

    for (final postId in _interactionManager.getAllPostIds()) {
      final index = findNewsIndexById(postId);
      if (index != -1) {
        syncPostStateFromInteractionManager(postId);
        syncedCount++;
      }
    }

    print('✅ Full sync completed: $syncedCount posts synchronized');
  }

  void _initializeRepostManager() {
    _repostManager.initialize(
      onRepostStateChanged: () {
        _safeNotifyListeners();
      },
      onRepostUpdated: (postId, isReposted, repostsCount) {
        final index = findNewsIndexById(postId);
        if (index != -1) {
          updateNewsRepostStatus(index, isReposted, repostsCount);
        }
      },
    );
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ УПРАВЛЕНИЯ ПОЛЬЗОВАТЕЛЯМИ
  void setCurrentUser(String userId, String userName, String userEmail) {
    _currentUserId = userId;

    // Создаем профиль если не существует
    if (!_userProfiles.containsKey(userId)) {
      _userProfiles[userId] = UserProfile(
        id: userId,
        userName: userName,
        userEmail: userEmail,
        registrationDate: DateTime.now(),
        stats: {},
      );

      // Загружаем данные профиля из хранилища
      _loadUserProfileData(userId);
    }

    _safeNotifyListeners();
  }

  UserProfile? _getCurrentUser() {
    if (_currentUserId == null) return null;
    return _userProfiles[_currentUserId!];
  }

  UserProfile? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  String? getCurrentUserId() {
    return _currentUserId;
  }

  // ОБНОВЛЕННЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С ПРОФИЛЕМ
  Future<void> updateProfileImageUrl(String? url) async {
    if (_isDisposed || _currentUserId == null) {
      print('❌ [PROVIDER] Cannot update profile: disposed=$_isDisposed, userId=$_currentUserId');
      return;
    }

    final user = _userProfiles[_currentUserId!];
    if (user == null) {
      print('❌ [PROVIDER] User not found: $_currentUserId');
      return;
    }

    print('🔄 [PROVIDER] Updating profile image URL for user $_currentUserId: $url');

    // Валидация URL
    String? validatedUrl = url;
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (!uri.hasScheme) {
          validatedUrl = 'https://$url';
          print('   🔧 Added https scheme: $validatedUrl');
        }

        // Проверяем доступность изображения
        print('   🔍 Checking image availability...');
        final response = await http.head(Uri.parse(validatedUrl!));
        if (response.statusCode != 200) {
          print('❌ [PROVIDER] Image URL not accessible: ${response.statusCode}');
          throw Exception('Изображение недоступно: ${response.statusCode}');
        }
        print('   ✅ Image is accessible');
      } catch (e) {
        print('❌ [PROVIDER] Invalid image URL: $e');
        throw Exception('Некорректная ссылка на изображение: $e');
      }
    }

    // ОБНОВЛЯЕМ ДАННЫЕ В ПАМЯТИ
    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageUrl: validatedUrl,
      profileImageFile: null, // Очищаем файл при установке URL
    );

    print('✅ [PROVIDER] Profile image updated in memory');

    // НЕМЕДЛЕННОЕ уведомление слушателей
    _safeNotifyListeners();

    // Сохранение в хранилище
    try {
      await StorageService.saveProfileImageUrl(_currentUserId!, validatedUrl);
      print('✅ [PROVIDER] Profile image URL saved to storage');
    } catch (e) {
      print('❌ [PROVIDER] Error saving to storage: $e');
    }

    // Дополнительная проверка
    final updatedUser = _userProfiles[_currentUserId!];
    print('🔍 [PROVIDER] Verification - current profile image: ${updatedUser?.profileImageUrl}');

    // ПРИНУДИТЕЛЬНАЯ ПЕРЕЗАГРУЗКА ДАННЫХ
    await _loadUserProfileData(_currentUserId!);
  }


  Future<void> updateProfileImageFile(File? file) async {
    if (_isDisposed || _currentUserId == null) {
      print('❌ [PROVIDER] Cannot update profile file: disposed=$_isDisposed, userId=$_currentUserId');
      return;
    }

    final user = _userProfiles[_currentUserId!];
    if (user == null) {
      print('❌ [PROVIDER] User not found: $_currentUserId');
      return;
    }

    print('🔄 [PROVIDER] Updating profile image FILE for user $_currentUserId: ${file?.path}');

    // ОБНОВЛЯЕМ ДАННЫЕ В ПАМЯТИ
    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageFile: file,
      profileImageUrl: null, // Очищаем URL при установке файла
    );

    print('✅ [PROVIDER] Profile image file updated in memory');

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        try {
          await StorageService.saveProfileImageFilePath(_currentUserId!, file.path);
          print('✅ [PROVIDER] Profile image file saved to storage: ${file.path}');
        } catch (e) {
          print('❌ [PROVIDER] Error saving file path: $e');
        }
      } else {
        print('❌ [PROVIDER] File does not exist: ${file.path}');
        _userProfiles[_currentUserId!] = user.copyWith(profileImageFile: null);
      }
    } else {
      await StorageService.saveProfileImageFilePath(_currentUserId!, null);
      print('✅ [PROVIDER] Profile image file removed from storage');
    }

    // НЕМЕДЛЕННОЕ уведомление
    _safeNotifyListeners();

    // Дополнительная проверка
    final updatedUser = _userProfiles[_currentUserId!];
    print('🔍 [PROVIDER] Verification - current profile file: ${updatedUser?.profileImageFile?.path}');

    // ПРИНУДИТЕЛЬНАЯ ПЕРЕЗАГРУЗКА ДАННЫХ
    await _loadUserProfileData(_currentUserId!);
  }
  // НОВЫЕ МЕТОДЫ ДЛЯ ОБЛОЖКИ
  Future<void> updateCoverImageUrl(String? url) async {
    if (_isDisposed || _currentUserId == null) {
      print('❌ [COVER] Cannot update cover: disposed=$_isDisposed, userId=$_currentUserId');
      return;
    }

    final user = _userProfiles[_currentUserId!];
    if (user == null) {
      print('❌ [COVER] User not found: $_currentUserId');
      return;
    }

    print('🔄 [COVER] Updating cover image URL for user $_currentUserId: $url');

    // Валидация URL
    String? validatedUrl = url;
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (!uri.hasScheme) {
          validatedUrl = 'https://$url';
          print('   🔧 Added https scheme: $validatedUrl');
        }

        // Проверяем доступность изображения
        print('   🔍 Checking cover image availability...');
        final response = await http.head(Uri.parse(validatedUrl!));
        if (response.statusCode != 200) {
          print('❌ [COVER] Cover URL not accessible: ${response.statusCode}');
          throw Exception('Обложка недоступна: ${response.statusCode}');
        }
        print('   ✅ Cover image is accessible');
      } catch (e) {
        print('❌ [COVER] Invalid cover URL: $e');
        throw Exception('Некорректная ссылка на обложку: $e');
      }
    }

    // ОБНОВЛЯЕМ ДАННЫЕ В ПАМЯТИ
    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageUrl: validatedUrl,
      coverImageFile: null, // Очищаем файл при установке URL
    );

    print('✅ [COVER] Cover image updated in memory');

    // НЕМЕДЛЕННОЕ уведомление слушателей
    _safeNotifyListeners();

    // Сохранение в хранилище
    try {
      await StorageService.saveCoverImageUrl(_currentUserId!, validatedUrl);
      print('✅ [COVER] Cover image URL saved to storage');
    } catch (e) {
      print('❌ [COVER] Error saving to storage: $e');
    }

    // Дополнительная проверка
    final updatedUser = _userProfiles[_currentUserId!];
    print('🔍 [COVER] Verification - current cover image: ${updatedUser?.coverImageUrl}');

    // ПРИНУДИТЕЛЬНАЯ ПЕРЕЗАГРУЗКА ДАННЫХ
    await _loadUserProfileData(_currentUserId!);
  }




  Future<void> updateCoverImageFile(File? file) async {
    if (_isDisposed || _currentUserId == null) {
      print('❌ [COVER] Cannot update cover file: disposed=$_isDisposed, userId=$_currentUserId');
      return;
    }

    final user = _userProfiles[_currentUserId!];
    if (user == null) {
      print('❌ [COVER] User not found: $_currentUserId');
      return;
    }

    print('🔄 [COVER] Updating cover image FILE for user $_currentUserId: ${file?.path}');

    // ОБНОВЛЯЕМ ДАННЫЕ В ПАМЯТИ
    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageFile: file,
      coverImageUrl: null, // Очищаем URL при установке файла
    );

    print('✅ [COVER] Cover image file updated in memory');

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        try {
          await StorageService.saveCoverImageFilePath(_currentUserId!, file.path);
          print('✅ [COVER] Cover image file saved to storage: ${file.path}');
        } catch (e) {
          print('❌ [COVER] Error saving file path: $e');
        }
      } else {
        print('❌ [COVER] File does not exist: ${file.path}');
        _userProfiles[_currentUserId!] = user.copyWith(coverImageFile: null);
      }
    } else {
      await StorageService.saveCoverImageFilePath(_currentUserId!, null);
      print('✅ [COVER] Cover image file removed from storage');
    }

    // НЕМЕДЛЕННОЕ уведомление
    _safeNotifyListeners();

    // Дополнительная проверка
    final updatedUser = _userProfiles[_currentUserId!];
    print('🔍 [COVER] Verification - current cover file: ${updatedUser?.coverImageFile?.path}');

    // ПРИНУДИТЕЛЬНАЯ ПЕРЕЗАГРУЗКА ДАННЫХ
    await _loadUserProfileData(_currentUserId!);
  }

  // Загрузка данных профиля пользователя
  // В NewsProvider - УЛУЧШЕННАЯ ЗАГРУЗКА
  Future<void> _loadUserProfileData(String userId) async {
    if (_isDisposed) return;

    try {
      print('🔄 [PROVIDER] Loading profile data for user: $userId');

      // Загружаем URL аватарки
      final savedUrl = await StorageService.loadProfileImageUrl(userId);
      print('📥 [PROVIDER] Loaded profile URL: $savedUrl');

      // Загружаем файл аватарки
      final savedFilePath = await StorageService.loadProfileImageFilePath(userId);
      File? profileFile;
      if (savedFilePath != null && savedFilePath.isNotEmpty) {
        final file = File(savedFilePath);
        if (await file.exists()) {
          profileFile = file;
          print('📥 [PROVIDER] Loaded profile file: ${file.path}');
        } else {
          await StorageService.saveProfileImageFilePath(userId, null);
          print('⚠️ [PROVIDER] Profile file not found, clearing path');
        }
      }

      // Загружаем обложку
      final savedCoverUrl = await StorageService.loadCoverImageUrl(userId);
      final savedCoverPath = await StorageService.loadCoverImageFilePath(userId);
      File? coverFile;
      if (savedCoverPath != null && savedCoverPath.isNotEmpty) {
        final file = File(savedCoverPath);
        if (await file.exists()) {
          coverFile = file;
          print('📥 [PROVIDER] Loaded cover file: ${file.path}');
        } else {
          await StorageService.saveCoverImageFilePath(userId, null);
          print('⚠️ [PROVIDER] Cover file not found, clearing path');
        }
      }

      // Обновляем профиль в памяти
      if (_userProfiles.containsKey(userId)) {
        _userProfiles[userId] = _userProfiles[userId]!.copyWith(
          profileImageUrl: savedUrl,
          profileImageFile: profileFile,
          coverImageUrl: savedCoverUrl,
          coverImageFile: coverFile,
        );

        print('✅ [PROVIDER] Profile data loaded successfully');
        print('🔍 [PROVIDER] Final state - Profile URL: $savedUrl, Profile File: ${profileFile?.path}');
        print('🔍 [PROVIDER] Final state - Cover URL: $savedCoverUrl, Cover File: ${coverFile?.path}');
      } else {
        print('❌ [PROVIDER] User profile not found in memory: $userId');
      }

      // УВЕДОМЛЯЕМ СЛУШАТЕЛЕЙ
      _safeNotifyListeners();

    } catch (e) {
      print('❌ [PROVIDER] Error loading profile data for user $userId: $e');
    }
  }

  // Безопасное уведомление слушателей
  void _safeNotifyListeners() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();
    }
  }

  // Безопасное выполнение операций
  void _safeOperation(Function() operation) {
    if (_isDisposed) {
      print('⚠️ NewsProvider is disposed, skipping operation');
      return;
    }
    operation();
  }

  void setLoading(bool loading) {
    _safeOperation(() {
      _isLoading = loading;
      _safeNotifyListeners();
    });
  }

  void setError(String? message) {
    _safeOperation(() {
      _errorMessage = message;
      _safeNotifyListeners();
    });
  }

  void clearData() {
    _safeOperation(() {
      _safeNotifyListeners();
    });
  }

  // Загрузка данных профиля для текущего пользователя
  Future<void> loadProfileData() async {
    if (_isDisposed || _currentUserId == null) return;

    try {
      await _loadUserProfileData(_currentUserId!);
      print('✅ Profile data loaded for current user: $_currentUserId');
    } catch (e) {
      print('❌ Error loading profile data: $e');
    }
  }

  // МЕТОД ДЛЯ СОХРАНЕНИЯ НОВОСТЕЙ В ХРАНИЛИЩЕ
  Future<void> _saveNewsToStorage() async {
    if (_isDisposed) return;

    try {
      print('💾 Автосохранение новостей...');
      await StorageService.saveNews(_news);
      print('✅ Новости сохранены в хранилище');
    } catch (e) {
      print('❌ Ошибка автосохранения новостей: $e');
    }
  }

  UserTagsProvider? _getUserTagsProvider(BuildContext context) {
    try {
      return Provider.of<UserTagsProvider>(context, listen: false);
    } catch (e) {
      print('⚠️ UserTagsProvider not available: $e');
      return null;
    }
  }

  // МЕТОДЫ ДЛЯ РЕПОСТА - ОБНОВЛЕННЫЕ С REPOST MANAGER
  void updateNewsRepostStatus(int index, bool isReposted, int repostsCount) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        _news[index]['isReposted'] = isReposted;
        _news[index]['reposts'] = repostsCount;
        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  // ОБНОВЛЕННЫЕ МЕТОДЫ РЕПОСТА ЧЕРЕЗ REPOST MANAGER
  Future<void> repostNews(int index, String currentUserId, String currentUserName) async {
    await _repostManager.createRepost(
      newsProvider: this,
      originalIndex: index,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
  }

  Future<void> cancelRepost(String repostId, String currentUserId) async {
    await _repostManager.cancelRepost(
      newsProvider: this,
      repostId: repostId,
      currentUserId: currentUserId,
    );
  }

  void toggleRepost(int index, String currentUserId, String currentUserName) {
    _repostManager.toggleRepost(
      newsProvider: this,
      originalIndex: index,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
  }

  List<dynamic> getUserReposts(String userId) {
    return _repostManager.getUserReposts(this, userId);
  }

  bool isNewsRepostedByUser(String newsId, String userId) {
    return _repostManager.isNewsRepostedByUser(this, newsId, userId);
  }

  String? getRepostIdForOriginal(String originalNewsId, String userId) {
    return _repostManager.getRepostIdForOriginal(this, originalNewsId, userId);
  }

  // ОСТАЛЬНЫЕ МЕТОДЫ ОБНОВЛЕНИЯ СТАТУСОВ
  void updateNewsLikeStatus(int index, bool isLiked, int likesCount) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;
        final newsId = newsItem['id'].toString();

        _news[index] = {
          ...newsItem,
          'isLiked': isLiked,
          'likes': likesCount,
        };

        _safeNotifyListeners();

        // Сохраняем в локальное хранилище
        if (isLiked) {
          StorageService.addLike(newsId);
        } else {
          StorageService.removeLike(newsId);
        }

        _saveNewsToStorage();
      }
    });
  }

// Аналогично для других методов обновления статусов...

  void updateNewsBookmarkStatus(int index, bool isBookmarked) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;
        final newsId = newsItem['id'].toString();

        _news[index] = {
          ...newsItem,
          'isBookmarked': isBookmarked,
        };

        _safeNotifyListeners();

        // Сохраняем в локальное хранилище
        if (isBookmarked) {
          StorageService.addBookmark(newsId);
        } else {
          StorageService.removeBookmark(newsId);
        }

        _saveNewsToStorage();
      }
    });
  }

  void updateNewsFollowStatus(int index, bool isFollowing) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;
        final newsId = newsItem['id'].toString();

        _news[index] = {
          ...newsItem,
          'isFollowing': isFollowing,
        };

        _safeNotifyListeners();

        // Сохраняем в локальное хранилище
        if (isFollowing) {
          if (_currentUserId != null) {
            StorageService.addFollow(_currentUserId!, newsId);
          }
        } else {
          if (_currentUserId != null) {
            StorageService.removeFollow(_currentUserId!, newsId);
          }
        }

        _saveNewsToStorage();
      }
    });
  }

  Future<void> loadNews() async {
    if (_isDisposed) return;

    _safeOperation(() {
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();
    });

    try {
      print('🔄 Starting local news loading process...');

      // 1. Загружаем из локального хранилища
      final cachedNews = await StorageService.loadNews();

      if (cachedNews.isNotEmpty) {
        await _processCachedNews(cachedNews);
      } else {
        // 2. Если в хранилище пусто, создаем начальные данные
        await _createInitialNews();
      }

    } catch (e) {
      print('❌ Error loading local news: $e');
      _safeOperation(() {
        _errorMessage = 'Ошибка загрузки локальных данных';
      });

      // Создаем mock данные при ошибке
      await _createInitialNews();
    } finally {
      _safeOperation(() {
        _isLoading = false;
        _safeNotifyListeners();
      });

      // Финальная синхронизация
      await _performFinalSyncAndCleanup();
    }
  }

  /// Обработка кэшированных новостей
  Future<void> _processCachedNews(List<dynamic> cachedNews) async {
    final localLikes = await StorageService.loadLikes();
    final localBookmarks = await StorageService.loadBookmarks();
    final userTags = await StorageService.loadUserTags();

    final processedNews = await Future.wait(cachedNews.map((newsItem) async {
      final newsId = newsItem['id'].toString();

      // Получаем user_tags
      final Map<String, String> itemUserTags;
      if (userTags.containsKey(newsId)) {
        final newsTags = userTags[newsId]!;
        if (newsTags['tags'] is Map) {
          final tagsMap = newsTags['tags'] as Map;
          itemUserTags = tagsMap.map((key, value) =>
              MapEntry(key.toString(), value.toString())
          );
        } else {
          itemUserTags = {'tag1': 'Фанат Манчестера'};
        }
      } else {
        itemUserTags = newsItem['user_tags'] is Map
            ? (newsItem['user_tags'] as Map).map((key, value) =>
            MapEntry(key.toString(), value.toString())
        )
            : {'tag1': 'Фанат Манчестера'};
      }

      final tagColor = await _getTagColor(newsId, itemUserTags);

      // Определяем аватар автора
      final authorName = newsItem['author_name']?.toString() ?? 'Пользователь';
      final authorId = newsItem['author_id']?.toString() ?? '';
      final authorAvatar = getUserAvatarUrl(authorId, authorName);
      // Для репостов гарантируем правильную структуру данных
      final isRepost = newsItem['is_repost'] == true;
      final repostComment = newsItem['repost_comment']?.toString() ?? '';
      List<dynamic> finalComments;

      if (isRepost && repostComment.isNotEmpty) {
        finalComments = [];
        print('✅ Ensuring empty comments for repost with comment: $newsId');
      } else {
        finalComments = newsItem['comments'] ?? [];
      }

      return {
        ...newsItem,
        'isLiked': localLikes.contains(newsId),
        'isBookmarked': localBookmarks.contains(newsId),
        'hashtags': _parseHashtags(newsItem['hashtags']),
        'user_tags': itemUserTags,
        'comments': finalComments,
        'likes': newsItem['likes'] ?? 0,
        'tag_color': tagColor,
        'author_avatar': authorAvatar,
      };
    }));

    _safeOperation(() {
      _news = processedNews;
      _safeNotifyListeners();
    });

    // Инициализируем взаимодействия
    _initializeInteractionsForNews(processedNews);

    print('📂 Loaded ${_news.length} news from local storage');
    await _saveNewsToStorage();
  }


  // В класс NewsProvider добавьте:

  /// 🎯 УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ ПОЛЬЗОВАТЕЛЯ
  // В классе NewsProvider - ОБНОВЛЕННЫЙ МЕТОД
  String getUserAvatarUrl(String userId, String userName) {
    try {
      print('🔍 NewsProvider: Getting avatar for user $userName ($userId)');

      // 1. 🥇 ПРИОРИТЕТ: Проверяем текущего пользователя
      if (_currentUserId == userId) {
        final currentUser = _getCurrentUser();
        if (currentUser != null) {
          // Файл с рабочего стола
          if (currentUser.profileImageFile != null) {
            print('✅ NewsProvider: Using CURRENT USER profile image FILE: ${currentUser.profileImageFile!.path}');
            return currentUser.profileImageFile!.path;
          }

          // URL из интернета
          if (currentUser.profileImageUrl != null && currentUser.profileImageUrl!.isNotEmpty) {
            print('✅ NewsProvider: Using CURRENT USER profile image URL: ${currentUser.profileImageUrl}');
            return currentUser.profileImageUrl!;
          }
        }
      }

      // 2. 🥈 ПРИОРИТЕТ: Проверяем других пользователей из _userProfiles
      final userProfile = getUserProfile(userId);
      if (userProfile != null) {
        if (userProfile.profileImageFile != null) {
          print('✅ NewsProvider: Using profile image FILE for $userName: ${userProfile.profileImageFile!.path}');
          return userProfile.profileImageFile!.path;
        }

        if (userProfile.profileImageUrl != null && userProfile.profileImageUrl!.isNotEmpty) {
          print('✅ NewsProvider: Using profile image URL for $userName: ${userProfile.profileImageUrl}');
          return userProfile.profileImageUrl!;
        }
      }

      // 3. 🥉 FALLBACK: Локальные assets
      final fallbackAvatar = _getFallbackAvatarUrl(userName);
      print('🎯 NewsProvider: Using fallback avatar for $userName: $fallbackAvatar');
      return fallbackAvatar;

    } catch (e) {
      print('❌ NewsProvider: Error getting avatar for $userName: $e');
      return _getFallbackAvatarUrl(userName);
    }
  }

  /// Создание начальных новостей
  Future<void> _createInitialNews() async {
    final mockNews = MockNewsData.getMockNews(); // ← ПРАВИЛЬНЫЙ ВЫЗОВ

    _safeOperation(() {
      _news = mockNews;
      _safeNotifyListeners();
    });

    // Инициализируем взаимодействия
    _initializeInteractionsForNews(mockNews);

    await _saveNewsToStorage();
    print('🔄 Created initial news: ${mockNews.length} items');
  }

  /// Инициализация взаимодействий для списка новостей
  void _initializeInteractionsForNews(List<dynamic> newsList) {
    final List<Map<String, dynamic>> newsMapList = newsList.map((item) {
      if (item is Map<String, dynamic>) {
        // Для репостов с комментариями гарантируем пустые комментарии
        final isRepost = item['is_repost'] == true;
        final repostComment = item['repost_comment']?.toString() ?? '';
        final comments = List<dynamic>.from(item['comments'] ?? []);

        if (isRepost && repostComment.isNotEmpty && comments.isNotEmpty) {
          print('🔄 [INIT INTERACTIONS] Fixing repost comments for: ${item['id']}');
          return {
            ...item,
            'comments': [],
          };
        }
        return item;
      } else {
        return {'id': item.toString(), 'isLiked': false, 'isBookmarked': false};
      }
    }).toList();

    // ✅ Исправленный вызов
    _interactionManager.bulkUpdatePostStates(newsMapList);
    print('✅ Interactions initialized for ${newsMapList.length} posts');
  }


  /// Финальная синхронизация и очистка
  Future<void> _performFinalSyncAndCleanup() async {
    // Синхронизируем все посты
    syncAllPostsFromInteractionManager();

    // Очищаем дубликаты комментариев репостов
    await _cleanupRepostCommentDuplicates();

    // Исправляем дублирование комментариев
    fixRepostCommentsDuplication();

    print('✅ Final sync and cleanup completed');
  }

// НОВЫЙ МЕТОД: Очистка дубликатов комментариев репостов
  Future<void> _cleanupRepostCommentDuplicates() async {
    try {
      int cleanedCount = 0;

      for (int i = 0; i < _news.length; i++) {
        final newsItem = Map<String, dynamic>.from(_news[i]);
        final isRepost = newsItem['is_repost'] == true;
        final repostComment = newsItem['repost_comment']?.toString() ?? '';
        final comments = List<dynamic>.from(newsItem['comments'] ?? []);

        // Если это репост с комментарием И есть обычные комментарии - очищаем
        if (isRepost && repostComment.isNotEmpty && comments.isNotEmpty) {
          print('❌ [CLEANUP] Found duplication in repost: ${newsItem['id']}');
          print('   Repost comment: "$repostComment"');
          print('   Regular comments count: ${comments.length}');

          final cleanItem = {
            ...newsItem,
            'comments': [], // Очищаем обычные комментарии
          };

          _news[i] = cleanItem;
          cleanedCount++;
          print('✅ [CLEANUP] Cleaned repost: ${newsItem['id']}');

          // Также обновляем InteractionManager
          final postId = newsItem['id'].toString();
          _interactionManager.updateComments(postId, []);
        }
      }

      if (cleanedCount > 0) {
        await _saveNewsToStorage();
        _safeNotifyListeners();
        print('🎉 [CLEANUP] Cleaned $cleanedCount reposts with comment duplication');
      } else {
        print('✅ [CLEANUP] No repost duplicates found');
      }
    } catch (e) {
      print('❌ [CLEANUP] Error cleaning repost duplicates: $e');
    }
  }

  Future<void> ensureDataPersistence() async {
    if (_isDisposed) return;

    try {
      // Сначала загружаем данные профиля для текущего пользователя
      if (_currentUserId != null) {
        await _loadUserProfileData(_currentUserId!);
      }

      // Затем загружаем новости
      final cachedNews = await StorageService.loadNews();
      if (cachedNews.isEmpty) {
        // Если данных нет, создаем начальные mock данные
        final mockNews = MockNewsData.getMockNews();
        await _saveNewsToStorage();
        _safeOperation(() {
          _news = mockNews;
          _safeNotifyListeners();
        });

        // ИНИЦИАЛИЗИРУЕМ взаимодействия
        initializeInteractions();

        print('✅ Initial data ensured with ${mockNews.length} items');
      } else {
        // Используем кэшированные данные
        _safeOperation(() {
          _news = cachedNews;
          _safeNotifyListeners();
        });

        // ИНИЦИАЛИЗИРУЕМ взаимодействия
        initializeInteractions();

        print('📂 Using cached data: ${_news.length} items');
      }
    } catch (e) {
      print('❌ Error ensuring data persistence: $e');
      // Создаем mock данные при ошибке
      final mockNews = MockNewsData.getMockNews();
      _safeOperation(() {
        _news = mockNews;
      });
      await _saveNewsToStorage();

      // ИНИЦИАЛИЗИРУЕМ взаимодействия
      initializeInteractions();

      _safeNotifyListeners();
    }
  }

  // Вспомогательный метод для парсинга хештегов
  List<String> _parseHashtags(dynamic hashtags) {
    if (_isDisposed) return [];

    print('🔍 NewsProvider _parseHashtags INPUT: $hashtags (type: ${hashtags.runtimeType})');

    if (hashtags is List) {
      final result = List<String>.from(hashtags).map((tag) {
        print('   🎯 NewsProvider processing tag: "$tag"');
        // Убираем решетки и пробелы
        var cleanTag = tag.toString().replaceAll(RegExp(r'#'), '').trim();
        cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
        return cleanTag;
      }).where((tag) => tag.isNotEmpty).toList();
      print('🔍 NewsProvider _parseHashtags OUTPUT: $result');
      return result;
    }

    if (hashtags is String) {
      final result = hashtags
          .split(RegExp(r'[,\s]+'))
          .map((tag) {
        var cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
        cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
        return cleanTag;
      })
          .where((tag) => tag.isNotEmpty)
          .toList();
      print('🔍 NewsProvider _parseHashtags OUTPUT: $result');
      return result;
    }

    print('🔍 NewsProvider _parseHashtags OUTPUT: []');
    return [];
  }

  // ИСПРАВЛЕНИЕ: Метод теперь асинхронный и возвращает Future<int>
  Future<int> _getTagColor(String newsId, Map<String, String> userTags) async {
    if (_isDisposed) return Colors.blue.value;

    try {
      final storedColor = await StorageService.getTagColor(newsId);
      if (storedColor != null) return storedColor;
    } catch (e) {
      print('Error getting tag color: $e');
    }

    // Генерируем цвет на основе хеша новости
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

  // ИСПРАВЛЕННЫЙ МЕТОД: Используем локальные аватарки вместо URL
  // В классе NewsProvider замените метод _getFallbackAvatarUrl:

// ИСПРАВЛЕННЫЙ МЕТОД: Используем универсальную систему
  String _getFallbackAvatarUrl(String userName) {
    // Теперь используем ту же логику, что и в ImageUtils
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

    // Генерируем индекс на основе хеша имени для консистентности
    final index = userName.hashCode.abs() % avatars.length;
    final selectedAvatar = avatars[index];

    print('🎲 NewsProvider: Generated fallback avatar for $userName: $selectedAvatar (index: $index)');
    return selectedAvatar;
  }

  // ПОЛНОСТЬЮ ОБНОВЛЕННЫЙ МЕТОД addNews В news_provider.dart
  Future<void> addNews(Map<String, dynamic> newsItem, {BuildContext? context}) async {
    if (_isDisposed) return;

    try {
      final newNewsId = newsItem['id']?.toString();

      // ОТЛАДОЧНАЯ ИНФОРМАЦИЯ О РЕПОСТАХ
      final isRepost = newsItem['is_repost'] == true;
      final repostComment = newsItem['repost_comment']?.toString() ?? '';

      print('🔄 ADDING NEWS TO PROVIDER:');
      print('   ID: $newNewsId');
      print('   Is repost: $isRepost');
      print('   Repost comment: "$repostComment"');
      print('   Repost comment length: ${repostComment.length}');
      print('   Input comments count: ${(newsItem['comments'] ?? []).length}');

      // ПРОВЕРКА НА ДУБЛИКАТЫ - БОЛЕЕ ГИБКАЯ ДЛЯ РЕПОСТОВ
      if (newNewsId != null) {
        final exists = _news.any((item) {
          final itemId = item['id']?.toString();
          return itemId == newNewsId;
        });

        if (exists) {
          print('⚠️ News with ID already exists: $newNewsId, skipping...');
          return;
        }
      }

      final isChannelPost = newsItem['is_channel_post'] == true;
      final authorName = newsItem['author_name']?.toString() ?? 'Пользователь';
      final channelName = newsItem['channel_name']?.toString() ?? '';

      // СОЗДАЕМ УНИКАЛЬНЫЙ ID если не предоставлен
      final uniqueId = newsItem['id']?.toString() ?? 'news-${DateTime.now().millisecondsSinceEpoch}';

      // ДЛЯ РЕПОСТОВ: сохраняем все данные репоста
      String authorAvatar;
      if (isRepost) {
        final repostedById = newsItem['reposted_by']?.toString() ?? '';
        final repostedByName = newsItem['reposted_by_name']?.toString() ?? authorName;

        // Используем универсальную систему
        authorAvatar = getUserAvatarUrl(repostedById, repostedByName);

        print('🔄 ADDING REPOST TO PROVIDER:');
        print('   Repost ID: $uniqueId');
        print('   Reposted by: $repostedByName ($repostedById)');
        print('   Avatar: $authorAvatar');
      } else {
        // Для обычных постов
        final authorId = newsItem['author_id']?.toString() ?? '';
        authorAvatar = getUserAvatarUrl(authorId, authorName);
      }

      // ВАЖНОЕ ИСПРАВЛЕНИЕ: Для репостов с комментариями - ГАРАНТИРУЕМ, что обычные комментарии ПУСТЫЕ
      final List<dynamic> comments;
      if (isRepost && repostComment.isNotEmpty) {
        // ДЛЯ РЕПОСТОВ С КОММЕНТАРИЕМ: принудительно устанавливаем пустой массив комментариев
        comments = [];
        print('✅ [ADD NEWS] Forcing empty comments array for repost with comment');
      } else if (isRepost) {
        // ДЛЯ РЕПОСТОВ БЕЗ КОММЕНТАРИЯ: также используем пустой массив для консистентности
        comments = [];
        print('✅ [ADD NEWS] Using empty comments array for repost without comment');
      } else {
        // ДЛЯ ОБЫЧНЫХ ПОСТОВ: используем переданные комментарии
        comments = newsItem['comments'] ?? [];
        print('✅ [ADD NEWS] Using provided comments for regular post: ${comments.length} items');
      }

      // ВАЖНОЕ ИЗМЕНЕНИЕ: сохраняем ВСЕ переданные данные, включая репост и комментарий
      final Map<String, dynamic> cleanNewsItem = {
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
        'comments': comments, // ИСПРАВЛЕНИЕ: используем гарантированно правильные комментарии
        'hashtags': _parseHashtags(newsItem['hashtags']),

        // ВАЖНО: сохраняем ВСЕ данные репоста если они есть
        'is_repost': isRepost,
        'reposted_by': newsItem['reposted_by']?.toString(),
        'reposted_by_name': newsItem['reposted_by_name']?.toString(),
        'reposted_at': newsItem['reposted_at']?.toString(),
        'original_post_id': newsItem['original_post_id']?.toString(),
        'original_author_name': newsItem['original_author_name']?.toString(),
        'original_author_avatar': newsItem['original_author_avatar']?.toString(),
        'original_channel_name': newsItem['original_channel_name']?.toString(),
        'is_original_channel_post': newsItem['is_original_channel_post'] ?? false,

        // ВАЖНОЕ ИСПРАВЛЕНИЕ: Сохраняем комментарий репоста если он есть
        'repost_comment': repostComment, // Явно сохраняем комментарий

        // Обычные поля
        'user_tags': newsItem['user_tags'] ?? <String, String>{},
        'isLiked': newsItem['isLiked'] ?? false,
        'isBookmarked': newsItem['isBookmarked'] ?? false,
        'isFollowing': newsItem['isFollowing'] ?? false,
        'tag_color': newsItem['tag_color'] ?? _generateColorFromId(uniqueId).value,
        'is_channel_post': isChannelPost,
        'content_type': isChannelPost ? 'channel_post' : (isRepost ? 'repost' : 'regular_post'),
      };

      // ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА КОММЕНТАРИЯ РЕПОСТА
      if (isRepost && repostComment.isNotEmpty) {
        print('✅ [ADD NEWS] Repost comment successfully saved: "$repostComment"');
        print('   Regular comments count: ${(cleanNewsItem['comments'] as List).length}');

        // ФИНАЛЬНАЯ ПРОВЕРКА: убедимся, что комментарии действительно пустые
        if (cleanNewsItem['comments'] is List && (cleanNewsItem['comments'] as List).isNotEmpty) {
          print('❌ [ADD NEWS] CRITICAL ERROR: Comments array is not empty for repost with comment!');
          print('   Forcing comments to empty array...');
          cleanNewsItem['comments'] = [];
        } else {
          print('✅ [ADD NEWS] Comments array is properly empty for repost with comment');
        }
      } else if (isRepost) {
        print('ℹ️ [ADD NEWS] Repost without comment - comments count: ${(cleanNewsItem['comments'] as List).length}');
      } else {
        print('📝 [ADD NEWS] Regular post - comments count: ${(cleanNewsItem['comments'] as List).length}');
      }

      // ДОБАВЛЯЕМ в начало списка
      _safeOperation(() {
        _news.insert(0, cleanNewsItem);
        _safeNotifyListeners();
      });

      // НЕМЕДЛЕННО сохраняем в хранилище
      await _saveNewsToStorage();

      // ИНИЦИАЛИЗИРУЕМ взаимодействия для новой новости
      _interactionManager.initializePostState(
        postId: uniqueId,
        isLiked: cleanNewsItem['isLiked'],
        isBookmarked: cleanNewsItem['isBookmarked'],
        isReposted: cleanNewsItem['isReposted'] ?? false,
        likesCount: cleanNewsItem['likes'],
        repostsCount: cleanNewsItem['reposts'] ?? 0,
        comments: List<Map<String, dynamic>>.from(cleanNewsItem['comments'] ?? []),
      );

      print('✅ Новость добавлена в NewsProvider. ID: $uniqueId, Тип: ${isRepost ? 'РЕПОСТ' : 'обычный'}, Всего новостей: ${_news.length}');

      // ОТЛАДОЧНАЯ ИНФОРМАЦИЯ ПОСЛЕ ДОБАВЛЕНИЯ
      if (isRepost) {
        print('🔍 [ADD NEWS] FINAL REPOST DATA VERIFICATION:');
        print('   repost_comment: "${cleanNewsItem['repost_comment']}"');
        print('   comments array: ${cleanNewsItem['comments']}');
        print('   comments count: ${(cleanNewsItem['comments'] as List).length}');

        // ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА: если все еще есть проблема, исправляем немедленно
        if (repostComment.isNotEmpty && (cleanNewsItem['comments'] as List).isNotEmpty) {
          print('❌ [ADD NEWS] URGENT: Still have duplication! Fixing immediately...');
          final fixedIndex = _news.indexWhere((item) => item['id'] == uniqueId);
          if (fixedIndex != -1) {
            _news[fixedIndex] = {
              ...cleanNewsItem,
              'comments': [],
            };
            await _saveNewsToStorage();
            _safeNotifyListeners();
            print('✅ [ADD NEWS] Immediately fixed duplication for: $uniqueId');
          }
        }
      }

      // ПОКАЗЫВАЕМ УВЕДОМЛЕНИЕ О УСПЕШНОМ ДОБАВЛЕНИИ
      if (context != null && mounted) {
        final message = isRepost
            ? (repostComment.isNotEmpty ? 'Репост с комментарием создан!' : 'Репост создан!')
            : 'Пост создан!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      print('❌ Ошибка при добавлении новости в NewsProvider: $e');

      // ДЕТАЛЬНАЯ ОШИБКА ДЛЯ ОТЛАДКИ
      if (e is Error) {
        print('❌ Stack trace: ${e.stackTrace}');
      }

      if (context != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при создании поста: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ДОБАВЬТЕ этот метод в класс NewsProvider
  void fixRepostCommentsDuplication() {
    _safeOperation(() {
      int fixedCount = 0;

      for (int i = 0; i < _news.length; i++) {
        final newsItem = Map<String, dynamic>.from(_news[i]);

        // Проверяем репосты с комментариями
        if (newsItem['is_repost'] == true && newsItem['repost_comment'] != null) {
          final repostComment = newsItem['repost_comment'].toString();
          final comments = List<Map<String, dynamic>>.from(newsItem['comments'] ?? []);

          // Убеждаемся, что комментарии репоста не дублируются в обычных комментариях
          final hasDuplicate = comments.any((comment) {
            final commentText = comment['text']?.toString() ?? '';
            return commentText == repostComment;
          });

          if (hasDuplicate) {
            // Очищаем обычные комментарии для репостов с комментариями
            _news[i] = {
              ...newsItem,
              'comments': [], // Принудительно очищаем обычные комментарии
            };
            fixedCount++;
            print('✅ Fixed repost comments duplication: ${newsItem['id']}');
          }
        }
      }

      if (fixedCount > 0) {
        _safeNotifyListeners();
        _saveNewsToStorage();
        print('🎉 Fixed $fixedCount reposts with comment duplication');
      }
    });
  }



  void debugRepostData(String repostId) {
    if (_isDisposed) return;

    final repostIndex = _news.indexWhere((item) => item['id'] == repostId);
    if (repostIndex != -1) {
      final repost = _news[repostIndex] as Map<String, dynamic>;
      print('🔍 DEBUG REPOST DATA:');
      print('   ID: ${repost['id']}');
      print('   is_repost: ${repost['is_repost']}');
      print('   repost_comment: "${repost['repost_comment']}"');
      print('   comments count: ${(repost['comments'] as List).length}');
      print('   comments: ${repost['comments']}');
    }
  }

  // Вспомогательный метод проверки индекса
  bool _isValidIndex(int index) {
    return index >= 0 && index < _news.length;
  }

  void refreshAllPostsUserTags() {
    if (_isDisposed) return;

    _safeOperation(() {
      _safeNotifyListeners();
    });
    print('✅ NewsProvider: все посты обновлены для отображения новых тегов');
  }

  // НОВЫЙ МЕТОД: Инициализация Interaction Manager
  void initializeInteractions() {
    // Конвертируем List<dynamic> в List<Map<String, dynamic>>
    final List<Map<String, dynamic>> newsList = _news.map((item) {
      if (item is Map<String, dynamic>) {
        // ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА: для репостов с комментариями гарантируем пустые комментарии
        final isRepost = item['is_repost'] == true;
        final repostComment = item['repost_comment']?.toString() ?? '';
        final comments = List<dynamic>.from(item['comments'] ?? []);

        if (isRepost && repostComment.isNotEmpty && comments.isNotEmpty) {
          print('🔄 [INIT INTERACTIONS] Fixing repost comments for: ${item['id']}');
          print('   Repost comment: "$repostComment"');
          print('   Regular comments before: ${comments.length}');

          // Возвращаем исправленный элемент с пустыми комментариями
          return {
            ...item,
            'comments': [], // Гарантируем пустой массив для репостов с комментариями
          };
        }
        return item;
      } else {
        // Если элемент не Map, конвертируем его
        return {'id': item.toString(), 'isLiked': false, 'isBookmarked': false};
      }
    }).toList();

    // ✅ Исправленный вызов
    _interactionManager.bulkUpdatePostStates(newsList);
    print('✅ Interactions initialized for ${newsList.length} posts');
  }

  bool _containsNewsWithId(String newsId) {
    return _news.any((item) => item['id'].toString() == newsId);
  }

  void updateNews(int index, Map<String, dynamic> updatedNews) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final originalNews = _news[index] as Map<String, dynamic>;
        final preservedFields = {
          'id': originalNews['id'],
          'author_name': originalNews['author_name'],
          'created_at': originalNews['created_at'],
          'likes': originalNews['likes'],
          'comments': originalNews['comments'],
          'isLiked': originalNews['isLiked'],
          'isBookmarked': originalNews['isBookmarked'],
          'isFollowing': originalNews['isFollowing'],
          'tag_color': originalNews['tag_color'],
        };

        _news[index] = {
          ...preservedFields,
          ...updatedNews,
          'hashtags': _parseHashtags(updatedNews['hashtags'] ?? originalNews['hashtags']),
          'user_tags': updatedNews['user_tags'] ?? originalNews['user_tags'],
        };

        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  void addCommentToNews(String newsId, Map<String, dynamic> comment) {
    _safeOperation(() {
      final index = _news.indexWhere((item) => item['id'].toString() == newsId);
      if (index != -1) {
        final newsItem = _news[index] as Map<String, dynamic>;

        if (newsItem['comments'] == null) {
          newsItem['comments'] = [];
        }

        final completeComment = {
          ...comment,
          'time': comment['time'] ?? DateTime.now().toIso8601String(),
        };

        // Добавляем комментарий в начало списка
        (newsItem['comments'] as List).insert(0, completeComment);
        _safeNotifyListeners();

        // Сохраняем в хранилище
        _saveNewsToStorage();

        print('✅ Комментарий добавлен к новости $newsId');
      }
    });
  }

  int findNewsIndexById(String newsId) {
    return _news.indexWhere((item) => item['id'].toString() == newsId);
  }

  void updateNewsComments(String newsId, List<dynamic> comments) {
    _safeOperation(() {
      final index = findNewsIndexById(newsId);
      if (index != -1) {
        final newsItem = _news[index] as Map<String, dynamic>;
        _news[index] = {
          ...newsItem,
          'comments': comments,
        };
        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  void removeCommentFromNews(int index, String commentId) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;

        if (newsItem['comments'] != null) {
          final commentsList = newsItem['comments'] as List;
          final initialLength = commentsList.length;

          commentsList.removeWhere((comment) =>
          comment['id'] == commentId
          );

          if (commentsList.length < initialLength) {
            _safeNotifyListeners();
            _saveNewsToStorage();
            print('✅ Комментарий $commentId удален');
          }
        }
      }
    });
  }

  void removeNews(int index) async {
    if (_isDisposed) return;

    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;
        final newsId = newsItem['id'].toString();
        final isChannelPost = newsItem['is_channel_post'] == true;

        print('🗑️ Removing news from NewsProvider: $newsId (channel: $isChannelPost)');

        try {
          // Только для API постов пытаемся удалить через API
          if (!isChannelPost) {
            try {
              ApiService.deleteNews(newsId).catchError((e) {
                print('⚠️ API delete error (expected for local posts): $e');
              });
            } catch (e) {
              print('⚠️ API delete error (expected for local posts): $e');
            }
          }

          // Удаляем из локальных хранилищ
          StorageService.removeLike(newsId);
          StorageService.removeBookmark(newsId);
          StorageService.removeUserTags(newsId);

          _news.removeAt(index);
          _safeNotifyListeners();

          // Сохраняем обновленный список
          _saveNewsToStorage();

          print('✅ News removed from NewsProvider: $newsId');

        } catch (e) {
          print('❌ Error removing news from NewsProvider: $e');
          rethrow;
        }
      }
    });
  }

  Future<void> loadUserTags() async {
    if (_isDisposed) return;

    try {
      final loadedTags = await StorageService.loadUserTags();

      // Обновляем теги в новостях
      _safeOperation(() {
        for (var i = 0; i < _news.length; i++) {
          final newsItem = _news[i] as Map<String, dynamic>;
          final newsId = newsItem['id'].toString();

          if (loadedTags.containsKey(newsId)) {
            final newsTags = loadedTags[newsId]!;
            Map<String, String> updatedUserTags = {'tag1': 'Новый тег'};

            if (newsTags['tags'] is Map) {
              final tagsMap = newsTags['tags'] as Map;
              updatedUserTags = tagsMap.map((key, value) =>
                  MapEntry(key.toString(), value.toString())
              );
            }

            _getTagColor(newsId, updatedUserTags).then((tagColor) {
              _safeOperation(() {
                _news[i] = {
                  ...newsItem,
                  'user_tags': updatedUserTags,
                  'tag_color': tagColor,
                };
                _safeNotifyListeners();
              });
            });
          }
        }
      });

      _safeNotifyListeners();
    } catch (e) {
      print('Ошибка загрузки тегов: $e');
    }
  }

  void updateNewsHashtags(int index, List<String> hashtags) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;
        _news[index] = {
          ...newsItem,
          'hashtags': _parseHashtags(hashtags),
        };
        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  Map<String, String> _ensureStringStringMap(dynamic map) {
    if (map is Map<String, String>) {
      return map;
    }
    if (map is Map) {
      return map.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {'tag1': 'Новый тег'};
  }

  void updateNewsUserTag(int index, String tagId, String newTagName, {Color? color}) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;
        final newsId = newsItem['id'].toString();

        final updatedUserTags = {
          ..._ensureStringStringMap(newsItem['user_tags'] ?? {}),
          tagId: newTagName,
        };

        final tagColor = color ?? Color(newsItem['tag_color'] ?? _generateColorFromId(newsId).value);

        final updatedNews = {
          ...newsItem,
          'user_tags': updatedUserTags,
          'tag_color': tagColor.value,
        };

        _news[index] = updatedNews;
        _safeNotifyListeners();

        // Сохраняем тег и цвет в отдельном хранилище
        StorageService.updateUserTag(newsId, tagId, newTagName, color: tagColor.value);
        _saveNewsToStorage();
      }
    });
  }

  // Поиск новостей
  List<dynamic> searchNews(String query) {
    if (_isDisposed) return [];
    if (query.isEmpty) return _news;

    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      final title = newsItem['title']?.toString().toLowerCase() ?? '';
      final description = newsItem['description']?.toString().toLowerCase() ?? '';
      final hashtags = (newsItem['hashtags'] is List
          ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
          : '');
      final author = newsItem['author_name']?.toString().toLowerCase() ?? '';
      final userTags = (newsItem['user_tags'] is Map
          ? (newsItem['user_tags'] as Map).values.join(' ').toLowerCase()
          : '');

      return title.contains(query.toLowerCase()) ||
          description.contains(query.toLowerCase()) ||
          hashtags.contains(query.toLowerCase()) ||
          author.contains(query.toLowerCase()) ||
          userTags.contains(query.toLowerCase());
    }).toList();
  }

  // Получение избранных новостей
  List<dynamic> getBookmarkedNews() {
    if (_isDisposed) return [];
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['isBookmarked'] == true;
    }).toList();
  }

  // Получение популярных новостей (лайков > 5)
  List<dynamic> getPopularNews() {
    if (_isDisposed) return [];
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return (newsItem['likes'] ?? 0) > 5;
    }).toList();
  }

  // Получение моих новостей
  List<dynamic> getMyNews(String userName) {
    if (_isDisposed) return [];
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['author_name'] == userName;
    }).toList();
  }

  // Получение новости по ID
  Map<String, dynamic>? getNewsById(String id) {
    if (_isDisposed) return null;
    try {
      return _news.firstWhere(
            (item) => (item as Map<String, dynamic>)['id'].toString() == id,
      ) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Получение списка подписок
  List<dynamic> getFollowedNews() {
    if (_isDisposed) return [];
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['isFollowing'] == true;
    }).toList();
  }

  // Получение постов от подписанных авторов/каналов
  Future<List<dynamic>> getFollowedContent() async {
    if (_isDisposed) return [];
    try {
      if (_currentUserId == null) return [];
      final followedIds = await StorageService.loadFollows(_currentUserId!);
      return _news.where((item) {
        try {
          final newsItem = item as Map<String, dynamic>;
          final itemId = newsItem['id']?.toString() ?? '';
          return followedIds.contains(itemId);
        } catch (e) {
          print('Error checking follow for item: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error loading followed content: $e');
      return [];
    }
  }

  // Обновление количества просмотров
  void incrementNewsViews(int index) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news[index] as Map<String, dynamic>;
        final currentViews = newsItem['views'] ?? 0;

        _news[index] = {
          ...newsItem,
          'views': currentViews + 1,
        };

        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  // ИСПРАВЛЕННЫЙ МЕТОД: Получение статистики
  Map<String, int> getStats() {
    if (_isDisposed) return {'total_news': 0, 'total_likes': 0, 'total_comments': 0, 'bookmarked_count': 0, 'liked_count': 0};

    final totalNews = _news.length;

    // ИСПРАВЛЕНИЕ: Явное приведение типов для fold
    final totalLikes = _news.fold<int>(0, (int sum, item) => sum + ((item['likes'] as int?) ?? 0));
    final totalComments = _news.fold<int>(0, (int sum, item) {
      final comments = item['comments'] as List? ?? [];
      return sum + comments.length;
    });

    final bookmarkedCount = _news.where((item) => item['isBookmarked'] == true).length;
    final likedCount = _news.where((item) => item['isLiked'] == true).length;

    return {
      'total_news': totalNews,
      'total_likes': totalLikes,
      'total_comments': totalComments,
      'bookmarked_count': bookmarkedCount,
      'liked_count': likedCount,
    };
  }

  // Проверка существования новости
  bool containsNews(String newsId) {
    if (_isDisposed) return false;
    return _news.any((item) => item['id'].toString() == newsId);
  }

  // Получение индекса новости по ID
  int getNewsIndexById(String newsId) {
    if (_isDisposed) return -1;
    return _news.indexWhere((item) => item['id'].toString() == newsId);
  }

  // Обновление только определенных полей новости
  void patchNews(int index, Map<String, dynamic> partialUpdates) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final currentNews = _news[index] as Map<String, dynamic>;
        _news[index] = {
          ...currentNews,
          ...partialUpdates,
        };
        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  // Перемещение новости в начало списка
  void moveNewsToTop(int index) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final newsItem = _news.removeAt(index);
        _news.insert(0, newsItem);
        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  // Дублирование новости
  void duplicateNews(int index) {
    _safeOperation(() {
      if (index >= 0 && index < _news.length) {
        final originalNews = _news[index] as Map<String, dynamic>;
        final duplicatedNews = {
          ...originalNews,
          'id': 'dup-${DateTime.now().millisecondsSinceEpoch}-${originalNews['id']}',
          'created_at': DateTime.now().toIso8601String(),
          'likes': 0,
          'comments': [],
          'isLiked': false,
          'isBookmarked': false,
        };

        _news.insert(index + 1, duplicatedNews);
        _safeNotifyListeners();
        _saveNewsToStorage();
      }
    });
  }

  // Сортировка новостей по дате (сначала новые)
  void sortByDate() {
    _safeOperation(() {
      _news.sort((a, b) {
        final dateA = DateTime.parse(a['created_at'] ?? '');
        final dateB = DateTime.parse(b['created_at'] ?? '');
        return dateB.compareTo(dateA);
      });
      _safeNotifyListeners();
      _saveNewsToStorage();
    });
  }

  // Сортировка новостей по лайкам
  void sortByLikes() {
    _safeOperation(() {
      _news.sort((a, b) {
        final likesA = a['likes'] ?? 0;
        final likesB = b['likes'] ?? 0;
        return likesB.compareTo(likesA);
      });
      _safeNotifyListeners();
      _saveNewsToStorage();
    });
  }

  // Очистка всех данных
  Future<void> clearAllData() async {
    if (_isDisposed) return;

    _safeOperation(() {
      _news = [];
      _isLoading = false;
      _errorMessage = null;
      _userProfiles.clear();
      _currentUserId = null;
      _safeNotifyListeners();
    });

    await StorageService.clearAllData();
  }

  // Обновление нескольких новостей
  void updateMultipleNews(List<Map<String, dynamic>> updatedNewsList) {
    _safeOperation(() {
      for (final updatedNews in updatedNewsList) {
        final newsId = updatedNews['id']?.toString();
        if (newsId != null) {
          final index = _news.indexWhere((item) =>
          (item as Map<String, dynamic>)['id'].toString() == newsId
          );

          if (index != -1) {
            _news[index] = {
              ..._news[index],
              ...updatedNews,
            };
          }
        }
      }

      _safeNotifyListeners();
      _saveNewsToStorage();
    });
  }

  // Восстановление из резервной копии
  Future<void> restoreFromBackup(List<dynamic> backupData) async {
    if (_isDisposed) return;

    _safeOperation(() {
      _news = backupData;
      _safeNotifyListeners();
    });
    await _saveNewsToStorage();
  }

  // Создание резервной копии
  List<dynamic> createBackup() {
    if (_isDisposed) return [];
    return List<dynamic>.from(_news);
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ УПРАВЛЕНИЯ ПРОФИЛЕМ
  void removeProfileImage() {
    if (_isDisposed || _currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageUrl: null,
      profileImageFile: null,
    );

    _safeNotifyListeners();

    // Очищаем в хранилище
    StorageService.saveProfileImageUrl(_currentUserId!, null);
    StorageService.saveProfileImageFilePath(_currentUserId!, null);

    print('✅ Profile image removed for user $_currentUserId');
  }


  bool hasProfileImage() {
    if (_isDisposed || _currentUserId == null) return false;
    final user = _userProfiles[_currentUserId!];
    return user?.profileImageUrl != null || user?.profileImageFile != null;
  }


  Future<void> removeCoverImage() async {
    if (_isDisposed || _currentUserId == null) {
      print('❌ [COVER] Cannot remove cover: disposed=$_isDisposed, userId=$_currentUserId');
      return;
    }

    final user = _userProfiles[_currentUserId!];
    if (user == null) {
      print('❌ [COVER] User not found: $_currentUserId');
      return;
    }

    print('🗑️ [COVER] Removing cover image for user $_currentUserId');

    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageUrl: null,
      coverImageFile: null,
    );

    _safeNotifyListeners();

    // Очищаем в хранилище
    await StorageService.saveCoverImageUrl(_currentUserId!, null);
    await StorageService.saveCoverImageFilePath(_currentUserId!, null);

    print('✅ [COVER] Cover image removed for user $_currentUserId');
  }




  bool hasCoverImage() {
    if (_isDisposed || _currentUserId == null) return false;
    final user = _userProfiles[_currentUserId!];
    return user?.coverImageUrl != null || user?.coverImageFile != null;
  }

  dynamic getCurrentProfileImage() {
    if (_isDisposed || _currentUserId == null) return null;
    final user = _userProfiles[_currentUserId!];
    // Приоритет у файла, затем URL
    if (user?.profileImageFile != null) return user!.profileImageFile;
    if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) return user.profileImageUrl;
    return null;
  }

  dynamic getCurrentCoverImage() {
    if (_isDisposed || _currentUserId == null) return null;
    final user = _userProfiles[_currentUserId!];
    // Приоритет у файла, затем URL
    if (user?.coverImageFile != null) return user!.coverImageFile;
    if (user?.coverImageUrl != null && user!.coverImageUrl!.isNotEmpty) return user.coverImageUrl;
    return null;
  }

  // Получение контента по типу
  List<dynamic> getContentByType(String contentType) {
    if (_isDisposed) return [];

    switch (contentType) {
      case 'all':
        return _news;
      case 'channel_posts':
        return _news.where((item) => item['is_channel_post'] == true).toList();
      case 'regular_posts':
        return _news.where((item) => item['is_channel_post'] != true).toList();
      case 'popular':
        return getPopularNews();
      case 'bookmarked':
        return getBookmarkedNews();
      default:
        return _news;
    }
  }

  // Обновление нескольких новостей батчем
  void updateNewsBatch(List<Map<String, dynamic>> updates) {
    _safeOperation(() {
      for (final update in updates) {
        final newsId = update['id']?.toString();
        if (newsId != null) {
          final index = findNewsIndexById(newsId);
          if (index != -1) {
            _news[index] = {
              ..._news[index],
              ...update,
            };
          }
        }
      }
      _safeNotifyListeners();
      _saveNewsToStorage();
    });
  }

  // Проверка дубликатов
  bool hasDuplicate(String newsId) {
    if (_isDisposed) return false;
    return _news.any((item) => item['id'].toString() == newsId);
  }

  // Получение последних новостей
  List<dynamic> getLatestNews({int count = 10}) {
    if (_isDisposed) return [];

    // Сортируем по дате (сначала новые)
    final sortedNews = List<dynamic>.from(_news)
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

    return sortedNews.take(count).toList();
  }

  // Получение статистики по периодам
  Map<String, int> getPeriodStats(Duration period) {
    if (_isDisposed) return {};

    final cutoffTime = DateTime.now().subtract(period);
    final periodNews = _news.where((item) {
      final createdAt = DateTime.tryParse(item['created_at'] ?? '');
      return createdAt != null && createdAt.isAfter(cutoffTime);
    }).toList();

    return {
      'count': periodNews.length,
      'total_likes': periodNews.fold<int>(
        0,
            (sum, item) => sum + ((item['likes'] ?? 0) as num).toInt(),
      ),
      'total_comments': periodNews.fold<int>(
        0,
            (sum, item) {
          final comments = item['comments'] as List? ?? [];
          return sum + comments.length;
        },
      ),
    };
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ ДОСТУПА К МЕНЕДЖЕРАМ
  InteractionManager get interactionManager => _interactionManager;
  RepostManager get repostManager => _repostManager;
  @override
  void dispose() {
    print('🔴 NewsProvider dispose() called');

    // Устанавливаем флаг disposed ПЕРВЫМ ДЕЛОМ
    _isDisposed = true;

    // 1. УДАЛЯЕМ ВСЕ СЛУШАТЕЛИ INTERACTION MANAGER
    try {
      _interactionManager.setCallbacks(
        onLike: null,
        onBookmark: null,
        onRepost: null,
        onComment: null,
        onCommentRemoval: null,
      );
      print('✅ InteractionManager callbacks cleared');
    } catch (e) {
      print('⚠️ Error clearing InteractionManager callbacks: $e');
    }

    // 2. ДИСПОЗИМ МЕНЕДЖЕРЫ
    try {
      _repostManager.dispose();
      print('✅ RepostManager disposed');
    } catch (e) {
      print('⚠️ Error disposing RepostManager: $e');
    }

    try {
      // Если InteractionManager тоже нужно диспозить
      if (_interactionManager.isDisposed) {
        _interactionManager.dispose();
        print('✅ InteractionManager disposed');
      }
    } catch (e) {
      print('⚠️ Error disposing InteractionManager: $e');
    }

    // 3. ОЧИЩАЕМ КОЛЛЕКЦИИ ДАННЫХ
    _news.clear();
    _userProfiles.clear();

    // 4. СБРАСЫВАЕМ СОСТОЯНИЕ
    _currentUserId = null;
    _errorMessage = null;

    print('✅ NewsProvider resources cleaned up');
    super.dispose();
  }
}