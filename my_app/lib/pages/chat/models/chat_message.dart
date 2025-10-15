import 'package:flutter/foundation.dart';
import 'chat_user.dart';
import 'reaction.dart';
import 'message_status.dart';
import 'message_type.dart';

@immutable
class ChatMessage {
  final String id;
  final String text;
  final ChatUser author;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final List<Reaction> reactions;
  final ChatMessage? replyTo;
  final bool isPinned;
  final Map<String, dynamic>? metadata;
  final DateTime? expiresAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.author,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.reactions = const [],
    this.replyTo,
    this.isPinned = false,
    this.metadata,
    this.expiresAt,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatUser? author,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    List<Reaction>? reactions,
    ChatMessage? replyTo,
    bool? isPinned,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      replyTo: replyTo ?? this.replyTo,
      isPinned: isPinned ?? this.isPinned,
      metadata: metadata ?? this.metadata,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author.toJson(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.value,
      'status': status.value,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'replyTo': replyTo?.toJson(),
      'isPinned': isPinned,
      'metadata': metadata,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      author: ChatUser.fromJson(json['author']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      type: MessageType.values.firstWhere(
            (e) => e.value == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
            (e) => e.value == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      reactions: (json['reactions'] as List?)
          ?.map((r) => Reaction.fromJson(r))
          .toList() ?? [],
      replyTo: json['replyTo'] != null
          ? ChatMessage.fromJson(json['replyTo'])
          : null,
      isPinned: json['isPinned'] ?? false,
      metadata: json['metadata'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.text == text &&
        other.author == author &&
        other.timestamp == timestamp &&
        other.type == type &&
        other.status == status &&
        listEquals(other.reactions, reactions) &&
        other.replyTo == replyTo &&
        other.isPinned == isPinned &&
        mapEquals(other.metadata, metadata) &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      text,
      author,
      timestamp,
      type,
      status,
      Object.hashAll(reactions),
      replyTo,
      isPinned,
      metadata != null ? Object.hashAll(metadata!.entries) : null,
      expiresAt,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get hasReactions => reactions.isNotEmpty;
  bool get isReply => replyTo != null;
}