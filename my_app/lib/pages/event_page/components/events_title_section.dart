import 'package:flutter/material.dart';

class EventsTitleSection extends StatelessWidget {
  final int eventsCount;

  const EventsTitleSection({
    Key? key,
    required this.eventsCount,
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

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : horizontalPadding, // 🆕 Адаптивные отступы
          vertical: 16,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 0, // 🆕 Внутренние отступы на мобильных
          ),
          child: Row(
            children: [
              Icon(Icons.event, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'События',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '$eventsCount найдено',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}