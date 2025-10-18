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

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool get mounted => !_isDisposed;
  // НОВЫЕ ПОЛЯ ДЛЯ ФОТО ПРОФИЛЯ
  String? _profileImageUrl;
  File? _profileImageFile;

  // Флаг для отслеживания disposed состояния
  bool _isDisposed = false;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // НОВЫЕ ГЕТТЕРЫ ДЛЯ ФОТО ПРОФИЛЯ
  String? get profileImageUrl => _profileImageUrl;
  File? get profileImageFile => _profileImageFile;

  // Геттер для проверки disposed состояния
  bool get isDisposed => _isDisposed;

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

  // НОВЫЕ МЕТОДЫ ДЛЯ УПРАВЛЕНИЯ ФОТО ПРОФИЛЯ
  Future<void> updateProfileImageUrl(String? url) async {
    if (_isDisposed) return;

    if (url != null && url.isNotEmpty) {
      // Проверяем валидность URL перед сохранением
      try {
        final uri = Uri.parse(url);
        if (!uri.hasScheme) {
          url = 'https://$url';
        }

        // Проверяем доступность изображения
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

    _safeOperation(() {
      _profileImageUrl = url;
      _profileImageFile = null;
      _safeNotifyListeners();
    });

    // Сохраняем в хранилище
    await StorageService.saveProfileImageUrl(url);
    print('✅ Profile image URL updated: $url');
  }

  Future<void> updateProfileImageFile(File? file) async {
    if (_isDisposed) return;

    _safeOperation(() {
      _profileImageFile = file;
      _profileImageUrl = null;
    });

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        await StorageService.saveProfileImageFilePath(file.path);
        print('✅ Profile image file updated: ${file.path}');
      } else {
        print('❌ File does not exist: ${file.path}');
        _safeOperation(() {
          _profileImageFile = null;
        });
      }
    } else {
      await StorageService.saveProfileImageFilePath(null);
      print('✅ Profile image file removed');
    }

    _safeNotifyListeners();
  }

  void clearData() {
    _safeOperation(() {
      _safeNotifyListeners();
    });
  }

  // Загрузка данных профиля из хранилища
  Future<void> loadProfileData() async {
    if (_isDisposed) return;

    try {
      // Загружаем URL фото профиля
      final savedUrl = await StorageService.loadProfileImageUrl();
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _safeOperation(() {
          _profileImageUrl = savedUrl;
        });
      }

      // Загружаем файл фото профиля
      final savedFilePath = await StorageService.loadProfileImageFilePath();
      if (savedFilePath != null && savedFilePath.isNotEmpty) {
        final file = File(savedFilePath);
        if (await file.exists()) {
          _safeOperation(() {
            _profileImageFile = file;
          });
        } else {
          // Файл не существует, очищаем запись
          await StorageService.saveProfileImageFilePath(null);
          print('⚠️ Profile image file not found, clearing path');
        }
      }

      print('✅ Profile data loaded: URL=$_profileImageUrl, File=${_profileImageFile?.path}');
      _safeNotifyListeners();
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
          StorageService.addFollow(newsId);
        } else {
          StorageService.removeFollow(newsId);
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

            return {
              ...newsItem,
              'isLiked': localLikes.contains(newsId),
              'isBookmarked': localBookmarks.contains(newsId),
              'hashtags': _parseHashtags(newsItem['hashtags']),
              'user_tags': itemUserTags,
              'comments': newsItem['comments'] ?? [],
              'likes': newsItem['likes'] ?? 0,
              'tag_color': tagColor,
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
      // Сначала загружаем данные профиля
      await loadProfileData();

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

    final index = userName.hashCode.abs() % avatars.length;
    return avatars[index];
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
        // ДОБАВЛЯЕМ АВАТАРКУ АВТОРА - используем локальную аватарку
        'author_avatar': newsItem['author_avatar'] ?? _getFallbackAvatarUrl(authorName),
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

      print('✅ Новость добавлена в NewsProvider. ID: $uniqueId, Теги: $personalTags, Всего новостей: ${_news.length}');

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

  // ЗАМЕНИТЕ метод removeNews на этот:
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
      final followedIds = await StorageService.loadFollows();
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
      _profileImageUrl = null;
      _profileImageFile = null;
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

  // НОВЫЙ МЕТОД: Удаление фото профиля
  void removeProfileImage() {
    _safeOperation(() {
      _profileImageUrl = null;
      _profileImageFile = null;
      _safeNotifyListeners();
    });

    // Очищаем в хранилище
    StorageService.saveProfileImageUrl(null);
    StorageService.saveProfileImageFilePath(null);

    print('✅ Profile image removed');
  }

  // НОВЫЙ МЕТОД: Проверка наличия фото профиля
  bool hasProfileImage() {
    if (_isDisposed) return false;
    return _profileImageUrl != null || _profileImageFile != null;
  }

  // НОВЫЙ МЕТОД: Получение текущего фото профиля (приоритет у файла)
  dynamic getCurrentProfileImage() {
    if (_isDisposed) return null;
    // Приоритет у файла, затем URL
    if (_profileImageFile != null) return _profileImageFile;
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) return _profileImageUrl;
    return null;
  }

  // ДОБАВИТЕ В КЛАСС NewsProvider:

// НОВЫЙ МЕТОД: Получение контента по типу
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

// НОВЫЙ МЕТОД: Обновление нескольких новостей батчем
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

// НОВЫЙ МЕТОД: Проверка дубликатов
  bool hasDuplicate(String newsId) {
    if (_isDisposed) return false;
    return _news.any((item) => item['id'].toString() == newsId);
  }

// НОВЫЙ МЕТОД: Получение последних новостей
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

// НОВЫЙ МЕТОД: Получение статистики по периодам
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