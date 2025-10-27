import 'dart:async';
import 'dart:math';

import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/chat_user.dart';
import '../models/message_status.dart';
import '../models/pagination_response.dart';
import '../models/reaction.dart';
import 'chat_api_service.dart';

class AdvancedMockChatService implements ChatApiService {
  final List<ChatMessage> _mockMessages = [];
  final List<ChatUser> _mockUsers = [];
  final Map<String, Timer> _typingTimers = {};
  final Random _random = Random();

  // Текущий пользователь
  late ChatUser _currentUser;

  // Для индикатора печатания
  final Set<String> _typingUsers = {};
  final StreamController<List<String>> _typingStreamController =
  StreamController<List<String>>.broadcast();

  // Для потоковых сообщений
  final StreamController<ChatMessage> _messageStreamController =
  StreamController<ChatMessage>.broadcast();

  @override
  final Duration timeout = const Duration(seconds: 30);

  AdvancedMockChatService() {
    _initializeMockData();
    _startSimulatedActivity();
  }

  void _initializeMockData() {
    // Создаем текущего пользователя
    _currentUser = ChatUser(
      id: 'current-user',
      name: 'Вы',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      isOnline: true,
    );

    // Создаем тестовых пользователей с разными статусами
    _mockUsers.addAll([
      ChatUser(
        id: 'user1',
        name: 'Алексей Петров',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
      ),
      ChatUser(
        id: 'user2',
        name: 'Мария Иванова',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        isOnline: false,
      ),
      ChatUser(
        id: 'user3',
        name: 'Дмитрий Сидоров',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        isOnline: true,
      ),
    ]);

    // Создаем реалистичную историю сообщений
    final now = DateTime.now();

    _mockMessages.addAll([
      ChatMessage(
        id: '1',
        text: 'Привет всем! Как успехи с новой архитектурой?',
        author: _mockUsers[0],
        timestamp: now.subtract(const Duration(hours: 3)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '2',
        text: 'Всё отлично! Завершил работу над модулем аутентификации',
        author: _mockUsers[1],
        timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        text: 'Отлично! У меня тоже хороший прогресс. UI компоненты почти готовы',
        author: _currentUser,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        status: MessageStatus.read,
      ),
    ]);
  }

  void _startSimulatedActivity() {
    void scheduleNext() {
      // Случайный интервал от 10 до 15 секунд
      final nextDelay = Duration(seconds: 10 + _random.nextInt(6));
      Timer(nextDelay, () {
        // 75% шанс нового сообщения
        if (_random.nextDouble() < 0.75) {
          _simulateTypingThenMessage();
        } else {
          scheduleNext(); // Планируем следующее событие
        }
      });
    }

    scheduleNext(); // Запускаем цикл
  }

  void _simulateTypingThenMessage() {
    final randomUser = _mockUsers[_random.nextInt(_mockUsers.length)];

    // Показываем индикатор печати
    _showTypingIndicator(randomUser);

    // Через 5 секунд отправляем сообщение и скрываем индикатор
    Timer(const Duration(seconds: 5), () {
      _hideTypingIndicator(randomUser);
      _sendIncomingMessage(randomUser);
    });

    // Планируем следующее событие через 6 секунд (после отправки сообщения)
    Timer(const Duration(seconds: 6), () {
      _startSimulatedActivity();
    });
  }

  void _showTypingIndicator(ChatUser user) {
    // Добавляем пользователя в список печатающих
    if (!_typingUsers.contains(user.id)) {
      _typingUsers.add(user.id);
      _notifyTypingUpdate();
    }
  }

  void _hideTypingIndicator(ChatUser user) {
    // Убираем пользователя из списка печатающих
    if (_typingUsers.contains(user.id)) {
      _typingUsers.remove(user.id);
      _notifyTypingUpdate();
    }
  }

  void _sendIncomingMessage(ChatUser user) {
    final responses = [
      'Только что закончил работу над этим функционалом!',
      'Отличная идея! Полностью поддерживаю',
      'Может стоит добавить валидацию на стороне клиента?',
      'Проверил на тестовом стенде - всё работает идеально 🎉',
      'Есть небольшое предложение по улучшению UX',
      'Кто-то уже тестировал это на мобильных устройствах?',
      'Нашёл интересную библиотеку, которая может упростить реализацию',
      'Завтра планирую релиз новой версии',
      'Нужна помощь с деплоем? Могу подключиться',
      'Отлично смотрится! Особенно понравился новый интерфейс',
      'А что если попробовать другой подход?',
      'Согласен с предыдущим комментарием 👍',
      'Есть вопросы по API? Могу помочь',
      'Посмотрел логи - всё работает стабильно',
      'Может добавить темную тему? 👀',
    ];

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responses[_random.nextInt(responses.length)],
      author: user,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    );

    _mockMessages.add(newMessage);
    _messageStreamController.add(newMessage);

    // Помечаем как прочитанное через 2-4 секунды
    Timer(Duration(seconds: 2 + _random.nextInt(3)), () {
      final index = _mockMessages.indexWhere((msg) => msg.id == newMessage.id);
      if (index != -1) {
        _mockMessages[index] = _mockMessages[index].copyWith(status: MessageStatus.read);
        _messageStreamController.add(_mockMessages[index]);
      }
    });
  }

  void _notifyTypingUpdate() {
    _typingStreamController.add(_typingUsers.toList());
  }

  // Геттер для потока печатающих пользователей
  Stream<List<String>> get typingStream => _typingStreamController.stream;

  // Геттер для потока сообщений
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  // === ОСНОВНЫЕ МЕТОДЫ API ===

  @override
  String get baseUrl => 'mock://localhost';

  @override
  String get authToken => 'mock-token';

  @override
  Future<ChatRoom> getRoom(String roomId) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(400)));

    final participants = [..._mockUsers, _currentUser];
    final lastMessage = _mockMessages.isNotEmpty ? _mockMessages.last : null;

    return ChatRoom(
      id: roomId,
      name: 'Команда разработки',
      participants: participants,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isGroup: true,
      createdBy: participants.first,
      lastMessage: lastMessage,
    );
  }

  @override
  Future<PaginationResponse<ChatMessage>> getMessages({
    required String roomId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    List<ChatMessage> paginatedMessages = [];

    if (startIndex < _mockMessages.length) {
      final reversedMessages = _mockMessages.reversed.toList();
      paginatedMessages = reversedMessages.sublist(
        startIndex,
        endIndex > _mockMessages.length ? _mockMessages.length : endIndex,
      );
    }

    return PaginationResponse(
      messages: paginatedMessages,
      currentPage: page,
      totalPages: (_mockMessages.length / limit).ceil(),
      totalCount: _mockMessages.length,
      hasMore: endIndex < _mockMessages.length,
    );
  }

  @override
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String text,
    String? replyToId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: _currentUser,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      replyTo: replyToId != null
          ? _mockMessages.firstWhere(
              (msg) => msg.id == replyToId,
          orElse: () => _mockMessages.first
      )
          : null,
    );

    _mockMessages.add(newMessage);
    _messageStreamController.add(newMessage);

    // Реалистичная последовательность статусов
    Timer(const Duration(seconds: 1), () {
      final index = _mockMessages.indexWhere((msg) => msg.id == newMessage.id);
      if (index != -1) {
        _mockMessages[index] = _mockMessages[index].copyWith(status: MessageStatus.delivered);
        _messageStreamController.add(_mockMessages[index]);
      }
    });

    Timer(const Duration(seconds: 3), () {
      final index = _mockMessages.indexWhere((msg) => msg.id == newMessage.id);
      if (index != -1) {
        _mockMessages[index] = _mockMessages[index].copyWith(status: MessageStatus.read);
        _messageStreamController.add(_mockMessages[index]);
      }
    });

    return newMessage;
  }

  @override
  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockMessages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = _mockMessages[index];
      final existingReactionIndex = message.reactions
          .indexWhere((r) => r.emoji == emoji && r.user.id == _currentUser.id);

      List<Reaction> updatedReactions;

      if (existingReactionIndex != -1) {
        updatedReactions = List<Reaction>.from(message.reactions);
        updatedReactions.removeAt(existingReactionIndex);
      } else {
        updatedReactions = [
          ...message.reactions,
          Reaction(
            emoji: emoji,
            user: _currentUser,
            timestamp: DateTime.now(),
          ),
        ];
      }

      _mockMessages[index] = message.copyWith(reactions: updatedReactions);
      _messageStreamController.add(_mockMessages[index]);
    }
  }

  @override
  Future<void> pinMessage({
    required String messageId,
    required bool pinned,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _mockMessages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final updatedMessage = _mockMessages[index].copyWith(isPinned: pinned);
      _mockMessages[index] = updatedMessage;
      _messageStreamController.add(updatedMessage);
    }
  }

  @override
  Future<List<ChatMessage>> searchMessages({
    required String roomId,
    required String query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final searchTerm = query.toLowerCase();
    return _mockMessages.where((message) {
      return message.text.toLowerCase().contains(searchTerm) ||
          message.author.name.toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  Future<void> sendTypingIndicator({
    required String roomId,
    required bool isTyping,
  }) async {
    if (isTyping) {
      _typingTimers[roomId]?.cancel();
      _typingTimers[roomId] = Timer(const Duration(seconds: 3), () {
        // Автоматически останавливаем печатание через 3 секунды
        _typingTimers.remove(roomId);
      });
    } else {
      _typingTimers[roomId]?.cancel();
      _typingTimers.remove(roomId);
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockMessages.removeWhere((msg) => msg.id == messageId);
  }

  @override
  Future<ChatMessage> editMessage({
    required String messageId,
    required String newText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _mockMessages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final updatedMessage = _mockMessages[index].copyWith(text: newText);
      _mockMessages[index] = updatedMessage;
      _messageStreamController.add(updatedMessage);
      return updatedMessage;
    }

    throw Exception('Message not found');
  }

  // Очистка ресурсов
  void dispose() {
    _typingTimers.forEach((_, timer) => timer.cancel());
    _typingTimers.clear();
    _typingStreamController.close();
    _messageStreamController.close();
  }
}