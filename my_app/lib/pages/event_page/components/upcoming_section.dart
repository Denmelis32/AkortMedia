import 'package:flutter/material.dart';
import '../event_model.dart';
import '../widgets/event/adaptive_event_card.dart';

class UpcomingSection extends StatelessWidget {
  final List<Event> events;
  final Set<String> favoriteEvents;
  final Set<String> attendingEvents;
  final Map<String, int> eventViews;
  final ValueChanged<Event> onEventTap;
  final ValueChanged<String> onFavorite;
  final ValueChanged<String> onAttend;
  final VoidCallback onCreateEvent;

  const UpcomingSection({
    Key? key,
    required this.events,
    required this.favoriteEvents,
    required this.attendingEvents,
    required this.eventViews,
    required this.onEventTap,
    required this.onFavorite,
    required this.onAttend,
    required this.onCreateEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    // 🎯 АДАПТИВНОЕ КОЛИЧЕСТВО КОЛОНОК С ЗАЩИТОЙ ОТ OVERFLOW
    final crossAxisCount = _getAdaptiveCrossAxisCount(screenWidth);

    // 🛡️ Защита от пустого списка
    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return SliverPadding(
      padding: _getAdaptivePadding(screenWidth, isMobile),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: _getCrossAxisSpacing(screenWidth),
          mainAxisSpacing: _getMainAxisSpacing(screenWidth),
          childAspectRatio: _getChildAspectRatio(screenWidth, crossAxisCount),
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            // 🛡️ Защита от выхода за пределы списка
            if (index >= events.length) return const SizedBox.shrink();

            final event = events[index];
            return Container(
              // 🛡️ ОГРАНИЧИТЕЛЬ ДЛЯ КАРТОЧКИ
              constraints: BoxConstraints(
                maxWidth: _getMaxCardWidth(screenWidth, crossAxisCount),
              ),
              child: AdaptiveEventCard(
                event: event,
                isFavorite: favoriteEvents.contains(event.id),
                isAttending: attendingEvents.contains(event.id),
                onTap: () => onEventTap(event),
                onFavorite: () => onFavorite(event.id),
                onAttend: () => onAttend(event.id),
                viewCount: eventViews[event.id] ?? 0,
              ),
            );
          },
          childCount: events.length,
        ),
      ),
    );
  }

  // 🎯 АДАПТИВНОЕ КОЛИЧЕСТВО КОЛОНОК
  int _getAdaptiveCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 1; // 📱 Мобильные
    if (screenWidth < 800) return 2; // 💻 Маленькие десктопы
    if (screenWidth < 1200) return 2; // 💻 Средние десктопы
    return 2; // 🖥️ Большие десктопы (максимум 2 колонки)
  }

  // 🎯 АДАПТИВНЫЕ ОТСТУПЫ
  EdgeInsets _getAdaptivePadding(double screenWidth, bool isMobile) {
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 16);
    } else if (screenWidth < 800) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else if (screenWidth < 1200) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  // 🎯 АДАПТИВНЫЕ РАССТОЯНИЯ МЕЖДУ КОЛОНКАМИ
  double _getCrossAxisSpacing(double screenWidth) {
    if (screenWidth < 600) return 12;
    if (screenWidth < 800) return 16;
    if (screenWidth < 1200) return 20;
    return 24;
  }

  // 🎯 АДАПТИВНЫЕ РАССТОЯНИЯ МЕЖДУ СТРОКАМИ
  double _getMainAxisSpacing(double screenWidth) {
    if (screenWidth < 600) return 16;
    if (screenWidth < 800) return 20;
    if (screenWidth < 1200) return 24;
    return 28;
  }

  // 🎯 АДАПТИВНОЕ СООТНОШЕНИЕ СТОРОН
  double _getChildAspectRatio(double screenWidth, int crossAxisCount) {
    if (screenWidth < 600) {
      return 2.5; // 📱 Горизонтальные карточки для мобильных
    }

    // 💻 Вертикальные карточки для десктопа
    if (screenWidth < 800) return 1.8;  // Меньшие экраны
    if (screenWidth < 1200) return 1.9; // Средние экраны
    return 2.1; // Большие экраны
  }

  // 🛡️ МАКСИМАЛЬНАЯ ШИРИНА КАРТОЧКИ ДЛЯ ЗАЩИТЫ ОТ OVERFLOW
  double _getMaxCardWidth(double screenWidth, int crossAxisCount) {
    final horizontalPadding = _getAdaptivePadding(screenWidth, false).horizontal;
    final crossAxisSpacing = _getCrossAxisSpacing(screenWidth);

    // 🎯 РАСЧЕТ МАКСИМАЛЬНОЙ ШИРИНЫ С УЧЕТОМ ОТСТУПОВ
    final availableWidth = screenWidth - horizontalPadding - (crossAxisSpacing * (crossAxisCount - 1));
    final maxWidth = availableWidth / crossAxisCount;

    // 🛡️ ДОПОЛНИТЕЛЬНАЯ ЗАЩИТА - ОГРАНИЧЕНИЕ 400px
    return maxWidth.clamp(300, 400);
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SliverToBoxAdapter(
      child: Container(
        height: isMobile ? 200 : 240,
        margin: EdgeInsets.symmetric(
          horizontal: _getEmptyStateHorizontalMargin(screenWidth),
          vertical: 32,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎯 Улучшенная иконка
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_outlined,
                size: isMobile ? 32 : 40,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 20),

            // 🛡️ Текст с защитой от overflow
            Container(
              constraints: BoxConstraints(
                maxWidth: _getEmptyStateMaxTextWidth(screenWidth),
              ),
              child: Column(
                children: [
                  Text(
                    'Предстоящих событий нет',
                    style: TextStyle(
                      fontSize: _getEmptyStateTitleSize(screenWidth),
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Будьте первым, кто создаст событие в вашем сообществе',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: _getEmptyStateSubtitleSize(screenWidth),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (!isMobile) ...[
              const SizedBox(height: 24),
              // 🎯 Улучшенная кнопка
              ElevatedButton.icon(
                onPressed: onCreateEvent,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'Создать событие',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ EMPTY STATE
  double _getEmptyStateHorizontalMargin(double screenWidth) {
    if (screenWidth < 600) return 16;
    if (screenWidth < 800) return 20;
    return 24;
  }

  double _getEmptyStateMaxTextWidth(double screenWidth) {
    if (screenWidth < 600) return 250;
    if (screenWidth < 800) return 280;
    return 300;
  }

  double _getEmptyStateTitleSize(double screenWidth) {
    if (screenWidth < 600) return 18;
    if (screenWidth < 800) return 19;
    return 20;
  }

  double _getEmptyStateSubtitleSize(double screenWidth) {
    if (screenWidth < 600) return 14;
    if (screenWidth < 800) return 14.5;
    return 15;
  }
}