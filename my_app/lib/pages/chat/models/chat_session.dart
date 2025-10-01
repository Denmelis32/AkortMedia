// models/chat_session.dart
import 'package:intl/intl.dart';

import 'chat_member.dart';
import 'chat_message.dart';
import 'chat_settings.dart';
import 'enums.dart';

class ChatSession {
  final String roomId;
  final List<ChatMessage> messages;
  final Map<String, ChatMember> members;
  final ChatSettings settings;
  final DateTime lastUpdate;
  final bool isLoading;
  final bool hasMoreMessages;

  const ChatSession({
    required this.roomId,
    required this.messages,
    required this.members,
    required this.settings,
    required this.lastUpdate,
    this.isLoading = false,
    this.hasMoreMessages = true,
  });

  ChatSession copyWith({
    String? roomId,
    List<ChatMessage>? messages,
    Map<String, ChatMember>? members,
    ChatSettings? settings,
    DateTime? lastUpdate,
    bool? isLoading,
    bool? hasMoreMessages,
  }) {
    return ChatSession(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      members: members ?? this.members,
      settings: settings ?? this.settings,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isLoading: isLoading ?? this.isLoading,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
    );
  }

  // Вспомогательные методы
  List<ChatMessage> get pinnedMessages =>
      messages.where((msg) => msg.isPinned).toList();

  List<ChatMessage> get unreadMessages =>
      messages.where((msg) => msg.status == MessageStatus.delivered).toList();

  int get totalMessages => messages.length;

  bool get hasUnreadMessages => unreadMessages.isNotEmpty;

  List<ChatMember> get onlineMembers =>
      members.values.where((member) => member.isOnline).toList();

  List<ChatMember> get offlineMembers =>
      members.values.where((member) => !member.isOnline).toList();

  ChatMember? getMember(String userId) => members[userId];

  // Для пагинации
  ChatSession startLoading() => copyWith(isLoading: true);
  ChatSession stopLoading() => copyWith(isLoading: false);
  ChatSession setHasMoreMessages(bool value) => copyWith(hasMoreMessages: value);
}