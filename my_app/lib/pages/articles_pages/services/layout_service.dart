import 'package:flutter/material.dart';

class LayoutService {
  static const double maxContentWidth = 1200;
  static const double minContentWidth = 320;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxContentWidth) return maxContentWidth;
    if (screenWidth < minContentWidth) return minContentWidth;
    return screenWidth;
  }

  static int getCrossAxisCount(BuildContext context) {
    final contentWidth = getContentWidth(context);
    if (contentWidth > 1000) return 3;
    if (contentWidth > 700) return 2;
    return 1;
  }

  static double getHorizontalPadding(BuildContext context) {
    final contentWidth = getContentWidth(context);
    if (contentWidth > 1000) return 24;
    if (contentWidth > 800) return 20;
    if (contentWidth > 600) return 16;
    return 12;
  }

  static double getGridSpacing(BuildContext context) {
    return isMobile(context) ? 8 : 6;
  }

  static double getCardPadding(BuildContext context) {
    final contentWidth = getContentWidth(context);
    if (contentWidth > 1000) return 16;
    if (contentWidth > 600) return 12;
    return 8;
  }

  static double calculateFixedAspectRatio(BuildContext context) {
    final contentWidth = getContentWidth(context);
    final crossAxisCount = getCrossAxisCount(context);
    final horizontalPadding = getHorizontalPadding(context);
    final gridSpacing = getGridSpacing(context);

    final cardWidth = (contentWidth - (horizontalPadding * 2) -
        (gridSpacing * (crossAxisCount - 1))) / crossAxisCount;
    final fixedCardHeight = 460.0;

    return cardWidth / fixedCardHeight;
  }

  static Widget buildDesktopLayout(Widget content) {
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
}