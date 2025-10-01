import 'package:flutter/material.dart';

class FilterOption {
  final String id;
  final String title;
  final IconData icon;

  const FilterOption({
    required this.id,
    required this.title,
    required this.icon,
  });

  // Статические константы
  static const FilterOption verified = FilterOption(
    id: 'verified',
    title: 'Только проверенные',
    icon: Icons.verified,
  );

  static const FilterOption subscribed = FilterOption(
    id: 'subscribed',
    title: 'Мои подписки',
    icon: Icons.subscriptions,
  );

  static const FilterOption favorites = FilterOption(
    id: 'favorites',
    title: 'Избранное',
    icon: Icons.favorite,
  );

  static const FilterOption live = FilterOption(
    id: 'live',
    title: 'Прямой эфир',
    icon: Icons.live_tv,
  );

  // Список всех опций фильтрации
  static List<FilterOption> get allOptions => [
    verified,
    subscribed,
    favorites,
    live,
  ];
}