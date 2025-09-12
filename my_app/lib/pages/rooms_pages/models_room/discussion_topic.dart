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
  final List<Message> messages;
  final bool isFavorite; // ← ДОБАВИТЬ

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.createdAt,
    required this.tags,
    this.accessLevel = AccessLevel.everyone,
    required this.cardColor,
    required this.iconAsset,
    required this.gradient,
    required this.categoryId,
    this.messages = const [],
    this.isFavorite = false, // ← ДОБАВИТЬ
  });

  // Добавить copyWith метод
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
    List<Message>? messages,
    bool? isFavorite, // ← ДОБАВИТЬ
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
      messages: messages ?? this.messages,
      isFavorite: isFavorite ?? this.isFavorite, // ← ДОБАВИТЬ
    );
  }
}