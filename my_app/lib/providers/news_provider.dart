// lib/providers/news_provider.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';
import '../services/storage_service.dart';

class NewsProvider with ChangeNotifier {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;

  // НОВЫЕ ПОЛЯ ДЛЯ ФОТО ПРОФИЛЯ
  String? _profileImageUrl;
  File? _profileImageFile;

  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // НОВЫЕ ГЕТТЕРЫ ДЛЯ ФОТО ПРОФИЛЯ
  String? get profileImageUrl => _profileImageUrl;
  File? get profileImageFile => _profileImageFile;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ УПРАВЛЕНИЯ ФОТО ПРОФИЛЯ
  // В NewsProvider обновите метод updateProfileImageUrl:
  void updateProfileImageUrl(String? url) async {
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

    _profileImageUrl = url;
    _profileImageFile = null;
    notifyListeners();

    // Сохраняем в хранилище
    await StorageService.saveProfileImageUrl(url);
    print('✅ Profile image URL updated: $url');
  }

  void updateProfileImageFile(File? file) {
    _profileImageFile = file;
    _profileImageUrl = null;
    notifyListeners();

    if (file != null) {
      // Проверяем существует ли файл
      file.exists().then((exists) {
        if (exists) {
          StorageService.saveProfileImageFilePath(file.path);
          print('✅ Profile image file updated: ${file.path}');
        } else {
          print('❌ File does not exist: ${file.path}');
          _profileImageFile = null;
          notifyListeners();
        }
      });
    } else {
      StorageService.saveProfileImageFilePath(null);
      print('✅ Profile image file removed');
    }
  }

  // Загрузка данных профиля из хранилища
  Future<void> loadProfileData() async {
    try {
      // Загружаем URL фото профиля
      final savedUrl = await StorageService.loadProfileImageUrl();
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _profileImageUrl = savedUrl;
      }

      // Загружаем файл фото профиля
      final savedFilePath = await StorageService.loadProfileImageFilePath();
      if (savedFilePath != null && savedFilePath.isNotEmpty) {
        final file = File(savedFilePath);
        if (await file.exists()) {
          _profileImageFile = file;
        } else {
          // Файл не существует, очищаем запись
          await StorageService.saveProfileImageFilePath(null);
          print('⚠️ Profile image file not found, clearing path');
        }
      }

      print('✅ Profile data loaded: URL=$_profileImageUrl, File=${_profileImageFile?.path}');
    } catch (e) {
      print('❌ Error loading profile data: $e');
    }
  }

  // НОВЫЙ МЕТОД: Обеспечение сохранности данных
  Future<void> ensureDataPersistence() async {
    try {
      // Сначала загружаем данные профиля
      await loadProfileData();

      // Затем загружаем новости
      final cachedNews = await StorageService.loadNews();
      if (cachedNews.isEmpty) {
        // Если данных нет, создаем начальные mock данные
        final mockNews = _getMockNews();
        await StorageService.saveNews(mockNews);
        _news = mockNews;
        notifyListeners();
        print('✅ Initial data ensured with ${mockNews.length} items');
      } else {
        // Используем кэшированные данные
        _news = cachedNews;
        notifyListeners();
        print('📂 Using cached data: ${_news.length} items');
      }
    } catch (e) {
      print('❌ Error ensuring data persistence: $e');
      // Создаем mock данные при ошибке
      final mockNews = _getMockNews();
      _news = mockNews;
      await StorageService.saveNews(mockNews);
      notifyListeners();
    }
  }

  Future<void> loadNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // СНАЧАЛА загружаем из кэша для мгновенного отображения
      final cachedNews = await StorageService.loadNews();
      if (cachedNews.isNotEmpty) {
        _news = cachedNews;
        notifyListeners();
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

          // ОБНОВЛЯЕМ данные только если API вернул данные
          _news = updatedNews;
          await StorageService.saveNews(_news);
          print('🔄 Updated news from API: ${_news.length} items');
        } else {
          print('⚠️ API returned empty list, keeping cached data');
        }
      } catch (apiError) {
        print('⚠️ API update failed, using cached data: $apiError');
        // Продолжаем использовать кэшированные данные
      }

    } catch (e) {
      print('❌ Both cache and API failed: $e');
      _errorMessage = 'Ошибка загрузки данных';

      // Используем mock данные только если совсем ничего нет
      if (_news.isEmpty) {
        _news = _getMockNews();
        await StorageService.saveNews(_news);
        print('🔄 Using mock data: ${_news.length} items');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Вспомогательный метод для парсинга хештегов
  List<String> _parseHashtags(dynamic hashtags) {
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
  String _getFallbackAvatarUrl(String userName) {
    return 'https://ui-avatars.com/api/?name=$userName&background=667eea&color=ffffff';
  }

  List<dynamic> _getMockNews() {
    return [
      {
        "id": "1",
        "title": "Добро пожаловать!",
        "description": "Это ваша первая новость. Создавайте свои посты!",
        "image": "👋",
        "likes": 1,
        "author_name": "Система",
        "created_at": DateTime.now().toIso8601String(),
        "comments": [],
        "hashtags": ["добропожаловать"],
        "user_tags": {"tag1": "Приветствие"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": true,
        "author_avatar": _getFallbackAvatarUrl("Система"),
      },
      {
        "id": "2",
        "title": "Манчестер Сити выиграл Лигу Чемпионов",
        "description": "Манчестер Сити в драматичном матче обыграл Интер со счетом 1:0",
        "image": "⚽",
        "likes": 45,
        "author_name": "Администратор",
        "created_at": "2025-09-09T16:33:18.417Z",
        "comments": [],
        "hashtags": ["футбол", "лигачемпионов"],
        "user_tags": {"tag1": "Фанат Манчестера"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": false,
        "author_avatar": _getFallbackAvatarUrl("Система"),
      },
      {
        "id": "3",
        "title": "Новый сезон Formula 1",
        "description": "Начало нового сезона Formula 1 обещает быть захватывающим с новыми правилами и командами",
        "image": "🏎️",
        "likes": 23,
        "author_name": "Спортивный обозреватель",
        "created_at": "2025-09-08T10:15:30.123Z",
        "comments": [],
        "hashtags": ["formula1", "автоспорт"],
        "user_tags": {"tag1": "Болельщик"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.red.value,
        "is_channel_post": false,
        "author_avatar": _getFallbackAvatarUrl("Система"),
      },
      {
        "id": "channel-1",
        "title": "Важное обновление системы",
        "description": "В этом обновлении мы добавили новые функции и улучшили производительность",
        "image": "📢",
        "likes": 156,
        "author_name": "Система",
        "channel_name": "Официальные новости",
        "created_at": "2025-09-10T09:00:00.000Z",
        "comments": [],
        "hashtags": ["обновление", "новости"],
        "user_tags": {"tag1": "Официально"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.purple.value,
        "is_channel_post": true,
        "author_avatar": _getFallbackAvatarUrl("Система"),
      }
    ];
  }

  // УЛУЧШЕННЫЙ МЕТОД ДОБАВЛЕНИЯ НОВОСТИ
  Future<void> addNews(Map<String, dynamic> newsItem) async {
    try {
      // СОХРАНЯЕМ оригинальные данные
      final isChannelPost = newsItem['is_channel_post'] == true;
      final authorName = newsItem['author_name']?.toString() ?? 'Пользователь';
      final channelName = newsItem['channel_name']?.toString() ?? '';

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

      final Map<String, dynamic> cleanNewsItem = {
        'id': newsItem['id']?.toString() ?? 'local-${DateTime.now().millisecondsSinceEpoch}',
        'title': newsItem['title']?.toString() ?? '',
        'description': newsItem['description']?.toString() ?? '',
        'image': newsItem['image']?.toString() ?? '',
        'author_name': authorName,
        'channel_name': channelName,
        'created_at': newsItem['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        'likes': newsItem['likes'] ?? 0,
        'comments': newsItem['comments'] ?? [],
        'hashtags': cleanHashtags,
        'user_tags': newsItem['user_tags'] ?? {'tag1': 'Новый тег'},
        'isLiked': newsItem['isLiked'] ?? false,
        'isBookmarked': newsItem['isBookmarked'] ?? false,
        'isFollowing': newsItem['isFollowing'] ?? false,
        'tag_color': newsItem['tag_color'] ?? _generateColorFromId(newsItem['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString()).value,
        'is_channel_post': isChannelPost,
      };

      // ДОБАВЛЯЕМ в начало списка
      _news.insert(0, cleanNewsItem);
      notifyListeners();

      // НЕМЕДЛЕННО сохраняем в хранилище
      await StorageService.saveNews(_news);

      print('✅ Новость добавлена и сохранена. Всего новостей: ${_news.length}');

    } catch (e) {
      print('❌ Ошибка при добавлении новости: $e');
      // Повторяем попытку с упрощенными данными
      try {
        final Map<String, dynamic> fallbackNews = {
          'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
          'title': newsItem['title']?.toString() ?? 'Новая новость',
          'description': newsItem['description']?.toString() ?? '',
          'author_name': newsItem['author_name']?.toString() ?? 'Пользователь',
          'created_at': DateTime.now().toIso8601String(),
          'likes': 0,
          'comments': [],
          'hashtags': [],
          'user_tags': {'tag1': 'Новый тег'},
          'isLiked': false,
          'isBookmarked': false,
          'isFollowing': false,
          'tag_color': Colors.blue.value,
          'is_channel_post': false,
        };

        _news.insert(0, fallbackNews);
        notifyListeners();
        await StorageService.saveNews(_news);
        print('✅ Новость добавлена через fallback');
      } catch (e2) {
        print('❌ Критическая ошибка при добавлении новости: $e2');
        // Даже при критической ошибке добавляем в память
        _news.insert(0, {
          'id': 'emergency-${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Новая запись',
          'description': newsItem['description']?.toString() ?? '',
          'author_name': 'Пользователь',
          'created_at': DateTime.now().toIso8601String(),
          'likes': 0,
          'comments': [],
          'hashtags': [],
          'user_tags': {'tag1': 'Новый тег'},
          'isLiked': false,
          'isBookmarked': false,
          'isFollowing': false,
          'tag_color': Colors.blue.value,
          'is_channel_post': false,
        });
        notifyListeners();
      }
    }
  }

  void updateNews(int index, Map<String, dynamic> updatedNews) {
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

      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  // Обновление статуса лайка
  void updateNewsLikeStatus(int index, bool isLiked, int newLikesCount) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      _news[index] = {
        ...newsItem,
        'isLiked': isLiked,
        'likes': newLikesCount,
      };

      notifyListeners();

      // Сохраняем в локальное хранилище
      if (isLiked) {
        StorageService.addLike(newsId);
      } else {
        StorageService.removeLike(newsId);
      }

      StorageService.saveNews(_news);
    }
  }

  // Обновление статуса закладки
  void updateNewsBookmarkStatus(int index, bool isBookmarked) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      _news[index] = {
        ...newsItem,
        'isBookmarked': isBookmarked,
      };

      notifyListeners();

      // Сохраняем в локальное хранилище
      if (isBookmarked) {
        StorageService.addBookmark(newsId);
      } else {
        StorageService.removeBookmark(newsId);
      }

      StorageService.saveNews(_news);
    }
  }

  // Обновление статуса подписки
  void updateNewsFollowStatus(int index, bool isFollowing) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      _news[index] = {
        ...newsItem,
        'isFollowing': isFollowing,
      };

      notifyListeners();

      // Сохраняем в локальное хранилище
      if (isFollowing) {
        StorageService.addFollow(newsId);
      } else {
        StorageService.removeFollow(newsId);
      }

      StorageService.saveNews(_news);
    }
  }

  void addCommentToNews(int index, Map<String, dynamic> comment) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;

      if (newsItem['comments'] == null) {
        newsItem['comments'] = [];
      }

      // ИСПРАВЛЕНИЕ: Используем ID комментария из параметра, а не создаем новый
      final completeComment = {
        ...comment,
        'time': comment['time'] ?? DateTime.now().toIso8601String(),
      };

      // Добавляем комментарий в начало списка
      (newsItem['comments'] as List).insert(0, completeComment);
      notifyListeners();

      // Сохраняем в хранилище
      StorageService.saveNews(_news);

      print('✅ Комментарий добавлен к новости ${newsItem['id']}');
    }
  }

  void removeCommentFromNews(int index, String commentId) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;

      if (newsItem['comments'] != null) {
        final commentsList = newsItem['comments'] as List;
        final initialLength = commentsList.length;

        commentsList.removeWhere((comment) =>
        comment['id'] == commentId
        );

        if (commentsList.length < initialLength) {
          notifyListeners();
          StorageService.saveNews(_news);
          print('✅ Комментарий $commentId удален');
        }
      }
    }
  }
  void removeNews(int index) async {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final newsId = newsItem['id'].toString();

      try {
        await ApiService.deleteNews(newsId);
      } catch (e) {
        print('API delete error: $e');
      }

      // Удаляем из локальных хранилищ
      await StorageService.removeLike(newsId);
      await StorageService.removeBookmark(newsId);
      await StorageService.removeUserTags(newsId);

      _news.removeAt(index);
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  Future<void> loadUserTags() async {
    try {
      final loadedTags = await StorageService.loadUserTags();

      // Обновляем теги в новостях
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

          final tagColor = await _getTagColor(newsId, updatedUserTags);

          _news[i] = {
            ...newsItem,
            'user_tags': updatedUserTags,
            'tag_color': tagColor,
          };
        }
      }

      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки тегов: $e');
    }
  }

  void updateNewsHashtags(int index, List<String> hashtags) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      _news[index] = {
        ...newsItem,
        'hashtags': _parseHashtags(hashtags),
      };
      notifyListeners();
      StorageService.saveNews(_news);
    }
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
      notifyListeners();

      // Сохраняем тег и цвет в отдельном хранилище
      StorageService.updateUserTag(newsId, tagId, newTagName, color: tagColor.value);
      StorageService.saveNews(_news);
    }
  }

  // Поиск новостей
  List<dynamic> searchNews(String query) {
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
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['isBookmarked'] == true;
    }).toList();
  }

  // Получение популярных новостей (лайков > 5)
  List<dynamic> getPopularNews() {
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return (newsItem['likes'] ?? 0) > 5;
    }).toList();
  }

  // Получение моих новостей
  List<dynamic> getMyNews(String userName) {
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['author_name'] == userName;
    }).toList();
  }

  // Получение новости по ID
  Map<String, dynamic>? getNewsById(String id) {
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
    return _news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      return newsItem['isFollowing'] == true;
    }).toList();
  }

  // Получение постов от подписанных авторов/каналов
  Future<List<dynamic>> getFollowedContent() async {
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
    if (index >= 0 && index < _news.length) {
      final newsItem = _news[index] as Map<String, dynamic>;
      final currentViews = newsItem['views'] ?? 0;

      _news[index] = {
        ...newsItem,
        'views': currentViews + 1,
      };

      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  // ИСПРАВЛЕННЫЙ МЕТОД: Получение статистики
  Map<String, int> getStats() {
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
    return _news.any((item) => item['id'].toString() == newsId);
  }

  // Получение индекса новости по ID
  int getNewsIndexById(String newsId) {
    return _news.indexWhere((item) => item['id'].toString() == newsId);
  }

  // Обновление только определенных полей новости
  void patchNews(int index, Map<String, dynamic> partialUpdates) {
    if (index >= 0 && index < _news.length) {
      final currentNews = _news[index] as Map<String, dynamic>;
      _news[index] = {
        ...currentNews,
        ...partialUpdates,
      };
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  // Перемещение новости в начало списка
  void moveNewsToTop(int index) {
    if (index >= 0 && index < _news.length) {
      final newsItem = _news.removeAt(index);
      _news.insert(0, newsItem);
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  // Дублирование новости
  void duplicateNews(int index) {
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
      notifyListeners();
      StorageService.saveNews(_news);
    }
  }

  // Сортировка новостей по дате (сначала новые)
  void sortByDate() {
    _news.sort((a, b) {
      final dateA = DateTime.parse(a['created_at'] ?? '');
      final dateB = DateTime.parse(b['created_at'] ?? '');
      return dateB.compareTo(dateA);
    });
    notifyListeners();
    StorageService.saveNews(_news);
  }

  // Сортировка новостей по лайкам
  void sortByLikes() {
    _news.sort((a, b) {
      final likesA = a['likes'] ?? 0;
      final likesB = b['likes'] ?? 0;
      return likesB.compareTo(likesA);
    });
    notifyListeners();
    StorageService.saveNews(_news);
  }

  // Очистка всех данных
  Future<void> clearAllData() async {
    _news = [];
    _isLoading = false;
    _errorMessage = null;
    _profileImageUrl = null;
    _profileImageFile = null;
    await StorageService.clearAllData();
    notifyListeners();
  }

  // Обновление нескольких новостей
  void updateMultipleNews(List<Map<String, dynamic>> updatedNewsList) {
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

    notifyListeners();
    StorageService.saveNews(_news);
  }

  // Восстановление из резервной копии
  Future<void> restoreFromBackup(List<dynamic> backupData) async {
    _news = backupData;
    await StorageService.saveNews(_news);
    notifyListeners();
  }

  // Создание резервной копии
  List<dynamic> createBackup() {
    return List<dynamic>.from(_news);
  }

  // НОВЫЙ МЕТОД: Удаление фото профиля
  void removeProfileImage() {
    _profileImageUrl = null;
    _profileImageFile = null;
    notifyListeners();

    // Очищаем в хранилище
    StorageService.saveProfileImageUrl(null);
    StorageService.saveProfileImageFilePath(null);

    print('✅ Profile image removed');
  }

  // НОВЫЙ МЕТОД: Проверка наличия фото профиля
  bool hasProfileImage() {
    return _profileImageUrl != null || _profileImageFile != null;
  }

  // НОВЫЙ МЕТОД: Получение текущего фото профиля (приоритет у файла)
  dynamic getCurrentProfileImage() {
    // Приоритет у файла, затем URL
    if (_profileImageFile != null) return _profileImageFile;
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) return _profileImageUrl;
    return null;
  }
}