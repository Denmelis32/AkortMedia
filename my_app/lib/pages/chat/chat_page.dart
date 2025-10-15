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

// Временный мок для тестирования чата
class SimpleMockChatService implements ChatApiService {
  final List<ChatMessage> _mockMessages = [];

  @override
  final Duration timeout = const Duration(seconds: 30);

  SimpleMockChatService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Создаем тестовых пользователей
    final user1 = ChatUser(
      id: 'user1',
      name: 'Алексей',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      isOnline: true,
    );

    final user2 = ChatUser(
      id: 'user2',
      name: 'Мария',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      isOnline: true,
    );

    // Создаем тестовые сообщения
    _mockMessages.addAll([
      ChatMessage(
        id: '1',
        text: 'Привет! Как дела?',
        author: user1,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '2',
        text: 'Привет! Всё отлично, работаю над проектом.',
        author: user2,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        text: 'Отлично! У меня тоже всё хорошо.',
        author: user1,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '4',
        text: 'Посмотри новый дизайн, что думаешь?',
        author: user2,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '5',
        text: 'Очень круто! Мне нравится новый подход 🚀',
        author: user1,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: MessageStatus.read,
        reactions: [
          Reaction(
            emoji: '👍',
            user: user2,
            timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          ),
        ],
      ),
    ]);
  }

  @override
  String get baseUrl => 'mock://localhost';

  @override
  String get authToken => 'mock-token';

  @override
  Future<ChatRoom> getRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final participants = [
      ChatUser(
        id: 'user1',
        name: 'Алексей',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
      ),
      ChatUser(
        id: 'user2',
        name: 'Мария',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
      ),
      ChatUser(
        id: 'current-user',
        name: 'Вы',
        isOnline: true,
      ),
    ];

    return ChatRoom(
      id: roomId,
      name: 'Тестовый чат $roomId',
      participants: participants,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      isGroup: roomId.contains('group'),
      createdBy: participants.first,
      lastMessage: _mockMessages.isNotEmpty ? _mockMessages.last : null,
    );
  }

  @override
  Future<PaginationResponse<ChatMessage>> getMessages({
    required String roomId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Симуляция пагинации
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    List<ChatMessage> paginatedMessages = [];

    if (startIndex < _mockMessages.length) {
      paginatedMessages = _mockMessages.sublist(
        startIndex,
        endIndex > _mockMessages.length ? _mockMessages.length : endIndex,
      ).reversed.toList();
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
    await Future.delayed(const Duration(milliseconds: 300));

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: ChatUser(
        id: 'current-user',
        name: 'Вы',
        isOnline: true,
      ),
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      replyTo: replyToId != null
          ? _mockMessages.firstWhere((msg) => msg.id == replyToId, orElse: () => _mockMessages.first)
          : null,
    );

    _mockMessages.add(newMessage);
    return newMessage;
  }

  @override
  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _mockMessages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = _mockMessages[index];
      final existingReactionIndex = message.reactions
          .indexWhere((r) => r.emoji == emoji && r.user.id == 'current-user');

      List<Reaction> updatedReactions;

      if (existingReactionIndex != -1) {
        updatedReactions = List<Reaction>.from(message.reactions);
        updatedReactions.removeAt(existingReactionIndex);
      } else {
        updatedReactions = [
          ...message.reactions,
          Reaction(
            emoji: emoji,
            user: ChatUser(id: 'current-user', name: 'Вы', isOnline: true),
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
    await Future.delayed(const Duration(milliseconds: 200));

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
    await Future.delayed(const Duration(milliseconds: 500));

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
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockMessages.removeWhere((msg) => msg.id == messageId);
  }

  @override
  Future<ChatMessage> editMessage({
    required String messageId,
    required String newText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

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

  // URL для аватарки
  String _avatarUrl = 'https://i.pravatar.cc/150?img=1';

  @override
  void initState() {
    super.initState();

    // Инициализация анимаций
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

    // Запуск анимаций
    _animationController.forward();

    // Инициализация контроллера
    _initializeController();
  }

  void _initializeController() {
    final apiService = SimpleMockChatService();
    final cacheManager = ChatCacheManager();

    _chatController = ChatController(
      apiService: apiService,
      cacheManager: cacheManager,
    );
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
    FocusScope.of(context).requestFocus(FocusNode());
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

  // Метод для получения отступов
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0; // На телефоне убираем отступы
  }

  // Метод для изменения аватарки
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            vertical: isMobile ? 0 : 16, // Отступ снизу на компьютере
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
                  // Основной контент с анимацией
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
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

                  // Меню реакций (поверх всего)
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

        // Кнопка прокрутки вниз
        floatingActionButton: _buildScrollToBottomButton(),
      ),
    );
  }

  // AppBar с белым фоном и работающей кнопкой назад
  PreferredSizeWidget _buildAppBar(bool isMobile, double horizontalPadding) {
    return CustomAppBar(
      title: widget.roomName,
      backgroundColor: Colors.white,
      elevation: 2,
      showBackButton: true,
      onBackPressed: () {
        Navigator.of(context).pop(); // Используем Navigator.of(context)
      },
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

        return FloatingActionButton(
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
        );
      },
    );
  }

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

    if (typingUsers.length == 1) {
      return '${typingUsers.first} печатает...';
    } else if (typingUsers.length == 2) {
      return '${typingUsers.first} и ${typingUsers.last} печатают...';
    } else {
      return 'Несколько участников печатают...';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
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
    // TODO: Реализовать редактирование через API
  }

  void _showPinnedMessages() {
    // TODO: Реализовать экран закрепленных сообщений
  }

  void _showParticipants() {
    // TODO: Реализовать экран участников
  }
}

// Класс для поиска по сообщениям
class _ChatSearchDelegate extends SearchDelegate<String> {
  final ChatController chatController;

  _ChatSearchDelegate({required this.chatController});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Введите поисковый запрос'),
      );
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
              return const Center(
                child: Text('Сообщения не найдены'),
              );
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
                  onTap: () {
                    close(context, message.id);
                  },
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