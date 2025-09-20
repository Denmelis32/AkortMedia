import '../pages/rooms_pages/models/room.dart';

class RoomService {
  Future<List<Room>> getRooms() async {
    // Имитация загрузки из API
    await Future.delayed(const Duration(seconds: 1));

    return [
      Room(
        id: '1',
        title: 'Технологии будущего',
        description: 'Обсуждаем новейшие технологии и инновации в IT-индустрии',
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
        participants: 12450,
        messages: 89456,
        isJoined: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
        category: RoomCategory.tech,
        creatorId: 'user1',
        tags: ['технологии', 'инновации', 'IT'],
      ),
      // ... остальные комнаты
    ];
  }

  Future<Room> createRoom({
    required String title,
    required String description,
    required RoomCategory category,
    bool isPrivate = false,
    List<String> tags = const [],
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return Room(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      participants: 1,
      messages: 0,
      isJoined: true,
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
      category: category,
      creatorId: 'current_user',
      isPrivate: isPrivate,
      tags: tags,
    );
  }

  Future<void> updateRoom(Room room) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}