// lib/services/network_service.dart - упрощенная версия
import 'package:http/http.dart' as http;

class NetworkService {
  static Future<http.Response> safeRequest(Future<http.Response> request) async {
    try {
      // Просто выполняем запрос, обработка ошибок будет в ApiService
      return await request;
    } catch (e) {
      print('🌐 Network error: $e');
      rethrow;
    }
  }
}