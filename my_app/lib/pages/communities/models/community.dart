import 'package:flutter/material.dart';

class Community {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String coverImageUrl;
  final Color cardColor;
  final List<String> tags;
  final int membersCount;
  final int postsCount;
  final bool isPrivate;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.cardColor,
    required this.tags,
    required this.membersCount,
    required this.postsCount,
    required this.isPrivate,
    required this.createdAt,
  });

  // Метод для создания тестовых данных
  static List<Community> get testCommunities => [
    Community(
      id: 1,
      title: 'Flutter Developers',
      description: 'Сообщество разработчиков Flutter',
      imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=150&h=150&fit=crop',
      coverImageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500&h=300&fit=crop',
      cardColor: Colors.blue,
      tags: ['technology', 'programming'],
      membersCount: 1250,
      postsCount: 340,
      isPrivate: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Community(
      id: 2,
      title: 'Startup Entrepreneurs',
      description: 'Сообщество предпринимателей и стартаперов',
      imageUrl: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=150&h=150&fit=crop',
      coverImageUrl: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=500&h=300&fit=crop',
      cardColor: Colors.orange,
      tags: ['business', 'startup'],
      membersCount: 890,
      postsCount: 210,
      isPrivate: false,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Community(
      id: 3,
      title: 'Game Development',
      description: 'Разработка игр и геймдизайн',
      imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=150&h=150&fit=crop',
      coverImageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500&h=300&fit=crop',
      cardColor: Colors.purple,
      tags: ['games', 'development'],
      membersCount: 670,
      postsCount: 180,
      isPrivate: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Community(
      id: 4,
      title: 'Digital Artists',
      description: 'Сообщество цифровых художников',
      imageUrl: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=150&h=150&fit=crop',
      coverImageUrl: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=500&h=300&fit=crop',
      cardColor: Colors.pink,
      tags: ['art', 'design'],
      membersCount: 430,
      postsCount: 95,
      isPrivate: false,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
}