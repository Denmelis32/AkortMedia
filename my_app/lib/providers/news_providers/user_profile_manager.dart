// lib/providers/news_providers/user_profile_manager.dart
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../../services/storage_service.dart';

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



  Future<void> loadProfileData() async {
    if (_currentUserId == null) return;
    await _loadUserProfileData(_currentUserId!);
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

// Делегируем вызов StorageService
  Future<void> removeCoverImage() async {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      coverImageUrl: null,
      coverImageFile: null,
    );

    _notifyListeners();
    await StorageService.saveCoverImageUrl(_currentUserId!, null);
    await StorageService.saveCoverImageFilePath(_currentUserId!, null);
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

    await StorageService.saveProfileImageUrl(_currentUserId!, validatedUrl);
    await _loadUserProfileData(_currentUserId!);
  }

  Future<void> updateProfileImageFile(File? file) async {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageFile: file,
      profileImageUrl: null,
    );

    _notifyListeners();

    if (file != null) {
      final exists = await file.exists();
      if (exists) {
        await StorageService.saveProfileImageFilePath(_currentUserId!, file.path);
      } else {
        _userProfiles[_currentUserId!] = user.copyWith(profileImageFile: null);
      }
    } else {
      await StorageService.saveProfileImageFilePath(_currentUserId!, null);
    }

    await _loadUserProfileData(_currentUserId!);
  }

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
    await _loadUserProfileData(_currentUserId!);
  }

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
      } else {
        _userProfiles[_currentUserId!] = user.copyWith(coverImageFile: null);
      }
    } else {
      await StorageService.saveCoverImageFilePath(_currentUserId!, null);
    }

    await _loadUserProfileData(_currentUserId!);
  }

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
    } catch (e) {
      print('❌ Error loading profile data: $e');
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

  String getUserAvatarUrl(String userId, String userName) {
    // 1. Проверяем текущего пользователя
    if (_currentUserId == userId) {
      final currentUser = _getCurrentUser();
      if (currentUser?.profileImageFile != null) return currentUser!.profileImageFile!.path;
      if (currentUser?.profileImageUrl != null && currentUser!.profileImageUrl!.isNotEmpty) {
        return currentUser.profileImageUrl!;
      }
    }

    // 2. Проверяем других пользователей
    final userProfile = getUserProfile(userId);
    if (userProfile != null) {
      if (userProfile.profileImageFile != null) return userProfile.profileImageFile!.path;
      if (userProfile.profileImageUrl != null && userProfile.profileImageUrl!.isNotEmpty) {
        return userProfile.profileImageUrl!;
      }
    }

    // 3. Fallback аватар
    return _getFallbackAvatarUrl(userName);
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

  void removeProfileImage() {
    if (_currentUserId == null) return;

    final user = _userProfiles[_currentUserId!];
    if (user == null) return;

    _userProfiles[_currentUserId!] = user.copyWith(
      profileImageUrl: null,
      profileImageFile: null,
    );

    _notifyListeners();
    StorageService.saveProfileImageUrl(_currentUserId!, null);
    StorageService.saveProfileImageFilePath(_currentUserId!, null);
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
}