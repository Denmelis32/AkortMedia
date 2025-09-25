import 'package:flutter/material.dart';

class EventCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  EventCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });
}

class EventCategoriesHeader extends StatefulWidget {
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddEvent;

  const EventCategoriesHeader({
    super.key,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.onAddEvent,
  });

  @override
  State<EventCategoriesHeader> createState() => _EventCategoriesHeaderState();
}

class _EventCategoriesHeaderState extends State<EventCategoriesHeader> {
  final List<EventCategory> _categories = [
    EventCategory(
      id: 'all',
      title: 'Все события',
      icon: Icons.all_inclusive,
      color: Colors.deepPurple,
    ),
    EventCategory(
      id: 'meeting',
      title: 'Встречи',
      description: 'Деловые и личные встречи',
      icon: Icons.people,
      color: Colors.blue,
    ),
    EventCategory(
      id: 'birthday',
      title: 'Дни рождения',
      description: 'Праздники и поздравления',
      icon: Icons.cake,
      color: Colors.pink,
    ),
    EventCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Совещания и переговоры',
      icon: Icons.business,
      color: Colors.orange,
    ),
    EventCategory(
      id: 'travel',
      title: 'Путешествия',
      description: 'Поездки и командировки',
      icon: Icons.flight,
      color: Colors.green,
    ),
    EventCategory(
      id: 'education',
      title: 'Обучение',
      description: 'Курсы и семинары',
      icon: Icons.school,
      color: Colors.purple,
    ),
    EventCategory(
      id: 'health',
      title: 'Здоровье',
      description: 'Врачи и спорт',
      icon: Icons.favorite,
      color: Colors.red,
    ),
    EventCategory(
      id: 'entertainment',
      title: 'Развлечения',
      description: 'Кино, театры, концерты',
      icon: Icons.music_note,
      color: Colors.amber,
    ),
  ];

  final ScrollController _tabScrollController = ScrollController();

  Widget _buildTabItem(EventCategory category, int index) {
    final isSelected = widget.currentTabIndex == index;
    return GestureDetector(
      onTap: () => widget.onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? category.color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              category.title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.deepPurple,
      title: Text(
        'Мои события',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: ColoredBox(
          color: Colors.deepPurple,
          child: SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories
                  .asMap()
                  .entries
                  .map((entry) => _buildTabItem(entry.value, entry.key))
                  .toList(),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Поиск событий
          },
          tooltip: 'Поиск событий',
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            // Фильтры событий
          },
          tooltip: 'Фильтры',
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: widget.onAddEvent,
          tooltip: 'Добавить событие',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }
}