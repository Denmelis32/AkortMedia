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

  // Для дебаггинга
  @override
  String toString() {
    return 'ChatMessage{id: $id, sender: $sender, text: $text, time: $time, status: $status}';
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