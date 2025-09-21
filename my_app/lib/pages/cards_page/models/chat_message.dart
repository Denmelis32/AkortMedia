// lib/pages/cards_page/models/chat_message.dart
class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String senderName;
  final String senderImageUrl;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.senderName = 'Пользователь',
    this.senderImageUrl = '',
  });
}