import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../pages/rooms_pages/models/room.dart';
import '../pages/rooms_pages/models/room_filters.dart';
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

  // НОВЫЕ СВОЙСТВА ДЛЯ РАСШИРЕННЫХ ФИЛЬТРОВ
  RoomFilters _activeFilters = const RoomFilters();
  Set<String> _selectedTags = {};
  List<String> _searchSuggestions = [];

  RoomProvider(this._roomService);

  // ГЕТТЕРЫ
  List<Room> get rooms => _rooms;
  List<Room> get filteredRooms => _filteredRooms;
  RoomCategory get selectedCategory => _selectedCategory;
  RoomSortBy get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showJoinedOnly => _showJoinedOnly;
  bool get showActiveOnly => _showActiveOnly;
  bool get showPinnedFirst => _showPinnedFirst;

  // НОВЫЕ ГЕТТЕРЫ
  RoomFilters get activeFilters => _activeFilters;
  Set<String> get selectedTags => _selectedTags;
  List<String> get searchSuggestions => _searchSuggestions;

  // ОСНОВНЫЕ МЕТОДЫ
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
    if (query.length >= 2) {
      updateSearchSuggestions(query); // ← изменили здесь
    } else {
      _searchSuggestions = [];
    }
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

  // НОВЫЕ МЕТОДЫ ДЛЯ РАСШИРЕННЫХ ФИЛЬТРОВ
  void setFilters(RoomFilters filters) {
    _activeFilters = filters;
    _applyFilters();
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _applyFilters();
    notifyListeners();
  }

  void updateSearchSuggestions(String query) {
    if (query.length < 2) {
      _searchSuggestions = [];
    } else {
      final queryLower = query.toLowerCase();
      _searchSuggestions = _rooms
          .where((room) =>
      room.title.toLowerCase().contains(queryLower) ||
          room.description.toLowerCase().contains(queryLower) ||
          room.tags.any((tag) => tag.toLowerCase().contains(queryLower)) ||
          room.creatorName.toLowerCase().contains(queryLower))
          .map((room) => room.title)
          .take(5)
          .toList();
    }
    notifyListeners();
  }

  void resetAllFilters() {
    _selectedCategory = RoomCategory.all;
    _sortBy = RoomSortBy.recent;
    _searchQuery = '';
    _showJoinedOnly = false;
    _showActiveOnly = true;
    _showPinnedFirst = true;
    _activeFilters = const RoomFilters();
    _selectedTags = {};
    _searchSuggestions = [];
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
          currentParticipants: room.isJoined ? room.currentParticipants - 1 : room.currentParticipants + 1,
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
        // Усреднение рейтинга с учетом предыдущих оценок
        final updatedRating = (room.rating * room.ratingCount + newRating) / (room.ratingCount + 1);
        final updatedRoom = room.copyWith(
          rating: updatedRating,
          ratingCount: room.ratingCount + 1,
        );

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
          messageCount: room.messageCount + 1,
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
        final updatedTags = List<String>.from(room.tags)..add(tag);
        final updatedRoom = room.copyWith(tags: updatedTags);

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
        final updatedTags = List<String>.from(room.tags)..remove(tag);
        final updatedRoom = room.copyWith(tags: updatedTags);

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
    return _rooms.where((room) => room.tags.contains(tag)).toList();
  }

  List<Room> getPopularRooms({int minParticipants = 20, double minRating = 4.0}) {
    return _rooms.where((room) =>
    room.currentParticipants >= minParticipants && room.rating >= minRating
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

  // Статистика с обновленными данными
  Map<String, dynamic> getRoomStats() {
    final filtered = _filteredRooms;
    final totalRooms = _rooms.length;
    final activeRooms = _rooms.where((room) => room.isActive).length;
    final totalParticipants = _rooms.fold(0, (sum, room) => sum + room.currentParticipants);
    final averageRating = _rooms.isEmpty ? 0.0 :
    _rooms.map((room) => room.rating).reduce((a, b) => a + b) / _rooms.length;

    return {
      'totalRooms': totalRooms,
      'activeRooms': activeRooms,
      'totalParticipants': totalParticipants,
      'averageRating': averageRating.toStringAsFixed(1),
      'pinnedRooms': _rooms.where((room) => room.isPinned).length,
      'scheduledRooms': _rooms.where((room) => room.isScheduled).length,
      'filteredRooms': filtered.length,
      'joinedRooms': _rooms.where((room) => room.isJoined).length,
    };
  }

  // ОБНОВЛЕННЫЙ МЕТОД ФИЛЬТРАЦИИ
  void _applyFilters() {
    List<Room> filtered = _rooms;

    // Базовые фильтры
    if (_selectedCategory != RoomCategory.all) {
      filtered = filtered.where((room) => room.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((room) =>
      room.title.toLowerCase().contains(query) ||
          room.description.toLowerCase().contains(query) ||
          room.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          room.creatorName.toLowerCase().contains(query)
      ).toList();
    }

    if (_showJoinedOnly) {
      filtered = filtered.where((room) => room.isJoined).toList();
    }

    if (_showActiveOnly) {
      filtered = filtered.where((room) => room.isActive).toList();
    }

    // Расширенные фильтры из RoomFilters
    if (_activeFilters.tags.isNotEmpty) {
      filtered = filtered.where((room) =>
          _activeFilters.tags.any((tag) => room.tags.contains(tag))
      ).toList();
    }

    if (_activeFilters.minParticipants > 0) {
      filtered = filtered.where((room) =>
      room.currentParticipants >= _activeFilters.minParticipants
      ).toList();
    }

    if (_activeFilters.maxParticipants < 1000) {
      filtered = filtered.where((room) =>
      room.currentParticipants <= _activeFilters.maxParticipants
      ).toList();
    }

    if (_activeFilters.minRating > 0.0) {
      filtered = filtered.where((room) => room.rating >= _activeFilters.minRating).toList();
    }

    if (_activeFilters.createdAfter != null) {
      filtered = filtered.where((room) =>
          room.createdAt.isAfter(_activeFilters.createdAfter!)
      ).toList();
    }

    if (_activeFilters.hasMedia) {
      filtered = filtered.where((room) => room.hasMedia).toList();
    }

    if (_activeFilters.isVerified) {
      filtered = filtered.where((room) => room.isVerified).toList();
    }

    if (_activeFilters.isPinned) {
      filtered = filtered.where((room) => room.isPinned).toList();
    }

    if (_activeFilters.isJoined) {
      filtered = filtered.where((room) => room.isJoined).toList();
    }

    // Фильтр по выбранным тегам
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((room) =>
          _selectedTags.any((tag) => room.tags.contains(tag))
      ).toList();
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
        return rooms.sorted((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
      case RoomSortBy.participants:
        return rooms.sorted((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
      case RoomSortBy.messages:
        return rooms.sorted((a, b) => b.messageCount.compareTo(a.messageCount));
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

  // Получение всех уникальных тегов
  Set<String> getAllTags() {
    return _rooms.fold<Set<String>>({}, (tags, room) {
      return tags..addAll(room.tags);
    });
  }

  // Получение популярных тегов
  Map<String, int> getPopularTags({int limit = 10}) {
    final tagCounts = <String, int>{};

    for (final room in _rooms) {
      for (final tag in room.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedTags.take(limit));
  }

  // Сброс фильтров (старый метод для обратной совместимости)
  void resetFilters() {
    resetAllFilters();
  }
}