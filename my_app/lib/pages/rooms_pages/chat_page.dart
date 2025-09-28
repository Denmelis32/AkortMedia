// lib/pages/rooms_page/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'models/room.dart';
import '../../providers/room_provider.dart';

class ChatPage extends StatefulWidget {
  final Room room;
  final String userName;

  const ChatPage({
    super.key,
    required this.room,
    required this.userName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final List<ChatMessage> _messages = [];

  bool _isLoading = true;
  bool _showScrollToBottom = false;
  bool _isTyping = false;
  bool _isRecording = false;
  bool _showReactions = false;
  String _typingUser = '';
  ChatMessage? _replyingTo;
  ChatMessage? _editingMessage;
  double _recordingTime = 0.0;
  int _selectedReactionIndex = -1;

  final Map<String, Color> _userColors = {};
  final Random _random = Random();
  final List<String> _availableReactions = ['❤️', '😂', '😮', '😢', '👍', '👎', '🔥', '🎉'];

  final Map<String, bool> _expandedMessages = {};

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _scrollController.addListener(_onScroll);
    _setupTypingIndicator();
  }

  void _setupTypingIndicator() {
    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty && !_isTyping) {
        setState(() => _isTyping = true);
        _simulateTyping();
      } else if (_messageController.text.isEmpty && _isTyping) {
        setState(() {
          _isTyping = false;
          _typingUser = '';
        });
      }
    });
  }

  void _simulateTyping() {
    if (_isTyping) {
      final typingUsers = ['Алексей Петров', 'Мария Иванова', 'Иван Сидоров'];
      final randomUser = typingUsers[DateTime.now().millisecond % typingUsers.length];

      setState(() => _typingUser = randomUser);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isTyping) {
          setState(() => _typingUser = '');
        }
      });
    }
  }

  Color _getUserColor(String userName) {
    if (!_userColors.containsKey(userName)) {
      _userColors[userName] = Colors.primaries[_random.nextInt(Colors.primaries.length)].shade600;
    }
    return _userColors[userName]!;
  }

  void _loadInitialMessages() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        _messages.addAll([
          ChatMessage(
            id: '1',
            text: 'Добро пожаловать в "${widget.room.title}"! 🎉\nЗдесь обсуждаем последние спортивные события и матчи. Не стесняйтесь задавать вопросы и делиться мнениями!',
            sender: 'Система',
            time: DateTime.now().subtract(const Duration(minutes: 2)),
            isMe: false,
            messageType: MessageType.system,
          ),
          ChatMessage(
            id: '2',
            text: 'Привет всем! Рад присоединиться к обсуждению! 👋',
            sender: 'Алексей Петров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            reactions: {'👍': 2, '❤️': 1},
            userColor: _getUserColor('Алексей Петров'),
          ),
          ChatMessage(
            id: '3',
            text: 'Кто уже смотрел последний матч? Какие мысли? ⚽',
            sender: 'Мария Иванова',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            reactions: {'❤️': 1, '🔥': 1},
            userColor: _getUserColor('Мария Иванова'),
          ),
          ChatMessage(
            id: '4',
            text: 'Отличная игра была! Особенно понравилась стратегия команды в защите. На мой взгляд, ключевым моментом стала замена на 70-й минуте.',
            sender: 'Иван Сидоров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            userColor: _getUserColor('Иван Сидоров'),
          ),
          ChatMessage(
            id: '5',
            text: 'А как вам гол на 89-й минуте? Просто великолепно! 🥅',
            sender: 'Алексей Петров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            isEdited: true,
            userColor: _getUserColor('Алексей Петров'),
          ),
        ]);
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    roomProvider.addMessageToRoom(widget.room.id);

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: widget.userName,
      time: DateTime.now(),
      isMe: true,
      replyTo: _replyingTo,
      userColor: _getUserColor(widget.userName),
    );

    setState(() {
      if (_editingMessage != null) {
        final index = _messages.indexWhere((msg) => msg.id == _editingMessage!.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(text: text, isEdited: true);
        }
        _editingMessage = null;
      } else {
        _messages.add(newMessage);
      }
      _messageController.clear();
      _isTyping = false;
      _typingUser = '';
      _replyingTo = null;
    });

    if (_editingMessage == null) {
      _simulateAIResponse(text);
    }
    _scrollToBottom();
  }

  void _simulateAIResponse(String userMessage) {
    String response = '';

    if (userMessage.toLowerCase().contains('привет')) {
      response = 'Привет! Рад видеть вас в чате! 😊';
    } else if (userMessage.toLowerCase().contains('матч')) {
      response = 'Да, матч был захватывающий! Особенно впечатлила игра полузащиты.';
    } else {
      final responses = [
        'Интересная мысль! Что еще думаете по этому поводу?',
        'Согласен с вами! Добавлю, что важна также командная работа.',
        'Хороший вопрос! Давайте обсудим это подробнее.',
        'Отличное замечание! Полностью поддерживаю вашу точку зрения.',
      ];
      response = responses[DateTime.now().millisecond % responses.length];
    }

    Future.delayed(Duration(seconds: 1 + _random.nextInt(2)), () {
      if (!mounted) return;

      final aiUsers = ['Алексей Петров', 'Мария Иванова', 'Иван Сидоров'];
      final aiUser = aiUsers[DateTime.now().second % aiUsers.length];

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          sender: aiUser,
          time: DateTime.now().add(const Duration(seconds: 1)),
          isMe: false,
          userColor: _getUserColor(aiUser),
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    setState(() {
      _showScrollToBottom = (maxScroll - currentScroll) > 200;
    });
  }

  void _replyToMessage(ChatMessage message) {
    setState(() {
      _replyingTo = message;
      _editingMessage = null;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _addReaction(ChatMessage message, String emoji) {
    setState(() {
      message.reactions ??= {};
      message.reactions![emoji] = (message.reactions![emoji] ?? 0) + 1;
    });
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
      _recordingTime = 0.0;
    });
    _updateRecordingTime();
  }

  void _stopVoiceRecording() {
    setState(() {
      _isRecording = false;
    });
  }

  void _updateRecordingTime() {
    if (_isRecording) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isRecording && mounted) {
          setState(() {
            _recordingTime += 0.1;
          });
          _updateRecordingTime();
        }
      });
    }
  }

  void _sendVoiceMessage() {
    _stopVoiceRecording();
    _simulateAIResponse('[Голосовое сообщение]');
  }

  void _toggleMessageExpansion(String messageId) {
    setState(() {
      _expandedMessages[messageId] = !(_expandedMessages[messageId] ?? false);
    });
  }

  void _handleAppBarAction(String value) {
    switch (value) {
      case 'info':
        _showEnhancedRoomInfo();
        break;
      case 'members':
        _showMembers();
        break;
      case 'share':
        _inviteUsers();
        break;
      case 'settings':
        _showRoomSettings();
        break;
      case 'search':
        _showSearch();
        break;
    }
  }

  void _showRoomSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки комнаты'),
        content: const Text('Эта функция находится в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _ChatSearchDelegate(_messages),
    );
  }

  void _toggleReactions() {
    setState(() {
      _showReactions = !_showReactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildEnhancedAppBar(theme),
            Expanded(
              child: Stack(
                children: [
                  // Улучшенный фоновый градиент
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                          theme.colorScheme.surface.withOpacity(0.3),
                          theme.colorScheme.background.withOpacity(0.7),
                        ]
                            : [
                          theme.colorScheme.primary.withOpacity(0.03),
                          theme.colorScheme.background.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  if (_isLoading)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Загружаем сообщения...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_typingUser.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        final message = _messages[index];
                        final showAvatar = index == 0 ||
                            _messages[index - 1].sender != message.sender ||
                            message.time.difference(_messages[index - 1].time).inMinutes > 5;

                        return _buildEnhancedMessageBubble(message, showAvatar, theme);
                      } else {
                        return _buildTypingIndicator(theme);
                      }
                    },
                  ),

                  if (_showScrollToBottom)
                    Positioned(
                      bottom: 100,
                      right: 20,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: theme.primaryColor,
                        onPressed: _scrollToBottom,
                        child: Icon(Icons.arrow_downward, size: 20, color: theme.colorScheme.onPrimary),
                      ),
                    ),
                ],
              ),
            ),

            if (_typingUser.isNotEmpty) _buildTypingIndicatorBar(theme),

            if (_replyingTo != null) _buildReplyPanel(theme),

            if (_editingMessage != null) _buildEditPanel(theme),

            _buildEnhancedMessageInput(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Кнопка назад с улучшенным дизайном
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(width: 12),

            // Информация о комнате
            Expanded(
              child: GestureDetector(
                onTap: _showEnhancedRoomInfo,
                child: Row(
                  children: [
                    // Аватар комнаты с градиентом
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.room.category.color,
                            widget.room.category.color.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.room.category.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.room.category.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.room.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Бейджи комнаты
                              if (widget.room.isVerified)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified, size: 12, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Проверено',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          _buildEnhancedOnlineIndicator(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Кнопки действий
            Row(
              children: [
                // Кнопка участников
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Badge(
                      smallSize: 8,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.people_alt_outlined, color: theme.primaryColor),
                    ),
                    onPressed: _showMembers,
                  ),
                ),

                const SizedBox(width: 8),

                // Меню дополнительных действий
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: theme.primaryColor),
                    onSelected: _handleAppBarAction,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'info',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('Информация о комнате'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'members',
                        child: Row(
                          children: [
                            Icon(Icons.people, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('Участники'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('Поделиться'),
                          ],
                        ),
                      ),
                      if (widget.room.canEdit('current_user_id'))
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings, color: theme.primaryColor),
                              const SizedBox(width: 8),
                              const Text('Настройки комнаты'),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'search',
                        child: Row(
                          children: [
                            Icon(Icons.search, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('Поиск по сообщениям'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedOnlineIndicator(ThemeData theme) {
    final onlineCount = (widget.room.currentParticipants * 0.3).round();
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.room.isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.room.isActive ? Colors.green.withOpacity(0.5) : Colors.transparent,
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${widget.room.isActive ? '$onlineCount онлайн' : 'Неактивна'} • ${_formatParticipantCount(widget.room.currentParticipants)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicatorBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_typingUser печатает...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ответ ${_replyingTo!.sender}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyingTo!.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }

  Widget _buildEditPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Редактирование сообщения',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _editingMessage!.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            onPressed: () {
              setState(() {
                _editingMessage = null;
                _messageController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMessageInput(ThemeData theme) {
    if (_isRecording) {
      return _buildVoiceRecordingPanel(theme);
    }

    // Проверка доступности комнаты
    final isRoomAvailable = widget.room.isActive &&
        !widget.room.isExpired &&
        !widget.room.isFull;

    if (!isRoomAvailable) {
      return _buildRoomUnavailablePanel(theme);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Быстрые реакции
          if (_showReactions) _buildQuickReactions(theme),

          Row(
            children: [
              // Кнопка прикрепления файлов
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: theme.primaryColor, size: 24),
                  onPressed: _showEnhancedAttachmentMenu,
                ),
              ),

              const SizedBox(width: 8),

              // Поле ввода сообщения
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: _editingMessage != null ? 'Редактирование сообщения...' : 'Напишите сообщение...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.emoji_emotions_outlined, color: theme.primaryColor),
                            onPressed: _toggleReactions,
                          ),
                          IconButton(
                            icon: Icon(Icons.attach_file, color: theme.primaryColor),
                            onPressed: _showEnhancedAttachmentMenu,
                          ),
                        ],
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Кнопка отправки/записи
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _messageController.text.isEmpty ? 48 : 48,
                child: _messageController.text.isEmpty
                    ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.mic, color: Colors.white),
                    onPressed: _startVoiceRecording,
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(_editingMessage != null ? Icons.check : Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReactions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_availableReactions.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedReactionIndex = index;
              });
              _toggleReactions();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedReactionIndex == index
                    ? theme.primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _availableReactions[index],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoomUnavailablePanel(ThemeData theme) {
    String message;
    Color color;
    IconData icon;

    if (widget.room.isExpired) {
      message = 'Эта комната завершена';
      color = Colors.grey;
      icon = Icons.timer_off;
    } else if (widget.room.isFull) {
      message = 'Комната заполнена';
      color = Colors.orange;
      icon = Icons.person_off;
    } else if (!widget.room.isActive) {
      message = 'Комната неактивна';
      color = Colors.red;
      icon = Icons.access_alarm;
    } else {
      message = 'Комната недоступна';
      color = Colors.grey;
      icon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // Визуализатор звука
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (index) {
              final height = (_random.nextDouble() * 30) + 5;
              final isActive = index < ((_recordingTime * 2) % 20).toInt();
              return Container(
                width: 3,
                height: isActive ? height : 5,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isActive ? theme.colorScheme.onErrorContainer : theme.colorScheme.onErrorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, color: theme.colorScheme.onErrorContainer, size: 24),
              const SizedBox(width: 8),
              Text(
                'Запись... ${_recordingTime.toStringAsFixed(1)}с',
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: _recordingTime % 30 / 30,
            backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.onErrorContainer),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _stopVoiceRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel, size: 18),
                    SizedBox(width: 6),
                    Text('Отменить'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _sendVoiceMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.send, size: 18),
                    SizedBox(width: 6),
                    Text('Отправить'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMessageBubble(ChatMessage message, bool showAvatar, ThemeData theme) {
    final isSystem = message.messageType == MessageType.system;
    final isExpanded = _expandedMessages[message.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isSystem)
            _buildSystemMessage(message, theme)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!message.isMe && showAvatar)
                  _buildUserAvatar(message, theme),
                if (!message.isMe && showAvatar) const SizedBox(width: 8),

                Flexible(
                  child: Column(
                    crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!message.isMe && showAvatar)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 8),
                          child: Text(
                            message.sender,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      // Сообщение с улучшенным дизайном
                      GestureDetector(
                        onLongPress: () => _showEnhancedMessageOptions(message, theme),
                        onDoubleTap: () => _addReaction(message, '❤️'),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: message.isMe
                                ? theme.primaryColor
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            gradient: message.isMe
                                ? LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Текст сообщения
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isMe
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  height: 1.4,
                                ),
                                maxLines: isExpanded ? null : 10,
                                overflow: isExpanded ? null : TextOverflow.ellipsis,
                              ),

                              // Кнопка "Развернуть" для длинных сообщений
                              if (message.text.length > 200 && !isExpanded)
                                GestureDetector(
                                  onTap: () => _toggleMessageExpansion(message.id),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Развернуть...',
                                      style: TextStyle(
                                        color: message.isMe
                                            ? theme.colorScheme.onPrimary.withOpacity(0.8)
                                            : theme.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Реакции
                      if (message.reactions != null && message.reactions!.isNotEmpty)
                        _buildEnhancedReactions(message, theme),

                      // Время и статус редактирования
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat.Hm().format(message.time),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            if (message.isEdited) ...[
                              const SizedBox(width: 6),
                              Text(
                                'ред.',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (message.isMe) const SizedBox(width: 8),
                if (message.isMe && showAvatar)
                  _buildUserAvatar(message, theme),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ChatMessage message, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                message.userColor ?? theme.primaryColor,
                message.userColor?.withOpacity(0.7) ?? theme.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (message.userColor ?? theme.primaryColor).withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              message.sender[0].toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemMessage(ChatMessage message, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.primaryColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedReactions(ChatMessage message, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: message.reactions!.entries.map((entry) {
          return GestureDetector(
            onTap: () => _addReaction(message, entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '${entry.key} ${entry.value}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildUserAvatar(ChatMessage(
            id: 'typing',
            text: '',
            sender: _typingUser,
            time: DateTime.now(),
            isMe: false,
            userColor: _getUserColor(_typingUser),
          ), theme),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTypingDot(0, theme),
                _buildTypingDot(1, theme),
                _buildTypingDot(2, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.5 + index * 0.2),
        shape: BoxShape.circle,
      ),
    );
  }

  void _showEnhancedMessageOptions(ChatMessage message, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Заголовок с информацией о сообщении
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildUserAvatar(message, theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.sender,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy, HH:mm').format(message.time),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Опции сообщения
              if (!message.isMe)
                _buildEnhancedOptionTile(
                  Icons.reply,
                  'Ответить',
                  'Ответить на это сообщение',
                      () {
                    Navigator.pop(context);
                    _replyToMessage(message);
                  },
                  theme,
                ),

              _buildEnhancedOptionTile(
                Icons.copy,
                'Скопировать текст',
                'Скопировать текст сообщения',
                    () {
                  Navigator.pop(context);
                  _copyMessageText(message);
                },
                theme,
              ),

              _buildEnhancedOptionTile(
                Icons.emoji_emotions_outlined,
                'Добавить реакцию',
                'Выбрать эмодзи для реакции',
                    () {
                  Navigator.pop(context);
                  _showEnhancedReactionPicker(message, theme);
                },
                theme,
              ),

              if (message.isMe)
                _buildEnhancedOptionTile(
                  Icons.edit,
                  'Редактировать',
                  'Изменить текст сообщения',
                      () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                  theme,
                ),

              if (message.isMe)
                _buildEnhancedOptionTile(
                  Icons.delete,
                  'Удалить',
                  'Удалить это сообщение',
                      () {
                    Navigator.pop(context);
                    _deleteMessage(message);
                  },
                  theme,
                  isDestructive: true,
                ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap, ThemeData theme, {bool isDestructive = false}) {
    final color = isDestructive ? theme.colorScheme.error : theme.primaryColor;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(color: isDestructive ? theme.colorScheme.error : null)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      )),
      onTap: onTap,
    );
  }

  void _showEnhancedReactionPicker(ChatMessage message, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Выберите реакцию',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _availableReactions.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _addReaction(message, emoji);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.background,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyMessageText(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Текст скопирован'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editMessage(ChatMessage message) {
    _messageController.text = message.text;
    _messageFocusNode.requestFocus();

    setState(() {
      _editingMessage = message;
      _replyingTo = null;
    });
  }

  void _deleteMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Это действие нельзя отменить. Сообщение будет удалено для всех участников.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.remove(message);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Сообщение удалено'),
                  backgroundColor: Theme.of(context).primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEnhancedRoomInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEnhancedRoomHeader(Theme.of(context)),
                    const SizedBox(height: 32),
                    _buildEnhancedRoomStats(Theme.of(context)),
                    const SizedBox(height: 32),
                    _buildRoomDescription(Theme.of(context)),
                    const SizedBox(height: 24),
                    _buildRoomTags(Theme.of(context)),
                    const SizedBox(height: 32),
                    _buildRoomRules(Theme.of(context)),
                    const SizedBox(height: 32),
                    _buildEnhancedActionButtons(Theme.of(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedRoomHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Аватар комнаты
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.room.category.color,
                widget.room.category.color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.room.category.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.room.category.icon,
            color: Colors.white,
            size: 40,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Категория и статус
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.room.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.room.category.title,
                      style: TextStyle(
                        color: widget.room.category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.room.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.room.isActive ? Icons.circle : Icons.circle_outlined,
                          size: 12,
                          color: widget.room.isActive ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.room.status,
                          style: TextStyle(
                            color: widget.room.isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Создатель комнаты
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      'АП',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Создатель: Алексей Петров',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedRoomStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEnhancedStatItem(Icons.people_alt, 'Участники', '${widget.room.currentParticipants}/${widget.room.maxParticipants}', theme),
          _buildEnhancedStatItem(Icons.chat_bubble, 'Сообщения', NumberFormatting(widget.room.messageCount).formatCount(), theme),
          _buildEnhancedStatItem(Icons.star, 'Рейтинг', widget.room.rating.toStringAsFixed(1), theme),
          _buildEnhancedStatItem(Icons.visibility, 'Просмотры', NumberFormatting(widget.room.viewCount).formatCount(), theme),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(IconData icon, String label, String value, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: theme.primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание комнаты',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.room.description,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTags(ThemeData theme) {
    if (widget.room.tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Теги',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: widget.room.tags.map((tag) {
            return Chip(
              label: Text(
                '#$tag',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoomRules(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Правила комнаты',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildRuleItem('Будьте вежливы и уважайте других участников', Icons.people, theme),
              _buildRuleItem('Запрещен спам и реклама', Icons.block, theme),
              _buildRuleItem('Соблюдайте тематику комнаты', Icons.category, theme),
              _buildRuleItem('Контент должен соответствовать правилам платформы', Icons.security, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String text, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Закрыть'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _inviteUsers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 18),
                SizedBox(width: 6),
                Text('Пригласить'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _inviteUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пригласить в комнату'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ссылка на комнату скопирована в буфер обмена'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://chat.app/room/${widget.room.id}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'https://chat.app/room/${widget.room.id}'));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMembers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Функция участников в разработке'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEnhancedAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Прикрепить файл',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEnhancedAttachmentOption(Icons.photo, 'Фото', Colors.green, () {}),
                    _buildEnhancedAttachmentOption(Icons.videocam, 'Видео', Colors.blue, () {}),
                    _buildEnhancedAttachmentOption(Icons.attach_file, 'Файл', Colors.orange, () {}),
                    _buildEnhancedAttachmentOption(Icons.location_on, 'Местоположение', Colors.red, () {}),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEnhancedAttachmentOption(Icons.poll, 'Опрос', Colors.purple, () {}),
                    _buildEnhancedAttachmentOption(Icons.event, 'Событие', Colors.teal, () {}),
                    _buildEnhancedAttachmentOption(Icons.contact_page, 'Контакты', Colors.brown, () {}),
                    _buildEnhancedAttachmentOption(Icons.music_note, 'Аудио', Colors.pink, () {}),
                  ],
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAttachmentOption(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatParticipantCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }
}

// Класс для поиска по сообщениям
class _ChatSearchDelegate extends SearchDelegate<String> {
  final List<ChatMessage> messages;

  _ChatSearchDelegate(this.messages);

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
    final results = messages.where((message) {
      return message.text.toLowerCase().contains(query.toLowerCase()) ||
          message.sender.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final message = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              message.sender[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(message.sender),
          subtitle: Text(
            message.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(DateFormat.Hm().format(message.time)),
          onTap: () {
            close(context, message.id);
          },
        );
      },
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final String sender;
  final DateTime time;
  final bool isMe;
  final MessageType messageType;
  final bool isEdited;
  final ChatMessage? replyTo;
  final Color? userColor;
  Map<String, int>? reactions;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
    this.messageType = MessageType.text,
    this.isEdited = false,
    this.replyTo,
    this.reactions,
    this.userColor,
  });

  ChatMessage copyWith({
    String? text,
    bool? isEdited,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      time: time,
      isMe: isMe,
      messageType: messageType,
      isEdited: isEdited ?? this.isEdited,
      replyTo: replyTo,
      reactions: reactions,
      userColor: userColor,
    );
  }
}

enum MessageType {
  text,
  image,
  system,
}

// Расширение для форматирования чисел
extension NumberFormatting on int {
  String formatCount() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}