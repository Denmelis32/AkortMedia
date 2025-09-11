import 'package:flutter/material.dart';
import 'message.dart';
import 'access_level.dart';

class DiscussionTopic {
  final String id;
  final String title;
  final String description;
  final String author;
  final DateTime createdAt;
  final List<Message> messages;
  final List<String> tags;
  final AccessLevel accessLevel;
  final Color cardColor;
  final String iconAsset;
  final LinearGradient gradient;
  final String categoryId;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.createdAt,
    this.messages = const [],
    this.tags = const [],
    this.accessLevel = AccessLevel.everyone,
    this.cardColor = Colors.lightBlue,
    this.iconAsset = 'assets/icons/default_room.png',
    required this.gradient,
    required this.categoryId,
  });

  DiscussionTopic copyWith({
    List<Message>? messages,
  }) {
    return DiscussionTopic(
      id: id,
      title: title,
      description: description,
      author: author,
      createdAt: createdAt,
      messages: messages ?? this.messages,
      tags: tags,
      accessLevel: accessLevel,
      cardColor: cardColor,
      iconAsset: iconAsset,
      gradient: gradient,
      categoryId: categoryId,
    );
  }
}