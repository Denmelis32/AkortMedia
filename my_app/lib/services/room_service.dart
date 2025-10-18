import 'package:flutter/foundation.dart';
import '../pages/rooms_pages/models/room.dart';
import '../pages/rooms_pages/models/room_category.dart';

class RoomService {
  Future<List<Room>> getRooms() async {
    // Имитация загрузки из API
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();

    return [
      Room(
        id: '1',
        title: 'Маринцев и его Друзья',
        description: 'Обсуждаем Наськин День Рождения',
        imageUrl: 'assets/images/ava_news/ava29.png',
        currentParticipants: 12450,
        messageCount: 89456,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 2)),
        lastActivity: now.subtract(const Duration(minutes: 5)),
        category: RoomCategory.youtube, // ИСПРАВЛЕНО: tech → technology
        creatorId: 'user1',
        creatorName: 'Маринцев',
        creatorAvatarUrl: 'assets/images/ava_news/ava29.png', // НОВОЕ ПОЛЕ
        moderators: ['user2', 'user3'],
        isPrivate: false,
        tags: ['НаськинДень', 'День Рождения'],
        language: 'ru', // НОВОЕ ПОЛЕ
        isPinned: true,
        maxParticipants: 15000,
        rules: 'Будьте вежливы, делитесь знаниями',
        bannedUsers: [],
        isActive: true,
        rating: 4.8,
        ratingCount: 245,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: true,
        isVerified: true,
        viewCount: 125000,
        favoriteCount: 4500,
      ),
      Room(
        id: '2',
        title: 'Flutter Development',
        description: 'Сообщество разработчиков Flutter. Помощь, обмен опытом, лучшие практики',
        imageUrl: 'assets/images/ava_news/ava28.png',
        currentParticipants: 8734,
        messageCount: 45678,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 15)),
        lastActivity: now.subtract(const Duration(hours: 2)),
        category: RoomCategory.programming,
        creatorId: 'user4',
        creatorName: 'Мария Разработчик',
        creatorAvatarUrl: 'assets/images/ava_news/ava28.png', // НОВОЕ ПОЛЕ
        moderators: ['user5'],
        isPrivate: false,
        tags: ['flutter', 'dart', 'mobile', 'development', 'программирование'],
        language: 'ru', // НОВОЕ ПОЛЕ
        isPinned: false,
        maxParticipants: 10000,
        rules: 'Помогайте новичкам, делитесь кодом',
        bannedUsers: ['spam_user'],
        isActive: true,
        rating: 4.9,
        ratingCount: 189,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: true,
        isVerified: true,
        viewCount: 89000,
        favoriteCount: 3200,
      ),
      Room(
        id: '3',
        title: 'Бизнес и Стартапы',
        description: 'Обсуждение бизнес-идей, инвестиций и развития стартапов',
        imageUrl: 'assets/images/ava_news/ava27.png',
        currentParticipants: 5432,
        messageCount: 23456,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 30)),
        lastActivity: now.subtract(const Duration(days: 1)),
        category: RoomCategory.business,
        creatorId: 'user6',
        creatorName: 'Дмитрий Бизнесмен',
        creatorAvatarUrl: 'assets/images/ava_news/ava27.png',// НОВОЕ ПОЛЕ
        moderators: ['user7', 'user8'],
        isPrivate: true,
        tags: ['бизнес', 'стартапы', 'инвестиции', 'предпринимательство'],
        language: 'ru', // НОВОЕ ПОЛЕ
        isPinned: false,
        maxParticipants: 5000,
        rules: 'Конфиденциальность, только деловые обсуждения',
        bannedUsers: [],
        isActive: true,
        rating: 4.7,
        ratingCount: 156,
        allowedUsers: ['user1', 'user2', 'user3'],
        password: '',
        accessLevel: RoomAccessLevel.private,
        hasMedia: false,
        isVerified: false,
        viewCount: 45000,
        favoriteCount: 1200,
      ),
      Room(
        id: '4',
        title: 'Игровая индустрия',
        description: 'Новости игр, разработка, геймдизайн и киберспорт и много-много всего обсуждаем',
        imageUrl: 'assets/images/ava_news/ava26.png',
        currentParticipants: 15678,
        messageCount: 67890,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 10)),
        lastActivity: now.subtract(const Duration(minutes: 30)),
        category: RoomCategory.games,
        creatorId: 'user9',
        creatorName: 'Иван Геймер',
        creatorAvatarUrl: 'assets/images/ava_news/ava26.png',// НОВОЕ ПОЛЕ
        moderators: ['user10'],
        isPrivate: false,
        tags: ['игры', 'геймдев', 'киберспорт', 'streaming'],
        language: 'ru', // НОВОЕ ПОЛЕ
        isPinned: true,
        maxParticipants: 20000,
        rules: 'Уважайте мнение других, никакого токсичного поведения',
        bannedUsers: ['toxic_user1', 'toxic_user2'],
        isActive: true,
        rating: 4.6,
        ratingCount: 278,
        allowedUsers: [],
        password: 'gaming2024',
        accessLevel: RoomAccessLevel.protected,
        hasMedia: true,
        isVerified: true,
        viewCount: 167000,
        favoriteCount: 5600,
      ),
    ];
  }

  Future<Room> createRoom({
    required String title,
    required String description,
    required RoomCategory category,
    bool isPrivate = false,
    List<String> tags = const [],
    String language = 'ru',
    int maxParticipants = 100,
    String rules = '',
    RoomAccessLevel accessLevel = RoomAccessLevel.public,
    String password = '',
    DateTime? scheduledStart,
    Duration? duration,
    bool hasMedia = false,
    bool enableVoiceChat = false,
    bool enableVideoChat = false,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();

    return Room(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      imageUrl: _getDefaultImageForCategory(category),
      currentParticipants: 1,
      messageCount: 0,
      isJoined: true,
      createdAt: now,
      lastActivity: now,
      category: category,
      creatorId: 'current_user',
      creatorName: 'Текущий Пользователь',
      creatorAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', // НОВОЕ ПОЛЕ
      moderators: [],
      isPrivate: isPrivate,
      tags: tags,
      language: language, // НОВОЕ ПОЛЕ
      isPinned: false,
      maxParticipants: maxParticipants,
      rules: rules,
      bannedUsers: [],
      isActive: true,
      rating: 0.0,
      ratingCount: 0,
      allowedUsers: [],
      password: password,
      accessLevel: accessLevel,
      scheduledStart: scheduledStart,
      duration: duration,
      hasMedia: hasMedia,
      isVerified: false,
      viewCount: 0,
      favoriteCount: 0,
    );
  }

  Future<void> updateRoom(Room room) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Имитация обновления на сервере
    if (kDebugMode) {
      print('Room updated: ${room.title}');
    }
  }

  String _getDefaultImageForCategory(RoomCategory category) {
    switch (category.id) {
      case 'technology':
        return 'https://avatars.mds.yandex.net/i?id=1e90171b7d4bc14b07b66f1f6757ff2f_l-9837529-images-thumbs&n=13';
      case 'programming':
        return 'https://avatars.mds.yandex.net/i?id=32c0a73c0990f1f127a8f440607ad510f6650260-4559382-images-thumbs&n=13';
      case 'business':
        return 'https://avatars.mds.yandex.net/i?id=dda503b4fa8209f9669720bbe1d3b708_l-10251881-images-thumbs&n=13';
      case 'games':
        return 'https://avatars.mds.yandex.net/i?id=1d8887bee2ca66b5d364c0c930a7ae4f_l-5115383-images-thumbs&n=13';
      case 'sport':
        return 'https://i.pinimg.com/736x/fe/90/2a/fe902a418aeeac098af585df9d84b67f.jpg';
      case 'youtube':
        return 'https://avatars.mds.yandex.net/i?id=a3c059dfd766f0b77cb583919bc5c0c8_l-5245909-images-thumbs&n=13';
      case 'communication':
        return 'https://avatars.mds.yandex.net/i?id=af750c649d6cf46534419eb162e883c7500e26bc-4828405-images-thumbs&n=13';
      default:
        return 'https://avatars.mds.yandex.net/i?id=2154efb7672c374c3a7d819f4f4590e55315e1d1-4316446-images-thumbs&n=13';
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


  // Методы для работы с рейтингами
  Future<double> rateRoom(String roomId, double rating) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return rating;
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
        room.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())) ||
        room.creatorName.toLowerCase().contains(query.toLowerCase())
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
      'ratingDistribution': [5, 15, 30, 40, 10],
      'growthRate': '+12.5%',
      'activityLevel': 0.75, // НОВАЯ СТАТИСТИКА
      'hasPendingInvite': false, // НОВАЯ СТАТИСТИКА
    };
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С ИЗБРАННЫМ
  Future<void> addToFavorites(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> removeFromFavorites(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<List<Room>> getFavoriteRooms() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allRooms = await getRooms();
    return allRooms.where((room) => room.isJoined).take(3).toList();
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ АНАЛИТИКИ
  Future<void> trackRoomView(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<Map<String, dynamic>> getUserRoomStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return {
      'roomsCreated': 5,
      'roomsJoined': 12,
      'totalMessages': 456,
      'averageRating': 4.3,
      'favoriteCategories': ['Технологии', 'Программирование'],
      'hasNewInvites': true, // НОВАЯ СТАТИСТИКА
    };
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С ПРИГЛАШЕНИЯМИ
  Future<void> sendRoomInvite(String roomId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> acceptRoomInvite(String inviteId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> declineRoomInvite(String inviteId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<List<Room>> getRoomInvites() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final allRooms = await getRooms();
    // Возвращаем приватные комнаты как пример приглашений
    return allRooms.where((room) => room.isPrivate).take(2).toList();
  }
}