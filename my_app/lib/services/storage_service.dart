// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _newsKey = 'cached_news';
  static const String _likesKey = 'user_likes';
  static const String _bookmarksKey = 'user_bookmarks';
  static const String _userTagsKey = 'user_tags';

  // ========== НОВОСТИ ==========
  static Future<void> saveNews(List<dynamic> news) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_newsKey, json.encode(news));
  }

  static Future<List<dynamic>> loadNews() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_newsKey);
    if (data != null) {
      final cachedData = json.decode(data) as List<dynamic>;

      // Убедимся, что у старых записей есть все необходимые поля
      final news = cachedData.map((item) {
        final map = item as Map<String, dynamic>;
        return {
          ...map,
          'hashtags': map['hashtags'] ?? [],
          'user_tags': map['user_tags'] ?? {},
          'likes': map['likes'] ?? 0,
          'comments': map['comments'] ?? [],
          'isLiked': map['isLiked'] ?? false,
          'isBookmarked': map['isBookmarked'] ?? false,
        };
      }).toList();

      return news;
    }
    return [];
  }

  // ========== ЛАЙКИ ==========
  static Future<void> saveLikes(Set<String> likedNewsIds) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_likesKey, likedNewsIds.toList());
  }

  static Future<Set<String>> loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final likes = prefs.getStringList(_likesKey);
    return likes != null ? Set<String>.from(likes) : <String>{};
  }

  static Future<void> addLike(String newsId) async {
    final likes = await loadLikes();
    likes.add(newsId);
    await saveLikes(likes);
  }

  static Future<void> removeLike(String newsId) async {
    final likes = await loadLikes();
    likes.remove(newsId);
    await saveLikes(likes);
  }

  // ========== ЗАКЛАДКИ ==========
  static Future<void> saveBookmarks(Set<String> bookmarkedNewsIds) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_bookmarksKey, bookmarkedNewsIds.toList());
  }

  static Future<Set<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarksKey);
    return bookmarks != null ? Set<String>.from(bookmarks) : <String>{};
  }

  static Future<void> addBookmark(String newsId) async {
    final bookmarks = await loadBookmarks();
    bookmarks.add(newsId);
    await saveBookmarks(bookmarks);
  }

  static Future<void> removeBookmark(String newsId) async {
    final bookmarks = await loadBookmarks();
    bookmarks.remove(newsId);
    await saveBookmarks(bookmarks);
  }

  // ========== ПОЛЬЗОВАТЕЛЬСКИЕ ТЕГИ ==========
  static Future<void> saveUserTags(Map<String, Map<String, dynamic>> userTags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userTagsKey, json.encode(userTags));
      print('💾 Сохранено тегов: ${userTags.length}');
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
        final userTags = decoded.map((key, value) =>
            MapEntry(key, Map<String, dynamic>.from(value)));
        print('📂 Загружено тегов: ${userTags.length}');
        return userTags;
      }
    } catch (e) {
      print('❌ Ошибка загрузки тегов: $e');
    }
    return {};
  }

  static Future<void> updateUserTag(String newsId, String tagId, String tagName, {int? color}) async {
    try {
      final userTags = await loadUserTags();
      final newsTags = userTags[newsId] ?? {};

      newsTags[tagId] = {
        'name': tagName,
        'color': color ?? 0xFF2196F3, // Синий по умолчанию
        'created_at': DateTime.now().toIso8601String()
      };

      userTags[newsId] = newsTags;
      await saveUserTags(userTags);
      print('🎨 Тег обновлен: $tagName');

    } catch (e) {
      print('❌ Ошибка обновления тега: $e');
    }
  }

  // ========== ОЧИСТКА ДАННЫХ ==========
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_newsKey);
    await prefs.remove(_likesKey);
    await prefs.remove(_bookmarksKey);
    await prefs.remove(_userTagsKey);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_newsKey);
  }


}