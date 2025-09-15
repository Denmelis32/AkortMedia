enum AchievementType {
  firstMessage,
  topicCreator,
  activeUser,
  popularTopic,
  categoryExplorer,
  nightOwl,
  quickReplier,
  conversationStarter,
  socialButterfly,
  expert,
  firstSubscription,
  subscriber,
  channelExplorer,
  superFan,
  verifiedLover,
}

class Achievement {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final DateTime earnedAt;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedAt,
    required this.isUnlocked,
  });

  Achievement copyWith({
    String? id,
    AchievementType? type,
    String? title,
    String? description,
    String? icon,
    DateTime? earnedAt,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      earnedAt: earnedAt ?? this.earnedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}