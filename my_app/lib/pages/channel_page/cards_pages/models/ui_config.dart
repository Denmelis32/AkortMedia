// lib/pages/cards_pages/models/ui_config.dart
import 'package:flutter/material.dart';

class UIConfig {
  // Цветовая схема
  final Color primaryColor = const Color(0xFFFb5679); // Розовый цвет
  final Color secondaryColor = const Color(0xFFF8BBD0); // Светло-розовый
  final Color backgroundColor = const Color(0xFFF5F7FA); // Очень светлый серо-голубой
  final Color surfaceColor = Colors.white; // Цвет поверхностей
  final Color textColor = const Color(0xFF37474F); // Темно-серый для текста

  // Размеры и ограничения
  final double maxContentWidth = 1200;
  final double minContentWidth = 320;

  // Адаптивные методы
  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxContentWidth) return maxContentWidth;
    return screenWidth;
  }

  int getCrossAxisCount(BuildContext context) {
    final contentWidth = getContentWidth(context);
    if (contentWidth > 1000) return 3;
    if (contentWidth > 700) return 2;
    return 1;
  }

  double getHorizontalPadding(BuildContext context) {
    final contentWidth = getContentWidth(context);
    if (contentWidth > 1000) return 24;
    if (contentWidth > 800) return 20;
    if (contentWidth > 600) return 16;
    return 12;
  }

  double getGridSpacing(BuildContext context) {
    if (isMobile(context)) return 8;
    return 6;
  }

  // Основной layout с фиксированной шириной
  Widget buildDesktopLayout(Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxContentWidth,
          minWidth: minContentWidth,
        ),
        child: content,
      ),
    );
  }

  // Форматирование чисел
  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}