// lib/services/image_upload_service.dart
import 'dart:convert'; // 🎯 ДОБАВЛЯЕМ ЭТОТ ИМПОРТ
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'api_service.dart';

class ImageUploadService {
  static const String baseUrl = 'https://your-api-id.apigw.yandexcloud.net';

  // 🎯 ИСПРАВЛЯЕМ МЕТОД ДЛЯ ПОЛУЧЕНИЯ ЗАГОЛОВКОВ
  static Future<Map<String, String>> _getHeaders() async {
    final token = await ApiService.getToken(); // 🎯 ИСПОЛЬЗУЕМ ПУБЛИЧНЫЙ МЕТОД
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<String> uploadUserAvatar(File imageFile, String userId) async {
    try {
      print('🔄 Uploading avatar for user: $userId');

      // Временно возвращаем заглушку
      final publicUrl = '$baseUrl/uploads/avatars/avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      print('✅ Avatar URL generated: $publicUrl');
      return publicUrl;

    } catch (e) {
      print('❌ Error uploading avatar: $e');
      throw Exception('Не удалось загрузить аватарку: $e');
    }
  }

  // 🎯 УПРОЩАЕМ МЕТОД ДЛЯ ТЕСТИРОВАНИЯ
  static Future<String> _getPresignedUploadUrl(String filename) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/upload/avatar-url'),
        headers: await _getHeaders(), // 🎯 ИСПОЛЬЗУЕМ НАШ МЕТОД
        body: json.encode({'filename': filename}), // 🎯 json ДОСТУПЕН
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // 🎯 json ДОСТУПЕН
        return data['uploadUrl'];
      } else {
        throw Exception('Failed to get upload URL: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting upload URL: $e');
      // Временно возвращаем заглушку
      return '$baseUrl/upload/temp-url';
    }
  }

  // 🎯 УПРОЩАЕМ ЗАГРУЗКУ
  static Future<void> _uploadToPresignedUrl(String uploadUrl, File file) async {
    print('🔄 Simulating upload to: $uploadUrl');
    await Future.delayed(Duration(milliseconds: 500));
  }

  // 🎯 УПРОЩАЕМ УДАЛЕНИЕ
  static Future<void> deleteUserAvatar(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/upload/avatar/$userId'),
        headers: await _getHeaders(), // 🎯 ИСПОЛЬЗУЕМ НАШ МЕТОД
      );

      if (response.statusCode == 200) {
        print('✅ Avatar deleted for user: $userId');
      } else {
        throw Exception('Failed to delete avatar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting avatar: $e');
      // Игнорируем ошибку для тестирования
      print('⚠️ Avatar deletion failed, but continuing...');
    }
  }
}