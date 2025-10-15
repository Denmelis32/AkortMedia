import 'package:flutter/foundation.dart';

@immutable
class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? status;
  final Map<String, dynamic>? metadata;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
    this.status,
    this.metadata,
  });

  ChatUser copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
      'status': status,
      'metadata': metadata,
    };
  }

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSeen'])
          : null,
      status: json['status'],
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatUser &&
        other.id == id &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.isOnline == isOnline &&
        other.lastSeen == lastSeen &&
        other.status == status &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      avatarUrl,
      isOnline,
      lastSeen,
      status,
      metadata != null ? Object.hashAll(metadata!.entries) : null,
    );
  }

  String get displayName => name;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
}