import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';

class ProfileUtils {
  String generateUserId(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final userId = 'user_${cleanEmail.hashCode.abs()}';
    print('🆔 ProfileUtils: Generated user ID: $userId for email: $cleanEmail');
    return userId;
  }

  double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Адаптивные отступы на основе размера экрана
    if (width > 1200) return width * 0.2; // 20% для десктопа
    if (width > 800) return width * 0.1;  // 10% для планшета
    if (width > 600) return 24;          // Фиксированный для больших телефонов
    return 16;                           // Стандартный для мобильных
  }

  double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Адаптивная максимальная ширина контента
    if (width > 1400) return 800;
    if (width > 1200) return 700;
    if (width > 1000) return 600;
    if (width > 800) return 500;
    if (width > 600) return 450;
    return width - 32; // На мобильных занимает почти всю ширину
  }

  double getAdaptiveValue(BuildContext context, {double mobile = 16, double tablet = 24, double desktop = 32}) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return desktop;
    if (width > 600) return tablet;
    return mobile;
  }

  double getAdaptiveFontSize(BuildContext context, {double mobile = 14, double tablet = 16, double desktop = 18}) {
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    double baseSize;
    if (width > 1200) {
      baseSize = desktop;
    } else if (width > 600) {
      baseSize = tablet;
    } else {
      baseSize = mobile;
    }

    return baseSize * textScaleFactor;
  }

  // УДАЛЕНО: Конфликтующее свойство
  // bool get isMobile => throw UnsupportedError('Use isMobile(context)');

  // Статические методы для проверки типа устройства
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  Color getUserColor(String userName) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
      Colors.teal.shade700,
    ];
    final index = userName.isEmpty ? 0 : userName.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  Color darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  List<Color> getAvatarGradient(String name) {
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];
    final index = name.isEmpty ? 0 : name.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  Map<String, int> getUserStats(List<dynamic> news, String userName) {
    return {
      'posts': 23,
      'likes': 156,
      'comments': 42,
    };
  }

  List<dynamic> getUserReposts(List<dynamic> news, String userEmail) {
    return [];
  }

  Widget buildNewsSliver({
    required BuildContext context,
    required List<dynamic> news,
    required double horizontalPadding,
    required double contentMaxWidth,
    required VoidCallback onLogout,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        constraints: BoxConstraints(maxWidth: contentMaxWidth),
        padding: EdgeInsets.all(getAdaptiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        child: Text(
          'Функционал постов будет добавлен позже',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: getAdaptiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
          ),
        ),
      ),
    );
  }

  String? getUserCoverUrl(BuildContext context, String userEmail) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    return newsProvider.coverImageUrl;
  }

  File? getProfileImage(BuildContext context, String userEmail) {
    return null;
  }

  String? getProfileImageUrl(BuildContext context, String userEmail) {
    return null;
  }


  File? getUserCoverFile(BuildContext context, String userEmail) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    return newsProvider.coverImageFile;
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ АДАПТИВНОГО ДИЗАЙНА

  int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2; // Для мобильных
  }

  double getAdaptiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 24;
    if (width > 800) return 22;
    if (width > 600) return 20;
    return 18; // Для мобильных
  }

  double getAdaptiveCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 120;
    if (width > 800) return 110;
    if (width > 600) return 100;
    return 90; // Для мобильных
  }

  EdgeInsets getAdaptivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return const EdgeInsets.all(24);
    if (width > 800) return const EdgeInsets.all(20);
    if (width > 600) return const EdgeInsets.all(16);
    return const EdgeInsets.all(12); // Для мобильных
  }

  BorderRadius getAdaptiveBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return BorderRadius.circular(20);
    return BorderRadius.circular(16); // Для мобильных
  }

  double getAdaptiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 24;
    if (width > 800) return 20;
    if (width > 600) return 16;
    return 12; // Для мобильных
  }
}