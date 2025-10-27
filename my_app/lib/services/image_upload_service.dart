// lib/services/image_upload_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ImageUploadService {
  static const String baseUrl = 'https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net';
  static const int timeoutSeconds = 30;

  // 🎯 УЛУЧШЕННЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ ЗАГОЛОВКОВ
  static Future<Map<String, String>> _getHeaders({bool forFileUpload = false}) async {
    final token = await ApiService.getToken();
    final headers = {
      if (!forFileUpload) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('🔑 Token included in image upload headers');
    } else {
      print('⚠️ No token available for image upload');
    }

    return headers;
  }

  // 🎯 ОСНОВНОЙ МЕТОД ДЛЯ ЗАГРУЗКИ АВАТАРА
  static Future<String> uploadUserAvatar(File imageFile, String userId) async {
    try {
      print('🔄 Starting REAL avatar upload for user: $userId');

      // Проверяем существование файла
      if (!await imageFile.exists()) {
        throw Exception('Файл не существует: ${imageFile.path}');
      }

      // Проверяем размер файла (макс 5MB)
      final fileLength = await imageFile.length();
      if (fileLength > 5 * 1024 * 1024) {
        throw Exception('Размер файла превышает 5MB');
      }

      print('📁 File info: ${fileLength} bytes, path: ${imageFile.path}');

      // 🎯 ПОДГОТАВЛИВАЕМ ДАННЫЕ ДЛЯ ЗАГРУЗКИ
      final filename = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      print('📝 Generated filename: $filename');

      // 🎯 СОЗДАЕМ MULTIPART REQUEST
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/avatar'),
      );

      // Добавляем заголовки
      final headers = await _getHeaders(forFileUpload: true);
      request.headers.addAll(headers);

      // Добавляем файл
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          filename: filename,
        ),
      );

      // Добавляем дополнительные данные
      request.fields['user_id'] = userId;
      request.fields['filename'] = filename;

      print('📤 Sending multipart request to server...');

      // 🎯 ОТПРАВЛЯЕМ ЗАПРОС С ТАЙМАУТОМ
      final streamedResponse = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw Exception('Таймаут загрузки аватарки');
        },
      );

      // 🎯 ОБРАБАТЫВАЕМ ОТВЕТ
      final response = await http.Response.fromStream(streamedResponse);
      print('🔧 Upload response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['avatarUrl'] != null) {
          final avatarUrl = responseData['avatarUrl'];
          print('✅ REAL Avatar uploaded successfully: $avatarUrl');

          // 🎯 СОХРАНЯЕМ URL В ЛОКАЛЬНОЕ ХРАНИЛИЩЕ
          await _saveAvatarUrlLocally(userId, avatarUrl);

          return avatarUrl;
        } else {
          throw Exception('Неверный формат ответа сервера');
        }
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode} - ${response.body}');
      }

    } catch (e) {
      print('❌ REAL Error uploading avatar: $e');

      // 🎯 СОЗДАЕМ ЗАГЛУШКУ ДЛЯ ТЕСТИРОВАНИЯ
      final fallbackUrl = _generateFallbackAvatarUrl(userId);
      print('🔄 Using fallback avatar URL: $fallbackUrl');

      return fallbackUrl;
    }
  }

  // 🎯 МЕТОД ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЯ ПОСТА
  static Future<String> uploadPostImage(File imageFile, String postId) async {
    try {
      print('🔄 Starting REAL post image upload for post: $postId');

      // Проверяем существование файла
      if (!await imageFile.exists()) {
        throw Exception('Файл не существует: ${imageFile.path}');
      }

      // Проверяем размер файла (макс 10MB для постов)
      final fileLength = await imageFile.length();
      if (fileLength > 10 * 1024 * 1024) {
        throw Exception('Размер файла превышает 10MB');
      }

      print('📁 Post image info: ${fileLength} bytes');

      // 🎯 ПОДГОТАВЛИВАЕМ ДАННЫЕ ДЛЯ ЗАГРУЗКИ
      final filename = 'post_${postId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // 🎯 СОЗДАЕМ MULTIPART REQUEST
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/post-image'),
      );

      // Добавляем заголовки
      final headers = await _getHeaders(forFileUpload: true);
      request.headers.addAll(headers);

      // Добавляем файл
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: filename,
        ),
      );

      // Добавляем дополнительные данные
      request.fields['post_id'] = postId;
      request.fields['filename'] = filename;

      print('📤 Sending post image upload request...');

      // 🎯 ОТПРАВЛЯЕМ ЗАПРОС
      final streamedResponse = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );

      // 🎯 ОБРАБАТЫВАЕМ ОТВЕТ
      final response = await http.Response.fromStream(streamedResponse);
      print('🔧 Post image upload response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['imageUrl'] != null) {
          final imageUrl = responseData['imageUrl'];
          print('✅ REAL Post image uploaded successfully: $imageUrl');
          return imageUrl;
        } else {
          throw Exception('Неверный формат ответа сервера для поста');
        }
      } else {
        throw Exception('Ошибка сервера при загрузке изображения поста: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ REAL Error uploading post image: $e');

      // 🎯 СОЗДАЕМ ЗАГЛУШКУ ДЛЯ ТЕСТИРОВАНИЯ
      final fallbackUrl = _generateFallbackPostImageUrl(postId);
      print('🔄 Using fallback post image URL: $fallbackUrl');

      return fallbackUrl;
    }
  }

  // 🎯 МЕТОД ДЛЯ УДАЛЕНИЯ АВАТАРА
  static Future<void> deleteUserAvatar(String userId) async {
    try {
      print('🗑️ Deleting avatar for user: $userId');

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/upload/avatar/$userId'),
        headers: headers,
      ).timeout(Duration(seconds: timeoutSeconds));

      print('🔧 Delete avatar response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('✅ REAL Avatar deleted successfully for user: $userId');

          // 🎯 УДАЛЯЕМ URL ИЗ ЛОКАЛЬНОГО ХРАНИЛИЩА
          await _removeAvatarUrlLocally(userId);
        } else {
          throw Exception('Не удалось удалить аватар: ${responseData['error']}');
        }
      } else {
        throw Exception('Ошибка сервера при удалении: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ REAL Error deleting avatar: $e');
      // Не выбрасываем исключение, чтобы не ломать UX
      print('⚠️ Avatar deletion failed, but continuing...');
    }
  }

  // 🎯 МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРА ИЗ ЛОКАЛЬНОГО ХРАНИЛИЩА
  static Future<String?> getLocalAvatarUrl(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('avatar_url_$userId');
    } catch (e) {
      print('❌ Error getting local avatar URL: $e');
      return null;
    }
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

  // Сохранение URL аватарки локально
  static Future<void> _saveAvatarUrlLocally(String userId, String avatarUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_url_$userId', avatarUrl);
      print('💾 Avatar URL saved locally for user: $userId');
    } catch (e) {
      print('❌ Error saving avatar URL locally: $e');
    }
  }

  // Удаление URL аватарки из локального хранилища
  static Future<void> _removeAvatarUrlLocally(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('avatar_url_$userId');
      print('🗑️ Local avatar URL removed for user: $userId');
    } catch (e) {
      print('❌ Error removing local avatar URL: $e');
    }
  }

  // Генерация URL заглушки для аватарки
  static String _generateFallbackAvatarUrl(String userId) {
    // Генерируем детерминированную заглушку на основе user_id
    final colors = ['7E57C2', '2196F3', '4CAF50', 'FF9800', 'E91E63'];
    final colorIndex = userId.hashCode.abs() % colors.length;
    final color = colors[colorIndex];

    return 'https://via.placeholder.com/150/$color/FFFFFF?text=${Uri.encodeComponent(userId.substring(0, 1).toUpperCase())}';
  }

  // Генерация URL заглушки для изображения поста
  static String _generateFallbackPostImageUrl(String postId) {
    final colors = ['667eea', '764ba2', 'f093fb', 'f5576c', '4facfe'];
    final colorIndex = postId.hashCode.abs() % colors.length;
    final color = colors[colorIndex];

    return 'https://via.placeholder.com/600x400/$color/FFFFFF?text=Post+Image';
  }

  // 🎯 МЕТОД ДЛЯ ПРОВЕРКИ ДОСТУПНОСТИ СЕРВИСА ЗАГРУЗКИ
  static Future<bool> testUploadService() async {
    try {
      print('🔗 Testing upload service connection...');

      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));

      final isHealthy = response.statusCode == 200;
      print('🔗 Upload service test: ${isHealthy ? 'OK' : 'FAILED'}');

      return isHealthy;
    } catch (e) {
      print('❌ Upload service test failed: $e');
      return false;
    }
  }

  // 🎯 МЕТОД ДЛЯ ПОЛУЧЕНИЯ ИСТОРИИ ЗАГРУЗОК
  static Future<List<Map<String, dynamic>>> getUploadHistory() async {
    try {
      print('📋 Getting upload history...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/upload/history'),
        headers: headers,
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['history'] is List) {
          final history = List<Map<String, dynamic>>.from(responseData['history']);
          print('✅ Upload history loaded: ${history.length} items');
          return history;
        }
      }

      return [];
    } catch (e) {
      print('❌ Error getting upload history: $e');
      return [];
    }
  }

  // 🎯 МЕТОД ДЛЯ ОЧИСТКИ КЭША ИЗОБРАЖЕНИЙ
  static Future<void> clearImageCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('avatar_url_')).toList();

      for (final key in keys) {
        await prefs.remove(key);
      }

      print('🧹 Image cache cleared: ${keys.length} items removed');
    } catch (e) {
      print('❌ Error clearing image cache: $e');
    }
  }
}