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
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onFilter;

  const EventCategoriesHeader({
    super.key,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.onAddEvent,
    this.onSearch,
    this.onFilter,
  });

  @override
  State<EventCategoriesHeader> createState() => _EventCategoriesHeaderState();
}

class _EventCategoriesHeaderState extends State<EventCategoriesHeader> {
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
    EventCategory(
      id: 'education',
      title: 'Обучение',
      description: 'Курсы и семинары',
      icon: Icons.school_rounded,
      color: Colors.lightBlueAccent,
    ),
    EventCategory(
      id: 'health',
      title: 'Здоровье',
      description: 'Врачи и спорт',
      icon: Icons.favorite_rounded,
      color: Colors.red,
    ),
    EventCategory(
      id: 'entertainment',
      title: 'Развлечения',
      description: 'Кино, театры, концерты',
      icon: Icons.music_note_rounded,
      color: Colors.amber,
    ),
    EventCategory(
      id: 'shopping',
      title: 'Покупки',
      description: 'Шопинг и заказы',
      icon: Icons.shopping_cart_rounded,
      color: Colors.teal,
    ),
    EventCategory(
      id: 'family',
      title: 'Семья',
      description: 'Семейные мероприятия',
      icon: Icons.family_restroom_rounded,
      color: Colors.blueGrey,
    ),
  ];

  final ScrollController _tabScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  bool _isFilterMenuVisible = false;

  Widget _buildTabItem(EventCategory category, int index) {
    final isSelected = widget.currentTabIndex == index;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [
            category.color.withOpacity(0.8),
            category.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isSelected ? null : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: category.color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onTabChanged(index);
            _animateToTab(index);
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    category.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _animateToTab(int index) {
    final double itemWidth = 120.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scrollOffset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _tabScrollController.animateTo(
      scrollOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        widget.onSearch?.call('');
      }
    });
  }

  void _showFilterMenu() {
    setState(() {
      _isFilterMenuVisible = true;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterMenu(),
    ).then((_) {
      setState(() {
        _isFilterMenuVisible = false;
      });
    });
  }

  Widget _buildFilterMenu() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.filter_alt_rounded, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Фильтры событий',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          _buildFilterOption('Только сегодня', Icons.today_rounded),
          _buildFilterOption('Предстоящие', Icons.upcoming_rounded),
          _buildFilterOption('Прошедшие', Icons.history_rounded),
          _buildFilterOption('С напоминанием', Icons.notifications_active_rounded),
          _buildFilterOption('Высокий приоритет', Icons.flag_rounded),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Сбросить'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('Применить'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: Switch(
        value: false,
        onChanged: (value) {},
        activeColor: Colors.blue,
      ),
      onTap: () {},
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isSearchVisible ? 56 : 0,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: _isSearchVisible
          ? TextField(
        controller: _searchController,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Поиск событий...',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Colors.white70),
            onPressed: _toggleSearch,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(color: Colors.white),
      )
          : SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _isSearchVisible ? 140.0 : 120.0,
      floating: false,
      pinned: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FlexibleSpaceBar(
          title: AnimatedOpacity(
            opacity: _isSearchVisible ? 0 : 1,
            duration: Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 16, left: 16),
                child: Text(
                  'Мои события',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          titlePadding: EdgeInsets.zero, // Убираем стандартные отступы
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_isSearchVisible ? 100 : 80),
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              _buildSearchField(),
              Container(
                height: 60,
                child: SingleChildScrollView(
                  controller: _tabScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
            ],
          ),
        ),
      ),
      actions: [
        if (!_isSearchVisible) ...[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isFilterMenuVisible ? 48 : 0,
            child: IconButton(
              icon: Icon(Icons.filter_alt_rounded, color: Colors.white),
              onPressed: _showFilterMenu,
              tooltip: 'Фильтры',
            ),
          ),
          IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.white),
            onPressed: _toggleSearch,
            tooltip: 'Поиск',
          ),
        ],
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
          onPressed: widget.onAddEvent,
          tooltip: 'Добавить событие',
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}