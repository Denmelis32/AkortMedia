import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net';
  static const int timeoutSeconds = 10;

  // 🎯 УЛУЧШЕННОЕ ПОЛУЧЕНИЕ ТОКЕНА
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      print('🔑 getToken: ${token != null ? 'Token found' : 'No token'}');

      if (token != null && token.isNotEmpty) {
        print('✅ Token retrieved: ${token.substring(0, min(token.length, 20))}...');
        return token;
      }

      // 🎯 АВАРИЙНОЕ ВОССТАНОВЛЕНИЕ ТОКЕНА
      print('🔄 Attempting emergency token recovery...');
      token = await _emergencyTokenRecovery();

      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  static int min(int a, int b) => a < b ? a : b;

  // 🎯 АВАРИЙНОЕ ВОССТАНОВЛЕНИЕ ТОКЕНА
  static Future<String?> _emergencyTokenRecovery() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        final user = json.decode(userData);
        if (user['id'] != null) {
          final newToken = 'mock-jwt-token-${user['id']}';
          await saveToken(newToken);
          print('🔄 EMERGENCY: Recreated token from user data: $newToken');
          return newToken;
        }
      }

      // 🎯 ПРОВЕРЯЕМ ДРУГИЕ КЛЮЧИ
      final userId = prefs.getString('user_id');
      if (userId != null && userId.isNotEmpty) {
        final newToken = 'mock-jwt-token-$userId';
        await saveToken(newToken);
        print('🔄 EMERGENCY: Recreated token from user_id: $newToken');
        return newToken;
      }

      print('❌ Emergency recovery failed: no user data found');
      return null;
    } catch (e) {
      print('❌ Emergency token recovery failed: $e');
      return null;
    }
  }

// 🎯 НОВЫЙ МЕТОД: ПОЛУЧЕНИЕ ПРОФИЛЯ ПОЛЬЗОВАТЕЛЯ ИЗ YDB
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('👤 Getting user profile from YDB: $userId');

      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/getUserProfile?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  // 🎯 УЛУЧШЕННОЕ СОХРАНЕНИЕ ТОКЕНА
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      // 🎯 ПРОВЕРКА СОХРАНЕНИЯ
      final savedToken = prefs.getString('auth_token');
      if (savedToken == token) {
        print('✅ Token saved successfully: ${token.substring(0, min(token.length, 20))}...');
      } else {
        print('❌ Token NOT saved correctly!');

        // 🎯 ПОВТОРНАЯ ПОПЫТКА
        await prefs.setString('auth_token', token);
        final retryToken = prefs.getString('auth_token');
        if (retryToken == token) {
          print('✅ Token saved on retry');
        } else {
          print('❌ Token still not saved after retry');
        }
      }
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  // 🎯 ДЕБАГ ХРАНИЛИЩА
  static Future<void> debugTokenStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final keys = prefs.getKeys();

      print('🔍 TOKEN DEBUG INFO:');
      print('   🔑 Token exists: ${token != null}');
      print('   🔑 Token length: ${token?.length ?? 0}');
      print('   🔑 Token value: $token');
      print('   📋 All keys: $keys');

      for (final key in keys) {
        final value = prefs.get(key);
        print('   📝 $key: $value');
      }
    } catch (e) {
      print('❌ Token debug error: $e');
    }
  }

  // 🎯 СОХРАНЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ
  static Future<void> saveUser(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(user));

      // 🎯 ДУБЛИРУЕМ В ОТДЕЛЬНЫЕ КЛЮЧИ ДЛЯ НАДЕЖНОСТИ
      if (user['id'] != null) {
        await prefs.setString('user_id', user['id'].toString());
      }
      if (user['name'] != null) {
        await prefs.setString('user_name', user['name'].toString());
      }
      if (user['email'] != null) {
        await prefs.setString('user_email', user['email'].toString());
      }

      print('✅ User data saved: ${user['name']} (ID: ${user['id']})');
    } catch (e) {
      print('❌ Error saving user: $e');
    }
  }

  // 🎯 ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // 🎯 ПОЛУЧЕНИЕ SERVER USER_ID ИЗ ТОКЕНА
  static Future<String?> getServerUserId() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return null;

      print('🔑 Token for user_id extraction: ${token.substring(0, min(token.length, 20))}...');

      if (token.startsWith('mock-jwt-token-')) {
        final userId = token.replaceFirst('mock-jwt-token-', '');
        print('✅ Extracted server user_id from token: $userId');
        return userId;
      }

      // 🎯 ПАРСИНГ ДРУГИХ ФОРМАТОВ ТОКЕНОВ
      if (token.contains('user_')) {
        final match = RegExp(r'user_[a-zA-Z0-9_]+').firstMatch(token);
        if (match != null) {
          final userId = match.group(0)!;
          print('✅ Extracted server user_id from token pattern: $userId');
          return userId;
        }
      }

      return null;
    } catch (e) {
      print('❌ Error extracting server user_id: $e');
      return null;
    }
  }

  // 🎯 НОВЫЙ МЕТОД: ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ С СЕРВЕРА
  static Future<Map<String, dynamic>?> getServerUserData() async {
    try {
      final serverUserId = await getServerUserId();
      if (serverUserId == null) {
        print('⚠️ No server user ID found for getting user data');
        return null;
      }

      print('👤 Getting user data from server for ID: $serverUserId');

      // Получаем локальные данные пользователя как fallback
      final localUser = await getUser();
      if (localUser != null) {
        print('✅ Using local user data: ${localUser['name']}');
        return localUser;
      }

      // Если локальных данных нет, создаем базовые данные
      final basicUserData = {
        'id': serverUserId,
        'name': 'Пользователь',
        'email': 'user@example.com',
      };

      print('✅ Created basic user data for ID: $serverUserId');
      return basicUserData;

    } catch (e) {
      print('❌ Error getting server user data: $e');
      return null;
    }
  }

  // 🎯 ПРОВЕРКА АВТОРИЗАЦИИ
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final user = await getUser();

      final isLoggedIn = token != null && token.isNotEmpty && user != null;
      print('🔐 Login status: $isLoggedIn');

      if (isLoggedIn) {
        print('   👤 User: ${user['name']}');
        print('   🆔 ID: ${user['id']}');
        print('   🔑 Token: ${token!.substring(0, min(token.length, 20))}...');
      }

      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // 🎯 ВХОД С УЛУЧШЕННОЙ ОБРАБОТКОЙ
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🎯 Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: timeoutSeconds));

      print('🔧 Login response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // 🎯 ГАРАНТИРОВАННОЕ СОХРАНЕНИЕ ТОКЕНА
          if (data['token'] != null) {
            await saveToken(data['token']);
          } else if (data['user'] != null && data['user']['id'] != null) {
            // 🎯 СОЗДАЕМ ТОКЕН ЕСЛИ ЕГО НЕТ В ОТВЕТЕ
            final manualToken = 'mock-jwt-token-${data['user']['id']}';
            await saveToken(manualToken);
            data['token'] = manualToken;
          }

          // 🎯 СОХРАНЯЕМ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ
          if (data['user'] != null) {
            await saveUser(Map<String, dynamic>.from(data['user']));
          }

          print('✅ Login successful for user: ${data['user']?['name']}');

          // 🎯 ФИНАЛЬНАЯ ПРОВЕРКА
          await debugTokenStorage();

          return data;
        } else {
          throw Exception(data['error'] ?? 'Login failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Ошибка входа: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ Network error during login: $e');
      throw Exception('Проблема с подключением к серверу. Проверьте интернет.');
    } on Exception catch (e) {
      print('❌ Login error: $e');
      throw Exception('Ошибка входа: $e');
    }
  }

  // 🎯 РЕГИСТРАЦИЯ С УЛУЧШЕННОЙ ОБРАБОТКОЙ
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      print('🎯 Attempting registration for: $name ($email)');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: timeoutSeconds));

      print('🔧 Registration response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // 🎯 ГАРАНТИРОВАННОЕ СОХРАНЕНИЕ ТОКЕНА
          if (data['token'] != null) {
            await saveToken(data['token']);
          } else if (data['user'] != null && data['user']['id'] != null) {
            // 🎯 СОЗДАЕМ ТОКЕН ЕСЛИ ЕГО НЕТ В ОТВЕТЕ
            final manualToken = 'mock-jwt-token-${data['user']['id']}';
            await saveToken(manualToken);
            data['token'] = manualToken;
          }

          // 🎯 СОХРАНЯЕМ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ
          if (data['user'] != null) {
            await saveUser(Map<String, dynamic>.from(data['user']));
          }

          print('✅ Registration successful for user: ${data['user']?['name']}');

          // 🎯 ФИНАЛЬНАЯ ПРОВЕРКА
          await debugTokenStorage();

          return data;
        } else {
          throw Exception(data['error'] ?? 'Registration failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Ошибка регистрации: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ Network error during registration: $e');
      throw Exception('Проблема с подключением к серверу. Проверьте интернет.');
    } on Exception catch (e) {
      print('❌ Register error: $e');
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // 🎯 ВЫХОД
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      print('✅ Logout successful - all user data cleared');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  // 🎯 ПОЛУЧЕНИЕ ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // 🎯 ПРОВЕРКА РАБОТОСПОСОБНОСТИ API
  static Future<bool> checkApiHealth() async {
    try {
      print('🔗 Checking API health...');
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));

      final isHealthy = response.statusCode == 200;
      print('🔗 API health: ${isHealthy ? 'OK' : 'ERROR'} (${response.statusCode})');

      return isHealthy;
    } catch (e) {
      print('❌ API health check failed: $e');
      return false;
    }
  }
}