import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _userEmail = '';
  String _userId = '';
  String? _profileImageUrl;
  String? _coverImageUrl;
  Map<String, int> _stats = {
    'posts': 0,
    'likes': 0,
    'comments': 0,
    'followers': 0,
    'following': 0,
  };

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userId => _userId;
  String? get profileImageUrl => _profileImageUrl;
  String? get coverImageUrl => _coverImageUrl;
  Map<String, int> get stats => _stats;
  bool get isLoggedIn => _userName.isNotEmpty && _userId.isNotEmpty;

  // Константы для ключей SharedPreferences
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _profileImageUrlKey = 'profile_image_url';
  static const String _coverImageUrlKey = 'cover_image_url';
  static const String _userStatsKey = 'user_stats';

  UserProvider() {
    _loadUserData();
  }

  // 🎯 ЗАГРУЗКА ДАННЫХ ИЗ SHARED_PREFERENCES
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _userName = prefs.getString(_userNameKey) ?? '';
      _userEmail = prefs.getString(_userEmailKey) ?? '';
      _userId = prefs.getString(_userIdKey) ?? '';
      _profileImageUrl = prefs.getString(_profileImageUrlKey);
      _coverImageUrl = prefs.getString(_coverImageUrlKey);

      // Загружаем статистику
      final statsJson = prefs.getString(_userStatsKey);
      if (statsJson != null) {
        final statsMap = Map<String, dynamic>.from(json.decode(statsJson));
        _stats = statsMap.map((key, value) => MapEntry(key, value as int));
      }

      if (_userName.isNotEmpty) {
        print('✅ UserProvider: Loaded user data from storage');
        print('   👤 Name: $_userName');
        print('   📧 Email: $_userEmail');
        print('   🆔 ID: $_userId');
        print('   📊 Stats: $_stats');

        notifyListeners();
      }
    } catch (e) {
      print('❌ UserProvider: Error loading user data: $e');
    }
  }

  // 🎯 СОХРАНЕНИЕ ДАННЫХ В SHARED_PREFERENCES
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_userNameKey, _userName);
      await prefs.setString(_userEmailKey, _userEmail);
      await prefs.setString(_userIdKey, _userId);

      if (_profileImageUrl != null) {
        await prefs.setString(_profileImageUrlKey, _profileImageUrl!);
      }

      if (_coverImageUrl != null) {
        await prefs.setString(_coverImageUrlKey, _coverImageUrl!);
      }

      // Сохраняем статистику
      await prefs.setString(_userStatsKey, json.encode(_stats));

      print('💾 UserProvider: Saved user data to storage');
    } catch (e) {
      print('❌ UserProvider: Error saving user data: $e');
    }
  }

  // 🎯 ОСНОВНОЙ МЕТОД УСТАНОВКИ ДАННЫХ
  Future<void> setUserData(String name, String email, {String userId = ''}) async {
    // Сохраняем существующий ID если он уже есть и новый не предоставлен
    if (userId.isEmpty && _userId.isNotEmpty) {
      print('🔄 Preserving existing user ID: $_userId');
    } else if (userId.isNotEmpty) {
      _userId = userId;
      print('🎯 Using provided user ID: $userId');
    } else {
      // Генерируем стабильный ID на основе email только если нет существующего
      _userId = 'user_${email.trim().toLowerCase().hashCode.abs()}';
      print('🔄 Generated new user ID: $_userId');
    }

    _userName = name;
    _userEmail = email;

    print('🆔 UserProvider: Set user data');
    print('   👤 Name: $name');
    print('   📧 Email: $email');
    print('   🆔 ID: $_userId');

    // Сохраняем данные
    await _saveUserData();
    notifyListeners();
  }

  // 🎯 СИНХРОНИЗАЦИЯ С СЕРВЕРОМ
  Future<void> syncWithServer() async {
    try {
      print('🔄 UserProvider: Starting server sync...');

      // Получаем серверный user_id из токена
      final serverUserId = await AuthService.getServerUserId();
      if (serverUserId == null) {
        print('⚠️ No server user ID found in token');
        return;
      }

      print('🎯 Server user ID from token: $serverUserId');

      // Обновляем локальный user_id серверным
      if (_userId != serverUserId) {
        print('🔄 Updating local user ID from $_userId to $serverUserId');
        _userId = serverUserId;
        await _saveUserData();
      }

      // Получаем данные пользователя с сервера
      final serverUserData = await AuthService.getServerUserData();
      if (serverUserData != null) {
        // Используем данные с сервера
        await setUserData(
          serverUserData['name'] ?? _userName,
          serverUserData['email'] ?? _userEmail,
          userId: serverUserId,
        );

        // Обновляем аватарку если есть
        if (serverUserData['avatar'] != null) {
          await updateProfileImage(serverUserData['avatar']);
        }

        print('✅ UserProvider: Successfully synced with server');
      } else {
        // Если не удалось получить данные с сервера, но есть серверный ID
        print('⚠️ Could not fetch server user data, but using server ID: $serverUserId');
        await setUserData(_userName, _userEmail, userId: serverUserId);
      }

    } catch (e) {
      print('❌ UserProvider: Error syncing with server: $e');
    }
  }

  // 🎯 СИНХРОНИЗАЦИЯ С AUTH SERVICE
  Future<void> syncWithAuthService() async {
    try {
      print('🔄 UserProvider: Syncing with AuthService...');

      final authUser = await AuthService.getCurrentUser();
      if (authUser != null) {
        print('🔄 UserProvider: AuthService data: $authUser');

        // Используем серверные данные
        final serverUserId = authUser['id'] ?? authUser['user_id'];
        final serverUserName = authUser['name'] ?? _userName;
        final serverUserEmail = authUser['email'] ?? _userEmail;

        if (serverUserId != null && serverUserId.isNotEmpty) {
          print('🎯 Using SERVER user ID from AuthService: $serverUserId');
          await setUserData(
            serverUserName,
            serverUserEmail,
            userId: serverUserId.toString(),
          );
        } else {
          print('⚠️ No server user ID in AuthService, using existing ID');
          await setUserData(serverUserName, serverUserEmail);
        }

        // Обновляем аватарку если есть
        if (authUser['avatar'] != null) {
          await updateProfileImage(authUser['avatar']);
        }

        print('✅ UserProvider: Synced with AuthService');
      } else {
        print('⚠️ UserProvider: No auth user data found');
      }
    } catch (e) {
      print('❌ UserProvider: Error syncing with AuthService: $e');
      // Пробуем использовать syncWithServer как запасной вариант
      await syncWithServer();
    }
  }

  // 🎯 ПРОВЕРКА АВТОРИЗАЦИИ
  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasUserData = prefs.getString(_userNameKey) != null;

      // Проверяем авторизацию через Auth Service
      final isAuthLoggedIn = await AuthService.isLoggedIn();

      print('🔐 UserProvider: Auth check - Local: $hasUserData, AuthService: $isAuthLoggedIn');

      // Если есть данные в AuthService, синхронизируем с сервером
      if (isAuthLoggedIn && hasUserData) {
        await syncWithServer();
      }

      return hasUserData && isAuthLoggedIn;
    } catch (e) {
      print('❌ UserProvider: Error checking auth status: $e');
      return false;
    }
  }

  // 🎯 ОБНОВЛЕНИЕ ДАННЫХ ИЗ СЕРВЕРА
  Future<void> updateUserFromServer() async {
    try {
      print('🔄 UserProvider: Updating user data from server');
      await syncWithServer();
    } catch (e) {
      print('❌ UserProvider: Error updating from server: $e');
    }
  }

  // 🎯 ОБНОВЛЕНИЕ АВАТАРКИ
  Future<void> updateProfileImage(String? imageUrl) async {
    _profileImageUrl = imageUrl;
    await _saveUserData();
    notifyListeners();

    print('🖼️ UserProvider: Profile image updated: $imageUrl');
  }

  // 🎯 ОБНОВЛЕНИЕ ОБЛОЖКИ
  Future<void> updateCoverImage(String? imageUrl) async {
    _coverImageUrl = imageUrl;
    await _saveUserData();
    notifyListeners();

    print('🏞️ UserProvider: Cover image updated: $imageUrl');
  }

  // 🎯 ОБНОВЛЕНИЕ СТАТИСТИКИ
  Future<void> updateStats(Map<String, int> newStats) async {
    _stats.addAll(newStats);
    await _saveUserData();
    notifyListeners();

    print('📊 UserProvider: Stats updated: $newStats');
  }

  // 🎯 ОБНОВЛЕНИЕ ИМЕНИ
  Future<void> updateUserName(String newName) async {
    _userName = newName;
    await _saveUserData();
    notifyListeners();

    print('✏️ UserProvider: Username updated: $newName');
  }

  // 🎯 ПОЛУЧЕНИЕ ДАННЫХ ДЛЯ СОЗДАНИЯ НОВОСТЕЙ
  Map<String, dynamic> getAuthorData() {
    return {
      'author_id': _userId,
      'author_name': _userName,
      'author_email': _userEmail,
      'author_avatar': _profileImageUrl ?? '',
    };
  }

  // 🎯 ПРОВЕРКА ЯВЛЯЕТСЯ ЛИ ПОЛЬЗОВАТЕЛЬ АВТОРОМ
  bool isAuthorOf(String authorId) {
    return _userId == authorId;
  }

  // 🎯 ОЧИСТКА ДАННЫХ (LOGOUT)
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_profileImageUrlKey);
      await prefs.remove(_coverImageUrlKey);
      await prefs.remove(_userStatsKey);

      _userName = '';
      _userEmail = '';
      _userId = '';
      _profileImageUrl = null;
      _coverImageUrl = null;
      _stats = {
        'posts': 0,
        'likes': 0,
        'comments': 0,
        'followers': 0,
        'following': 0,
      };

      print('🚪 UserProvider: Cleared all user data');
      notifyListeners();
    } catch (e) {
      print('❌ UserProvider: Error clearing user data: $e');
    }
  }

  // 🎯 ПОЛУЧЕНИЕ ДАННЫХ В ФОРМАТЕ ДЛЯ API
  Map<String, dynamic> toMap() {
    return {
      'id': _userId,
      'name': _userName,
      'email': _userEmail,
      'profileImageUrl': _profileImageUrl,
      'coverImageUrl': _coverImageUrl,
      'stats': _stats,
    };
  }

  @override
  String toString() {
    return 'UserProvider{name: $_userName, email: $_userEmail, id: $_userId, stats: $_stats}';
  }
}