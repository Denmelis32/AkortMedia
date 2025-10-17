import 'dart:async';
import 'dart:math';
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
  final Random _random = Random();

  // Состояние чата
  ChatRoom? _currentRoom;
  final List<ChatMessage> _messages = [];
  PaginationState _paginationState = const PaginationState();
  bool _isLoading = false;
  String? _error;
  final Set<String> _typingUsers = {};
  Timer? _typingTimer;

  // Поиск
  final List<ChatMessage> _searchResults = [];
  bool _isSearching = false;
  String? _searchQuery;

  // Кэшированные данные
  final Map<String, List<ChatMessage>> _roomMessagesCache = {};
  final Map<String, ChatRoom> _roomsCache = {};

  // Потоковые обновления
  final StreamController<ChatMessage> _messageStreamController =
  StreamController<ChatMessage>.broadcast();
  final StreamController<List<String>> _typingStreamController =
  StreamController<List<String>>.broadcast();

  // Состояние прокрутки
  bool _isNearBottom = true;

  ChatController({
    required ChatApiService apiService,
    required ChatCacheManager cacheManager,
  })  : _apiService = apiService,
        _cacheManager = cacheManager;

  // === ГЕТТЕРЫ ===
  ChatRoom? get currentRoom => _currentRoom;
  List<ChatMessage> get messages => _messages;
  List<ChatMessage> get visibleMessages => _messages;
  PaginationState get paginationState => _paginationState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get typingUsers => _typingUsers.toList();
  bool get isTyping => _typingUsers.isNotEmpty;
  bool get isNearBottom => _isNearBottom;

  // Поиск
  List<ChatMessage> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchQuery => _searchQuery;

  // Потоки
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;
  Stream<List<String>> get typingStream => _typingStreamController.stream;

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
          _sortMessages();
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

      // Показываем кэшированные данные даже при ошибке
      final cachedMessages = await _cacheManager.getMessages(roomId);
      if (cachedMessages != null && cachedMessages.isNotEmpty) {
        _messages.clear();
        _messages.addAll(cachedMessages);
        _sortMessages();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Загрузка начальных сообщений (упрощенная версия)
  Future<void> loadInitialMessages(String roomId) async {
    try {
      await _loadMessages(
        roomId: roomId,
        page: 1,
        isInitialLoad: true,
      );
    } catch (e) {
      debugPrint('ChatController.loadInitialMessages error: $e');
    }
  }

  // Пагинация - загрузка истории
  Future<void> loadMoreMessages() async {
    if (!_paginationState.canLoadMore || _currentRoom == null || _paginationState.isLoading) {
      return;
    }

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
      notifyListeners();
    }
  }

  // Отправка сообщения
  Future<void> sendMessage(String text, {ChatMessage? replyTo}) async {
    if (_currentRoom == null || text.trim().isEmpty) return;

    // Останавливаем индикатор печати
    stopTyping();

    final message = ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      author: _currentUser,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      replyTo: replyTo,
    );

    // Оптимистичное обновление UI
    _addMessage(message);
    _scrollToBottom();

    try {
      // Отправка на сервер
      final sentMessage = await _apiService.sendMessage(
        roomId: _currentRoom!.id,
        text: text.trim(),
        replyToId: replyTo?.id,
      );

      // Заменяем временное сообщение на настоящее
      _replaceMessage(message.id, sentMessage);

      // Обновляем кэш
      await _cacheManager.saveMessage(_currentRoom!.id, sentMessage);
      await _cacheManager.updateRoomLastMessage(_currentRoom!.id, sentMessage);

      // Уведомляем через поток
      _messageStreamController.add(sentMessage);

    } catch (e) {
      // Помечаем сообщение как неудачное
      _updateMessageStatus(message.id, MessageStatus.failed);
      _error = 'Ошибка отправки сообщения';
      debugPrint('ChatController.sendMessage error: $e');
    }
  }

  // Редактирование сообщения
  Future<void> editMessage(String messageId, String newText) async {
    if (newText.trim().isEmpty) return;

    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final originalMessage = _messages[messageIndex];
    final updatedMessage = originalMessage.copyWith(text: newText.trim());

    // Оптимистичное обновление
    _messages[messageIndex] = updatedMessage;
    notifyListeners();

    try {
      final result = await _apiService.editMessage(
        messageId: messageId,
        newText: newText.trim(),
      );

      _messages[messageIndex] = result;
      await _cacheManager.saveMessage(_currentRoom!.id, result);

    } catch (e) {
      // Откатываем изменения
      _messages[messageIndex] = originalMessage;
      _error = 'Ошибка редактирования сообщения';
      debugPrint('ChatController.editMessage error: $e');
    } finally {
      notifyListeners();
    }
  }

  // Удаление сообщения
  Future<void> deleteMessage(String messageId) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];

    // Оптимистичное удаление
    _messages.removeAt(messageIndex);
    notifyListeners();

    try {
      await _apiService.deleteMessage(messageId);
      await _cacheManager.deleteMessage(_currentRoom!.id, messageId);
    } catch (e) {
      // Восстанавливаем сообщение при ошибке
      _messages.insert(messageIndex, message);
      _error = 'Ошибка удаления сообщения';
      debugPrint('ChatController.deleteMessage error: $e');
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
    List<Reaction> updatedReactions;

    if (existingReactionIndex != -1) {
      // Удаляем существующую реакцию
      updatedReactions = List<Reaction>.from(message.reactions);
      updatedReactions.removeAt(existingReactionIndex);
    } else {
      // Добавляем новую реакцию
      final newReaction = Reaction(
        emoji: emoji,
        user: _currentUser,
        timestamp: DateTime.now(),
      );
      updatedReactions = [...message.reactions, newReaction];
    }

    _messages[messageIndex] = message.copyWith(reactions: updatedReactions);
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

      // Обновляем кэш
      await _cacheManager.saveMessage(_currentRoom!.id, _messages[messageIndex]);
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

    // Отменяем предыдущий таймер
    _typingTimer?.cancel();

    // Добавляем пользователя в список печатающих
    if (!_typingUsers.contains(_currentUser.id)) {
      _typingUsers.add(_currentUser.id);
      _notifyTypingUpdate();
    }

    // Устанавливаем таймер для автоматической остановки
    _typingTimer = Timer(const Duration(seconds: 3), stopTyping);

    // Отправляем индикатор на сервер
    _apiService.sendTypingIndicator(
      roomId: _currentRoom!.id,
      isTyping: true,
    );
  }

  void stopTyping() {
    if (_currentRoom == null) return;

    _typingTimer?.cancel();

    if (_typingUsers.contains(_currentUser.id)) {
      _typingUsers.remove(_currentUser.id);
      _notifyTypingUpdate();
    }

    _apiService.sendTypingIndicator(
      roomId: _currentRoom!.id,
      isTyping: false,
    );
  }

  // === УПРАВЛЕНИЕ ПРОКРУТКОЙ ===

  void updateScrollPosition(double scrollOffset, double maxScrollExtent) {
    final wasNearBottom = _isNearBottom;
    _isNearBottom = scrollOffset >= maxScrollExtent - 100;

    if (wasNearBottom != _isNearBottom) {
      notifyListeners();
    }
  }

  void _scrollToBottom() {
    _isNearBottom = true;
    notifyListeners();
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

      _sortMessages();

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

  void _sortMessages() {
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _addMessage(ChatMessage message) {
    _messages.insert(0, message);
    _sortMessages();
    notifyListeners();
  }

  void _replaceMessage(String oldId, ChatMessage newMessage) {
    final index = _messages.indexWhere((m) => m.id == oldId);
    if (index != -1) {
      _messages[index] = newMessage;
      notifyListeners();
    }
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void _notifyTypingUpdate() {
    notifyListeners();
    _typingStreamController.add(_typingUsers.toList());
  }

  void _subscribeToRoomUpdates(String roomId) {
    // Здесь будет подписка на WebSocket/Socket.io
    // Пока просто симулируем получение сообщений
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_messages.isNotEmpty && _currentRoom != null) {
        // Берем случайного пользователя из участников комнаты (исключая текущего)
        final participants = _currentRoom!.participants
            .where((user) => user.id != 'current-user')
            .toList();

        if (participants.isNotEmpty) {
          final randomUser = participants[_random.nextInt(participants.length)];
          final randomMessages = [
            'Только что закончил работу над этим!',
            'Отличная идея! Поддерживаю',
            'Может стоит добавить валидацию?',
            'Проверил - всё работает отлично 🎉',
            'Интересная мысль, нужно обдумать',
            'Согласен с этим предложением',
            'Может обсудим это на созвоне?',
            'Отличный прогресс! 🚀',
          ];

          final newMessage = ChatMessage(
            id: 'incoming-${DateTime.now().millisecondsSinceEpoch}',
            text: randomMessages[_random.nextInt(randomMessages.length)],
            author: randomUser, // Используем существующего пользователя
            timestamp: DateTime.now(),
            status: MessageStatus.delivered,
          );

          _addMessage(newMessage);
          _messageStreamController.add(newMessage);

          // Автоматически помечаем как прочитанное через 2 секунды
          Timer(const Duration(seconds: 2), () {
            _updateMessageStatus(newMessage.id, MessageStatus.read);
          });
        }
      }
    });
  }

  // Текущий пользователь
  ChatUser get _currentUser => ChatUser(
    id: 'current-user',
    name: 'Вы',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    isOnline: true,
  );

  // Очистка ресурсов
  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageStreamController.close();
    _typingStreamController.close();
    stopTyping();
    super.dispose();
  }
}