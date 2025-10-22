import 'package:flutter/material.dart';

class LayoutUtils {
  // ЦВЕТОВАЯ СХЕМА
  final Color primaryColor = const Color(0xFF26A69A);
  final Color secondaryColor = const Color(0xFF80CBC4);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color surfaceColor = Colors.white;
  final Color textColor = const Color(0xFF37474F);

  // Градиенты для карточек
  final List<Color> cardGradients = [
    const Color(0xFFE0F2F1),
    const Color(0xFFE0F7FA),
    const Color(0xFFE8F5E8),
    const Color(0xFFF3E5F5),
    const Color(0xFFFFF3E0),
    const Color(0xFFE3F2FD),
    const Color(0xFFEDE7F6),
    const Color(0xFFFFF8E1),
  ];

  final List<Color> cardBorderColors = [
    const Color(0xFF80CBC4),
    const Color(0xFF4DB6AC),
    const Color(0xFF26A69A),
    const Color(0xFF00897B),
    const Color(0xFF80DEEA),
    const Color(0xFF4DD0E1),
    const Color(0xFF26C6DA),
    const Color(0xFF00ACC1),
  ];

  // РАЗМЕРЫ
  double get maxContentWidth => 1200;
  double get minContentWidth => 320;

  // МЕТОДЫ
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

  Color getCardColor(int index) {
    return cardGradients[index % cardGradients.length];
  }

  Color getCardBorderColor(int index) {
    return cardBorderColors[index % cardBorderColors.length];
  }
}