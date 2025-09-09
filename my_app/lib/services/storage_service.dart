// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveNews(List<dynamic> news) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('news_data', json.encode(news));
  }

  static Future<List<dynamic>> loadNews() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('news_data');
    if (data != null) {
      return json.decode(data);
    }
    return [];
  }
}