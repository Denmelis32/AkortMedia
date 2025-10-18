// lib/data/mock_news_data.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class MockNewsData {
  // Локальные аватарки
  static const String _ava1 = 'assets/images/ava_news/ava1.png';
  static const String _ava2 = 'assets/images/ava_news/ava2.png';
  static const String _ava3 = 'assets/images/ava_news/ava3.png';
  static const String _ava4 = 'assets/images/ava_news/ava4.png';
  static const String _ava5 = 'assets/images/ava_news/ava5.png';
  static const String _ava6 = 'assets/images/ava_news/ava6.png';
  static const String _ava7 = 'assets/images/ava_news/ava7.png';
  static const String _ava8 = 'assets/images/ava_news/ava8.png';
  static const String _ava9 = 'assets/images/ava_news/ava9.png';
  static const String _ava10 = 'assets/images/ava_news/ava10.png';
  static const String _ava11 = 'assets/images/ava_news/ava11.png';
  static const String _ava12 = 'assets/images/ava_news/ava12.png';

  // Локальные изображения для постов
  static const String _postImage1 = 'assets/images/ava_news/ava1.png';
  static const String _postImage2 = 'assets/images/ava_news/ava2.png';
  static const String _postImage3 = 'assets/images/ava_news/ava3.png';
  static const String _postImage4 = 'assets/images/ava_news/ava4.png';

  static List<dynamic> getMockNews() {
    return [
      {
        "id": "1",
        "title": "Добро пожаловать!",
        "description": "Это ваша первая новость. Создавайте свои посты!",
        "image": _postImage1,
        "likes": 1,
        "author_name": "Система",
        "created_at": DateTime.now().toIso8601String(),
        "comments": [],
        "hashtags": ["добропожаловать"],
        "user_tags": {"tag1": "Приветствие"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": true,
        "author_avatar": _ava1,
      },
      {
        "id": "2",
        "title": "Манчестер Сити выиграл Лигу Чемпионов",
        "description": "Манчестер Сити в драматичном матче обыграл Интер со счетом 1:0",
        "image": _postImage2,
        "likes": 45,
        "author_name": "Администратор",
        "created_at": "2025-09-09T16:33:18.417Z",
        "comments": [],
        "hashtags": ["футбол", "лигачемпионов"],
        "user_tags": {"tag1": "Фанат Манчестера"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.green.value,
        "is_channel_post": false,
        "author_avatar": _ava2,
      },
      {
        "id": "3",
        "title": "Новый сезон Formula 1",
        "description": "Начало нового сезона Formula 1 обещает быть захватывающим с новыми правилами и командами",
        "image": _postImage3,
        "likes": 23,
        "author_name": "Спортивный обозреватель",
        "created_at": "2025-09-08T10:15:30.123Z",
        "comments": [],
        "hashtags": ["formula1", "автоспорт"],
        "user_tags": {"tag1": "Болельщик"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.red.value,
        "is_channel_post": false,
        "author_avatar": _ava3,
      },
      {
        "id": "channel-1",
        "title": "Важное обновление системы",
        "description": "В этом обновлении мы добавили новые функции и улучшили производительность",
        "image": _postImage4,
        "likes": 156,
        "author_name": "Система",
        "channel_name": "Официальные новости",
        "created_at": "2025-09-10T09:00:00.000Z",
        "comments": [],
        "hashtags": ["обновление", "новости"],
        "user_tags": {"tag1": "Официально"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.purple.value,
        "is_channel_post": true,
        "author_avatar": _ava1,
      }
    ];
  }

  // Методы для получения конкретных демо-данных
  static Map<String, dynamic> getWelcomeMessage() {
    return getMockNews()[0] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getSportsNews() {
    return getMockNews()[1] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getTechNews() {
    return getMockNews()[2] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getChannelPost() {
    return getMockNews()[3] as Map<String, dynamic>;
  }

  // Метод для получения демо-данных по типу
  static List<dynamic> getNewsByType(String type) {
    final allNews = getMockNews();

    switch (type) {
      case 'channel':
        return allNews.where((news) => news['is_channel_post'] == true).toList();
      case 'regular':
        return allNews.where((news) => news['is_channel_post'] != true).toList();
      case 'sports':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          return title.contains('спорт') || title.contains('футбол') ||
              title.contains('formula') || title.contains('гонк');
        }).toList();
      case 'tech':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          return title.contains('ии') || title.contains('техн') ||
              title.contains('интеллект') || title.contains('обновление');
        }).toList();
      default:
        return allNews;
    }
  }

  // Метод для получения случайного демо-сообщения
  static Map<String, dynamic> getRandomNews() {
    final allNews = getMockNews();
    final random = DateTime.now().millisecond % allNews.length;
    return allNews[random] as Map<String, dynamic>;
  }

  // Вспомогательный метод для fallback аватарок
  static String _getFallbackAvatarUrl(String userName) {
    final avatars = [
      _ava1, _ava2, _ava3, _ava4, _ava5, _ava6,
      _ava7, _ava8, _ava9, _ava10, _ava11, _ava12
    ];
    final index = userName.hashCode.abs() % avatars.length;
    return avatars[index];
  }
}