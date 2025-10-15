import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/communities/widgets/add_community_dialog.dart';
import 'package:my_app/pages/communities/widgets/community_card.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/community_state_provider.dart';

import '../communities_details_page/community_detail_page.dart';
import 'models/community.dart';

class CommunitiesPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const CommunitiesPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class SortOption {
  final String label;
  final String title;
  final IconData icon;
  final int Function(Community, Community) comparator;

  SortOption(this.label, this.title, this.icon, this.comparator);
}

class CommunityCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  CommunityCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  // Константы
  static const defaultImageUrl = 'https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=500&h=300&fit=crop';
  static const defaultAvatarUrl = 'https://via.placeholder.com/150/007bff/ffffff?text=C';

  final List<CommunityCategory> _categories = [
    CommunityCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive,
      color: Colors.blue,
    ),
    CommunityCategory(
      id: 'technology',
      title: 'Технологии',
      description: 'IT, программирование, гаджеты',
      icon: Icons.computer,
      color: Colors.blue,
    ),
    CommunityCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Стартапы и инвестиции',
      icon: Icons.business,
      color: Colors.orange,
    ),
    CommunityCategory(
      id: 'games',
      title: 'Игры',
      description: 'Игровая индустрия',
      icon: Icons.sports_esports,
      color: Colors.purple,
    ),
    CommunityCategory(
      id: 'education',
      title: 'Образование',
      description: 'Обучение и курсы',
      icon: Icons.school,
      color: Colors.green,
    ),
    CommunityCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer,
      color: Colors.red,
    ),
    CommunityCategory(
      id: 'art',
      title: 'Искусство',
      description: 'Творчество и дизайн',
      icon: Icons.palette,
      color: Colors.pink,
    ),
    CommunityCategory(
      id: 'music',
      title: 'Музыка',
      description: 'Музыкальные сообщества',
      icon: Icons.music_note,
      color: Colors.deepPurple,
    ),
  ];

  final List<SortOption> _sortOptions = [
    SortOption('Сначала новые', 'Сначала новые', Icons.new_releases, (a, b) {
      return b.createdAt.compareTo(a.createdAt);
    }),
    SortOption('По популярности', 'По популярности', Icons.trending_up, (a, b) {
      return b.membersCount.compareTo(a.membersCount);
    }),
    SortOption('По активности', 'По активности', Icons.local_fire_department, (a, b) {
      return b.postsCount.compareTo(a.postsCount);
    }),
  ];

  final List<String> _popularSearches = ['Flutter', 'Программирование', 'Бизнес', 'Игры'];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Set<String> _favoriteCommunityIds = <String>{};
  final Set<String> _selectedCommunities = <String>{};
  final List<String> _searchHistory = [];

  int _currentTabIndex = 0;
  int _currentSortIndex = 0;
  String _searchQuery = '';

  bool _isLoadingMore = false;
  bool _isOffline = false;
  bool _isSelectionMode = false;
  bool _showSearchBar = false;
  bool _showFilters = false;

  // АДАПТИВНЫЕ МЕТОДЫ
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  // Определяем, мобильное ли устройство
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // ОПТИМАЛЬНЫЕ ПРОПОРЦИИ
  double _getCardAspectRatio(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные - 1 карточка в ряд
        return 1.1;
      case 2: // Планшеты - 2 карточки в ряд
        return 0.8;
      case 3: // Десктоп - 3 карточки в ряд
        return 0.85;
      default:
        return 0.8;
    }
  }

  // ТАКИЕ ЖЕ ОТСТУПЫ КАК В CARDS_PAGE
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  // ОТСТУПЫ МЕЖДУ КАРТОЧКАМИ
  double _getGridSpacing(BuildContext context) {
    if (_isMobile(context)) return 0;
    return 12;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
    _loadCachedCommunities();
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

  void _loadCachedCommunities() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreCommunities();
    }
  }

  Future<void> _loadMoreCommunities() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _openCommunityDetail(Community community) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommunityDetailPage(community: community),
      ),
    );
  }

  void _navigateToAddCommunityPage() {
    final communityStateProvider = Provider.of<CommunityStateProvider>(context, listen: false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCommunityPage(
          categories: _categories.where((cat) => cat.id != 'all').map((cat) => cat.title).toList(),
          onCommunityAdded: (newCommunity) {
            communityStateProvider.addCommunity(newCommunity);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Сообщество "${newCommunity.title}" успешно создано!'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          },
          userName: widget.userName,
          userAvatarUrl: defaultAvatarUrl,
        ),
      ),
    );
  }

  void _toggleFavorite(String communityId) {
    setState(() {
      if (_favoriteCommunityIds.contains(communityId)) {
        _favoriteCommunityIds.remove(communityId);
      } else {
        _favoriteCommunityIds.add(communityId);
      }
    });
  }

  bool _isCommunityFavorite(String communityId) => _favoriteCommunityIds.contains(communityId);

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedCommunities.clear();
    });
  }

  void _toggleCommunitySelection(String communityId) {
    setState(() {
      if (_selectedCommunities.contains(communityId)) {
        _selectedCommunities.remove(communityId);
      } else {
        _selectedCommunities.add(communityId);
      }
    });
  }

  void _deleteSelectedCommunities() {
    if (_selectedCommunities.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщества?'),
        content: Text('Вы уверены, что хотите удалить ${_selectedCommunities.length} сообществ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')
          ),
          TextButton(
            onPressed: () {
              final communityStateProvider = Provider.of<CommunityStateProvider>(context, listen: false);
              for (final id in _selectedCommunities) {
                communityStateProvider.removeCommunity(id);
              }
              _toggleSelectionMode();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Удалено ${_selectedCommunities.length} сообществ'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareSelectedCommunities() {
    if (_selectedCommunities.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Поделиться ${_selectedCommunities.length} сообществами'),
          backgroundColor: Colors.blue,
        )
    );
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

  // ВИДЖЕТЫ ДЛЯ ФИЛЬТРОВ И КАТЕГОРИЙ
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

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
                'Фильтры',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _buildFilterChip('verified', 'Только проверенные', Icons.verified),
                    _buildFilterChip('favorites', 'Избранное', Icons.favorite),
                    _buildFilterChip('private', 'Приватные', Icons.lock),
                    _buildFilterChip('public', 'Публичные', Icons.public),
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
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (id == 'favorites') {
              _showFavorites();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isActive ? Colors.white : Colors.blue),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : Colors.black87
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

  Widget _buildCategoryChip(CommunityCategory category) {
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
                Text(
                  category.title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87
                  ),
                ),
              ],
            ),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск сообществ...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _addToSearchHistory(value);
        },
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
            const Text('Сортировка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._sortOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return ListTile(
                leading: Icon(option.icon, size: 18),
                title: Text(option.title, style: const TextStyle(fontSize: 13)),
                trailing: index == _currentSortIndex
                    ? const Icon(Icons.check, color: Colors.blue, size: 18)
                    : null,
                onTap: () {
                  setState(() => _currentSortIndex = index);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Виджет для пустого состояния
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Сообщества не найдены',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить параметры поиска или создать новое сообщество',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _navigateToAddCommunityPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Создать сообщество'),
              ),
            ],
          ),
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
              // AppBar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : horizontalPadding,
                    vertical: 8
                ),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    // КНОПКА НАЗАД
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),

                    if (!_showSearchBar) ...[
                      const Text(
                        'Сообщества',
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
                              child: const Icon(Icons.search, color: Colors.black, size: 18),
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
                              child: const Icon(Icons.sort, color: Colors.black, size: 18),
                            ),
                            onPressed: _showSortBottomSheet,
                          ),
                          if (_isSelectionMode) ...[
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.delete, color: Colors.red[700], size: 18),
                              ),
                              onPressed: _deleteSelectedCommunities,
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.share, color: Colors.blue[700], size: 18),
                              ),
                              onPressed: _shareSelectedCommunities,
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.black, size: 18),
                              ),
                              onPressed: _toggleSelectionMode,
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: Consumer<CommunityStateProvider>(
                  builder: (context, communityStateProvider, child) {
                    return _buildContent(communityStateProvider, horizontalPadding);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Кнопка добавления сообщества
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton(
        onPressed: _navigateToAddCommunityPage,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.group_add, size: 24),
      ),
    );
  }

  Widget _buildContent(CommunityStateProvider communityStateProvider, double horizontalPadding) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Фильтры
        SliverToBoxAdapter(child: _buildFiltersCard(horizontalPadding)),

        // Категории
        SliverToBoxAdapter(child: _buildCategoriesCard(horizontalPadding)),

        // Карточки сообществ
        _buildCommunitiesGrid(communityStateProvider, horizontalPadding),
      ],
    );
  }

  Widget _buildCommunitiesGrid(CommunityStateProvider communityStateProvider, double horizontalPadding) {
    final communitiesToShow = communityStateProvider.communities;
    final filteredCommunities = _getFilteredCommunities(communitiesToShow);
    final isMobile = _isMobile(context);
    final gridSpacing = _getGridSpacing(context);

    if (filteredCommunities.isEmpty) {
      return _buildEmptyState();
    }

    // ДЛЯ МОБИЛЬНЫХ - ИСПОЛЬЗУЕМ SliverList вместо SliverGrid
    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= filteredCommunities.length) return const SizedBox.shrink();

            final community = filteredCommunities[index];
            final communityId = community.id.toString();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Stack(
                children: [
                  CommunityCard(
                    key: ValueKey(community.id),
                    community: community,
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleCommunitySelection(communityId);
                      } else {
                        _openCommunityDetail(community);
                      }
                    },
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        _toggleSelectionMode();
                        _toggleCommunitySelection(communityId);
                      }
                    },
                  ),
                  if (_isSelectionMode)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Checkbox(
                        value: _selectedCommunities.contains(communityId),
                        onChanged: (_) => _toggleCommunitySelection(communityId),
                      ),
                    ),
                  if (_isCommunityFavorite(communityId))
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, size: 16, color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
          childCount: filteredCommunities.length,
        ),
      );
    }

    // ДЛЯ ПЛАНШЕТОВ И КОМПЬЮТЕРОВ - ИСПОЛЬЗУЕМ SliverGrid
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          childAspectRatio: _getCardAspectRatio(context),
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == filteredCommunities.length && _isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            }
            if (index >= filteredCommunities.length) return const SizedBox.shrink();

            final community = filteredCommunities[index];
            final communityId = community.id.toString();

            return Stack(
              children: [
                CommunityCard(
                  key: ValueKey(community.id),
                  community: community,
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleCommunitySelection(communityId);
                    } else {
                      _openCommunityDetail(community);
                    }
                  },
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      _toggleSelectionMode();
                      _toggleCommunitySelection(communityId);
                    }
                  },
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Checkbox(
                      value: _selectedCommunities.contains(communityId),
                      onChanged: (_) => _toggleCommunitySelection(communityId),
                    ),
                  ),
                if (_isCommunityFavorite(communityId))
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, size: 16, color: Colors.red),
                    ),
                  ),
              ],
            );
          },
          childCount: filteredCommunities.length + (_isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  List<Community> _getFilteredCommunities(List<Community> allCommunities) {
    final selectedCategory = _categories[_currentTabIndex];
    var filtered = allCommunities.where((community) {
      final matchesSearch = _searchQuery.isEmpty ||
          community.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory = selectedCategory.id == 'all' ||
          community.tags.any((tag) => tag.toLowerCase() == selectedCategory.id.toLowerCase());

      return matchesSearch && matchesCategory;
    }).toList();

    filtered.sort(_sortOptions[_currentSortIndex].comparator);
    return filtered;
  }
}