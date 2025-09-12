// models_room/user_permissions.dart
import 'achievement.dart';

class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String avatarUrl;
  final int messagesCount;
  final int topicsCreated;
  final Set<String> participatedCategories;
  final Map<AchievementType, DateTime> achievements;

  UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    required this.avatarUrl,
    this.messagesCount = 0,
    this.topicsCreated = 0,
    Set<String>? participatedCategories,
    Map<AchievementType, DateTime>? achievements,
  })  : participatedCategories = participatedCategories ?? {},
        achievements = achievements ?? {};

  UserPermissions copyWith({
    int? messagesCount,
    int? topicsCreated,
    Set<String>? participatedCategories,
    Map<AchievementType, DateTime>? achievements,
  }) {
    return UserPermissions(
      isSeniorDeveloper: isSeniorDeveloper,
      isLongTermFan: isLongTermFan,
      joinDate: joinDate,
      avatarUrl: avatarUrl,
      messagesCount: messagesCount ?? this.messagesCount,
      topicsCreated: topicsCreated ?? this.topicsCreated,
      participatedCategories: participatedCategories ?? this.participatedCategories,
      achievements: achievements ?? this.achievements,
    );
  }
}