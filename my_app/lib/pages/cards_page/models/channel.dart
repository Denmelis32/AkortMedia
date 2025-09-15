// models/channel.dart
import 'dart:ui' show Color;

class Channel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final int subscribers;
  final int videos;
  final bool isSubscribed;
  final Color cardColor;
  final String categoryId; // Добавьте это поле

  Channel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.subscribers,
    required this.videos,
    required this.isSubscribed,
    required this.cardColor,
    required this.categoryId,
  });

  Channel copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    int? subscribers,
    int? videos,
    bool? isSubscribed,
    Color? cardColor,
    String? categoryId,
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
      categoryId: categoryId ?? this.categoryId,
    );
  }
}