// models_room/achievement.dart
enum AchievementType {
  firstMessage,      // Первое сообщение
  topicCreator,      // Создал первую тему
  activeUser,        // 10+ сообщений
  popularTopic,      // Тема с 10+ сообщениями
  categoryExplorer,  // Участвовал в 3+ категориях
  nightOwl,          // Сообщение ночью (22-6)
  quickReplier,      // Ответ в течение 5 минут
  conversationStarter, // Создал 5+ тем
  socialButterfly,   // 50+ сообщений
  expert             // 100+ сообщений
}

class Achievement {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final DateTime earnedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedAt,
    required this.isUnlocked,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? earnedAt,
  }) {
    return Achievement(
      id: id,
      type: type,
      title: title,
      description: description,
      icon: icon,
      earnedAt: earnedAt ?? this.earnedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}