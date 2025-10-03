// utils/chat_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';

import '../../../services/chat_service.dart';
import '../../rooms_pages/models/room.dart';
import '../models/chat_message.dart';
import '../models/chat_member.dart';
import '../models/chat_settings.dart';
import '../models/enums.dart';

class ChatNavigation {
  final BuildContext context;
  final Room room;
  final String userName;
  final String userAvatar;
  final List<ChatMessage> messages;
  final Function(void Function()) updateState;
  final VoidCallback scrollToBottom;
  final VoidCallback? onMessagesUpdated;

  final Random _random = Random();
  final List<String> _availableReactions = ['❤️', '😂', '😮', '😢', '👍', '👎', '🔥', '🎉'];
  final Map<String, String> _translationCache = {};
  final Map<String, Color> _userColors = {};
  final ChatService _chatService = ChatService();

  // Новые поля для управления ботами
  List<ChatBot> _availableBots = [];
  List<ChatBot> _activeBots = [];
  ChatSettings _chatSettings = ChatSettings(
    id: 'default',
    enableBotResponses: true,
    translationEnabled: false,
    soundEnabled: true,
    vibrationEnabled: true,
    fontSize: 16.0,
    theme: ThemeMode.light,
  );

  ChatNavigation({
    required this.context,
    required this.room,
    required this.userName,
    required this.userAvatar,
    required this.messages,
    required this.updateState,
    required this.scrollToBottom,
    this.onMessagesUpdated,
  }) {
    _initializeChatService();
  }

  Future<void> _initializeChatService() async {
    try {
      await _chatService.initialize();

      // Загружаем настройки и ботов
      _chatSettings = await _chatService.getChatSettings(room.id);
      _availableBots = _chatService.getAvailableBots();
      _activeBots = await _chatService.getActiveBots(room.id);

      // Подписываемся на обновления сообщений
      _setupMessageStream();

      print('✅ ChatService инициализирован для комнаты ${room.id}');
      print('🤖 Доступно ботов: ${_availableBots.length}, активных: ${_activeBots.length}');

    } catch (e) {
      print('❌ Ошибка инициализации ChatService: $e');
    }
  }

  void _setupMessageStream() {
    _chatService.watchRoomMessages(room.id).listen((newMessages) {
      print('📨 Получены новые сообщения из потока: ${newMessages.length}');

      updateState(() {
        messages.clear();
        messages.addAll(newMessages);
      });

      onMessagesUpdated?.call();
      scrollToBottom();
    });
  }

  List<String> get availableReactions => _availableReactions;

  // Геттеры для ботов и настроек
  List<ChatBot> get availableBots => _availableBots;
  List<ChatBot> get activeBots => _activeBots;
  ChatSettings get chatSettings => _chatSettings;

  Color _getUserColor(String userName, Map<String, Color> userColors) {
    if (!userColors.containsKey(userName)) {
      userColors[userName] = Colors.primaries[_random.nextInt(Colors.primaries.length)].shade600;
    }
    return userColors[userName]!;
  }

  // === ОСНОВНЫЕ МЕТОДЫ ЧАТА ===

  Future<void> loadInitialData() async {
    try {
      print('🔄 Загрузка начальных данных для комнаты ${room.id}');

      // Загружаем сообщения через сервис
      final loadedMessages = await _chatService.loadMessages(room.id, limit: 50);

      updateState(() {
        messages.clear();
        messages.addAll(loadedMessages);
      });

      print('✅ Загружено ${messages.length} сообщений');

    } catch (e) {
      print('❌ Ошибка загрузки начальных данных: $e');
      // Загружаем демо-сообщения при ошибке
      _loadDemoMessages();
    }
  }

  void _loadDemoMessages() {
    final demoMessages = [
      ChatMessage(
        id: '1',
        roomId: room.id,
        text: 'Добро пожаловать в "${room.title}"! 🎉\nЗдесь обсуждаем последние спортивные события и матчи.',
        sender: 'Система',
        time: DateTime.now().subtract(const Duration(minutes: 2)),
        isMe: false,
        messageType: MessageType.system,
      ),
      ChatMessage(
        id: '2',
        roomId: room.id,
        text: 'Привет всем! Рад присоединиться к обсуждению! 👋',
        sender: 'Алексей Петров',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        userColor: _getUserColor('Алексей Петров', _userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
      ChatMessage(
        id: '3',
        roomId: room.id,
        text: 'Как вам вчерашний матч? Отличная игра была! ⚽',
        sender: 'Мария Иванова',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        userColor: _getUserColor('Мария Иванова', _userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=2',
      ),
    ];

    updateState(() {
      messages.clear();
      messages.addAll(demoMessages);
    });
  }

  Future<List<ChatMember>> loadRoomMembers() async {
    try {
      return await _chatService.loadRoomMembers(room.id);
    } catch (e) {
      print('❌ Ошибка загрузки участников: $e');
      return _loadDemoMembers();
    }
  }

  List<ChatMember> _loadDemoMembers() {
    return [
      ChatMember(
        id: '1',
        name: 'Алексей Петров',
        avatar: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
        role: MemberRole.admin,
        lastSeen: DateTime.now(),
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ChatMember(
        id: '2',
        name: 'Мария Иванова',
        avatar: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
        role: MemberRole.moderator,
        lastSeen: DateTime.now(),
        joinDate: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ChatMember(
        id: '3',
        name: 'Иван Сидоров',
        avatar: 'https://i.pravatar.cc/150?img=3',
        isOnline: false,
        role: MemberRole.member,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        joinDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  // === ОТПРАВКА СООБЩЕНИЙ И УПРАВЛЕНИЕ БОТАМИ ===

  Future<void> sendMessage({
    required TextEditingController messageController,
    required ChatMessage? replyingTo,
    required ChatMessage? editingMessage,
    required VoidCallback onMessageSent,
  }) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    print('📤 Пользователь "$userName" отправляет сообщение: "$text"');

    try {
      ChatMessage sentMessage;

      if (editingMessage != null) {
        // Редактирование сообщения
        sentMessage = await _chatService.editMessage(
            editingMessage.id,
            text,
            room.id
        );

        updateState(() {
          final index = messages.indexWhere((msg) => msg.id == editingMessage.id);
          if (index != -1) {
            messages[index] = sentMessage;
          }
        });

      } else {
        // Новое сообщение
        final newMessage = ChatMessage(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          roomId: room.id,
          text: text,
          sender: userName,
          time: DateTime.now(),
          isMe: true,
          replyTo: replyingTo,
          userColor: _getUserColor(userName, _userColors),
          userAvatar: userAvatar,
          status: MessageStatus.sending,
        );

        // Добавляем сообщение локально сразу
        updateState(() {
          messages.add(newMessage);
        });

        // Отправляем через сервис
        sentMessage = await _chatService.sendMessage(newMessage);

        // Обновляем сообщение с сервера
        updateState(() {
          final index = messages.indexWhere((msg) => msg.id == newMessage.id);
          if (index != -1) {
            messages[index] = sentMessage;
          }
        });
      }

      messageController.clear();
      onMessageSent();
      scrollToBottom();

      print('✅ Сообщение отправлено: ${sentMessage.text}');

    } catch (e) {
      print('❌ Ошибка отправки сообщения: $e');
      showSnackBar('Ошибка отправки сообщения');

      // Помечаем сообщение как неотправленное
      if (editingMessage == null) {
        updateState(() {
          final lastMessage = messages.lastWhere(
                  (msg) => msg.id.startsWith('temp-'),
              orElse: () => messages.last
          );
          final errorIndex = messages.indexOf(lastMessage);
          if (errorIndex != -1) {
            messages[errorIndex] = lastMessage.copyWith(
                status: MessageStatus.error
            );
          }
        });
      }
    }
  }

  // === УПРАВЛЕНИЕ БОТАМИ ===

  Future<void> toggleBot(String botId, bool active) async {
    try {
      await _chatService.toggleBot(botId, active);

      // Обновляем локальный список активных ботов
      _activeBots = await _chatService.getActiveBots(room.id);

      updateState(() {}); // Перерисовываем UI

      showSnackBar(active ?
      '🤖 Бот активирован' :
      '🤖 Бот деактивирован'
      );

      print('${active ? '✅' : '❌'} Бот $botId ${active ? 'активирован' : 'деактивирован'}');

    } catch (e) {
      print('❌ Ошибка при переключении бота: $e');
      showSnackBar('Ошибка при управлении ботом');
    }
  }

  Future<void> updateChatSettings(ChatSettings newSettings) async {
    try {
      await _chatService.updateChatSettings(room.id, newSettings);
      _chatSettings = newSettings;

      updateState(() {}); // Перерисовываем UI

      showSnackBar('⚙️ Настройки обновлены');
      print('✅ Настройки чата обновлены');

    } catch (e) {
      print('❌ Ошибка при обновлении настроек: $e');
      showSnackBar('Ошибка при обновлении настроек');
    }
  }

  // === РЕАКЦИИ И ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ ===

  Future<void> addReaction(String messageId, String reaction) async {
    try {
      final updatedReactions = await _chatService.addReaction(
          messageId,
          room.id,
          reaction,
          userName
      );

      if (updatedReactions != null) {
        updateState(() {
          final index = messages.indexWhere((msg) => msg.id == messageId);
          if (index != -1) {
            messages[index] = messages[index].copyWith(
                reactions: updatedReactions
            );
          }
        });

        print('✅ Реакция $reaction добавлена к сообщению $messageId');
      }

    } catch (e) {
      print('❌ Ошибка при добавлении реакции: $e');
      showSnackBar('Ошибка при добавлении реакции');
    }
  }

  Future<void> toggleMessagePin(String messageId) async {
    try {
      final success = await _chatService.toggleMessagePin(messageId, room.id);

      if (success) {
        updateState(() {
          final index = messages.indexWhere((msg) => msg.id == messageId);
          if (index != -1) {
            messages[index] = messages[index].copyWith(
                isPinned: !messages[index].isPinned
            );
          }
        });

        showSnackBar(messages.firstWhere((msg) => msg.id == messageId).isPinned ?
        '📌 Сообщение закреплено' :
        '📌 Сообщение откреплено'
        );
      }

    } catch (e) {
      print('❌ Ошибка при закреплении сообщения: $e');
      showSnackBar('Ошибка при закреплении сообщения');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final success = await _chatService.deleteMessage(messageId, room.id);

      if (success) {
        updateState(() {
          messages.removeWhere((msg) => msg.id == messageId);
        });

        showSnackBar('🗑️ Сообщение удалено');
        print('✅ Сообщение $messageId удалено');
      }

    } catch (e) {
      print('❌ Ошибка при удалении сообщения: $e');
      showSnackBar('Ошибка при удалении сообщения');
    }
  }

  // === ПОИСК И ПЕРЕВОД ===

  Future<List<ChatMessage>> searchMessages(String query) async {
    try {
      return await _chatService.searchMessages(room.id, query);
    } catch (e) {
      print('❌ Ошибка при поиске сообщений: $e');
      return [];
    }
  }

  Future<List<ChatMessage>> getPinnedMessages() async {
    try {
      return await _chatService.getPinnedMessages(room.id);
    } catch (e) {
      print('❌ Ошибка при получении закрепленных сообщений: $e');
      return [];
    }
  }

  Future<String?> translateMessage(ChatMessage message) async {
    try {
      return await _chatService.translateMessage(message.text, 'en');
    } catch (e) {
      print('❌ Ошибка при переводе сообщения: $e');
      return null;
    }
  }

  // === СТАТИСТИКА И АНАЛИТИКА ===

  Future<Map<String, dynamic>> getRoomStats() async {
    try {
      return await _chatService.getRoomStats(room.id);
    } catch (e) {
      print('❌ Ошибка при получении статистики: $e');
      return {
        'totalMessages': messages.length,
        'totalMembers': 0,
        'onlineMembers': 0,
        'todayMessages': 0,
        'pinnedMessages': 0,
        'activeBots': _activeBots.length,
      };
    }
  }

  // === ТЕСТИРОВАНИЕ И ДЕМО-ФУНКЦИИ ===

  void triggerTestBotResponse(String testMessage) {
    print('🔧 Тестовый вызов ботов для сообщения: "$testMessage"');

    // Создаем тестовое сообщение для триггера ботов
    final testUserMessage = ChatMessage(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      roomId: room.id,
      text: testMessage,
      sender: 'Тестовый пользователь',
      time: DateTime.now(),
      isMe: false,
      userColor: Colors.grey,
      userAvatar: '👤',
    );

    // Отправляем через сервис для активации ботов
    _chatService.sendMessage(testUserMessage);
  }

  void sendSticker(String sticker) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: room.id,
      text: sticker,
      sender: userName,
      time: DateTime.now(),
      isMe: true,
      messageType: MessageType.sticker,
      userColor: _getUserColor(userName, _userColors),
      userAvatar: userAvatar,
    );

    _chatService.sendMessage(newMessage);
  }

  Future<void> sendVoiceMessage(double recordingTime) async {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: room.id,
      text: '🎵 Голосовое сообщение',
      sender: userName,
      time: DateTime.now(),
      isMe: true,
      messageType: MessageType.voice,
      userColor: _getUserColor(userName, _userColors),
      userAvatar: userAvatar,
      voiceDuration: recordingTime,
    );

    _chatService.sendMessage(newMessage);
  }

  // === UI ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  void showEnhancedMessageOptions({
    required ChatMessage message,
    required ThemeData theme,
    required VoidCallback onReply,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleSelection,
    required Function(String) onToggleExpansion,
    required VoidCallback onTranslate,
    required VoidCallback onPin,
    required VoidCallback onUnpin,
    required Function(String) onAddReaction,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMessageOptionsDialog(
        message: message,
        theme: theme,
        onReply: onReply,
        onEdit: onEdit,
        onDelete: onDelete,
        onToggleSelection: onToggleSelection,
        onToggleExpansion: onToggleExpansion,
        onTranslate: onTranslate,
        onPin: onPin,
        onUnpin: onUnpin,
        onAddReaction: onAddReaction,
      ),
    );
  }

  Widget _buildMessageOptionsDialog({
    required ChatMessage message,
    required ThemeData theme,
    required VoidCallback onReply,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleSelection,
    required Function(String) onToggleExpansion,
    required VoidCallback onTranslate,
    required VoidCallback onPin,
    required VoidCallback onUnpin,
    required Function(String) onAddReaction,
  }) {
    return Container(
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
            if (!message.isMe)
              _buildOptionTile(
                Icons.reply,
                'Ответить',
                'Ответить на это сообщение',
                onReply,
                theme,
              ),
            _buildOptionTile(
              Icons.copy,
              'Скопировать текст',
              'Скопировать текст сообщения',
                  () => _copyMessageText(message),
              theme,
            ),
            if (message.messageType == MessageType.text)
              _buildOptionTile(
                Icons.translate,
                'Перевести',
                'Перевести сообщение на английский',
                onTranslate,
                theme,
              ),
            _buildOptionTile(
              Icons.emoji_emotions_outlined,
              'Добавить реакцию',
              'Выбрать эмодзи для реакции',
                  () => _showReactionPicker(message, onAddReaction, theme),
              theme,
            ),
            if (message.isPinned)
              _buildOptionTile(
                Icons.push_pin,
                'Открепить',
                'Убрать сообщение из закрепленных',
                onUnpin,
                theme,
              )
            else
              _buildOptionTile(
                Icons.push_pin,
                'Закрепить',
                'Закрепить это сообщение',
                onPin,
                theme,
              ),
            _buildOptionTile(
              Icons.select_all,
              'Выбрать',
              'Выбрать несколько сообщений',
              onToggleSelection,
              theme,
            ),
            if (message.isMe)
              _buildOptionTile(
                Icons.edit,
                'Редактировать',
                'Изменить текст сообщения',
                onEdit,
                theme,
              ),
            if (message.isMe)
              _buildOptionTile(
                Icons.delete,
                'Удалить',
                'Удалить это сообщение',
                onDelete,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Отмена'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ThemeData theme,
      {bool isDestructive = false}
      ) {
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
      title: Text(
          title,
          style: TextStyle(color: isDestructive ? theme.colorScheme.error : null)
      ),
      subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          )
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showReactionPicker(
      ChatMessage message,
      Function(String) onAddReaction,
      ThemeData theme
      ) {
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
                        onAddReaction(emoji);
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

  Widget _buildUserAvatar(ChatMessage message, ThemeData theme) {
    if (message.userAvatar?.isNotEmpty == true && !message.userAvatar!.startsWith('http')) {
      // Для эмодзи аватаров ботов
      return Container(
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
        ),
        child: Center(
          child: Text(
            message.userAvatar!,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    } else if (message.userAvatar?.isNotEmpty == true) {
      // Для URL аватаров
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(message.userAvatar!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // Для обычных пользователей
      return Container(
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
        ),
        child: Center(
          child: Text(
            message.sender[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  void _copyMessageText(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text));
    showSnackBar('Текст скопирован');
  }

  void showBotManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.smart_toy),
                SizedBox(width: 8),
                Text('Управление ботами'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableBots.length,
                itemBuilder: (context, index) {
                  final bot = _availableBots[index];
                  final isActive = _activeBots.any((b) => b.id == bot.id);

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bot.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          bot.avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    title: Text(bot.name),
                    subtitle: Text(
                      bot.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Switch(
                      value: isActive,
                      onChanged: (value) {
                        toggleBot(bot.id, value);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          );
        },
      ),
    );
  }

  void showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text('Настройки чата'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Ответы ботов'),
                    subtitle: const Text('Разрешить ботам отвечать на сообщения'),
                    value: _chatSettings.enableBotResponses,
                    onChanged: (value) {
                      final newSettings = _chatSettings.copyWith(enableBotResponses: value);
                      updateChatSettings(newSettings);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Перевод сообщений'),
                    subtitle: const Text('Автоматический перевод сообщений'),
                    value: _chatSettings.translationEnabled,
                    onChanged: (value) {
                      final newSettings = _chatSettings.copyWith(translationEnabled: value);
                      updateChatSettings(newSettings);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Звуковые уведомления'),
                    subtitle: const Text('Воспроизводить звук при новых сообщениях'),
                    value: _chatSettings.soundEnabled,
                    onChanged: (value) {
                      final newSettings = _chatSettings.copyWith(soundEnabled: value);
                      updateChatSettings(newSettings);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Размер шрифта',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _chatSettings.fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    onChanged: (value) {
                      final newSettings = _chatSettings.copyWith(fontSize: value);
                      updateChatSettings(newSettings);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          );
        },
      ),
    );
  }

  // === ДОПОЛНИТЕЛЬНЫЕ UI МЕТОДЫ ===

  void showEnhancedAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Прикрепить файл',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildAttachmentOption(Icons.photo, 'Фото', () {}),
                    _buildAttachmentOption(Icons.videocam, 'Видео', () {}),
                    _buildAttachmentOption(Icons.audio_file, 'Аудио', () {}),
                    _buildAttachmentOption(Icons.insert_drive_file, 'Документ', () {}),
                    _buildAttachmentOption(Icons.location_on, 'Местоположение', () {}),
                    _buildAttachmentOption(Icons.contact_page, 'Контакт', () {}),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

  Widget _buildAttachmentOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStickersPanel({required Function(String) onStickerSelected}) {
    final stickerPacks = [
      ['😀', '😃', '😄', '😁', '😆'],
      ['😊', '😇', '🙂', '🙃', '😉'],
      ['😌', '😍', '🥰', '😘', '😗'],
      ['😙', '😚', '😋', '😛', '😝'],
    ];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: TabController(length: 4, vsync: Navigator.of(context)),
            isScrollable: true,
            tabs: List.generate(
                stickerPacks.length,
                    (index) => Tab(text: 'Pack ${index + 1}')
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: stickerPacks[0].length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onStickerSelected(stickerPacks[0][index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        stickerPacks[0][index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void dispose() {
    _translationCache.clear();
    _userColors.clear();
  }
}