// lib/pages/cards_pages/widgets/channel_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/channel_state_provider.dart';
import '../../cards_detail_page/models/channel.dart';
import '../models/channel_data.dart';
import '../models/ui_config.dart';
import '../utils/image_loader.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final int index;
  final ChannelStateProvider stateProvider;
  final UIConfig uiConfig;
  final ChannelDataManager dataManager;
  final VoidCallback onTap;
  final VoidCallback onSubscribe;
  final bool isMobile;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.index,
    required this.stateProvider,
    required this.uiConfig,
    required this.dataManager,
    required this.onTap,
    required this.onSubscribe,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = dataManager.getCategoryColor(channel.categoryId);
    final categoryIcon = dataManager.getCategoryIcon(channel.categoryId);
    final categoryTitle = dataManager.getCategoryTitle(channel.categoryId);
    final cardColor = dataManager.getCardColor(index);
    final borderColor = dataManager.getCardBorderColor(index);

    if (isMobile) {
      return _buildMobileChannelCard(
        categoryColor,
        categoryIcon,
        categoryTitle,
        cardColor,
        borderColor,
      );
    } else {
      return _buildDesktopChannelCard(
        categoryColor,
        categoryIcon,
        categoryTitle,
        cardColor,
        borderColor,
      );
    }
  }

  Widget _buildMobileChannelCard(
      Color categoryColor,
      IconData categoryIcon,
      String categoryTitle,
      Color cardColor,
      Color borderColor,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ОБЛОЖКА КАНАЛА
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: ImageLoader.buildChannelCover(channel, stateProvider, height: 140),
                      ),
                    ),
                    // Категория в левом верхнем углу
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcon,
                              size: 14,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              categoryTitle.toUpperCase(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // ОСНОВНОЙ КОНТЕНТ
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок и аватар
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Аватарка
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                ImageLoader.buildChannelAvatar(channel, stateProvider, size: 50),
                                if (channel.isVerified)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Название и описание
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  channel.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: uiConfig.textColor,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  channel.author,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: uiConfig.textColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Описание канала
                      Text(
                        channel.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: uiConfig.textColor.withOpacity(0.8),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // ХЕШТЕГИ
                      if (channel.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: channel.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: borderColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // СТАТИСТИКА И КНОПКИ
                      Row(
                        children: [
                          // Статистика
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  uiConfig.formatNumber(channel.subscribers),
                                  'подписчиков',
                                  icon: Icons.people_outline,
                                  color: borderColor,
                                ),
                                _buildStatItem(
                                  channel.videos.toString(),
                                  'видео',
                                  icon: Icons.video_library,
                                  color: borderColor,
                                ),
                                _buildStatItem(
                                  channel.rating.toStringAsFixed(1),
                                  'рейтинг',
                                  icon: Icons.star,
                                  color: borderColor,
                                ),
                              ],
                            ),
                          ),
                          // Кнопка подписки
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: channel.isSubscribed
                                  ? Colors.white.withOpacity(0.8)
                                  : uiConfig.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: channel.isSubscribed
                                    ? borderColor.withOpacity(0.5)
                                    : uiConfig.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              onPressed: onSubscribe,
                              icon: Icon(
                                channel.isSubscribed ? Icons.check : Icons.add,
                                size: 18,
                                color: channel.isSubscribed ? borderColor : Colors.white,
                              ),
                              padding: EdgeInsets.zero,
                              style: IconButton.styleFrom(
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopChannelCard(
      Color categoryColor,
      IconData categoryIcon,
      String categoryTitle,
      Color cardColor,
      Color borderColor,
      ) {
    final double cardWidth = 360.0;
    final double fixedCardHeight = 460;

    return Container(
      width: cardWidth,
      height: fixedCardHeight,
      margin: const EdgeInsets.all(2),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(24),
        color: cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Обложка - ФИКСИРОВАННАЯ ВЫСОТА
                    Container(
                      height: 160,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                        child: ImageLoader.buildChannelCover(channel, stateProvider, height: 160),
                      ),
                    ),
                    // Категория
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcon,
                              size: 14,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              categoryTitle.toUpperCase(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Аватар
                    Positioned(
                      bottom: -30,
                      left: 16,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ImageLoader.buildChannelAvatar(channel, stateProvider, size: 60),
                            if (channel.isVerified)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // НАЗВАНИЕ И АВТОР
                        Text(
                          channel.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: uiConfig.textColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          channel.author,
                          style: TextStyle(
                            fontSize: 13,
                            color: uiConfig.textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // ОПИСАНИЕ
                        Expanded(
                          child: Text(
                            channel.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: uiConfig.textColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // СТАТИСТИКА
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                uiConfig.formatNumber(channel.subscribers),
                                'подписчиков',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                channel.videos.toString(),
                                'видео',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                channel.rating.toStringAsFixed(1),
                                'рейтинг',
                                fontSize: 10,
                                color: borderColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // КНОПКА ПОДПИСКИ И ХЕШТЕГИ
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: channel.tags.take(2).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: borderColor.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: borderColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // КНОПКА ПОДПИСКИ
                            Container(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: onSubscribe,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: channel.isSubscribed
                                      ? Colors.white.withOpacity(0.8)
                                      : uiConfig.primaryColor,
                                  foregroundColor: channel.isSubscribed
                                      ? borderColor
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: channel.isSubscribed
                                          ? borderColor.withOpacity(0.5)
                                          : uiConfig.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      channel.isSubscribed ? Icons.check : Icons.add,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      channel.isSubscribed ? 'Подписка' : 'Подписаться',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {
    double fontSize = 12,
    Color? color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: color,
            ),
            const SizedBox(height: 2),
          ],
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color ?? uiConfig.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (color ?? uiConfig.textColor).withOpacity(0.7),
              fontSize: fontSize - 1,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}