// lib/pages/news_cards/utils/image_utils.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';

class ImageUtils {
  // 🎯 УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ ИЗ ЛЮБОГО ИСТОЧНИКА
  static String getUniversalAvatarUrl({
    required BuildContext context,
    required String userId,
    required String userName,
  }) {
    try {
      print('🔍 ImageUtils: Getting universal avatar for $userName ($userId)');

      // Используем NewsProvider для получения аватарки
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      final avatarUrl = newsProvider.getUserAvatarUrl(userId, userName);

      print('✅ ImageUtils: Got avatar from provider: $avatarUrl');
      return avatarUrl;

    } catch (e) {
      print('❌ ImageUtils: Error getting universal avatar: $e');
      return getFallbackAvatarUrl(userName);
    }
  }

  // 🎯 ПОСТРОЕНИЕ ВИДЖЕТА АВАТАРКИ С УНИВЕРСАЛЬНОЙ СИСТЕМОЙ
  static Widget buildUserAvatarWidget({
    required BuildContext context,
    required String userId,
    required String userName,
    required double size,
    VoidCallback? onTap,
  }) {
    final avatarUrl = getUniversalAvatarUrl(
      context: context,
      userId: userId,
      userName: userName,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildAvatarImage(avatarUrl, userName, size),
        ),
      ),
    );
  }

  // 🖼️ ПОСТРОЕНИЕ ИЗОБРАЖЕНИЯ АВАТАРКИ
  static Widget _buildAvatarImage(String avatarUrl, String userName, double size) {
    print('🖼️ ImageUtils: Building avatar image from: $avatarUrl');

    // Если это путь к файлу
    if (avatarUrl.startsWith('/') ||
        avatarUrl.contains('storage/') ||
        avatarUrl.contains('.jpg') ||
        avatarUrl.contains('.png') ||
        avatarUrl.contains('.jpeg')) {

      if (avatarUrl.startsWith('assets/')) {
        // Asset изображение
        return Image.asset(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading asset avatar: $error');
            return _buildFallbackAvatar(userName, size);
          },
        );
      } else {
        // Локальный файл
        try {
          return Image.file(
            File(avatarUrl),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading file avatar: $error, path: $avatarUrl');
              return _buildFallbackAvatar(userName, size);
            },
          );
        } catch (e) {
          print('❌ Exception loading file avatar: $e');
          return _buildFallbackAvatar(userName, size);
        }
      }
    }
    // Если это URL
    else if (avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingAvatar(userName, size);
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network avatar: $error, URL: $avatarUrl');
          return _buildFallbackAvatar(userName, size);
        },
      );
    }
    // Fallback на локальные аватарки
    else if (avatarUrl.startsWith('assets/images/ava_news/')) {
      return Image.asset(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(userName, size);
        },
      );
    }
    // Fallback
    else {
      print('⚠️ ImageUtils: Using fallback avatar for: $userName');
      return _buildFallbackAvatar(userName, size);
    }
  }

  // 🎯 FALLBACK АВАТАРКА
  static Widget _buildFallbackAvatar(String userName, double size) {
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
    ];

    final index = userName.isEmpty ? 0 : userName.codeUnits.reduce((a, b) => a + b) % colors.length;
    final gradientColors = colors[index];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🔄 АВАТАРКА ЗАГРУЗКИ
  static Widget _buildLoadingAvatar(String userName, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.grey[600]!),
          ),
        ),
      ),
    );
  }

  // 🎯 FALLBACK АВАТАРКИ ИЗ ASSETS
  static String getFallbackAvatarUrl(String userName) {
    final avatars = [
      'assets/images/ava_news/ava1.png',
      'assets/images/ava_news/ava2.png',
      'assets/images/ava_news/ava3.png',
      'assets/images/ava_news/ava4.png',
      'assets/images/ava_news/ava5.png',
      'assets/images/ava_news/ava6.png',
      'assets/images/ava_news/ava7.png',
      'assets/images/ava_news/ava8.png',
      'assets/images/ava_news/ava9.png',
      'assets/images/ava_news/ava10.png',
      'assets/images/ava_news/ava11.png',
      'assets/images/ava_news/ava12.png',
    ];

    // Генерируем индекс на основе хеша имени для консистентности
    final index = userName.hashCode.abs() % avatars.length;
    final selectedAvatar = avatars[index];

    print('🎲 ImageUtils: Generated fallback avatar for $userName: $selectedAvatar (index: $index)');
    return selectedAvatar;
  }
}