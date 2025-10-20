// utils/channel_utils.dart
import 'package:flutter/material.dart';
import 'channel.dart';

class ChannelUtils {

  // 🎯 СОЗДАНИЕ КАНАЛА ИЗ ДАННЫХ ПОСТА С ОБРАБОТКОЙ ОШИБОК
  static Channel createChannelFromPost(Map<String, dynamic> post, {List<Channel>? availableChannels}) {
    try {
      final channelId = Channel.getChannelIdFromPost(post);
      final channelName = Channel.getChannelNameFromPost(post);

      // Если есть доступные каналы, попробуем найти совпадение
      if (availableChannels != null && channelId.isNotEmpty) {
        final existingChannel = Channel.findById(availableChannels, channelId);
        if (existingChannel != null && existingChannel.id != 0) {
          return existingChannel;
        }
      }

      // Создаем новый канал из данных поста
      return Channel.fromPostData(post);
    } catch (e) {
      print('❌ Error creating channel from post: $e');
      return _createFallbackChannel();
    }
  }

  // 🆘 СОЗДАНИЕ FALLBACK КАНАЛА
  static Channel _createFallbackChannel() {
    return Channel.simple(
      id: 0,
      title: 'Неизвестный канал',
      description: 'Информация о канале недоступна',
      imageUrl: 'assets/images/ava_news/ava1.png',
      cardColor: Colors.grey,
    );
  }

  // 🔍 ПОИСК КАНАЛА В СПИСКЕ ПО ДАННЫМ ПОСТА
  static Channel? findChannelForPost(Map<String, dynamic> post, List<Channel> channels) {
    final channelId = Channel.getChannelIdFromPost(post);
    if (channelId.isEmpty) return null;

    return Channel.findById(channels, channelId);
  }

  // 🎨 ПОЛУЧЕНИЕ ЦВЕТА ДЛЯ КАНАЛА
  static Color getChannelColor(Channel channel) {
    return channel.cardColor;
  }

  // 🖼️ ПОЛУЧЕНИЕ АВАТАРКИ КАНАЛА С FALLBACK
  static String getChannelAvatar(Channel channel) {
    if (channel.imageUrl.isNotEmpty) {
      return channel.imageUrl;
    }

    // Fallback аватарки для каналов
    final fallbackAvatars = [
      'assets/images/ava_news/ava16.png',
      'assets/images/ava_news/ava17.png',
      'assets/images/ava_news/ava18.png',
    ];

    final index = channel.title.hashCode.abs() % fallbackAvatars.length;
    return fallbackAvatars[index];
  }

  // 📊 ФОРМАТИРОВАНИЕ СТАТИСТИКИ КАНАЛА
  static String formatChannelStats(Channel channel) {
    return '${channel.formattedSubscribers} подписчиков • ${channel.videos} публикаций';
  }

  // ⭐ ПОЛУЧЕНИЕ ИКОНКИ ВЕРИФИКАЦИИ
  static Widget getVerificationIcon(Channel channel, {double size = 16}) {
    if (channel.isVerified) {
      return Icon(
        Icons.verified,
        color: Colors.blue,
        size: size,
      );
    }
    return const SizedBox.shrink();
  }

  // 🔔 ПРОВЕРКА ПОДПИСКИ НА КАНАЛ
  static bool isSubscribedToChannel(Channel channel, String userId) {
    // TODO: Реализовать проверку подписки через провайдер
    return channel.isSubscribed;
  }
}