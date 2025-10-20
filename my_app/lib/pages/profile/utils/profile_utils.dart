import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';

class ProfileUtils {
  String generateUserId(String email) {
    final cleanEmail = email.trim().toLowerCase();
    return 'user_${cleanEmail.hashCode.abs()}';
  }

  double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 16;
  }

  double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

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
    // Заглушка - возвращаем фиксированные данные
    return {
      'posts': 23,
      'likes': 156,
      'comments': 42,
    };
  }

  List<dynamic> getUserReposts(List<dynamic> news, String userEmail) {
    // Заглушка - возвращаем пустой список
    return [];
  }

  // Добавленные методы для исправления ошибок
  Widget buildNewsSliver({
    required BuildContext context,
    required List<dynamic> news,
    required double horizontalPadding,
    required double contentMaxWidth,
    required VoidCallback onLogout,
  }) {
    // Заглушка - возвращаем пустой sliver
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        constraints: BoxConstraints(maxWidth: contentMaxWidth),
        padding: const EdgeInsets.all(20),
        child: const Text(
          'Функционал постов будет добавлен позже',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String? getUserCoverUrl(BuildContext context, String userEmail) {
    // Заглушка - возвращаем null
    return null;
  }

  File? getProfileImage(BuildContext context, String userEmail) {
    // Заглушка - возвращаем null
    return null;
  }

  String? getProfileImageUrl(BuildContext context, String userEmail) {
    // Заглушка - возвращаем null
    return null;
  }
}