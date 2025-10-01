import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import '../../rooms_pages/models/room.dart';
import '../models/chat_message.dart';
import '../models/chat_member.dart';
import '../models/enums.dart';

class ChatNavigation {
  final BuildContext context;
  final Room room;
  final String userName;
  final String userAvatar;
  final List<ChatMessage> messages;
  final Function(void Function()) updateState;
  final VoidCallback scrollToBottom;

  final Random _random = Random();
  final List<String> _availableReactions = ['❤️', '😂', '😮', '😢', '👍', '👎', '🔥', '🎉'];

  ChatNavigation({
    required this.context,
    required this.room,
    required this.userName,
    required this.userAvatar,
    required this.messages,
    required this.updateState,
    required this.scrollToBottom,
  });

  List<String> get availableReactions => _availableReactions;

  Color _getUserColor(String userName, Map<String, Color> userColors) {
    if (!userColors.containsKey(userName)) {
      userColors[userName] = Colors.primaries[_random.nextInt(Colors.primaries.length)].shade600;
    }
    return userColors[userName]!;
  }

  void loadSampleMessages(Map<String, Color> userColors) {
    messages.addAll([
      ChatMessage(
        id: '1',
        text: 'Добро пожаловать в "${room.title}"! 🎉\nЗдесь обсуждаем последние спортивные события и матчи. Не стесняйтесь задавать вопросы и делиться мнениями!',
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
        userColor: _getUserColor('Алексей Петров', userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
      ChatMessage(
        id: '3',
        text: 'Кто уже смотрел последний матч? Какие мысли? ⚽',
        sender: 'Мария Иванова',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        reactions: {'❤️': 1, '🔥': 1},
        userColor: _getUserColor('Мария Иванова', userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=2',
      ),
      ChatMessage(
        id: '4',
        text: 'Отличная игра была! Особенно понравилась стратегия команды в защите. На мой взгляд, ключевым моментом стала замена на 70-й минуте.',
        sender: 'Иван Сидоров',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        userColor: _getUserColor('Иван Сидоров', userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=3',
      ),
      ChatMessage(
        id: '5',
        text: 'А как вам гол на 89-й минуте? Просто великолепно! 🥅',
        sender: 'Алексей Петров',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        isEdited: true,
        userColor: _getUserColor('Алексей Петров', userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
      ChatMessage(
        id: '6',
        text: 'Кстати, не пропустите завтрашний матч! Начинается в 20:00 по московскому времени. Будет очень интересно! 🏆',
        sender: 'Мария Иванова',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        userColor: _getUserColor('Мария Иванова', userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        isPinned: true,
      ),
      ChatMessage(
        id: '7',
        text: '🎵',
        sender: 'Алексей Петров',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        messageType: MessageType.voice,
        userColor: _getUserColor('Алексей Петров', userColors),
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        voiceDuration: 30,
      ),
    ]);
  }

  Future<RoomMembers> loadRoomMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Явно указываем тип для onlineMembers
    final List<ChatMember> onlineMembers = [
      ChatMember(
        id: '1',
        name: 'Алексей Петров',
        avatar: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
        role: MemberRole.admin,
        lastSeen: DateTime.now(),
      ),
      ChatMember(
        id: '2',
        name: 'Мария Иванова',
        avatar: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
        role: MemberRole.moderator,
        lastSeen: DateTime.now(),
      ),
      ChatMember(
        id: '3',
        name: 'Иван Сидоров',
        avatar: 'https://i.pravatar.cc/150?img=3',
        isOnline: true,
        role: MemberRole.member,
        lastSeen: DateTime.now(),
      ),
      ChatMember(
        id: '4',
        name: 'Екатерина Смирнова',
        avatar: 'https://i.pravatar.cc/150?img=4',
        isOnline: false,
        role: MemberRole.member,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    // Явно указываем тип для allMembers и используем правильный синтаксис
    final List<ChatMember> allMembers = [
      ...onlineMembers,
      ChatMember(
        id: '5',
        name: 'Дмитрий Козлов',
        avatar: 'https://i.pravatar.cc/150?img=5',
        isOnline: false,
        role: MemberRole.member,
        lastSeen: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Возвращаем RoomMembers с правильными типами
    return RoomMembers(
      onlineMembers: onlineMembers,
      allMembers: allMembers,
    );
  }

  void sendMessage({
    required TextEditingController messageController,
    required ChatMessage? replyingTo,
    required ChatMessage? editingMessage,
    required VoidCallback onMessageSent,
  }) {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: userName,
      time: DateTime.now(),
      isMe: true,
      replyTo: replyingTo,
      userColor: _getUserColor(userName, {}),
      userAvatar: userAvatar,
    );

    updateState(() {
      if (editingMessage != null) {
        final index = messages.indexWhere((msg) => msg.id == editingMessage.id);
        if (index != -1) {
          messages[index] = messages[index].copyWith(text: text, isEdited: true);
        }
      } else {
        messages.add(newMessage);
      }
      messageController.clear();
      onMessageSent();
    });

    if (editingMessage == null) {
      _simulateAIResponse(text);
    }
    scrollToBottom();
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
      if (!context.mounted) return;

      final aiUsers = ['Алексей Петров', 'Мария Иванова', 'Иван Сидоров'];
      final aiUser = aiUsers[DateTime.now().second % aiUsers.length];

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        sender: aiUser,
        time: DateTime.now().add(const Duration(seconds: 1)),
        isMe: false,
        userColor: _getUserColor(aiUser, {}),
        userAvatar: 'https://i.pravatar.cc/150?img=${aiUsers.indexOf(aiUser) + 1}',
      );

      updateState(() {
        messages.add(aiMessage);
      });
      scrollToBottom();
    });
  }

  void sendSticker(String sticker) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: sticker,
      sender: userName,
      time: DateTime.now(),
      isMe: true,
      messageType: MessageType.sticker,
      userColor: _getUserColor(userName, {}),
      userAvatar: userAvatar,
    );

    updateState(() {
      messages.add(newMessage);
    });
  }

  Future<void> sendVoiceMessage(double recordingTime) async {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '🎵 Голосовое сообщение',
      sender: userName,
      time: DateTime.now(),
      isMe: true,
      messageType: MessageType.voice,
      userColor: _getUserColor(userName, {}),
      userAvatar: userAvatar,
      voiceDuration: recordingTime.round(),
    );

    updateState(() {
      messages.add(newMessage);
    });
  }

  void startVoiceRecording(Function(double) onTimeUpdate) {
    double recordingTime = 0.0;

    void updateRecordingTime() {
      if (context.mounted) {
        recordingTime += 0.1;
        onTimeUpdate(recordingTime);

        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            updateRecordingTime();
          }
        });
      }
    }

    updateRecordingTime();
  }

  void simulateVoicePlayback(int duration, Function(double) onProgressUpdate) {
    double progress = 0.0;

    void updateProgress() {
      if (context.mounted && progress < 1.0) {
        progress += 0.1 / duration;
        onProgressUpdate(progress);

        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted && progress < 1.0) {
            updateProgress();
          }
        });
      }
    }

    updateProgress();
  }

  Future<String?> translateMessage(ChatMessage message) async {
    final translations = {
      'Привет всем! Рад присоединиться к обсуждению! 👋': 'Hello everyone! Glad to join the discussion! 👋',
      'Кто уже смотрел последний матч? Какие мысли? ⚽': 'Who has already watched the last match? Any thoughts? ⚽',
      'Отличная игра была!': 'It was a great game!',
      'А как вам гол на 89-й минуте? Просто великолепно! 🥅': 'What about the goal at the 89th minute? Just great! 🥅',
    };

    await Future.delayed(const Duration(milliseconds: 500));
    return translations[message.text] ?? 'Translation not available';
  }

  void addEmojiToMessage(TextEditingController messageController, String emoji) {
    final currentText = messageController.text;
    final selection = messageController.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    messageController.value = messageController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + emoji.length),
    );
  }

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
                'Перевести сообщение на русский',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap, ThemeData theme, {bool isDestructive = false}) {
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
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showReactionPicker(ChatMessage message, Function(String) onAddReaction, ThemeData theme) {
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

  Widget _buildUserAvatar(ChatMessage message, ThemeData theme) {
    if (message.userAvatar?.isNotEmpty == true) {
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
    } else {
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

  void deleteMessage({
    required ChatMessage message,
    required VoidCallback onDelete,
  }) {
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
              onDelete();
              Navigator.pop(context);
              showSnackBar('Сообщение удалено');
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void forwardSelectedMessages(int selectedCount) {
    showSnackBar('$selectedCount сообщений готовы к пересылке');
  }

  void deleteSelectedMessages(int selectedCount, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщения?'),
        content: Text('Вы уверены, что хотите удалить $selectedCount сообщений? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
              showSnackBar('Удалено $selectedCount сообщений');
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

  // Placeholder methods for other navigation actions
  void showEnhancedRoomInfo() {}
  void showRoomSettings() {}
  void inviteUsers() {}
  void showEnhancedAttachmentMenu() {}

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
            tabs: List.generate(stickerPacks.length, (index) => Tab(text: 'Pack ${index + 1}')),
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
}

class RoomMembers {
  final List<ChatMember> onlineMembers;
  final List<ChatMember> allMembers;

  RoomMembers({
    required this.onlineMembers,
    required this.allMembers,
  });
}