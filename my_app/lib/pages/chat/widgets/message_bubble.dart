import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/message_status.dart';
import 'message_reactions.dart';
import 'reply_preview.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool showTimestamp;
  final Function(ChatMessage)? onReply;
  final Function(ChatMessage)? onReact;
  final Function(ChatMessage)? onLongPress;
  final String? avatarUrl; // Добавлен параметр для URL аватарки

  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.showTimestamp,
    this.onReply,
    this.onReact,
    this.onLongPress,
    this.avatarUrl,   // Добавлен в конструктор
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.author.id == 'current-user'; // TODO: Заменить на реальную проверку
    final hasReactions = message.hasReactions;
    final isPinned = message.isPinned;

    // Определяем URL аватарки: для текущего пользователя используем кастомную, для других - стандартную
    final effectiveAvatarUrl = isCurrentUser
        ? (avatarUrl ?? message.author.avatarUrl)
        : message.author.avatarUrl;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Timestamp если нужно
          if (showTimestamp)
            _buildTimestamp(),

          // Основной контент сообщения
          Row(
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар (для чужих сообщений)
              if (!isCurrentUser && showAvatar)
                _buildAvatar(effectiveAvatarUrl),

              // Пузырь сообщения
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: isCurrentUser ? 48 : 8,
                    right: isCurrentUser ? 8 : 48,
                  ),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Имя пользователя (для групповых чатов)
                      if (!isCurrentUser && showAvatar)
                        _buildUsername(),

                      // Превью ответа
                      if (message.isReply && message.replyTo != null)
                        ReplyPreview(
                          replyTo: message.replyTo!,
                          onTap: () => _scrollToMessage(message.replyTo!.id),
                        ),

                      // Основной пузырь
                      GestureDetector(
                        onLongPress: onLongPress != null
                            ? () => onLongPress!(message)
                            : null,
                        onDoubleTap: onReact != null
                            ? () => onReact!(message)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[100],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Текст сообщения
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),

                              // Статус сообщения (только для текущего пользователя)
                              if (isCurrentUser)
                                _buildMessageStatus(),

                              // Иконка закрепления
                              if (isPinned)
                                _buildPinIndicator(),
                            ],
                          ),
                        ),
                      ),

                      // Реакции
                      if (hasReactions)
                        MessageReactions(
                          reactions: message.reactions,
                          onReactionTap: onReact != null
                              ? () => onReact!(message)
                              : null,
                        ),
                    ],
                  ),
                ),
              ),

              // Аватар (для своих сообщений)
              if (isCurrentUser && showAvatar)
                _buildAvatar(effectiveAvatarUrl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        _formatTimestamp(message.timestamp),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey[300],
        backgroundImage: avatarUrl != null
            ? NetworkImage(avatarUrl)
            : null,
        child: avatarUrl == null
            ? Text(
          message.author.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildUsername() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 8),
      child: Text(
        message.author.name,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            _getStatusIcon(message.status),
            size: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildPinIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.push_pin, size: 12, color: Colors.amber),
          SizedBox(width: 4),
          Text(
            'Закреплено',
            style: TextStyle(
              fontSize: 10,
              color: Colors.amber,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.done;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Сегодня в ${_formatTime(timestamp)}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера в ${_formatTime(timestamp)}';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year} в ${_formatTime(timestamp)}';
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToMessage(String messageId) {
    // TODO: Реализовать скролл к сообщению
  }
}