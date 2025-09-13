import 'achievement.dart';
import 'access_level.dart';

class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String avatarUrl;
  final int messagesCount;
  final int topicsCreated;
  final String userId; // ← Уже есть
  final Set<String> participatedCategories;
  final Map<AchievementType, DateTime> achievements;

  const UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    required this.avatarUrl,
    required this.messagesCount,
    required this.topicsCreated,
    required this.userId, // ← Добавляем в конструктор
    required this.participatedCategories,
    required this.achievements,
  });

  UserPermissions copyWith({
    bool? isSeniorDeveloper,
    bool? isLongTermFan,
    DateTime? joinDate,
    String? avatarUrl,
    int? messagesCount,
    int? topicsCreated,
    String? userId, // ← Добавляем в copyWith
    Set<String>? participatedCategories,
    Map<AchievementType, DateTime>? achievements,
  }) {
    return UserPermissions(
      isSeniorDeveloper: isSeniorDeveloper ?? this.isSeniorDeveloper,
      isLongTermFan: isLongTermFan ?? this.isLongTermFan,
      joinDate: joinDate ?? this.joinDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messagesCount: messagesCount ?? this.messagesCount,
      topicsCreated: topicsCreated ?? this.topicsCreated,
      userId: userId ?? this.userId, // ← Добавляем
      participatedCategories: participatedCategories ?? this.participatedCategories,
      achievements: achievements ?? this.achievements,
    );
  }
}