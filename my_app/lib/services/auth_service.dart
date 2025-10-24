import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String baseUrl = 'https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net';

  // Получаем заголовки с токеном
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Получаем токен из SharedPreferences
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Сохраняем токен
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Сохраняем данные пользователя
  static Future<void> saveUser(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(user));
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  // Получаем данные пользователя
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Проверяем авторизацию
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final user = await getUser();

      // Простая проверка - есть ли токен и данные пользователя
      final isLoggedIn = token != null && token.isNotEmpty && user != null;
      print('Login status: $isLoggedIn');

      return isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Вход
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Сохраняем токен и пользователя
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['user'] != null) {
          await saveUser(data['user']);
        }

        return data;
      } else {
        throw Exception('Ошибка входа: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Ошибка входа: $e');
    }
  }

  // Регистрация
  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Сохраняем токен и пользователя
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['user'] != null) {
          await saveUser(data['user']);
        }

        return data;
      } else {
        throw Exception('Ошибка регистрации: ${response.statusCode}');
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // Выход
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Получаем текущего пользователя (alias для getUser)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await getUser();
  }
}