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

  final List<LeagueCategory> _categories = [
    LeagueCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive,
      color: Colors.blue,
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
      color: Colors.red,
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

  // АДАПТИВНЫЕ МЕТОДЫ КАК В ПЕРВОМ ФАЙЛЕ
  bool get _isMobile => MediaQuery.of(context).size.width <= 600;

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getCardAspectRatio(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1: return 0.75;
      case 2: return 0.8;
      case 3: return 0.85;
      default: return 0.8;
    }
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0; // Для мобильных - 0 отступов по бокам
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
      'title': 'Курс биткоина к концу года',
      'description': 'Прогнозы стоимости биткоина и других криптовалют на конец года',
      'emoji': '💰',
      'participants': 3400,
      'predictions': 15000,
      'end_date': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      'category': 'finance',
      'author': 'Криптоаналитики',
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

  // ВИДЖЕТЫ ФИЛЬТРОВ И КАТЕГОРИЙ КАК В ПЕРВОМ ФАЙЛЕ
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: _isMobile ? 0 : horizontalPadding,
          vertical: 8
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isMobile ? 0 : 12),
        ),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(_isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фильтры',
                style: TextStyle(
                  fontSize: _isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: _isMobile ? 36 : 40,
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

    return Container(
      margin: EdgeInsets.only(right: _isMobile ? 6 : 8),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
        child: InkWell(
          onTap: () {
            if (id == 'favorites') {
              _showFavorites();
            }
          },
          borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobile ? 12 : 16,
              vertical: _isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: _isMobile ? 14 : 16,
                  color: isActive ? Colors.white : Colors.blue,
                ),
                SizedBox(width: _isMobile ? 4 : 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.black87,
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
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: _isMobile ? 0 : horizontalPadding,
          vertical: 8
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isMobile ? 0 : 12),
        ),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(_isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Категории',
                style: TextStyle(
                  fontSize: _isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: _isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _categories
                      .map((category) => _buildCategoryChip(category))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(LeagueCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return Container(
      margin: EdgeInsets.only(right: _isMobile ? 6 : 8),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
        child: InkWell(
          onTap: () {
            setState(() {
              _currentTabIndex = _categories.indexOf(category);
            });
          },
          borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobile ? 12 : 16,
              vertical: _isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: _isMobile ? 14 : 16,
                  color: isSelected ? Colors.white : category.color,
                ),
                SizedBox(width: _isMobile ? 4 : 6),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: _isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск лиг прогнозов...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            const Text(
              'Сортировка',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._sortOptions.map((option) => ListTile(
              leading: Icon(option.icon, size: 18),
              title: Text(
                option.title,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: _sortOptions.indexOf(option) == _currentSortIndex
                  ? const Icon(Icons.check, color: Colors.blue, size: 18)
                  : null,
              onTap: () {
                setState(() => _currentSortIndex = _sortOptions.indexOf(option));
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
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
              // AppBar как в первом файле
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: _isMobile ? 16 : horizontalPadding,
                    vertical: 8
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    if (!_showSearchBar) ...[
                      const Text(
                        'Лиги Прогнозов',
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
                            Expanded(
                              child: _buildSearchField(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                              onPressed: () => setState(() {
                                _showSearchBar = false;
                                _searchController.clear();
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
                              child: const Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                            onPressed: () => setState(() => _showSearchBar = true),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                            onPressed: () => setState(() => _showFilters = !_showFilters),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sort,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                            onPressed: _showSortBottomSheet,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _buildContent(horizontalPadding),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateLeague,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget _buildContent(double horizontalPadding) {
    final filteredLeagues = _getFilteredLeagues(_demoLeagues);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildFiltersCard(horizontalPadding),
        ),
        SliverToBoxAdapter(
          child: _buildCategoriesCard(horizontalPadding),
        ),
        if (filteredLeagues.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  const Text(
                    'Лиги не найдены',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Попробуйте изменить параметры поиска',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobile ? 0 : horizontalPadding,
              vertical: _isMobile ? 0 : 8,
            ),
            sliver: _isMobile
                ? SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index == filteredLeagues.length && _isLoadingMore) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (index >= filteredLeagues.length) return const SizedBox.shrink();

                  final leagueData = filteredLeagues[index];
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
                childCount: filteredLeagues.length + (_isLoadingMore ? 1 : 0),
              ),
            )
                : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: _getCardAspectRatio(context),
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index == filteredLeagues.length && _isLoadingMore) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (index >= filteredLeagues.length) return const SizedBox.shrink();

                  final leagueData = filteredLeagues[index];
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
                childCount: filteredLeagues.length + (_isLoadingMore ? 1 : 0),
              ),
            ),
          ),
      ],
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