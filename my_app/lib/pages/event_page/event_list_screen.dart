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
  String _searchQuery = '';

  final List<EventCategory> _categories = [
    EventCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive_rounded,
      color: Colors.lightBlue,
    ),
    EventCategory(
      id: 'meeting',
      title: 'Встречи',
      description: 'Деловые и личные встречи',
      icon: Icons.people_alt_rounded,
      color: Colors.blue,
    ),
    EventCategory(
      id: 'birthday',
      title: 'Дни рождения',
      description: 'Праздники и поздравления',
      icon: Icons.cake_rounded,
      color: Colors.pink,
    ),
    EventCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Совещания и переговоры',
      icon: Icons.business_center_rounded,
      color: Colors.orange,
    ),
    EventCategory(
      id: 'travel',
      title: 'Путешествия',
      description: 'Поездки и командировки',
      icon: Icons.travel_explore_rounded,
      color: Colors.green,
    ),
  ];

  void _addEvent(Event newEvent) {
    setState(() {
      events.add(newEvent);
      events.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _editEvent(Event updatedEvent, int index) {
    setState(() {
      events[index] = updatedEvent;
      events.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
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
    ).then((_) {
      setState(() {});
    });
  }

  List<Event> _getFilteredEvents() {
    List<Event> filteredEvents = events;

    if (_currentTabIndex > 0) {
      final selectedCategory = _categories[_currentTabIndex];
      filteredEvents = filteredEvents.where((event) => event.category == selectedCategory.title).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) =>
      event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filteredEvents;
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Поиск событий...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    if (_currentTabIndex == 0) return SizedBox.shrink();

    final category = _categories[_currentTabIndex];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.1),
            category.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: category.color, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: category.color,
                    fontSize: 16,
                  ),
                ),
                if (category.description != null)
                  Text(
                    category.description!,
                    style: TextStyle(
                      fontSize: 14,
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

  Widget _buildEventCard(Event event, int index) {
    final bool isToday = event.date.day == DateTime.now().day &&
        event.date.month == DateTime.now().month &&
        event.date.year == DateTime.now().year;

    final bool isPast = event.date.isBefore(DateTime.now());

    return Dismissible(
      key: Key(event.title + event.date.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_rounded, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Удалить событие?"),
              content: Text("Вы уверены, что хотите удалить событие \"${event.title}\"?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Отмена"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Удалить", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteEvent(events.indexOf(event));
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(
                event: event,
                onEdit: (updatedEvent) {
                  _editEvent(updatedEvent, events.indexOf(event));
                },
                onDelete: () {
                  _deleteEvent(events.indexOf(event));
                },
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.color.withOpacity(0.9),
                    event.color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.event_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isToday)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'СЕГОДНЯ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                event.description,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.white70, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    '${event.date.day}.${event.date.month}.${event.date.year}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  if (event.category != null) ...[
                                    Icon(Icons.category, color: Colors.white70, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      event.category!,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  if (isPast)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          'ПРОШЕДШЕЕ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          EventCategoriesHeader(
            currentTabIndex: _currentTabIndex,
            onTabChanged: _onTabChanged,
            onAddEvent: _openAddEventDialog,
            onSearch: _onSearchChanged,
          ),
          SliverToBoxAdapter(child: _buildSearchField()),
          SliverToBoxAdapter(child: _buildCategoryInfo()),
          if (filteredEvents.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 100,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Пока нет событий',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Попробуйте изменить поисковый запрос'
                          : 'Нажмите + чтобы добавить первое событие',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildEventCard(filteredEvents[index], index);
                },
                childCount: filteredEvents.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEventDialog,
        child: Icon(Icons.add_rounded, size: 30),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}