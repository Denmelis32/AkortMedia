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
  final List<String> moderators;
  final bool isPrivate;
  final List<String> tags;

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
    this.moderators = const [],
    this.isPrivate = false,
    this.tags = const [],
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
    List<String>? moderators,
    bool? isPrivate,
    List<String>? tags,
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
      moderators: moderators ?? this.moderators,
      isPrivate: isPrivate ?? this.isPrivate,
      tags: tags ?? this.tags,
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

  String get status {
    if (!isActive) return 'Неактивна';
    if (isExpired) return 'Завершена';
    if (isScheduled) return 'Запланирована';
    if (isFull) return 'Заполнена';
    return 'Активна';
  }

  // Методы проверки прав
  bool canEdit(String userId) => userId == creatorId || moderators.contains(userId);
  bool canDelete(String userId) => userId == creatorId;
  bool canBan(String userId) => userId == creatorId || moderators.contains(userId);
  bool canPin(String userId) => userId == creatorId || moderators.contains(userId);
  bool canManage(String userId) => canEdit(userId) || isModerator;

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

    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }

  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inHours < 1) return '${difference.inMinutes}м назад';
    if (difference.inDays < 1) return '${difference.inHours}ч назад';

    return '${lastActivity.hour}:${lastActivity.minute.toString().padLeft(2, '0')}';
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
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.contains(lowerQuery)) ||
        creatorName.toLowerCase().contains(lowerQuery);
  }

  bool matchesCategory(RoomCategory category) {
    if (category == RoomCategory.all) return true;
    return this.category == category;
  }

  // Валидация комнаты
  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        currentParticipants >= 0 &&
        messageCount >= 0 &&
        maxParticipants > 0 &&
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
  Widget buildRatingStars({double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  // Индикатор заполненности
  Widget buildCapacityIndicator({double height = 4}) {
    final percentage = participationRate;
    Color color;

    if (percentage < 0.5) color = Colors.green;
    else if (percentage < 0.8) color = Colors.orange;
    else color = Colors.red;

    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        FractionallySizedBox(
          widthFactor: percentage,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  // Бейджи для комнаты
  List<Widget> buildBadges() {
    final badges = <Widget>[];

    if (isVerified) {
      badges.add(_buildBadge('Проверено', Icons.verified, Colors.blue));
    }
    if (isPinned) {
      badges.add(_buildBadge('Закреплено', Icons.push_pin, Colors.orange));
    }
    if (hasMedia) {
      badges.add(_buildBadge('Медиа', Icons.photo_library, Colors.purple));
    }
    if (isNew) {
      badges.add(_buildBadge('Новое', Icons.new_releases, Colors.green));
    }
    if (isTrending) {
      badges.add(_buildBadge('В тренде', Icons.trending_up, Colors.red));
    }

    return badges;
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
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

enum RoomCategory {
  all('Все', Icons.all_inclusive, Colors.blue, 'Все категории'),
  tech('Технологии', Icons.smartphone, Colors.blue, 'Обсуждения технологий и гаджетов'),
  business('Бизнес', Icons.business_center, Colors.orange, 'Бизнес и предпринимательство'),
  games('Игры', Icons.sports_esports, Colors.purple, 'Видеоигры и киберспорт'),
  programming('Программирование', Icons.code, Colors.teal, 'Разработка и IT'),
  sport('Спорт', Icons.sports_soccer, Colors.green, 'Спорт и активный отдых'),
  psychology('Психология', Icons.psychology, Colors.pink, 'Психология и саморазвитие'),
  art('Искусство', Icons.palette, Colors.amber, 'Творчество и искусство'),
  music('Музыка', Icons.music_note, Colors.deepPurple, 'Музыка и аудио'),
  science('Наука', Icons.science, Colors.indigo, 'Научные дискуссии'),
  education('Образование', Icons.school, Colors.brown, 'Обучение и курсы'),
  health('Здоровье', Icons.favorite, Colors.red, 'Медицина и здоровый образ жизни'),
  travel('Путешествия', Icons.travel_explore, Colors.lightBlue, 'Туризм и приключения'),
  food('Еда', Icons.restaurant, Colors.deepOrange, 'Кулинария и рецепты'),
  fashion('Мода', Icons.style, Colors.pinkAccent, 'Стиль и мода');

  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const RoomCategory(this.title, this.icon, this.color, this.description);
}

enum RoomAccessLevel {
  public('Публичная', Icons.public, Colors.green, 'Доступна всем пользователям'),
  private('Приватная', Icons.lock, Colors.orange, 'Только по приглашению'),
  protected('Защищенная', Icons.security, Colors.blue, 'С паролем'),
  scheduled('Запланированная', Icons.schedule, Colors.purple, 'Назначена на время');

  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const RoomAccessLevel(this.title, this.icon, this.color, this.description);
}

enum RoomSortBy {
  recent('Недавние', Icons.access_time, 'По дате последней активности'),
  popular('Популярные', Icons.trending_up, 'По популярности и просмотрам'),
  participants('Участники', Icons.people, 'По количеству участников'),
  messages('Сообщения', Icons.chat, 'По количеству сообщений'),
  rating('Рейтинг', Icons.star, 'По рейтингу пользователей'),
  scheduled('Запланированные', Icons.schedule, 'По времени начала');

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
  static List<Room> filterRooms(List<Room> rooms, String query, RoomCategory category) {
    return rooms.where((room) {
      final matchesQuery = query.isEmpty || room.matchesQuery(query);
      final matchesCategory = room.matchesCategory(category);
      return matchesQuery && matchesCategory;
    }).toList();
  }

  static List<Room> sortRooms(List<Room> rooms, RoomSortBy sortBy) {
    switch (sortBy) {
      case RoomSortBy.recent:
        return rooms..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      case RoomSortBy.popular:
        return rooms..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      case RoomSortBy.participants:
        return rooms..sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
      case RoomSortBy.messages:
        return rooms..sort((a, b) => b.messageCount.compareTo(a.messageCount));
      case RoomSortBy.rating:
        return rooms..sort((a, b) => b.rating.compareTo(a.rating));
      case RoomSortBy.scheduled:
        return rooms..sort((a, b) {
          final aStart = a.scheduledStart ?? DateTime(0);
          final bStart = b.scheduledStart ?? DateTime(0);
          return aStart.compareTo(bStart);
        });
    }
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
}