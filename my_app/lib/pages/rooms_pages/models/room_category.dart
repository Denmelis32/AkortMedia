import 'package:flutter/material.dart';

class RoomCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  const RoomCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });

  // Статические константы для часто используемых категорий
  static const RoomCategory all = RoomCategory(
    id: 'all',
    title: 'Все',
    icon: Icons.all_inclusive,
    color: Colors.blue,
  );

  static const RoomCategory youtube = RoomCategory(
    id: 'youtube',
    title: 'YouTube',
    description: 'Обсуждение видео и блогеров',
    icon: Icons.video_library,
    color: Colors.red,
  );

  static const RoomCategory business = RoomCategory(
    id: 'business',
    title: 'Бизнес',
    description: 'Стартапы и инвестиции',
    icon: Icons.business,
    color: Colors.orange,
  );

  static const RoomCategory games = RoomCategory(
    id: 'games',
    title: 'Игры',
    description: 'Игровая индустрия',
    icon: Icons.sports_esports,
    color: Colors.purple,
  );

  static const RoomCategory programming = RoomCategory(
    id: 'programming',
    title: 'Программирование',
    description: 'Разработка и IT',
    icon: Icons.code,
    color: Colors.blue,
  );

  static const RoomCategory sport = RoomCategory(
    id: 'sport',
    title: 'Спорт',
    description: 'Спортивные события',
    icon: Icons.sports_soccer,
    color: Colors.green,
  );

  static const RoomCategory communication = RoomCategory(
    id: 'communication',
    title: 'Общение',
    description: 'Психология и отношения',
    icon: Icons.chat,
    color: Colors.pink,
  );

  // Список всех категорий
  static List<RoomCategory> get allCategories => [
    all,
    youtube,
    business,
    games,
    programming,
    sport,
    communication,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RoomCategory &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RoomCategory(id: $id, title: $title)';
}