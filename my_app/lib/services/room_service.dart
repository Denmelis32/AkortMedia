import 'package:flutter/foundation.dart';
import '../pages/rooms_pages/models/room.dart';
import '../pages/rooms_pages/models/room_category.dart';

class RoomService {
  // Кэш для хранения комнат
  List<Room>? _cachedRooms;
  final Map<String, Room> _roomCache = {};

  // Получение списка комнат с кэшированием
  Future<List<Room>> getRooms({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedRooms != null) {
      return _cachedRooms!;
    }

    // Имитация загрузки из API
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final rooms = [
      _createRoom(
        id: '1',
        title: 'Роккер Ближник',
        description: 'Обсуждаем ванильные деньки',
        imageUrl: 'assets/images/ava_news/ava29.png',
        currentParticipants: 12450,
        messageCount: 89456,
        category: RoomCategory.youtube,
        creatorName: 'Нонаши Покемонов',
        creatorAvatarUrl: 'https://avatars.mds.yandex.net/i?id=afbd7642e852a1eb5203048042bb5fe0_l-10702804-images-thumbs&n=13',
        tags: ['Ваниль', 'День'],
        isPinned: true,
        maxParticipants: 15000,
        rating: 4.8,
        ratingCount: 245,
        viewCount: 125000,
        favoriteCount: 4500,
        createdAt: now.subtract(const Duration(days: 2)),
        lastActivity: now.subtract(const Duration(minutes: 5)),
      ),
      _createRoom(
        id: '2',
        title: 'Flutter Development',
        description: 'Сообщество разработчиков Flutter',
        imageUrl: 'assets/images/ava_news/ava28.png',
        currentParticipants: 8734,
        messageCount: 45678,
        category: RoomCategory.programming,
        creatorName: 'Мария Разработчик',
        creatorAvatarUrl: 'assets/images/ava_news/ava28.png',
        tags: ['flutter', 'dart', 'mobile'],
        rating: 4.9,
        ratingCount: 189,
        viewCount: 89000,
        favoriteCount: 3200,
        createdAt: now.subtract(const Duration(days: 15)),
        lastActivity: now.subtract(const Duration(hours: 2)),
      ),
      _createRoom(
        id: '3',
        title: 'Бизнес и Стартапы',
        description: 'Обсуждение бизнес-идей и инвестиций',
        imageUrl: 'assets/images/ava_news/ava27.png',
        currentParticipants: 5432,
        messageCount: 23456,
        category: RoomCategory.business,
        creatorName: 'Дмитрий Бизнесмен',
        creatorAvatarUrl: 'assets/images/ava_news/ava27.png',
        tags: ['бизнес', 'стартапы', 'инвестиции'],
        isPrivate: true,
        accessType: RoomAccessType.private,
        rating: 4.7,
        ratingCount: 156,
        viewCount: 45000,
        favoriteCount: 1200,
        createdAt: now.subtract(const Duration(days: 30)),
        lastActivity: now.subtract(const Duration(days: 1)),
      ),
      _createRoom(
        id: '4',
        title: 'Игровая индустрия',
        description: 'Новости игр и разработка',
        imageUrl: 'assets/images/ava_news/ava26.png',
        currentParticipants: 15678,
        messageCount: 67890,
        category: RoomCategory.games,
        creatorName: 'Иван Геймер',
        creatorAvatarUrl: 'assets/images/ava_news/ava26.png',
        tags: ['игры', 'геймдев', 'киберспорт'],
        isPinned: true,
        maxParticipants: 20000,
        accessType: RoomAccessType.password,
        password: 'gaming2024',
        rating: 4.6,
        ratingCount: 278,
        viewCount: 167000,
        favoriteCount: 5600,
        createdAt: now.subtract(const Duration(days: 10)),
        lastActivity: now.subtract(const Duration(minutes: 30)),
      ),
    ];

    _cachedRooms = rooms;
    // Обновляем кэш отдельных комнат
    for (final room in rooms) {
      _roomCache[room.id] = room;
    }

    return rooms;
  }

  // Вспомогательный метод для создания комнат
  Room _createRoom({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required int currentParticipants,
    required int messageCount,
    required RoomCategory category,
    required String creatorName,
    required String? creatorAvatarUrl,
    required List<String> tags,
    DateTime? createdAt,
    DateTime? lastActivity,
    bool isJoined = false,
    bool isPrivate = false,
    bool isPinned = false,
    int maxParticipants = 10000,
    double rating = 0.0,
    int ratingCount = 0,
    int viewCount = 0,
    int favoriteCount = 0,
    RoomAccessType accessType = RoomAccessType.public,
    String password = '',
  }) {
    final now = DateTime.now();
    return Room(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      currentParticipants: currentParticipants,
      messageCount: messageCount,
      isJoined: isJoined,
      createdAt: createdAt ?? now,
      lastActivity: lastActivity ?? now,
      category: category,
      creatorId: 'user_$id',
      creatorName: creatorName,
      creatorAvatarUrl: creatorAvatarUrl,
      moderators: const [],
      isPrivate: isPrivate,
      tags: tags,
      language: 'ru',
      isPinned: isPinned,
      maxParticipants: maxParticipants,
      rules: '',
      bannedUsers: const [],
      isActive: true,
      rating: rating,
      ratingCount: ratingCount,
      allowedUsers: const [],
      password: password,
      accessLevel: RoomAccessLevel.fromAccessType(accessType),
      scheduledStart: null,
      duration: null,
      hasMedia: true,
      isVerified: rating > 4.5,
      viewCount: viewCount,
      favoriteCount: favoriteCount,
      customIcon: null,
      hasPendingInvite: false,
      communityId: null,
      accessType: accessType,
    );
  }

  // Создание новой комнаты
  Future<Room> createRoom({
    required String title,
    required String description,
    required RoomCategory category,
    RoomAccessType accessType = RoomAccessType.public,
    String password = '',
    List<String> tags = const [],
    int maxParticipants = 100,
    DateTime? scheduledStart,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final room = _createRoom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      imageUrl: _getDefaultImageForCategory(category),
      currentParticipants: 1,
      messageCount: 0,
      category: category,
      creatorName: 'Вы',
      creatorAvatarUrl: null,
      tags: tags,
      isJoined: true,
      maxParticipants: maxParticipants,
      accessType: accessType,
      password: password,
    );

    // Добавляем в кэш
    _cachedRooms?.insert(0, room);
    _roomCache[room.id] = room;

    return room;
  }

  // Обновление комнаты
  Future<void> updateRoom(Room room) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Обновляем в кэше
    _roomCache[room.id] = room;
    final index = _cachedRooms?.indexWhere((r) => r.id == room.id);
    if (index != null && index != -1) {
      _cachedRooms?[index] = room;
    }

    if (kDebugMode) {
      print('Room updated: ${room.title}');
    }
  }

  // Получение комнаты по ID
  Future<Room?> getRoomById(String roomId) async {
    // Проверяем кэш
    if (_roomCache.containsKey(roomId)) {
      return _roomCache[roomId];
    }

    // Если нет в кэше, загружаем все комнаты
    final rooms = await getRooms();
    return rooms.firstWhere((room) => room.id == roomId);
  }

  // Удаление комнаты
  Future<bool> deleteRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Удаляем из кэша
    _roomCache.remove(roomId);
    _cachedRooms?.removeWhere((room) => room.id == roomId);

    if (kDebugMode) {
      print('Room deleted: $roomId');
    }
    return true;
  }

  // Упрощенные методы для участия/выхода
  Future<bool> joinRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final room = await getRoomById(roomId);
    if (room != null && room.hasAvailableSpots) {
      final updatedRoom = room.copyWith(
        currentParticipants: room.currentParticipants + 1,
        isJoined: true,
      );
      await updateRoom(updatedRoom);
      return true;
    }
    return false;
  }

  Future<bool> leaveRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final room = await getRoomById(roomId);
    if (room != null && room.isJoined) {
      final updatedRoom = room.copyWith(
        currentParticipants: room.currentParticipants - 1,
        isJoined: false,
      );
      await updateRoom(updatedRoom);
      return true;
    }
    return false;
  }

  // Рейтинг комнаты
  Future<bool> rateRoom(String roomId, double rating) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final room = await getRoomById(roomId);
    if (room != null) {
      final newRatingCount = room.ratingCount + 1;
      final newRating = ((room.rating * room.ratingCount) + rating) / newRatingCount;

      final updatedRoom = room.copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        ratingCount: newRatingCount,
      );
      await updateRoom(updatedRoom);
      return true;
    }
    return false;
  }

  // Поиск комнат
  Future<List<Room>> searchRooms(String query) async {
    if (query.isEmpty) {
      return await getRooms();
    }

    final rooms = await getRooms();
    final lowerQuery = query.toLowerCase();

    return rooms.where((room) =>
    room.title.toLowerCase().contains(lowerQuery) ||
        room.description.toLowerCase().contains(lowerQuery) ||
        room.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
        room.category.title.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Получение рекомендуемых комнат
  Future<List<Room>> getRecommendedRooms() async {
    final rooms = await getRooms();
    return rooms
        .where((room) => room.isActive && room.isHighlyRated && room.hasAvailableSpots)
        .take(5)
        .toList();
  }

  // Получение популярных комнат
  Future<List<Room>> getPopularRooms() async {
    final rooms = await getRooms();
    return rooms
        .where((room) => room.isActive && room.isPopular)
        .toList()
      ..sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
  }

  // Очистка кэша
  void clearCache() {
    _cachedRooms = null;
    _roomCache.clear();
  }

  // Вспомогательный метод для получения изображения по категории
  String _getDefaultImageForCategory(RoomCategory category) {
    const defaultImages = {
      'technology': 'https://avatars.mds.yandex.net/i?id=1e90171b7d4bc14b07b66f1f6757ff2f_l-9837529-images-thumbs&n=13',
      'programming': 'https://avatars.mds.yandex.net/i?id=32c0a73c0990f1f127a8f440607ad510f6650260-4559382-images-thumbs&n=13',
      'business': 'https://avatars.mds.yandex.net/i?id=dda503b4fa8209f9669720bbe1d3b708_l-10251881-images-thumbs&n=13',
      'games': 'https://avatars.mds.yandex.net/i?id=1d8887bee2ca66b5d364c0c930a7ae4f_l-5115383-images-thumbs&n=13',
      'youtube': 'https://avatars.mds.yandex.net/i?id=a3c059dfd766f0b77cb583919bc5c0c8_l-5245909-images-thumbs&n=13',
    };

    return defaultImages[category.id] ?? defaultImages['technology']!;
  }
}