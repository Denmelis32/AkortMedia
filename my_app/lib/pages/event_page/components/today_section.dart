import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../event_model.dart';
import '../utils/event_utils.dart';

class TodaySection extends StatelessWidget {
  final List<Event> todayEvents;
  final ValueChanged<Event> onEventTap;

  const TodaySection({
    Key? key,
    required this.todayEvents,
    required this.onEventTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🆕 ЕСЛИ НЕТ СЕГОДНЯШНИХ СОБЫТИЙ, НЕ ПОКАЗЫВАЕМ СЕКЦИЮ
    if (todayEvents.isEmpty) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width <= 600;
    final now = DateTime.now();

    // 🆕 РАЗДЕЛЯЕМ СОБЫТИЯ НА ПРОШЕДШИЕ, ТЕКУЩИЕ И БУДУЩИЕ
    final pastEvents = todayEvents.where((e) => e.endDate.isBefore(now)).toList();
    final currentEvents = todayEvents.where((e) =>
    e.date.isBefore(now) && e.endDate.isAfter(now)
    ).toList();
    final upcomingEvents = todayEvents.where((e) => e.date.isAfter(now)).toList();

    // 🆕 ПРИОРИТЕТ ДЛЯ ТЕКУЩИХ И БЛИЖАЙШИХ СОБЫТИЙ
    final eventsToShow = [
      ...currentEvents,
      ...upcomingEvents.take(3 - currentEvents.length)
    ].take(3).toList();

    return FadeTransition(
      opacity: AlwaysStoppedAnimation(1.0),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 0,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🆕 ИСПРАВЛЕННЫЙ ЗАГОЛОВОК ДЛЯ МОБИЛЬНЫХ УСТРОЙСТВ
                if (isMobile)
                  _buildMobileHeader(currentEvents, upcomingEvents, context)
                else
                  _buildDesktopHeader(currentEvents, upcomingEvents, context),

                const SizedBox(height: 12),

                // 🆕 ИНДИКАТОРЫ СТАТУСОВ
                if (pastEvents.isNotEmpty || currentEvents.isNotEmpty) ...[
                  _buildStatusIndicators(pastEvents, currentEvents, isMobile),
                  const SizedBox(height: 8),
                ],

                // СПИСОК СОБЫТИЙ
                Column(
                  children: [
                    ...eventsToShow.asMap().entries.map((entry) {
                      final index = entry.key;
                      final event = entry.value;
                      final isCurrent = currentEvents.contains(event);

                      return Column(
                        children: [
                          _buildTodayEventItem(event, context, isCurrent: isCurrent),
                          if (index < eventsToShow.length - 1)
                            const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🆕 ОТДЕЛЬНЫЙ МЕТОД ДЛЯ МОБИЛЬНОГО ЗАГОЛОВКА
  Widget _buildMobileHeader(List<Event> currentEvents, List<Event> upcomingEvents, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Первая строка: заголовок и бейдж
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сегодня',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (currentEvents.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Сейчас проходит ${currentEvents.length} ${_getEventsCountText(currentEvents.length)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Бейдж
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getBadgeColor(upcomingEvents.length),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (upcomingEvents.isNotEmpty)
                    Icon(Icons.access_time, size: 12, color: _getBadgeTextColor(upcomingEvents.length)),
                  if (upcomingEvents.isNotEmpty) const SizedBox(width: 4),
                  Text(
                    '${upcomingEvents.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getBadgeTextColor(upcomingEvents.length),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Вторая строка: кнопка "Все сегодня"
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              _showAllTodayEvents(context, todayEvents);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Все сегодня',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: Colors.blue[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🆕 ОТДЕЛЬНЫЙ МЕТОД ДЛЯ ДЕСКТОПНОГО ЗАГОЛОВКА
  Widget _buildDesktopHeader(List<Event> currentEvents, List<Event> upcomingEvents, BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сегодня',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (currentEvents.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Сейчас проходит ${currentEvents.length} ${_getEventsCountText(currentEvents.length)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const Spacer(),

        // 🆕 УЛУЧШЕННЫЙ БЕЙДЖ С РАЗБИВКОЙ
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getBadgeColor(upcomingEvents.length),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (upcomingEvents.isNotEmpty)
                Icon(Icons.access_time, size: 12, color: _getBadgeTextColor(upcomingEvents.length)),
              if (upcomingEvents.isNotEmpty) const SizedBox(width: 4),
              Text(
                '${upcomingEvents.length} ${_getEventsCountText(upcomingEvents.length)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getBadgeTextColor(upcomingEvents.length),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Кнопка "Все сегодня"
        TextButton(
          onPressed: () {
            _showAllTodayEvents(context, todayEvents);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            backgroundColor: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Все сегодня',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 14, color: Colors.blue[700]),
            ],
          ),
        ),
      ],
    );
  }

  // 🆕 ОТДЕЛЬНЫЙ МЕТОД ДЛЯ ИНДИКАТОРОВ СТАТУСА
  Widget _buildStatusIndicators(List<Event> pastEvents, List<Event> currentEvents, bool isMobile) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        if (pastEvents.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Прошедшие: ${pastEvents.length}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        if (currentEvents.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Сейчас: ${currentEvents.length}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
      ],
    );
  }

  // 🆕 ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ
  Color _getBadgeColor(int count) {
    if (count == 0) return Colors.grey[100]!;
    if (count <= 2) return Colors.orange[100]!;
    return Colors.green[100]!;
  }

  Color _getBadgeTextColor(int count) {
    if (count == 0) return Colors.grey[600]!;
    if (count <= 2) return Colors.orange[800]!;
    return Colors.green[800]!;
  }

  void _showAllTodayEvents(BuildContext context, List<Event> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Индикатор свайпа для закрытия
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Все события сегодня',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isCurrent = event.date.isBefore(DateTime.now()) &&
                      event.endDate.isAfter(DateTime.now());
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTodayEventItem(event, context, isCurrent: isCurrent),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayEventItem(Event event, BuildContext context, {bool isCurrent = false}) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onEventTap(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            color: isCurrent ? Colors.green[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent ? Colors.green[200]! : Colors.grey[200]!,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🆕 ОБНОВЛЕННЫЙ ИНДИКАТОР С УЧЕТОМ СТАТУСА
              Container(
                width: 4,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.green : event.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и категория
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isCurrent) ...[
                                    Icon(Icons.play_arrow, size: 12, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Сейчас идет',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('HH:mm').format(event.date)} • ${event.location ?? 'Место не указано'}',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: event.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                EventUtils.getCategoryIcon(event.category),
                                size: 10,
                                color: event.color,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _getCategoryShort(event.category),
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: event.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Организатор
                    Text(
                      event.organizer,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // СТАТУС УЧАСТНИКОВ И ЦЕНА
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${event.currentAttendees}/${event.maxAttendees}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        // Цена
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.price == 0 ? Colors.green[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: event.price == 0 ? Colors.green[100]! : Colors.orange[100]!,
                            ),
                          ),
                          child: Text(
                            event.price == 0 ? 'БЕСПЛАТНО' : '${event.price}₽',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: event.price == 0 ? Colors.green[700] : Colors.orange[700],
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
    );
  }

  // Вспомогательные методы
  String _getEventsCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'событие';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20))
      return 'события';
    return 'событий';
  }

  String _getCategoryShort(String category) {
    final Map<String, String> categories = {
      'Концерты': 'КОНЦЕРТ', 'Выставки': 'ВЫСТАВКА', 'Фестивали': 'ФЕСТИВАЛЬ',
      'Образование': 'ОБУЧЕНИЕ', 'Спорт': 'СПОРТ', 'Театр': 'ТЕАТР',
      'Встречи': 'ВСТРЕЧА', 'Вечеринка': 'ВЕЧЕРИНКА', 'Лекция': 'ЛЕКЦИЯ',
      'Мастер-класс': 'МАСТЕР-КЛАСС', 'Семинар': 'СЕМИНАР', 'Митап': 'МИТАП',
    };
    return categories[category] ?? category.toUpperCase();
  }
}