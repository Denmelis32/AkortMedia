import 'package:flutter/material.dart';
import '../event_model.dart';
import '../utils/screen_utils.dart';
import '../widgets/event/featured_event_card.dart';

class FeaturedSection extends StatelessWidget {
  final List<Event> featuredEvents;
  final ValueChanged<Event> onEventTap;
  final Animation<double> fadeAnimation;

  const FeaturedSection({
    Key? key,
    required this.featuredEvents,
    required this.onEventTap,
    required this.fadeAnimation,
  }) : super(key: key);

  // 🆕 Метод для определения горизонтальных отступов как в CardsPage
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final horizontalPadding = _getHorizontalPadding(context);

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        // 🆕 Убрали margin, так как контейнер уже имеет отступы
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🆕 Заголовок секции с такими же отступами как AppBar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 0,
              ),
              child: Row(
                children: [
                  Icon(Icons.star, size: 20, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Главные события',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Действие "Все"
                    },
                    child: Text(
                      'Все',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🆕 Список карточек с такими же отступами как AppBar
            SizedBox(
              height: ScreenUtils.getFeaturedCardHeight(context),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: isMobile ? 16 : 0,
                  right: isMobile ? 16 : horizontalPadding,
                ),
                itemCount: featuredEvents.length,
                itemBuilder: (context, index) {
                  return FeaturedEventCard(
                    event: featuredEvents[index],
                    onTap: () => onEventTap(featuredEvents[index]),
                    cardWidth: ScreenUtils.getFeaturedCardWidth(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}