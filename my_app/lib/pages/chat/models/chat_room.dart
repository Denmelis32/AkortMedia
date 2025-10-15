import 'package:flutter/foundation.dart';
import 'chat_user.dart';
import 'chat_message.dart';

@immutable
class ChatRoom {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final List<ChatUser> participants;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isGroup;
  final DateTime createdAt;
  final ChatUser? createdBy;
  final List<ChatUser> admins;
  final Map<String, dynamic>? metadata;
  final bool isMuted;

  const ChatRoom({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    this.isGroup = false,
    required this.createdAt,
    this.createdBy,
    this.admins = const [],
    this.metadata,
    this.isMuted = false,
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    List<ChatUser>? participants,
    ChatMessage? lastMessage,
    int? unreadCount,
    bool? isGroup,
    DateTime? createdAt,
    ChatUser? createdBy,
    List<ChatUser>? admins,
    Map<String, dynamic>? metadata,
    bool? isMuted,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      admins: admins ?? this.admins,
      metadata: metadata ?? this.metadata,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy?.toJson(),
      'admins': admins.map((a) => a.toJson()).toList(),
      'metadata': metadata,
      'isMuted': isMuted,
    };
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      avatarUrl: json['avatarUrl'],
      participants: (json['participants'] as List)
          .map((p) => ChatUser.fromJson(p))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isGroup: json['isGroup'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      createdBy: json['createdBy'] != null
          ? ChatUser.fromJson(json['createdBy'])
          : null,
      admins: (json['admins'] as List?)
          ?.map((a) => ChatUser.fromJson(a))
          .toList() ?? [],
      metadata: json['metadata'],
      isMuted: json['isMuted'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoom &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.avatarUrl == avatarUrl &&
        listEquals(other.participants, participants) &&
        other.lastMessage == lastMessage &&
        other.unreadCount == unreadCount &&
        other.isGroup == isGroup &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        listEquals(other.admins, admins) &&
        mapEquals(other.metadata, metadata) &&
        other.isMuted == isMuted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      avatarUrl,
      Object.hashAll(participants),
      lastMessage,
      unreadCount,
      isGroup,
      createdAt,
      createdBy,
      Object.hashAll(admins),
      metadata != null ? Object.hashAll(metadata!.entries) : null,
      isMuted,
    );
  }

  bool get hasUnread => unreadCount > 0;
  bool get isDirect => !isGroup;
  int get participantsCount => participants.length;
  String get displayName => isDirect && participants.length == 2
      ? participants.firstWhere((p) => p.id != createdBy?.id).name
      : name;
}