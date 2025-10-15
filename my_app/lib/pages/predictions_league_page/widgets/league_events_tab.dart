import 'package:flutter/material.dart';
import 'event_item.dart'; // Импортируем наш новый виджет

class LeagueEventsTab extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final Function(Map<String, dynamic>) onEventSelected;

  const LeagueEventsTab({
    super.key,
    required this.events,
    required this.onEventSelected,
  });

  @override
  State<LeagueEventsTab> createState() => _LeagueEventsTabState();
}

class _LeagueEventsTabState extends State<LeagueEventsTab> {
  String _selectedFilter = 'Все';
  final List<String> _filters = ['Все', 'Футбол', 'LIVE', 'Сегодня'];

  List<Map<String, dynamic>> get _filteredEvents {
    switch (_selectedFilter) {
      case 'Футбол':
        return widget.events.where((event) => event['sport'] == 'Футбол').toList();
      case 'LIVE':
        return widget.events.where((event) => event['isLive'] == true).toList();
      case 'Сегодня':
        final today = DateTime.now();
        return widget.events.where((event) {
          final eventDate = event['date'] as DateTime;
          return eventDate.year == today.year &&
              eventDate.month == today.month &&
              eventDate.day == today.day;
        }).toList();
      default:
        return widget.events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Фильтры
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: _filters.map((filter) {
                    return _buildFilterChip(filter, _selectedFilter == filter);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Список событий
        if (_filteredEvents.isNotEmpty)
          ..._filteredEvents.map((event) => EventItem(
            event: event,
            onTap: () => widget.onEventSelected(event),
          )).toList()
        else
          _buildEmptyEventsState(),

        // Кнопка показать больше
        if (_filteredEvents.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: OutlinedButton(
              onPressed: _loadMoreEvents,
              child: const Text('Показать больше событий'),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'Все';
        });
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Column(
      children: [
        const Icon(Icons.event, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Нет доступных событий',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedFilter == 'Все'
              ? 'События появятся ближе к началу матчей'
              : 'Нет событий по выбранному фильтру',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedFilter = 'Все';
            });
          },
          child: const Text('Показать все события'),
        ),
      ],
    );
  }

  void _loadMoreEvents() {
    // Здесь будет логика загрузки дополнительных событий
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Загрузка дополнительных событий...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}