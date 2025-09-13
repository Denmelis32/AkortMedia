import 'achievement.dart';
import 'access_level.dart';

class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String avatarUrl; // ← Добавить это поле
  final int messagesCount;
  final int topicsCreated;
  final Set<String> participatedCategories;
  final Map<AchievementType, DateTime> achievements;

  const UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    required this.avatarUrl, // ← Добавить
    required this.messagesCount,
    required this.topicsCreated,
    required this.participatedCategories,
    required this.achievements,
  });

  UserPermissions copyWith({
    bool? isSeniorDeveloper,
    bool? isLongTermFan,
    DateTime? joinDate,
    String? avatarUrl, // ← Добавить
    int? messagesCount,
    int? topicsCreated,
    Set<String>? participatedCategories,
    Map<AchievementType, DateTime>? achievements,
  }) {
    return UserPermissions(
      isSeniorDeveloper: isSeniorDeveloper ?? this.isSeniorDeveloper,
      isLongTermFan: isLongTermFan ?? this.isLongTermFan,
      joinDate: joinDate ?? this.joinDate,
      avatarUrl: avatarUrl ?? this.avatarUrl, // ← Добавить
      messagesCount: messagesCount ?? this.messagesCount,
      topicsCreated: topicsCreated ?? this.topicsCreated,
      participatedCategories: participatedCategories ?? this.participatedCategories,
      achievements: achievements ?? this.achievements,
    );
  }
}