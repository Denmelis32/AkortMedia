// lib/models/channel.dart
import 'package:flutter/material.dart';

class Channel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final int subscribers;
  final int videos;
  final bool isSubscribed;
  final Color cardColor;

  Channel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.subscribers,
    required this.videos,
    this.isSubscribed = false,
    required this.cardColor,
  });

  // Метод для копирования с изменениями
  Channel copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    int? subscribers,
    int? videos,
    bool? isSubscribed,
    Color? cardColor,
  }) {
    return Channel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      subscribers: subscribers ?? this.subscribers,
      videos: videos ?? this.videos,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      cardColor: cardColor ?? this.cardColor,
    );
  }
}