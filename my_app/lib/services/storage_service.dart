// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _newsKey = 'cached_news';

  static Future<void> saveNews(List<dynamic> news) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_newsKey, json.encode(news));
  }

  static Future<List<dynamic>> loadNews() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_newsKey);
    if (data != null) {
      final cachedData = json.decode(data) as List<dynamic>;

      // Убедимся, что у старых записей есть поле hashtags
      final news = cachedData;
      for (var item in news) {
        if (!item.containsKey('hashtags')) {
          item['hashtags'] = [];
        }
      }
      return news;
    }
    return [];
  }
}