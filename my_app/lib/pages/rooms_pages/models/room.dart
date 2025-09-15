// lib/pages/rooms_page/models/room.dart
import 'dart:ui';

class Room {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final int participants;
  final int messages;
  final bool isJoined;
  final Color cardColor;
  final String categoryId;
  final String lastActivity;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.messages,
    required this.isJoined,
    required this.cardColor,
    required this.categoryId,
    required this.lastActivity,
  });

  Room copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    int? participants,
    int? messages,
    bool? isJoined,
    Color? cardColor,
    String? categoryId,
    String? lastActivity,
  }) {
    return Room(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      isJoined: isJoined ?? this.isJoined,
      cardColor: cardColor ?? this.cardColor,
      categoryId: categoryId ?? this.categoryId,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}