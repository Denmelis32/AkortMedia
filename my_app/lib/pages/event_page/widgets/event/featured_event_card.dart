import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../event_model.dart';
import '../../utils/event_utils.dart';
import '../../utils/screen_utils.dart';

class FeaturedEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final double cardWidth;

  const FeaturedEventCard({
    Key? key,
    required this.event,
    required this.onTap,
    required this.cardWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeUntilEvent = event.date.difference(DateTime.now());
    final isSmall = ScreenUtils.isSmallScreen(context);

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: isSmall ? 12 : 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withOpacity(0.15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Фоновое изображение
              _buildBackground(),
              // Градиентный оверлей
              _buildOverlay(),
              // Контент
              _buildContent(timeUntilEvent, isSmall),
              // 🆕 Бейдж "Скоро" в правом верхнем углу
              if (timeUntilEvent.inDays <= 2) _buildSoonBadge(timeUntilEvent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (event.imageUrl != null) {
      // УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ЛОКАЛЬНЫХ И СЕТЕВЫХ ИЗОБРАЖЕНИЙ
      if (event.imageUrl!.startsWith('http')) {
        return Image.network(
          event.imageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Featured event network image error: $error');
            return _buildGradientBackground();
          },
        );
      } else {
        return Image.asset(
          event.imageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Featured event asset image error: $error');
            return _buildGradientBackground();
          },
        );
      }
    } else {
      return _buildGradientBackground();
    }
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            event.color.withOpacity(0.8),
            event.color.withOpacity(0.6),
            event.color,
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Duration timeUntilEvent, bool isSmall) {
    return Padding(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 🆕 Категория и рейтинг в одной строке
          _buildCategoryAndRating(isSmall),
          const SizedBox(height: 8),

          // Заголовок
          Text(
            event.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Описание
          Text(
            event.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmall ? 11 : 12,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Информация в строку
          _buildInfoRow(isSmall),
        ],
      ),
    );
  }

  Widget _buildCategoryAndRating(bool isSmall) {
    return Row(
      children: [
        // 🆕 Категория с иконкой как в AdaptiveEventCard
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                EventUtils.getCategoryIcon(event.category),
                size: isSmall ? 10 : 12,
                color: event.color,
              ),
              const SizedBox(width: 4),
              Text(
                _getCategoryShort(event.category),
                style: TextStyle(
                  color: event.color,
                  fontSize: isSmall ? 9 : 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // 🆕 Рейтинг с иконкой звезды
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: isSmall ? 10 : 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                event.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 10 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(bool isSmall) {
    return Row(
      children: [
        // 🆕 Дата и время
        Icon(Icons.access_time, size: isSmall ? 12 : 14, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _formatEventDate(event.date),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),

        // 🆕 Цена с улучшенным дизайном
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: event.price == 0 ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            event.price == 0 ? 'БЕСПЛАТНО' : '${event.price} ₽',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoonBadge(Duration timeUntilEvent) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: timeUntilEvent.inDays == 0 ? Colors.red : Colors.orange,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          timeUntilEvent.inDays == 0 ? 'СЕГОДНЯ!' : 'СКОРО!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🆕 Вспомогательные методы для консистентности
  String _getCategoryShort(String category) {
    final Map<String, String> categories = {
      'Концерты': 'КОНЦЕРТ',
      'Выставки': 'ВЫСТАВКА',
      'Фестивали': 'ФЕСТИВАЛЬ',
      'Образование': 'ОБРАЗОВАНИЕ',
      'Спорт': 'СПОРТ',
      'Театр': 'ТЕАТР',
      'Встречи': 'ВСТРЕЧА',
      'Концерт': 'КОНЦЕРТ',
      'Выставка': 'ВЫСТАВКА',
      'Вечеринка': 'ВЕЧЕРИНКА',
      'Лекция': 'ЛЕКЦИЯ',
      'Мастер-класс': 'МАСТЕР-КЛАСС',
    };

    String result = categories[category] ?? category.toUpperCase();
    if (result.length > 8) {
      return '${result.substring(0, 7)}...';
    }
    return result;
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return 'Сегодня, ${DateFormat('HH:mm').format(date)}';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      return 'Завтра, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd MMM, HH:mm').format(date);
    }
  }
}