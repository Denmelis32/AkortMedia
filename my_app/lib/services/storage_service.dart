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

  // ========== НОВЫЕ КЛЮЧИ ДЛЯ МНОГОПОЛЬЗОВАТЕЛЬСКОЙ СИСТЕМЫ ==========
  static String _getUserProfileImageUrlKey(String userId) => 'profile_image_url_$userId';
  static String _getUserProfileImagePathKey(String userId) => 'profile_image_path_$userId';
  static String _getUserCoverImageUrlKey(String userId) => 'cover_image_url_$userId';
  static String _getUserCoverImagePathKey(String userId) => 'cover_image_path_$userId';
  static String _getUserFollowsKey(String userId) => 'user_follows_$userId';

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

  // ========== НОВЫЕ МЕТОДЫ ДЛЯ МНОГОПОЛЬЗОВАТЕЛЬСКОЙ СИСТЕМЫ ==========

  // ========== АВАТАРКИ ПОЛЬЗОВАТЕЛЕЙ ==========
  static Future<void> saveProfileImageUrl(String userId, String? url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserProfileImageUrlKey(userId);

      print('🔄 [STORAGE] Saving profile image URL for user: $userId');
      print('   📤 URL to save: $url');
      print('   🔑 Storage key: $key');

      if (url == null) {
        await prefs.remove(key);
        print('🗑️ [STORAGE] URL аватарки удален для пользователя: $userId');
      } else {
        await prefs.setString(key, url);

        // НЕМЕДЛЕННАЯ ПРОВЕРКА СОХРАНЕНИЯ
        final savedValue = prefs.getString(key);
        print('💾 [STORAGE] URL аватарки сохранен для пользователя: $userId');
        print('   ✅ Проверка сохранения: $savedValue');
        print('   🔍 Совпадение с исходным: ${savedValue == url}');
      }
    } catch (e) {
      print('❌ [STORAGE] Ошибка сохранения URL аватарки для пользователя $userId: $e');
    }
  }


  static Future<String?> loadProfileImageUrl(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserProfileImageUrlKey(userId);
      final url = prefs.getString(key);

      print('📂 [STORAGE] Loading profile image URL for user: $userId');
      print('   🔑 Storage key: $key');
      print('   📥 Loaded URL: $url');

      return url;
    } catch (e) {
      print(
          '❌ [STORAGE] Ошибка загрузки URL аватарки для пользователя $userId: $e');
      return null;
    }
  }

  static Future<void> saveProfileImageFilePath(String userId, String? filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserProfileImagePathKey(userId);

      print('🔄 [STORAGE] Saving profile image file path for user: $userId');
      print('   📤 File path to save: $filePath');
      print('   🔑 Storage key: $key');

      if (filePath == null) {
        await prefs.remove(key);
        print('🗑️ [STORAGE] Файл аватарки удален для пользователя: $userId');
      } else {
        await prefs.setString(key, filePath);

        // НЕМЕДЛЕННАЯ ПРОВЕРКА
        final savedValue = prefs.getString(key);
        print('💾 [STORAGE] Файл аватарки сохранен для пользователя: $userId');
        print('   ✅ Проверка сохранения: $savedValue');
        print('   🔍 Совпадение с исходным: ${savedValue == filePath}');
      }
    } catch (e) {
      print('❌ [STORAGE] Ошибка сохранения файла аватарки для пользователя $userId: $e');
    }
  }

  static Future<String?> loadProfileImageFilePath(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserProfileImagePathKey(userId);
      final path = prefs.getString(key);

      print('📂 [STORAGE] Loading profile image file path for user: $userId');
      print('   🔑 Storage key: $key');
      print('   📥 Loaded path: $path');

      return path;
    } catch (e) {
      print('❌ [STORAGE] Ошибка загрузки файла аватарки для пользователя $userId: $e');
      return null;
    }
  }

  // ========== ОБЛОЖКИ ПОЛЬЗОВАТЕЛЕЙ ==========
  static Future<void> saveCoverImageUrl(String userId, String? url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserCoverImageUrlKey(userId);
      if (url == null) {
        await prefs.remove(key);
        print('🗑️ URL обложки удален для пользователя: $userId');
      } else {
        await prefs.setString(key, url);
        print('💾 URL обложки сохранен для пользователя: $userId');
      }
    } catch (e) {
      print('❌ Ошибка сохранения URL обложки для пользователя $userId: $e');
    }
  }

  static Future<String?> loadCoverImageUrl(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserCoverImageUrlKey(userId);
      final url = prefs.getString(key);
      print('📂 URL обложки загружен для пользователя: $userId - $url');
      return url;
    } catch (e) {
      print('❌ Ошибка загрузки URL обложки для пользователя $userId: $e');
      return null;
    }
  }

  static Future<void> saveCoverImageFilePath(String userId, String? filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserCoverImagePathKey(userId);
      if (filePath == null) {
        await prefs.remove(key);
        print('🗑️ Файл обложки удален для пользователя: $userId');
      } else {
        await prefs.setString(key, filePath);
        print('💾 Файл обложки сохранен для пользователя: $userId');
      }
    } catch (e) {
      print('❌ Ошибка сохранения файла обложки для пользователя $userId: $e');
    }
  }

  static Future<String?> loadCoverImageFilePath(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserCoverImagePathKey(userId);
      final path = prefs.getString(key);
      print('📂 Файл обложки загружен для пользователя: $userId - $path');
      return path;
    } catch (e) {
      print('❌ Ошибка загрузки файла обложки для пользователя $userId: $e');
      return null;
    }
  }

  // ========== ПОДПИСКИ ПОЛЬЗОВАТЕЛЕЙ ==========
  static Future<void> addFollow(String userId, String newsId) async {
    try {
      final follows = await loadFollows(userId);
      if (!follows.contains(newsId)) {
        follows.add(newsId);
        final prefs = await SharedPreferences.getInstance();
        final key = _getUserFollowsKey(userId);
        await prefs.setStringList(key, follows);
        print('➕ Подписка добавлена для пользователя $userId: $newsId');
      }
    } catch (e) {
      print('❌ Ошибка добавления подписки для пользователя $userId: $e');
    }
  }

  static Future<void> removeFollow(String userId, String newsId) async {
    try {
      final follows = await loadFollows(userId);
      follows.remove(newsId);
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserFollowsKey(userId);
      await prefs.setStringList(key, follows);
      print('➖ Подписка удалена для пользователя $userId: $newsId');
    } catch (e) {
      print('❌ Ошибка удаления подписки для пользователя $userId: $e');
    }
  }

  static Future<List<String>> loadFollows(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserFollowsKey(userId);
      final follows = prefs.getStringList(key) ?? [];
      print('📂 Загружено подписок для пользователя $userId: ${follows.length}');
      return follows;
    } catch (e) {
      print('❌ Ошибка загрузки подписок для пользователя $userId: $e');
      return [];
    }
  }

  // ========== ОЧИСТКА ДАННЫХ ПОЛЬЗОВАТЕЛЯ ==========
  static Future<void> clearUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Очищаем данные профиля пользователя
      await prefs.remove(_getUserProfileImageUrlKey(userId));
      await prefs.remove(_getUserProfileImagePathKey(userId));
      await prefs.remove(_getUserCoverImageUrlKey(userId));
      await prefs.remove(_getUserCoverImagePathKey(userId));
      await prefs.remove(_getUserFollowsKey(userId));

      print('🧹 Данные пользователя очищены: $userId');
    } catch (e) {
      print('❌ Ошибка очистки данных пользователя $userId: $e');
    }
  }

  // ========== МИГРАЦИЯ ДАННЫХ (для обратной совместимости) ==========
  static Future<void> migrateOldUserData(String newUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Миграция старых данных (без userId) в новые (с userId)
      final oldProfileUrl = prefs.getString('profile_image_url');
      final oldProfilePath = prefs.getString('profile_image_file_path');
      final oldFollows = prefs.getStringList('user_follows') ?? [];

      if (oldProfileUrl != null) {
        await saveProfileImageUrl(newUserId, oldProfileUrl);
        await prefs.remove('profile_image_url');
        print('🔄 Мигрирован старый URL аватарки для пользователя: $newUserId');
      }

      if (oldProfilePath != null) {
        await saveProfileImageFilePath(newUserId, oldProfilePath);
        await prefs.remove('profile_image_file_path');
        print('🔄 Мигрирован старый файл аватарки для пользователя: $newUserId');
      }

      if (oldFollows.isNotEmpty) {
        for (final follow in oldFollows) {
          await addFollow(newUserId, follow);
        }
        await prefs.remove('user_follows');
        print('🔄 Мигрированы старые подписки для пользователя: $newUserId');
      }

    } catch (e) {
      print('❌ Ошибка миграции данных для пользователя $newUserId: $e');
    }
  }

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========
  static Map<String, String> _convertMapToStringString(dynamic map) {
    if (map is Map<String, String>) {
      return map;
    }
    if (map is Map) {
      return map.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {'tag1': 'Новый тег'};
  }

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

  static String _cleanSingleHashtag(String tag) {
    var cleanTag = tag.trim();
    cleanTag = cleanTag.replaceAll(RegExp(r'^#+|#+$'), '').trim();
    cleanTag = cleanTag.replaceAll(RegExp(r'#+'), ' ').trim();
    return cleanTag;
  }




  // В StorageService добавьте:
  static Future<void> addRepost(String userId, String repostId, String originalPostId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_${userId}_reposts';

      final existingReposts = await loadReposts(userId);
      existingReposts[repostId] = {
        'repostId': repostId,
        'originalPostId': originalPostId,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(key, json.encode(existingReposts));
    } catch (e) {
      print('❌ Error saving repost: $e');
    }
  }

  static Future<Map<String, dynamic>> loadReposts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_${userId}_reposts';
      final repostsJson = prefs.getString(key);

      if (repostsJson != null) {
        final Map<String, dynamic> repostsMap = Map<String, dynamic>.from(json.decode(repostsJson));
        return repostsMap;
      }
    } catch (e) {
      print('❌ Error loading reposts: $e');
    }

    return {};
  }


  static Future<void> removeRepost(String userId, String repostId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'reposts_$userId';

      final existingReposts = await loadReposts(userId);
      existingReposts.remove(repostId);

      await prefs.setString(key, json.encode(existingReposts));
      print('✅ Repost removed for user $userId: $repostId');
    } catch (e) {
      print('❌ Error removing repost: $e');
    }
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

  static Future<Map<String, int>> getUserStorageStats(String userId) async {
    try {
      final profileUrl = await loadProfileImageUrl(userId);
      final profilePath = await loadProfileImageFilePath(userId);
      final coverUrl = await loadCoverImageUrl(userId);
      final coverPath = await loadCoverImageFilePath(userId);
      final follows = await loadFollows(userId);

      return {
        'has_profile_image': (profileUrl != null || profilePath != null) ? 1 : 0,
        'has_cover_image': (coverUrl != null || coverPath != null) ? 1 : 0,
        'follows_count': follows.length,
      };
    } catch (e) {
      print('❌ Ошибка получения статистики пользователя $userId: $e');
      return {};
    }
  }

  // ========== ОЧИСТКА ВСЕХ ДАННЫХ ==========
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Очищаем общие данные
      await prefs.remove(_newsKey);
      await prefs.remove(_likesKey);
      await prefs.remove(_bookmarksKey);
      await prefs.remove(_userTagsKey);
      await prefs.remove(_tagColorsKey);

      // Очищаем все пользовательские данные
      final allKeys = prefs.getKeys();
      final userKeys = allKeys.where((key) =>
      key.contains('profile_image_url_') ||
          key.contains('profile_image_path_') ||
          key.contains('cover_image_url_') ||
          key.contains('cover_image_path_') ||
          key.contains('user_follows_')
      ).toList();

      for (final key in userKeys) {
        await prefs.remove(key);
      }

      print('🧹 Все данные очищены (включая пользовательские)');
    } catch (e) {
      print('❌ Ошибка очистки всех данных: $e');
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

  // ========== ОБЕСПЕЧЕНИЕ СОХРАННОСТИ ДАННЫХ ==========
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
      print('❌ Error ensuring data persistence: $e');
    }
  }

  // ========== УТИЛИТЫ ДЛЯ ОТЛАДКИ ==========
  static Future<void> debugPrintAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      print('🔍 DEBUG: Все ключи в хранилище:');
      for (final key in allKeys) {
        final value = prefs.get(key);
        print('   $key: $value');
      }
    } catch (e) {
      print('❌ Ошибка отладки хранилища: $e');
    }
  }

  static Future<void> debugPrintUserData(String userId) async {
    try {
      print('🔍 DEBUG: Данные пользователя $userId:');

      final profileUrl = await loadProfileImageUrl(userId);
      final profilePath = await loadProfileImageFilePath(userId);
      final coverUrl = await loadCoverImageUrl(userId);
      final coverPath = await loadCoverImageFilePath(userId);
      final follows = await loadFollows(userId);

      print('   Аватар URL: $profileUrl');
      print('   Аватар файл: $profilePath');
      print('   Обложка URL: $coverUrl');
      print('   Обложка файл: $coverPath');
      print('   Подписки: $follows (${follows.length})');
    } catch (e) {
      print('❌ Ошибка отладки данных пользователя: $e');
    }
  }
}