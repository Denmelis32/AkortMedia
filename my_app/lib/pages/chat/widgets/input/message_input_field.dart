import 'package:flutter/material.dart';
import '../../../rooms_pages/models/room.dart';
import '../../models/chat_message.dart';
import 'voice_recording_panel.dart';
import 'reactions_panel.dart';

class MessageInputField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final Room room;
  final bool isRecording;
  final bool showReactions;
  final ChatMessage? editingMessage;
  final List<String> availableReactions;
  final VoidCallback onSendMessage;
  final VoidCallback onStartVoiceRecording;
  final VoidCallback onStopVoiceRecording;
  final VoidCallback onSendVoiceMessage;
  final VoidCallback onToggleReactions;
  final VoidCallback onToggleStickers;
  final VoidCallback onShowAttachmentMenu;
  final Function(String) onAddEmoji;
  final double recordingTime;

  const MessageInputField({
    super.key,
    required this.theme,
    required this.messageController,
    required this.messageFocusNode,
    required this.room,
    required this.isRecording,
    required this.showReactions,
    this.editingMessage,
    required this.availableReactions,
    required this.onSendMessage,
    required this.onStartVoiceRecording,
    required this.onStopVoiceRecording,
    required this.onSendVoiceMessage,
    required this.onToggleReactions,
    required this.onToggleStickers,
    required this.onShowAttachmentMenu,
    required this.onAddEmoji,
    required this.recordingTime,
  });

  @override
  Widget build(BuildContext context) {
    if (isRecording) {
      return VoiceRecordingPanel(
        theme: theme,
        recordingTime: recordingTime,
        onStopRecording: onStopVoiceRecording,
        onSendVoiceMessage: onSendVoiceMessage,
      );
    }

    // Проверка доступности комнаты
    final isRoomAvailable = room.isActive && !room.isExpired && !room.isFull;

    if (!isRoomAvailable) {
      return _buildRoomUnavailablePanel();
    }

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Быстрые реакции для добавления в текущее сообщение
          if (showReactions)
            ReactionsPanel(
              theme: theme,
              availableReactions: availableReactions,
              onEmojiSelected: (emoji) {
                onAddEmoji(emoji);
                onToggleReactions();
              },
            ),

          Row(
            children: [
              // Кнопка прикрепления файлов
              _buildAttachmentButton(),

              const SizedBox(width: 8),

              // Поле ввода сообщения
              Expanded(
                child: _buildMessageInput(),
              ),

              const SizedBox(width: 8),

              // Кнопка отправки/записи
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(Icons.add, color: theme.primaryColor, size: 24),
        onPressed: onShowAttachmentMenu,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
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
        controller: messageController,
        focusNode: messageFocusNode,
        maxLines: 5,
        minLines: 1,
        decoration: InputDecoration(
          hintText: editingMessage != null ? 'Редактирование сообщения...' : 'Напишите сообщение...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.emoji_emotions_outlined, color: theme.primaryColor),
                onPressed: onToggleReactions,
              ),
              IconButton(
                icon: Icon(Icons.attach_file, color: theme.primaryColor),
                onPressed: onShowAttachmentMenu,
              ),
              IconButton(
                icon: Icon(Icons.face, color: theme.primaryColor),
                onPressed: onToggleStickers,
              ),
            ],
          ),
        ),
        onSubmitted: (_) => onSendMessage(),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      child: messageController.text.isEmpty
          ? _buildVoiceRecordButton()
          : _buildSendMessageButton(),
    );
  }

  Widget _buildVoiceRecordButton() {
    return Container(
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
        icon: const Icon(Icons.mic, color: Colors.white),
        onPressed: onStartVoiceRecording,
      ),
    );
  }

  Widget _buildSendMessageButton() {
    return Container(
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
        icon: Icon(editingMessage != null ? Icons.check : Icons.send, color: Colors.white),
        onPressed: onSendMessage,
      ),
    );
  }

  Widget _buildRoomUnavailablePanel() {
    String message;
    Color color;
    IconData icon;

    if (room.isExpired) {
      message = 'Эта комната завершена';
      color = Colors.grey;
      icon = Icons.timer_off;
    } else if (room.isFull) {
      message = 'Комната заполнена';
      color = Colors.orange;
      icon = Icons.person_off;
    } else if (!room.isActive) {
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
}