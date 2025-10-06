import 'package:flutter/material.dart';

class NewsTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFFFF6B35);
  static const Color backgroundColor = Color(0xFFF5F9FF);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF666666);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);

  static const List<Color> tagColors = [
    Color(0xFF2196F3),
    Color(0xFFFF6B35),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFFFC107),
    Color(0xFF607D8B),
  ];

  // Упрощенная тема без проблемных свойств
  static ThemeData get themeData => ThemeData(
    useMaterial3: false, // Отключаем Material 3 для совместимости
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardColor,
      elevation: 2,
      centerTitle: false,
      foregroundColor: textColor,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    // Убираем cardTheme полностью и используем кастомные контейнеры
  );

  // Альтернативный вариант с Material 3
  static ThemeData get themeDataMaterial3 => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      background: backgroundColor,
      surface: cardColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardColor,
      elevation: 2,
      centerTitle: false,
      foregroundColor: textColor,
    ),
    // Не используем cardTheme в Material 3
  );

  // Самый безопасный вариант
  static ThemeData get themeDataSafe => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: cardColor,
      elevation: 2,
      centerTitle: false,
      foregroundColor: textColor,
    ),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get floatingDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryColor, secondaryColor],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // Текст стили
  static TextStyle get titleStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle get bodyStyle => const TextStyle(
    fontSize: 14,
    color: textColor,
    height: 1.4,
  );

  static TextStyle get secondaryStyle => const TextStyle(
    fontSize: 12,
    color: secondaryTextColor,
  );

  static TextStyle get buttonStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}