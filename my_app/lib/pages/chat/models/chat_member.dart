// models/chat_member.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'enums.dart';

class ChatMember {
  final String id;
  final String name;
  final String? avatar;
  final bool isOnline;
  final MemberRole role;
  final DateTime lastSeen;
  final DateTime joinDate; // Обязательное поле
  final String? status;
  final bool isTyping;
  final int messageCount;

  const ChatMember({
    required this.id,
    required this.name,
    this.avatar,
    required this.isOnline,
    required this.role,
    required this.lastSeen,
    required this.joinDate, // Теперь обязательное
    this.status,
    this.isTyping = false,
    this.messageCount = 0,
  });

  ChatMember copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isOnline,
    MemberRole? role,
    DateTime? lastSeen,
    DateTime? joinDate,
    String? status,
    bool? isTyping,
    int? messageCount,
  }) {
    return ChatMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      role: role ?? this.role,
      lastSeen: lastSeen ?? this.lastSeen,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      isTyping: isTyping ?? this.isTyping,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  // Вспомогательные методы
  String get displayLastSeen {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (isOnline) return 'online';
    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 7) return '${difference.inDays} д назад';

    return DateFormat('dd.MM.yy').format(lastSeen);
  }

  String get memberSince {
    final now = DateTime.now();
    final difference = now.difference(joinDate);

    if (difference.inDays < 1) return 'сегодня';
    if (difference.inDays < 7) return '${difference.inDays} дней';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} недель';

    return '${(difference.inDays / 30).floor()} месяцев';
  }

  String get roleDisplayName {
    switch (role) {
      case MemberRole.admin:
        return 'Администратор';
      case MemberRole.moderator:
        return 'Модератор';
      case MemberRole.member:
        return 'Участник';
      case MemberRole.guest:
        return 'Гость';
    }
  }

  Color get roleColor {
    switch (role) {
      case MemberRole.admin:
        return Colors.red;
      case MemberRole.moderator:
        return Colors.orange;
      case MemberRole.member:
        return Colors.blue;
      case MemberRole.guest:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'ChatMember{id: $id, name: $name, role: $role, isOnline: $isOnline, joinDate: $joinDate}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatMember &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}