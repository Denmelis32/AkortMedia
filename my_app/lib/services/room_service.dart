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
        currentParticipants: 12450, // ОБНОВЛЕНО
        messageCount: 89456, // ОБНОВЛЕНО
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 2)),
        lastActivity: now.subtract(const Duration(minutes: 5)),
        category: RoomCategory.tech,
        creatorId: 'user1',
        creatorName: 'Алексей Технов', // НОВОЕ ПОЛЕ
        moderators: ['user2', 'user3'],
        isPrivate: false,
        tags: ['технологии', 'инновации', 'IT', 'будущее'],
        isPinned: true,
        maxParticipants: 15000,
        rules: 'Будьте вежливы, делитесь знаниями',
        bannedUsers: [],
        isActive: true,
        rating: 4.8,
        ratingCount: 245, // НОВОЕ ПОЛЕ
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: true, // НОВОЕ ПОЛЕ
        isVerified: true, // НОВОЕ ПОЛЕ
        viewCount: 125000, // НОВОЕ ПОЛЕ
        favoriteCount: 4500, // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '2',
        title: 'Flutter Development',
        description: 'Сообщество разработчиков Flutter. Помощь, обмен опытом, лучшие практики',
        imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400',
        currentParticipants: 8734, // ОБНОВЛЕНО
        messageCount: 45678, // ОБНОВЛЕНО
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 15)),
        lastActivity: now.subtract(const Duration(hours: 2)),
        category: RoomCategory.programming,
        creatorId: 'user4',
        creatorName: 'Мария Разработчик', // НОВОЕ ПОЛЕ
        moderators: ['user5'],
        isPrivate: false,
        tags: ['flutter', 'dart', 'mobile', 'development', 'программирование'],
        isPinned: false,
        maxParticipants: 10000,
        rules: 'Помогайте новичкам, делитесь кодом',
        bannedUsers: ['spam_user'],
        isActive: true,
        rating: 4.9,
        ratingCount: 189, // НОВОЕ ПОЛЕ
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: true, // НОВОЕ ПОЛЕ
        isVerified: true, // НОВОЕ ПОЛЕ
        viewCount: 89000, // НОВОЕ ПОЛЕ
        favoriteCount: 3200, // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '3',
        title: 'Бизнес и Стартапы',
        description: 'Обсуждение бизнес-идей, инвестиций и развития стартапов',
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
        currentParticipants: 5432, // ОБНОВЛЕНО
        messageCount: 23456, // ОБНОВЛЕНО
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 30)),
        lastActivity: now.subtract(const Duration(days: 1)),
        category: RoomCategory.business,
        creatorId: 'user6',
        creatorName: 'Дмитрий Бизнесмен', // НОВОЕ ПОЛЕ
        moderators: ['user7', 'user8'],
        isPrivate: true,
        tags: ['бизнес', 'стартапы', 'инвестиции', 'предпринимательство'],
        isPinned: false,
        maxParticipants: 5000,
        rules: 'Конфиденциальность, только деловые обсуждения',
        bannedUsers: [],
        isActive: true,
        rating: 4.7,
        ratingCount: 156, // НОВОЕ ПОЛЕ
        allowedUsers: ['user1', 'user2', 'user3'],
        password: '',
        accessLevel: RoomAccessLevel.private,
        hasMedia: false, // НОВОЕ ПОЛЕ
        isVerified: false, // НОВОЕ ПОЛЕ
        viewCount: 45000, // НОВОЕ ПОЛЕ
        favoriteCount: 1200, // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '4',
        title: 'Игровая индустрия',
        description: 'Новости игр, разработка, геймдизайн и киберспорт',
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400',
        currentParticipants: 15678, // ОБНОВЛЕНО
        messageCount: 67890, // ОБНОВЛЕНО
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 10)),
        lastActivity: now.subtract(const Duration(minutes: 30)),
        category: RoomCategory.games,
        creatorId: 'user9',
        creatorName: 'Иван Геймер', // НОВОЕ ПОЛЕ
        moderators: ['user10'],
        isPrivate: false,
        tags: ['игры', 'геймдев', 'киберспорт', 'streaming'],
        isPinned: true,
        maxParticipants: 20000,
        rules: 'Уважайте мнение других, никакого токсичного поведения',
        bannedUsers: ['toxic_user1', 'toxic_user2'],
        isActive: true,
        rating: 4.6,
        ratingCount: 278, // НОВОЕ ПОЛЕ
        allowedUsers: [],
        password: 'gaming2024',
        accessLevel: RoomAccessLevel.protected,
        hasMedia: true, // НОВОЕ ПОЛЕ
        isVerified: true, // НОВОЕ ПОЛЕ
        viewCount: 167000, // НОВОЕ ПОЛЕ
        favoriteCount: 5600, // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '5',
        title: 'Спорт и Здоровье',
        description: 'Тренировки, питание, здоровый образ жизни',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        currentParticipants: 8765, // ОБНОВЛЕНО
        messageCount: 34567, // ОБНОВЛЕНО
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 5)),
        lastActivity: now.subtract(const Duration(hours: 5)),
        category: RoomCategory.sport,
        creatorId: 'user11',
        creatorName: 'Анна Фитнес', // НОВОЕ ПОЛЕ
        moderators: ['user12'],
        isPrivate: false,
        tags: ['спорт', 'здоровье', 'тренировки', 'питание'],
        isPinned: false,
        maxParticipants: 10000,
        rules: 'Делитесь опытом, поддерживайте друг друга',
        bannedUsers: [],
        isActive: true,
        rating: 4.8,
        ratingCount: 198, // НОВОЕ ПОЛЕ
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        scheduledStart: now.add(const Duration(days: 1)),
        duration: const Duration(hours: 2),
        hasMedia: true, // НОВОЕ ПОЛЕ
        isVerified: false, // НОВОЕ ПОЛЕ
        viewCount: 78000, // НОВОЕ ПОЛЕ
        favoriteCount: 2300, // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '6',
        title: 'Психология общения',
        description: 'Развитие коммуникативных навыков и эмоционального интеллекта',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
        currentParticipants: 4321, // ОБНОВЛЕНО
        messageCount: 12345, // ОБНОВЛЕНО
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 20)),
        lastActivity: now.subtract(const Duration(days: 3)),
        category: RoomCategory.psychology,
        creatorId: 'user13',
        creatorName: 'София Психолог', // НОВОЕ ПОЛЕ
        moderators: ['user14'],
        isPrivate: false,
        tags: ['психология', 'общение', 'развитие', 'отношения'],
        isPinned: false,
        maxParticipants: 5000,
        rules: 'Конфиденциальность, уважение к участникам',
        bannedUsers: [],
        isActive: false,
        rating: 4.5,
        ratingCount: 87, // НОВОЕ ПОЛЕ
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: false, // НОВОЕ ПОЛЕ
        isVerified: true, // НОВОЕ ПОЛЕ
        viewCount: 34000, // НОВОЕ ПОЛЕ
        favoriteCount: 890, // НОВОЕ ПОЛЕ
      ),
      // НОВЫЕ КОМНАТЫ С ДОПОЛНИТЕЛЬНЫМИ КАТЕГОРИЯМИ
      Room(
        id: '7',
        title: 'Искусство и Творчество',
        description: 'Обсуждение современного искусства, выставок и творческих проектов',
        imageUrl: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400',
        currentParticipants: 2345,
        messageCount: 9876,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 8)),
        lastActivity: now.subtract(const Duration(hours: 3)),
        category: RoomCategory.art,
        creatorId: 'user15',
        creatorName: 'Екатерина Художник',
        moderators: ['user16'],
        isPrivate: false,
        tags: ['искусство', 'творчество', 'живопись', 'дизайн'],
        isPinned: false,
        maxParticipants: 3000,
        rules: 'Делитесь своими работами, конструктивная критика',
        bannedUsers: [],
        isActive: true,
        rating: 4.4,
        ratingCount: 76,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: true,
        isVerified: false,
        viewCount: 21000,
        favoriteCount: 650,
      ),
      Room(
        id: '8',
        title: 'Путешествия по миру',
        description: 'Советы путешественникам, интересные места и маршруты',
        imageUrl: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400',
        currentParticipants: 5678,
        messageCount: 23456,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 12)),
        lastActivity: now.subtract(const Duration(hours: 1)),
        category: RoomCategory.travel,
        creatorId: 'user17',
        creatorName: 'Максим Путешественник',
        moderators: ['user18'],
        isPrivate: false,
        tags: ['путешествия', 'туризм', 'отдых', 'адвенча'],
        isPinned: false,
        maxParticipants: 8000,
        rules: 'Делитесь реальным опытом, полезные советы',
        bannedUsers: [],
        isActive: true,
        rating: 4.7,
        ratingCount: 143,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: true,
        isVerified: true,
        viewCount: 67000,
        favoriteCount: 2100,
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
      currentParticipants: 1, // ОБНОВЛЕНО
      messageCount: 0, // ОБНОВЛЕНО
      isJoined: true,
      createdAt: now,
      lastActivity: now,
      category: category,
      creatorId: 'current_user',
      creatorName: 'Текущий Пользователь', // НОВОЕ ПОЛЕ
      moderators: [],
      isPrivate: isPrivate,
      tags: tags,
      isPinned: false,
      maxParticipants: maxParticipants,
      rules: rules,
      bannedUsers: [],
      isActive: true,
      rating: 0.0,
      ratingCount: 0, // НОВОЕ ПОЛЕ
      allowedUsers: [],
      password: password,
      accessLevel: accessLevel,
      scheduledStart: scheduledStart,
      duration: duration,
      hasMedia: false, // НОВОЕ ПОЛЕ
      isVerified: false, // НОВОЕ ПОЛЕ
      viewCount: 0, // НОВОЕ ПОЛЕ
      favoriteCount: 0, // НОВОЕ ПОЛЕ
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
      case RoomCategory.health:
        return 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=400';
      case RoomCategory.travel:
        return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400';
      case RoomCategory.food:
        return 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400';
      case RoomCategory.fashion:
        return 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400';
      default:
        return 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400';
    }
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
        room.creatorName.toLowerCase().contains(query.toLowerCase()) // НОВЫЙ ПОИСК
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
      'ratingDistribution': [5, 15, 30, 40, 10], // НОВАЯ СТАТИСТИКА
      'growthRate': '+12.5%', // НОВАЯ СТАТИСТИКА
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
    };
  }
}