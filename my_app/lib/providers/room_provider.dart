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
  bool _hasNewInvites = false;

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
  bool get hasNewInvites => _hasNewInvites;

  // НОВЫЕ ГЕТТЕРЫ
  RoomFilters get activeFilters => _activeFilters;
  Set<String> get selectedTags => _selectedTags;
  List<String> get searchSuggestions => _searchSuggestions;

  // Проверка активных расширенных фильтров
  bool get hasActiveAdvancedFilters {
    return _activeFilters.tags.isNotEmpty ||
        _activeFilters.minParticipants > 0 ||
        _activeFilters.maxParticipants < 1000 ||
        _activeFilters.minRating > 0.0 ||
        _activeFilters.createdAfter != null ||
        _activeFilters.hasMedia ||
        _activeFilters.isVerified ||
        _activeFilters.isPinned ||
        _activeFilters.isJoined ||
        _selectedTags.isNotEmpty;
  }

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

      // Проверяем наличие новых приглашений
      _checkForNewInvites();
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
      _updateSearchSuggestions(query);
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

  void setHasNewInvites(bool value) {
    _hasNewInvites = value;
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

  void clearSelectedTags() {
    _selectedTags.clear();
    _applyFilters();
    notifyListeners();
  }

  void _updateSearchSuggestions(String query) {
    if (query.length < 2) {
      _searchSuggestions = [];
    } else {
      final queryLower = query.toLowerCase();
      final suggestions = <String>{};

      // Добавляем предложения из названий комнат
      for (final room in _rooms) {
        if (room.title.toLowerCase().contains(queryLower)) {
          suggestions.add(room.title);
        }
      }

      // Добавляем предложения из тегов
      for (final room in _rooms) {
        for (final tag in room.tags) {
          if (tag.toLowerCase().contains(queryLower)) {
            suggestions.add(tag);
          }
        }
      }

      // Добавляем предложения из категорий
      for (final category in RoomCategory.values) {
        if (category.title.toLowerCase().contains(queryLower)) {
          suggestions.add(category.title);
        }
      }

      _searchSuggestions = suggestions.take(8).toList();
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

  // НОВЫЙ МЕТОД: Сброс фильтров для новой комнаты

  void _checkForNewInvites() {
    // Логика проверки новых приглашений
    // В реальном приложении здесь будет запрос к серверу
    final hasInvites = _rooms.any((room) =>
    room.hasPendingInvite ||
        room.accessLevel == RoomAccessLevel.private &&
            room.allowedUsers.contains('current_user_id') // TODO: Заменить на реальный ID
    );

    _hasNewInvites = hasInvites;
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
      // Откатываем изменения в случае ошибки
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

  Future<void> updateRoomRating(String roomId, double newRating) async {
    try {
      final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        // Усреднение рейтинга с учетом предыдущих оценок
        final updatedRating = (room.rating * room.ratingCount + newRating) / (room.ratingCount + 1);
        final updatedRoom = room.copyWith(
          rating: double.parse(updatedRating.toStringAsFixed(1)),
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
        final updatedTags = List<String>.from(room.tags)..add(tag.toLowerCase());
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
        final updatedTags = List<String>.from(room.tags)..remove(tag.toLowerCase());
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

  // ИСПРАВЛЕННЫЙ МЕТОД СОЗДАНИЯ КОМНАТЫ
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
    bool hasMedia = false,
    bool enableVoiceChat = false,
    bool enableVideoChat = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Проверяем, не создается ли уже комната с таким названием
      final existingRoom = _rooms.firstWhereOrNull(
            (room) => room.title == title && room.creatorId == 'current_user_id', // TODO: заменить на реальный ID
      );

      if (existingRoom != null) {
        throw Exception('Комната с таким названием уже существует');
      }

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
        hasMedia: hasMedia,
        enableVoiceChat: enableVoiceChat,
        enableVideoChat: enableVideoChat,
      );

      // ВАЖНО: Добавляем комнату с правильными флагами для фильтров
      final roomWithCorrectFlags = newRoom.copyWith(
        isJoined: true, // Создатель автоматически присоединен к комнате
        lastActivity: DateTime.now(), // Делаем комнату активной
        isActive: true,
      );

      // Добавляем комнату в начало списка
      _rooms.insert(0, roomWithCorrectFlags);

      // Сбрасываем ТОЛЬКО проблемные фильтры
      _resetProblematicFilters();

      // Применяем фильтры и уведомляем
      _applyFilters();
      notifyListeners();

      if (kDebugMode) {
        print('Комната создана: ${roomWithCorrectFlags.title}');
        print('isJoined: ${roomWithCorrectFlags.isJoined}');
        print('isActive: ${roomWithCorrectFlags.isActive}');
        print('Всего комнат: ${_rooms.length}');
        print('Отфильтровано: ${_filteredRooms.length}');
      }

      return roomWithCorrectFlags;

    } catch (error) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }


  void _resetProblematicFilters() {
    // Сбрасываем только фильтры, которые могут скрыть новую комнату
    _showJoinedOnly = false; // Важно: сбрасываем фильтр "только мои"
    _searchQuery = ''; // Очищаем поиск
    _selectedTags.clear(); // Очищаем выбранные теги

    // Сбрасываем проблемные расширенные фильтры
    _activeFilters = _activeFilters.copyWith(
      isJoined: false, // Сбрасываем фильтр "только присоединенные"
    );

    // НЕ сбрасываем категорию - пусть новая комната показывается в выбранной категории
    // НЕ сбрасываем сортировку
    // НЕ сбрасываем другие расширенные фильтры

    if (kDebugMode) {
      print('=== СБРОС ПРОБЛЕМНЫХ ФИЛЬТРОВ ===');
      print('showJoinedOnly: $_showJoinedOnly');
      print('searchQuery: "$_searchQuery"');
      print('selectedTags: $_selectedTags');
      print('activeFilters.isJoined: ${_activeFilters.isJoined}');
    }
  }


  // Поиск и фильтрация
  List<Room> searchRoomsByTag(String tag) {
    return _rooms.where((room) => room.tags.contains(tag.toLowerCase())).toList();
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

  List<Room> getRoomsWithNewInvites() {
    return _rooms.where((room) => room.hasPendingInvite).toList();
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
      'newInvites': _rooms.where((room) => room.hasPendingInvite).length,
      'activeNow': _rooms.where((room) => room.lastActivity.isAfter(
          DateTime.now().subtract(const Duration(minutes: 5))
      )).length,
    };
  }

  // ИСПРАВЛЕННЫЙ МЕТОД ФИЛЬТРАЦИИ
  void _applyFilters() {
    List<Room> filtered = List.from(_rooms);

    if (kDebugMode) {
      print('=== ПРИМЕНЕНИЕ ФИЛЬТРОВ ===');
      print('Всего комнат: ${_rooms.length}');
      print('Категория: ${_selectedCategory.title}');
      print('Поиск: "$_searchQuery"');
      print('Только мои: $_showJoinedOnly');
      print('Только активные: $_showActiveOnly');
      print('Показать закрепленные первыми: $_showPinnedFirst');
      print('Активные фильтры: ${_activeFilters.hasActiveFilters}');
      if (_activeFilters.hasActiveFilters) {
        print('Детали фильтров: $_activeFilters');
      }
    }

    // Базовые фильтры
    if (_selectedCategory != RoomCategory.all) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.category == _selectedCategory).toList();
      if (kDebugMode) print('После категории: $before -> ${filtered.length}');
    }

    if (_searchQuery.isNotEmpty) {
      final before = filtered.length;
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((room) =>
      room.title.toLowerCase().contains(query) ||
          room.description.toLowerCase().contains(query) ||
          room.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          room.creatorName.toLowerCase().contains(query) ||
          room.category.title.toLowerCase().contains(query)
      ).toList();
      if (kDebugMode) print('После поиска: $before -> ${filtered.length}');
    }

    if (_showJoinedOnly) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.isJoined).toList();
      if (kDebugMode) print('После "только мои": $before -> ${filtered.length}');

      // Отладочная информация о joined статусе
      if (kDebugMode && before != filtered.length) {
        final joinedRooms = _rooms.where((room) => room.isJoined).toList();
        print('Всего присоединенных комнат: ${joinedRooms.length}');
        for (final room in joinedRooms.take(3)) {
          print(' - "${room.title}" (joined: ${room.isJoined}, active: ${room.isActive})');
        }
      }
    }

    if (_showActiveOnly) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.isActive && !room.isExpired).toList();
      if (kDebugMode) print('После "только активные": $before -> ${filtered.length}');
    }

    // Расширенные фильтры из RoomFilters
    if (_activeFilters.tags.isNotEmpty) {
      final before = filtered.length;
      filtered = filtered.where((room) =>
          _activeFilters.tags.any((tag) => room.tags.contains(tag))
      ).toList();
      if (kDebugMode) print('После фильтра по тегам: $before -> ${filtered.length}');
    }

    if (_activeFilters.minParticipants > 0) {
      final before = filtered.length;
      filtered = filtered.where((room) =>
      room.currentParticipants >= _activeFilters.minParticipants
      ).toList();
      if (kDebugMode) print('После мин. участников: $before -> ${filtered.length}');
    }

    if (_activeFilters.maxParticipants < 1000) {
      final before = filtered.length;
      filtered = filtered.where((room) =>
      room.currentParticipants <= _activeFilters.maxParticipants
      ).toList();
      if (kDebugMode) print('После макс. участников: $before -> ${filtered.length}');
    }

    if (_activeFilters.minRating > 0.0) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.rating >= _activeFilters.minRating).toList();
      if (kDebugMode) print('После мин. рейтинга: $before -> ${filtered.length}');
    }

    if (_activeFilters.createdAfter != null) {
      final before = filtered.length;
      filtered = filtered.where((room) =>
          room.createdAt.isAfter(_activeFilters.createdAfter!)
      ).toList();
      if (kDebugMode) print('После даты создания: $before -> ${filtered.length}');
    }

    if (_activeFilters.hasMedia) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.hasMedia).toList();
      if (kDebugMode) print('После медиа-фильтра: $before -> ${filtered.length}');
    }

    if (_activeFilters.isVerified) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.isVerified).toList();
      if (kDebugMode) print('После верификации: $before -> ${filtered.length}');
    }

    if (_activeFilters.isPinned) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.isPinned).toList();
      if (kDebugMode) print('После закрепленных: $before -> ${filtered.length}');
    }

    if (_activeFilters.isJoined) {
      final before = filtered.length;
      filtered = filtered.where((room) => room.isJoined).toList();
      if (kDebugMode) print('После присоединенных: $before -> ${filtered.length}');
    }

    // Фильтр по выбранным тегам
    if (_selectedTags.isNotEmpty) {
      final before = filtered.length;
      filtered = filtered.where((room) =>
          _selectedTags.any((tag) => room.tags.contains(tag))
      ).toList();
      if (kDebugMode) print('После выбранных тегов: $before -> ${filtered.length}');
    }

    // Сортировка
    filtered = _sortRooms(filtered);

    // Закрепленные комнаты в начале
    if (_showPinnedFirst) {
      final pinnedRooms = filtered.where((room) => room.isPinned).toList();
      final unpinnedRooms = filtered.where((room) => !room.isPinned).toList();
      filtered = [...pinnedRooms, ...unpinnedRooms];
      if (kDebugMode) print('После закрепления: ${pinnedRooms.length} закрепленных + ${unpinnedRooms.length} обычных');
    }

    _filteredRooms = filtered;

    if (kDebugMode) {
      print('Итоговое количество: ${_filteredRooms.length}');
      if (_filteredRooms.isNotEmpty) {
        print('Первые 3 комнаты в результате:');
        for (final room in _filteredRooms.take(3)) {
          print(' - "${room.title}" (joined: ${room.isJoined}, active: ${room.isActive}, participants: ${room.currentParticipants})');
        }
      } else {
        print('⚠️ Нет комнат после фильтрации!');
        print('Последние 3 комнаты в исходном списке:');
        for (final room in _rooms.take(3)) {
          print(' - "${room.title}" (joined: ${room.isJoined}, active: ${room.isActive}, category: ${room.category.title})');
        }
      }
      print('========================');
    }
  }

  List<Room> _sortRooms(List<Room> rooms) {
    final sortedRooms = List<Room>.from(rooms);

    switch (_sortBy) {
      case RoomSortBy.recent:
        sortedRooms.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
        break;
      case RoomSortBy.popular:
        sortedRooms.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case RoomSortBy.participants:
        sortedRooms.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
        break;
      case RoomSortBy.messages:
        sortedRooms.sort((a, b) => b.messageCount.compareTo(a.messageCount));
        break;
      case RoomSortBy.rating:
        sortedRooms.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case RoomSortBy.scheduled:
        sortedRooms.sort((a, b) {
          final aStart = a.scheduledStart ?? DateTime(2100);
          final bStart = b.scheduledStart ?? DateTime(2100);
          return aStart.compareTo(bStart);
        });
        break;
      case RoomSortBy.activity:
        sortedRooms.sort((a, b) => b.activityLevel.compareTo(a.activityLevel));
        break;
      case RoomSortBy.newest:
        sortedRooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sortedRooms;
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

  // Получение комнат по уровню активности
  List<Room> getRoomsByActivityLevel(double minActivityLevel) {
    return _rooms.where((room) => room.activityLevel >= minActivityLevel).toList();
  }

  // Обновление активности комнаты
  void updateRoomActivity(String roomId) {
    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      final room = _rooms[roomIndex];
      final updatedRoom = room.copyWith(lastActivity: DateTime.now());
      _rooms[roomIndex] = updatedRoom;
      _applyFilters();
      notifyListeners();
    }
  }

  void addRoomLocally(Room newRoom) {
    _rooms.insert(0, newRoom); // Добавляем в начало
    notifyListeners();
  }

  // Сброс фильтров (старый метод для обратной совместимости)
  void resetFilters() {
    resetAllFilters();
  }
}