// lib/services/storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ========== ОСНОВНЫЕ КЛЮЧИ ==========
  static const String _newsKey = 'cached_news';
  static const String _likesKey = 'user_likes';
  static const String _bookmarksKey = 'user_bookmarks';
  static const String _userTagsKey = 'user_tags';
  static const String _tagColorsKey = 'tag_colors';
  static const String _dataVersionKey = 'data_version';
  static const String _userProfilesKey = 'user_profiles';
  static const String _appSettingsKey = 'app_settings';

  // ========== ТЕКУЩАЯ ВЕРСИЯ ДАННЫХ ==========
  static const int _currentDataVersion = 3;

  // ========== КЛЮЧИ ДЛЯ МНОГОПОЛЬЗОВАТЕЛЬСКОЙ СИСТЕМЫ ==========
  static String _getUserProfileImageUrlKey(String userId) => 'profile_image_url_$userId';
  static String _getUserProfileImagePathKey(String userId) => 'profile_image_path_$userId';
  static String _getUserCoverImageUrlKey(String userId) => 'cover_image_url_$userId';
  static String _getUserCoverImagePathKey(String userId) => 'cover_image_path_$userId';
  static String _getUserFollowsKey(String userId) => 'user_follows_$userId';
  static String _getUserRepostsKey(String userId) => 'user_reposts_$userId';
  static String _getUserCommentsKey(String userId) => 'user_comments_$userId';

  // ========== ИНИЦИАЛИЗАЦИЯ И МИГРАЦИЯ ==========
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = prefs.getInt(_dataVersionKey) ?? 1;

      if (currentVersion < _currentDataVersion) {
        print('🔄 Миграция данных с версии $currentVersion на $_currentDataVersion');
        await _migrateData(currentVersion);
        await prefs.setInt(_dataVersionKey, _currentDataVersion);
        print('✅ Миграция данных завершена');
      }

      await ensureDataPersistence();
    } catch (e) {
      print('❌ Ошибка инициализации хранилища: $e');
    }
  }

  static Future<void> _migrateData(int oldVersion) async {
    try {
      if (oldVersion == 1) {
        await _migrateFromV1ToV2();
      }
      if (oldVersion <= 2) {
        await _migrateFromV2ToV3();
      }
    } catch (e) {
      print('❌ Ошибка миграции данных: $e');
    }
  }

  static Future<void> _migrateFromV1ToV2() async {
    final prefs = await SharedPreferences.getInstance();

    // Миграция старых данных пользователя
    final oldProfileUrl = prefs.getString('profile_image_url');
    final oldProfilePath = prefs.getString('profile_image_file_path');

    if (oldProfileUrl != null || oldProfilePath != null) {
      await saveProfileImageUrl('default_user', oldProfileUrl);
      await saveProfileImageFilePath('default_user', oldProfilePath);
      await prefs.remove('profile_image_url');
      await prefs.remove('profile_image_file_path');
      print('🔄 Мигрированы старые данные профиля');
    }
  }

  static Future<void> _migrateFromV2ToV3() async {
    // Добавляем новые поля в существующие данные
    final news = await loadNews();
    if (news.isNotEmpty) {
      final migratedNews = news.map((item) {
        if (item is Map<String, dynamic>) {
          return {
            ...item,
            'migrated_to_v3': true,
            'comments_count': item['comments_count'] ?? (item['comments'] as List).length,
            'reposts_count': item['reposts_count'] ?? 0,
          };
        }
        return item;
      }).toList();

      await saveNews(migratedNews);
      print('🔄 Мигрированы новости до версии 3');
    }
  }

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
            final cleanItem = _convertToPlainMap(item);
            // 🆕 ДОБАВЛЯЕМ МЕТАДАННЫЕ
            cleanItem['_saved_at'] = DateTime.now().toIso8601String();
            cleanItem['_version'] = _currentDataVersion;
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
            // 🆕 ОБЕСПЕЧИВАЕМ ОБРАТНУЮ СОВМЕСТИМОСТЬ
            'comments_count': map['comments_count'] ?? (map['comments'] as List).length,
            'reposts_count': map['reposts_count'] ?? 0,
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

  // 🆕 ДОБАВИТЬ: Очистка устаревших новостей
  static Future<void> cleanupOldNews({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final news = await loadNews();

      final freshNews = news.where((item) {
        if (item is Map<String, dynamic>) {
          final createdAt = DateTime.tryParse(item['created_at'] ?? '');
          final savedAt = DateTime.tryParse(item['_saved_at'] ?? '');
          final relevantDate = createdAt ?? savedAt;
          return relevantDate == null || relevantDate.isAfter(cutoffDate);
        }
        return true;
      }).toList();

      if (freshNews.length < news.length) {
        await saveNews(freshNews);
        print('✅ Очищено ${news.length - freshNews.length} устаревших новостей');
      }
    } catch (e) {
      print('❌ Ошибка очистки устаревших новостей: $e');
    }
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

  // ========== ПРОФИЛИ ПОЛЬЗОВАТЕЛЕЙ ==========
  static Future<void> saveUserProfile(String userId, Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfiles = await loadAllUserProfiles();
      userProfiles[userId] = {
        ...profile,
        '_last_updated': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_userProfilesKey, json.encode(userProfiles));
      print('💾 Профиль сохранен для пользователя: $userId');
    } catch (e) {
      print('❌ Ошибка сохранения профиля пользователя $userId: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadUserProfile(String userId) async {
    try {
      final userProfiles = await loadAllUserProfiles();
      return userProfiles[userId];
    } catch (e) {
      print('❌ Ошибка загрузки профиля пользователя $userId: $e');
      return null;
    }
  }

  static Future<Map<String, Map<String, dynamic>>> loadAllUserProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_userProfilesKey);
      if (data != null) {
        final decoded = json.decode(data) as Map<String, dynamic>;
        return decoded.map((key, value) =>
            MapEntry(key, Map<String, dynamic>.from(value))
        );
      }
    } catch (e) {
      print('❌ Ошибка загрузки всех профилей пользователей: $e');
    }
    return {};
  }

  static Future<void> removeUserProfile(String userId) async {
    try {
      final userProfiles = await loadAllUserProfiles();
      userProfiles.remove(userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userProfilesKey, json.encode(userProfiles));
      print('🗑️ Профиль удален для пользователя: $userId');
    } catch (e) {
      print('❌ Ошибка удаления профиля пользователя $userId: $e');
    }
  }

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
      print('❌ [STORAGE] Ошибка загрузки URL аватарки для пользователя $userId: $e');
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

  // ========== РЕПОСТЫ ==========
  static Future<void> addRepost(String userId, String repostId, String originalPostId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserRepostsKey(userId);

      final existingReposts = await loadReposts(userId);
      existingReposts[repostId] = {
        'repostId': repostId,
        'originalPostId': originalPostId,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(key, json.encode(existingReposts));
      print('🔁 Репост сохранен для пользователя $userId: $repostId');
    } catch (e) {
      print('❌ Ошибка сохранения репоста: $e');
    }
  }

  static Future<Map<String, dynamic>> loadReposts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserRepostsKey(userId);
      final repostsJson = prefs.getString(key);

      if (repostsJson != null) {
        final Map<String, dynamic> repostsMap = Map<String, dynamic>.from(json.decode(repostsJson));
        return repostsMap;
      }
    } catch (e) {
      print('❌ Ошибка загрузки репостов: $e');
    }

    return {};
  }

  static Future<void> removeRepost(String userId, String repostId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserRepostsKey(userId);

      final existingReposts = await loadReposts(userId);
      existingReposts.remove(repostId);

      await prefs.setString(key, json.encode(existingReposts));
      print('✅ Репост удален для пользователя $userId: $repostId');
    } catch (e) {
      print('❌ Ошибка удаления репоста: $e');
    }
  }

  // ========== НАСТРОЙКИ ПРИЛОЖЕНИЯ ==========
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appSettingsKey, json.encode(settings));
      print('⚙️ Настройки приложения сохранены');
    } catch (e) {
      print('❌ Ошибка сохранения настроек приложения: $e');
    }
  }

  static Future<Map<String, dynamic>> loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_appSettingsKey);
      if (data != null) {
        return Map<String, dynamic>.from(json.decode(data));
      }
    } catch (e) {
      print('❌ Ошибка загрузки настроек приложения: $e');
    }
    return {
      'theme': 'light',
      'notifications': true,
      'auto_save': true,
      'cache_duration': 7,
    };
  }

  // ========== ОЧИСТКА ДАННЫХ ==========
  static Future<void> clearUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Очищаем данные профиля пользователя
      await prefs.remove(_getUserProfileImageUrlKey(userId));
      await prefs.remove(_getUserProfileImagePathKey(userId));
      await prefs.remove(_getUserCoverImageUrlKey(userId));
      await prefs.remove(_getUserCoverImagePathKey(userId));
      await prefs.remove(_getUserFollowsKey(userId));
      await prefs.remove(_getUserRepostsKey(userId));
      await prefs.remove(_getUserCommentsKey(userId));

      // Удаляем профиль
      await removeUserProfile(userId);

      print('🧹 Данные пользователя очищены: $userId');
    } catch (e) {
      print('❌ Ошибка очистки данных пользователя $userId: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Очищаем общие данные
      await prefs.remove(_newsKey);
      await prefs.remove(_likesKey);
      await prefs.remove(_bookmarksKey);
      await prefs.remove(_userTagsKey);
      await prefs.remove(_tagColorsKey);
      await prefs.remove(_userProfilesKey);
      await prefs.remove(_appSettingsKey);

      // Очищаем все пользовательские данные
      final allKeys = prefs.getKeys();
      final userKeys = allKeys.where((key) =>
      key.contains('profile_image_url_') ||
          key.contains('profile_image_path_') ||
          key.contains('cover_image_url_') ||
          key.contains('cover_image_path_') ||
          key.contains('user_follows_') ||
          key.contains('user_reposts_') ||
          key.contains('user_comments_')
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

  // ========== СТАТИСТИКА ==========
  static Future<Map<String, int>> getStorageStats() async {
    try {
      final news = await loadNews();
      final likes = await loadLikes();
      final bookmarks = await loadBookmarks();
      final userTags = await loadUserTags();
      final tagColors = await loadTagColors();
      final userProfiles = await loadAllUserProfiles();

      return {
        'news_count': news.length,
        'likes_count': likes.length,
        'bookmarks_count': bookmarks.length,
        'tagged_news_count': userTags.length,
        'colored_tags_count': tagColors.length,
        'user_profiles_count': userProfiles.length,
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
      final reposts = await loadReposts(userId);

      return {
        'has_profile_image': (profileUrl != null || profilePath != null) ? 1 : 0,
        'has_cover_image': (coverUrl != null || coverPath != null) ? 1 : 0,
        'follows_count': follows.length,
        'reposts_count': reposts.length,
      };
    } catch (e) {
      print('❌ Ошибка получения статистики пользователя $userId: $e');
      return {};
    }
  }

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========
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
      final reposts = await loadReposts(userId);
      final profile = await loadUserProfile(userId);

      print('   Аватар URL: $profileUrl');
      print('   Аватар файл: $profilePath');
      print('   Обложка URL: $coverUrl');
      print('   Обложка файл: $coverPath');
      print('   Подписки: $follows (${follows.length})');
      print('   Репосты: ${reposts.length}');
      print('   Профиль: $profile');
    } catch (e) {
      print('❌ Ошибка отладки данных пользователя: $e');
    }
  }

  // 🆕 ДОБАВИТЬ: Экспорт и импорт данных
  static Future<String> exportUserData(String userId) async {
    try {
      final data = {
        'userId': userId,
        'exportedAt': DateTime.now().toIso8601String(),
        'version': _currentDataVersion,
        'profile': await loadUserProfile(userId),
        'likes': (await loadLikes()).toList(),
        'bookmarks': (await loadBookmarks()).toList(),
        'follows': await loadFollows(userId),
        'reposts': await loadReposts(userId),
      };

      return json.encode(data);
    } catch (e) {
      print('❌ Ошибка экспорта данных пользователя: $e');
      return '';
    }
  }

  static Future<bool> importUserData(String userId, String jsonData) async {
    try {
      final data = json.decode(jsonData) as Map<String, dynamic>;

      if (data['userId'] == userId) {
        if (data['profile'] != null) {
          await saveUserProfile(userId, Map<String, dynamic>.from(data['profile']));
        }
        if (data['likes'] != null) {
          await saveLikes(Set<String>.from(data['likes']));
        }
        if (data['bookmarks'] != null) {
          await saveBookmarks(Set<String>.from(data['bookmarks']));
        }
        // ... импорт других данных

        print('✅ Данные пользователя импортированы: $userId');
        return true;
      }
    } catch (e) {
      print('❌ Ошибка импорта данных пользователя: $e');
    }
    return false;
  }
}