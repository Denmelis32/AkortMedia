import 'package:flutter/foundation.dart';

import '../pages/rooms_pages/models/room.dart';

class RoomService {
  Future<List<Room>> getRooms() async {
    // Имитация загрузки из API
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();

    return [
      Room(
        id: '1',
        title: 'Технологии будущего',
        description: 'Обсуждаем новейшие технологии и инновации в IT-индустрии',
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
        participants: 12450,
        messages: 89456,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 2)),
        lastActivity: now.subtract(const Duration(minutes: 5)),
        category: RoomCategory.tech,
        creatorId: 'user1',
        moderators: ['user2', 'user3'],
        isPrivate: false,
        tags: ['технологии', 'инновации', 'IT'],
        isPinned: true,
        maxParticipants: 15000,
        rules: 'Будьте вежливы, делитесь знаниями',
        bannedUsers: [],
        isActive: true,
        rating: 4.8,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
      ),
      Room(
        id: '2',
        title: 'Flutter Development',
        description: 'Сообщество разработчиков Flutter. Помощь, обмен опытом, лучшие практики',
        imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400',
        participants: 8734,
        messages: 45678,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 15)),
        lastActivity: now.subtract(const Duration(hours: 2)),
        category: RoomCategory.programming,
        creatorId: 'user4',
        moderators: ['user5'],
        isPrivate: false,
        tags: ['flutter', 'dart', 'mobile', 'development'],
        isPinned: false,
        maxParticipants: 10000,
        rules: 'Помогайте новичкам, делитесь кодом',
        bannedUsers: ['spam_user'],
        isActive: true,
        rating: 4.9,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
      ),
      Room(
        id: '3',
        title: 'Бизнес и Стартапы',
        description: 'Обсуждение бизнес-идей, инвестиций и развития стартапов',
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
        participants: 5432,
        messages: 23456,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 30)),
        lastActivity: now.subtract(const Duration(days: 1)),
        category: RoomCategory.business,
        creatorId: 'user6',
        moderators: ['user7', 'user8'],
        isPrivate: true,
        tags: ['бизнес', 'стартапы', 'инвестиции'],
        isPinned: false,
        maxParticipants: 5000,
        rules: 'Конфиденциальность, только деловые обсуждения',
        bannedUsers: [],
        isActive: true,
        rating: 4.7,
        allowedUsers: ['user1', 'user2', 'user3'],
        password: '',
        accessLevel: RoomAccessLevel.private,
      ),
      Room(
        id: '4',
        title: 'Игровая индустрия',
        description: 'Новости игр, разработка, геймдизайн и киберспорт',
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400',
        participants: 15678,
        messages: 67890,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 10)),
        lastActivity: now.subtract(const Duration(minutes: 30)),
        category: RoomCategory.games,
        creatorId: 'user9',
        moderators: ['user10'],
        isPrivate: false,
        tags: ['игры', 'геймдев', 'киберспорт'],
        isPinned: true,
        maxParticipants: 20000,
        rules: 'Уважайте мнение других, никакого токсичного поведения',
        bannedUsers: ['toxic_user1', 'toxic_user2'],
        isActive: true,
        rating: 4.6,
        allowedUsers: [],
        password: 'gaming2024',
        accessLevel: RoomAccessLevel.protected,
      ),
      Room(
        id: '5',
        title: 'Спорт и Здоровье',
        description: 'Тренировки, питание, здоровый образ жизни',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        participants: 8765,
        messages: 34567,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 5)),
        lastActivity: now.subtract(const Duration(hours: 5)),
        category: RoomCategory.sport,
        creatorId: 'user11',
        moderators: ['user12'],
        isPrivate: false,
        tags: ['спорт', 'здоровье', 'тренировки'],
        isPinned: false,
        maxParticipants: 10000,
        rules: 'Делитесь опытом, поддерживайте друг друга',
        bannedUsers: [],
        isActive: true,
        rating: 4.8,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        scheduledStart: now.add(const Duration(days: 1)),
        duration: const Duration(hours: 2),
      ),
      Room(
        id: '6',
        title: 'Психология общения',
        description: 'Развитие коммуникативных навыков и эмоционального интеллекта',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
        participants: 4321,
        messages: 12345,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 20)),
        lastActivity: now.subtract(const Duration(days: 3)),
        category: RoomCategory.psychology,
        creatorId: 'user13',
        moderators: ['user14'],
        isPrivate: false,
        tags: ['психология', 'общение', 'развитие'],
        isPinned: false,
        maxParticipants: 5000,
        rules: 'Конфиденциальность, уважение к участникам',
        bannedUsers: [],
        isActive: false,
        rating: 4.5,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
      ),
    ];
  }

  Future<Room> createRoom({
    required String title,
    required String description,
    required RoomCategory category,
    bool isPrivate = false,
    List<String> tags = const [],
    int maxParticipants = 100,
    String rules = '',
    RoomAccessLevel accessLevel = RoomAccessLevel.public,
    String password = '',
    DateTime? scheduledStart,
    Duration? duration,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();

    return Room(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      imageUrl: _getDefaultImageForCategory(category),
      participants: 1,
      messages: 0,
      isJoined: true,
      createdAt: now,
      lastActivity: now,
      category: category,
      creatorId: 'current_user',
      moderators: [],
      isPrivate: isPrivate,
      tags: tags,
      isPinned: false,
      maxParticipants: maxParticipants,
      rules: rules,
      bannedUsers: [],
      isActive: true,
      rating: 0.0,
      allowedUsers: [],
      password: password,
      accessLevel: accessLevel,
      scheduledStart: scheduledStart,
      duration: duration,
    );
  }

  Future<void> updateRoom(Room room) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Имитация обновления на сервере
    if (kDebugMode) {
      print('Room updated: ${room.title}');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Имитация удаления на сервере
    if (kDebugMode) {
      print('Room deleted: $roomId');
    }
  }

  Future<void> joinRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> leaveRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  String _getDefaultImageForCategory(RoomCategory category) {
    switch (category) {
      case RoomCategory.tech:
        return 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400';
      case RoomCategory.programming:
        return 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400';
      case RoomCategory.business:
        return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400';
      case RoomCategory.games:
        return 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400';
      case RoomCategory.sport:
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400';
      case RoomCategory.psychology:
        return 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400';
      case RoomCategory.art:
        return 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400';
      case RoomCategory.music:
        return 'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=400';
      case RoomCategory.science:
        return 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400';
      case RoomCategory.education:
        return 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400';
      default:
        return 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400';
    }
  }

  // Методы для работы с рейтингами
  Future<double> rateRoom(String roomId, double rating) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return rating; // В реальном приложении здесь будет логика усреднения
  }

  // Методы для модерации
  Future<void> addModerator(String roomId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> removeModerator(String roomId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> banUser(String roomId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> unbanUser(String roomId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Методы для работы с тегами
  Future<void> addTag(String roomId, String tag) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> removeTag(String roomId, String tag) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // Методы для запланированных комнат
  Future<void> scheduleRoom(String roomId, DateTime startTime, Duration duration) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> cancelScheduledRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Поиск комнат
  Future<List<Room>> searchRooms(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final allRooms = await getRooms();
    return allRooms.where((room) =>
    room.title.toLowerCase().contains(query.toLowerCase()) ||
        room.description.toLowerCase().contains(query.toLowerCase()) ||
        room.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // Получение статистики
  Future<Map<String, dynamic>> getRoomStats(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'views': 15000,
      'uniqueVisitors': 4500,
      'avgSessionDuration': '12:34',
      'popularTags': ['flutter', 'dart', 'mobile'],
      'peakActivity': '19:00-21:00',
    };
  }
}