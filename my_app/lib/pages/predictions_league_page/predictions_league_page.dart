import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/predictions_league_page/prediction_league_card.dart';
import 'package:provider/provider.dart';

import 'league_detail_page.dart';
import 'models/enums.dart';
import 'models/prediction_league.dart';

class PredictionsLeaguePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const PredictionsLeaguePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<PredictionsLeaguePage> createState() => _PredictionsLeaguePageState();
}

class LeagueCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  LeagueCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });
}

class SortOption {
  final String label;
  final String title;
  final IconData icon;
  final int Function(Map<String, dynamic>, Map<String, dynamic>) comparator;

  SortOption(this.label, this.title, this.icon, this.comparator);
}

class _PredictionsLeaguePageState extends State<PredictionsLeaguePage> {
  // Константы
  static const defaultImageUrl = 'assets/images/predictions_league_image/data.png';

  // НОВЫЙ ОСНОВНОЙ ЦВЕТ #9E2C21 (красный)
  final Color _primaryColor = const Color(0xFF9E2C21);
  final Color _secondaryColor = const Color(0xFFC4453A); // Более светлый красный
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF37474F);

  // Красные градиенты для карточек
  final List<Color> _cardGradients = [
    const Color(0xFFFCE4EC), // Светло-розовый
    const Color(0xFFFFEBEE), // Светло-красный
    const Color(0xFFFFF3E0), // Светло-оранжевый
    const Color(0xFFE8F5E8), // Светло-зеленый
    const Color(0xFFE3F2FD), // Светло-голубой
    const Color(0xFFF3E5F5), // Светло-фиолетовый
    const Color(0xFFEDE7F6), // Светло-лавандовый
    const Color(0xFFFFF8E1), // Светло-желтый
  ];

  final List<Color> _cardBorderColors = [
    const Color(0xFFF48FB1), // Розовый
    const Color(0xFFEF5350), // Красный
    const Color(0xFFFF7043), // Оранжевый
    const Color(0xFFA5D6A7), // Зеленый
    const Color(0xFF90CAF9), // Голубой
    const Color(0xFFCE93D8), // Фиолетовый
    const Color(0xFFB39DDB), // Лавандовый
    const Color(0xFFFFE082), // Желтый
  ];

  final List<LeagueCategory> _categories = [
    LeagueCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive,
      color: const Color(0xFF9E2C21), // Новый цвет
    ),
    LeagueCategory(
      id: 'sports',
      title: 'Спорт',
      description: 'Спортивные прогнозы',
      icon: Icons.sports_soccer,
      color: Colors.green,
    ),
    LeagueCategory(
      id: 'esports',
      title: 'Киберспорт',
      description: 'Прогнозы на киберспорт',
      icon: Icons.sports_esports,
      color: Colors.purple,
    ),
    LeagueCategory(
      id: 'politics',
      title: 'Города',
      description: 'Прогнозы для городов',
      icon: Icons.location_city,
      color: Colors.blue,
    ),
    LeagueCategory(
      id: 'entertainment',
      title: 'Развлечения',
      description: 'Прогнозы в индустрии развлечений',
      icon: Icons.movie,
      color: Colors.orange,
    ),
    LeagueCategory(
      id: 'finance',
      title: 'Финансы',
      description: 'Финансовые прогнозы',
      icon: Icons.trending_up,
      color: Colors.teal,
    ),
  ];

  final List<SortOption> _sortOptions = [
    SortOption('Сначала новые', 'Сначала новые', Icons.new_releases, (a, b) {
      final dateA = DateTime.parse(a['end_date'] ?? '');
      final dateB = DateTime.parse(b['end_date'] ?? '');
      return dateB.compareTo(dateA);
    }),
    SortOption('По популярности', 'По популярности', Icons.trending_up, (a, b) {
      final participantsA = (a['participants'] as int?) ?? 0;
      final participantsB = (b['participants'] as int?) ?? 0;
      return participantsB.compareTo(participantsA);
    }),
    SortOption('По призовому фонду', 'По призовому фонду', Icons.attach_money, (a, b) {
      final prizeA = (a['prize_pool'] as num?)?.toDouble() ?? 0.0;
      final prizeB = (b['prize_pool'] as num?)?.toDouble() ?? 0.0;
      return prizeB.compareTo(prizeA);
    }),
  ];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Set<String> _favoriteLeagueIds = <String>{};
  final Set<String> _selectedLeagues = <String>{};
  final List<String> _searchHistory = [];

  int _currentTabIndex = 0;
  int _currentSortIndex = 0;
  String _searchQuery = '';

  bool _isLoadingMore = false;
  bool _isOffline = false;
  bool _isSelectionMode = false;
  bool _showSearchBar = false;
  bool _showFilters = false;

  // ФИКСИРОВАННАЯ МАКСИМАЛЬНАЯ ШИРИНА ДЛЯ ДЕСКТОПА
  double get _maxContentWidth => 1200;
  double get _minContentWidth => 320;

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

  // ДЕМО ДАННЫЕ С ПРОГРЕССОМ И ЛОКАЛЬНЫМИ ИЗОБРАЖЕНИЯМИ
  final List<Map<String, dynamic>> _demoLeagues = [
    {
      'id': '1',
      'title': 'Чемпионат мира по футболу 2024',
      'description': 'Прогнозы на матчи чемпионата мира по футболу с участием лучших команд',
      'emoji': '⚽',
      'participants': 1250,
      'predictions': 8900,
      'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'category': 'sports',
      'author': 'Футбольная ассоциация',
      'image_url': 'assets/images/predictions_league_image/football.png',
      'is_active': true,
      'prize_pool': 50000.0,
      'progress': 0.7,
    },
    {
      'id': '2',
      'title': 'Dota 2 - The International',
      'description': 'Прогнозы на главный турнир по Dota 2 с многомиллионным призовым фондом',
      'emoji': '🎮',
      'participants': 890,
      'predictions': 4500,
      'end_date': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
      'category': 'esports',
      'author': 'Valve Corporation',
      'image_url': 'assets/images/predictions_league_image/dota.png',
      'is_active': true,
      'prize_pool': 25000.0,
      'progress': 0.4,
    },
    {
      'id': '3',
      'title': 'Выборы лучшего города мира',
      'description': 'Прогнозы на звание лучшего города для жизни и туризма в 2024 году',
      'emoji': '🏙️',
      'participants': 2100,
      'predictions': 12000,
      'end_date': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
      'category': 'politics',
      'author': 'Международная ассоциация городов',
      'image_url': 'assets/images/predictions_league_image/city_league.jpeg',
      'is_active': true,
      'prize_pool': 100000.0,
      'progress': 0.3,
    },
    {
      'id': '4',
      'title': 'Прогноз упадет ли курс доллара?',
      'description': 'Лига крутых прогнозистов?',
      'emoji': '💰',
      'participants': 3400,
      'predictions': 15000,
      'end_date': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      'category': 'finance',
      'author': 'Маринцев',
      'image_url': 'assets/images/predictions_league_image/bitcoin_exchange_rate.png',
      'is_active': true,
      'prize_pool': 75000.0,
      'progress': 0.25,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
    _loadCachedLeagues();
    _setupListeners();
  }

  void _setupListeners() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkConnectivity() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isOffline = false;
    });
  }

  void _loadCachedLeagues() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreLeagues();
    }
  }

  Future<void> _loadMoreLeagues() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoadingMore = false;
    });
  }

  DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    try {
      if (dateData is String) return DateTime.parse(dateData);
      if (dateData is DateTime) return dateData;
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  void _openLeagueDetail(Map<String, dynamic> leagueData) {
    final league = PredictionLeague(
      id: leagueData['id'] ?? '',
      title: leagueData['title'] ?? '',
      description: leagueData['description'] ?? '',
      emoji: leagueData['emoji'] ?? '🏆',
      participants: (leagueData['participants'] as int?) ?? 0,
      predictions: (leagueData['predictions'] as int?) ?? 0,
      endDate: _parseDate(leagueData['end_date']),
      category: _categories.firstWhere(
            (cat) => cat.id == leagueData['category'],
        orElse: () => _categories.first,
      ).title,
      author: leagueData['author'] ?? '',
      imageUrl: leagueData['image_url'] ?? defaultImageUrl,
      authorLevel: AuthorLevel.expert,
      isActive: leagueData['is_active'] == true,
      prizePool: (leagueData['prize_pool'] as num?)?.toDouble() ?? 0.0,
      progress: (leagueData['progress'] as double?) ?? 0.5,
      views: (leagueData['participants'] as int? ?? 0) * 3,
      detailedDescription: 'Лига прогнозов предлагает участникам сделать предсказания на исход различных событий. Участвуйте в обсуждениях, следите за статистикой и выигрывайте призы!',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeagueDetailPage(league: league),
      ),
    );
  }

  void _navigateToCreateLeague() {
    _showSnackBar('Создание новой лиги прогнозов');
  }

  void _toggleFavorite(String leagueId) {
    setState(() {
      if (_favoriteLeagueIds.contains(leagueId)) {
        _favoriteLeagueIds.remove(leagueId);
      } else {
        _favoriteLeagueIds.add(leagueId);
      }
    });
  }

  bool _isLeagueFavorite(String leagueId) => _favoriteLeagueIds.contains(leagueId);

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedLeagues.clear();
    });
  }

  void _toggleLeagueSelection(String leagueId) {
    setState(() {
      if (_selectedLeagues.contains(leagueId)) {
        _selectedLeagues.remove(leagueId);
      } else {
        _selectedLeagues.add(leagueId);
      }
    });
  }

  void _deleteSelectedLeagues() {
    if (_selectedLeagues.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить лиги?'),
        content: Text('Вы уверены, что хотите удалить ${_selectedLeagues.length} лиг?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              _toggleSelectionMode();
              Navigator.pop(context);
              _showSnackBar('Удалено ${_selectedLeagues.length} лиг');
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareSelectedLeagues() {
    if (_selectedLeagues.isEmpty) return;
    _showSnackBar('Поделиться ${_selectedLeagues.length} лигами');
  }

  void _addToSearchHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5) _searchHistory.removeLast();
      });
    }
  }

  void _showFavorites() {
    setState(() {
      _currentTabIndex = 0;
      _searchQuery = "избранное";
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ВИДЖЕТЫ ФИЛЬТРОВ И КАТЕГОРИЙ В СТИЛЕ ПЕРВОГО ФАЙЛА
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _surfaceColor,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _buildFilterChip('active', 'Только активные', Icons.event_available),
                    _buildFilterChip('favorites', 'Избранное', Icons.favorite),
                    _buildFilterChip('high_prize', 'Высокий приз', Icons.attach_money),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String id, String title, IconData icon) {
    final isActive = id == 'favorites' && _searchQuery == "избранное";
    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.only(right: isMobile ? 8 : 12),
      child: Material(
        color: isActive ? _primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        child: InkWell(
          onTap: () {
            if (id == 'favorites') {
              _showFavorites();
            }
          },
          borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 8 : 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
              border: Border.all(
                color: isActive ? _primaryColor : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isMobile ? 16 : 18,
                  color: isActive ? Colors.white : _primaryColor,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(double horizontalPadding) {
    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _surfaceColor,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Категории',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // АДАПТИВНЫЙ СПИСОК КАТЕГОРИЙ
              if (isMobile)
                _buildMobileCategories()
              else
                _buildDesktopCategories(),
            ],
          ),
        ),
      ),
    );
  }

  // ГОРИЗОНТАЛЬНЫЙ СКРОЛЛ КАТЕГОРИЙ ДЛЯ ТЕЛЕФОНА
  Widget _buildMobileCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildMobileCategoryChip(category);
        },
      ),
    );
  }

  // КАТЕГОРИИ ДЛЯ ДЕСКТОПА
  Widget _buildDesktopCategories() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) => _buildDesktopCategoryChip(category)).toList(),
    );
  }

  Widget _buildMobileCategoryChip(LeagueCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return Container(
      margin: const EdgeInsets.only(right: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 14,
                  color: isSelected ? Colors.white : category.color,
                ),
                const SizedBox(width: 4),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCategoryChip(LeagueCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return Material(
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
              color: isSelected ? category.color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 16,
                color: isSelected ? Colors.white : category.color,
              ),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет поля поиска
  Widget _buildSearchField() {
    return Container(
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
          hintText: 'Поиск лиг прогнозов...',
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
      child: Row(
        children: [
          if (!_showSearchBar) ...[
            // Заголовок "Лиги Прогнозов" с фоном и выравниванием по категориям
            Padding(
              padding: EdgeInsets.only(left: totalCategoriesLeftPadding -
                  (isMobile ? 12 : horizontalPadding)),
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
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Лиги Прогнозов',
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
              margin: EdgeInsets.only(right: totalCategoriesLeftPadding -
                  (isMobile ? 12 : horizontalPadding)),
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
                        color: _showFilters
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
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

          if (_showSearchBar)
            Expanded(
              child: Row(
                children: [
                  // Поле поиска с выравниванием
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding),
                        right: 8,
                      ),
                      child: _buildSearchField(),
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
              ),
            ),
        ],
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
            ..._sortOptions.map((option) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, size: 20, color: _primaryColor),
              ),
              title: Text(
                option.title,
                style: TextStyle(fontSize: 15, color: _textColor, fontWeight: FontWeight.w500),
              ),
              trailing: _sortOptions.indexOf(option) == _currentSortIndex
                  ? Icon(Icons.check, color: _primaryColor, size: 20)
                  : null,
              onTap: () {
                setState(() => _currentSortIndex = _sortOptions.indexOf(option));
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

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final isMobile = _isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        constraints: BoxConstraints(
          minWidth: _minContentWidth,
        ),
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
              ? _buildMobileLayout(horizontalPadding)
              : _buildDesktopLayout(_buildDesktopContent(horizontalPadding)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateLeague,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildMobileLayout(double horizontalPadding) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, true),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildMobileContent(horizontalPadding),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(double horizontalPadding) {
    final filteredLeagues = _getFilteredLeagues(_demoLeagues);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Фильтры
        SliverToBoxAdapter(child: _buildFiltersCard(horizontalPadding)),

        // Категории
        SliverToBoxAdapter(child: _buildCategoriesCard(horizontalPadding)),

        // Разделитель
        SliverToBoxAdapter(
          child: Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            color: Colors.grey.shade100,
          ),
        ),

        // Карточки лиг
        _buildLeaguesGrid(horizontalPadding, filteredLeagues, true),
      ],
    );
  }

  Widget _buildDesktopContent(double horizontalPadding) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, false),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildDesktopContentBody(horizontalPadding),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContentBody(double horizontalPadding) {
    final filteredLeagues = _getFilteredLeagues(_demoLeagues);

    return _buildDesktopLayout(
      CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Фильтры
          SliverToBoxAdapter(child: _buildFiltersCard(horizontalPadding)),

          // Категории
          SliverToBoxAdapter(child: _buildCategoriesCard(horizontalPadding)),

          // Разделитель
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              color: Colors.grey.shade100,
            ),
          ),

          // Карточки лиг
          _buildLeaguesGrid(horizontalPadding, filteredLeagues, false),
        ],
      ),
    );
  }

  Widget _buildLeaguesGrid(double horizontalPadding, List<Map<String, dynamic>> leagues, bool isMobile) {
    if (leagues.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.emoji_events_rounded, size: 48, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Лиги не найдены',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить параметры поиска\nили выбрать другую категорию',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ДЛЯ МОБИЛЬНЫХ - ИСПОЛЬЗУЕМ SliverList
    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == leagues.length && _isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            }
            if (index >= leagues.length) return const SizedBox.shrink();

            final leagueData = leagues[index];
            final league = PredictionLeague(
              id: leagueData['id'] ?? '',
              title: leagueData['title'] ?? '',
              description: leagueData['description'] ?? '',
              emoji: leagueData['emoji'] ?? '🏆',
              participants: (leagueData['participants'] as int?) ?? 0,
              predictions: (leagueData['predictions'] as int?) ?? 0,
              endDate: _parseDate(leagueData['end_date']),
              category: _categories.firstWhere(
                    (cat) => cat.id == leagueData['category'],
                orElse: () => _categories.first,
              ).title,
              author: leagueData['author'] ?? '',
              imageUrl: leagueData['image_url'] ?? defaultImageUrl,
              authorLevel: AuthorLevel.expert,
              isActive: leagueData['is_active'] == true,
              prizePool: (leagueData['prize_pool'] as num?)?.toDouble() ?? 0.0,
              progress: (leagueData['progress'] as double?) ?? 0.5,
              views: (leagueData['participants'] as int? ?? 0) * 3,
              detailedDescription: 'Лига прогнозов предлагает участникам сделать предсказания на исход различных событий.',
            );

            return Stack(
              children: [
                PredictionLeagueCard(
                  key: ValueKey(league.id),
                  league: league,
                  onTap: () => _openLeagueDetail(leagueData),
                  isMobile: true,
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Checkbox(
                      value: _selectedLeagues.contains(league.id),
                      onChanged: (_) => _toggleLeagueSelection(league.id),
                    ),
                  ),
                if (_isLeagueFavorite(league.id))
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.favorite, size: 16, color: Colors.red),
                  ),
              ],
            );
          },
          childCount: leagues.length + (_isLoadingMore ? 1 : 0),
        ),
      );
    }

    // ДЛЯ ПЛАНШЕТОВ И КОМПЬЮТЕРОВ - ИСПОЛЬЗУЕМ SliverGrid
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 360 / 460, // ФИКСИРОВАННОЕ СООТНОШЕНИЕ
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == leagues.length && _isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            }
            if (index >= leagues.length) return const SizedBox.shrink();

            final leagueData = leagues[index];
            final league = PredictionLeague(
              id: leagueData['id'] ?? '',
              title: leagueData['title'] ?? '',
              description: leagueData['description'] ?? '',
              emoji: leagueData['emoji'] ?? '🏆',
              participants: (leagueData['participants'] as int?) ?? 0,
              predictions: (leagueData['predictions'] as int?) ?? 0,
              endDate: _parseDate(leagueData['end_date']),
              category: _categories.firstWhere(
                    (cat) => cat.id == leagueData['category'],
                orElse: () => _categories.first,
              ).title,
              author: leagueData['author'] ?? '',
              imageUrl: leagueData['image_url'] ?? defaultImageUrl,
              authorLevel: AuthorLevel.expert,
              isActive: leagueData['is_active'] == true,
              prizePool: (leagueData['prize_pool'] as num?)?.toDouble() ?? 0.0,
              progress: (leagueData['progress'] as double?) ?? 0.5,
              views: (leagueData['participants'] as int? ?? 0) * 3,
              detailedDescription: 'Лига прогнозов предлагает участникам сделать предсказания на исход различных событий.',
            );

            return Padding(
              padding: const EdgeInsets.all(2),
              child: Stack(
                children: [
                  PredictionLeagueCard(
                    key: ValueKey(league.id),
                    league: league,
                    onTap: () => _openLeagueDetail(leagueData),
                    isMobile: false,

                  ),
                  if (_isSelectionMode)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Checkbox(
                        value: _selectedLeagues.contains(league.id),
                        onChanged: (_) => _toggleLeagueSelection(league.id),
                      ),
                    ),
                  if (_isLeagueFavorite(league.id))
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.favorite, size: 16, color: Colors.red),
                    ),
                ],
              ),
            );
          },
          childCount: leagues.length + (_isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredLeagues(List<Map<String, dynamic>> allLeagues) {
    final selectedCategory = _categories[_currentTabIndex];
    var filtered = allLeagues.where((league) {
      final matchesSearch = _searchQuery.isEmpty ||
          (league['title']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (league['description']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = selectedCategory.id == 'all' ||
          (league['category']?.toString() ?? '').toLowerCase() == selectedCategory.id.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    filtered.sort(_sortOptions[_currentSortIndex].comparator);
    return filtered;
  }
}