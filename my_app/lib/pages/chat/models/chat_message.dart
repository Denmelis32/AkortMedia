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
  final DateTime? editedAt;
  final List<String> readBy;
  final String? roomId;

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
    this.editedAt,
    this.readBy = const [],
    this.roomId,
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
    DateTime? editedAt,
    List<String>? readBy,
    String? roomId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      reactions: reactions ?? List.from(this.reactions),
      replyTo: replyTo ?? this.replyTo,
      isPinned: isPinned ?? this.isPinned,
      metadata: metadata ?? (this.metadata != null ? Map.from(this.metadata!) : null),
      expiresAt: expiresAt ?? this.expiresAt,
      editedAt: editedAt ?? this.editedAt,
      readBy: readBy ?? List.from(this.readBy),
      roomId: roomId ?? this.roomId,
    );
  }

  // Упрощенный copyWith для часто изменяемых полей
  ChatMessage copyWithStatus(MessageStatus newStatus) => copyWith(status: newStatus);
  ChatMessage copyWithReactions(List<Reaction> newReactions) => copyWith(reactions: newReactions);
  ChatMessage copyWithPinned(bool pinned) => copyWith(isPinned: pinned);
  ChatMessage copyWithEdited(String newText) => copyWith(
    text: newText,
    editedAt: DateTime.now(),
  );
  ChatMessage copyWithReadBy(String userId) {
    final newReadBy = List<String>.from(readBy);
    if (!newReadBy.contains(userId)) {
      newReadBy.add(userId);
    }
    return copyWith(readBy: newReadBy);
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
      'editedAt': editedAt?.millisecondsSinceEpoch,
      'readBy': readBy,
      'roomId': roomId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      author: ChatUser.fromJson(json['author']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      type: MessageTypeExt.fromValue(json['type']),
      status: MessageStatusExt.fromValue(json['status']),
      reactions: (json['reactions'] as List?)
          ?.map((r) => Reaction.fromJson(r))
          .toList() ?? [],
      replyTo: json['replyTo'] != null
          ? ChatMessage.fromJson(json['replyTo'])
          : null,
      isPinned: json['isPinned'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int)
          : null,
      editedAt: json['editedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['editedAt'] as int)
          : null,
      readBy: (json['readBy'] as List?)?.cast<String>() ?? [],
      roomId: json['roomId'] as String?,
    );
  }

  // Создание временного сообщения (для оптимистичного обновления)
  factory ChatMessage.temporary({
    required String text,
    required ChatUser author,
    ChatMessage? replyTo,
    String? roomId,
  }) {
    return ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}_${author.id}',
      text: text,
      author: author,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      replyTo: replyTo,
      roomId: roomId,
    );
  }

  // Создание системного сообщения
  factory ChatMessage.system({
    required String text,
    String? roomId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: 'system_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      author: ChatUser(
        id: 'system',
        name: 'Система',
        isOnline: false,
      ),
      timestamp: DateTime.now(),
      type: MessageType.system,
      status: MessageStatus.read,
      roomId: roomId,
      metadata: metadata,
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
        other.expiresAt == expiresAt &&
        other.editedAt == editedAt &&
        listEquals(other.readBy, readBy) &&
        other.roomId == roomId;
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
      editedAt,
      Object.hashAll(readBy),
      roomId,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, text: ${text.length > 20 ? '${text.substring(0, 20)}...' : text}, author: ${author.name}, status: $status)';
  }

  // === COMPUTED PROPERTIES ===

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get hasReactions => reactions.isNotEmpty;
  bool get isReply => replyTo != null;
  bool get isEdited => editedAt != null;
  bool get isTemporary => id.startsWith('temp_');
  bool get isSystem => type == MessageType.system;
  bool get isFromCurrentUser => author.id == 'current-user';

  bool get isFailed => status == MessageStatus.failed;
  bool get isSending => status == MessageStatus.sending;
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isRead => status == MessageStatus.read;

  // Время редактирования в читаемом формате
  String get editTime {
    if (!isEdited) return '';
    final now = DateTime.now();
    final difference = now.difference(editedAt!);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inHours < 1) return '${difference.inMinutes} мин назад';
    if (difference.inDays < 1) return '${difference.inHours} ч назад';
    return '${difference.inDays} дн назад';
  }

  // Статистика реакций
  Map<String, int> get reactionStats {
    final stats = <String, int>{};
    for (final reaction in reactions) {
      stats[reaction.emoji] = (stats[reaction.emoji] ?? 0) + 1;
    }
    return stats;
  }

  // Проверка, поставил ли пользователь реакцию
  bool hasUserReacted(String userId, [String? emoji]) {
    if (emoji != null) {
      return reactions.any((r) => r.user.id == userId && r.emoji == emoji);
    }
    return reactions.any((r) => r.user.id == userId);
  }

  // Получение реакций пользователя
  List<String> getUserReactions(String userId) {
    return reactions
        .where((r) => r.user.id == userId)
        .map((r) => r.emoji)
        .toList();
  }

  // Проверка, прочитал ли пользователь сообщение
  bool isReadByUser(String userId) => readBy.contains(userId);

  // Количество прочитавших
  int get readCount => readBy.length;

  // Можно ли редактировать сообщение (в течение 15 минут)
  bool get canEdit {
    if (isSystem || isTemporary) return false;
    final timeSinceSent = DateTime.now().difference(timestamp);
    return timeSinceSent.inMinutes <= 15;
  }

  // Можно ли удалить сообщение (в течение 1 часа или всегда для текущего пользователя)
  bool get canDelete {
    if (isSystem) return false;
    if (isFromCurrentUser) return true;
    final timeSinceSent = DateTime.now().difference(timestamp);
    return timeSinceSent.inMinutes <= 60;
  }
}

// Extension для удобной работы с MessageType
extension MessageTypeExt on MessageType {
  static MessageType fromValue(dynamic value) {
    return MessageType.values.firstWhere(
          (e) => e.value == value,
      orElse: () => MessageType.text,
    );
  }
}

// Extension для удобной работы с MessageStatus
extension MessageStatusExt on MessageStatus {
  static MessageStatus fromValue(dynamic value) {
    return MessageStatus.values.firstWhere(
          (e) => e.value == value,
      orElse: () => MessageStatus.sent,
    );
  }
}