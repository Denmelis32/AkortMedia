import 'dart:math';
import 'package:flutter/material.dart';

import '../models/channel.dart';

class ChannelUtils {
  static Color getRandomColor() {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  static List<String> generateTagsForChannel(String title, String categoryId) {
    final words = title.toLowerCase().split(' ');
    final tags = <String>[];

    for (final word in words) {
      if (word.length > 3 && tags.length < 3) {
        tags.add(word);
      }
    }

    // Добавляем общие теги в зависимости от категории
    switch (categoryId) {
      case 'sport':
        tags.addAll(['спорт', 'новости']);
        break;
      case 'games':
        tags.addAll(['игры', 'гейминг']);
        break;
      case 'tech':
        tags.addAll(['технологии', 'IT']);
        break;
      case 'business':
        tags.addAll(['бизнес', 'финансы']);
        break;
    }

    return tags.take(4).toList();
  }

  static Channel createNewChannel({
    required int id,
    required String title,
    required String description,
    required String categoryId,
    required String userName,
    required String userAvatarUrl,
    String? customAvatarUrl,
    String? customCoverUrl,
  }) {
    return Channel(
      id: id,
      title: title,
      description: description,
      imageUrl: customAvatarUrl ?? _getRandomAvatarUrl(),
      subscribers: 0,
      videos: 0,
      isSubscribed: false,
      isFavorite: false,
      cardColor: getRandomColor(),
      categoryId: categoryId,
      createdAt: DateTime.now(),
      isVerified: false,
      rating: 0.0,
      views: 0,
      likes: 0,
      comments: 0,
      owner: userName,
      author: userName,
      authorImageUrl: userAvatarUrl,
      tags: generateTagsForChannel(title, categoryId),
      isLive: false,
      liveViewers: 0,
      websiteUrl: '',
      socialMedia: '',
      commentsCount: 0,
      coverImageUrl: customCoverUrl ?? _getRandomCoverUrl(),
    );
  }

  // Приватные методы для случайных изображений (используются как fallback)
  static String _getRandomAvatarUrl() {
    final avatars = [
      'https://avatars.mds.yandex.net/i?id=856af239789ab3f5f7962897c9a69647_l-12422990-images-thumbs&n=13',
      'https://avatars.mds.yandex.net/get-yapic/43978/i5F2TxqvHEddRcAEUmpIFyO2tL0-1/orig',
      'https://avatars.mds.yandex.net/i?id=62ba1b69e7eacb8bfab63982c958d61b_l-5221158-images-thumbs&n=13',
      'https://avatars.mds.yandex.net/i?id=b6988c99b85abf799a69c5470867357b_l-5235116-images-thumbs&n=13',
    ];
    return avatars[Random().nextInt(avatars.length)];
  }

  static String _getRandomCoverUrl() {
    final covers = [
      'https://avatars.mds.yandex.net/i?id=ea37c708c5ce62c18b1bdd46eee2f008f7be91ac-11389740-images-thumbs&n=13',
      'https://avatars.mds.yandex.net/i?id=a8645c8c94fcb35eda1d8297057c76fed507e2d4-8821845-images-thumbs&n=13',
      'https://avatars.mds.yandex.net/i?id=b6988c99b85abf799a69c5470867357b_l-5235116-images-thumbs&n=13',
    ];
    return covers[Random().nextInt(covers.length)];
  }
}