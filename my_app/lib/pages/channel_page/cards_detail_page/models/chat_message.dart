// lib/pages/cards_detail_page/models/chat_message.dart
class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String senderName;
  final String senderImageUrl;
  final String senderId; // Добавлено

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.senderName = 'Пользователь',
    this.senderImageUrl = '',
    required this.senderId, // Добавлено
  });
}