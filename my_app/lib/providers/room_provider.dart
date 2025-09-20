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

  RoomProvider(this._roomService);

  List<Room> get rooms => _rooms;
  List<Room> get filteredRooms => _filteredRooms;
  RoomCategory get selectedCategory => _selectedCategory;
  RoomSortBy get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showJoinedOnly => _showJoinedOnly;

  // Добавленный метод addRoom
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

  Future<void> createRoom({
    required String title,
    required String description,
    required RoomCategory category,
    bool isPrivate = false,
    List<String> tags = const [],
  }) async {
    try {
      final newRoom = await _roomService.createRoom(
        title: title,
        description: description,
        category: category,
        isPrivate: isPrivate,
        tags: tags,
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

  void _applyFilters() {
    List<Room> filtered = _rooms;

    // Фильтр по категории
    if (_selectedCategory != RoomCategory.all) {
      filtered = filtered.where((room) => room.category == _selectedCategory).toList();
    }

    // Фильтр по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((room) {
        return room.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            room.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            room.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Фильтр по присоединенным комнатам
    if (_showJoinedOnly) {
      filtered = filtered.where((room) => room.isJoined).toList();
    }

    // Сортировка
    filtered = _sortRooms(filtered);

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
    }
  }
}