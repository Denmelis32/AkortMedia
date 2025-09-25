import 'package:flutter/material.dart';

class Room {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int participants;
  final int messages;
  final bool isJoined;
  final DateTime createdAt;
  final DateTime lastActivity;
  final RoomCategory category;
  final String creatorId;
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
  final List<String> allowedUsers;
  final String password;
  final RoomAccessLevel accessLevel;
  final DateTime? scheduledStart;
  final Duration? duration;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.messages,
    required this.isJoined,
    required this.createdAt,
    required this.lastActivity,
    required this.category,
    required this.creatorId,
    this.moderators = const [],
    this.isPrivate = false,
    this.tags = const [],
    this.isPinned = false,
    this.maxParticipants = 100,
    this.rules = '',
    this.bannedUsers = const [],
    this.isActive = true,
    this.rating = 0.0,
    this.allowedUsers = const [],
    this.password = '',
    this.accessLevel = RoomAccessLevel.public,
    this.scheduledStart,
    this.duration,
  });

  Room copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? participants,
    int? messages,
    bool? isJoined,
    DateTime? createdAt,
    DateTime? lastActivity,
    RoomCategory? category,
    String? creatorId,
    List<String>? moderators,
    bool? isPrivate,
    List<String>? tags,
    bool? isPinned,
    int? maxParticipants,
    String? rules,
    List<String>? bannedUsers,
    bool? isActive,
    double? rating,
    List<String>? allowedUsers,
    String? password,
    RoomAccessLevel? accessLevel,
    DateTime? scheduledStart,
    Duration? duration,
  }) {
    return Room(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      category: category ?? this.category,
      creatorId: creatorId ?? this.creatorId,
      moderators: moderators ?? this.moderators,
      isPrivate: isPrivate ?? this.isPrivate,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      rules: rules ?? this.rules,
      bannedUsers: bannedUsers ?? this.bannedUsers,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      allowedUsers: allowedUsers ?? this.allowedUsers,
      password: password ?? this.password,
      accessLevel: accessLevel ?? this.accessLevel,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      duration: duration ?? this.duration,
    );
  }

  // Геттеры
  bool get isOwner => creatorId == 'current_user_id'; // TODO: Заменить на реальную проверку
  bool get isModerator => moderators.contains('current_user_id');
  bool get isFull => participants >= maxParticipants;
  bool get isScheduled => scheduledStart != null;
  bool get canJoin => isActive && !isFull && !bannedUsers.contains('current_user_id');
  bool get requiresPassword => accessLevel == RoomAccessLevel.protected && password.isNotEmpty;
  bool get isExpired => isScheduled && scheduledStart!.isBefore(DateTime.now());
  double get participationRate => maxParticipants > 0 ? participants / maxParticipants : 0;
  bool get isPopular => participants > 50 || rating > 4.0;

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
      'participants': participants,
      'isActive': isActive,
      'rating': rating,
      'status': status,
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
        tags.any((tag) => tag.contains(lowerQuery));
  }

  bool matchesCategory(RoomCategory category) {
    if (category == RoomCategory.all) return true;
    return this.category == category;
  }

  // Валидация комнаты
  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        participants >= 0 &&
        messages >= 0 &&
        maxParticipants > 0 &&
        rating >= 0 &&
        rating <= 5;
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
    return 'Room{id: $id, title: $title, participants: $participants, category: ${category.title}, status: $status}';
  }
}

enum RoomCategory {
  all('Все', Icons.all_inclusive, Colors.blue, 'Все категории'),
  tech('Технологии', Icons.smartphone, Colors.blue, 'Обсуждения технологий и гаджетов'),
  business('Бизнес', Icons.business, Colors.orange, 'Бизнес и предпринимательство'),
  games('Игры', Icons.sports_esports, Colors.purple, 'Видеоигры и киберспорт'),
  programming('Программирование', Icons.code, Colors.teal, 'Разработка и IT'),
  sport('Спорт', Icons.sports_soccer, Colors.green, 'Спорт и активный отдых'),
  psychology('Психология', Icons.psychology, Colors.pink, 'Психология и саморазвитие'),
  art('Искусство', Icons.palette, Colors.amber, 'Творчество и искусство'),
  music('Музыка', Icons.music_note, Colors.deepPurple, 'Музыка и аудио'),
  science('Наука', Icons.science, Colors.indigo, 'Научные дискуссии'),
  education('Образование', Icons.school, Colors.brown, 'Обучение и курсы');

  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const RoomCategory(this.title, this.icon, this.color, this.description);
}

enum RoomAccessLevel {
  public('Публичная', Icons.public, Colors.green),
  private('Приватная', Icons.lock, Colors.orange),
  protected('Защищенная', Icons.security, Colors.blue),
  scheduled('Запланированная', Icons.schedule, Colors.purple);

  final String title;
  final IconData icon;
  final Color color;

  const RoomAccessLevel(this.title, this.icon, this.color);
}

enum RoomSortBy {
  recent('Недавние', Icons.access_time),
  popular('Популярные', Icons.trending_up),
  participants('Участники', Icons.people),
  messages('Сообщения', Icons.chat),
  rating('Рейтинг', Icons.star),
  scheduled('Запланированные', Icons.schedule);

  final String title;
  final IconData icon;

  const RoomSortBy(this.title, this.icon);
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
        return rooms..sort((a, b) => b.participants.compareTo(a.participants));
      case RoomSortBy.participants:
        return rooms..sort((a, b) => b.participants.compareTo(a.participants));
      case RoomSortBy.messages:
        return rooms..sort((a, b) => b.messages.compareTo(a.messages));
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
}