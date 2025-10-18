import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_controller.dart';
import 'custom_app_bar.dart';
import 'services/chat_api_service.dart';
import 'cache/chat_cache_manager.dart';
import 'widgets/message_list.dart';
import 'widgets/chat_input.dart';
import 'widgets/reaction_menu.dart';
import 'models/chat_message.dart';
import 'models/chat_room.dart';
import 'models/chat_user.dart';
import 'models/message_status.dart';
import 'models/pagination_response.dart';
import 'models/reaction.dart';

// Улучшенный мок с реалистичным поведением
class AdvancedMockChatService implements ChatApiService {
  final List<ChatMessage> _mockMessages = [];
  final List<ChatUser> _mockUsers = [];
  final Map<String, Timer> _typingTimers = {};
  final Random _random = Random();
  late ChatUser _currentUser;

  @override
  final Duration timeout = const Duration(seconds: 30);

  AdvancedMockChatService() {
    _initializeMockData();
    _startSimulatedActivity();
  }

  void _initializeMockData() {
    // Текущий пользователь
    _currentUser = ChatUser(
      id: 'current-user',
      name: 'Вы',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      isOnline: true,
      lastSeen: DateTime.now(),
    );

    // Тестовые пользователи
    _mockUsers.addAll([
      ChatUser(
        id: 'user1',
        name: 'Алексей Петров',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
        lastSeen: DateTime.now(),
        status: 'Ищу цветы 🌸',
      ),
      ChatUser(
        id: 'user2',
        name: 'Мария Иванова',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 3)),
        status: 'В цветочном магазине',
      ),
      ChatUser(
        id: 'user3',
        name: 'Дмитрий Сидоров',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        isOnline: true,
        lastSeen: DateTime.now(),
        status: 'Заказываю букет',
      ),
    ]);

    // Переписка про подарок с акцентом на цветы
    final now = DateTime.now();
    _mockMessages.addAll([
      ChatMessage(
        id: '1',
        text: 'Денис, ты приготовил уже подарок Насте?',
        author: _mockUsers[0],
        timestamp: now.subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
        reactions: [
          Reaction(
            emoji: '😱',
            user: _mockUsers[2],
            timestamp: now.subtract(const Duration(minutes: 40)),
          ),
        ],
      ),
      ChatMessage(
        id: '2',
        text: 'Что?! Завтра?! Я думал через неделю! Я совсем забыли про др 😅',
        author: _currentUser,
        timestamp: now.subtract(const Duration(minutes: 40)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        text: 'Ты как обычно:D',
        author: _mockUsers[2],
        timestamp: now.subtract(const Duration(minutes: 35)),
        status: MessageStatus.read,
        reactions: [
          Reaction(
            emoji: '🌸',
            user: _mockUsers[1],
            timestamp: now.subtract(const Duration(minutes: 33)),
          ),
        ],
      ),
      ChatMessage(
        id: '4',
        text: 'Ты правда забыл про подарок?',
        author: _mockUsers[1],
        timestamp: now.subtract(const Duration(minutes: 32)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '5',
        text: 'Или ты пошутил?',
        author: _mockUsers[0],
        timestamp: now.subtract(const Duration(minutes: 28)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '6',
        text: 'Правда интересно?',
        author: _mockUsers[2],
        timestamp: now.subtract(const Duration(minutes: 25)),
        status: MessageStatus.read,
        reactions: [
          Reaction(
            emoji: '❤️',
            user: _currentUser,
            timestamp: now.subtract(const Duration(minutes: 23)),
          ),
        ],
      ),
      ChatMessage(
        id: '7',
        text: 'Нет, конечно. :D Я себе даже напоминание в приложение в своем сделал',
        author: _currentUser,
        timestamp: now.subtract(const Duration(minutes: 22)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '8',
        text: 'АХАХХАХАХАХАХ',
        author: _mockUsers[1],
        timestamp: now.subtract(const Duration(minutes: 18)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '9',
        text: 'Типичный Маринцев',
        author: _mockUsers[0],
        timestamp: now.subtract(const Duration(minutes: 15)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '10',
        text: ':D я не специально, оно само так выходит, что я как обычно перемудряю',
        author: _currentUser,
        timestamp: now.subtract(const Duration(minutes: 10)),
        status: MessageStatus.read,
        reactions: [
          Reaction(
            emoji: '✅',
            user: _currentUser,
            timestamp: now.subtract(const Duration(minutes: 8)),
          ),
          Reaction(
            emoji: '🎉',
            user: _mockUsers[2],
            timestamp: now.subtract(const Duration(minutes: 7)),
          ),
        ],
      ),
      ChatMessage(
        id: '11',
        text: 'Главное, чтобы теперь успеть все сделать до завтра. ИБО Я НИЧЕГО НЕ УСПЕЮ!!!!Буду из говна и палок все собирать сейчас, чтобы успеть',
        author: _currentUser,
        timestamp: now.subtract(const Duration(minutes: 5)),
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
          _simulateIncomingMessage();
        }
        scheduleNext(); // Планируем следующее событие
      });
    }

    scheduleNext(); // Запускаем цикл
  }

  void _simulateIncomingMessage() {
    final randomUser = _mockUsers[_random.nextInt(_mockUsers.length)];
    final responses = [
      'Только что закончил работу над этим функционалом!',
      'Отличная идея! Полностью поддерживаю',
      'Может стоит добавить валидацию на стороне клиента?',
      'Проверил на тестовом стенде - всё работает идеально 🎉',
      'Есть небольшое предложение по улучшению UX',
      'Кто-то уже тестировал это на мобильных устройствах?',
    ];

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responses[_random.nextInt(responses.length)],
      author: randomUser,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    );

    _mockMessages.add(newMessage);

    // Имитация прочтения
    Timer(const Duration(seconds: 3), () {
      final index = _mockMessages.indexWhere((msg) => msg.id == newMessage.id);
      if (index != -1) {
        _mockMessages[index] = _mockMessages[index].copyWith(status: MessageStatus.read);
      }
    });
  }

  @override
  String get baseUrl => 'mock://localhost';

  @override
  String get authToken => 'mock-token';

  @override
  Future<ChatRoom> getRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 600));

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
      unreadCount: _random.nextInt(3),
    );
  }

  @override
  Future<PaginationResponse<ChatMessage>> getMessages({
    required String roomId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

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

    // 10% шанс ошибки для реалистичности
    if (_random.nextDouble() < 0.1) {
      throw Exception('Ошибка загрузки сообщений');
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
          ? _mockMessages.firstWhere((msg) => msg.id == replyToId, orElse: () => _mockMessages.first)
          : null,
    );

    _mockMessages.add(newMessage);

    // Реалистичная последовательность статусов
    Timer(const Duration(seconds: 1), () {
      final index = _mockMessages.indexWhere((msg) => msg.id == newMessage.id);
      if (index != -1) {
        _mockMessages[index] = _mockMessages[index].copyWith(status: MessageStatus.delivered);
      }
    });

    Timer(const Duration(seconds: 4), () {
      final index = _mockMessages.indexWhere((msg) => msg.id == newMessage.id);
      if (index != -1) {
        _mockMessages[index] = _mockMessages[index].copyWith(status: MessageStatus.read);
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
      _mockMessages[index] = _mockMessages[index].copyWith(isPinned: pinned);
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
      _typingTimers[roomId] = Timer(const Duration(seconds: 3), () {});
    } else {
      _typingTimers[roomId]?.cancel();
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
      return updatedMessage;
    }

    throw Exception('Message not found');
  }
}

class ChatPage extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  static PageRouteBuilder route({
    required String roomId,
    required String roomName,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
        roomId: roomId,
        roomName: roomName,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late ChatController _chatController;
  final ScrollController _scrollController = ScrollController();

  // Анимации
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Состояние UI
  ChatMessage? _replyToMessage;
  ChatMessage? _messageForReaction;
  bool _showReactionMenu = false;
  String _avatarUrl = 'https://i.pravatar.cc/150?img=1';

  // Состояние загрузки
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final apiService = AdvancedMockChatService();
      final cacheManager = ChatCacheManager();

      _chatController = ChatController(
        apiService: apiService,
        cacheManager: cacheManager,
      );

      // Загружаем начальные данные
      await _chatController.loadRoom(widget.roomId);
      await _chatController.loadInitialMessages(widget.roomId);

      setState(() {
        _isInitializing = false;
      });

      _animationController.forward();
    } catch (error) {
      // Обработка ошибки инициализации
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки чата: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _handleReply(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  void _handleCancelReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  void _handleReact(ChatMessage message) {
    setState(() {
      _messageForReaction = message;
      _showReactionMenu = true;
    });
  }

  void _handleCloseReactionMenu() {
    setState(() {
      _showReactionMenu = false;
      _messageForReaction = null;
    });
  }

  void _handleLongPress(ChatMessage message) {
    _showMessageContextMenu(message);
  }

  void _showMessageContextMenu(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMessageContextMenu(message),
    );
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  void _changeAvatar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить аватарку'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Введите URL аватарки',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _avatarUrl = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.roomName,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Загрузка чата...'),
            ],
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width <= 600;
    final horizontalPadding = _getHorizontalPadding(context);

    return ChangeNotifierProvider<ChatController>.value(
      value: _chatController,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _buildAppBar(isMobile, horizontalPadding),
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : horizontalPadding,
            vertical: isMobile ? 0 : 16,
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
            ),
            margin: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
              child: Stack(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Индикатор печати
                        Consumer<ChatController>(
                          builder: (context, controller, child) {
                            final typingUsers = controller.typingUsers;
                            if (typingUsers.isEmpty) return const SizedBox.shrink();

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.blue[50],
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.blue[700]!),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getTypingText(typingUsers),
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Список сообщений
                        Expanded(
                          child: MessageListView(
                            roomId: widget.roomId,
                            scrollController: _scrollController,
                            onReply: _handleReply,
                            onReact: _handleReact,
                            onLongPress: _handleLongPress,
                            avatarUrl: _avatarUrl,
                          ),
                        ),

                        // Поле ввода
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _replyToMessage != null
                                ? ChatInputField(
                              key: ValueKey(_replyToMessage?.id),
                              roomId: widget.roomId,
                              replyTo: _replyToMessage,
                              onCancelReply: _handleCancelReply,
                            )
                                : ChatInputField(
                              key: const ValueKey('default_input'),
                              roomId: widget.roomId,
                              replyTo: _replyToMessage,
                              onCancelReply: _handleCancelReply,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Меню реакций
                  if (_showReactionMenu && _messageForReaction != null)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _handleCloseReactionMenu,
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: ReactionMenu(
                              message: _messageForReaction!,
                              onClose: _handleCloseReactionMenu,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        floatingActionButton: _buildScrollToBottomButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile, double horizontalPadding) {
    return CustomAppBar(
      title: widget.roomName,
      backgroundColor: Colors.white,
      elevation: 2,
      showBackButton: true,
      onBackPressed: () => Navigator.of(context).pop(),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.black, size: 18),
          ),
          onPressed: _showSearch,
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_vert, color: Colors.black, size: 18),
          ),
          onPressed: _showChatMenu,
        ),
      ],
    );
  }

  Widget _buildScrollToBottomButton() {
    return Consumer<ChatController>(
      builder: (context, controller, child) {
        final messages = controller.visibleMessages;
        if (messages.length < 10) return const SizedBox.shrink();

        return AnimatedOpacity(
          opacity: controller.isNearBottom ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.arrow_downward, size: 18, color: Colors.white),
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        );
      },
    );
  }

  // Остальные методы остаются такими же, как в вашем коде
  Widget _buildMessageContextMenu(ChatMessage message) {
    final isCurrentUser = message.author.id == 'current-user';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: message.author.avatarUrl != null
                    ? NetworkImage(message.author.avatarUrl!)
                    : null,
                child: message.author.avatarUrl == null
                    ? Text(message.author.name.substring(0, 1))
                    : null,
              ),
              title: Text(message.author.name),
              subtitle: Text(_formatMessageTime(message.timestamp)),
            ),

            const Divider(),

            if (isCurrentUser) ...[
              _buildMenuAction(
                icon: Icons.reply,
                label: 'Ответить',
                onTap: () {
                  Navigator.pop(context);
                  _handleReply(message);
                },
              ),
              _buildMenuAction(
                icon: Icons.edit,
                label: 'Редактировать',
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
              _buildMenuAction(
                icon: Icons.push_pin,
                label: message.isPinned ? 'Открепить' : 'Закрепить',
                onTap: () {
                  Navigator.pop(context);
                  _chatController.togglePinMessage(message.id);
                },
              ),
              _buildMenuAction(
                icon: Icons.delete,
                label: 'Удалить',
                onTap: () {
                  Navigator.pop(context);
                  _chatController.deleteMessage(message.id);
                },
              ),
            ] else ...[
              _buildMenuAction(
                icon: Icons.reply,
                label: 'Ответить',
                onTap: () {
                  Navigator.pop(context);
                  _handleReply(message);
                },
              ),
              _buildMenuAction(
                icon: Icons.emoji_emotions,
                label: 'Реагировать',
                onTap: () {
                  Navigator.pop(context);
                  _handleReact(message);
                },
              ),
              _buildMenuAction(
                icon: Icons.push_pin,
                label: message.isPinned ? 'Открепить' : 'Закрепить',
                onTap: () {
                  Navigator.pop(context);
                  _chatController.togglePinMessage(message.id);
                },
              ),
            ],

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label),
      onTap: onTap,
    );
  }

  String _getTypingText(List<String> typingUsers) {
    if (typingUsers.isEmpty) return '';
    if (typingUsers.length == 1) return '${typingUsers.first} печатает...';
    if (typingUsers.length == 2) return '${typingUsers.first} и ${typingUsers.last} печатают...';
    return 'Несколько участников печатают...';
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Только что';
    if (difference.inHours < 1) return '${difference.inMinutes} мин назад';
    if (difference.inDays < 1) return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _ChatSearchDelegate(chatController: _chatController),
    );
  }

  void _showChatMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildChatMenu(),
    );
  }

  Widget _buildChatMenu() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ChatController>(
              builder: (context, controller, child) {
                final room = controller.currentRoom;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.group, color: Colors.blue),
                  ),
                  title: Text(room?.displayName ?? widget.roomName),
                  subtitle: room?.isGroup ?? false
                      ? Text('${room?.participantsCount ?? 0} участников')
                      : const Text('Личный чат'),
                );
              },
            ),

            const Divider(),

            _buildMenuAction(
              icon: Icons.search,
              label: 'Поиск в чате',
              onTap: () {
                Navigator.pop(context);
                _showSearch();
              },
            ),

            _buildMenuAction(
              icon: Icons.push_pin,
              label: 'Закрепленные сообщения',
              onTap: () {
                Navigator.pop(context);
                _showPinnedMessages();
              },
            ),

            _buildMenuAction(
              icon: Icons.people,
              label: 'Участники чата',
              onTap: () {
                Navigator.pop(context);
                _showParticipants();
              },
            ),

            _buildMenuAction(
              icon: Icons.person,
              label: 'Изменить аватарку',
              onTap: () {
                Navigator.pop(context);
                _changeAvatar();
              },
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать сообщение'),
        content: TextField(
          controller: TextEditingController(text: message.text),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Реализовать редактирование через API
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showPinnedMessages() {
    // TODO: Реализовать экран закрепленных сообщений
  }

  void _showParticipants() {
    // TODO: Реализовать экран участников
  }
}

class _ChatSearchDelegate extends SearchDelegate<String> {
  final ChatController chatController;

  _ChatSearchDelegate({required this.chatController});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Введите поисковый запрос'));
    }

    return FutureBuilder<void>(
      future: chatController.searchMessages(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Consumer<ChatController>(
          builder: (context, controller, child) {
            final results = controller.searchResults;

            if (results.isEmpty) {
              return const Center(child: Text('Сообщения не найдены'));
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final message = results[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: message.author.avatarUrl != null
                        ? NetworkImage(message.author.avatarUrl!)
                        : null,
                    child: message.author.avatarUrl == null
                        ? Text(message.author.name.substring(0, 1))
                        : null,
                  ),
                  title: Text(message.author.name),
                  subtitle: Text(message.text),
                  trailing: Text(_formatSearchTime(message.timestamp)),
                  onTap: () => close(context, message.id),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatSearchTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}