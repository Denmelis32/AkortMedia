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
    final crossAxisCount = _getCrossAxisCount(screenWidth);

    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: 16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isMobile ? 8 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          childAspectRatio: _getChildAspectRatio(crossAxisCount, isMobile, screenWidth),
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final event = events[index];
            return AdaptiveEventCard(
              event: event,
              isFavorite: favoriteEvents.contains(event.id),
              isAttending: attendingEvents.contains(event.id),
              onTap: () => onEventTap(event),
              onFavorite: () => onFavorite(event.id),
              onAttend: () => onAttend(event.id),
              viewCount: eventViews[event.id] ?? 0,
            );
          },
          childCount: events.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SliverToBoxAdapter(
      child: Container(
        height: isMobile ? 180 : 220,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: isMobile ? 40 : 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Предстоящих событий нет',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Будьте первым, кто создаст событие в вашем сообществе',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: isMobile ? 13 : 14,
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onCreateEvent,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Создать событие'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 1;
    if (screenWidth < 900) return 2;
    if (screenWidth < 1200) return 3;
    if (screenWidth < 1600) return 4;
    return 5;
  }

  double _getChildAspectRatio(int crossAxisCount, bool isMobile, double screenWidth) {
    if (isMobile) {
      return 1.65;
    }

    // Оптимизированные соотношения для десктопа
    switch (crossAxisCount) {
      case 1: return 1.1;
      case 2: return 0.75; // Улучшено для 2 колонок
      case 3: return 0.68; // Улучшено для 3 колонок
      case 4: return 0.62; // Улучшено для 4 колонок
      case 5: return 0.58; // Улучшено для 5 колонок
      default: return 0.7;
    }
  }
}