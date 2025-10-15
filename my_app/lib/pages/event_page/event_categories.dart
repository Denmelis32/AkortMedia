import 'package:flutter/material.dart';

class EventCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final int count;
  final bool isActive;
  final int sortOrder;

  const EventCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.count = 0,
    this.isActive = true,
    this.sortOrder = 0,
  });

  EventCategory copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    int? count,
    bool? isActive,
    int? sortOrder,
  }) {
    return EventCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      count: count ?? this.count,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class EventCategoriesHeader extends StatefulWidget {
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddEvent;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onFilter;
  final ValueChanged<Map<String, dynamic>>? onAdvancedFilter;
  final bool showSearchBar;
  final VoidCallback? onSearchToggle;
  final String searchQuery;

  const EventCategoriesHeader({
    super.key,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.onAddEvent,
    this.onSearch,
    this.onFilter,
    this.onAdvancedFilter,
    this.showSearchBar = false,
    this.onSearchToggle,
    this.searchQuery = '',
  });

  @override
  State<EventCategoriesHeader> createState() => _EventCategoriesHeaderState();
}

class _EventCategoriesHeaderState extends State<EventCategoriesHeader>
    with TickerProviderStateMixin {
  final List<EventCategory> _categories = [
    EventCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive_rounded,
      color: Colors.blue,
      count: 156,
    ),
    EventCategory(
      id: 'meeting',
      title: 'Встречи',
      description: 'Деловые и личные встречи',
      icon: Icons.people_alt_rounded,
      color: Colors.blue,
      count: 42,
    ),
    EventCategory(
      id: 'birthday',
      title: 'Дни рождения',
      description: 'Праздники и поздравления',
      icon: Icons.cake_rounded,
      color: Colors.pink,
      count: 28,
    ),
    EventCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Совещания и переговоры',
      icon: Icons.business_center_rounded,
      color: Colors.orange,
      count: 35,
    ),
    EventCategory(
      id: 'travel',
      title: 'Путешествия',
      description: 'Поездки и командировки',
      icon: Icons.travel_explore_rounded,
      color: Colors.green,
      count: 19,
    ),
    EventCategory(
      id: 'education',
      title: 'Обучение',
      description: 'Курсы и семинары',
      icon: Icons.school_rounded,
      color: Colors.lightBlueAccent,
      count: 27,
    ),
    EventCategory(
      id: 'health',
      title: 'Здоровье',
      description: 'Врачи и спорт',
      icon: Icons.favorite_rounded,
      color: Colors.red,
      count: 31,
    ),
    EventCategory(
      id: 'entertainment',
      title: 'Развлечения',
      description: 'Кино, театры, концерты',
      icon: Icons.music_note_rounded,
      color: Colors.amber,
      count: 45,
    ),
    EventCategory(
      id: 'shopping',
      title: 'Покупки',
      description: 'Шопинг и заказы',
      icon: Icons.shopping_cart_rounded,
      color: Colors.teal,
      count: 22,
    ),
    EventCategory(
      id: 'family',
      title: 'Семья',
      description: 'Семейные мероприятия',
      icon: Icons.family_restroom_rounded,
      color: Colors.blueGrey,
      count: 18,
    ),
    EventCategory(
      id: 'conference',
      title: 'Конференции',
      description: 'Профессиональные мероприятия',
      icon: Icons.record_voice_over_rounded,
      color: Colors.indigo,
      count: 15,
    ),
    EventCategory(
      id: 'workshop',
      title: 'Воркшопы',
      description: 'Практические занятия',
      icon: Icons.work_rounded,
      color: Colors.teal,
      count: 12,
    ),
    EventCategory(
      id: 'networking',
      title: 'Нетворкинг',
      description: 'Деловые знакомства',
      icon: Icons.handshake_rounded,
      color: Colors.cyan,
      count: 8,
    ),
  ];

  final ScrollController _tabScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Анимации
  late AnimationController _searchAnimationController;
  late Animation<double> _searchHeightAnimation;
  late Animation<double> _searchOpacityAnimation;

  // Состояния фильтров
  final Map<String, dynamic> _activeFilters = {};
  int _activeFiltersCount = 0;

  @override
  void initState() {
    super.initState();

    // Инициализация анимаций
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _searchHeightAnimation = Tween<double>(
      begin: 0.0,
      end: 56.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _searchOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    // Запуск анимации если поиск активен
    if (widget.showSearchBar) {
      _searchAnimationController.forward();
    }

    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(EventCategoriesHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showSearchBar != oldWidget.showSearchBar) {
      if (widget.showSearchBar) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
      }
    }

    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  Widget _buildTabItem(EventCategory category, int index) {
    final isSelected = widget.currentTabIndex == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [
            category.color.withOpacity(0.9),
            category.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isSelected ? null : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: category.color.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ]
            : null,
        border: isSelected
            ? null
            : Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                ),
                SizedBox(width: 8),
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    category.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (category.count > 0) ...[
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _animateToTab(int index) {
    final double itemWidth = 140.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scrollOffset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _tabScrollController.animateTo(
      scrollOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildSearchField() {
    return AnimatedBuilder(
      animation: _searchAnimationController,
      builder: (context, child) {
        return Container(
          height: _searchHeightAnimation.value,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _searchHeightAnimation.value > 0
              ? Opacity(
            opacity: _searchOpacityAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearch,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Поиск событий, мест, категорий...',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white70),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear_rounded, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearch?.call('');
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: widget.onSearchToggle,
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
              : SizedBox.shrink(),
        );
      },
    );
  }

  void _showAdvancedFilterMenu() {
    final Map<String, dynamic> initialFilters = Map.from(_activeFilters);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAdvancedFilterMenu(initialFilters),
    ).then((result) {
      if (result != null) {
        setState(() {
          _activeFilters.clear();
          _activeFilters.addAll(result);
          _activeFiltersCount = _countActiveFilters(result);
        });
        widget.onAdvancedFilter?.call(result);
      }
    });
  }

  Widget _buildAdvancedFilterMenu(Map<String, dynamic> initialFilters) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_alt_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Расширенные фильтры',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Статус события',
                    Icons.event_available_rounded,
                    [
                      _buildFilterOption('Только активные', 'active', initialFilters),
                      _buildFilterOption('Прошедшие', 'past', initialFilters),
                      _buildFilterOption('Сегодня', 'today', initialFilters),
                      _buildFilterOption('На этой неделе', 'this_week', initialFilters),
                    ],
                  ),

                  SizedBox(height: 24),

                  _buildFilterSection(
                    'Тип события',
                    Icons.category_rounded,
                    [
                      _buildFilterOption('Онлайн', 'online', initialFilters),
                      _buildFilterOption('Офлайн', 'offline', initialFilters),
                      _buildFilterOption('Бесплатные', 'free', initialFilters),
                      _buildFilterOption('Платные', 'paid', initialFilters),
                    ],
                  ),

                  SizedBox(height: 24),

                  _buildFilterSection(
                    'Приоритет',
                    Icons.flag_rounded,
                    [
                      _buildFilterOption('Высокий', 'high_priority', initialFilters),
                      _buildFilterOption('С напоминанием', 'with_reminder', initialFilters),
                      _buildFilterOption('Избранные', 'favorite', initialFilters),
                    ],
                  ),

                  SizedBox(height: 24),

                  _buildFilterSection(
                    'Участники',
                    Icons.people_rounded,
                    [
                      _buildFilterOption('Свободные места', 'has_free_slots', initialFilters),
                      _buildFilterOption('Популярные', 'popular', initialFilters),
                      _buildFilterOption('Мало участников', 'small_event', initialFilters),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer buttons
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop({}),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Сбросить все'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(initialFilters),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Применить фильтры'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options,
        ),
      ],
    );
  }

  Widget _buildFilterOption(String title, String key, Map<String, dynamic> filters) {
    final isSelected = filters[key] == true;

    return FilterChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (selected) {
        filters[key] = selected;
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  int _countActiveFilters(Map<String, dynamic> filters) {
    return filters.values.where((value) => value == true).length;
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onPressed, {int? badgeCount}) {
    return Stack(
      children: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount > 9 ? '9+' : badgeCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // АДАПТИВНЫЕ МЕТОДЫ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final isSearchActive = widget.showSearchBar;

    return SliverAppBar(
      expandedHeight: isSearchActive ? 140.0 : 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent.shade400, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        title: AnimatedOpacity(
          opacity: isSearchActive ? 0 : 1,
          duration: Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 16, left: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Мои события',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Управляйте вашими мероприятиями',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(isSearchActive ? 100 : 80),
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
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding - 12),
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
        if (!isSearchActive) ...[
          _buildActionButton(
            Icons.filter_alt_rounded,
            'Фильтры',
            _showAdvancedFilterMenu,
            badgeCount: _activeFiltersCount,
          ),
          _buildActionButton(
            Icons.search_rounded,
            'Поиск',
            widget.onSearchToggle ?? () {},
          ),
        ],
        _buildActionButton(
          Icons.add_rounded,
          'Добавить событие',
          widget.onAddEvent,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }
}