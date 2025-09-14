import 'achievement.dart';
import 'access_level.dart';
import 'channel.dart'; // Импортируем модель канала

class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String avatarUrl;
  final int messagesCount;
  final int topicsCreated;
  final String userId;
  final Set<String> participatedCategories;
  final Map<AchievementType, DateTime> achievements;
  final List<String> subscribedChannels; // Добавляем список подписанных каналов

  const UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    required this.avatarUrl,
    required this.messagesCount,
    required this.topicsCreated,
    required this.userId,
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
    String? userId,
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
      participatedCategories: participatedCategories ?? this.participatedCategories,
      achievements: achievements ?? this.achievements,
      subscribedChannels: subscribedChannels ?? this.subscribedChannels, // Добавляем
    );
  }
}