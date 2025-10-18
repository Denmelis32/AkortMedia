// lib/providers/news_provider.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/providers/user_tags_provider.dart';
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';
import '../pages/news_page/mock_news_data.dart';
import '../services/interaction_manager.dart';
import '../services/storage_service.dart';

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
    _initializeInteractionManager();
    print('✅ NewsProvider initialized with InteractionManager');
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
    if (_isDisposed || _currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    // Валидация URL
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (!uri.hasScheme) {
          url = 'https://$url';
        }

        final response = await http.head(Uri.parse(url));
        if (response.statusCode != 200) {
          print('❌ Image URL not accessible: ${response.statusCode}');
          return;
        }
      } catch (e) {
        print('❌ Invalid image URL: $e');
        return;
      }
    }

    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageUrl: url,
      profileImageFile: null,
    );

    _safeNotifyListeners();
    await StorageService.saveProfileImageUrl(_currentUserId!, url);
    print('✅ Profile image URL updated for user $_currentUserId: $url');
  }

  Future<void> updateProfileImageFile(File? file) async {
    if (_isDisposed || _currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageFile: file,
      profileImageUrl: null,
    );

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        await StorageService.saveProfileImageFilePath(_currentUserId!, file.path);
        print('✅ Profile image file updated for user $_currentUserId: ${file.path}');
      } else {
        print('❌ File does not exist: ${file.path}');
        _userProfiles[_currentUserId!] = user.copyWith(profileImageFile: null);
      }
    } else {
      await StorageService.saveProfileImageFilePath(_currentUserId!, null);
      print('✅ Profile image file removed for user $_currentUserId');
    }

    _safeNotifyListeners();
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ ОБЛОЖКИ
  Future<void> updateCoverImageUrl(String? url) async {
    if (_isDisposed || _currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    // Валидация URL
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (!uri.hasScheme) {
          url = 'https://$url';
        }
      } catch (e) {
        print('❌ Invalid cover URL: $e');
        return;
      }
    }

    _userProfiles[_currentUserId!] = user.copyWith(coverImageUrl: url);
    _safeNotifyListeners();
    await StorageService.saveCoverImageUrl(_currentUserId!, url);
    print('✅ Cover image URL updated for user $_currentUserId: $url');
  }

  Future<void> updateCoverImageFile(File? file) async {
    if (_isDisposed || _currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(coverImageFile: file);

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        await StorageService.saveCoverImageFilePath(_currentUserId!, file.path);
        print('✅ Cover image file updated for user $_currentUserId: ${file.path}');
      } else {
        print('❌ Cover file does not exist: ${file.path}');
        _userProfiles[_currentUserId!] = user.copyWith(coverImageFile: null);
      }
    } else {
      await StorageService.saveCoverImageFilePath(_currentUserId!, null);
      print('✅ Cover image file removed for user $_currentUserId');
    }

    _safeNotifyListeners();
  }

  // Загрузка данных профиля пользователя
  Future<void> _loadUserProfileData(String userId) async {
    if (_isDisposed) return;

    try {
      // Загружаем URL аватарки
      final savedUrl = await StorageService.loadProfileImageUrl(userId);

      // Загружаем файл аватарки
      final savedFilePath = await StorageService.loadProfileImageFilePath(userId);
      File? profileFile;
      if (savedFilePath != null && savedFilePath.isNotEmpty) {
        final file = File(savedFilePath);
        if (await file.exists()) {
          profileFile = file;
        } else {
          await StorageService.saveProfileImageFilePath(userId, null);
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
        } else {
          await StorageService.saveCoverImageFilePath(userId, null);
        }
      }

      // Обновляем профиль
      if (_userProfiles.containsKey(userId)) {
        _userProfiles[userId] = _userProfiles[userId]!.copyWith(
          profileImageUrl: savedUrl,
          profileImageFile: profileFile,
          coverImageUrl: savedCoverUrl,
          coverImageFile: coverFile,
        );
      }

      print('✅ Profile data loaded for user $userId');
      _safeNotifyListeners();
    } catch (e) {
      print('❌ Error loading profile data for user $userId: $e');
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

  // МЕТОДЫ ДЛЯ РЕПОСТА
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
      // СНАЧАЛА загружаем из кэша для мгновенного отображения
      final cachedNews = await StorageService.loadNews();
      if (cachedNews.isNotEmpty) {
        _safeOperation(() {
          _news = cachedNews;
          _safeNotifyListeners();
        });
        print('📂 Loaded ${_news.length} news from cache');
      }

      // ПОТОМ пытаемся обновить из API (в фоне)
      try {
        final apiNews = await ApiService.getNews();
        if (apiNews.isNotEmpty) {
          final localLikes = await StorageService.loadLikes();
          final localBookmarks = await StorageService.loadBookmarks();
          final userTags = await StorageService.loadUserTags();

          final updatedNews = await Future.wait(apiNews.map((newsItem) async {
            final newsId = newsItem['id'].toString();

            // ПРОВЕРЯЕМ на дублирование
            if (_containsNewsWithId(newsId)) {
              print('⚠️ Skipping duplicate news from API: $newsId');
              return _news.firstWhere((item) => item['id'].toString() == newsId);
            }

            // ИСПРАВЛЕНИЕ: Правильное получение user_tags
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

            // ВАЖНОЕ ИСПРАВЛЕНИЕ: Сохраняем аватар автора из API данных
            final authorName = newsItem['author_name']?.toString() ?? 'Пользователь';
            final authorAvatarFromApi = newsItem['author_avatar']?.toString() ?? '';

            // Определяем финальный аватар: приоритет у API, затем fallback
            String finalAuthorAvatar;
            if (authorAvatarFromApi.isNotEmpty) {
              finalAuthorAvatar = authorAvatarFromApi;
              print('✅ Using author avatar from API: $authorAvatarFromApi for $authorName');
            } else {
              finalAuthorAvatar = _getFallbackAvatarUrl(authorName);
              print('ℹ️ Using fallback avatar for $authorName: $finalAuthorAvatar');
            }

            return {
              ...newsItem,
              'isLiked': localLikes.contains(newsId),
              'isBookmarked': localBookmarks.contains(newsId),
              'hashtags': _parseHashtags(newsItem['hashtags']),
              'user_tags': itemUserTags,
              'comments': newsItem['comments'] ?? [],
              'likes': newsItem['likes'] ?? 0,
              'tag_color': tagColor,
              // ВАЖНОЕ ИСПРАВЛЕНИЕ: Сохраняем аватар автора
              'author_avatar': finalAuthorAvatar,
            };
          }));

          // ОБНОВЛЯЕМ данные только если API вернул новые данные
          final newItems = updatedNews.where((item) =>
          !_containsNewsWithId(item['id'].toString())).toList();

          if (newItems.isNotEmpty) {
            _safeOperation(() {
              _news.insertAll(0, newItems);
            });
            await _saveNewsToStorage();
            print('🔄 Updated news from API: ${newItems.length} new items');

            // Логируем аватары для отладки
            for (final item in newItems.take(3)) {
              final author = item['author_name'] ?? 'Unknown';
              final avatar = item['author_avatar'] ?? 'No avatar';
              print('👤 New item - Author: $author, Avatar: $avatar');
            }
          } else {
            print('⚠️ No new items from API, keeping cached data');
          }
        } else {
          print('⚠️ API returned empty list, keeping cached data');
        }
      } catch (apiError) {
        print('⚠️ API update failed, using cached data: $apiError');
        // Продолжаем использовать кэшированные данные
      }

    } catch (e) {
      print('❌ Both cache and API failed: $e');
      _safeOperation(() {
        _errorMessage = 'Ошибка загрузки данных';
      });

      // Используем mock данные только если совсем ничего нет
      if (_news.isEmpty) {
        final mockNews = _getMockNews();
        _safeOperation(() {
          _news = mockNews;
        });
        await _saveNewsToStorage();
        print('🔄 Using mock data: ${_news.length} items');
      }
    } finally {
      _safeOperation(() {
        _isLoading = false;
        _safeNotifyListeners();
      });
      initializeInteractions();
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

    // Генерируем индекс на основе хеша имени для консистентности
    final index = userName.hashCode.abs() % avatars.length;
    final selectedAvatar = avatars[index];

    print('🎲 Generated fallback avatar for $userName: $selectedAvatar (index: $index)');
    return selectedAvatar;
  }

  List<dynamic> _getMockNews() {
    return MockNewsData.getMockNews();
  }

  // ИСПРАВЛЕННЫЙ МЕТОД ДОБАВЛЕНИЯ НОВОСТИ
  Future<void> addNews(Map<String, dynamic> newsItem, {BuildContext? context}) async {
    if (_isDisposed) return;

    try {
      // ПРОВЕРЯЕМ на дублирование по ID - более строгая проверка
      final newNewsId = newsItem['id']?.toString();
      if (newNewsId != null) {
        // Проверяем все возможные форматы ID
        final exists = _news.any((item) {
          final itemId = item['id']?.toString();
          return itemId == newNewsId ||
              itemId == 'post-$newNewsId' ||
              itemId == 'channel-$newNewsId' ||
              newNewsId == 'post-$itemId' ||
              newNewsId == 'channel-$itemId';
        });

        if (exists) {
          print('⚠️ News with similar ID already exists: $newNewsId, skipping...');
          return;
        }
      }

      final isChannelPost = newsItem['is_channel_post'] == true;
      final authorName = newsItem['author_name']?.toString() ?? 'Пользователь';
      final channelName = newsItem['channel_name']?.toString() ?? '';

      // СОЗДАЕМ УНИКАЛЬНЫЙ ID если не предоставлен
      final uniqueId = newsItem['id']?.toString() ?? 'news-${DateTime.now().millisecondsSinceEpoch}';

      // ВАЖНОЕ ИСПРАВЛЕНИЕ: Получаем аватар автора из переданных данных
      final authorAvatar = newsItem['author_avatar']?.toString() ?? _getFallbackAvatarUrl(authorName);

      // ВАЖНОЕ ИЗМЕНЕНИЕ: ИСПОЛЬЗУЕМ ПОСЛЕДНИЕ ТЕГИ ПОЛЬЗОВАТЕЛЯ
      Map<String, String> personalTags = <String, String>{};

      // Инициализируем UserTagsProvider для нового поста
      if (context != null) {
        try {
          final userTagsProvider = Provider.of<UserTagsProvider>(context, listen: false);
          if (userTagsProvider != null && userTagsProvider.isInitialized) {
            // Получаем последние теги пользователя
            personalTags = userTagsProvider.getLastUsedTags();
            print('✅ Используем последние теги пользователя для нового поста: $personalTags');

            // Инициализируем теги для нового поста
            await userTagsProvider.initializeTagsForNewPost(uniqueId);
            print('✅ Инициализированы теги для нового поста: $uniqueId');
          }
        } catch (e) {
          print('⚠️ Не удалось инициализировать UserTagsProvider для нового поста: $e');
        }
      }

      // АГРЕССИВНАЯ ОЧИСТКА ХЕШТЕГОВ
      List<String> cleanHashtags = [];
      if (newsItem['hashtags'] is List) {
        cleanHashtags = (newsItem['hashtags'] as List).map((tag) {
          String cleanTag;
          if (tag is String) {
            cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
          } else {
            cleanTag = tag.toString().replaceAll(RegExp(r'#'), '').trim();
          }
          cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
          return cleanTag;
        }).where((tag) => tag.isNotEmpty).toList();
      }

      // ОПРЕДЕЛЯЕМ ЦВЕТ ТЕГА - используем дефолтный
      Color tagColor = _generateColorFromId(uniqueId);

      final Map<String, dynamic> cleanNewsItem = {
        'id': uniqueId,
        'title': newsItem['title']?.toString() ?? '',
        'description': newsItem['description']?.toString() ?? '',
        'image': newsItem['image']?.toString() ?? '',
        'author_name': authorName,
        'author_avatar': authorAvatar, // ← ИСПРАВЛЕНО: сохраняем переданный аватар
        'channel_name': channelName,
        'channel_id': newsItem['channel_id']?.toString() ?? '',
        'created_at': newsItem['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        'likes': newsItem['likes'] ?? 0,
        'comments': newsItem['comments'] ?? [],
        'hashtags': cleanHashtags,
        // ВАЖНОЕ ИЗМЕНЕНИЕ: используем ПОСЛЕДНИЕ ТЕГИ пользователя
        'user_tags': personalTags,
        'isLiked': newsItem['isLiked'] ?? false,
        'isBookmarked': newsItem['isBookmarked'] ?? false,
        'isFollowing': newsItem['isFollowing'] ?? false,
        'tag_color': tagColor.value,
        'is_channel_post': isChannelPost,
        'content_type': isChannelPost ? 'channel_post' : 'regular_post',
      };

      // ДОБАВЛЯЕМ в начало списка
      _safeOperation(() {
        _news.insert(0, cleanNewsItem);
        _safeNotifyListeners();
      });

      // НЕМЕДЛЕННО сохраняем в хранилище
      await _saveNewsToStorage();

      // ИНИЦИАЛИЗИРУЕМ взаимодействия для новой новости
      final interactionManager = InteractionManager();
      interactionManager.initializePostState(
        postId: uniqueId,
        isLiked: cleanNewsItem['isLiked'],
        isBookmarked: cleanNewsItem['isBookmarked'],
        isReposted: cleanNewsItem['isReposted'] ?? false,
        likesCount: cleanNewsItem['likes'],
        repostsCount: cleanNewsItem['reposts'] ?? 0,
        comments: List<Map<String, dynamic>>.from(cleanNewsItem['comments'] ?? []),
      );

      print('✅ Новость добавлена в NewsProvider. ID: $uniqueId, Автор: $authorName, Аватар: $authorAvatar, Теги: $personalTags, Всего новостей: ${_news.length}');

    } catch (e) {
      print('❌ Ошибка при добавлении новости в NewsProvider: $e');
      // Показываем ошибку пользователю если контекст доступен
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

  Future<void> repostNews(int index, String currentUserId, String currentUserName) async {
    if (_isDisposed || !_isValidIndex(index)) return;

    try {
      final originalNews = Map<String, dynamic>.from(_news[index]);
      final originalNewsId = originalNews['id'].toString();

      // Проверяем, не существует ли уже репост
      final existingRepost = getRepostIdForOriginal(originalNewsId, currentUserId);
      if (existingRepost != null) {
        print('⚠️ Repost already exists: $existingRepost');
        return;
      }

      // Создаем уникальный ID для репоста
      final repostId = 'repost-${DateTime.now().millisecondsSinceEpoch}-$currentUserId';

      print('🔄 Creating repost: $repostId for user: $currentUserId');

      // Получаем аватар текущего пользователя
      final currentUserAvatar = _getCurrentUserAvatarUrl(currentUserId);

      // Создаем данные репоста
      final repostData = {
        'id': repostId,
        'original_post_id': originalNewsId,
        'is_repost': true,
        'reposted_by': currentUserId,
        'reposted_by_name': currentUserName,
        'reposted_at': DateTime.now().toIso8601String(),
        'title': originalNews['title'] ?? '',
        'description': originalNews['description'] ?? '',
        'image': originalNews['image'] ?? '',
        'author_name': currentUserName,
        'author_avatar': currentUserAvatar,
        'channel_name': originalNews['channel_name'] ?? '',
        'channel_id': originalNews['channel_id'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'likes': 0,
        'comments': [],
        'hashtags': List<String>.from(originalNews['hashtags'] ?? []),
        'user_tags': <String, String>{},
        'isLiked': false,
        'isBookmarked': false,
        'isFollowing': false,
        'tag_color': _generateColorFromId(repostId).value,
        'is_channel_post': false,
        'content_type': 'repost',
        'original_author': originalNews['author_name'] ?? 'Пользователь',
        'repost_user_avatar': currentUserAvatar,
      };

      // Добавляем репост в начало ленты
      _safeOperation(() {
        _news.insert(0, repostData);
        _safeNotifyListeners();
      });

      // Сохраняем в хранилище
      await _saveNewsToStorage();

      // Сохраняем информацию о репосте
      await StorageService.addRepost(currentUserId, repostId, originalNewsId);

      print('✅ Репост создан: $repostId');
      print('📊 Total news after repost: ${_news.length}');

    } catch (e) {
      print('❌ Ошибка при репосте: $e');
      rethrow;
    }
  }





  Future<void> cancelRepost(String repostId, String currentUserId) async {
    if (_isDisposed) return;

    try {
      // Находим индекс репоста
      final repostIndex = _news.indexWhere((item) =>
      item['id'].toString() == repostId &&
          item['is_repost'] == true);

      if (repostIndex != -1) {
        _safeOperation(() {
          _news.removeAt(repostIndex);
          _safeNotifyListeners();
        });

        // Удаляем из хранилища
        await _saveNewsToStorage();
        await StorageService.removeRepost(currentUserId, repostId);

        print('✅ Репост отменен: $repostId');
      }
    } catch (e) {
      print('❌ Ошибка при отмене репоста: $e');
      rethrow;
    }
  }


  List<dynamic> getUserReposts(String userId) {
    if (_isDisposed) return [];

    return _news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['is_repost'] == true &&
          newsItem['reposted_by'] == userId;
    }).toList();
  }

// Проверка, является ли пост репостом пользователя
  bool isNewsRepostedByUser(String newsId, String userId) {
    if (_isDisposed) return false;

    return _news.any((item) {
      final newsItem = Map<String, dynamic>.from(item);
      final isRepost = newsItem['is_repost'] == true;
      final isRepostedByUser = newsItem['reposted_by'] == userId;
      final isOriginalPost = newsItem['original_post_id'] == newsId;

      return isRepost && isRepostedByUser && isOriginalPost;
    });
  }


  String? getRepostIdForOriginal(String originalNewsId, String userId) {
    if (_isDisposed) return null;

    try {
      final repost = _news.firstWhere((item) {
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

  String _getCurrentUserAvatarUrl(String userId) {
    final userProfile = _userProfiles[userId];

    if (userProfile?.profileImageFile != null) {
      return userProfile!.profileImageFile!.path;
    } else if (userProfile?.profileImageUrl != null &&
        userProfile!.profileImageUrl!.isNotEmpty) {
      return userProfile.profileImageUrl!;
    } else {
      return _getFallbackAvatarUrl(userProfile?.userName ?? 'Пользователь');
    }
  }


  void _initializeInteractionManager() {
    final interactionManager = InteractionManager();

    interactionManager.setCallbacks(
      onLike: (postId, isLiked, likesCount) {
        // Обновляем состояние в NewsProvider
        final index = findNewsIndexById(postId);
        if (index != -1) {
          updateNewsLikeStatus(index, isLiked, likesCount);
        }
      },
      onBookmark: (postId, isBookmarked) {
        final index = findNewsIndexById(postId);
        if (index != -1) {
          updateNewsBookmarkStatus(index, isBookmarked);
        }
      },
      onRepost: (postId, isReposted, repostsCount, userId, userName) {
        print('🔄 NewsProvider: Repost callback received');
        print('   postId: $postId, isReposted: $isReposted');
        print('   userId: $userId, userName: $userName');

        final index = findNewsIndexById(postId);
        if (index != -1) {
          if (isReposted) {
            // Создаем репост
            print('✅ Creating repost for post $postId by user $userName');
            repostNews(index, userId, userName);
          } else {
            // Отменяем репост
            print('❌ Canceling repost for post $postId by user $userId');
            final repostId = getRepostIdForOriginal(postId, userId);
            if (repostId != null) {
              cancelRepost(repostId, userId);
            } else {
              print('⚠️ No repost ID found for original post $postId and user $userId');
            }
          }
        } else {
          print('❌ NewsProvider: Post not found with ID $postId');
        }
      },
      onComment: (postId, comment) {
        addCommentToNews(postId, comment);
      },
      onCommentRemoval: (postId, commentId) {
        final index = findNewsIndexById(postId);
        if (index != -1) {
          removeCommentFromNews(index, commentId);
        }
      },
    );

    print('✅ InteractionManager callbacks set in NewsProvider');
  }


// Обновленный метод toggleRepost для использования в UI
  // ЗАМЕНИТЕ текущий метод toggleRepost на этот:
  void toggleRepost(int index, String currentUserId, String currentUserName) {
    if (_isDisposed || !_isValidIndex(index)) return;

    final newsItem = Map<String, dynamic>.from(_news[index]);
    final newsId = newsItem['id'].toString();

    // Проверяем, не делал ли уже пользователь репост этой новости
    final existingRepostId = getRepostIdForOriginal(newsId, currentUserId);

    if (existingRepostId != null) {
      // Отменяем существующий репост
      cancelRepost(existingRepostId, currentUserId);
    } else {
      // Создаем новый репост
      repostNews(index, currentUserId, currentUserName);
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
    final interactionManager = InteractionManager();

    // Конвертируем List<dynamic> в List<Map<String, dynamic>>
    final List<Map<String, dynamic>> newsList = _news.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      } else {
        // Если элемент не Map, конвертируем его
        return {'id': item.toString(), 'isLiked': false, 'isBookmarked': false};
      }
    }).toList();

    interactionManager.bulkUpdatePostStates(newsList);
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

  void removeCoverImage() {
    if (_isDisposed || _currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageUrl: null,
      coverImageFile: null,
    );

    _safeNotifyListeners();

    // Очищаем в хранилище
    StorageService.saveCoverImageUrl(_currentUserId!, null);
    StorageService.saveCoverImageFilePath(_currentUserId!, null);

    print('✅ Cover image removed for user $_currentUserId');
  }

  bool hasProfileImage() {
    if (_isDisposed || _currentUserId == null) return false;
    final user = _userProfiles[_currentUserId!];
    return user?.profileImageUrl != null || user?.profileImageFile != null;
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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}