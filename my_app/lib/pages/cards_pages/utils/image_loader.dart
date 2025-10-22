// lib/pages/cards_pages/utils/image_loader.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../providers/channel_state_provider.dart';
import '../../cards_detail_page/models/channel.dart';

class ImageLoader {
  static Widget buildChannelAvatar(Channel channel, ChannelStateProvider stateProvider, {double size = 50}) {
    final channelId = channel.id.toString();
    final customAvatar = stateProvider.getAvatarForChannel(channelId);
    final avatarUrl = customAvatar ?? channel.imageUrl;

    return ClipOval(
      child: _buildChannelImage(avatarUrl, size),
    );
  }

  static Widget buildChannelCover(Channel channel, ChannelStateProvider stateProvider, {double height = 120}) {
    final channelId = channel.id.toString();
    final customCover = stateProvider.getCoverForChannel(channelId);
    final coverUrl = customCover ?? channel.coverImageUrl ?? channel.imageUrl;

    return _buildChannelImage(coverUrl, height, isCover: true);
  }

  static Widget _buildChannelImage(String imageUrl, double size, {bool isCover = false}) {
    print('🖼️ Loading channel image: $imageUrl');

    try {
      if (imageUrl.startsWith('http')) {
        // Сетевые изображения с кэшированием
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          placeholder: (context, url) => _buildLoadingPlaceholder(size, isCover: isCover),
          errorWidget: (context, url, error) {
            print('❌ Network image error: $error');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      } else if (imageUrl.startsWith('assets/')) {
        // Локальные assets
        return Image.asset(
          imageUrl,
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Asset image error: $error for path: $imageUrl');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      } else if (imageUrl.startsWith('/') || imageUrl.contains(RegExp(r'[a-zA-Z]:\\'))) {
        // Локальные файлы
        return Image.file(
          File(imageUrl),
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ File image error: $error for path: $imageUrl');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      } else {
        // Попытка загрузить как asset, если путь не указан явно
        return Image.asset(
          imageUrl,
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Image loading failed: $error');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      }
    } catch (e) {
      print('❌ Exception loading image: $e');
      return _buildErrorImage(size, isCover: isCover);
    }
  }

  static Widget _buildLoadingPlaceholder(double size, {bool isCover = false}) {
    return Container(
      width: isCover ? double.infinity : size,
      height: size,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isCover ? 30 : 20,
            height: isCover ? 30 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
          if (isCover) ...[
            const SizedBox(height: 8),
            Text(
              'Загрузка...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildErrorImage(double size, {bool isCover = false}) {
    return Container(
      width: isCover ? double.infinity : size,
      height: size,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCover ? Icons.photo_library : Icons.person,
            color: Colors.grey[500],
            size: isCover ? 40 : 24,
          ),
          if (isCover) ...[
            const SizedBox(height: 8),
            Text(
              'Обложка не загружена',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}