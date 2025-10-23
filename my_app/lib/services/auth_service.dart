// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://your-api-id.apigw.yandexcloud.net/auth';

  // 🎯 РЕАЛЬНЫЙ ЛОГИН ЧЕРЕЗ API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('🔐 Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🎯 СОХРАНЯЕМ ТОКЕН И ПОЛЬЗОВАТЕЛЯ
        await _saveToken(data['token']);
        await _saveUser(data['user'] ?? {
          'id': data['user']?['id'] ?? 'user_${email.hashCode}',
          'name': data['user']?['name'] ?? 'Пользователь',
          'email': email,
        });

        print('✅ Login successful for: ${data['user']?['name']}');
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Ошибка входа: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Ошибка входа: $e');
    }
  }

  // 🎯 РЕАЛЬНАЯ РЕГИСТРАЦИЯ ЧЕРЕЗ API
  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      print('👤 Attempting registration for: $name ($email)');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      print('👤 Registration response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // 🎯 ЕСЛИ СЕРВЕР ВОЗВРАЩАЕТ ТОКЕН ПРИ РЕГИСТРАЦИИ
        if (data['token'] != null) {
          await _saveToken(data['token']);
          await _saveUser(data['user'] ?? {
            'id': data['user']?['id'] ?? 'user_${email.hashCode}',
            'name': name,
            'email': email,
          });
        }

        print('✅ Registration successful for: $name');
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Ошибка регистрации: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // 🎯 СОХРАНЕНИЕ ТОКЕНА (БЕЗ ИЗМЕНЕНИЙ)
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('💾 Token saved: ${token.substring(0, 20)}...');
  }

  // 🎯 СОХРАНЕНИЕ ПОЛЬЗОВАТЕЛЯ (БЕЗ ИЗМЕНЕНИЙ)
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user));
    print('💾 User data saved: ${user['name']}');
  }

  // 🎯 ПОЛУЧЕНИЕ ТОКЕНА (БЕЗ ИЗМЕНЕНИЙ)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      print('🔑 Token retrieved: ${token.substring(0, 20)}...');
    }
    return token;
  }

  // 🎯 ПОЛУЧЕНИЕ ПОЛЬЗОВАТЕЛЯ (БЕЗ ИЗМЕНЕНИЙ)
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final user = json.decode(userData);
      print('👤 User data retrieved: ${user['name']}');
      return user;
    }
    return null;
  }

  // 🎯 ВЫХОД (БЕЗ ИЗМЕНЕНИЙ)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    print('🚪 User logged out');
  }

  // 🎯 ПРОВЕРКА АВТОРИЗАЦИИ (БЕЗ ИЗМЕНЕНИЙ)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isLoggedIn = token != null;
    print('🔐 Login status: $isLoggedIn');
    return isLoggedIn;
  }
}