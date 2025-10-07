// lib/services/storage_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _newsKey = 'cached_news';
  static const String _likesKey = 'user_likes';
  static const String _bookmarksKey = 'user_bookmarks';
  static const String _userTagsKey = 'user_tags';
  static const String _tagColorsKey = 'tag_colors';

  // ========== НОВОСТИ ==========
  static Future<void> saveNews(List<dynamic> news) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('🔍 DEBUG: Starting saveNews with ${news.length} items');

      final List<Map<String, dynamic>> serializableNews = [];

      for (int i = 0; i < news.length; i++) {
        try {
          final item = news[i];
          if (item is Map) {
            // ПРЕОБРАЗУЕМ ЛЮБОЙ TYPESCRIPT MAP В ОБЫЧНЫЙ MAP
            final cleanItem = _convertToPlainMap(item);
            serializableNews.add(cleanItem);
          }
        } catch (e) {
          print('❌ Error processing news item $i: $e');
        }
      }

      final jsonString = json.encode(serializableNews);
      await prefs.setString(_newsKey, jsonString);
      print('💾 Сохранено новостей: ${serializableNews.length}');

    } catch (e) {
      print('❌ Ошибка сохранения новостей: $e');
      // Fallback: попробуем сохранить простым способом
      try {
        final prefs = await SharedPreferences.getInstance();
        final simpleNews = news.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return item;
        }).toList();
        await prefs.setString(_newsKey, json.encode(simpleNews));
        print('💾 Сохранено упрощенным методом');
      } catch (e2) {
        print('❌ Критическая ошибка сохранения: $e2');
      }
    }
  }

// ДОБАВЬТЕ ЭТОТ МЕТОД
  static Map<String, dynamic> _convertToPlainMap(dynamic input) {
    if (input is Map<String, dynamic>) {
      return input;
    }

    if (input is Map) {
      final result = <String, dynamic>{};
      input.forEach((key, value) {
        final stringKey = key.toString();

        if (value is Map) {
          result[stringKey] = _convertToPlainMap(value);
        } else if (value is List) {
          result[stringKey] = _convertListToPlain(value);
        } else {
          result[stringKey] = value;
        }
      });
      return result;
    }

    return {};
  }

  static List<dynamic> _convertListToPlain(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertToPlainMap(item);
      } else if (item is List) {
        return _convertListToPlain(item);
      } else {
        return item;
      }
    }).toList();
  }

// Метод для отладки типов Map
  static void _debugMapTypes(dynamic map, String label) {
    if (map is Map) {
      print('   $label: ${map.runtimeType}');
      map.forEach((key, value) {
        if (value is Map) {
          _debugMapTypes(value, '   $key');
        }
      });
    }
  }

// Метод для глубокой очистки Map
  static Map<String, dynamic> _deepCleanMap(dynamic input) {
    if (input is! Map) {
      return {};
    }

    final Map<String, dynamic> result = {};

    input.forEach((key, value) {
      final String stringKey = key.toString();

      if (value is Map) {
        // Рекурсивно очищаем вложенные Map
        result[stringKey] = _deepCleanMap(value);
      } else if (value is List) {
        // Обрабатываем списки
        result[stringKey] = _deepCleanList(value);
      } else {
        // Простые значения
        result[stringKey] = value;
      }
    });

    return result;
  }

// Метод для очистки списков
  static List<dynamic> _deepCleanList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _deepCleanMap(item);
      } else if (item is List) {
        return _deepCleanList(item);
      } else {
        return item;
      }
    }).toList();
  }




// Вспомогательный метод для преобразования Map
  static Map<String, String> _convertMapToStringString(dynamic map) {
    if (map is Map<String, String>) {
      return map;
    }
    if (map is Map) {
      return map.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {'tag1': 'Новый тег'};
  }

  static Future<List<dynamic>> loadNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_newsKey);
      if (data != null) {
        final cachedData = json.decode(data) as List<dynamic>;

        // Загружаем пользовательские теги для обновления данных
        final userTags = await loadUserTags();
        final tagColors = await loadTagColors();

        final news = cachedData.map((item) {
          final map = item as Map<String, dynamic>;
          final newsId = map['id']?.toString() ?? '';

          // ИСПРАВЛЕНИЕ: Правильное преобразование user_tags
          Map<String, String> updatedUserTags = _convertMapToStringString(map['user_tags'] ?? {'tag1': 'Новый тег'});

          if (userTags.containsKey(newsId)) {
            final newsTags = userTags[newsId]!;
            if (newsTags['tags'] is Map) {
              updatedUserTags = _convertMapToStringString(newsTags['tags']);
            }
          }

          final tagColor = tagColors[newsId] ?? map['tag_color'] ?? _generateDefaultColor(newsId).value;

          return {
            ...map,
            'hashtags': map['hashtags'] ?? [],
            'user_tags': updatedUserTags,
            'likes': map['likes'] ?? 0,
            'comments': map['comments'] ?? [],
            'isLiked': map['isLiked'] ?? false,
            'isBookmarked': map['isBookmarked'] ?? false,
            'tag_color': tagColor,
          };
        }).toList();

        print('📂 Загружено новостей: ${news.length}');
        return news;
      }
    } catch (e) {
      print('❌ Ошибка загрузки новостей: $e');
    }
    return [];
  }

  // ========== ЛАЙКИ ==========
  static Future<void> saveLikes(Set<String> likedNewsIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_likesKey, likedNewsIds.toList());
      print('💖 Сохранено лайков: ${likedNewsIds.length}');
    } catch (e) {
      print('❌ Ошибка сохранения лайков: $e');
    }
  }

  static Future<Set<String>> loadLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likes = prefs.getStringList(_likesKey);
      final result = likes != null ? Set<String>.from(likes) : <String>{};
      print('❤️ Загружено лайков: ${result.length}');
      return result;
    } catch (e) {
      print('❌ Ошибка загрузки лайков: $e');
      return <String>{};
    }
  }

  static Future<void> addLike(String newsId) async {
    try {
      final likes = await loadLikes();
      likes.add(newsId);
      await saveLikes(likes);
      print('➕ Лайк добавлен: $newsId');
    } catch (e) {
      print('❌ Ошибка добавления лайка: $e');
    }
  }

  static Future<void> removeLike(String newsId) async {
    try {
      final likes = await loadLikes();
      likes.remove(newsId);
      await saveLikes(likes);
      print('➖ Лайк удален: $newsId');
    } catch (e) {
      print('❌ Ошибка удаления лайка: $e');
    }
  }

  // ========== ЗАКЛАДКИ ==========
  static Future<void> saveBookmarks(Set<String> bookmarkedNewsIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_bookmarksKey, bookmarkedNewsIds.toList());
      print('🔖 Сохранено закладок: ${bookmarkedNewsIds.length}');
    } catch (e) {
      print('❌ Ошибка сохранения закладок: $e');
    }
  }

  static Future<Set<String>> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_bookmarksKey);
      final result = bookmarks != null ? Set<String>.from(bookmarks) : <String>{};
      print('📑 Загружено закладок: ${result.length}');
      return result;
    } catch (e) {
      print('❌ Ошибка загрузки закладок: $e');
      return <String>{};
    }
  }

  static Future<void> addBookmark(String newsId) async {
    try {
      final bookmarks = await loadBookmarks();
      bookmarks.add(newsId);
      await saveBookmarks(bookmarks);
      print('📌 Закладка добавлена: $newsId');
    } catch (e) {
      print('❌ Ошибка добавления закладки: $e');
    }
  }

  static Future<void> removeBookmark(String newsId) async {
    try {
      final bookmarks = await loadBookmarks();
      bookmarks.remove(newsId);
      await saveBookmarks(bookmarks);
      print('🗑️ Закладка удалена: $newsId');
    } catch (e) {
      print('❌ Ошибка удаления закладки: $e');
    }
  }

  // ========== ПОЛЬЗОВАТЕЛЬСКИЕ ТЕГИ ==========
  static Future<void> saveUserTags(Map<String, Map<String, dynamic>> userTags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serializedTags = userTags.map((key, value) => MapEntry(key, value));
      await prefs.setString(_userTagsKey, json.encode(serializedTags));
      print('💾 Сохранено тегов для ${userTags.length} новостей');
    } catch (e) {
      print('❌ Ошибка сохранения тегов: $e');
    }
  }

  static Future<Map<String, Map<String, dynamic>>> loadUserTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_userTagsKey);

      if (data != null) {
        final decoded = json.decode(data) as Map<String, dynamic>;
        final userTags = <String, Map<String, dynamic>>{};

        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            userTags[key] = value;
          } else if (value is Map) {
            userTags[key] = Map<String, dynamic>.from(value);
          } else {
            userTags[key] = {
              'tags': {'tag1': 'Новый тег'},
              'last_updated': DateTime.now().toIso8601String()
            };
          }
        });

        print('📂 Загружено тегов для ${userTags.length} новостей');
        return userTags;
      }
    } catch (e) {
      print('❌ Ошибка загрузки тегов: $e');
    }
    return {};
  }

  static Future<Map<String, String>> getUserTagsForNews(String newsId) async {
    try {
      final userTags = await loadUserTags();
      if (userTags.containsKey(newsId)) {
        final newsTags = userTags[newsId]!;
        if (newsTags['tags'] is Map) {
          final tagsMap = newsTags['tags'] as Map;
          return tagsMap.map((key, value) =>
              MapEntry(key.toString(), value.toString())
          );
        }
      }
    } catch (e) {
      print('❌ Ошибка получения тегов для новости: $e');
    }
    return {'tag1': 'Новый тег'};
  }

  static Future<void> updateUserTag(String newsId, String tagId, String tagName, {int? color}) async {
    try {
      final userTags = await loadUserTags();
      final newsTags = userTags[newsId] ?? {};

      // Получаем текущие теги
      Map<String, String> currentTags = {'tag1': 'Новый тег'};
      if (newsTags['tags'] is Map) {
        final tagsMap = newsTags['tags'] as Map;
        currentTags = tagsMap.map((key, value) =>
            MapEntry(key.toString(), value.toString())
        );
      }

      // Обновляем тег
      currentTags[tagId] = tagName;

      // Сохраняем обновленную структуру
      newsTags['tags'] = currentTags;
      newsTags['last_updated'] = DateTime.now().toIso8601String();

      if (color != null) {
        newsTags['color'] = color;
        await saveTagColor(newsId, color);
      }

      userTags[newsId] = newsTags;
      await saveUserTags(userTags);
      print('🎨 Тег обновлен: $tagName (новость: $newsId)');

    } catch (e) {
      print('❌ Ошибка обновления тега: $e');
    }
  }

  // В lib/services/storage_service.dart ДОБАВЬТЕ:
  static Future<void> ensureDataPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasData = prefs.containsKey(_newsKey);

      if (!hasData) {
        // Если данных нет, создаем начальные mock данные
        final mockNews = [
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
          }
        ];
        await saveNews(mockNews);
      }
    } catch (e) {
      print('Error ensuring data persistence: $e');
    }
  }

  static Future<void> removeUserTags(String newsId) async {
    try {
      final userTags = await loadUserTags();
      userTags.remove(newsId);
      await saveUserTags(userTags);

      await removeTagColor(newsId);
      print('🗑️ Теги удалены для новости: $newsId');
    } catch (e) {
      print('❌ Ошибка удаления тегов: $e');
    }
  }

  // ========== ЦВЕТА ТЕГОВ ==========
  static Future<void> saveTagColors(Map<String, int> tagColors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tagColorsKey, json.encode(tagColors));
    } catch (e) {
      print('❌ Ошибка сохранения цветов тегов: $e');
    }
  }

  static Future<Map<String, int>> loadTagColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_tagColorsKey);
      if (data != null) {
        final decoded = json.decode(data) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value as int));
      }
    } catch (e) {
      print('❌ Ошибка загрузки цветов тегов: $e');
    }
    return {};
  }

  static Future<void> saveTagColor(String newsId, int color) async {
    try {
      final tagColors = await loadTagColors();
      tagColors[newsId] = color;
      await saveTagColors(tagColors);
    } catch (e) {
      print('❌ Ошибка сохранения цвета тега: $e');
    }
  }

  static Future<int?> getTagColor(String newsId) async {
    try {
      final tagColors = await loadTagColors();
      return tagColors[newsId];
    } catch (e) {
      print('❌ Ошибка получения цвета тега: $e');
      return null;
    }
  }

  static Future<void> removeTagColor(String newsId) async {
    try {
      final tagColors = await loadTagColors();
      tagColors.remove(newsId);
      await saveTagColors(tagColors);
    } catch (e) {
      print('❌ Ошибка удаления цвета тега: $e');
    }
  }

  // ========== МЕТОДЫ ДЛЯ ОЧИСТКИ ХЕШТЕГОВ ==========

  // Метод для очистки хештегов от дубликатов и лишних символов

  static List<String> _cleanHashtagsForStorage(dynamic hashtags) {
    if (hashtags == null) return [];

    List<String> tags = [];

    if (hashtags is String) {
      tags = hashtags.split(RegExp(r'[,\s]+'));
    } else if (hashtags is List) {
      tags = hashtags.map((e) => e.toString()).toList();
    }

    // Используем унифицированную очистку
    final cleanedTags = tags
        .map((tag) => _cleanSingleHashtag(tag))
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    print('🧹 Cleaned hashtags for storage: $cleanedTags');
    return cleanedTags;
  }

// Добавьте статический метод очистки
  static String _cleanSingleHashtag(String tag) {
    var cleanTag = tag.trim();
    cleanTag = cleanTag.replaceAll(RegExp(r'^#+|#+$'), '').trim();
    cleanTag = cleanTag.replaceAll(RegExp(r'#+'), ' ').trim();
    return cleanTag;
  }


  // Добавьте эти методы в StorageService:

// Сохранение подписки
  static Future<void> addFollow(String newsId) async {
    try {
      final follows = await loadFollows();
      if (!follows.contains(newsId)) {
        follows.add(newsId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('user_follows', follows);
      }
    } catch (e) {
      print('Error adding follow: $e');
    }
  }

// Удаление подписки
  static Future<void> removeFollow(String newsId) async {
    try {
      final follows = await loadFollows();
      follows.remove(newsId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_follows', follows);
    } catch (e) {
      print('Error removing follow: $e');
    }
  }

// Загрузка списка подписок
  static Future<List<String>> loadFollows() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('user_follows') ?? [];
    } catch (e) {
      print('Error loading follows: $e');
      return [];
    }
  }

  // Метод для отладки сохраненных хештегов
  static void _debugSavedHashtags(List<dynamic> newsData) {
    print('🔍 DEBUG SAVED HASHTAGS:');
    for (var item in newsData) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] ?? 'unknown';
      final hashtags = map['hashtags'] ?? [];
      print('   News $id: $hashtags (${hashtags.length} tags)');
    }
    print('---');
  }

  // Метод для отладки загруженных хештегов
  static void _debugLoadedHashtags(List<dynamic> news) {
    print('🔍 DEBUG LOADED HASHTAGS:');
    for (var item in news) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] ?? 'unknown';
      final hashtags = map['hashtags'] ?? [];
      print('   News $id: $hashtags (${hashtags.length} tags)');

      // Детальная информация о каждом хештеге
      if (hashtags is List && hashtags.isNotEmpty) {
        for (int i = 0; i < hashtags.length; i++) {
          print('     [$i]: "${hashtags[i]}"');
        }
      }
    }
    print('---');
  }

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========
  static Color _generateDefaultColor(String id) {
    final colors = [
      const Color(0xFF2196F3), // Синий
      const Color(0xFF4CAF50), // Зеленый
      const Color(0xFFFF9800), // Оранжевый
      const Color(0xFF9C27B0), // Фиолетовый
      const Color(0xFFF44336), // Красный
      const Color(0xFF00BCD4), // Бирюзовый
      const Color(0xFFE91E63), // Розовый
      const Color(0xFF795548), // Коричневый
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // ========== СТАТИСТИКА ==========
  static Future<Map<String, int>> getStorageStats() async {
    try {
      final news = await loadNews();
      final likes = await loadLikes();
      final bookmarks = await loadBookmarks();
      final userTags = await loadUserTags();
      final tagColors = await loadTagColors();

      return {
        'news_count': news.length,
        'likes_count': likes.length,
        'bookmarks_count': bookmarks.length,
        'tagged_news_count': userTags.length,
        'colored_tags_count': tagColors.length,
      };
    } catch (e) {
      print('❌ Ошибка получения статистики: $e');
      return {};
    }
  }

  // ========== ОЧИСТКА ДАННЫХ ==========
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_newsKey);
      await prefs.remove(_likesKey);
      await prefs.remove(_bookmarksKey);
      await prefs.remove(_userTagsKey);
      await prefs.remove(_tagColorsKey);
      print('🧹 Все данные очищены');
    } catch (e) {
      print('❌ Ошибка очистки данных: $e');
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_newsKey);
      print('🗂️ Кэш новостей очищен');
    } catch (e) {
      print('❌ Ошибка очистки кэша: $e');
    }
  }

  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_likesKey);
      await prefs.remove(_bookmarksKey);
      await prefs.remove(_userTagsKey);
      await prefs.remove(_tagColorsKey);
      print('👤 Пользовательские данные очищены');
    } catch (e) {
      print('❌ Ошибка очистки пользовательских данных: $e');
    }
  }
}