import 'package:flutter/foundation.dart';
import 'chat_user.dart';

@immutable
class Reaction {
  final String emoji;
  final ChatUser user;
  final DateTime timestamp;

  const Reaction({
    required this.emoji,
    required this.user,
    required this.timestamp,
  });

  Reaction copyWith({
    String? emoji,
    ChatUser? user,
    DateTime? timestamp,
  }) {
    return Reaction(
      emoji: emoji ?? this.emoji,
      user: user ?? this.user,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'user': user.toJson(),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      emoji: json['emoji'],
      user: ChatUser.fromJson(json['user']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reaction &&
        other.emoji == emoji &&
        other.user == user &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(emoji, user, timestamp);
}