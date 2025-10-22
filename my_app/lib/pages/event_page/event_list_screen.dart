import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/event_page/today_events.dart';
import 'package:share_plus/share_plus.dart';
import 'event_model.dart';
import 'event_data.dart';
import 'add_event_dialog.dart';
import 'event_details_screen.dart' hide ScreenSize;
import 'components/custom_app_bar.dart';
import 'components/featured_section.dart';
import 'components/categories_section.dart';
import 'components/quick_stats_section.dart';
import 'components/today_section.dart';
import 'components/events_title_section.dart';
import 'components/upcoming_section.dart';
import 'utils/screen_utils.dart';
import 'utils/event_utils.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with TickerProviderStateMixin {
  // НОВЫЙ ОСНОВНОЙ ЦВЕТ #1B2A30 (темный сине-зеленый)
  final Color _primaryColor = const Color(0xFF1B2A30);
  final Color _secondaryColor = const Color(0xFF2A3D45); // Более светлый оттенок
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF37474F);

  // Темные градиенты для карточек
  final List<Color> _cardGradients = [
    const Color(0xFFE3F2FD), // Светло-голубой
    const Color(0xFFF3E5F5), // Светло-фиолетовый
    const Color(0xFFE8F5E8), // Светло-зеленый
    const Color(0xFFFFF3E0), // Светло-оранжевый
    const Color(0xFFFCE4EC), // Светло-розовый
    const Color(0xFFE0F2F1), // Светло-бирюзовый
    const Color(0xFFEDE7F6), // Светло-лавандовый
    const Color(0xFFFFF8E1), // Светло-желтый
  ];

  final List<Color> _cardBorderColors = [
    const Color(0xFF90CAF9), // Голубой
    const Color(0xFFCE93D8), // Фиолетовый
    const Color(0xFFA5D6A7), // Зеленый
    const Color(0xFFFFCC80), // Оранжевый
    const Color(0xFFF48FB1), // Розовый
    const Color(0xFF80CBC4), // Бирюзовый
    const Color(0xFFB39DDB), // Лавандовый
    const Color(0xFFFFE082), // Желтый
  ];

  List<Event> events = [];
  int _currentTabIndex = 0;
  String _searchQuery = '';
  bool _showSearchBar = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Состояния пользователя
  final Set<String> _favoriteEvents = {};
  final Set<String> _attendingEvents = {};
  final Map<String, int> _eventViews = {};
  final Map<String, double> _eventRatings = {};

  // Фильтры и сортировка
  DateTime? _selectedDate;
  double _priceRange = 5000;
  String _selectedCity = 'Москва';
  List<String> _selectedTags = [];
  String _sortBy = 'date';
  bool _showFreeOnly = false;
  bool _showOnlineOnly = false;

  // Статистика
  int _totalEventsCreated = 0;
  int _eventsThisMonth = 0;
  int _totalFavorites = 0;

  // Анимации
  late AnimationController _refreshController;

  // ФИКСИРОВАННАЯ МАКСИМАЛЬНАЯ ШИРИНА ДЛЯ ДЕСКТОПА
  double get _maxContentWidth => 1200;
  double get _minContentWidth => 320;

  // Пример популярных событий - ИНИЦИАЛИЗИРУЕМ СРАЗУ
  late final List<Event> _featuredEvents = EventData.featuredEvents;

  final List<EventCategory> _categories = [
    EventCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive_rounded,
      color: const Color(0xFF1B2A30), // Новый цвет
      count: 156,
    ),
    EventCategory(
      id: 'concert',
      title: 'Концерты',
      description: 'Музыкальные мероприятия',
      icon: Icons.music_note_rounded,
      color: Colors.purple,
      count: 42,
    ),
    EventCategory(
      id: 'exhibition',
      title: 'Выставки',
      description: 'Искусство и культура',
      icon: Icons.palette_rounded,
      color: const Color(0xFF1B2A30), // Новый цвет
      count: 28,
    ),
    EventCategory(
      id: 'festival',
      title: 'Фестивали',
      description: 'Праздники и мероприятия',
      icon: Icons.celebration_rounded,
      color: Colors.orange,
      count: 15,
    ),
    EventCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer_rounded,
      color: Colors.green,
      count: 33,
    ),
    EventCategory(
      id: 'theater',
      title: 'Театр',
      description: 'Спектакли и постановки',
      icon: Icons.theater_comedy_rounded,
      color: Colors.red,
      count: 19,
    ),
    EventCategory(
      id: 'meeting',
      title: 'Встречи',
      description: 'Деловые и личные встречи',
      icon: Icons.people_alt_rounded,
      color: Colors.teal,
      count: 47,
    ),
    EventCategory(
      id: 'education',
      title: 'Образование',
      description: 'Лекции и мастер-классы',
      icon: Icons.school_rounded,
      color: Colors.indigo,
      count: 24,
    ),
  ];

  final List<String> _cities = ['Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань'];
  final List<String> _popularTags = ['бесплатно', 'премьера', 'онлайн', 'для детей', 'гастрономия', 'искусство', 'музыка', 'спорт'];

  // АДАПТИВНЫЕ МЕТОДЫ КАК В ПЕРВОМ ФАЙЛЕ
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // ШИРИНА КОНТЕНТА С УЧЕТОМ ОГРАНИЧЕНИЙ
  double _getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > _maxContentWidth) return _maxContentWidth;
    return screenWidth;
  }

  int _getCrossAxisCount(BuildContext context) {
    final contentWidth = _getContentWidth(context);
    if (contentWidth > 1000) return 3;
    if (contentWidth > 700) return 2;
    return 1;
  }

  // АДАПТИВНЫЕ ОТСТУПЫ
  double _getHorizontalPadding(BuildContext context) {
    final contentWidth = _getContentWidth(context);
    if (contentWidth > 1000) return 24;
    if (contentWidth > 800) return 20;
    if (contentWidth > 600) return 16;
    return 12;
  }

  // ОСНОВНОЙ LAYOUT С ФИКСИРОВАННОЙ ШИРИНОЙ
  Widget _buildDesktopLayout(Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _maxContentWidth,
          minWidth: _minContentWidth,
        ),
        child: content,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
    _initializeEventData();
    _loadInitialData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.forward();
  }

  void _initializeEventData() {
    for (var event in _featuredEvents) {
      _eventViews[event.id] = (event.currentAttendees * 3) + 100;
      _eventRatings[event.id] = event.rating;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    // 🆕 ЗАГРУЖАЕМ ВСЕ СОБЫТИЯ ИЗ ФАЙЛА ДАННЫХ
    final allEvents = EventData.getAllEvents();

    setState(() {
      events = allEvents;
      _isLoading = false;
      _totalEventsCreated = events.length;
      _eventsThisMonth = events.where((e) => e.date.month == DateTime.now().month).length;

      // Инициализируем просмотры для всех событий
      for (var event in events) {
        _eventViews[event.id] = (_eventViews[event.id] ?? (event.currentAttendees * 3) + 100);
        _eventRatings[event.id] = event.rating;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
    }
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedDate != null) count++;
    if (_priceRange < 5000) count++;
    if (_selectedCity != 'Москва') count++;
    if (_selectedTags.isNotEmpty) count++;
    if (_showFreeOnly) count++;
    if (_showOnlineOnly) count++;
    if (_sortBy != 'date') count++;
    return count;
  }

  List<Event> _getFilteredEvents() {
    List<Event> filteredEvents = List.from(events);

    // Фильтрация по категории
    if (_currentTabIndex > 0) {
      final selectedCategory = _categories[_currentTabIndex];
      filteredEvents = filteredEvents.where((event) => event.category == selectedCategory.title).toList();
    }

    // Фильтрация по поиску
    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) =>
      event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (event.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          event.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    // Фильтрация по дате
    if (_selectedDate != null) {
      filteredEvents = filteredEvents.where((event) =>
      event.date.year == _selectedDate!.year &&
          event.date.month == _selectedDate!.month &&
          event.date.day == _selectedDate!.day
      ).toList();
    }

    // Фильтрация по цене
    filteredEvents = filteredEvents.where((event) =>
    event.price == null || event.price! <= _priceRange
    ).toList();

    // Фильтрация по городу
    if (_selectedCity != 'Москва') {
      filteredEvents = filteredEvents.where((event) =>
      event.location == _selectedCity
      ).toList();
    }

    // Фильтрация по тегам
    if (_selectedTags.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) =>
          _selectedTags.any((tag) => event.tags.contains(tag))
      ).toList();
    }

    // Фильтрация бесплатных
    if (_showFreeOnly) {
      filteredEvents = filteredEvents.where((event) =>
      event.price == 0
      ).toList();
    }

    // Фильтрация онлайн
    if (_showOnlineOnly) {
      filteredEvents = filteredEvents.where((event) =>
      event.isOnline
      ).toList();
    }

    // Сортировка
    switch (_sortBy) {
      case 'date':
        filteredEvents.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'popularity':
        filteredEvents.sort((a, b) => (_eventViews[b.id] ?? 0).compareTo(_eventViews[a.id] ?? 0));
        break;
      case 'price_low':
        filteredEvents.sort((a, b) => (a.price ?? double.infinity).compareTo(b.price ?? double.infinity));
        break;
      case 'price_high':
        filteredEvents.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'rating':
        filteredEvents.sort((a, b) => (_eventRatings[b.id] ?? 0).compareTo(_eventRatings[a.id] ?? 0));
        break;
    }

    return filteredEvents;
  }

  List<Event> _getTodayEvents() {
    // 🆕 ИСПОЛЬЗУЕМ ДАННЫЕ ИЗ ОТДЕЛЬНОГО ФАЙЛА
    return TodayEvents.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();
    final todayEvents = _getTodayEvents();
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColor,
                  _backgroundColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: isMobile
                  ? _buildMobileLayout(horizontalPadding, filteredEvents, todayEvents)
                  : _buildDesktopLayout(_buildDesktopContent(horizontalPadding, filteredEvents, todayEvents)),
            ),
          ),

          // Кнопка "Добавить событие"
          Positioned(
            bottom: isMobile ? 16 : 24,
            right: isMobile ? 16 : horizontalPadding + 16,
            child: _buildPermanentAddButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(double horizontalPadding, List<Event> filteredEvents, List<Event> todayEvents) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, true),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildMobileContent(horizontalPadding, filteredEvents, todayEvents),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent(double horizontalPadding, List<Event> filteredEvents, List<Event> todayEvents) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, false),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildDesktopContentBody(horizontalPadding, filteredEvents, todayEvents),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContentBody(double horizontalPadding, List<Event> filteredEvents, List<Event> todayEvents) {
    return _buildDesktopLayout(
      _isLoading && events.isEmpty
          ? _buildLoadingState()
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          constraints: BoxConstraints(maxWidth: _maxContentWidth),
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Секция главных событий
              SliverToBoxAdapter(
                child: FeaturedSection(
                  featuredEvents: _featuredEvents,
                  onEventTap: _openEventDetails,
                  fadeAnimation: _fadeAnimation,
                ),
              ),

              // Секция категорий
              SliverToBoxAdapter(
                child: CategoriesSection(
                  categories: _categories,
                  currentTabIndex: _currentTabIndex,
                  onTabChanged: (index) => setState(() => _currentTabIndex = index),
                  fadeAnimation: _fadeAnimation,
                ),
              ),

              // Статистика
              SliverToBoxAdapter(
                child: QuickStatsSection(
                  totalEventsCreated: _totalEventsCreated,
                  eventsThisMonth: _eventsThisMonth,
                  totalFavorites: _totalFavorites,
                ),
              ),

              // Сегодняшние события
              SliverToBoxAdapter(
                child: TodaySection(
                  todayEvents: todayEvents,
                  onEventTap: _openEventDetails,
                ),
              ),

              // Заголовок событий
              EventsTitleSection(eventsCount: filteredEvents.length),

              // Предстоящие события
              UpcomingSection(
                events: filteredEvents,
                favoriteEvents: _favoriteEvents,
                attendingEvents: _attendingEvents,
                eventViews: _eventViews,
                onEventTap: _openEventDetails,
                onFavorite: _toggleFavorite,
                onAttend: _toggleAttending,
                onCreateEvent: _openAddEventDialog,
              ),

              // Индикатор загрузки
              if (_isLoading && _hasMore)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              // Отступ снизу для кнопки
              SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(double horizontalPadding, List<Event> filteredEvents, List<Event> todayEvents) {
    return _isLoading && events.isEmpty
        ? _buildLoadingState()
        : RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        constraints: BoxConstraints(maxWidth: _maxContentWidth),
        margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Секция главных событий
            SliverToBoxAdapter(
              child: FeaturedSection(
                featuredEvents: _featuredEvents,
                onEventTap: _openEventDetails,
                fadeAnimation: _fadeAnimation,
              ),
            ),

            // Секция категорий
            SliverToBoxAdapter(
              child: CategoriesSection(
                categories: _categories,
                currentTabIndex: _currentTabIndex,
                onTabChanged: (index) => setState(() => _currentTabIndex = index),
                fadeAnimation: _fadeAnimation,
              ),
            ),

            // Статистика
            SliverToBoxAdapter(
              child: QuickStatsSection(
                totalEventsCreated: _totalEventsCreated,
                eventsThisMonth: _eventsThisMonth,
                totalFavorites: _totalFavorites,
              ),
            ),

            // Сегодняшние события
            SliverToBoxAdapter(
              child: TodaySection(
                todayEvents: todayEvents,
                onEventTap: _openEventDetails,
              ),
            ),

            // Заголовок событий
            EventsTitleSection(eventsCount: filteredEvents.length),

            // Предстоящие события
            UpcomingSection(
              events: filteredEvents,
              favoriteEvents: _favoriteEvents,
              attendingEvents: _attendingEvents,
              eventViews: _eventViews,
              onEventTap: _openEventDetails,
              onFavorite: _toggleFavorite,
              onAttend: _toggleAttending,
              onCreateEvent: _openAddEventDialog,
            ),

            // Индикатор загрузки
            if (_isLoading && _hasMore)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // Отступ снизу для кнопки
            SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  // КОМПАКТНЫЙ APP BAR В СТИЛЕ ПЕРВОГО ФАЙЛА
  Widget _buildCompactAppBar(double horizontalPadding, bool isMobile) {
    // Вычисляем отступ для выравнивания с категориями
    final categoriesCardMargin = isMobile ? 12.0 : horizontalPadding;
    final categoriesContentPadding = isMobile ? 12.0 : 16.0;
    final categoriesTitlePadding = 4.0;

    // Общий отступ от левого края до текста "Категории"
    final totalCategoriesLeftPadding = categoriesCardMargin +
        categoriesContentPadding + categoriesTitlePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _showSearchBar
          ? _buildSearchAppBar(isMobile, horizontalPadding, totalCategoriesLeftPadding)
          : _buildMainAppBar(isMobile, horizontalPadding, totalCategoriesLeftPadding),
    );
  }

  Widget _buildMainAppBar(bool isMobile, double horizontalPadding, double totalCategoriesLeftPadding) {
    return Row(
      children: [
        // Заголовок "Афиша" с фоном и выравниванием по категориям
        Padding(
          padding: EdgeInsets.only(left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Афиша',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Правый контент выровненный по правому краю категорий
        Container(
          margin: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
          child: Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () => setState(() => _showSearchBar = true),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getActiveFiltersCount() > 0
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getActiveFiltersCount() > 0 ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: _showAdvancedFilters,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sort_rounded, color: Colors.white, size: 18),
                ),
                onPressed: _showSortBottomSheet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAppBar(bool isMobile, double horizontalPadding, double totalCategoriesLeftPadding) {
    return Row(
      children: [
        // Поле поиска с выравниванием
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding),
              right: 8,
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Поиск событий...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: _primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                    onPressed: () => _searchController.clear(),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
        ),
        // Кнопка закрытия с выравниванием
        Padding(
          padding: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
            onPressed: () => setState(() {
              _showSearchBar = false;
              _searchController.clear();
              _searchQuery = '';
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPermanentAddButton() {
    return FloatingActionButton(
      onPressed: _openAddEventDialog,
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add, size: 28),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Загружаем события...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    _refreshController.forward();
    await Future.delayed(const Duration(seconds: 2));
    _refreshController.reset();
    setState(() {
      _currentPage = 0;
      _hasMore = true;
    });
    _loadInitialData();
  }

  void _toggleFavorite(String eventId) {
    setState(() {
      if (_favoriteEvents.contains(eventId)) {
        _favoriteEvents.remove(eventId);
        _totalFavorites--;
      } else {
        _favoriteEvents.add(eventId);
        _totalFavorites++;
      }
    });
  }

  void _toggleAttending(String eventId) {
    setState(() {
      if (_attendingEvents.contains(eventId)) {
        _attendingEvents.remove(eventId);
      } else {
        _attendingEvents.add(eventId);
      }
    });
  }

  void _openEventDetails(Event event) {
    _eventViews[event.id] = (_eventViews[event.id] ?? 0) + 1;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          event: event,
          onEdit: (updatedEvent) {
            final index = events.indexOf(event);
            if (index != -1) _editEvent(updatedEvent, index);
          },
          onDelete: () {
            final index = events.indexOf(event);
            if (index != -1) _deleteEvent(index);
          },
          onFavorite: () => _toggleFavorite(event.id),
          onAttend: () => _toggleAttending(event.id),
          onShare: () => _shareEvent(event),
          onRate: (rating) => _rateEvent(event.id, rating),
          isFavorite: _favoriteEvents.contains(event.id),
          isAttending: _attendingEvents.contains(event.id),
          currentRating: _eventRatings[event.id] ?? event.rating,
          viewCount: _eventViews[event.id] ?? 0,
        ),
      ),
    );
  }

  void _shareEvent(Event event) {
    Share.share(
      '🎉 ${event.title}\n\n${event.description}\n\n📅 ${EventUtils.formatEventDate(event.date)}\n📍 ${event.location}\n💰 ${event.price == 0 ? 'Бесплатно' : '${event.price} ₽'}\n\nПрисоединяйтесь!',
      subject: event.title,
    );
  }

  void _rateEvent(String eventId, double rating) {
    setState(() {
      _eventRatings[eventId] = rating;
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
      _totalEventsCreated--;
    });
  }

  void _openAddEventDialog() {
    final selectedCategory = _categories[_currentTabIndex];
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onAdd: _addEvent,
        initialCategory: selectedCategory.id == 'all' ? null : selectedCategory.title,
      ),
    );
  }

  void _addEvent(Event newEvent) {
    setState(() {
      events.add(newEvent);
      events.sort((a, b) => a.date.compareTo(b.date));
      _totalEventsCreated++;
      if (newEvent.date.month == DateTime.now().month) {
        _eventsThisMonth++;
      }
    });
  }

  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Календарь событий'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (date) {
              setState(() => _selectedDate = date);
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Фильтры будут реализованы позже'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Сортировка',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
            ),
            const SizedBox(height: 16),
            ...['date', 'popularity', 'price_low', 'price_high', 'rating'].map((sortOption) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.sort, size: 20, color: _primaryColor),
              ),
              title: Text(
                _getSortOptionTitle(sortOption),
                style: TextStyle(fontSize: 15, color: _textColor, fontWeight: FontWeight.w500),
              ),
              trailing: _sortBy == sortOption
                  ? Icon(Icons.check, color: _primaryColor, size: 20)
                  : null,
              onTap: () {
                setState(() => _sortBy = sortOption);
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  String _getSortOptionTitle(String sortOption) {
    switch (sortOption) {
      case 'date': return 'По дате';
      case 'popularity': return 'По популярности';
      case 'price_low': return 'По цене (сначала дешевые)';
      case 'price_high': return 'По цене (сначала дорогие)';
      case 'rating': return 'По рейтингу';
      default: return 'По дате';
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Календарь'),
              onTap: () {
                Navigator.pop(context);
                _showCalendar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Фильтры'),
              onTap: () {
                Navigator.pop(context);
                _showAdvancedFilters();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                _showSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Помощь'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Настройки приложения'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Помощь'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Как пользоваться приложением:'),
            SizedBox(height: 8),
            Text('- Используйте поиск для быстрого поиска событий'),
            Text('- Применяйте фильтры для уточнения результатов'),
            Text('- Добавляйте события в избранное'),
            Text('- Создавайте свои события'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}