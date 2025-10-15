import 'package:flutter/foundation.dart';
import 'models/chat_message.dart';
import 'models/chat_room.dart';
import 'models/chat_user.dart';
import 'models/message_status.dart';
import 'models/pagination_state.dart';
import 'models/reaction.dart';
import 'services/chat_api_service.dart';
import 'cache/chat_cache_manager.dart';

class ChatController with ChangeNotifier {
  final ChatApiService _apiService;
  final ChatCacheManager _cacheManager;

  // Состояние чата
  ChatRoom? _currentRoom;
  final List<ChatMessage> _messages = [];
  PaginationState _paginationState = const PaginationState();
  bool _isLoading = false;
  String? _error;
  final Set<String> _typingUsers = {};

  // Поиск
  final List<ChatMessage> _searchResults = [];
  bool _isSearching = false;
  String? _searchQuery;

  // Кэшированные данные
  final Map<String, List<ChatMessage>> _roomMessagesCache = {};
  final Map<String, ChatRoom> _roomsCache = {};

  ChatController({
    required ChatApiService apiService,
    required ChatCacheManager cacheManager,
  })  : _apiService = apiService,
        _cacheManager = cacheManager;

  // === ГЕТТЕРЫ ===
  ChatRoom? get currentRoom => _currentRoom;
  List<ChatMessage> get messages => _messages;
  List<ChatMessage> get visibleMessages =>
      _messages.where((msg) => !msg.isExpired).toList();
  PaginationState get paginationState => _paginationState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get typingUsers => _typingUsers.toList();
  bool get isTyping => _typingUsers.isNotEmpty;

  // Поиск
  List<ChatMessage> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchQuery => _searchQuery;

  // === ОСНОВНЫЕ МЕТОДЫ ЧАТА ===

  // Загрузка комнаты и сообщений
  Future<void> loadRoom(String roomId, {bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Загружаем комнату
      if (forceRefresh || !_roomsCache.containsKey(roomId)) {
        _currentRoom = await _apiService.getRoom(roomId);
        _roomsCache[roomId] = _currentRoom!;
        await _cacheManager.saveRoom(_currentRoom!);
      } else {
        _currentRoom = _roomsCache[roomId];
      }

      // 2. Загружаем сообщения (сначала из кэша)
      if (!forceRefresh) {
        final cachedMessages = await _cacheManager.getMessages(roomId);
        if (cachedMessages != null && cachedMessages.isNotEmpty) {
          _messages.clear();
          _messages.addAll(cachedMessages);
          notifyListeners();
        }
      }



      // 3. Загружаем свежие сообщения
      await _loadMessages(
        roomId: roomId,
        page: 1,
        isInitialLoad: true,
      );

      // 4. Подписываемся на обновления в реальном времени
      _subscribeToRoomUpdates(roomId);

    } catch (e) {
      _error = 'Ошибка загрузки чата: ${e.toString()}';
      debugPrint('ChatController.loadRoom error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Пагинация - загрузка истории
  Future<void> loadMoreMessages() async {
    if (!_paginationState.canLoadMore || _currentRoom == null) return;

    try {
      _paginationState = _paginationState.copyWith(isLoading: true);
      notifyListeners();

      await _loadMessages(
        roomId: _currentRoom!.id,
        page: _paginationState.currentPage + 1,
      );

    } catch (e) {
      _paginationState = _paginationState.copyWith(error: e.toString());
      debugPrint('ChatController.loadMoreMessages error: $e');
    } finally {
      notifyListeners();
    }
  }

  // Отправка сообщения
  Future<void> sendMessage(String text, {ChatMessage? replyTo}) async {
    if (_currentRoom == null || text.trim().isEmpty) return;

    final message = ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      author: _currentUser, // Предполагаем, что текущий пользователь известен
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      replyTo: replyTo,
    );

    // Оптимистичное обновление UI
    _messages.insert(0, message);
    notifyListeners();

    try {
      // Отправка на сервер
      final sentMessage = await _apiService.sendMessage(
        roomId: _currentRoom!.id,
        text: text.trim(),
        replyToId: replyTo?.id,
      );

      // Заменяем временное сообщение на настоящее
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = sentMessage;
      }

      // Обновляем кэш
      await _cacheManager.saveMessage(_currentRoom!.id, sentMessage);
      await _cacheManager.updateRoomLastMessage(_currentRoom!.id, sentMessage);

    } catch (e) {
      // Помечаем сообщение как неудачное
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = message.copyWith(status: MessageStatus.failed);
      }
      _error = 'Ошибка отправки сообщения';
      debugPrint('ChatController.sendMessage error: $e');
    } finally {
      notifyListeners();
    }
  }

  // Добавление реакции
  Future<void> addReaction(String messageId, String emoji) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];
    final existingReactionIndex = message.reactions
        .indexWhere((r) => r.emoji == emoji && r.user.id == _currentUser.id);

    // Оптимистичное обновление
    if (existingReactionIndex != -1) {
      // Удаляем существующую реакцию
      final updatedReactions = List<Reaction>.from(message.reactions);
      updatedReactions.removeAt(existingReactionIndex);
      _messages[messageIndex] = message.copyWith(reactions: updatedReactions);
    } else {
      // Добавляем новую реакцию
      final newReaction = Reaction(
        emoji: emoji,
        user: _currentUser,
        timestamp: DateTime.now(),
      );
      final updatedReactions = [...message.reactions, newReaction];
      _messages[messageIndex] = message.copyWith(reactions: updatedReactions);
    }

    notifyListeners();

    try {
      await _apiService.toggleReaction(
        messageId: messageId,
        emoji: emoji,
      );
    } catch (e) {
      // Откатываем изменения при ошибке
      _messages[messageIndex] = message;
      notifyListeners();
      debugPrint('ChatController.addReaction error: $e');
    }
  }

  // Закрепление сообщения
  Future<void> togglePinMessage(String messageId) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];
    final newPinnedState = !message.isPinned;

    // Оптимистичное обновление
    _messages[messageIndex] = message.copyWith(isPinned: newPinnedState);
    notifyListeners();

    try {
      await _apiService.pinMessage(
        messageId: messageId,
        pinned: newPinnedState,
      );
    } catch (e) {
      // Откатываем при ошибке
      _messages[messageIndex] = message;
      notifyListeners();
      debugPrint('ChatController.togglePinMessage error: $e');
    }
  }

  // === ПОИСК ===

  Future<void> searchMessages(String query) async {
    if (query.trim().isEmpty || _currentRoom == null) return;

    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      final results = await _apiService.searchMessages(
        roomId: _currentRoom!.id,
        query: query,
      );

      _searchResults.clear();
      _searchResults.addAll(results);

    } catch (e) {
      _error = 'Ошибка поиска: ${e.toString()}';
      debugPrint('ChatController.searchMessages error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _isSearching = false;
    _searchQuery = null;
    _searchResults.clear();
    notifyListeners();
  }

  // === ТИПИНГ (набор текста) ===

  void startTyping() {
    if (_currentRoom == null) return;

    _typingUsers.add(_currentUser.id);
    notifyListeners();

    _apiService.sendTypingIndicator(
      roomId: _currentRoom!.id,
      isTyping: true,
    );
  }

  void stopTyping() {
    if (_currentRoom == null) return;

    _typingUsers.remove(_currentUser.id);
    notifyListeners();

    _apiService.sendTypingIndicator(
      roomId: _currentRoom!.id,
      isTyping: false,
    );
  }

  // === ПРИВАТНЫЕ МЕТОДЫ ===

  Future<void> _loadMessages({
    required String roomId,
    required int page,
    bool isInitialLoad = false,
  }) async {
    try {
      final response = await _apiService.getMessages(
        roomId: roomId,
        page: page,
        limit: _paginationState.itemsPerPage,
      );

      if (isInitialLoad) {
        _messages.clear();
      }

      // Добавляем сообщения, избегая дубликатов
      for (final message in response.messages) {
        if (!_messages.any((m) => m.id == message.id)) {
          _messages.add(message);
        }
      }

      // Сортируем по времени (новые сверху)
      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Обновляем состояние пагинации
      _paginationState = _paginationState.copyWith(
        currentPage: page,
        hasMore: response.hasMore,
        totalItems: response.totalCount,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // Кэшируем сообщения
      await _cacheManager.saveMessages(roomId, _messages);

    } catch (e) {
      _paginationState = _paginationState.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void _subscribeToRoomUpdates(String roomId) {
    // Здесь будет подписка на WebSocket/Socket.io
    // для получения сообщений в реальном времени
  }

  // Временное решение - предполагаем, что текущий пользователь известен
  ChatUser get _currentUser => ChatUser(
    id: 'current-user',
    name: 'Текущий пользователь',
    isOnline: true,
  );

  // Очистка ресурсов
  @override
  void dispose() {
    // Отписываемся от сокетов и т.д.
    super.dispose();
  }
}