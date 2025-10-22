// models/user_profile.dart
import 'dart:io';

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

  // Метод для копирования с обновлениями
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