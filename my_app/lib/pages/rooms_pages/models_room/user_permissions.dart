
import 'achievement.dart';

class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String avatarUrl;
  final int messagesCount;
  final int topicsCreated;
  final String userId; // Добавляемое поле 1
  final String userName; // Добавляемое поле 2
  final Set<String> participatedCategories;
  final Map<AchievementType, DateTime> achievements;
  final List<String> subscribedChannels; // Добавляемое поле 3

  const UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    required this.avatarUrl,
    required this.messagesCount,
    required this.topicsCreated,
    required this.userId, // Добавляем в конструктор
    required this.userName, // Добавляем в конструктор
    required this.participatedCategories,
    required this.achievements,
    required this.subscribedChannels, // Добавляем в конструктор
  });

  UserPermissions copyWith({
    bool? isSeniorDeveloper,
    bool? isLongTermFan,
    DateTime? joinDate,
    String? avatarUrl,
    int? messagesCount,
    int? topicsCreated,
    String? userId, // Добавляем в copyWith
    String? userName, // Добавляем в copyWith
    Set<String>? participatedCategories,
    Map<AchievementType, DateTime>? achievements,
    List<String>? subscribedChannels, // Добавляем в copyWith
  }) {
    return UserPermissions(
      isSeniorDeveloper: isSeniorDeveloper ?? this.isSeniorDeveloper,
      isLongTermFan: isLongTermFan ?? this.isLongTermFan,
      joinDate: joinDate ?? this.joinDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messagesCount: messagesCount ?? this.messagesCount,
      topicsCreated: topicsCreated ?? this.topicsCreated,
      userId: userId ?? this.userId,
      // Копируем
      userName: userName ?? this.userName,
      // Копируем
      participatedCategories: participatedCategories ??
          this.participatedCategories,
      achievements: achievements ?? this.achievements,
      subscribedChannels: subscribedChannels ??
          this.subscribedChannels, // Копируем
    );
  }
}