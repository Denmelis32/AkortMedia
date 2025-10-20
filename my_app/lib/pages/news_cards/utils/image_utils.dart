// 🖼️ УТИЛИТЫ ДЛЯ РАБОТЫ С ИЗОБРАЖЕНИЯМИ И АВАТАРКАМИ

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

/// 🖼️ КЛАСС ДЛЯ РАБОТЫ С РАЗЛИЧНЫМИ ТИПАМИ ИЗОБРАЖЕНИЙ
/// Обеспечивает единый интерфейс для загрузки изображений из разных источников
/// с обработкой ошибок и кэшированием
class ImageUtils {

  // 📦 ЛОКАЛЬНЫЕ АВАТАРКИ ДЛЯ FALLBACK
  static final List<String> _localAvatars = [
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
    'assets/images/ava_news/ava13.png',
    'assets/images/ava_news/ava14.png',
    'assets/images/ava_news/ava15.png',
    'assets/images/ava_news/ava16.png',
    'assets/images/ava_news/ava17.png',
    'assets/images/ava_news/ava18.png',
    'assets/images/ava_news/ava19.png',
    'assets/images/ava_news/ava20.png',
    'assets/images/ava_news/ava21.png',
    'assets/images/ava_news/ava22.png',
    'assets/images/ava_news/ava23.png',
    'assets/images/ava_news/ava24.png',
    'assets/images/ava_news/ava25.png',
    'assets/images/ava_news/ava26.png',
    'assets/images/ava_news/ava27.png',
    'assets/images/ava_news/ava28.png',
    'assets/images/ava_news/ava29.png',
    'assets/images/ava_news/ava30.png',
  ];

  // 💾 КЭШ ДЛЯ ОПТИМИЗАЦИИ
  static final _avatarCache = <String, String>{};

  /// 🖼️ СОЗДАЕТ ВИДЖЕТ ИЗОБРАЖЕНИЯ С ПОДДЕРЖКОЙ РАЗНЫХ ИСТОЧНИКОВ
  /// Автоматически определяет тип изображения (asset, network, file)
  /// и создает соответствующий виджет с обработкой ошибок
  static Widget buildImageWidget(
      String imageUrl, {
        double? width,
        double? height,
        BoxFit fit = BoxFit.cover,
      }) {
    // 🚫 ПРОВЕРКА НА ПУСТОЙ URL
    if (imageUrl.isEmpty) {
      return _buildErrorImage(width: width, height: height);
    }

    print('🖼️ Загрузка изображения: $imageUrl');

    try {
      // 📱 ASSET ИЗОБРАЖЕНИЯ
      if (_isAssetImage(imageUrl)) {
        return Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: width != null ? (width * 2).toInt() : null,
          cacheHeight: height != null ? (height * 2).toInt() : null,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Ошибка загрузки asset изображения: $error для пути: $imageUrl');
            return _buildErrorImage(width: width, height: height);
          },
        );
      }
      // 🌐 СЕТЕВЫЕ ИЗОБРАЖЕНИЯ
      else if (_isNetworkImage(imageUrl)) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildLoadingPlaceholder(width: width, height: height),
          errorWidget: (context, url, error) {
            print('❌ Ошибка загрузки network изображения: $error для URL: $imageUrl');
            return _buildErrorImage(width: width, height: height);
          },
        );
      }
      // 📁 ФАЙЛОВЫЕ ИЗОБРАЖЕНИЯ
      else if (_isFileImage(imageUrl)) {
        return Image.file(
          File(imageUrl),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Ошибка загрузки file изображения: $error для пути: $imageUrl');
            return _buildErrorImage(width: width, height: height);
          },
        );
      }
      // ❓ НЕИЗВЕСТНЫЙ ТИП
      else {
        print('⚠️ Неизвестный тип изображения: $imageUrl');
        return _buildErrorImage(width: width, height: height);
      }
    } catch (e) {
      print('❌ Исключение при загрузке изображения: $e');
      return _buildErrorImage(width: width, height: height);
    }
  }

  /// 👤 ПОЛУЧАЕТ URL АВАТАРКИ ПОЛЬЗОВАТЕЛЯ/КАНАЛА
  /// Интеллектуально определяет источник аватарки с приоритетами:
  /// 1. ChannelStateProvider для каналов
  /// 2. Данные из поста
  /// 3. Fallback локальные аватары
  static String getUserAvatarUrl({
    required Map<String, dynamic> news,
    required String userName,
    bool isCurrentUser = false,
    bool isOriginalPost = false,
  }) {
    try {
      print('🔍 Получение аватарки для: $userName, текущий пользователь: $isCurrentUser, оригинальный пост: $isOriginalPost');

      // 🔄 ДЛЯ РЕПОСТОВ - ОРИГИНАЛЬНЫЙ АВТОР/КАНАЛ
      if (isOriginalPost) {
        return _getOriginalPostAvatar(news, userName);
      }

      // 📢 ДЛЯ ОСНОВНЫХ ПОСТОВ - КАНАЛЫ
      final isChannelPost = _getBoolValue(news['is_channel_post']);
      final channelId = _getStringValue(news['channel_id']);
      final channelName = _getStringValue(news['channel_name']);

      if (isChannelPost && channelId.isNotEmpty) {
        return _getChannelAvatar(news, channelId, channelName);
      }

      // 👤 ДЛЯ ОБЫЧНЫХ ПОЛЬЗОВАТЕЛЕЙ
      return _getUserAvatar(news, userName, isCurrentUser);

    } catch (e) {
      print('❌ Ошибка получения аватарки пользователя: $e');
      return _getFallbackAvatarUrl(userName);
    }
  }

  /// 👤 ПОЛУЧАЕТ АВАТАРКУ ДЛЯ ОРИГИНАЛЬНОГО ПОСТА В РЕПОСТЕ
  static String _getOriginalPostAvatar(Map<String, dynamic> news, String userName) {
    final isOriginalChannelPost = _getBoolValue(news['is_original_channel_post']);

    if (isOriginalChannelPost) {
      // 📢 АВАТАР ОРИГИНАЛЬНОГО КАНАЛА
      final originalChannelId = _getStringValue(news['original_channel_id']);
      final originalChannelName = _getStringValue(news['original_channel_name']);
      final originalChannelAvatar = _getStringValue(news['original_channel_avatar']);

      print('   Оригинальный канал: $originalChannelName, ID: $originalChannelId');

      // TODO: Добавить получение из ChannelStateProvider когда будет доступен контекст
      if (originalChannelAvatar.isNotEmpty) {
        print('   ✅ Используем аватар канала из данных поста: $originalChannelAvatar');
        return originalChannelAvatar;
      }

      print('   🎯 Используем fallback аватар для канала: $originalChannelName');
      return _getFallbackAvatarUrl(originalChannelName);
    } else {
      // 👤 АВАТАР ОРИГИНАЛЬНОГО ПОЛЬЗОВАТЕЛЯ
      final originalAuthorAvatar = _getStringValue(news['original_author_avatar']);
      final originalAuthorName = _getStringValue(news['original_author_name']);

      print('   Оригинальный автор: $originalAuthorName');

      if (originalAuthorAvatar.isNotEmpty) {
        print('   ✅ Используем аватар автора из данных поста: $originalAuthorAvatar');
        return originalAuthorAvatar;
      }

      print('   🎯 Используем fallback аватар для автора: $originalAuthorName');
      return _getFallbackAvatarUrl(originalAuthorName);
    }
  }

  /// 📢 ПОЛУЧАЕТ АВАТАРКУ КАНАЛА
  static String _getChannelAvatar(Map<String, dynamic> news, String channelId, String channelName) {
    print('   🔍 Это канальный пост, канал: $channelName, ID: $channelId');

    // TODO: Добавить получение из ChannelStateProvider когда будет доступен контекст
    final channelAvatar = _getStringValue(news['channel_avatar']);
    if (channelAvatar.isNotEmpty) {
      print('   ✅ Используем аватар канала из данных поста: $channelAvatar');
      return channelAvatar;
    }

    print('   🎯 Используем fallback аватар для канала: $channelName');
    return _getFallbackAvatarUrl(channelName);
  }

  /// 👤 ПОЛУЧАЕТ АВАТАРКУ ПОЛЬЗОВАТЕЛЯ
  static String _getUserAvatar(Map<String, dynamic> news, String userName, bool isCurrentUser) {
    final authorAvatar = _getStringValue(news['author_avatar']);
    final authorName = _getStringValue(news['author_name']);

    print('   Автор: $authorName');
    print('   Аватар автора из данных: $authorAvatar');

    if (authorAvatar.isNotEmpty) {
      return authorAvatar;
    }

    print('   🎯 Используем fallback аватар для пользователя: $authorName');
    return _getFallbackAvatarUrl(authorName);
  }

  /// 🎯 ПОЛУЧАЕТ FALLBACK АВАТАРКУ ИЗ ЛОКАЛЬНЫХ РЕСУРСОВ
  static String _getFallbackAvatarUrl(String userName) {
    // Всегда возвращаем локальные аватары из assets
    final index = userName.hashCode.abs() % _localAvatars.length;
    return _localAvatars[index];
  }

  /// 👤 СОЗДАЕТ ВИДЖЕТ АВАТАРКИ С FALLBACK
  static Widget buildUserAvatarWidget({
    required String avatarUrl,
    required String displayName,
    required double size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildImageWidgetWithFallback(avatarUrl, displayName, size: size),
        ),
      ),
    );
  }

  /// 🖼️ СОЗДАЕТ ВИДЖЕТ ИЗОБРАЖЕНИЯ С FALLBACK
  static Widget _buildImageWidgetWithFallback(String imageUrl, String displayName, {double? size}) {
    if (imageUrl.isEmpty) {
      return _buildGradientFallbackAvatar(displayName, size ?? 40);
    }

    return buildImageWidget(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }

  /// 🌈 СОЗДАЕТ ГРАДИЕНТНЫЙ FALLBACK ДЛЯ АВАТАРКИ
  static Widget _buildGradientFallbackAvatar(String name, double size) {
    final gradientColors = _getAvatarGradient(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: name.isNotEmpty
            ? Text(
          name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
          ),
        )
            : Icon(
          Icons.group_rounded,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  /// ⏳ СОЗДАЕТ ВИДЖЕТ ЗАГРУЗКИ
  static Widget _buildLoadingPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // TODO: Использовать цвет из дизайна
          ),
        ),
      ),
    );
  }

  /// ❌ СОЗДАЕТ ВИДЖЕТ ОШИБКИ ЗАГРУЗКИ
  static Widget _buildErrorImage({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.grey[500],
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'Ошибка\nзагрузки',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 ПРОВЕРЯЕТ ЯВЛЯЕТСЯ ЛИ ИЗОБРАЖЕНИЕ ASSET
  static bool _isAssetImage(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    return imageUrl.startsWith('assets/') ||
        imageUrl.startsWith('assets/images/') ||
        (imageUrl.contains('.png') && !imageUrl.contains('://')) ||
        (imageUrl.contains('.jpg') && !imageUrl.contains('://')) ||
        (imageUrl.contains('.jpeg') && !imageUrl.contains('://'));
  }

  /// 🌐 ПРОВЕРЯЕТ ЯВЛЯЕТСЯ ЛИ ИЗОБРАЖЕНИЕ СЕТЕВЫМ
  static bool _isNetworkImage(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    return imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://') ||
        imageUrl.contains('ui-avatars.com') ||
        imageUrl.contains('://');
  }

  /// 📁 ПРОВЕРЯЕТ ЯВЛЯЕТСЯ ЛИ ИЗОБРАЖЕНИЕ ФАЙЛОМ
  static bool _isFileImage(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    return imageUrl.startsWith('/') ||
        (imageUrl.contains(RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false)) &&
            !_isAssetImage(imageUrl) &&
            !_isNetworkImage(imageUrl));
  }

  /// 🌈 ПОЛУЧАЕТ ГРАДИЕНТ ДЛЯ FALLBACK АВАТАРКИ
  static List<Color> _getAvatarGradient(String name) {
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

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  static bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }
}