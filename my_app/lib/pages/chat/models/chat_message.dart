// models/chat_message.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'enums.dart';

class ChatMessage {
  final String id;
  final String roomId;
  final String text;
  final String sender;
  final DateTime time;
  final bool isMe;
  final bool isEdited;
  final DateTime? editTime;
  final bool isPinned;
  final MessageType messageType;
  final MessageStatus status;
  final ChatMessage? replyTo;
  final Map<String, Set<String>>? reactions; // Изменено: reaction -> set of usernames
  final Color? userColor;
  final String? userAvatar;
  final double? voiceDuration;
  final double? playbackProgress;

  // Новые поля для ботов
  final bool isBot;
  final String? botId;
  final String? botPersonality;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
    this.isEdited = false,
    this.editTime,
    this.isPinned = false,
    this.messageType = MessageType.text,
    this.status = MessageStatus.sent,
    this.replyTo,
    this.reactions,
    this.userColor,
    this.userAvatar,
    this.voiceDuration,
    this.playbackProgress,
    // Новые параметры для ботов
    this.isBot = false,
    this.botId,
    this.botPersonality,
  });

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? text,
    String? sender,
    DateTime? time,
    bool? isMe,
    bool? isEdited,
    DateTime? editTime,
    bool? isPinned,
    MessageType? messageType,
    MessageStatus? status,
    ChatMessage? replyTo,
    Map<String, Set<String>>? reactions,
    Color? userColor,
    String? userAvatar,
    double? voiceDuration,
    double? playbackProgress,
    bool? isBot,
    String? botId,
    String? botPersonality,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      isEdited: isEdited ?? this.isEdited,
      editTime: editTime ?? this.editTime,
      isPinned: isPinned ?? this.isPinned,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      userColor: userColor ?? this.userColor,
      userAvatar: userAvatar ?? this.userAvatar,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      playbackProgress: playbackProgress ?? this.playbackProgress,
      isBot: isBot ?? this.isBot,
      botId: botId ?? this.botId,
      botPersonality: botPersonality ?? this.botPersonality,
    );
  }

  // Вспомогательные методы
  bool get hasReactions => reactions != null && reactions!.isNotEmpty;

  int get totalReactions {
    if (reactions == null) return 0;
    return reactions!.values.fold(0, (sum, users) => sum + users.length);
  }

  bool hasUserReacted(String userName, String reaction) {
    return reactions?[reaction]?.contains(userName) ?? false;
  }

  List<String> get userReactions {
    if (reactions == null) return [];
    return reactions!.entries
        .where((entry) => entry.value.contains(sender))
        .map((entry) => entry.key)
        .toList();
  }

  // Для отображения в UI
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин';
    if (difference.inHours < 24) return '${difference.inHours} ч';
    if (difference.inDays < 7) return '${difference.inDays} д';

    return DateFormat('dd.MM.yy').format(time);
  }

  // Дополнительные геттеры для ботов
  bool get isFromBot => isBot;

  String get botDisplayName {
    if (!isBot) return sender;
    return '$sender 🤖';
  }

  Color get effectiveColor {
    if (userColor != null) return userColor!;
    if (isBot) {
      // Цвета для разных типов ботов
      switch (botPersonality) {
        case 'analytical':
          return Colors.blue;
        case 'funny':
          return Colors.orange;
        case 'professional':
          return Colors.green;
        case 'knowledgeable':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }
    return Colors.blue; // Цвет по умолчанию для пользователей
  }

  // Для дебаггинга
  @override
  String toString() {
    return 'ChatMessage{id: $id, sender: $sender, text: $text, time: $time, status: $status, isBot: $isBot, botId: $botId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatMessage &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}