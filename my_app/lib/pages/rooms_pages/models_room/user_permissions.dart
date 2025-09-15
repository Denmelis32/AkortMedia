import 'achievement.dart';

class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String avatarUrl;
  final int messagesCount;
  final int topicsCreated;
  final String userId;
  final String userName; // ДОБАВЛЯЕМ ЭТУ СТРОКУ
  final Set<String> participatedCategories;
  final Map<AchievementType, DateTime> achievements;
  final List<String> subscribedChannels;

  const UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    required this.avatarUrl,
    required this.messagesCount,
    required this.topicsCreated,
    required this.userId,
    required this.userName, // ДОБАВЛЯЕМ В КОНСТРУКТОР
    required this.participatedCategories,
    required this.achievements,
    required this.subscribedChannels,
  });

  UserPermissions copyWith({
    bool? isSeniorDeveloper,
    bool? isLongTermFan,
    DateTime? joinDate,
    String? avatarUrl,
    int? messagesCount,
    int? topicsCreated,
    String? userId,
    String? userName, // ДОБАВЛЯЕМ В copyWith
    Set<String>? participatedCategories,
    Map<AchievementType, DateTime>? achievements,
    List<String>? subscribedChannels,
  }) {
    return UserPermissions(
      isSeniorDeveloper: isSeniorDeveloper ?? this.isSeniorDeveloper,
      isLongTermFan: isLongTermFan ?? this.isLongTermFan,
      joinDate: joinDate ?? this.joinDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messagesCount: messagesCount ?? this.messagesCount,
      topicsCreated: topicsCreated ?? this.topicsCreated,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName, // ДОБАВЛЯЕМ
      participatedCategories: participatedCategories ?? this.participatedCategories,
      achievements: achievements ?? this.achievements,
      subscribedChannels: subscribedChannels ?? this.subscribedChannels,
    );
  }
}