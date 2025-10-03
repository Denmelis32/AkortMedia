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

  // Новые поля для статистики и информации о сессии
  final String title;
  final String? description;
  final DateTime createdAt;
  final int totalMemberCount;
  final int totalMessageCount;
  final bool isActive;
  final String? coverImage;
  final List<String>? tags;
  final int onlineMembers;
  final int todayMessages;
  final int pinnedMessages;
  final int activeBots;

  const ChatSession({
    required this.roomId,
    required this.messages,
    required this.members,
    required this.settings,
    required this.lastUpdate,
    this.isLoading = false,
    this.hasMoreMessages = true,
    // Новые поля
    required this.title,
    this.description,
    required this.createdAt,
    required this.totalMemberCount,
    required this.totalMessageCount,
    this.isActive = true,
    this.coverImage,
    this.tags,
    this.onlineMembers = 0,
    this.todayMessages = 0,
    this.pinnedMessages = 0,
    this.activeBots = 0,
  });

  ChatSession copyWith({
    String? roomId,
    List<ChatMessage>? messages,
    Map<String, ChatMember>? members,
    ChatSettings? settings,
    DateTime? lastUpdate,
    bool? isLoading,
    bool? hasMoreMessages,
    String? title,
    String? description,
    DateTime? createdAt,
    int? totalMemberCount,
    int? totalMessageCount,
    bool? isActive,
    String? coverImage,
    List<String>? tags,
    int? onlineMembers,
    int? todayMessages,
    int? pinnedMessages,
    int? activeBots,
  }) {
    return ChatSession(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      members: members ?? this.members,
      settings: settings ?? this.settings,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isLoading: isLoading ?? this.isLoading,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      totalMemberCount: totalMemberCount ?? this.totalMemberCount,
      totalMessageCount: totalMessageCount ?? this.totalMessageCount,
      isActive: isActive ?? this.isActive,
      coverImage: coverImage ?? this.coverImage,
      tags: tags ?? this.tags,
      onlineMembers: onlineMembers ?? this.onlineMembers,
      todayMessages: todayMessages ?? this.todayMessages,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      activeBots: activeBots ?? this.activeBots,
    );
  }

  // Вспомогательные методы
  List<ChatMessage> get pinnedMessagesList =>
      messages.where((msg) => msg.isPinned).toList();

  List<ChatMessage> get unreadMessages =>
      messages.where((msg) => msg.status == MessageStatus.delivered).toList();

  int get currentMessagesCount => messages.length;

  bool get hasUnreadMessages => unreadMessages.isNotEmpty;

  List<ChatMember> get onlineMembersList =>
      members.values.where((member) => member.isOnline).toList();

  List<ChatMember> get offlineMembersList =>
      members.values.where((member) => !member.isOnline).toList();

  ChatMember? getMember(String userId) => members[userId];

  // Статистика активности
  double get activityLevel {
    if (totalMessageCount == 0) return 0.0;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    if (daysSinceCreation == 0) return 1.0;
    return totalMessageCount / daysSinceCreation / 10.0;
  }

  String get activityStatus {
    final now = DateTime.now();
    final lastActive = now.difference(lastUpdate);

    if (lastActive.inMinutes < 5) return 'Online';
    if (lastActive.inHours < 1) return 'Был(а) ${lastActive.inMinutes} мин назад';
    if (lastActive.inHours < 24) return 'Был(а) ${lastActive.inHours} ч назад';
    return 'Был(а) ${lastActive.inDays} д назад';
  }

  // Для отображения в UI
  String get displayMembers {
    if (totalMemberCount == 0) return 'Нет участников';
    if (totalMemberCount == 1) return '1 участник';
    if (totalMemberCount < 5) return '$totalMemberCount участника';
    return '$totalMemberCount участников';
  }

  String get displayMessages {
    if (totalMessageCount == 0) return 'Нет сообщений';
    if (totalMessageCount == 1) return '1 сообщение';
    if (totalMessageCount < 5) return '$totalMessageCount сообщения';
    return '$totalMessageCount сообщений';
  }

  String get displayOnline {
    if (onlineMembers == 0) return 'Нет в сети';
    if (onlineMembers == 1) return '1 онлайн';
    return '$onlineMembers онлайн';
  }

  // Информация о ботах
  bool get hasActiveBots => activeBots > 0;

  String get botsInfo {
    if (activeBots == 0) return 'Боты отключены';
    if (activeBots == 1) return '1 активный бот';
    return '$activeBots активных ботов';
  }

  // Для пагинации
  ChatSession startLoading() => copyWith(isLoading: true);
  ChatSession stopLoading() => copyWith(isLoading: false);
  ChatSession setHasMoreMessages(bool value) => copyWith(hasMoreMessages: value);

  // Обновление статистики
  ChatSession updateStats({
    int? onlineMembers,
    int? todayMessages,
    int? pinnedMessages,
    int? activeBots,
  }) {
    return copyWith(
      onlineMembers: onlineMembers,
      todayMessages: todayMessages,
      pinnedMessages: pinnedMessages,
      activeBots: activeBots,
    );
  }

  // Для дебаггинга
  @override
  String toString() {
    return 'ChatSession{roomId: $roomId, title: $title, members: $totalMemberCount, messages: $totalMessageCount, online: $onlineMembers, bots: $activeBots}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatSession &&
              runtimeType == other.runtimeType &&
              roomId == other.roomId;

  @override
  int get hashCode => roomId.hashCode;
}