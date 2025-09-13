import 'package:flutter/material.dart';
import 'message.dart';
import 'access_level.dart';

class DiscussionTopic {
  final String id;
  final String title;
  final String description;
  final String author;
  final DateTime createdAt;
  final List<String> tags;
  final AccessLevel accessLevel;
  final Color cardColor;
  final String iconAsset;
  final LinearGradient gradient;
  final String categoryId;
  final String? channelId;
  final bool isFavorite;
  final List<Message> messages;

  const DiscussionTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.createdAt,
    this.tags = const [],
    this.accessLevel = AccessLevel.everyone,
    required this.cardColor,
    required this.iconAsset,
    required this.gradient,
    required this.categoryId,
    this.channelId,
    this.isFavorite = false,
    this.messages = const [],
  });

  DiscussionTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    DateTime? createdAt,
    List<String>? tags,
    AccessLevel? accessLevel,
    Color? cardColor,
    String? iconAsset,
    LinearGradient? gradient,
    String? categoryId,
    String? channelId,
    bool? isFavorite,
    List<Message>? messages,
  }) {
    return DiscussionTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      accessLevel: accessLevel ?? this.accessLevel,
      cardColor: cardColor ?? this.cardColor,
      iconAsset: iconAsset ?? this.iconAsset,
      gradient: gradient ?? this.gradient,
      categoryId: categoryId ?? this.categoryId,
      channelId: channelId ?? this.channelId,
      isFavorite: isFavorite ?? this.isFavorite,
      messages: messages ?? this.messages,
    );
  }
}