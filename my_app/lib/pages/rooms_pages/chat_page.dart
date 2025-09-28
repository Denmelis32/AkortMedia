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

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final List<ChatMessage> _messages = [];

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  bool _isLoading = true;
  bool _showScrollToBottom = false;
  bool _isTyping = false;
  bool _isRecording = false;
  String _typingUser = '';
  ChatMessage? _replyingTo;
  double _recordingTime = 0.0;

  final Map<String, Color> _userColors = {};
  final Random _random = Random();
  final List<String> _availableReactions = ['❤️', '😂', '😮', '😢', '👍', '👎', '🔥'];

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _scrollController.addListener(_onScroll);
    _setupAnimations();
    _setupTypingIndicator();
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _typingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingAnimationController, curve: Curves.easeInOut),
    );
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
      _userColors[userName] = Colors.primaries[_random.nextInt(Colors.primaries.length)];
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
            text: 'Добро пожаловать в "${widget.room.title}"! 🎉',
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
          ),
          ChatMessage(
            id: '3',
            text: 'Кто уже смотрел последний матч? Какие мысли? ⚽',
            sender: 'Мария Иванова',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            reactions: {'❤️': 1, '🔥': 1},
          ),
          ChatMessage(
            id: '4',
            text: 'Отличная игра была! Особенно понравилась стратегия команды в защите.',
            sender: 'Иван Сидоров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
          ),
          ChatMessage(
            id: '5',
            text: 'А как вам гол на 89-й минуте? Просто великолепно! 🥅',
            sender: 'Алексей Петров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            isEdited: true,
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
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
      _isTyping = false;
      _typingUser = '';
      _replyingTo = null;
    });

    _simulateAIResponse(text);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(theme),
            Expanded(
              child: Stack(
                children: [
                  // Фоновый градиент
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.background.withOpacity(0.9),
                          theme.colorScheme.background.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),

                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(theme.primaryColor),
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

                        return _buildMessageBubble(message, showAvatar, theme);
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

            _buildMessageInput(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),

            Expanded(
              child: GestureDetector(
                onTap: _showRoomInfo,
                child: Row(
                  children: [
                    // УБРАН Hero widget чтобы избежать конфликта тегов
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.forum,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.room.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildOnlineIndicator(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IconButton(
              icon: Badge(
                smallSize: 8,
                backgroundColor: Colors.green,
                child: Icon(Icons.people, color: theme.primaryColor),
              ),
              onPressed: _showRoomInfo,
            ),

            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: theme.primaryColor),
              onSelected: (value) => _handleAppBarAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'info', child: Text('Информация о комнате')),
                const PopupMenuItem(value: 'members', child: Text('Участники')),
                const PopupMenuItem(value: 'share', child: Text('Поделиться')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAppBarAction(String value) {
    switch (value) {
      case 'info':
        _showRoomInfo();
        break;
      case 'members':
        _showMembers();
        break;
      case 'share':
        _inviteUsers();
        break;
    }
  }

  Widget _buildOnlineIndicator(ThemeData theme) {
    final onlineCount = (widget.room.participants * 0.3).round();
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$onlineCount онлайн • ${_formatParticipantCount(widget.room.participants)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicatorBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface.withOpacity(0.9),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _typingAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _typingAnimation.value,
                child: child,
              );
            },
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(theme.primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$_typingUser печатает...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            color: theme.primaryColor,
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
                const SizedBox(height: 2),
                Text(
                  _replyingTo!.text,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
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

  Widget _buildMessageInput(ThemeData theme) {
    if (_isRecording) {
      return _buildVoiceRecordingPanel(theme);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: theme.primaryColor, size: 28),
            onPressed: _showAttachmentMenu,
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Напишите сообщение...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined, color: theme.primaryColor),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file, color: theme.primaryColor),
                        onPressed: _showAttachmentMenu,
                      ),
                    ],
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _messageController.text.isEmpty ? 48 : 80,
            child: _messageController.text.isEmpty
                ? IconButton(
              icon: Icon(Icons.mic, color: theme.primaryColor),
              onPressed: _startVoiceRecording,
            )
                : ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Отпр'),
                  SizedBox(width: 4),
                  Icon(Icons.send, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Text(
                'Запись... ${_recordingTime.toStringAsFixed(1)}с',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _recordingTime % 10 / 10,
            backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.onErrorContainer),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _stopVoiceRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('Отменить'),
              ),
              ElevatedButton(
                onPressed: _sendVoiceMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Отправить'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showAvatar, ThemeData theme) {
    final isSystem = message.messageType == MessageType.system;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(message, theme),
      onDoubleTap: () => _addReaction(message, '❤️'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _getUserColor(message.sender),
                      child: Text(
                        message.sender[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (!message.isMe && showAvatar) const SizedBox(width: 8),

                  Flexible(
                    child: Column(
                      crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!message.isMe && showAvatar)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              message.sender,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isMe
                                ? theme.primaryColor
                                : theme.colorScheme.surface,
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
                            message.text,
                            style: TextStyle(
                              color: message.isMe
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),

                        if (message.reactions != null && message.reactions!.isNotEmpty)
                          _buildReactions(message, theme),

                        Padding(
                          padding: const EdgeInsets.only(top: 4),
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
                                const SizedBox(width: 4),
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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        widget.userName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage message, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        message.text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildReactions(ChatMessage message, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: message.reactions!.entries.map((entry) {
          return GestureDetector(
            onTap: () => _addReaction(message, entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                '${entry.key} ${entry.value}',
                style: theme.textTheme.labelSmall,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getUserColor(_typingUser),
            child: Text(
              _typingUser[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildAnimatedTypingDot(0, theme),
                _buildAnimatedTypingDot(1, theme),
                _buildAnimatedTypingDot(2, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTypingDot(int index, ThemeData theme) {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _typingAnimation.value * (1.0 - index * 0.2),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _showMessageOptions(ChatMessage message, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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

              if (!message.isMe)
                _buildOptionTile(
                  Icons.reply,
                  'Ответить',
                      () {
                    Navigator.pop(context);
                    _replyToMessage(message);
                  },
                  theme,
                ),

              _buildOptionTile(
                Icons.copy,
                'Скопировать текст',
                    () {
                  Navigator.pop(context);
                  _copyMessageText(message);
                },
                theme,
              ),

              _buildOptionTile(
                Icons.emoji_emotions_outlined,
                'Добавить реакцию',
                    () {
                  Navigator.pop(context);
                  _showReactionPicker(message, theme);
                },
                theme,
              ),

              if (message.isMe)
                _buildOptionTile(
                  Icons.edit,
                  'Редактировать',
                      () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                  theme,
                ),

              if (message.isMe)
                _buildOptionTile(
                  Icons.delete,
                  'Удалить',
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
                  child: const Text('Отмена'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String text, VoidCallback onTap, ThemeData theme, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? theme.colorScheme.error : theme.primaryColor),
      title: Text(text, style: TextStyle(color: isDestructive ? theme.colorScheme.error : null)),
      onTap: onTap,
    );
  }

  void _showReactionPicker(ChatMessage message, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Выберите реакцию',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableReactions.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _addReaction(message, emoji);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
      ),
    );
  }

  void _editMessage(ChatMessage message) {
    _messageController.text = message.text;
    _messageFocusNode.requestFocus();

    setState(() {
      _messages.remove(message);
    });
  }

  void _deleteMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Это действие нельзя отменить'),
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
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRoomInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    _buildRoomHeader(Theme.of(context)),
                    const SizedBox(height: 24),
                    _buildRoomStats(Theme.of(context)),
                    const SizedBox(height: 24),
                    _buildRoomDescription(Theme.of(context)),
                    const SizedBox(height: 32),
                    _buildActionButtons(Theme.of(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.forum,
            color: theme.primaryColor,
            size: 40,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.room.category.title,
                style: TextStyle(
                  color: widget.room.category.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatParticipantCount(widget.room.participants)} участников',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.chat, 'Сообщения', _formatParticipantCount(widget.room.messages), theme),
          _buildStatItem(Icons.access_time, 'Активность', 'только что', theme),
          _buildStatItem(Icons.star, 'Рейтинг', widget.room.rating.toStringAsFixed(1), theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildRoomDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          widget.room.description,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
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
            ),
            child: const Text('Пригласить'),
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
        content: const Text('Ссылка на комнату скопирована в буфер обмена'),
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
      const SnackBar(content: Text('Функция участников в разработке')),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 20),
                Text(
                  'Прикрепить файл',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildAttachmentOption(Icons.photo, 'Фото', Colors.green, () {}),
                    _buildAttachmentOption(Icons.videocam, 'Видео', Colors.blue, () {}),
                    _buildAttachmentOption(Icons.attach_file, 'Файл', Colors.orange, () {}),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
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
    _typingAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
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
  });
}

enum MessageType {
  text,
  image,
  system,
}