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
        currentParticipants: 12450,
        messageCount: 89456,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 2)),
        lastActivity: now.subtract(const Duration(minutes: 5)),
        category: RoomCategory.technology, // ИСПРАВЛЕНО: tech → technology
        creatorId: 'user1',
        creatorName: 'Алексей Технов',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', // НОВОЕ ПОЛЕ
        moderators: ['user2', 'user3'],
        isPrivate: false,
        tags: ['технологии', 'инновации', 'IT', 'будущее'],
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
        attachments: [], // НОВОЕ ПОЛЕ
        settings: const RoomSettings(enableVoiceChat: true), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 89456, totalUsers: 15600), // НОВОЕ ПОЛЕ
        events: [], // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '2',
        title: 'Flutter Development',
        description: 'Сообщество разработчиков Flutter. Помощь, обмен опытом, лучшие практики',
        imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400',
        currentParticipants: 8734,
        messageCount: 45678,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 15)),
        lastActivity: now.subtract(const Duration(hours: 2)),
        category: RoomCategory.programming,
        creatorId: 'user4',
        creatorName: 'Мария Разработчик',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100', // НОВОЕ ПОЛЕ
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
        attachments: [], // НОВОЕ ПОЛЕ
        settings: const RoomSettings(enablePolls: true, enableReactions: true), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 45678, totalUsers: 9200), // НОВОЕ ПОЛЕ
        events: [], // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '3',
        title: 'Бизнес и Стартапы',
        description: 'Обсуждение бизнес-идей, инвестиций и развития стартапов',
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
        currentParticipants: 5432,
        messageCount: 23456,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 30)),
        lastActivity: now.subtract(const Duration(days: 1)),
        category: RoomCategory.business,
        creatorId: 'user6',
        creatorName: 'Дмитрий Бизнесмен',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', // НОВОЕ ПОЛЕ
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
        attachments: [], // НОВОЕ ПОЛЕ
        settings: const RoomSettings(), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 23456, totalUsers: 5800), // НОВОЕ ПОЛЕ
        events: [], // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '4',
        title: 'Игровая индустрия',
        description: 'Новости игр, разработка, геймдизайн и киберспорт',
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400',
        currentParticipants: 15678,
        messageCount: 67890,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 10)),
        lastActivity: now.subtract(const Duration(minutes: 30)),
        category: RoomCategory.games,
        creatorId: 'user9',
        creatorName: 'Иван Геймер',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=100', // НОВОЕ ПОЛЕ
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
        attachments: [], // НОВОЕ ПОЛЕ
        settings: const RoomSettings(enableVoiceChat: true, enableVideoChat: true), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 67890, totalUsers: 18200), // НОВОЕ ПОЛЕ
        events: [], // НОВОЕ ПОЛЕ
      ),
      Room(
        id: '5',
        title: 'Спорт и Здоровье',
        description: 'Тренировки, питание, здоровый образ жизни',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        currentParticipants: 8765,
        messageCount: 34567,
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 5)),
        lastActivity: now.subtract(const Duration(hours: 5)),
        category: RoomCategory.sports, // ИСПРАВЛЕНО: sport → sports
        creatorId: 'user11',
        creatorName: 'Анна Фитнес',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', // НОВОЕ ПОЛЕ
        moderators: ['user12'],
        isPrivate: false,
        tags: ['спорт', 'здоровье', 'тренировки', 'питание'],
        language: 'ru', // НОВОЕ ПОЛЕ
        isPinned: false,
        maxParticipants: 10000,
        rules: 'Делитесь опытом, поддерживайте друг друга',
        bannedUsers: [],
        isActive: true,
        rating: 4.8,
        ratingCount: 198,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        scheduledStart: now.add(const Duration(days: 1)),
        duration: const Duration(hours: 2),
        hasMedia: true,
        isVerified: false,
        viewCount: 78000,
        favoriteCount: 2300,
        attachments: [], // НОВОЕ ПОЛЕ
        settings: const RoomSettings(), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 34567, totalUsers: 9100), // НОВОЕ ПОЛЕ
        events: [ // НОВОЕ ПОЛЕ
          RoomEvent(
            id: 'event1',
            title: 'Онлайн тренировка',
            description: 'Групповая тренировка с профессиональным тренером',
            startTime: now.add(const Duration(days: 1)),
            endTime: now.add(const Duration(days: 1, hours: 2)),
            type: 'workshop',
            speakers: ['user11'],
          ),
        ],
      ),
      Room(
        id: '6',
        title: 'Психология общения',
        description: 'Развитие коммуникативных навыков и эмоционального интеллекта',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
        currentParticipants: 4321,
        messageCount: 12345,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 20)),
        lastActivity: now.subtract(const Duration(days: 3)),
        category: RoomCategory.psychology,
        creatorId: 'user13',
        creatorName: 'София Психолог',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=100', // НОВОЕ ПОЛЕ
        moderators: ['user14'],
        isPrivate: false,
        tags: ['психология', 'общение', 'развитие', 'отношения'],
        language: 'ru', // НОВОЕ ПОЛЕ
        isPinned: false,
        maxParticipants: 5000,
        rules: 'Конфиденциальность, уважение к участникам',
        bannedUsers: [],
        isActive: false,
        rating: 4.5,
        ratingCount: 87,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: false,
        isVerified: true,
        viewCount: 34000,
        favoriteCount: 890,
        attachments: [], // НОВОЕ ПОЛЕ
        settings: const RoomSettings(), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 12345, totalUsers: 4700), // НОВОЕ ПОЛЕ
        events: [], // НОВОЕ ПОЛЕ
      ),
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
        category: RoomCategory.arts, // ИСПРАВЛЕНО: art → arts
        creatorId: 'user15',
        creatorName: 'Екатерина Художник',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100', // НОВОЕ ПОЛЕ
        moderators: ['user16'],
        isPrivate: false,
        tags: ['искусство', 'творчество', 'живопись', 'дизайн'],
        language: 'ru', // НОВОЕ ПОЛЕ
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
        attachments: [], // НОВОЕ ПОЛЕ
        settings: const RoomSettings(enablePolls: true), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 9876, totalUsers: 2500), // НОВОЕ ПОЛЕ
        events: [], // НОВОЕ ПОЛЕ
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
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', // НОВОЕ ПОЛЕ
        moderators: ['user18'],
        isPrivate: false,
        tags: ['путешествия', 'туризм', 'отдых', 'адвенча'],
        language: 'ru', // НОВОЕ ПОЛЕ
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
        attachments: [ // НОВОЕ ПОЛЕ
          RoomAttachment(
            id: 'att1',
            type: 'image',
            url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
            title: 'Горный пейзаж',
            uploadedAt: now.subtract(const Duration(days: 5)),
            uploadedBy: 'user17',
          ),
        ],
        settings: const RoomSettings(allowFileSharing: true), // НОВОЕ ПОЛЕ
        statistics: const RoomStatistics(totalMessages: 23456, totalUsers: 6200), // НОВОЕ ПОЛЕ
        events: [], // НОВОЕ ПОЛЕ
      ),
      // НОВАЯ КОМНАТА С КАТЕГОРИЕЙ SOCIAL
      Room(
        id: '9',
        title: 'Социальные взаимодействия',
        description: 'Общение, знакомства, социальные проекты и волонтерство',
        imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
        currentParticipants: 3456,
        messageCount: 15678,
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 3)),
        lastActivity: now.subtract(const Duration(minutes: 15)),
        category: RoomCategory.social, // НОВАЯ КАТЕГОРИЯ
        creatorId: 'user19',
        creatorName: 'Ольга Социолог',
        creatorAvatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
        moderators: ['user20'],
        isPrivate: false,
        tags: ['общение', 'знакомства', 'волонтерство', 'социальные проекты'],
        language: 'ru',
        isPinned: false,
        maxParticipants: 5000,
        rules: 'Уважительное общение, поддержка друг друга',
        bannedUsers: [],
        isActive: true,
        rating: 4.3,
        ratingCount: 98,
        allowedUsers: [],
        password: '',
        accessLevel: RoomAccessLevel.public,
        hasMedia: false,
        isVerified: false,
        viewCount: 28000,
        favoriteCount: 780,
        attachments: [],
        settings: const RoomSettings(enablePolls: true, enableReactions: true),
        statistics: const RoomStatistics(totalMessages: 15678, totalUsers: 3800),
        events: [
          RoomEvent(
            id: 'event2',
            title: 'Волонтерская встреча',
            description: 'Планирование социальных проектов на месяц',
            startTime: now.add(const Duration(days: 3)),
            endTime: now.add(const Duration(days: 3, hours: 3)),
            type: 'meeting',
            speakers: ['user19', 'user20'],
          ),
        ],
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
      attachments: [], // НОВОЕ ПОЛЕ
      settings: RoomSettings( // НОВОЕ ПОЛЕ
        enableVoiceChat: enableVoiceChat,
        enableVideoChat: enableVideoChat,
        enablePolls: true,
        enableReactions: true,
        allowUserInvites: true,
        allowFileSharing: true,
      ),
      statistics: const RoomStatistics(), // НОВОЕ ПОЛЕ
      events: [], // НОВОЕ ПОЛЕ
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
      case RoomCategory.technology:
        return 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400';
      case RoomCategory.programming:
        return 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400';
      case RoomCategory.business:
        return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400';
      case RoomCategory.games:
        return 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400';
      case RoomCategory.sports:
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400';
      case RoomCategory.psychology:
        return 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400';
      case RoomCategory.arts:
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
      case RoomCategory.social: // НОВАЯ КАТЕГОРИЯ
        return 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400';
      case RoomCategory.entertainment:
        return 'https://images.unsplash.com/photo-1489599804159-4f3d1b7b4dac?w=400';
      case RoomCategory.news:
        return 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=400';
      case RoomCategory.politics:
        return 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?w=400';
      case RoomCategory.books:
        return 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400';
      case RoomCategory.crypto:
        return 'https://images.unsplash.com/photo-1516245834210-8e0b8b46fc28?w=400';
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