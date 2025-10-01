import 'package:flutter/material.dart';

class SortOption {
  final String id;
  final String title;
  final IconData icon;

  const SortOption({
    required this.id,
    required this.title,
    required this.icon,
  });

  // Статические константы
  static const SortOption newest = SortOption(
    id: 'newest',
    title: 'Сначала новые',
    icon: Icons.new_releases,
  );

  static const SortOption popular = SortOption(
    id: 'popular',
    title: 'По популярности',
    icon: Icons.trending_up,
  );

  static const SortOption subscribers = SortOption(
    id: 'subscribers',
    title: 'По подписчикам',
    icon: Icons.people,
  );

  static const SortOption rating = SortOption(
    id: 'rating',
    title: 'По рейтингу',
    icon: Icons.star,
  );

  static const SortOption videos = SortOption(
    id: 'videos',
    title: 'По количеству видео',
    icon: Icons.video_library,
  );

  static const SortOption comments = SortOption(
    id: 'comments',
    title: 'По комментариям',
    icon: Icons.comment,
  );

  // Список всех опций сортировки
  static List<SortOption> get allOptions => [
    newest,
    popular,
    subscribers,
    rating,
    videos,
    comments,
  ];
}