import 'package:flutter/material.dart';

class Room {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int currentParticipants;
  final int messageCount;
  final bool isJoined;
  final DateTime createdAt;
  final DateTime lastActivity;
  final RoomCategory category;
  final String creatorId;
  final String creatorName;
  final String? creatorAvatarUrl;
  final List<String> moderators;
  final bool isPrivate;
  final List<String> tags;
  final String language;

  // Новые свойства
  final bool isPinned;
  final int maxParticipants;
  final String rules;
  final List<String> bannedUsers;
  final bool isActive;
  final double rating;
  final int ratingCount;
  final List<String> allowedUsers;
  final String password;
  final RoomAccessLevel accessLevel;
  final DateTime? scheduledStart;
  final Duration? duration;
  final bool hasMedia;
  final bool isVerified;
  final int viewCount;
  final int favoriteCount;
  final List<RoomAttachment> attachments;
  final RoomSettings settings;
  final RoomStatistics statistics;
  final List<RoomEvent> events;
  final String? customIcon;

  // НОВОЕ СВОЙСТВО
  final bool hasPendingInvite;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.currentParticipants,
    required this.messageCount,
    required this.isJoined,
    required this.createdAt,
    required this.lastActivity,
    required this.category,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatarUrl,
    this.moderators = const [],
    this.isPrivate = false,
    this.tags = const [],
    this.language = 'ru',
    this.isPinned = false,
    this.maxParticipants = 100,
    this.rules = '',
    this.bannedUsers = const [],
    this.isActive = true,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.allowedUsers = const [],
    this.password = '',
    this.accessLevel = RoomAccessLevel.public,
    this.scheduledStart,
    this.duration,
    this.hasMedia = false,
    this.isVerified = false,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.attachments = const [],
    this.settings = const RoomSettings(),
    this.statistics = const RoomStatistics(),
    this.events = const [],
    this.customIcon,
    this.hasPendingInvite = false, // НОВОЕ СВОЙСТВО
  });

  Room copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? currentParticipants,
    int? messageCount,
    bool? isJoined,
    DateTime? createdAt,
    DateTime? lastActivity,
    RoomCategory? category,
    String? creatorId,
    String? creatorName,
    String? creatorAvatarUrl,
    List<String>? moderators,
    bool? isPrivate,
    List<String>? tags,
    String? language,
    bool? isPinned,
    int? maxParticipants,
    String? rules,
    List<String>? bannedUsers,
    bool? isActive,
    double? rating,
    int? ratingCount,
    List<String>? allowedUsers,
    String? password,
    RoomAccessLevel? accessLevel,
    DateTime? scheduledStart,
    Duration? duration,
    bool? hasMedia,
    bool? isVerified,
    int? viewCount,
    int? favoriteCount,
    List<RoomAttachment>? attachments,
    RoomSettings? settings,
    RoomStatistics? statistics,
    List<RoomEvent>? events,
    String? customIcon,
    bool? hasPendingInvite, // НОВОЕ СВОЙСТВО
  }) {
    return Room(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      messageCount: messageCount ?? this.messageCount,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      category: category ?? this.category,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
      moderators: moderators ?? this.moderators,
      isPrivate: isPrivate ?? this.isPrivate,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      isPinned: isPinned ?? this.isPinned,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      rules: rules ?? this.rules,
      bannedUsers: bannedUsers ?? this.bannedUsers,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      allowedUsers: allowedUsers ?? this.allowedUsers,
      password: password ?? this.password,
      accessLevel: accessLevel ?? this.accessLevel,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      duration: duration ?? this.duration,
      hasMedia: hasMedia ?? this.hasMedia,
      isVerified: isVerified ?? this.isVerified,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      attachments: attachments ?? this.attachments,
      settings: settings ?? this.settings,
      statistics: statistics ?? this.statistics,
      events: events ?? this.events,
      customIcon: customIcon ?? this.customIcon,
      hasPendingInvite: hasPendingInvite ?? this.hasPendingInvite, // НОВОЕ СВОЙСТВО
    );
  }

  // Геттеры
  bool get isOwner => creatorId == 'current_user_id'; // TODO: Заменить на реальную проверку
  bool get isModerator => moderators.contains('current_user_id');
  bool get isFull => currentParticipants >= maxParticipants;
  bool get isScheduled => scheduledStart != null;
  bool get canJoin => isActive && !isFull && !bannedUsers.contains('current_user_id');
  bool get requiresPassword => accessLevel == RoomAccessLevel.protected && password.isNotEmpty;
  bool get isExpired => isScheduled && scheduledStart!.isBefore(DateTime.now());
  double get participationRate => maxParticipants > 0 ? currentParticipants / maxParticipants : 0;
  bool get isPopular => currentParticipants > 50 || rating > 4.0;
  bool get hasAvailableSpots => currentParticipants < maxParticipants;
  int get availableSpots => maxParticipants - currentParticipants;
  bool get isNew => DateTime.now().difference(createdAt).inDays < 7;
  bool get isTrending => viewCount > 1000 || favoriteCount > 100;
  bool get isHighlyRated => rating >= 4.5 && ratingCount >= 10;
  bool get hasUpcomingEvents => events.any((event) => event.isUpcoming);
  bool get hasActiveEvents => events.any((event) => event.isActive);
  bool get hasVoiceChat => settings.enableVoiceChat;
  bool get hasVideoChat => settings.enableVideoChat;
  bool get hasScreenSharing => settings.enableScreenSharing;
  bool get hasPolls => settings.enablePolls;
  bool get hasReactions => settings.enableReactions;

  // НОВЫЕ ГЕТТЕРЫ
  bool get hasNewInvites => hasPendingInvite;
  bool get hasUnreadMessages => messageCount > 0; // Примерная логика
  bool get isFeatured => isVerified || isTrending || isHighlyRated;

  String get status {
    if (!isActive) return 'Неактивна';
    if (isExpired) return 'Завершена';
    if (isScheduled) return 'Запланирована';
    if (isFull) return 'Заполнена';
    if (hasActiveEvents) return 'Событие активно';
    return 'Активна';
  }

  // Методы проверки прав
  bool canEdit(String userId) => userId == creatorId || moderators.contains(userId);
  bool canDelete(String userId) => userId == creatorId;
  bool canBan(String userId) => userId == creatorId || moderators.contains(userId);
  bool canPin(String userId) => userId == creatorId || moderators.contains(userId);
  bool canManage(String userId) => canEdit(userId) || isModerator;
  bool canModerate(String userId) => canManage(userId);
  bool canInvite(String userId) => isActive && (canManage(userId) || settings.allowUserInvites);

  // Методы для работы со временем
  Duration? get timeUntilStart {
    if (!isScheduled) return null;
    return scheduledStart!.difference(DateTime.now());
  }

  String get formattedStartTime {
    if (!isScheduled) return '';
    final timeUntil = timeUntilStart;
    if (timeUntil == null || timeUntil.isNegative) return 'Началась';

    if (timeUntil.inDays > 0) return 'Через ${timeUntil.inDays} д';
    if (timeUntil.inHours > 0) return 'Через ${timeUntil.inHours} ч';
    return 'Через ${timeUntil.inMinutes} мин';
  }

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inHours < 1) return '${difference.inMinutes}м назад';
    if (difference.inDays < 1) return '${difference.inHours}ч назад';
    if (difference.inDays < 7) return '${difference.inDays}д назад';

    return '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}';
  }

  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inHours < 1) return '${difference.inMinutes}м назад';
    if (difference.inDays < 1) return '${difference.inHours}ч назад';

    return '${lastActivity.hour.toString().padLeft(2, '0')}:${lastActivity.minute.toString().padLeft(2, '0')}';
  }

  // Метод для проверки доступа
  bool hasAccess(String userId, {String? inputPassword}) {
    if (!isActive) return false;
    if (bannedUsers.contains(userId)) return false;

    switch (accessLevel) {
      case RoomAccessLevel.public:
        return true;
      case RoomAccessLevel.private:
        return allowedUsers.contains(userId) || userId == creatorId || moderators.contains(userId);
      case RoomAccessLevel.protected:
        if (inputPassword == null) return false;
        return inputPassword == password;
      case RoomAccessLevel.scheduled:
        return !isExpired;
      case RoomAccessLevel.ageRestricted:
        return true; // TODO: Добавить проверку возраста
      case RoomAccessLevel.geoRestricted:
        return true; // TODO: Добавить проверку геолокации
    }
  }

  // Метод для форматирования информации
  Map<String, dynamic> toBriefInfo() {
    return {
      'title': title,
      'category': category.title,
      'currentParticipants': currentParticipants,
      'maxParticipants': maxParticipants,
      'isActive': isActive,
      'rating': rating,
      'ratingCount': ratingCount,
      'status': status,
      'hasMedia': hasMedia,
      'isVerified': isVerified,
      'language': language,
      'hasVoiceChat': hasVoiceChat,
      'hasVideoChat': hasVideoChat,
      'hasPendingInvite': hasPendingInvite, // НОВОЕ ПОЛЕ
    };
  }

  // Работа с тегами
  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  Room addTag(String tag) {
    final lowerTag = tag.toLowerCase();
    if (!tags.contains(lowerTag)) {
      final newTags = List<String>.from(tags)..add(lowerTag);
      return copyWith(tags: newTags);
    }
    return this;
  }

  Room removeTag(String tag) {
    final newTags = List<String>.from(tags)..remove(tag.toLowerCase());
    return copyWith(tags: newTags);
  }

  List<String> get popularTags => tags.take(3).toList();

  // Поиск и фильтрация
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.contains(lowerQuery)) ||
        creatorName.toLowerCase().contains(lowerQuery) ||
        category.title.toLowerCase().contains(lowerQuery);
  }

  bool matchesCategory(RoomCategory category) {
    if (category == RoomCategory.all) return true;
    return this.category == category;
  }

  bool matchesLanguage(String language) {
    if (language.isEmpty) return true;
    return this.language == language;
  }

  // Валидация комнаты
  bool get isValid {
    return title.isNotEmpty &&
        title.length >= 3 &&
        title.length <= 100 &&
        description.isNotEmpty &&
        description.length >= 10 &&
        description.length <= 500 &&
        currentParticipants >= 0 &&
        messageCount >= 0 &&
        maxParticipants > 0 &&
        maxParticipants <= 1000 &&
        rating >= 0 &&
        rating <= 5 &&
        currentParticipants <= maxParticipants;
  }

  // Получение цвета статуса
  Color get statusColor {
    switch (status) {
      case 'Активна':
        return Colors.green;
      case 'Запланирована':
        return Colors.blue;
      case 'Заполнена':
        return Colors.orange;
      case 'Завершена':
        return Colors.grey;
      case 'Неактивна':
        return Colors.red;
      case 'Событие активно':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Форматирование длительности
  String get formattedDuration {
    if (duration == null) return 'Без ограничения';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    if (hours > 0) return '$hours ч ${minutes > 0 ? '$minutes мин' : ''}';
    return '$minutes мин';
  }

  // Рейтинг в виде звездочек
  Widget buildRatingStars({double size = 16, bool showCount = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() ? Icons.star_rounded :
            (index < rating.ceil() ? Icons.star_half_rounded : Icons.star_border_rounded),
            color: Colors.amber,
            size: size,
          );
        }),
        if (showCount && ratingCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '(${ratingCount.formatCount()})',
            style: TextStyle(
              fontSize: size * 0.7,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  // Индикатор заполненности
  Widget buildCapacityIndicator({double height = 6, double width = 100}) {
    final percentage = participationRate;
    Color color;

    if (percentage < 0.5) color = Colors.green;
    else if (percentage < 0.8) color = Colors.orange;
    else color = Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$currentParticipants/$maxParticipants',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Бейджи для комнаты
  List<Widget> buildBadges({bool showAll = false}) {
    final badges = <Widget>[];

    if (isVerified) {
      badges.add(_buildBadge('Проверено', Icons.verified_rounded, Colors.blue));
    }
    if (isPinned) {
      badges.add(_buildBadge('Закреплено', Icons.push_pin_rounded, Colors.orange));
    }
    if (hasMedia) {
      badges.add(_buildBadge('Медиа', Icons.photo_library_rounded, Colors.purple));
    }
    if (isNew) {
      badges.add(_buildBadge('Новое', Icons.new_releases_rounded, Colors.green));
    }
    if (isTrending) {
      badges.add(_buildBadge('В тренде', Icons.trending_up_rounded, Colors.red));
    }
    if (hasVoiceChat) {
      badges.add(_buildBadge('Голосовой чат', Icons.mic_rounded, Colors.teal));
    }
    if (hasVideoChat && showAll) {
      badges.add(_buildBadge('Видеочат', Icons.videocam_rounded, Colors.indigo));
    }
    if (isScheduled && showAll) {
      badges.add(_buildBadge('Запланирована', Icons.schedule_rounded, Colors.blue));
    }
    if (hasPendingInvite) {
      badges.add(_buildBadge('Приглашение', Icons.mark_email_unread_rounded, Colors.pink));
    }

    return badges;
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Метод для получения иконки комнаты
  Widget getRoomIcon({double size = 40, Color? color}) {
    if (customIcon != null) {
      // TODO: Загрузить кастомную иконку
      return Icon(Icons.room_preferences_rounded, size: size, color: color);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withOpacity(0.8),
            category.color.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        category.icon,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  // Метод для получения цвета комнаты
  Color get roomColor => category.color;

  // Метод для получения уровня активности
  double get activityLevel {
    final messageRate = messageCount / (currentParticipants > 0 ? currentParticipants : 1);
    final timeSinceLastActivity = DateTime.now().difference(lastActivity).inMinutes;

    double activity = 0.0;

    // Учитываем количество сообщений
    if (messageRate > 10) activity += 0.4;
    else if (messageRate > 5) activity += 0.3;
    else if (messageRate > 2) activity += 0.2;
    else activity += 0.1;

    // Учитываем время последней активности
    if (timeSinceLastActivity < 5) activity += 0.4;
    else if (timeSinceLastActivity < 30) activity += 0.3;
    else if (timeSinceLastActivity < 60) activity += 0.2;
    else activity += 0.1;

    // Учитываем количество участников
    if (participationRate > 0.8) activity += 0.2;
    else if (participationRate > 0.5) activity += 0.15;
    else if (participationRate > 0.2) activity += 0.1;

    return activity.clamp(0.0, 1.0);
  }

  String get activityLevelText {
    final level = activityLevel;
    if (level > 0.7) return 'Очень высокая';
    if (level > 0.5) return 'Высокая';
    if (level > 0.3) return 'Средняя';
    return 'Низкая';
  }

  // НОВЫЙ МЕТОД: Получение информации о комнате для отображения
  Map<String, dynamic> get displayInfo {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.title,
      'participants': '$currentParticipants/$maxParticipants',
      'rating': rating,
      'status': status,
      'isJoined': isJoined,
      'isVerified': isVerified,
      'hasPendingInvite': hasPendingInvite,
      'activityLevel': activityLevelText,
      'lastActivity': formattedLastActivity,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Room &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Room{id: $id, title: $title, participants: $currentParticipants/$maxParticipants, category: ${category.title}, rating: $rating, status: $status}';
  }
}

// Новые классы для расширенной функциональности
class RoomSettings {
  final bool enableVoiceChat;
  final bool enableVideoChat;
  final bool enableScreenSharing;
  final bool enablePolls;
  final bool enableReactions;
  final bool allowUserInvites;
  final bool allowFileSharing;
  final int maxFileSize;
  final List<String> allowedFileTypes;
  final bool requireApproval;
  final bool enableModeration;
  final bool enableRecording;
  final int messageCooldown;

  const RoomSettings({
    this.enableVoiceChat = false,
    this.enableVideoChat = false,
    this.enableScreenSharing = false,
    this.enablePolls = true,
    this.enableReactions = true,
    this.allowUserInvites = true,
    this.allowFileSharing = true,
    this.maxFileSize = 10, // MB
    this.allowedFileTypes = const ['jpg', 'png', 'pdf', 'doc', 'mp3', 'mp4'],
    this.requireApproval = false,
    this.enableModeration = true,
    this.enableRecording = false,
    this.messageCooldown = 0, // seconds
  });

  RoomSettings copyWith({
    bool? enableVoiceChat,
    bool? enableVideoChat,
    bool? enableScreenSharing,
    bool? enablePolls,
    bool? enableReactions,
    bool? allowUserInvites,
    bool? allowFileSharing,
    int? maxFileSize,
    List<String>? allowedFileTypes,
    bool? requireApproval,
    bool? enableModeration,
    bool? enableRecording,
    int? messageCooldown,
  }) {
    return RoomSettings(
      enableVoiceChat: enableVoiceChat ?? this.enableVoiceChat,
      enableVideoChat: enableVideoChat ?? this.enableVideoChat,
      enableScreenSharing: enableScreenSharing ?? this.enableScreenSharing,
      enablePolls: enablePolls ?? this.enablePolls,
      enableReactions: enableReactions ?? this.enableReactions,
      allowUserInvites: allowUserInvites ?? this.allowUserInvites,
      allowFileSharing: allowFileSharing ?? this.allowFileSharing,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      requireApproval: requireApproval ?? this.requireApproval,
      enableModeration: enableModeration ?? this.enableModeration,
      enableRecording: enableRecording ?? this.enableRecording,
      messageCooldown: messageCooldown ?? this.messageCooldown,
    );
  }
}

class RoomStatistics {
  final int totalMessages;
  final int totalUsers;
  final int peakParticipants;
  final double averageSessionDuration;
  final int reportsCount;
  final int moderationActions;
  final Map<String, int> userActivity;

  const RoomStatistics({
    this.totalMessages = 0,
    this.totalUsers = 0,
    this.peakParticipants = 0,
    this.averageSessionDuration = 0,
    this.reportsCount = 0,
    this.moderationActions = 0,
    this.userActivity = const {},
  });

  RoomStatistics copyWith({
    int? totalMessages,
    int? totalUsers,
    int? peakParticipants,
    double? averageSessionDuration,
    int? reportsCount,
    int? moderationActions,
    Map<String, int>? userActivity,
  }) {
    return RoomStatistics(
      totalMessages: totalMessages ?? this.totalMessages,
      totalUsers: totalUsers ?? this.totalUsers,
      peakParticipants: peakParticipants ?? this.peakParticipants,
      averageSessionDuration: averageSessionDuration ?? this.averageSessionDuration,
      reportsCount: reportsCount ?? this.reportsCount,
      moderationActions: moderationActions ?? this.moderationActions,
      userActivity: userActivity ?? this.userActivity,
    );
  }
}

class RoomAttachment {
  final String id;
  final String type; // image, video, audio, document, link
  final String url;
  final String title;
  final String? description;
  final int size;
  final DateTime uploadedAt;
  final String uploadedBy;

  const RoomAttachment({
    required this.id,
    required this.type,
    required this.url,
    required this.title,
    this.description,
    this.size = 0,
    required this.uploadedAt,
    required this.uploadedBy,
  });
}

class RoomEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // meeting, webinar, workshop, party
  final List<String> speakers;
  final bool isRecurring;

  const RoomEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.speakers = const [],
    this.isRecurring = false,
  });

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isActive => startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());
  bool get isFinished => endTime.isBefore(DateTime.now());
}

// Обновленные enum'ы
enum RoomCategory {
  all('Все', Icons.all_inclusive_rounded, Colors.blue, 'Все категории'),
  technology('Технологии', Icons.smartphone_rounded, Colors.blue, 'Обсуждения технологий и гаджетов'),
  business('Бизнес', Icons.business_center_rounded, Colors.orange, 'Бизнес и предпринимательство'),
  games('Игры', Icons.sports_esports_rounded, Colors.purple, 'Видеоигры и киберспорт'),
  programming('Программирование', Icons.code_rounded, Colors.teal, 'Разработка и IT'),
  sports('Спорт', Icons.sports_soccer_rounded, Colors.green, 'Спорт и активный отдых'),
  psychology('Психология', Icons.psychology_rounded, Colors.pink, 'Психология и саморазвитие'),
  arts('Искусство', Icons.palette_rounded, Colors.amber, 'Творчество и искусство'),
  music('Музыка', Icons.music_note_rounded, Colors.deepPurple, 'Музыка и аудио'),
  science('Наука', Icons.science_rounded, Colors.indigo, 'Научные дискуссии'),
  education('Образование', Icons.school_rounded, Colors.brown, 'Обучение и курсы'),
  health('Здоровье', Icons.favorite_rounded, Colors.red, 'Медицина и здоровый образ жизни'),
  travel('Путешествия', Icons.travel_explore_rounded, Colors.lightBlue, 'Туризм и приключения'),
  food('Еда', Icons.restaurant_rounded, Colors.deepOrange, 'Кулинария и рецепты'),
  fashion('Мода', Icons.style_rounded, Colors.pinkAccent, 'Стиль и мода'),
  entertainment('Развлечения', Icons.movie_rounded, Colors.redAccent, 'Фильмы и сериалы'),
  news('Новости', Icons.newspaper_rounded, Colors.blueGrey, 'Актуальные новости'),
  politics('Политика', Icons.policy_rounded, Colors.deepPurple, 'Политические обсуждения'),
  books('Книги', Icons.menu_book_rounded, Colors.brown, 'Литература и книги'),
  crypto('Криптовалюты', Icons.currency_bitcoin_rounded, Colors.orange, 'Крипто и блокчейн'),
  social('Социальное', Icons.people_alt_rounded, Colors.cyan, 'Социальные взаимодействия');

  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const RoomCategory(this.title, this.icon, this.color, this.description);
}

enum RoomAccessLevel {
  public('Публичная', Icons.public_rounded, Colors.green, 'Доступна всем пользователям'),
  private('Приватная', Icons.lock_rounded, Colors.orange, 'Только по приглашению'),
  protected('Защищенная', Icons.security_rounded, Colors.blue, 'С паролем'),
  scheduled('Запланированная', Icons.schedule_rounded, Colors.purple, 'Назначена на время'),
  ageRestricted('18+', Icons.eighteen_up_rating_rounded, Colors.red, 'Только для взрослых'),
  geoRestricted('Гео-ограничение', Icons.public_off_rounded, Colors.grey, 'Ограничена по региону');

  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const RoomAccessLevel(this.title, this.icon, this.color, this.description);
}

enum RoomSortBy {
  recent('Недавние', Icons.access_time_rounded, 'По дате последней активности'),
  popular('Популярные', Icons.trending_up_rounded, 'По популярности и просмотрам'),
  participants('Участники', Icons.people_rounded, 'По количеству участников'),
  messages('Сообщения', Icons.chat_rounded, 'По количеству сообщений'),
  rating('Рейтинг', Icons.star_rounded, 'По рейтингу пользователей'),
  scheduled('Запланированные', Icons.schedule_rounded, 'По времени начала'),
  activity('Активность', Icons.flash_on_rounded, 'По уровню активности'),
  newest('Сначала новые', Icons.new_releases_rounded, 'По дате создания');

  final String title;
  final IconData icon;
  final String description;

  const RoomSortBy(this.title, this.icon, this.description);
}

// Расширение для форматирования чисел
extension NumberFormatting on int {
  String formatCount() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

// Утилиты для работы с комнатами
class RoomUtils {
  static List<Room> filterRooms(List<Room> rooms, String query, RoomCategory category, String language) {
    return rooms.where((room) {
      final matchesQuery = query.isEmpty || room.matchesQuery(query);
      final matchesCategory = room.matchesCategory(category);
      final matchesLanguage = room.matchesLanguage(language);
      return matchesQuery && matchesCategory && matchesLanguage;
    }).toList();
  }

  static List<Room> sortRooms(List<Room> rooms, RoomSortBy sortBy) {
    final sortedRooms = List<Room>.from(rooms);

    switch (sortBy) {
      case RoomSortBy.recent:
        sortedRooms.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
        break;
      case RoomSortBy.popular:
        sortedRooms.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case RoomSortBy.participants:
        sortedRooms.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
        break;
      case RoomSortBy.messages:
        sortedRooms.sort((a, b) => b.messageCount.compareTo(a.messageCount));
        break;
      case RoomSortBy.rating:
        sortedRooms.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case RoomSortBy.scheduled:
        sortedRooms.sort((a, b) {
          final aStart = a.scheduledStart ?? DateTime(2100);
          final bStart = b.scheduledStart ?? DateTime(2100);
          return aStart.compareTo(bStart);
        });
        break;
      case RoomSortBy.activity:
        sortedRooms.sort((a, b) => b.activityLevel.compareTo(a.activityLevel));
        break;
      case RoomSortBy.newest:
        sortedRooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sortedRooms;
  }

  static RoomCategory getCategoryFromString(String categoryName) {
    return RoomCategory.values.firstWhere(
          (category) => category.title == categoryName,
      orElse: () => RoomCategory.all,
    );
  }

  static List<Room> getFeaturedRooms(List<Room> rooms) {
    return rooms.where((room) => room.isVerified || room.isTrending || room.isHighlyRated).toList();
  }

  static List<Room> getRecommendedRooms(List<Room> rooms, List<String> userInterests) {
    return rooms.where((room) {
      final commonTags = room.tags.where((tag) => userInterests.contains(tag));
      return commonTags.isNotEmpty || userInterests.contains(room.category.title.toLowerCase());
    }).toList();
  }

  static List<Room> getActiveRooms(List<Room> rooms) {
    return rooms.where((room) => room.isActive && !room.isExpired).toList();
  }

  static List<Room> getRoomsWithEvents(List<Room> rooms) {
    return rooms.where((room) => room.events.isNotEmpty).toList();
  }

  static List<Room> getRoomsWithInvites(List<Room> rooms) {
    return rooms.where((room) => room.hasPendingInvite).toList();
  }

  static Map<RoomCategory, int> getCategoryStats(List<Room> rooms) {
    final stats = <RoomCategory, int>{};
    for (final category in RoomCategory.values) {
      if (category != RoomCategory.all) {
        stats[category] = rooms.where((room) => room.category == category).length;
      }
    }
    return stats;
  }

  // НОВЫЙ МЕТОД: Получение статистики по приглашениям
  static int getTotalInvites(List<Room> rooms) {
    return rooms.where((room) => room.hasPendingInvite).length;
  }

  // НОВЫЙ МЕТОД: Получение комнат с высокой активностью
  static List<Room> getHighlyActiveRooms(List<Room> rooms, {double minActivityLevel = 0.7}) {
    return rooms.where((room) => room.activityLevel >= minActivityLevel).toList();
  }
}