import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../pages/rooms_pages/models/room.dart';
import '../pages/rooms_pages/models/room_category.dart';
import '../services/room_service.dart';

class RoomProvider with ChangeNotifier {
  final RoomService _roomService;

  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  RoomCategory _selectedCategory = RoomCategory.all;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showJoinedOnly = false;
  bool _showActiveOnly = true;
  final Set<String> _activeFilters = {};

  RoomProvider(this._roomService);

  // ГЕТТЕРЫ
  List<Room> get rooms => _rooms;
  List<Room> get filteredRooms => _filteredRooms;
  RoomCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showJoinedOnly => _showJoinedOnly;
  bool get showActiveOnly => _showActiveOnly;
  Set<String> get activeFilters => _activeFilters;

  // ОСНОВНЫЕ МЕТОДЫ ДЛЯ ADAPTIVE ROOMS PAGE
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

  void toggleFilter(String filterId) {
    if (_activeFilters.contains(filterId)) {
      _activeFilters.remove(filterId);
    } else {
      _activeFilters.add(filterId);
    }
    _applyFilters();
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedCategory = RoomCategory.all;
    _searchQuery = '';
    _showJoinedOnly = false;
    _showActiveOnly = true;
    _activeFilters.clear();
    _applyFilters();
    notifyListeners();
  }

  // МЕТОДЫ ДЛЯ РАБОТЫ С КОМНАТАМИ
  Future<void> toggleJoinRoom(String roomId) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedRoom = room.copyWith(
          isJoined: !room.isJoined,
          currentParticipants: room.isJoined
              ? room.currentParticipants - 1
              : room.currentParticipants + 1,
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
      notifyListeners();
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

  // СОЗДАНИЕ КОМНАТЫ - УПРОЩЕННАЯ ВЕРСИЯ
  Future<Room> createRoom({
    required String title,
    required String description,
    required RoomCategory category,
    List<String> tags = const [],
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newRoom = await _roomService.createRoom(
        title: title,
        description: description,
        category: category,
        tags: tags,
      );

      // Добавляем комнату с правильными флагами
      final roomWithCorrectFlags = newRoom.copyWith(
        isJoined: true,
        lastActivity: DateTime.now(),
        isActive: true,
      );

      _rooms.insert(0, roomWithCorrectFlags);
      _applyFilters();
      notifyListeners();

      return roomWithCorrectFlags;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ПОИСК И ФИЛЬТРАЦИЯ
  List<Room> searchRoomsByTag(String tag) {
    return _rooms
        .where((room) => room.tags.contains(tag.toLowerCase()))
        .toList();
  }

  List<Room> getPopularRooms() {
    return _rooms.where((room) =>
    room.currentParticipants >= 10 && room.rating >= 4.0
    ).toList();
  }

  List<Room> getMyRooms() {
    return _rooms.where((room) => room.isJoined).toList();
  }

  // СТАТИСТИКА
  Map<String, dynamic> getRoomStats() {
    final totalRooms = _rooms.length;
    final activeRooms = _rooms.where((room) => room.isActive).length;
    final totalParticipants = _rooms.fold(
        0, (sum, room) => sum + room.currentParticipants);
    final joinedRooms = _rooms.where((room) => room.isJoined).length;

    return {
      'totalRooms': totalRooms,
      'activeRooms': activeRooms,
      'totalParticipants': totalParticipants,
      'joinedRooms': joinedRooms,
      'filteredRooms': _filteredRooms.length,
    };
  }

  // ПОЛУЧЕНИЕ КОМНАТЫ ПО ID
  Room? getRoomById(String roomId) {
    return _rooms.firstWhereOrNull((room) => room.id == roomId);
  }

  // ПОЛУЧЕНИЕ ВСЕХ УНИКАЛЬНЫХ ТЕГОВ
  Set<String> getAllTags() {
    return _rooms.fold<Set<String>>({}, (tags, room) {
      return tags..addAll(room.tags);
    });
  }

  // ОСНОВНОЙ МЕТОД ФИЛЬТРАЦИИ
  void _applyFilters() {
    List<Room> filtered = List.from(_rooms);

    // Фильтр по категории
    if (_selectedCategory != RoomCategory.all) {
      filtered = filtered.where((room) => room.category == _selectedCategory).toList();
    }

    // Фильтр по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((room) =>
      room.title.toLowerCase().contains(query) ||
          room.description.toLowerCase().contains(query) ||
          room.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    // Фильтр "только мои комнаты"
    if (_showJoinedOnly) {
      filtered = filtered.where((room) => room.isJoined).toList();
    }

    // Фильтр "только активные"
    if (_showActiveOnly) {
      filtered = filtered.where((room) => room.isActive && !room.isExpired).toList();
    }

    // Дополнительные фильтры из activeFilters
    if (_activeFilters.contains('favorites')) {
      filtered = filtered.where((room) => room.isJoined).toList(); // Для примера - избранные = присоединенные
    }

    if (_activeFilters.contains('active')) {
      filtered = filtered.where((room) => room.isActive).toList();
    }

    // Сортировка: закрепленные первыми
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    _filteredRooms = filtered;
  }

  // ДОБАВЛЕНИЕ КОМНАТЫ ЛОКАЛЬНО (для CreateRoomButton)
  void addRoomLocally(Room newRoom) {
    _rooms.insert(0, newRoom);
    _applyFilters();
    notifyListeners();
  }

  // ОЧИСТКА ВСЕХ ДАННЫХ
  void clearAllData() {
    _rooms = [];
    _filteredRooms = [];
    _selectedCategory = RoomCategory.all;
    _searchQuery = '';
    _isLoading = false;
    _showJoinedOnly = false;
    _showActiveOnly = true;
    _activeFilters.clear();
    notifyListeners();
  }
}