import 'package:flutter/material.dart';
import 'event_details_screen.dart';
import 'event_model.dart';
import 'add_event_dialog.dart';
import 'event_categories.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Event> events = [];
  int _currentTabIndex = 0;

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

  void _addEvent(Event newEvent) {
    setState(() {
      events.add(newEvent);
    });
  }

  void _openAddEventDialog() {
    final selectedCategory = _categories[_currentTabIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEventDialog(
          onAdd: _addEvent,
          initialCategory: selectedCategory.id == 'all' ? null : selectedCategory.title,
        );
      },
    );
  }

  List<Event> _getFilteredEvents() {
    if (_currentTabIndex == 0) {
      return events; // Все события
    }

    final selectedCategory = _categories[_currentTabIndex];
    return events.where((event) => event.category == selectedCategory.title).toList();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          EventCategoriesHeader(
            currentTabIndex: _currentTabIndex,
            onTabChanged: _onTabChanged,
            onAddEvent: _openAddEventDialog,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCategoryInfo(),
            ),
          ),
          filteredEvents.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Пока нет событий',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Нажмите + чтобы добавить',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildEventCard(filteredEvents[index]);
              },
              childCount: filteredEvents.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEventDialog,
        child: Icon(Icons.add, size: 30),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    if (_currentTabIndex == 0) return SizedBox.shrink();

    final category = _categories[_currentTabIndex];
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: category.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(category.icon, color: category.color, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: category.color,
                  ),
                ),
                if (category.description != null)
                  Text(
                    category.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: category.color.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// В методе _buildEventCard замените ListTile на GestureDetector:
  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                event.color.withOpacity(0.8),
                event.color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Icon(
              Icons.event,
              color: Colors.white,
              size: 30,
            ),
            title: Text(
              event.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  event.description,
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  '${event.date.day}.${event.date.month}.${event.date.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                if (event.category != null)
                  Text(
                    'Категория: ${event.category}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

}