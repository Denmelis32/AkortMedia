// lib/providers/news_providers/user_profile_manager.dart
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import '../../services/image_upload_service.dart';

class UserProfile {
  final String id;
  final String userName;
  final String userEmail;
  String? profileImageUrl;
  File? profileImageFile;
  String? coverImageUrl;
  File? coverImageFile;
  DateTime? registrationDate;
  Map<String, int> stats;

  UserProfile({
    required this.id,
    required this.userName,
    required this.userEmail,
    this.profileImageUrl,
    this.profileImageFile,
    this.coverImageUrl,
    this.coverImageFile,
    this.registrationDate,
    this.stats = const {},
  });

  UserProfile copyWith({
    String? userName,
    String? userEmail,
    String? profileImageUrl,
    File? profileImageFile,
    String? coverImageUrl,
    File? coverImageFile,
    Map<String, int>? stats,
  }) {
    return UserProfile(
      id: id,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImageFile: profileImageFile ?? this.profileImageFile,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverImageFile: coverImageFile ?? this.coverImageFile,
      registrationDate: registrationDate,
      stats: stats ?? this.stats,
    );
  }
}

class UserProfileManager {
  final Map<String, UserProfile> _userProfiles = {};
  String? _currentUserId;
  Function()? _onProfileUpdated;

  String? get currentUserId => _currentUserId;
  String? get profileImageUrl => _getCurrentUser()?.profileImageUrl;
  File? get profileImageFile => _getCurrentUser()?.profileImageFile;
  String? get coverImageUrl => _getCurrentUser()?.coverImageUrl;
  File? get coverImageFile => _getCurrentUser()?.coverImageFile;

  void setOnProfileUpdated(Function()? callback) {
    _onProfileUpdated = callback;
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ЗАГРУЗКИ ДАННЫХ ПРОФИЛЯ
  Future<void> loadProfileData() async {
    if (_currentUserId == null) return;

    print('🔄 Loading profile data for user: $_currentUserId');

    try {
      // 🎯 ПЕРВОЕ: Пробуем загрузить с сервера
      try {
        final serverProfile = await ApiService.getUserProfile(_currentUserId!);
        if (serverProfile != null) {
          _updateProfileFromServer(_currentUserId!, serverProfile);
          print('✅ Profile loaded from server for: $_currentUserId');
          return;
        }
      } catch (e) {
        print('⚠️ Could not load profile from server: $e');
        // Продолжаем с локальными данными
      }

      // 🎯 FALLBACK: Загружаем локальные данные
      await _loadUserProfileData(_currentUserId!);

    } catch (e) {
      print('❌ Error loading profile data: $e');
    }
  }

  dynamic getCurrentProfileImage() {
    if (_currentUserId == null) return null;
    final user = _userProfiles[_currentUserId!];
    if (user?.profileImageFile != null) return user!.profileImageFile;
    if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) return user.profileImageUrl;
    return null;
  }

  dynamic getCurrentCoverImage() {
    if (_currentUserId == null) return null;
    final user = _userProfiles[_currentUserId!];
    if (user?.coverImageFile != null) return user!.coverImageFile;
    if (user?.coverImageUrl != null && user!.coverImageUrl!.isNotEmpty) return user.coverImageUrl;
    return null;
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД УДАЛЕНИЯ ОБЛОЖКИ
  Future<void> removeCoverImage() async {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageUrl: null,
      coverImageFile: null,
    );

    _notifyListeners();

    // 🎯 СОХРАНЯЕМ ЛОКАЛЬНО И СИНХРОНИЗИРУЕМ С СЕРВЕРОМ
    await StorageService.saveCoverImageUrl(_currentUserId!, null);
    await StorageService.saveCoverImageFilePath(_currentUserId!, null);

    try {
      await ApiService.updateProfile({
        'coverImageUrl': null,
      });
      print('✅ Cover image removed from server');
    } catch (e) {
      print('❌ Error removing cover image from server: $e');
    }
  }

  void setCurrentUser(String userId, String userName, String userEmail) {
    _currentUserId = userId;

    if (!_userProfiles.containsKey(userId)) {
      _userProfiles[userId] = UserProfile(
        id: userId,
        userName: userName,
        userEmail: userEmail,
        registrationDate: DateTime.now(),
        stats: {},
      );
      _loadUserProfileData(userId);
    }

    _notifyListeners();
  }

  UserProfile? _getCurrentUser() {
    if (_currentUserId == null) return null;
    return _userProfiles[_currentUserId!];
  }

  UserProfile? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  // 🎯 МЕТОД ДЛЯ ПОИСКА ПРОФИЛЯ ПО ИМЕНИ ПОЛЬЗОВАТЕЛЯ
  UserProfile? _getUserProfileByName(String userName) {
    for (final profile in _userProfiles.values) {
      if (profile.userName == userName) {
        return profile;
      }
    }
    return null;
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ДЛЯ URL АВАТАРКИ
  Future<void> updateProfileImageUrl(String? url) async {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    String? validatedUrl = await _validateImageUrl(url);

    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageUrl: validatedUrl,
      profileImageFile: null,
    );

    _notifyListeners();

    // 🎯 СОХРАНЯЕМ ЛОКАЛЬНО И ОТПРАВЛЯЕМ НА СЕРВЕР
    await StorageService.saveProfileImageUrl(_currentUserId!, validatedUrl);

    if (validatedUrl != null) {
      try {
        await ApiService.updateProfile({
          'profileImageUrl': validatedUrl,
        });
        print('✅ Profile image URL synced with server: $validatedUrl');
      } catch (e) {
        print('❌ Error syncing profile image with server: $e');
      }
    } else {
      // Если URL null, удаляем аватарку на сервере
      try {
        await ApiService.updateProfile({
          'profileImageUrl': null,
        });
        print('✅ Profile image removed from server');
      } catch (e) {
        print('❌ Error removing profile image from server: $e');
      }
    }

    await _loadUserProfileData(_currentUserId!);
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ДЛЯ ФАЙЛА АВАТАРКИ
  Future<void> updateProfileImageFile(File? file) async {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    // Сразу обновляем UI с локальным файлом
    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageFile: file,
      profileImageUrl: null,
    );

    _notifyListeners();

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        // Сохраняем локальный путь
        await StorageService.saveProfileImageFilePath(_currentUserId!, file.path);

        // 🎯 ЗАГРУЖАЕМ ФАЙЛ НА СЕРВЕР
        try {
          print('🔄 Uploading profile image to server...');
          final imageUrl = await ImageUploadService.uploadUserAvatar(file, _currentUserId!);

          // Обновляем URL после успешной загрузки
          _userProfiles[_currentUserId!] = user.copyWith(
            profileImageUrl: imageUrl,
            profileImageFile: null,
          );

          // Синхронизируем с сервером
          await ApiService.updateProfile({
            'profileImageUrl': imageUrl,
          });

          // Обновляем локальное хранилище
          await StorageService.saveProfileImageUrl(_currentUserId!, imageUrl);
          await StorageService.saveProfileImageFilePath(_currentUserId!, null);

          _notifyListeners();
          print('✅ Profile image uploaded to server: $imageUrl');

        } catch (e) {
          print('❌ Error uploading profile image to server: $e');
          // Оставляем локальный файл как fallback
          _showUploadErrorNotification();
        }
      } else {
        _userProfiles[_currentUserId!] = user.copyWith(profileImageFile: null);
        await StorageService.saveProfileImageFilePath(_currentUserId!, null);
      }
    } else {
      // Удаляем файл
      await StorageService.saveProfileImageFilePath(_currentUserId!, null);

      // 🎯 УДАЛЯЕМ АВАТАРКУ НА СЕРВЕРЕ
      try {
        await ApiService.updateProfile({
          'profileImageUrl': null,
        });
        print('✅ Profile image removed from server');
      } catch (e) {
        print('❌ Error removing profile image from server: $e');
      }
    }

    await _loadUserProfileData(_currentUserId!);
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ДЛЯ URL ОБЛОЖКИ
  Future<void> updateCoverImageUrl(String? url) async {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    String? validatedUrl = await _validateImageUrl(url);

    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageUrl: validatedUrl,
      coverImageFile: null,
    );

    _notifyListeners();

    await StorageService.saveCoverImageUrl(_currentUserId!, validatedUrl);

    if (validatedUrl != null) {
      try {
        await ApiService.updateProfile({
          'coverImageUrl': validatedUrl,
        });
        print('✅ Cover image URL synced with server: $validatedUrl');
      } catch (e) {
        print('❌ Error syncing cover image with server: $e');
      }
    }

    await _loadUserProfileData(_currentUserId!);
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ДЛЯ ФАЙЛА ОБЛОЖКИ
  Future<void> updateCoverImageFile(File? file) async {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageFile: file,
      coverImageUrl: null,
    );

    _notifyListeners();

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        await StorageService.saveCoverImageFilePath(_currentUserId!, file.path);

        // 🎯 TODO: Реализовать загрузку обложки на сервер
        // final coverUrl = await ImageUploadService.uploadCoverImage(file, _currentUserId!);
        // await ApiService.updateProfile({'coverImageUrl': coverUrl});

      } else {
        _userProfiles[_currentUserId!] = user.copyWith(coverImageFile: null);
      }
    } else {
      await StorageService.saveCoverImageFilePath(_currentUserId!, null);
    }

    await _loadUserProfileData(_currentUserId!);
  }

  // 🎯 ВАЛИДАЦИЯ URL ИЗОБРАЖЕНИЯ
  Future<String?> _validateImageUrl(String? url) async {
    if (url == null || url.isEmpty) return null;

    try {
      final uri = Uri.parse(url);
      String validatedUrl = uri.hasScheme ? url : 'https://$url';

      final response = await http.head(Uri.parse(validatedUrl));
      if (response.statusCode != 200) {
        throw Exception('Изображение недоступно: ${response.statusCode}');
      }

      return validatedUrl;
    } catch (e) {
      throw Exception('Некорректная ссылка на изображение: $e');
    }
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ЗАГРУЗКИ ЛОКАЛЬНЫХ ДАННЫХ
  Future<void> _loadUserProfileData(String userId) async {
    try {
      final savedUrl = await StorageService.loadProfileImageUrl(userId);
      final savedFilePath = await StorageService.loadProfileImageFilePath(userId);
      final savedCoverUrl = await StorageService.loadCoverImageUrl(userId);
      final savedCoverPath = await StorageService.loadCoverImageFilePath(userId);

      File? profileFile = await _getValidFile(savedFilePath);
      File? coverFile = await _getValidFile(savedCoverPath);

      if (_userProfiles.containsKey(userId)) {
        _userProfiles[userId] = _userProfiles[userId]!.copyWith(
          profileImageUrl: savedUrl,
          profileImageFile: profileFile,
          coverImageUrl: savedCoverUrl,
          coverImageFile: coverFile,
        );
      }

      _notifyListeners();
      print('✅ Local profile data loaded for: $userId');
    } catch (e) {
      print('❌ Error loading local profile data: $e');
    }
  }

  // 🎯 ОБНОВЛЕНИЕ ПРОФИЛЯ ИЗ ДАННЫХ СЕРВЕРА
  void _updateProfileFromServer(String userId, Map<String, dynamic> serverData) {
    if (_userProfiles.containsKey(userId)) {
      final currentProfile = _userProfiles[userId]!;

      _userProfiles[userId] = currentProfile.copyWith(
        profileImageUrl: serverData['profileImageUrl'] ?? currentProfile.profileImageUrl,
        coverImageUrl: serverData['coverImageUrl'] ?? currentProfile.coverImageUrl,
        userName: serverData['name'] ?? currentProfile.userName,
        userEmail: serverData['email'] ?? currentProfile.userEmail,
        stats: serverData['stats'] ?? currentProfile.stats,
      );

      // 🎯 СОХРАНЯЕМ ЛОКАЛЬНО ДЛЯ ОФФЛАЙН ДОСТУПА
      if (serverData['profileImageUrl'] != null) {
        StorageService.saveProfileImageUrl(userId, serverData['profileImageUrl']);
      }
      if (serverData['coverImageUrl'] != null) {
        StorageService.saveCoverImageUrl(userId, serverData['coverImageUrl']);
      }

      _notifyListeners();
      print('✅ Profile updated from server data for: $userId');
    }
  }

  Future<File?> _getValidFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return null;

    final file = File(filePath);
    if (await file.exists()) {
      return file;
    } else {
      await StorageService.saveProfileImageFilePath(_currentUserId!, null);
      return null;
    }
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ
  String getUserAvatarUrl(String userId, String userName) {
    print('🔍 UserProfileManager: Getting avatar for $userName ($userId)');

    // 1. Ищем по userId
    UserProfile? userProfile = getUserProfile(userId);

    // 2. Если не нашли по ID, ищем текущего пользователя по имени
    if (userProfile == null && _currentUserId != null) {
      final currentUser = _getCurrentUser();
      if (currentUser != null && currentUser.userName == userName) {
        userProfile = currentUser;
      }
    }

    // 3. Если не нашли, ищем любого пользователя по имени
    if (userProfile == null) {
      userProfile = _getUserProfileByName(userName);
    }

    // 4. Приоритет: серверный URL > локальный файл > fallback
    if (userProfile != null) {
      // Сначала проверяем серверный URL
      if (userProfile.profileImageUrl != null && userProfile.profileImageUrl!.isNotEmpty) {
        print('✅ UserProfileManager: Using server profile URL: ${userProfile.profileImageUrl}');
        return userProfile.profileImageUrl!;
      }
      // Затем локальный файл
      if (userProfile.profileImageFile != null) {
        print('✅ UserProfileManager: Using local profile file: ${userProfile.profileImageFile!.path}');
        return userProfile.profileImageFile!.path;
      }
    }

    // 5. Final fallback
    final fallback = _getFallbackAvatarUrl(userName);
    print('⚠️ UserProfileManager: Using fallback avatar: $fallback');
    return fallback;
  }

  String _getFallbackAvatarUrl(String userName) {
    final avatars = [
      'assets/images/ava_news/ava1.png',
      'assets/images/ava_news/ava2.png',
      'assets/images/ava_news/ava3.png',
      'assets/images/ava_news/ava4.png',
      'assets/images/ava_news/ava5.png',
      'assets/images/ava_news/ava6.png',
      'assets/images/ava_news/ava7.png',
      'assets/images/ava_news/ava8.png',
      'assets/images/ava_news/ava9.png',
      'assets/images/ava_news/ava10.png',
      'assets/images/ava_news/ava11.png',
      'assets/images/ava_news/ava12.png',
    ];

    final index = userName.hashCode.abs() % avatars.length;
    return avatars[index];
  }

  void _notifyListeners() {
    _onProfileUpdated?.call();
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД УДАЛЕНИЯ АВАТАРКИ
  void removeProfileImage() {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageUrl: null,
      profileImageFile: null,
    );

    _notifyListeners();

    // 🎯 УДАЛЯЕМ ЛОКАЛЬНО И С СЕРВЕРА
    StorageService.saveProfileImageUrl(_currentUserId!, null);
    StorageService.saveProfileImageFilePath(_currentUserId!, null);

    try {
      ApiService.updateProfile({
        'profileImageUrl': null,
      });
      print('✅ Profile image removed from server');
    } catch (e) {
      print('❌ Error removing profile image from server: $e');
    }
  }

  bool hasProfileImage() {
    if (_currentUserId == null) return false;
    final user = _userProfiles[_currentUserId!];
    return user?.profileImageUrl != null || user?.profileImageFile != null;
  }

  bool hasCoverImage() {
    if (_currentUserId == null) return false;
    final user = _userProfiles[_currentUserId!];
    return user?.coverImageUrl != null || user?.coverImageFile != null;
  }

  // 🎯 УВЕДОМЛЕНИЕ ОБ ОШИБКЕ ЗАГРУЗКИ
  void _showUploadErrorNotification() {
    // TODO: Реализовать показ уведомления об ошибке
    print('❌ Failed to upload profile image to server');
  }

  // 🎯 СИНХРОНИЗАЦИЯ ВСЕХ ДАННЫХ С СЕРВЕРОМ
  Future<void> syncAllProfilesWithServer() async {
    print('🔄 Syncing all profiles with server...');

    try {
      for (final profile in _userProfiles.values) {
        try {
          final serverProfile = await ApiService.getUserProfile(profile.id);
          if (serverProfile != null) {
            _updateProfileFromServer(profile.id, serverProfile);
          }
        } catch (e) {
          print('❌ Error syncing profile ${profile.id}: $e');
        }
      }
      print('✅ All profiles synced with server');
    } catch (e) {
      print('❌ Error during profile sync: $e');
    }
  }
}