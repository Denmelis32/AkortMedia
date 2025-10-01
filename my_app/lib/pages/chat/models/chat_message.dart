import 'package:flutter/material.dart';
import 'enums.dart';

class ChatMessage {
  final String id;
  final String text;
  final String sender;
  final DateTime time;
  final bool isMe;
  final MessageType messageType;
  final Map<String, int>? reactions;
  final Color? userColor;
  final String? userAvatar;
  final bool isEdited;
  final bool isPinned;
  final ChatMessage? replyTo;
  final int? voiceDuration;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
    this.messageType = MessageType.text,
    this.reactions,
    this.userColor,
    this.userAvatar,
    this.isEdited = false,
    this.isPinned = false,
    this.replyTo,
    this.voiceDuration,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    String? sender,
    DateTime? time,
    bool? isMe,
    MessageType? messageType,
    Map<String, int>? reactions,
    Color? userColor,
    String? userAvatar,
    bool? isEdited,
    bool? isPinned,
    ChatMessage? replyTo,
    int? voiceDuration,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      messageType: messageType ?? this.messageType,
      reactions: reactions ?? this.reactions,
      userColor: userColor ?? this.userColor,
      userAvatar: userAvatar ?? this.userAvatar,
      isEdited: isEdited ?? this.isEdited,
      isPinned: isPinned ?? this.isPinned,
      replyTo: replyTo ?? this.replyTo,
      voiceDuration: voiceDuration ?? this.voiceDuration,
    );
  }
}