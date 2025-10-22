// lib/providers/news_providers/news_storage_handler.dart
import '../../services/storage_service.dart';
import '../../services/api_service.dart';

class NewsStorageHandler {
  Future<List<dynamic>> loadNews() async {
    try {
      final cachedNews = await StorageService.loadNews();
      print('📂 Loaded ${cachedNews.length} news from storage');
      return cachedNews;
    } catch (e) {
      print('❌ Error loading news from storage: $e');
      return [];
    }
  }

  Future<void> saveNews(List<dynamic> news) async {
    try {
      print('💾 Saving ${news.length} news to storage...');
      await StorageService.saveNews(news);
      print('✅ News saved to storage');
    } catch (e) {
      print('❌ Error saving news to storage: $e');
    }
  }

  Future<void> removeNewsData(String newsId) async {
    try {
      StorageService.removeLike(newsId);
      StorageService.removeBookmark(newsId);
      StorageService.removeUserTags(newsId);

      // Пытаемся удалить через API (игнорируем ошибки для локальных постов)
      try {
        await ApiService.deleteNews(newsId);
      } catch (e) {
        print('⚠️ API delete error (expected for local posts): $e');
      }
    } catch (e) {
      print('❌ Error removing news data: $e');
    }
  }


  Future<void> removeAllData() async {
    try {
      await StorageService.clearAllData();
      print('✅ All data cleared from storage');
    } catch (e) {
      print('❌ Error clearing all data: $e');
    }
  }


  Future<Map<String, dynamic>> loadUserData() async {
    try {
      final localLikes = await StorageService.loadLikes();
      final localBookmarks = await StorageService.loadBookmarks();
      final userTags = await StorageService.loadUserTags();

      return {
        'likes': localLikes,
        'bookmarks': localBookmarks,
        'userTags': userTags,
      };
    } catch (e) {
      print('❌ Error loading user data: $e');
      return {'likes': [], 'bookmarks': [], 'userTags': {}};
    }
  }
}