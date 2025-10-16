import 'package:flutter/material.dart';

enum ScreenSize {
  small,      // < 360px
  medium,     // 360-420px
  large,      // 420-600px
  tablet,     // 600-900px
  desktop,    // 900-1200px
  largeDesktop, // > 1200px
}

class ScreenUtils {
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return ScreenSize.small;
    if (width < 420) return ScreenSize.medium;
    if (width < 600) return ScreenSize.large;
    if (width < 900) return ScreenSize.tablet;
    if (width < 1200) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  // 🆕 ОБНОВЛЕННЫЙ МЕТОД - ТАКИЕ ЖЕ ОТСТУПЫ КАК В CARDS_PAGE
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  // 🆕 ПРОСТОЙ МЕТОД ДЛЯ ОПРЕДЕЛЕНИЯ МОБИЛЬНОГО УСТРОЙСТВА
  static bool isMobileDevice(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  static int getCrossAxisCount(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
      case ScreenSize.medium:
      case ScreenSize.large: return 1;
      case ScreenSize.tablet: return 2;
      case ScreenSize.desktop: return 3;
      case ScreenSize.largeDesktop: return 4;
    }
  }

  // 🆕 УПРОЩЕННЫЙ МЕТОД ДЛЯ МАЛЕНЬКИХ ЭКРАНОВ
  static bool isSmallScreen(BuildContext context) {
    final screenSize = getScreenSize(context);
    return screenSize == ScreenSize.small || screenSize == ScreenSize.medium;
  }

  // 🆕 ВЫСОТА КАРТОЧКИ ДЛЯ FEATURED SECTION
  static double getFeaturedCardHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small: return 180;
      case ScreenSize.medium: return 200;
      case ScreenSize.large: return 220;
      case ScreenSize.tablet: return 240;
      case ScreenSize.desktop: return 260;
      case ScreenSize.largeDesktop: return 280;
    }
  }

  // 🆕 ШИРИНА КАРТОЧКИ ДЛЯ FEATURED SECTION
  static double getFeaturedCardWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small: return 260;
      case ScreenSize.medium: return 280;
      case ScreenSize.large: return 300;
      case ScreenSize.tablet: return 320;
      case ScreenSize.desktop: return 340;
      case ScreenSize.largeDesktop: return 360;
    }
  }

  // 🆕 СООТНОШЕНИЕ СТОРОН ДЛЯ СЕТКИ
  static double getChildAspectRatio(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
      case ScreenSize.medium:
      case ScreenSize.large:
        return 0.75; // Вертикальные карточки на мобильных
      case ScreenSize.tablet:
        return 0.9; // Оптимально для 2 колонок
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 0.8; // Оптимально для 3-4 колонок
    }
  }

  // 🆕 РЕКОМЕНДУЕМАЯ ВЫСОТА КАРТОЧКИ
  static double getRecommendedCardHeight(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return 140;
      case ScreenSize.medium:
        return 150;
      case ScreenSize.large:
        return 160;
      case ScreenSize.tablet:
        return 120;
      case ScreenSize.desktop:
        return 140;
      case ScreenSize.largeDesktop:
        return 160;
    }
  }

  // 🆕 ОТСТУПЫ ДЛЯ СЕТКИ
  static EdgeInsets getGridPadding(BuildContext context) {
    final isMobile = isMobileDevice(context);
    final horizontalPadding = getHorizontalPadding(context);

    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      );
    }
  }

  // 🆕 ВЫСОТА КАРТОЧКИ
  static double getCardHeight(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return 140;
      case ScreenSize.medium:
        return 150;
      case ScreenSize.large:
        return 160;
      case ScreenSize.tablet:
        return 180;
      case ScreenSize.desktop:
        return 200;
      case ScreenSize.largeDesktop:
        return 220;
    }
  }

  // 🆕 НОВЫЙ МЕТОД: ОТСТУПЫ ДЛЯ СЕКЦИЙ КАК В CARDS_PAGE
  static EdgeInsets getSectionPadding(BuildContext context) {
    final isMobile = isMobileDevice(context);
    final horizontalPadding = getHorizontalPadding(context);

    return EdgeInsets.symmetric(
      horizontal: isMobile ? 0 : horizontalPadding,
      vertical: 16,
    );
  }

  // 🆕 НОВЫЙ МЕТОД: ВНУТРЕННИЕ ОТСТУПЫ ДЛЯ КОНТЕНТА
  static EdgeInsets getContentPadding(BuildContext context) {
    final isMobile = isMobileDevice(context);

    return EdgeInsets.symmetric(
      horizontal: isMobile ? 16 : 0,
    );
  }

  // 🆕 НОВЫЙ МЕТОД: МАКСИМАЛЬНАЯ ШИРИНА КОНТЕНТА
  static double getMaxContentWidth(BuildContext context) {
    return 1400; // Такая же максимальная ширина как в CardsPage
  }

  // 🆕 НОВЫЙ МЕТОД: PADDING ДЛЯ ГОРИЗОНТАЛЬНЫХ СПИСКОВ
  static EdgeInsets getHorizontalListPadding(BuildContext context) {
    final isMobile = isMobileDevice(context);
    final horizontalPadding = getHorizontalPadding(context);

    return EdgeInsets.only(
      left: isMobile ? 16 : 0,
      right: isMobile ? 16 : horizontalPadding,
    );
  }

  // 🆕 НОВЫЙ МЕТОД: ПРОСТАЯ ПРОВЕРКА НА МОБИЛЬНОЕ УСТРОЙСТВО
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }
}