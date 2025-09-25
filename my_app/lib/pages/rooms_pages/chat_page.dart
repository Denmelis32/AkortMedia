// lib/pages/rooms_page/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  String _typingUser = '';

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _scrollController.addListener(_onScroll);
    _setupTypingIndicator();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _setupTypingIndicator() {
    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty && !_isTyping) {
        setState(() {
          _isTyping = true;
        });
        // Имитация печати других пользователей
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

      setState(() {
        _typingUser = randomUser;
      });

      // Автоматическое скрытие индикатора через 3 секунды
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isTyping) {
          setState(() {
            _typingUser = '';
          });
        }
      });
    }
  }

  void _loadInitialMessages() {
    // Имитация загрузки сообщений
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _messages.addAll([
          ChatMessage(
            text: 'Добро пожаловать в обсуждение "${widget.room.title}"! 🎉',
            sender: 'Система',
            time: DateTime.now().subtract(const Duration(minutes: 2)),
            isMe: false,
            messageType: MessageType.system,
          ),
          ChatMessage(
            text: 'Привет всем! Рад присоединиться к обсуждению!',
            sender: 'Алексей Петров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            avatarColor: Colors.blue,
          ),
          ChatMessage(
            text: 'Кто уже смотрел последний матч? Какие мысли?',
            sender: 'Мария Иванова',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            avatarColor: Colors.pink,
          ),
          ChatMessage(
            text: 'Отличная игра была! Особенно понравилась стратегия команды.',
            sender: 'Иван Сидоров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            avatarColor: Colors.green,
          ),
          ChatMessage(
            text: 'А как вам гол на 89-й минуте? Просто великолепно! ⚽',
            sender: 'Алексей Петров',
            time: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false,
            avatarColor: Colors.blue,
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

    // Обновляем статистику комнаты
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    roomProvider.addMessageToRoom(widget.room.id);

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          sender: widget.userName,
          time: DateTime.now(),
          isMe: true,
          avatarColor: const Color(0xFF396AA3),
        ),
      );
      _messageController.clear();
      _isTyping = false;
      _typingUser = '';
    });

    // Имитация ответа
    _simulateAIResponse(text);

    _scrollToBottom();
  }

  void _simulateAIResponse(String userMessage) {
    String response = '';

    if (userMessage.toLowerCase().contains('привет') || userMessage.toLowerCase().contains('hello')) {
      response = 'Привет! Рад видеть вас в чате! 😊';
    } else if (userMessage.toLowerCase().contains('матч') || userMessage.toLowerCase().contains('игра')) {
      response = 'Да, матч был захватывающий! Особенно впечатлила игра полузащиты.';
    } else if (userMessage.toLowerCase().contains('погод') || userMessage.toLowerCase().contains('weather')) {
      response = 'Сегодня отличная погода для футбола! ☀️';
    } else if (userMessage.toLowerCase().contains('спасибо') || userMessage.toLowerCase().contains('thanks')) {
      response = 'Всегда пожалуйста! Есть вопросы - задавайте! 👍';
    } else {
      // Генерация случайного ответа
      final responses = [
        'Интересная мысль! Что еще думаете по этому поводу?',
        'Согласен с вами! Добавлю, что важна также командная работа.',
        'Хороший вопрос! Давайте обсудим это подробнее.',
        'Отличное наблюдение! 🎯',
        'Интересная точка зрения! Я бы добавил...'
      ];
      response = responses[DateTime.now().millisecond % responses.length];
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final aiUsers = ['Алексей Петров', 'Мария Иванова', 'Иван Сидоров'];
      final aiUser = aiUsers[DateTime.now().second % aiUsers.length];

      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            sender: aiUser,
            time: DateTime.now().add(const Duration(seconds: 1)),
            isMe: false,
            avatarColor: aiUser == 'Алексей Петров' ? Colors.blue :
            aiUser == 'Мария Иванова' ? Colors.pink : Colors.green,
          ),
        );
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
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      _showScrollToBottom = (maxScroll - currentScroll) > screenHeight * 0.3;
    });
  }

  void _showRoomInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Хэндл для drag
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildRoomHeader(),
                    const SizedBox(height: 24),
                    _buildRoomStats(),
                    const SizedBox(height: 24),
                    _buildRoomDescription(),
                    const SizedBox(height: 24),
                    _buildRoomRules(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(widget.room.imageUrl),
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
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${NumberFormatting(widget.room.participants).formatCount()} участников',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.chat, 'Сообщения', NumberFormatting(widget.room.messages).formatCount()),
          _buildStatItem(Icons.access_time, 'Активность', _getLastActivity()),
          _buildStatItem(Icons.star, 'Рейтинг', widget.room.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF396AA3), size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRoomDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Описание',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.room.description,
          style: TextStyle(color: Colors.grey[700], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildRoomRules() {
    if (widget.room.rules.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Правила комнаты',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.room.rules,
          style: TextStyle(color: Colors.grey[700], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
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
              backgroundColor: const Color(0xFF396AA3),
              foregroundColor: Colors.white,
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

  // ... остальные методы (_showMessageOptions, _buildMessageBubble) остаются аналогичными

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF396AA3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _showRoomInfo,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.room.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    _buildOnlineIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              smallSize: 8,
              backgroundColor: Colors.green,
              child: const Icon(Icons.people, color: Color(0xFF396AA3)),
            ),
            onPressed: _showRoomInfo,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF396AA3)),
            onSelected: (value) {
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
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'info', child: Text('Информация о комнате')),
              const PopupMenuItem(value: 'members', child: Text('Участники')),
              const PopupMenuItem(value: 'share', child: Text('Поделиться')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF396AA3))),

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

                      return _buildMessageBubble(message, showAvatar);
                    } else {
                      return _buildTypingIndicator();
                    }
                  },
                ),

                if (_showScrollToBottom)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: const Color(0xFF396AA3),
                      onPressed: _scrollToBottom,
                      child: const Icon(Icons.arrow_downward, size: 20, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // Индикатор набора сообщения
          if (_typingUser.isNotEmpty) _buildTypingIndicatorBar(),

          // Поле ввода
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    final onlineCount = (widget.room.participants * 0.2).round(); // 20% онлайн
    return Text(
      '$onlineCount онлайн • ${NumberFormatting(widget.room.participants).formatCount()} участников',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
      ),
    );
  }

  Widget _buildTypingIndicatorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$_typingUser печатает...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildTypingDot(0),
                _buildTypingDot(1),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF396AA3), size: 28),
            onPressed: _showAttachmentMenu,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined,
                            color: Color(0xFF396AA3)),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file,
                            color: Color(0xFF396AA3)),
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
          CircleAvatar(
            backgroundColor: const Color(0xFF396AA3),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.green),
                title: const Text('Фотография'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Добавить выбор фото
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.blue),
                title: const Text('Видео'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Добавить выбор видео
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.orange),
                title: const Text('Файл'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Добавить выбор файла
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('Местоположение'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Добавить выбор локации
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMembers() {
    // TODO: Реализовать экран участников
  }




  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!message.isMe)
                ListTile(
                  leading: const Icon(Icons.reply, color: Colors.blue),
                  title: const Text('Ответить'),
                  onTap: () {
                    Navigator.pop(context);
                    _replyToMessage(message);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.green),
                title: const Text('Скопировать текст'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessageText(message);
                },
              ),
              if (message.isMe)
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.orange),
                  title: const Text('Редактировать'),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                ),
              if (message.isMe)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Удалить'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.purple),
                title: const Text('Пожаловаться'),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(message);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Вспомогательные методы для опций сообщения
  void _replyToMessage(ChatMessage message) {
    _messageController.text = '@${message.sender} ';
    _messageFocusNode.requestFocus();
  }

  void _copyMessageText(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Текст скопирован')),
    );
  }

  void _editMessage(ChatMessage message) {
    _messageController.text = message.text;
    _messageFocusNode.requestFocus();

    // Удаляем оригинальное сообщение
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

  void _reportMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на сообщение'),
        content: const Text('Расскажите о проблеме с этим сообщением'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Реализовать отправку жалобы
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Жалоба отправлена')),
              );
              Navigator.pop(context);
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }









  Widget _buildMessageBubble(ChatMessage message, bool showAvatar) {
    final isSystem = message.messageType == MessageType.system;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isSystem)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!message.isMe && showAvatar)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.isMe
                            ? const Color(0xFF396AA3)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: message.isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!message.isMe && showAvatar)
                            Text(
                              message.sender,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (!message.isMe && showAvatar) const SizedBox(height: 4),
                          Text(
                            message.text,
                            style: TextStyle(
                              color: message.isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (message.isMe) const SizedBox(width: 8),
                  if (message.isMe && showAvatar)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF396AA3),
                      child: Text(
                        widget.userName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            if (!isSystem)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                child: Text(
                  DateFormat.Hm().format(message.time),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class ChatMessage {
  final String text;
  final String sender;
  final DateTime time;
  final bool isMe;
  final MessageType messageType;
  final Color? avatarColor;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
    this.messageType = MessageType.text,
    this.avatarColor,
  });
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

String _getLastActivity() {
  // TODO: Реализовать логику определения последней активности
  return 'только что';
}