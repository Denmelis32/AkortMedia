import '../pages/rooms_pages/models_room/achievement.dart';
import '../pages/rooms_pages/models_room/user_permissions.dart';
import '../pages/rooms_pages/models_room/channel.dart'; // Добавляем импорт для Channel

class AchievementService {
  static final Map<AchievementType, Achievement> _achievementData = {
    AchievementType.firstMessage: Achievement(
      id: 'first_message',
      type: AchievementType.firstMessage,
      title: 'Первый шаг',
      description: 'Написано первое сообщение',
      icon: '🎯',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.topicCreator: Achievement(
      id: 'topic_creator',
      type: AchievementType.topicCreator,
      title: 'Основатель',
      description: 'Создана первая тема',
      icon: '🏗️',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.activeUser: Achievement(
      id: 'active_user',
      type: AchievementType.activeUser,
      title: 'Активный участник',
      description: 'Написано 10+ сообщений',
      icon: '💬',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.popularTopic: Achievement(
      id: 'popular_topic',
      type: AchievementType.popularTopic,
      title: 'Популярная тема',
      description: 'Тема собрала 10+ сообщений',
      icon: '🔥',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.categoryExplorer: Achievement(
      id: 'category_explorer',
      type: AchievementType.categoryExplorer,
      title: 'Исследователь',
      description: 'Участие в 3+ категориях',
      icon: '🧭',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.nightOwl: Achievement(
      id: 'night_owl',
      type: AchievementType.nightOwl,
      title: 'Ночная сова',
      description: 'Сообщение отправлено ночью (22:00-6:00)',
      icon: '🦉',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.quickReplier: Achievement(
      id: 'quick_replier',
      type: AchievementType.quickReplier,
      title: 'Скоростной ответ',
      description: 'Ответ в течение 5 минут',
      icon: '⚡',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.conversationStarter: Achievement(
      id: 'conversation_starter',
      type: AchievementType.conversationStarter,
      title: 'Заводила',
      description: 'Создано 5+ тем',
      icon: '🎤',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.socialButterfly: Achievement(
      id: 'social_butterfly',
      type: AchievementType.socialButterfly,
      title: 'Социальная бабочка',
      description: 'Написано 50+ сообщений',
      icon: '🦋',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.expert: Achievement(
      id: 'expert',
      type: AchievementType.expert,
      title: 'Эксперт',
      description: 'Написано 100+ сообщений',
      icon: '🎓',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    // ДОБАВЛЯЕМ НОВЫЕ ДОСТИЖЕНИЯ ДЛЯ ПОДПИСОК
    AchievementType.firstSubscription: Achievement(
      id: 'first_subscription',
      type: AchievementType.firstSubscription,
      title: 'Первый канал!',
      description: 'Подписка на первый канал',
      icon: '⭐',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.subscriber: Achievement(
      id: 'subscriber',
      type: AchievementType.subscriber,
      title: 'Активный подписчик',
      description: 'Подписаны на 5 каналов',
      icon: '📺',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.channelExplorer: Achievement(
      id: 'channel_explorer',
      type: AchievementType.channelExplorer,
      title: 'Исследователь каналов',
      description: 'Подписка на канал в новой категории',
      icon: '🔍',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.superFan: Achievement(
      id: 'super_fan',
      type: AchievementType.superFan,
      title: 'Супер-фанат',
      description: 'Подписаны на 10+ каналов',
      icon: '🤩',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
    AchievementType.verifiedLover: Achievement(
      id: 'verified_lover',
      type: AchievementType.verifiedLover,
      title: 'Любитель проверенного',
      description: 'Подписка на проверенный канал',
      icon: '✅',
      earnedAt: DateTime.now(),
      isUnlocked: false,
    ),
  };

  /// Проверяет и возвращает список новых достижений
  static List<Achievement> checkAchievements({
    required UserPermissions userPermissions,
    required String currentCategoryId,
    required DateTime messageTime,
    DateTime? lastMessageTime,
    int currentTopicMessageCount = 0,
  }) {
    final newAchievements = <Achievement>[];
    final achieved = userPermissions.achievements;

    for (final type in AchievementType.values) {
      if (!achieved.containsKey(type) &&
          _checkAchievement(
            type: type,
            user: userPermissions,
            categoryId: currentCategoryId,
            messageTime: messageTime,
            lastMessageTime: lastMessageTime,
            currentTopicMessageCount: currentTopicMessageCount,
          )) {
        newAchievements.add(_achievementData[type]!.copyWith(
          isUnlocked: true,
          earnedAt: DateTime.now(),
        ));
      }
    }

    return newAchievements;
  }

  /// НОВЫЙ МЕТОД: Проверяет достижения, связанные с подписками на каналы
  static List<Achievement> checkSubscriptionAchievements({
    required UserPermissions userPermissions,
    required Channel channel,
    required bool isSubscribing,
  }) {
    final newAchievements = <Achievement>[];
    final achieved = userPermissions.achievements;

    // Получаем текущее количество подписок пользователя
    final currentSubscriptionsCount = userPermissions.subscribedChannels.length;
    final newSubscriptionsCount = isSubscribing
        ? currentSubscriptionsCount + 1
        : currentSubscriptionsCount;

    // Проверяем достижения, связанные с подписками
    final subscriptionAchievementTypes = [
      AchievementType.firstSubscription,
      AchievementType.subscriber,
      AchievementType.channelExplorer,
      AchievementType.superFan,
      AchievementType.verifiedLover,
    ];

    for (final type in subscriptionAchievementTypes) {
      if (!achieved.containsKey(type) &&
          _checkSubscriptionAchievement(
            type: type,
            user: userPermissions,
            channel: channel,
            isSubscribing: isSubscribing,
            currentSubscriptionsCount: currentSubscriptionsCount,
            newSubscriptionsCount: newSubscriptionsCount,
          )) {
        newAchievements.add(_achievementData[type]!.copyWith(
          isUnlocked: true,
          earnedAt: DateTime.now(),
        ));
      }
    }

    return newAchievements;
  }

  /// Проверяет конкретное достижение
  static bool _checkAchievement({
    required AchievementType type,
    required UserPermissions user,
    required String categoryId,
    required DateTime messageTime,
    DateTime? lastMessageTime,
    int currentTopicMessageCount = 0,
  }) {
    switch (type) {
      case AchievementType.firstMessage:
        return user.messagesCount == 1;

      case AchievementType.topicCreator:
        return user.topicsCreated == 1;

      case AchievementType.activeUser:
        return user.messagesCount >= 10;

      case AchievementType.popularTopic:
        return currentTopicMessageCount >= 10;

      case AchievementType.categoryExplorer:
        return user.participatedCategories.length >= 3;

      case AchievementType.nightOwl:
        final hour = messageTime.hour;
        return hour >= 22 || hour < 6;

      case AchievementType.quickReplier:
        if (lastMessageTime == null) return false;
        return messageTime.difference(lastMessageTime).inMinutes <= 5;

      case AchievementType.conversationStarter:
        return user.topicsCreated >= 5;

      case AchievementType.socialButterfly:
        return user.messagesCount >= 50;

      case AchievementType.expert:
        return user.messagesCount >= 100;

    // Добавляем случаи для новых достижений (они проверяются в другом методе)
      case AchievementType.firstSubscription:
      case AchievementType.subscriber:
      case AchievementType.channelExplorer:
      case AchievementType.superFan:
      case AchievementType.verifiedLover:
        return false; // Эти достижения проверяются в checkSubscriptionAchievements
    }
  }

  /// Проверяет достижения, связанные с подписками
  static bool _checkSubscriptionAchievement({
    required AchievementType type,
    required UserPermissions user,
    required Channel channel,
    required bool isSubscribing,
    required int currentSubscriptionsCount,
    required int newSubscriptionsCount,
  }) {
    if (!isSubscribing) return false; // Достижения только при подписке

    switch (type) {
      case AchievementType.firstSubscription:
        return currentSubscriptionsCount == 0; // Первая подписка

      case AchievementType.subscriber:
        return newSubscriptionsCount >= 5; // 5+ подписок

      case AchievementType.channelExplorer:
      // Подписка на канал в новой категории
        return !user.participatedCategories.contains(channel.categoryId);

      case AchievementType.superFan:
        return newSubscriptionsCount >= 10; // 10+ подписок

      case AchievementType.verifiedLover:
        return channel.isVerified; // Подписка на проверенный канал

    // Все остальные достижения не относятся к подпискам
      default:
        return false;
    }
  }

  /// Возвращает все достижения с текущим статусом пользователя
  static List<Achievement> getAllAchievements(UserPermissions userPermissions) {
    return AchievementType.values.map((type) {
      final achievement = _achievementData[type]!;
      final isUnlocked = userPermissions.achievements.containsKey(type);
      final earnedAt = userPermissions.achievements[type];

      return achievement.copyWith(
        isUnlocked: isUnlocked,
        earnedAt: earnedAt ?? achievement.earnedAt,
      );
    }).toList();
  }

  /// Проверяет, разблокировано ли конкретное достижение
  static bool isAchievementUnlocked(AchievementType type, UserPermissions user) {
    return user.achievements.containsKey(type);
  }

  /// Возвращает достижение по типу
  static Achievement getAchievement(AchievementType type) {
    return _achievementData[type]!;
  }

  /// Возвращает количество разблокированных достижений
  static int getUnlockedCount(UserPermissions userPermissions) {
    return userPermissions.achievements.length;
  }

  /// Возвращает общее количество достижений
  static int getTotalCount() {
    return AchievementType.values.length;
  }

  /// Возвращает прогресс в процентах
  static double getProgress(UserPermissions userPermissions) {
    return getUnlockedCount(userPermissions) / getTotalCount();
  }

  /// Возвращает список всех типов достижений
  static List<AchievementType> getAllAchievementTypes() {
    return AchievementType.values;
  }

  /// Возвращает достижение по ID
  static Achievement? getAchievementById(String id) {
    return _achievementData.values.firstWhere(
          (achievement) => achievement.id == id,
      orElse: () => _achievementData.values.first,
    );
  }

  /// Возвращает достижения определенной категории
  static List<Achievement> getAchievementsByCategory(String category) {
    // Группируем достижения по категориям
    final categories = {
      'messages': [
        AchievementType.firstMessage,
        AchievementType.activeUser,
        AchievementType.socialButterfly,
        AchievementType.expert,
        AchievementType.nightOwl,
        AchievementType.quickReplier,
      ],
      'topics': [
        AchievementType.topicCreator,
        AchievementType.conversationStarter,
        AchievementType.popularTopic,
      ],
      'exploration': [
        AchievementType.categoryExplorer,
        AchievementType.channelExplorer,
      ],
      'subscriptions': [
        AchievementType.firstSubscription,
        AchievementType.subscriber,
        AchievementType.superFan,
        AchievementType.verifiedLover,
      ],
    };

    final types = categories[category] ?? [];
    return types.map((type) => _achievementData[type]!).toList();
  }
}