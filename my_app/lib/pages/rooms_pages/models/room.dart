import 'package:flutter/material.dart';

class Room {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int participants;
  final int messages;
  final bool isJoined;
  final DateTime createdAt;
  final DateTime lastActivity;
  final RoomCategory category;
  final String creatorId;
  final List<String> moderators;
  final bool isPrivate;
  final List<String> tags;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.messages,
    required this.isJoined,
    required this.createdAt,
    required this.lastActivity,
    required this.category,
    required this.creatorId,
    this.moderators = const [],
    this.isPrivate = false,
    this.tags = const [],
  });

  Room copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? participants,
    int? messages,
    bool? isJoined,
    DateTime? createdAt,
    DateTime? lastActivity,
    RoomCategory? category,
    String? creatorId,
    List<String>? moderators,
    bool? isPrivate,
    List<String>? tags,
  }) {
    return Room(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      category: category ?? this.category,
      creatorId: creatorId ?? this.creatorId,
      moderators: moderators ?? this.moderators,
      isPrivate: isPrivate ?? this.isPrivate,
      tags: tags ?? this.tags,
    );
  }
}

enum RoomCategory {
  all('Все', Icons.all_inclusive, Colors.blue),
  tech('Технологии', Icons.smartphone, Colors.blue),
  business('Бизнес', Icons.business, Colors.orange),
  games('Игры', Icons.sports_esports, Colors.purple),
  programming('Программирование', Icons.code, Colors.teal),
  sport('Спорт', Icons.sports_soccer, Colors.green),
  psychology('Психология', Icons.psychology, Colors.pink);

  final String title;
  final IconData icon;
  final Color color;

  const RoomCategory(this.title, this.icon, this.color);
}

enum RoomSortBy {
  recent('Недавние', Icons.access_time),
  popular('Популярные', Icons.trending_up),
  participants('Участники', Icons.people),
  messages('Сообщения', Icons.chat);

  final String title;
  final IconData icon;

  const RoomSortBy(this.title, this.icon);
}