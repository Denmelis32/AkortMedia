// models/room.dart
import 'package:flutter/material.dart';
import 'room_category.dart';

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
  final String? customIcon;
  final bool hasPendingInvite;
  final String? communityId;

  // НОВОЕ ПОЛЕ: Тип доступа к комнате
  final RoomAccessType accessType;

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
    this.customIcon,
    this.hasPendingInvite = false,
    this.communityId,
    required this.accessType, // НОВЫЙ ОБЯЗАТЕЛЬНЫЙ ПАРАМЕТР
  });

  // Геттер для совместимости
  bool get hasCommunity => communityId != null && communityId!.isNotEmpty;

  // Обновленный метод copyWith
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
    String? customIcon,
    bool? hasPendingInvite,
    String? communityId,
    RoomAccessType? accessType, // НОВЫЙ ПАРАМЕТР
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
      customIcon: customIcon ?? this.customIcon,
      hasPendingInvite: hasPendingInvite ?? this.hasPendingInvite,
      communityId: communityId ?? this.communityId,
      accessType: accessType ?? this.accessType, // НОВАЯ СТРОКА
    );
  }

  // НОВЫЕ ГЕТТЕРЫ ДЛЯ ТИПОВ ДОСТУПА
  bool get isPublic => accessType == RoomAccessType.public;
  bool get isPrivateRoom => accessType == RoomAccessType.private;
  bool get isPasswordProtected => accessType == RoomAccessType.password;
  bool get isInviteOnly => accessType == RoomAccessType.private;

  // Геттер для отображения типа комнаты
  String get accessTypeDisplay {
    switch (accessType) {
      case RoomAccessType.public:
        return 'Публичная';
      case RoomAccessType.private:
        return 'Закрытая';
      case RoomAccessType.password:
        return 'С паролем';
    }
  }

  // Цвет для типа доступа
  Color get accessTypeColor {
    switch (accessType) {
      case RoomAccessType.public:
        return Colors.green;
      case RoomAccessType.private:
        return Colors.orange;
      case RoomAccessType.password:
        return Colors.blue;
    }
  }

  // Иконка для типа доступа
  IconData get accessTypeIcon {
    switch (accessType) {
      case RoomAccessType.public:
        return Icons.public;
      case RoomAccessType.private:
        return Icons.lock;
      case RoomAccessType.password:
        return Icons.password;
    }
  }

  // Обновленный метод проверки доступа
  bool hasAccess(String userId, {String? inputPassword, bool? isInvited}) {
    if (!isActive) return false;
    if (bannedUsers.contains(userId)) return false;

    switch (accessType) {
      case RoomAccessType.public:
        return true;
      case RoomAccessType.private:
        return allowedUsers.contains(userId) ||
            userId == creatorId ||
            moderators.contains(userId) ||
            (isInvited == true);
      case RoomAccessType.password:
        if (inputPassword == null) return false;
        return inputPassword == password;
    }
  }

  // Метод для получения требований к доступу
  String get accessRequirements {
    switch (accessType) {
      case RoomAccessType.public:
        return 'Открыта для всех';
      case RoomAccessType.private:
        return 'Только по приглашению';
      case RoomAccessType.password:
        return 'Требуется пароль';
    }
  }

  // Обновленный метод для информации о сообществе
  Map<String, dynamic>? get communityInfo {
    if (!hasCommunity) return null;
    return {
      'id': communityId,
      'name': 'Сообщество $title',
      'memberCount': currentParticipants,
      'roomCount': 1,
      'accessType': accessTypeDisplay,
    };
  }

  // Остальные геттеры и методы остаются без изменений, но обновлены для работы с accessType
  bool get isOwner => creatorId == 'current_user_id';
  bool get isModerator => moderators.contains('current_user_id');
  bool get isFull => currentParticipants >= maxParticipants;
  bool get isScheduled => scheduledStart != null;
  bool get canJoin => isActive && !isFull && !bannedUsers.contains('current_user_id');
  bool get requiresPassword => accessType == RoomAccessType.password && password.isNotEmpty;
  bool get isExpired => isScheduled && scheduledStart!.isBefore(DateTime.now());
  double get participationRate => maxParticipants > 0 ? currentParticipants / maxParticipants : 0;
  bool get isPopular => currentParticipants > 50 || rating > 4.0;
  bool get hasAvailableSpots => currentParticipants < maxParticipants;
  int get availableSpots => maxParticipants - currentParticipants;
  bool get isNew => DateTime.now().difference(createdAt).inDays < 7;
  bool get isTrending => viewCount > 1000 || favoriteCount > 100;
  bool get isHighlyRated => rating >= 4.5 && ratingCount >= 10;

  // Обновленные геттеры
  bool get hasNewInvites => hasPendingInvite;
  bool get hasUnreadMessages => messageCount > 0;

  String get status {
    if (!isActive) return 'Неактивна';
    if (isExpired) return 'Завершена';
    if (isScheduled) return 'Запланирована';
    if (isFull) return 'Заполнена';
    return 'Активна';
  }

  // Методы проверки прав (без изменений)
  bool canEdit(String userId) => userId == creatorId || moderators.contains(userId);
  bool canDelete(String userId) => userId == creatorId;
  bool canBan(String userId) => userId == creatorId || moderators.contains(userId);
  bool canPin(String userId) => userId == creatorId || moderators.contains(userId);
  bool canManage(String userId) => canEdit(userId) || isModerator;
  bool canModerate(String userId) => canManage(userId);

  // Методы для работы со временем (без изменений)
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

  // Обновленный метод для форматирования информации
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
      'hasPendingInvite': hasPendingInvite,
      'accessType': accessTypeDisplay, // НОВОЕ ПОЛЕ
      'isPublic': isPublic,
      'isPrivate': isPrivateRoom,
      'requiresPassword': requiresPassword,
    };
  }

  // Работа с тегами (без изменений)
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

  // Поиск и фильтрация (без изменений)
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
    if (category.id == 'all') return true;
    return this.category.id == category.id;
  }

  bool matchesLanguage(String language) {
    if (language.isEmpty) return true;
    return this.language == language;
  }

  // НОВЫЙ МЕТОД: Фильтрация по типу доступа
  bool matchesAccessType(RoomAccessType? filterAccessType) {
    if (filterAccessType == null) return true;
    return accessType == filterAccessType;
  }

  // Валидация комнаты (обновлена)
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
        currentParticipants <= maxParticipants &&
        // НОВАЯ ВАЛИДАЦИЯ ДЛЯ ПАРОЛЯ
        (accessType != RoomAccessType.password || password.isNotEmpty) &&
        // ВАЛИДАЦИЯ ДЛЯ ПРИВАТНЫХ КОМНАТ
        (accessType != RoomAccessType.private || allowedUsers.isNotEmpty || moderators.isNotEmpty);
  }

  // Получение цвета статуса (без изменений)
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

  // Форматирование длительности (без изменений)
  String get formattedDuration {
    if (duration == null) return 'Без ограничения';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    if (hours > 0) return '$hours ч ${minutes > 0 ? '$minutes мин' : ''}';
    return '$minutes мин';
  }

  // Рейтинг в виде звездочек (без изменений)
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

  // Индикатор заполненности (без изменений)
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

  // Обновленные бейджи для комнаты
  List<Widget> buildBadges({bool showAll = false}) {
    final badges = <Widget>[];

    // Бейдж типа доступа (всегда показываем)
    badges.add(_buildAccessTypeBadge());

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
    if (isScheduled && showAll) {
      badges.add(_buildBadge('Запланирована', Icons.schedule_rounded, Colors.blue));
    }
    if (hasPendingInvite) {
      badges.add(_buildBadge('Приглашение', Icons.mark_email_unread_rounded, Colors.pink));
    }
    return badges;
  }

  // НОВЫЙ МЕТОД: Бейдж типа доступа
  Widget _buildAccessTypeBadge() {
    return _buildBadge(accessTypeDisplay, accessTypeIcon, accessTypeColor);
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

  // Метод для получения иконки комнаты (без изменений)
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

  // Метод для получения цвета комнаты (без изменений)
  Color get roomColor => category.color;

  // Метод для получения уровня активности (без изменений)
  double get activityLevel {
    final messageRate = messageCount / (currentParticipants > 0 ? currentParticipants : 1);
    final timeSinceLastActivity = DateTime.now().difference(lastActivity).inMinutes;

    double activity = 0.0;

    if (messageRate > 10) activity += 0.4;
    else if (messageRate > 5) activity += 0.3;
    else if (messageRate > 2) activity += 0.2;
    else activity += 0.1;

    if (timeSinceLastActivity < 5) activity += 0.4;
    else if (timeSinceLastActivity < 30) activity += 0.3;
    else if (timeSinceLastActivity < 60) activity += 0.2;
    else activity += 0.1;

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

  // Обновленный метод: Получение информации о комнате для отображения
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
      'accessType': accessTypeDisplay, // НОВОЕ ПОЛЕ
      'accessRequirements': accessRequirements,
      'isPublic': isPublic,
      'isPrivate': isPrivateRoom,
      'requiresPassword': requiresPassword,
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
    return 'Room{id: $id, title: $title, participants: $currentParticipants/$maxParticipants, category: ${category.title}, accessType: $accessType, rating: $rating, status: $status}';
  }
}

// НОВЫЙ ENUM: Типы доступа к комнате
enum RoomAccessType {
  public,
  private,
  password,
}

// Обновленный RoomAccessLevel для совместимости
class RoomAccessLevel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final RoomAccessType accessType; // НОВОЕ ПОЛЕ ДЛЯ СОВМЕСТИМОСТИ

  const RoomAccessLevel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.accessType,
  });

  static const RoomAccessLevel public = RoomAccessLevel(
    id: 'public',
    title: 'Публичная',
    icon: Icons.public,
    color: Colors.green,
    description: 'Доступна всем пользователям',
    accessType: RoomAccessType.public,
  );

  static const RoomAccessLevel private = RoomAccessLevel(
    id: 'private',
    title: 'Приватная',
    icon: Icons.lock,
    color: Colors.orange,
    description: 'Только по приглашению',
    accessType: RoomAccessType.private,
  );

  static const RoomAccessLevel protected = RoomAccessLevel(
    id: 'protected',
    title: 'Защищенная',
    icon: Icons.security,
    color: Colors.blue,
    description: 'С паролем',
    accessType: RoomAccessType.password,
  );

  static List<RoomAccessLevel> get allLevels => [public, private, protected];

  // Метод для конвертации из RoomAccessType
  static RoomAccessLevel fromAccessType(RoomAccessType accessType) {
    switch (accessType) {
      case RoomAccessType.public:
        return public;
      case RoomAccessType.private:
        return private;
      case RoomAccessType.password:
        return protected;
    }
  }
}

// RoomSortBy остается без изменений
class RoomSortBy {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  const RoomSortBy({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });

  static const RoomSortBy newest = RoomSortBy(
    id: 'newest',
    title: 'Сначала новые',
    icon: Icons.new_releases,
    description: 'По дате создания',
  );

  static const RoomSortBy popular = RoomSortBy(
    id: 'popular',
    title: 'Популярные',
    icon: Icons.trending_up,
    description: 'По популярности и просмотрам',
  );

  static const RoomSortBy participants = RoomSortBy(
    id: 'participants',
    title: 'Участники',
    icon: Icons.people,
    description: 'По количеству участников',
  );

  // НОВЫЙ ВАРИАНТ: Сортировка по типу доступа
  static const RoomAccessType accessType = RoomAccessType.public;

  static List<RoomSortBy> get allSortOptions => [newest, popular, participants];
}

// Расширение для форматирования чисел (без изменений)
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

// НОВОЕ РАСШИРЕНИЕ: Утилиты для работы с RoomAccessType
extension RoomAccessTypeExtension on RoomAccessType {
  String get displayName {
    switch (this) {
      case RoomAccessType.public:
        return 'Публичная';
      case RoomAccessType.private:
        return 'Закрытая';
      case RoomAccessType.password:
        return 'С паролем';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomAccessType.public:
        return Icons.public;
      case RoomAccessType.private:
        return Icons.lock;
      case RoomAccessType.password:
        return Icons.password;
    }
  }

  Color get color {
    switch (this) {
      case RoomAccessType.public:
        return Colors.green;
      case RoomAccessType.private:
        return Colors.orange;
      case RoomAccessType.password:
        return Colors.blue;
    }
  }

  String get description {
    switch (this) {
      case RoomAccessType.public:
        return 'Видна всем пользователям';
      case RoomAccessType.private:
        return 'Только по приглашению';
      case RoomAccessType.password:
        return 'Доступ по паролю';
    }
  }


}