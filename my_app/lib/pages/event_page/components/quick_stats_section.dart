import 'package:flutter/material.dart';

class QuickStatsSection extends StatelessWidget {
  final int totalEventsCreated;
  final int eventsThisMonth;
  final int totalFavorites;

  const QuickStatsSection({
    Key? key,
    required this.totalEventsCreated,
    required this.eventsThisMonth,
    required this.totalFavorites,
  }) : super(key: key);

  // 🆕 Тот же метод для определения горизонтальных отступов
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

    return Container(
      // 🆕 Тот же margin как в CategoriesSection
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 0, // 🆕 Только на мобильных
        vertical: 8,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
        ),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: isMobile
              ? _buildMobileStats()
              : _buildDesktopStats(),
        ),
      ),
    );
  }

  // 🆕 ВЕРСИЯ ДЛЯ МОБИЛЬНЫХ
  Widget _buildMobileStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMobileStatItem(
          'Всего',
          totalEventsCreated.toString(),
          Icons.event,
          Colors.blue,
        ),
        _buildMobileStatItem(
          'Месяц',
          eventsThisMonth.toString(),
          Icons.calendar_month,
          Colors.green,
        ),
        _buildMobileStatItem(
          'Избранное',
          totalFavorites.toString(),
          Icons.favorite,
          Colors.red,
        ),
      ],
    );
  }

  // 🆕 СТАТИСТИКА ДЛЯ МОБИЛЬНЫХ
  Widget _buildMobileStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 🆕 ВЕРСИЯ ДЛЯ ДЕСКТОПА
  Widget _buildDesktopStats() {
    return Row(
      children: [
        Expanded(
          child: _buildDesktopStatItem(
            'Всего событий',
            totalEventsCreated.toString(),
            Icons.event,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDesktopStatItem(
            'В этом месяце',
            eventsThisMonth.toString(),
            Icons.calendar_month,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDesktopStatItem(
            'В избранном',
            totalFavorites.toString(),
            Icons.favorite,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopStatItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}