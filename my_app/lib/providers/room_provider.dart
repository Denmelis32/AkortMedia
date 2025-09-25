import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../pages/rooms_pages/models/room.dart';
import '../services/room_service.dart';

class RoomProvider with ChangeNotifier {
  final RoomService _roomService;

  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  RoomCategory _selectedCategory = RoomCategory.all;
  RoomSortBy _sortBy = RoomSortBy.recent;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showJoinedOnly = false;
  bool _showActiveOnly = true;
  bool _showPinnedFirst = true;

  RoomProvider(this._roomService);

  List<Room> get rooms => _rooms;
  List<Room> get filteredRooms => _filteredRooms;
  RoomCategory get selectedCategory => _selectedCategory;
  RoomSortBy get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showJoinedOnly => _showJoinedOnly;
  bool get showActiveOnly => _showActiveOnly;
  bool get showPinnedFirst => _showPinnedFirst;

  // Основные методы
  void addRoom(Room room) {
    _rooms.insert(0, room);
    _applyFilters();
    notifyListeners();
  }

  Future<void> loadRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rooms = await _roomService.getRooms();
      _applyFilters();
    } catch (error) {
      if (kDebugMode) {
        print('Error loading rooms: $error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(RoomCategory category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(RoomSortBy sortBy) {
    _sortBy = sortBy;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleShowJoinedOnly() {
    _showJoinedOnly = !_showJoinedOnly;
    _applyFilters();
    notifyListeners();
  }

  void toggleShowActiveOnly() {
    _showActiveOnly = !_showActiveOnly;
    _applyFilters();
    notifyListeners();
  }

  void toggleShowPinnedFirst() {
    _showPinnedFirst = !_showPinnedFirst;
    _applyFilters();
    notifyListeners();
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С КОМНАТАМИ

  Future<void> toggleJoinRoom(String roomId) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedRoom = room.copyWith(
          isJoined: !room.isJoined,
          participants: room.isJoined ? room.participants - 1 : room.participants + 1,
        );

        _rooms[roomIndex] = updatedRoom;
        _applyFilters();
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error toggling room join: $error');
      }
    }
  }

  Future<void> togglePinRoom(String roomId) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedRoom = room.copyWith(isPinned: !room.isPinned);

        _rooms[roomIndex] = updatedRoom;

        // Перемещаем закрепленную комнату в начало
        if (updatedRoom.isPinned) {
          final pinnedRoom = _rooms.removeAt(roomIndex);
          _rooms.insert(0, pinnedRoom);
        }

        _applyFilters();
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error toggling room pin: $error');
      }
    }
  }

  Future<void> updateRoomRating(String roomId, double newRating) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        // Простое усреднение рейтинга
        final updatedRating = (room.rating + newRating) / 2;
        final updatedRoom = room.copyWith(rating: updatedRating);

        _rooms[roomIndex] = updatedRoom;
        _applyFilters();
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating room rating: $error');
      }
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      _rooms.removeWhere((room) => room.id == roomId);
      _applyFilters();
      notifyListeners();

      await _roomService.deleteRoom(roomId);
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting room: $error');
      }
      rethrow;
    }
  }

  Future<void> updateRoom(Room updatedRoom) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == updatedRoom.id);
      if (roomIndex != -1) {
        _rooms[roomIndex] = updatedRoom;
        _applyFilters();
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating room: $error');
      }
    }
  }

  Future<void> addMessageToRoom(String roomId) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedRoom = room.copyWith(
          messages: room.messages + 1,
          lastActivity: DateTime.now(),
        );

        _rooms[roomIndex] = updatedRoom;
        _applyFilters();
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding message to room: $error');
      }
    }
  }

  Future<void> banUserFromRoom(String roomId, String userId) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedBannedUsers = List<String>.from(room.bannedUsers)..add(userId);
        final updatedRoom = room.copyWith(bannedUsers: updatedBannedUsers);

        _rooms[roomIndex] = updatedRoom;
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error banning user from room: $error');
      }
    }
  }

  Future<void> addModeratorToRoom(String roomId, String userId) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedModerators = List<String>.from(room.moderators)..add(userId);
        final updatedRoom = room.copyWith(moderators: updatedModerators);

        _rooms[roomIndex] = updatedRoom;
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding moderator to room: $error');
      }
    }
  }

  // Методы для работы с тегами
  Future<void> addTagToRoom(String roomId, String tag) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedRoom = room.addTag(tag);

        _rooms[roomIndex] = updatedRoom;
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding tag to room: $error');
      }
    }
  }

  Future<void> removeTagFromRoom(String roomId, String tag) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedRoom = room.removeTag(tag);

        _rooms[roomIndex] = updatedRoom;
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error removing tag from room: $error');
      }
    }
  }

  // Создание комнаты с расширенными параметрами
  Future<void> createRoom({
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
    try {
      final newRoom = await _roomService.createRoom(
        title: title,
        description: description,
        category: category,
        isPrivate: isPrivate,
        tags: tags,
        maxParticipants: maxParticipants,
        rules: rules,
        accessLevel: accessLevel,
        password: password,
        scheduledStart: scheduledStart,
        duration: duration,
      );

      _rooms.insert(0, newRoom);
      _applyFilters();
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error creating room: $error');
      }
      rethrow;
    }
  }

  // Поиск и фильтрация
  List<Room> searchRoomsByTag(String tag) {
    return _rooms.where((room) => room.hasTag(tag)).toList();
  }

  List<Room> getPopularRooms({int minParticipants = 20, double minRating = 4.0}) {
    return _rooms.where((room) =>
    room.participants >= minParticipants && room.rating >= minRating
    ).toList();
  }

  List<Room> getMyRooms() {
    return _rooms.where((room) => room.isOwner).toList();
  }

  List<Room> getModeratedRooms() {
    return _rooms.where((room) => room.isModerator).toList();
  }

  List<Room> getScheduledRooms() {
    return _rooms.where((room) => room.isScheduled && !room.isExpired).toList();
  }

  // Статистика
  Map<String, dynamic> getRoomStats() {
    final totalRooms = _rooms.length;
    final activeRooms = _rooms.where((room) => room.isActive).length;
    final totalParticipants = _rooms.fold(0, (sum, room) => sum + room.participants);
    final averageRating = _rooms.isEmpty ? 0 :
    _rooms.map((room) => room.rating).reduce((a, b) => a + b) / _rooms.length;

    return {
      'totalRooms': totalRooms,
      'activeRooms': activeRooms,
      'totalParticipants': totalParticipants,
      'averageRating': averageRating.toStringAsFixed(1),
      'pinnedRooms': _rooms.where((room) => room.isPinned).length,
      'scheduledRooms': _rooms.where((room) => room.isScheduled).length,
    };
  }

  // Внутренние методы фильтрации
  void _applyFilters() {
    List<Room> filtered = _rooms;

    // Фильтр по категории
    if (_selectedCategory != RoomCategory.all) {
      filtered = filtered.where((room) => room.category == _selectedCategory).toList();
    }

    // Фильтр по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((room) => room.matchesQuery(_searchQuery)).toList();
    }

    // Фильтр по присоединенным комнатам
    if (_showJoinedOnly) {
      filtered = filtered.where((room) => room.isJoined).toList();
    }

    // Фильтр по активным комнатам
    if (_showActiveOnly) {
      filtered = filtered.where((room) => room.isActive).toList();
    }

    // Сортировка
    filtered = _sortRooms(filtered);

    // Закрепленные комнаты в начале
    if (_showPinnedFirst) {
      final pinnedRooms = filtered.where((room) => room.isPinned).toList();
      final unpinnedRooms = filtered.where((room) => !room.isPinned).toList();
      filtered = [...pinnedRooms, ...unpinnedRooms];
    }

    _filteredRooms = filtered;
  }

  List<Room> _sortRooms(List<Room> rooms) {
    switch (_sortBy) {
      case RoomSortBy.recent:
        return rooms.sorted((a, b) => b.lastActivity.compareTo(a.lastActivity));
      case RoomSortBy.popular:
        return rooms.sorted((a, b) => b.participants.compareTo(a.participants));
      case RoomSortBy.participants:
        return rooms.sorted((a, b) => b.participants.compareTo(a.participants));
      case RoomSortBy.messages:
        return rooms.sorted((a, b) => b.messages.compareTo(a.messages));
      case RoomSortBy.rating:
        return rooms.sorted((a, b) => b.rating.compareTo(a.rating));
      case RoomSortBy.scheduled:
        return rooms.sorted((a, b) {
          final aStart = a.scheduledStart ?? DateTime(0);
          final bStart = b.scheduledStart ?? DateTime(0);
          return aStart.compareTo(bStart);
        });
    }
  }

  // Валидация и утилиты
  bool canUserEditRoom(String roomId, String userId) {
    final room = _rooms.firstWhereOrNull((room) => room.id == roomId);
    return room?.canEdit(userId) ?? false;
  }

  bool canUserDeleteRoom(String roomId, String userId) {
    final room = _rooms.firstWhereOrNull((room) => room.id == roomId);
    return room?.canDelete(userId) ?? false;
  }

  Room? getRoomById(String roomId) {
    return _rooms.firstWhereOrNull((room) => room.id == roomId);
  }

  // Сброс фильтров
  void resetFilters() {
    _selectedCategory = RoomCategory.all;
    _sortBy = RoomSortBy.recent;
    _searchQuery = '';
    _showJoinedOnly = false;
    _showActiveOnly = true;
    _showPinnedFirst = true;
    _applyFilters();
    notifyListeners();
  }
}