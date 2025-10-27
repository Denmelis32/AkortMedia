import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../pages/rooms_pages/models/room.dart';
import '../pages/rooms_pages/models/room_category.dart';
import '../services/room_service.dart';

class RoomProvider with ChangeNotifier {
  final RoomService _roomService;
  String? _currentUserId; // Убрали final чтобы можно было изменять

  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  RoomCategory _selectedCategory = RoomCategory.all;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showJoinedOnly = false;
  bool _showActiveOnly = true;
  final Set<String> _activeFilters = {};

  // Кэш для быстрого доступа к комнатам
  final Map<String, Room> _roomCache = {};

  // Оптимизация: предотвращение частых обновлений
  bool _isFiltering = false;

  RoomProvider(this._roomService, {String? currentUserId})
      : _currentUserId = currentUserId ?? 'current_user';

  // ГЕТТЕРЫ
  List<Room> get rooms => _rooms;
  List<Room> get filteredRooms => _filteredRooms;
  RoomCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showJoinedOnly => _showJoinedOnly;
  bool get showActiveOnly => _showActiveOnly;
  Set<String> get activeFilters => _activeFilters;
  String? get currentUserId => _currentUserId; // Изменили на nullable

  // НОВЫЕ МЕТОДЫ ДЛЯ ПРОВЕРКИ ДОСТУПА
  bool canJoinRoom(Room room, {String? password}) {
    if (_currentUserId == null) return false;
    return room.hasAccess(_currentUserId!, inputPassword: password);
  }

  bool hasAccessToRoom(Room room, {String? password}) {
    if (_currentUserId == null) return false;
    return room.hasAccess(_currentUserId!, inputPassword: password);
  }

  Future<void> joinRoomWithPassword(String roomId, String password) async {
    try {
      if (_currentUserId == null) throw Exception('Пользователь не авторизован');

      final room = getRoomById(roomId);
      if (room == null) throw Exception('Комната не найдена');

      if (room.hasAccess(_currentUserId!, inputPassword: password)) {
        await toggleJoinRoom(roomId);
      } else {
        throw Exception('Неверный пароль');
      }
    } catch (error) {
      rethrow;
    }
  }

  void updateCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // ОСНОВНЫЕ МЕТОДЫ ДЛЯ ADAPTIVE ROOMS PAGE
  void addRoom(Room room) {
    _rooms.insert(0, room);
    _updateRoomCache(room);
    _applyFilters();
    notifyListeners();
  }

  Future<void> loadRooms() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _rooms = await _roomService.getRooms();
      _updateAllRoomCache();
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
    if (_selectedCategory == category) return;

    _selectedCategory = category;
    _applyFiltersDebounced();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;
    _applyFiltersDebounced();
  }

  void toggleShowJoinedOnly() {
    _showJoinedOnly = !_showJoinedOnly;
    _applyFiltersDebounced();
  }

  void toggleShowActiveOnly() {
    _showActiveOnly = !_showActiveOnly;
    _applyFiltersDebounced();
  }

  void toggleFilter(String filterId) {
    if (_activeFilters.contains(filterId)) {
      _activeFilters.remove(filterId);
    } else {
      _activeFilters.add(filterId);
    }
    _applyFiltersDebounced();
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
      if (_currentUserId == null) throw Exception('Пользователь не авторизован');

      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];

        // Проверяем доступ для приватных комнат
        if (room.isPrivateRoom && !room.isJoined) {
          if (!room.hasAccess(_currentUserId!)) {
            throw Exception('Нет доступа к закрытой комнате');
          }
        }

        final updatedRoom = room.copyWith(
          isJoined: !room.isJoined,
          currentParticipants: room.isJoined
              ? room.currentParticipants - 1
              : room.currentParticipants + 1,
        );

        _rooms[roomIndex] = updatedRoom;
        _updateRoomCache(updatedRoom);
        _applyFilters();
        notifyListeners();

        await _roomService.updateRoom(updatedRoom);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error toggling room join: $error');
      }
      rethrow;
    }
  }

  Future<void> togglePinRoom(String roomId) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        final updatedRoom = room.copyWith(isPinned: !room.isPinned);

        _rooms[roomIndex] = updatedRoom;
        _updateRoomCache(updatedRoom);

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
        _updateRoomCache(updatedRoom);
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
      _roomCache.remove(roomId);
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

  // СОЗДАНИЕ КОМНАТЫ - РАСШИРЕННАЯ ВЕРСИЯ
  Future<Room> createRoom({
    required String title,
    required String description,
    required RoomCategory category,
    RoomAccessType accessType = RoomAccessType.public,
    String password = '',
    List<String> tags = const [],
    int maxParticipants = 100,
    DateTime? scheduledStart,
    Duration? duration,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newRoom = await _roomService.createRoom(
        title: title,
        description: description,
        category: category,
        accessType: accessType,
        password: password,
        tags: tags,
        maxParticipants: maxParticipants,
        scheduledStart: scheduledStart,
      );

      // Добавляем комнату с правильными флагами
      final roomWithCorrectFlags = newRoom.copyWith(
        isJoined: true,
        lastActivity: DateTime.now(),
        isActive: true,
      );

      _rooms.insert(0, roomWithCorrectFlags);
      _updateRoomCache(roomWithCorrectFlags);
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

  // НОВЫЙ МЕТОД: Получение комнат по типу доступа
  List<Room> getRoomsByAccessType(RoomAccessType accessType) {
    return _rooms.where((room) => room.accessType == accessType).toList();
  }

  // НОВЫЙ МЕТОД: Рекомендуемые комнаты
  List<Room> getRecommendedRooms() {
    return _rooms
        .where((room) => room.isActive && room.isHighlyRated && room.hasAvailableSpots)
        .take(5)
        .toList();
  }

  // СТАТИСТИКА
  Map<String, dynamic> getRoomStats() {
    final totalRooms = _rooms.length;
    final activeRooms = _rooms.where((room) => room.isActive).length;
    final totalParticipants = _rooms.fold(
        0, (sum, room) => sum + room.currentParticipants);
    final joinedRooms = _rooms.where((room) => room.isJoined).length;

    // Новая статистика по типам доступа
    final publicRooms = _rooms.where((room) => room.isPublic).length;
    final privateRooms = _rooms.where((room) => room.isPrivateRoom).length;
    final passwordRooms = _rooms.where((room) => room.isPasswordProtected).length;

    return {
      'totalRooms': totalRooms,
      'activeRooms': activeRooms,
      'totalParticipants': totalParticipants,
      'joinedRooms': joinedRooms,
      'filteredRooms': _filteredRooms.length,
      'publicRooms': publicRooms,
      'privateRooms': privateRooms,
      'passwordRooms': passwordRooms,
    };
  }

  // ПОЛУЧЕНИЕ КОМНАТЫ ПО ID
  Room? getRoomById(String roomId) {
    // Используем кэш для быстрого доступа
    if (_roomCache.containsKey(roomId)) {
      return _roomCache[roomId];
    }

    final room = _rooms.firstWhereOrNull((room) => room.id == roomId);
    if (room != null) {
      _roomCache[roomId] = room;
    }

    return room;
  }

  // ПОЛУЧЕНИЕ ВСЕХ УНИКАЛЬНЫХ ТЕГОВ
  Set<String> getAllTags() {
    return _rooms.fold<Set<String>>({}, (tags, room) {
      return tags..addAll(room.tags);
    });
  }

  // ОСНОВНОЙ МЕТОД ФИЛЬТРАЦИИ С ОПТИМИЗАЦИЕЙ
  void _applyFilters() {
    if (_isFiltering) return;

    _isFiltering = true;

    try {
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
        filtered = filtered.where((room) => room.isJoined).toList();
      }

      if (_activeFilters.contains('active')) {
        filtered = filtered.where((room) => room.isActive).toList();
      }

      // НОВЫЕ ФИЛЬТРЫ ДЛЯ ТИПОВ ДОСТУПА
      if (_activeFilters.contains('public')) {
        filtered = filtered.where((room) => room.isPublic).toList();
      }

      if (_activeFilters.contains('private')) {
        filtered = filtered.where((room) => room.isPrivateRoom).toList();
      }

      if (_activeFilters.contains('password')) {
        filtered = filtered.where((room) => room.isPasswordProtected).toList();
      }

      // Сортировка: закрепленные первыми, затем по активности
      filtered.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;

        // Сортировка по активности (новые и активные первыми)
        final aActivity = a.activityLevel;
        final bActivity = b.activityLevel;

        if (aActivity != bActivity) {
          return bActivity.compareTo(aActivity);
        }

        return b.lastActivity.compareTo(a.lastActivity);
      });

      _filteredRooms = filtered;
    } finally {
      _isFiltering = false;
    }
  }

  // ОПТИМИЗАЦИЯ: Отложенная фильтрация для предотвращения частых обновлений
  void _applyFiltersDebounced() {
    _isFiltering = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      _applyFilters();
      notifyListeners();
    });
  }

  // КЭШИРОВАНИЕ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
  void _updateRoomCache(Room room) {
    _roomCache[room.id] = room;
  }

  void _updateAllRoomCache() {
    _roomCache.clear();
    for (final room in _rooms) {
      _roomCache[room.id] = room;
    }
  }

  // ДОБАВЛЕНИЕ КОМНАТЫ ЛОКАЛЬНО (для CreateRoomButton)
  void addRoomLocally(Room newRoom) {
    _rooms.insert(0, newRoom);
    _updateRoomCache(newRoom);
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
    _roomCache.clear();
    notifyListeners();
  }

  // НОВЫЙ МЕТОД: Обновление активности комнаты
  void updateRoomActivity(String roomId) {
    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      final room = _rooms[roomIndex];
      final updatedRoom = room.copyWith(
        lastActivity: DateTime.now(),
        messageCount: room.messageCount + 1,
      );

      _rooms[roomIndex] = updatedRoom;
      _updateRoomCache(updatedRoom);

      // Не уведомляем слушателей для оптимизации
      // notifyListeners();
    }
  }

  // НОВЫЙ МЕТОД: Получение комнат создателя
  List<Room> getCreatorRooms(String creatorId) {
    return _rooms.where((room) => room.creatorId == creatorId).toList();
  }

  // НОВЫЙ МЕТОД: Проверка доступности комнаты
  bool isRoomAvailable(String roomId) {
    final room = getRoomById(roomId);
    return room != null && room.isActive && !room.isFull && room.canJoin;
  }

  // НОВЫЙ МЕТОД: Получение доступных комнат для пользователя
  List<Room> getAccessibleRooms() {
    if (_currentUserId == null) return [];
    return _rooms.where((room) => room.hasAccess(_currentUserId!)).toList();
  }
}