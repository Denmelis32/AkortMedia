import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'event_details_screen.dart';
import 'event_model.dart' hide EventCategory;
import 'add_event_dialog.dart';
import 'event_categories.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with TickerProviderStateMixin {
  List<Event> events = [];
  int _currentTabIndex = 0;
  String _searchQuery = '';
  bool _showSearchBar = false;
  bool _showFilters = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _fabAnimationController;

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
  late Animation<double> _refreshAnimation;

  // Пример популярных событий
  late final List<Event> _featuredEvents;

  final List<EventCategory> _categories = [
    EventCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive_rounded,
      color: Colors.blue,
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
      color: Colors.blue,
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
  final List<String> _sortOptions = ['date', 'popularity', 'price_low', 'price_high', 'rating'];

  @override
  void initState() {
    super.initState();

    // Инициализация featuredEvents с правильными параметрами
    _featuredEvents = [
      Event(
        id: '1',
        title: 'Концерт популярной группы',
        description: 'Лучшие хиты этого сезона в живом исполнении. Не пропустите уникальное шоу с световыми эффектами и профессиональным звуком!',
        date: DateTime.now().add(const Duration(days: 2, hours: 19)),
        endDate: DateTime.now().add(const Duration(days: 2, hours: 22)),
        color: Colors.purple,
        category: 'Концерты',
        location: 'Главный концертный зал',
        address: 'ул. Примерная, 123',
        price: 1500,
        organizer: 'Концертное агентство "Музыка"',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        tags: ['музыка', 'живое исполнение', 'развлечения', 'вечер'],
        maxAttendees: 500,
        currentAttendees: 347,
        rating: 4.8,
        reviewCount: 124,
        isOnline: false,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Event(
        id: '2',
        title: 'Выставка современного искусства',
        description: 'Работы молодых художников и скульпторов. Инновации в искусстве и цифровые инсталляции.',
        date: DateTime.now().add(const Duration(days: 5, hours: 11)),
        endDate: DateTime.now().add(const Duration(days: 5, hours: 20)),
        color: Colors.blue,
        category: 'Выставки',
        location: 'Городской музей',
        address: 'пр. Культуры, 45',
        price: 500,
        organizer: 'Музей искусств',
        imageUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=400',
        tags: ['искусство', 'культура', 'выставка', 'современное'],
        maxAttendees: 200,
        currentAttendees: 89,
        rating: 4.6,
        reviewCount: 89,
        isOnline: false,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Event(
        id: '3',
        title: 'Фестиваль еды',
        description: 'Гастрономический праздник с шеф-поварами со всего мира. Дегустации, мастер-классы и конкурсы.',
        date: DateTime.now().add(const Duration(days: 7, hours: 12)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 23)),
        color: Colors.orange,
        category: 'Фестивали',
        location: 'Центральный парк',
        address: 'Центральный парк культуры',
        price: 800,
        organizer: 'Гастрономическая ассоциация',
        imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
        tags: ['еда', 'фестиваль', 'гастрономия', 'кулинария'],
        maxAttendees: 1000,
        currentAttendees: 623,
        rating: 4.9,
        reviewCount: 256,
        isOnline: false,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    // Основная анимация
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Анимация FAB
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Анимация обновления
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _scrollController.addListener(_onScroll);
    _loadInitialData();

    // Инициализация рейтингов
    _initializeEventData();
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
    _fabAnimationController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    // Симуляция загрузки дополнительных событий
    final additionalEvents = [
      Event(
        id: '4',
        title: 'Мастер-класс по программированию',
        description: 'Изучите основы Flutter и Dart с опытными разработчиками',
        date: DateTime.now().add(const Duration(days: 4, hours: 14)),
        endDate: DateTime.now().add(const Duration(days: 4, hours: 18)),
        color: Colors.indigo,
        category: 'Образование',
        location: 'IT Академия',
        address: 'ул. Технологическая, 67',
        price: 2000,
        organizer: 'IT Сообщество',
        tags: ['программирование', 'обучение', 'технологии'],
        maxAttendees: 50,
        currentAttendees: 35,
        rating: 4.7,
        reviewCount: 42,
        isOnline: true,
        onlineLink: 'https://meet.google.com/abc-def-ghi',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Event(
        id: '5',
        title: 'Бесплатный йога-урок в парке',
        description: 'Утренняя йога для всех желающих на свежем воздухе',
        date: DateTime.now().add(const Duration(days: 1, hours: 8)),
        endDate: DateTime.now().add(const Duration(days: 1, hours: 9)),
        color: Colors.green,
        category: 'Спорт',
        location: 'Городской парк',
        address: 'Центральный парк',
        price: 0,
        organizer: 'Йога-студия "Гармония"',
        tags: ['йога', 'здоровье', 'бесплатно', 'утро'],
        maxAttendees: 100,
        currentAttendees: 78,
        rating: 4.5,
        reviewCount: 67,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    setState(() {
      events.addAll(additionalEvents);
      _isLoading = false;
      _totalEventsCreated = events.length;
      _eventsThisMonth = events.where((e) => e.date.month == DateTime.now().month).length;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEvents();
    }
  }

  void _loadMoreEvents() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    // Симуляция загрузки дополнительных событий
    final newEvents = List.generate(5, (index) => Event(
      id: 'more-${_currentPage * 5 + index}',
      title: 'Событие ${_currentPage * 5 + index + 1}',
      description: 'Описание дополнительного события',
      date: now.add(Duration(days: 15 + index)),
      endDate: now.add(Duration(days: 15 + index, hours: 3)),
      color: [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red][index],
      category: _categories[(index % _categories.length)].title,
      location: _cities[index % _cities.length],
      price: (index + 1) * 500.0,
      organizer: 'Организатор ${index + 1}',
      tags: [_popularTags[index % _popularTags.length]],
      maxAttendees: 100,
      currentAttendees: 50 + index * 10,
      rating: 4.0 + (index * 0.1),
      reviewCount: 20 + index * 5,
      isOnline: index % 3 == 0,
      createdAt: now.subtract(Duration(days: 10 + index)),
      updatedAt: now.subtract(Duration(days: 5 + index)),
    ));

    setState(() {
      events.addAll(newEvents);
      _currentPage++;
      _isLoading = false;
      _hasMore = _currentPage < 3; // Ограничим для демонстрации
    });
  }

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ ВСЕХ ЭКРАНОВ
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return ScreenSize.small;
    if (width < 420) return ScreenSize.medium;
    if (width < 600) return ScreenSize.large;
    if (width < 900) return ScreenSize.tablet;
    if (width < 1200) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  double _getHorizontalPadding(BuildContext context) {
    final screenSize = _getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small: return 12;
      case ScreenSize.medium: return 16;
      case ScreenSize.large: return 20;
      case ScreenSize.tablet: return 40;
      case ScreenSize.desktop: return 100;
      case ScreenSize.largeDesktop: return 200;
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenSize = _getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
      case ScreenSize.medium:
      case ScreenSize.large: return 1;
      case ScreenSize.tablet: return 2;
      case ScreenSize.desktop: return 3;
      case ScreenSize.largeDesktop: return 4;
    }
  }

  double _getFeaturedCardHeight(BuildContext context) {
    final screenSize = _getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small: return 180;
      case ScreenSize.medium: return 200;
      case ScreenSize.large: return 220;
      case ScreenSize.tablet: return 240;
      case ScreenSize.desktop: return 260;
      case ScreenSize.largeDesktop: return 280;
    }
  }

  double _getFeaturedCardWidth(BuildContext context) {
    final screenSize = _getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small: return 260;
      case ScreenSize.medium: return 280;
      case ScreenSize.large: return 300;
      case ScreenSize.tablet: return 320;
      case ScreenSize.desktop: return 340;
      case ScreenSize.largeDesktop: return 360;
    }
  }

  // НОВЫЙ ФУНКЦИОНАЛ
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

    // Анимация для FAB
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
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

  void _shareEvent(Event event) {
    Share.share(
      '🎉 ${event.title}\n\n${event.description}\n\n📅 ${_formatEventDate(event.date)}\n📍 ${event.location}\n💰 ${event.price == 0 ? 'Бесплатно' : '${event.price} ₽'}\n\nПрисоединяйтесь!',
      subject: event.title,
    );
  }

  void _rateEvent(String eventId, double rating) {
    setState(() {
      _eventRatings[eventId] = rating;
    });
  }

  void _quickAddEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickAddSheet(),
    );
  }

  Widget _buildQuickAddSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 20),
              const Text(
                'Быстрое добавление',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildQuickAction(
                    icon: Icons.event,
                    title: 'Встреча',
                    color: Colors.blue,
                    onTap: () => _addQuickEvent('Встреча'),
                  ),
                  _buildQuickAction(
                    icon: Icons.cake,
                    title: 'День рождения',
                    color: Colors.pink,
                    onTap: () => _addQuickEvent('День рождения'),
                  ),
                  _buildQuickAction(
                    icon: Icons.work,
                    title: 'Рабочее',
                    color: Colors.green,
                    onTap: () => _addQuickEvent('Рабочее'),
                  ),
                  _buildQuickAction(
                    icon: Icons.sports_soccer,
                    title: 'Спорт',
                    color: Colors.orange,
                    onTap: () => _addQuickEvent('Спорт'),
                  ),
                  _buildQuickAction(
                    icon: Icons.movie,
                    title: 'Кино',
                    color: Colors.purple,
                    onTap: () => _addQuickEvent('Кино'),
                  ),
                  _buildQuickAction(
                    icon: Icons.restaurant,
                    title: 'Ужин',
                    color: Colors.red,
                    onTap: () => _addQuickEvent('Ужин'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildQuickEventForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEventForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Или создайте свое событие',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Название события',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Дата',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Время',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Создать событие'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _addQuickEvent(String type) {
    final now = DateTime.now();
    final event = Event(
      id: 'quick-${now.millisecondsSinceEpoch}',
      title: '$type - ${DateFormat('dd.MM.yyyy').format(now)}',
      description: 'Автоматически созданное событие',
      date: now.add(const Duration(hours: 2)),
      endDate: now.add(const Duration(hours: 4)),
      color: _getColorForType(type),
      category: type,
      location: _selectedCity,
      organizer: 'Я',
      tags: [type.toLowerCase()],
      maxAttendees: 10,
      currentAttendees: 1,
      rating: 0,
      reviewCount: 0,
      isOnline: false,
      createdAt: now,
      updatedAt: now,
    );
    _addEvent(event);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Событие "$type" добавлено!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            setState(() => events.remove(event));
          },
        ),
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Фильтры и сортировка',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Сортировка
                _buildSortFilter(),
                const SizedBox(height: 24),

                // Фильтры по дате
                _buildDateFilter(),
                const SizedBox(height: 24),

                // Фильтр по цене
                _buildPriceFilter(),
                const SizedBox(height: 24),

                // Фильтр по городу
                _buildCityFilter(),
                const SizedBox(height: 24),

                // Дополнительные фильтры
                _buildAdditionalFilters(),
                const SizedBox(height: 24),

                // Фильтр по тегам
                _buildTagsFilter(),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _priceRange = 5000;
                        _selectedCity = 'Москва';
                        _selectedTags.clear();
                        _sortBy = 'date';
                        _showFreeOnly = false;
                        _showOnlineOnly = false;
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Сбросить все'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Применить фильтры'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Сортировка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSortChip('По дате', 'date'),
            _buildSortChip('По популярности', 'popularity'),
            _buildSortChip('Сначала дешевые', 'price_low'),
            _buildSortChip('Сначала дорогие', 'price_high'),
            _buildSortChip('По рейтингу', 'rating'),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _sortBy = value),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Дата', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('Сегодня', _selectedDate?.day == DateTime.now().day),
            _buildFilterChip('Завтра', _selectedDate?.day == DateTime.now().add(const Duration(days: 1)).day),
            _buildFilterChip('На неделе', false),
            _buildFilterChip('В выходные', false),
            _buildFilterChip('Выбрать дату', false, onTap: _showDatePicker),
          ],
        ),
        if (_selectedDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Выбрана дата: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}',
            style: const TextStyle(color: Colors.blue, fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Максимальная цена', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(
              _priceRange == 0 ? 'Бесплатно' : '${_priceRange.toInt()} ₽',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _priceRange,
          min: 0,
          max: 10000,
          divisions: 20,
          onChanged: (value) => setState(() => _priceRange = value),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 ₽', style: TextStyle(color: Colors.grey)),
            Text('10 000 ₽', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildCityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Город', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _cities.map((city) => _buildFilterChip(city, _selectedCity == city)).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Дополнительно', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSwitchFilter(
                'Только бесплатные',
                _showFreeOnly,
                    (value) => setState(() => _showFreeOnly = value),
              ),
            ),
            Expanded(
              child: _buildSwitchFilter(
                'Только онлайн',
                _showOnlineOnly,
                    (value) => setState(() => _showOnlineOnly = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchFilter(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Теги и категории', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularTags.map((tag) => _buildFilterChip(tag, _selectedTags.contains(tag))).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, {VoidCallback? onTap}) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        if (onTap != null) {
          onTap();
        } else {
          setState(() {
            if (selected) {
              _selectedTags.remove(label);
            } else {
              _selectedTags.add(label);
            }
          });
        }
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(color: selected ? Colors.blue : Colors.black87),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _applyFilters() {
    // Применение фильтров
    setState(() {
      _currentPage = 0;
      _hasMore = true;
      events.clear();
      _loadInitialData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Фильтры применены'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Встреча': return Colors.blue;
      case 'День рождения': return Colors.pink;
      case 'Рабочее': return Colors.green;
      case 'Спорт': return Colors.orange;
      case 'Кино': return Colors.purple;
      case 'Ужин': return Colors.red;
      default: return Colors.grey;
    }
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

  // ИСПРАВЛЕННЫЙ APP BAR
  Widget _buildAppBar(double horizontalPadding) {
    final screenSize = _getScreenSize(context);
    final isSmall = screenSize == ScreenSize.small;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isSmall ? 8 : 12,
      ),
      child: _showSearchBar ? _buildSearchAppBar(isSmall) : _buildMainAppBar(isSmall, horizontalPadding),
    );
  }

  Widget _buildMainAppBar(bool isSmall, double horizontalPadding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Афиша',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSmall ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isSmall)
                    Text(
                      'Найдите свои идеальные события',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSmall) ...[
                  _buildAppBarAction(
                    icon: Icons.calendar_today,
                    tooltip: 'Календарь',
                    onTap: _showCalendar,
                    badge: _selectedDate != null ? '1' : null,
                  ),
                  _buildAppBarAction(
                    icon: Icons.filter_list,
                    tooltip: 'Фильтры',
                    onTap: _showAdvancedFilters,
                    badge: _getActiveFiltersCount() > 0 ? _getActiveFiltersCount().toString() : null,
                  ),
                ],
                _buildAppBarAction(
                  icon: Icons.search,
                  tooltip: 'Поиск',
                  onTap: () => setState(() => _showSearchBar = true),
                ),
                if (isSmall)
                  _buildAppBarAction(
                    icon: Icons.more_vert,
                    tooltip: 'Еще',
                    onTap: _showMoreOptions,
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarAction({required IconData icon, required String tooltip, required VoidCallback onTap, String? badge}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18),
          ),
          tooltip: tooltip,
          onPressed: onTap,
        ),
        if (badge != null)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badge,
                style: const TextStyle(
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

  Widget _buildSearchAppBar(bool isSmall) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: isSmall ? 40 : 44,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Поиск событий, мест, категорий...',
                      hintStyle: TextStyle(fontSize: isSmall ? 14 : 16, color: Colors.grey[600]),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: isSmall ? 14 : 16),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => setState(() {
            _showSearchBar = false;
            _searchController.clear();
            _searchQuery = '';
          }),
          child: Text(
            'Отмена',
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
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

  // ОСНОВНОЙ BUILD МЕТОД
  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100, // Уменьшена высота
              collapsedHeight: 70, // Уменьшена высота
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderBackground(),
                title: _buildAppBar(horizontalPadding),
                centerTitle: false,
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FAFD),
                Color(0xFFF0F4F8),
              ],
            ),
          ),
          child: _isLoading && events.isEmpty
              ? _buildLoadingState()
              : RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              slivers: [
                _buildFeaturedEventsSection(horizontalPadding),
                _buildCategoriesSection(horizontalPadding),
                _buildQuickStatsSection(horizontalPadding),
                _buildTodayEventsSection(horizontalPadding),
                _buildEventsTitleSection(horizontalPadding),
                _buildUpcomingEventsSection(horizontalPadding, filteredEvents),
                _buildLoadingMoreSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildMultiActionFab(),
    );
  }

  // НОВАЯ СЕКЦИЯ: ЗАГОЛОВОК "СОБЫТИЯ"
  Widget _buildEventsTitleSection(double horizontalPadding) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.event, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'События',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${_getFilteredEvents().length} найдено',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
      ),
    );
  }

  Widget _buildMultiActionFab() {
    return ScaleTransition(
      scale: _fabAnimationController,
      child: FloatingActionButton(
        onPressed: _openAddEventDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Badge(
          isLabelVisible: _totalFavorites > 0,
          label: Text(_totalFavorites.toString()),
          child: const Icon(Icons.add, size: 24),
        ),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
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

  // СЕКЦИЯ ГЛАВНЫХ СОБЫТИЙ
  Widget _buildFeaturedEventsSection(double horizontalPadding) {
    final screenSize = _getScreenSize(context);
    final isSmall = screenSize == ScreenSize.small;

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isSmall ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 0),
                child: Row(
                  children: [
                    Icon(Icons.star, size: isSmall ? 16 : 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Главные события',
                      style: TextStyle(
                        fontSize: isSmall ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Все',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: _getFeaturedCardHeight(context),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _featuredEvents.length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedEventCard(_featuredEvents[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedEventCard(Event event, int index) {
    final screenSize = _getScreenSize(context);
    final isSmall = screenSize == ScreenSize.small;
    final cardWidth = _getFeaturedCardWidth(context);
    final timeUntilEvent = event.date.difference(DateTime.now());

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: isSmall ? 8 : 12),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () => _openEventDetails(event),
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Фоновое изображение
              if (event.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    event.imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              event.color.withOpacity(0.7),
                              event.color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        event.color.withOpacity(0.7),
                        event.color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

              // Градиентный оверлей
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Контент
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Категория и рейтинг
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.color.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (event.category).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              event.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Заголовок
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

                    // Описание
                    Text(
                      event.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Информация в строку
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatEventDate(event.date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        if (event.price != null && event.price! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${event.price} ₽',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'БЕСПЛАТНО',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Бейдж "Скоро"
              if (timeUntilEvent.inDays <= 2)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timeUntilEvent.inDays == 0 ? 'СЕГОДНЯ!' : 'СКОРО!',
                      style: const TextStyle(
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
    );
  }

  // СЕКЦИЯ КАТЕГОРИЙ
  Widget _buildCategoriesSection(double horizontalPadding) {
    final screenSize = _getScreenSize(context);
    final isSmall = screenSize == ScreenSize.small;

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isSmall ? 8 : 12,
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.all(isSmall ? 12 : 16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: isSmall ? 16 : 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Категории',
                        style: TextStyle(
                          fontSize: isSmall ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: isSmall ? 32 : 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: _categories.map((category) => _buildCategoryChip(category)).toList(),
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

  Widget _buildCategoryChip(EventCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);
    final screenSize = _getScreenSize(context);
    final isSmall = screenSize == ScreenSize.small;

    return Container(
      margin: EdgeInsets.only(right: isSmall ? 6 : 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: isSmall ? 14 : 16, color: isSelected ? Colors.white : category.color),
            const SizedBox(width: 6),
            Text(category.title),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category.count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white : category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _currentTabIndex = _categories.indexOf(category);
          });
        },
        backgroundColor: Colors.white,
        selectedColor: category.color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: isSmall ? 12 : 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(color: isSelected ? category.color : Colors.grey[300]!),
        shape: StadiumBorder(side: BorderSide(color: isSelected ? category.color : Colors.grey[300]!)),
      ),
    );
  }

  // СЕКЦИЯ СТАТИСТИКИ
  Widget _buildQuickStatsSection(double horizontalPadding) {
    final screenSize = _getScreenSize(context);
    final isSmall = screenSize == ScreenSize.small;

    if (isSmall) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
        child: Row(
          children: [
            _buildStatCard(
              'Всего событий',
              _totalEventsCreated.toString(),
              Icons.event,
              Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              'В этом месяце',
              _eventsThisMonth.toString(),
              Icons.calendar_month,
              Colors.green,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              'В избранном',
              _totalFavorites.toString(),
              Icons.favorite,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // СЕКЦИЯ СЕГОДНЯШНИХ СОБЫТИЙ
  Widget _buildTodayEventsSection(double horizontalPadding) {
    final todayEvents = events.where((event) {
      final today = DateTime.now();
      return event.date.year == today.year &&
          event.date.month == today.month &&
          event.date.day == today.day;
    }).toList();

    if (todayEvents.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Сегодня',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Все сегодня', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...todayEvents.map((event) => _buildTodayEventItem(event)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayEventItem(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [event.color.withOpacity(0.7), event.color],
            ),
          ),
          child: Icon(_getCategoryIcon(event.category), color: Colors.white, size: 24),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(event.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (event.location != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _openEventDetails(event),
      ),
    );
  }

  // СЕКЦИЯ БЛИЖАЙШИХ СОБЫТИЙ
  Widget _buildUpcomingEventsSection(double horizontalPadding, List<Event> filteredEvents) {
    if (filteredEvents.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'События не найдены',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Попробуйте изменить параметры поиска\nили создать свое событие',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openAddEventDialog,
                child: const Text('Создать событие'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= filteredEvents.length) return const SizedBox.shrink();
            return _buildEventCard(filteredEvents[index], index);
          },
          childCount: filteredEvents.length,
        ),
      ),
    );
  }
  Widget _buildEventCard(Event event, int index) {
    final bool isToday = event.date.day == DateTime.now().day;
    final bool isPast = event.date.isBefore(DateTime.now());
    final timeUntilEvent = event.date.difference(DateTime.now());
    final isFavorite = _favoriteEvents.contains(event.id);
    final isAttending = _attendingEvents.contains(event.id);

    // Проверяем корректность данных события
    if (event.title.isEmpty || event.title.contains('Событие')) {
      return const SizedBox.shrink(); // Пропускаем тестовые события
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero, // Убираем внешние отступы
        child: InkWell(
          onTap: () => _openEventDetails(event),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: BoxConstraints(
              minHeight: 200, // Минимальная высота для консистентности
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Верхняя часть с изображением
                Stack(
                  children: [
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
                            event.color.withOpacity(0.8),
                            event.color,
                          ],
                        ),
                      ),
                      child: event.imageUrl != null
                          ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          event.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(); // Fallback to gradient
                          },
                        ),
                      )
                          : null,
                    ),

                    // Бейдж категории - ТОЛЬКО ОДИН
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getCategoryIcon(event.category),
                                size: 12, color: event.color),
                            const SizedBox(width: 4),
                            Text(
                              event.category.toUpperCase(),
                              style: TextStyle(
                                color: event.color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Бейдж статуса - ТОЛЬКО ОДИН
                    if (!isPast) // Только для будущих событий
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isToday ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isToday ? 'СЕГОДНЯ' : 'СКОРО',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Кнопка избранного
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(event.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Информация
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Описание
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Рейтинг и просмотры
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              event.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${event.reviewCount})',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600]
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.remove_red_eye,
                                size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Text(
                              '${_eventViews[event.id] ?? 0}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600]
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Дата и время
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatEventDate(event.date),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700]
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Местоположение - только если есть
                        if (event.location != null && event.location!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700]
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                        const Spacer(),

                        // Цена и кнопка участия
                        Row(
                          children: [
                            // Цена
                            if (event.price != null && event.price! > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${event.price?.toInt()} ₽',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'БЕСПЛАТНО',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            const Spacer(),

                            // Кнопка участия
                            GestureDetector(
                              onTap: () => _toggleAttending(event.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isAttending ?
                                  Colors.blue : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAttending ?
                                    Colors.blue : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  isAttending ? 'Участвую' : 'Участвовать',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isAttending ?
                                    Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildLoadingMoreSection() {
    if (!_isLoading || !_hasMore) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  void _openEventDetails(Event event) {
    // Увеличиваем счетчик просмотров
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

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return 'Сегодня, ${DateFormat('HH:mm').format(date)}';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      return 'Завтра, ${DateFormat('HH:mm').format(date)}';
    } else if (eventDay.isBefore(today.add(const Duration(days: 7)))) {
      return '${_getWeekday(date.weekday)}, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd MMM, HH:mm').format(date);
    }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Понедельник';
      case 2: return 'Вторник';
      case 3: return 'Среда';
      case 4: return 'Четверг';
      case 5: return 'Пятница';
      case 6: return 'Суббота';
      case 7: return 'Воскресенье';
      default: return '';
    }
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Концерты': Icons.music_note_rounded,
      'Выставки': Icons.palette_rounded,
      'Фестивали': Icons.celebration_rounded,
      'Спорт': Icons.sports_soccer_rounded,
      'Театр': Icons.theater_comedy_rounded,
      'Встречи': Icons.people_alt_rounded,
      'Образование': Icons.school_rounded,
      'Кино': Icons.movie_rounded,
      'Ужин': Icons.restaurant_rounded,
    };
    return icons[category] ?? Icons.event_rounded;
  }
}

enum ScreenSize {
  small,      // < 360px
  medium,     // 360-420px
  large,      // 420-600px
  tablet,     // 600-900px
  desktop,    // 900-1200px
  largeDesktop, // > 1200px
}