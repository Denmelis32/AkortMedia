import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _showSearchBar = false;
  bool _showFilters = false;

  final List<EventCategory> _categories = [
    EventCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive_rounded,
      color: Colors.blue,
    ),
    EventCategory(
      id: 'meeting',
      title: 'Встречи',
      description: 'Деловые и личные встречи',
      icon: Icons.people_alt_rounded,
      color: Colors.green,
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
      color: Colors.purple,
    ),
  ];

  // АДАПТИВНЫЕ МЕТОДЫ КАК В PREDICTIONS PAGE
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 16;
  }

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
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск событий...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _showSearchBar = false;
              });
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildCategoriesCard(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Категории',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _categories.asMap().entries.map((entry) {
                    final category = entry.value;
                    return _buildCategoryChip(category);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(EventCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            setState(() {
              _currentTabIndex = _categories.indexOf(category);
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16, color: isSelected ? Colors.white : category.color),
                const SizedBox(width: 6),
                Text(category.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    final bool isToday = event.date.day == DateTime.now().day &&
        event.date.month == DateTime.now().month &&
        event.date.year == DateTime.now().year;

    final bool isPast = event.date.isBefore(DateTime.now());
    final timeUntilEvent = event.date.difference(DateTime.now());

    return Container(
      margin: EdgeInsets.all(_getCrossAxisCount(context) >= 3 ? 6 : 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
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
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ЗАГОЛОВОК С ИЗОБРАЖЕНИЕМ
              Stack(
                children: [
                  // Градиентный фон
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          event.color.withOpacity(0.9),
                          event.color,
                        ],
                      ),
                    ),
                  ),

                  // Категория в левом верхнем углу
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(event.category ?? 'Общее'),
                            size: 12,
                            color: event.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (event.category ?? 'Общее').toUpperCase(),
                            style: TextStyle(
                              color: event.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Статус в правом верхнем углу
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPast ? Colors.grey : (isToday ? Colors.green : Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isPast ? 'ПРОШЛО' : (isToday ? 'СЕГОДНЯ' : 'СКОРО'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Контент в нижней части
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ОСНОВНОЙ КОНТЕНТ
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Дата и время
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _formatEventDate(event.date),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getTimeUntilEvent(timeUntilEvent),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPast ? Colors.grey : (isToday ? Colors.green : Colors.orange),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Прогресс-бар до события
                    if (!isPast)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _calculateProgress(event.date),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isToday ? Colors.green : Colors.orange,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_calculateProgress(event.date) * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                isToday ? 'Сегодня!' : 'До события',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
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

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return 'Сегодня, ${DateFormat('HH:mm').format(date)}';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      return 'Завтра, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }

  String _getTimeUntilEvent(Duration difference) {
    if (difference.isNegative) {
      return 'Завершено';
    } else if (difference.inDays > 0) {
      return 'Через ${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return 'Через ${difference.inHours}ч';
    } else {
      return 'Через ${difference.inMinutes}м';
    }
  }

  double _calculateProgress(DateTime eventDate) {
    final now = DateTime.now();
    final eventStart = eventDate.subtract(const Duration(days: 30));
    final totalDuration = eventDate.difference(eventStart);
    final passedDuration = now.difference(eventStart);

    if (passedDuration.isNegative) return 0.0;
    if (passedDuration > totalDuration) return 1.0;

    return passedDuration.inSeconds / totalDuration.inSeconds;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Встречи': Icons.people_alt_rounded,
      'Дни рождения': Icons.cake_rounded,
      'Бизнес': Icons.business_center_rounded,
      'Путешествия': Icons.travel_explore_rounded,
      'Общее': Icons.event_rounded,
    };
    return icons[category] ?? Icons.event_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      backgroundColor: Colors.transparent, // ИЗМЕНЕНО: прозрачный фон
      body: Container(
        decoration: const BoxDecoration( // ДОБАВЛЕНО: градиентный фон как в CardsPage
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    if (!_showSearchBar) ...[
                      const Text(
                        'Мои События',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],

                    if (_showSearchBar)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildSearchField()),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.black, size: 18),
                              ),
                              onPressed: () => setState(() {
                                _showSearchBar = false;
                                _searchQuery = '';
                              }),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search, color: Colors.black, size: 18),
                            ),
                            onPressed: () => setState(() => _showSearchBar = true),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Категории
                    SliverToBoxAdapter(child: _buildCategoriesCard(horizontalPadding)),

                    // Карточки событий
                    if (filteredEvents.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available_rounded, size: 60, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text(
                                'События не найдены',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Попробуйте изменить параметры поиска',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _getCrossAxisCount(context),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              return _buildEventCard(filteredEvents[index], index);
                            },
                            childCount: filteredEvents.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEventDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}