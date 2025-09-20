// lib/pages/cards_page/cards_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'channel_detail_page.dart';
import 'models/channel.dart';

class CardsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const CardsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> with TickerProviderStateMixin {
  final List<Channel> _channels = [
    Channel(
      id: 1,
      title: 'Технологии будущего',
      description: 'Обсуждаем новейшие технологии и инновации в IT и робототехнике. Присоединяйтесь к нашему сообществу!',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      subscribers: 12450,
      videos: 89,
      isSubscribed: true,
      isFavorite: false,
      cardColor: Colors.blue.shade800,
      categoryId: 'youtube',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isVerified: true,
      rating: 4.8,
      views: 1250000,
      likes: 45000,
      comments: 2300,
      owner: 'Иван Технолог',
      tags: ['технологии', 'IT', 'инновации', 'робототехника'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: 'https://tech-future.ru',
      socialMedia: '@tech_future',
    ),
    Channel(
      id: 2,
      title: 'Бизнес стратегии',
      description: 'Советы по ведению успешного бизнеса и инвестициям. Практические кейсы и экспертные мнения.',
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
      subscribers: 8900,
      videos: 67,
      isSubscribed: false,
      isFavorite: true,
      cardColor: Colors.purple.shade700,
      categoryId: 'business',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      isVerified: false,
      rating: 4.5,
      views: 890000,
      likes: 32000,
      comments: 1500,
      owner: 'Мария Бизнесменова',
      tags: ['бизнес', 'инвестиции', 'стратегии', 'финансы'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: 'https://business-strategy.ru',
      socialMedia: '@biz_strategy',
    ),
    Channel(
      id: 3,
      title: 'Игровые обзоры',
      description: 'Новинки игровой индустрии и геймплей по всем платформам. Только честные обзоры!',
      imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400',
      subscribers: 15600,
      videos: 120,
      isSubscribed: true,
      isFavorite: true,
      cardColor: Colors.red.shade800,
      categoryId: 'games',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      isVerified: true,
      rating: 4.9,
      views: 2100000,
      likes: 89000,
      comments: 4500,
      owner: 'Алексей Геймеров',
      tags: ['игры', 'гейминг', 'обзоры', 'стримы'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: 'https://game-reviews.ru',
      socialMedia: '@game_reviews',
    ),
    Channel(
      id: 4,
      title: 'Программирование',
      description: 'Уроки и советы по разработке ПО для всех уровней. От новичка до профессионала.',
      imageUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=400',
      subscribers: 23400,
      videos: 156,
      isSubscribed: false,
      isFavorite: false,
      cardColor: Colors.teal.shade700,
      categoryId: 'programming',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      isVerified: true,
      rating: 4.7,
      views: 3450000,
      likes: 125000,
      comments: 7800,
      owner: 'Сергей Разработчик',
      tags: ['программирование', 'IT', 'разработка', 'обучение'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: 'https://code-master.ru',
      socialMedia: '@code_master',
    ),
    Channel(
      id: 5,
      title: 'Спортивные новости',
      description: 'Последние события в мире спорта и аналитика матчей. Эксклюзивные интервью с атлетами.',
      imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400',
      subscribers: 17800,
      videos: 95,
      isSubscribed: true,
      isFavorite: false,
      cardColor: Colors.orange.shade800,
      categoryId: 'sport',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isVerified: false,
      rating: 4.6,
      views: 1980000,
      likes: 67000,
      comments: 3200,
      owner: 'Дмитрий Спортивный',
      tags: ['спорт', 'новости', 'аналитика', 'матчи'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: 'https://sport-news.ru',
      socialMedia: '@sport_news',
    ),
    Channel(
      id: 6,
      title: 'Психология общения',
      description: 'Как улучшить коммуникативные навыки и отношения. Практические техники и упражнения.',
      imageUrl: 'https://images.unsplash.com/photo-1545239351-ef35f43d514b?w=400',
      subscribers: 6700,
      videos: 45,
      isSubscribed: false,
      isFavorite: true,
      cardColor: Colors.green.shade800,
      categoryId: 'communication',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      isVerified: true,
      rating: 4.4,
      views: 780000,
      likes: 28000,
      comments: 1900,
      owner: 'Анна Психологова',
      tags: ['психология', 'общение', 'отношения', 'развитие'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: 'https://psychology-talk.ru',
      socialMedia: '@psychology_talk',
    ),
  ];

  final List<RoomCategory> _categories = [
    RoomCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive,
      color: Colors.blue,
    ),
    RoomCategory(
      id: 'youtube',
      title: 'YouTube',
      description: 'Обсуждение видео и блогеров',
      icon: Icons.video_library,
      color: Colors.red,
    ),
    RoomCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Стартапы и инвестиции',
      icon: Icons.business,
      color: Colors.orange,
    ),
    RoomCategory(
      id: 'games',
      title: 'Игры',
      description: 'Игровая индустрия',
      icon: Icons.sports_esports,
      color: Colors.purple,
    ),
    RoomCategory(
      id: 'programming',
      title: 'Программирование',
      description: 'Разработка и IT',
      icon: Icons.code,
      color: Colors.blue,
    ),
    RoomCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer,
      color: Colors.green,
    ),
    RoomCategory(
      id: 'communication',
      title: 'Общение',
      description: 'Психология и отношения',
      icon: Icons.chat,
      color: Colors.pink,
    ),
  ];

  final List<SortOption> _sortOptions = [
    SortOption(id: 'newest', title: 'Сначала новые', icon: Icons.new_releases),
    SortOption(id: 'popular', title: 'По популярности', icon: Icons.trending_up),
    SortOption(id: 'subscribers', title: 'По подписчикам', icon: Icons.people),
    SortOption(id: 'rating', title: 'По рейтингу', icon: Icons.star),
    SortOption(id: 'videos', title: 'По количеству видео', icon: Icons.video_library),
  ];

  final List<FilterOption> _filterOptions = [
    FilterOption(id: 'verified', title: 'Только проверенные', icon: Icons.verified),
    FilterOption(id: 'subscribed', title: 'Мои подписки', icon: Icons.subscriptions),
    FilterOption(id: 'favorites', title: 'Избранное', icon: Icons.favorite),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late AnimationController _refreshController;

  int _currentTabIndex = 0;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  String _selectedSort = 'newest';
  Set<String> _activeFilters = {};
  bool _isGridView = true;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _showFilters = false;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _tabScrollController.dispose();
    _animationController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  List<Channel> get _filteredChannels {
    List<Channel> filtered = List.from(_channels);

    // Фильтрация по категории
    if (_selectedCategoryId != 'all') {
      filtered = filtered
          .where((channel) => channel.categoryId == _selectedCategoryId)
          .toList();
    }

    // Применение дополнительных фильтров
    if (_activeFilters.contains('verified')) {
      filtered = filtered.where((channel) => channel.isVerified).toList();
    }
    if (_activeFilters.contains('subscribed')) {
      filtered = filtered.where((channel) => channel.isSubscribed).toList();
    }
    if (_activeFilters.contains('favorites')) {
      filtered = filtered.where((channel) => channel.isFavorite).toList();
    }

    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((channel) {
        return channel.title.toLowerCase().contains(_searchQuery) ||
            channel.description.toLowerCase().contains(_searchQuery) ||
            channel.tags.any((tag) => tag.toLowerCase().contains(_searchQuery)) ||
            channel.owner.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Сортировка
    switch (_selectedSort) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popular':
        filtered.sort((a, b) => b.views.compareTo(a.views));
        break;
      case 'subscribers':
        filtered.sort((a, b) => b.subscribers.compareTo(a.subscribers));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'videos':
        filtered.sort((a, b) => b.videos.compareTo(a.videos));
        break;
    }

    return filtered;
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    _refreshController.repeat(reverse: true);

    // Имитация загрузки новых данных
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _refreshController.reset();
    });
  }

  void _createNewChannel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
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
              'Создать новый канал',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Название канала',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.background,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.background,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId == 'all' ? 'youtube' : _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.background,
              ),
              items: _categories.where((c) => c.id != 'all').map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(category.icon, size: 18, color: category.color),
                      const SizedBox(width: 8),
                      Text(category.title),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _titleController.clear();
                      _descriptionController.clear();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isNotEmpty) {
                        _addNewChannel(
                          _titleController.text,
                          _descriptionController.text,
                        );
                        _titleController.clear();
                        _descriptionController.clear();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Создать'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewChannel(String title, String description) async {
    setState(() => _isLoading = true);

    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 1500));

    final newChannel = Channel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      description: description,
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      subscribers: 0,
      videos: 0,
      isSubscribed: false,
      isFavorite: false,
      cardColor: _getRandomColor(),
      categoryId: _selectedCategoryId == 'all' ? 'youtube' : _selectedCategoryId,
      createdAt: DateTime.now(),
      isVerified: false,
      rating: 0.0,
      views: 0,
      likes: 0,
      comments: 0,
      owner: widget.userName,
      tags: ['новый', 'канал'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: '',
      socialMedia: '',
    );

    setState(() {
      _channels.insert(0, newChannel);
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Канал успешно создан!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade800,
      Colors.purple.shade700,
      Colors.red.shade800,
      Colors.teal.shade700,
      Colors.orange.shade800,
      Colors.green.shade800,
      Colors.indigo.shade700,
      Colors.deepOrange.shade700,
      Colors.pink.shade700,
      Colors.cyan.shade700,
    ];
    return colors[_channels.length % colors.length];
  }

  Future<void> _toggleSubscription(int index) async {
    final channel = _filteredChannels[index];
    final globalIndex = _channels.indexWhere((c) => c.id == channel.id);

    if (globalIndex != -1) {
      setState(() {
        _channels[globalIndex] = _channels[globalIndex].copyWith(
          isSubscribed: !_channels[globalIndex].isSubscribed,
          subscribers: _channels[globalIndex].isSubscribed
              ? _channels[globalIndex].subscribers - 1
              : _channels[globalIndex].subscribers + 1,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _channels[globalIndex].isSubscribed
                ? '✅ Подписались на ${channel.title}'
                : '❌ Отписались от ${channel.title}',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: _channels[globalIndex].isSubscribed
              ? Colors.green
              : Colors.grey[800],
        ),
      );
    }
  }

  Future<void> _toggleFavorite(int index) async {
    final channel = _filteredChannels[index];
    final globalIndex = _channels.indexWhere((c) => c.id == channel.id);

    if (globalIndex != -1) {
      setState(() {
        _channels[globalIndex] = _channels[globalIndex].copyWith(
          isFavorite: !_channels[globalIndex].isFavorite,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _channels[globalIndex].isFavorite
                ? '⭐ Добавлено в избранное'
                : '🗑️ Удалено из избранного',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: _channels[globalIndex].isFavorite
              ? Colors.amber[700]
              : Colors.grey[800],
        ),
      );
    }
  }

  Widget _buildTabItem(RoomCategory category, int index) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
          _selectedCategoryId = category.id;
          _searchController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? category.color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? category.color : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              category.title,
              style: TextStyle(
                color: isSelected ? category.color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _createNewChannel,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: theme.colorScheme.primary,
        backgroundColor: theme.scaffoldBackgroundColor,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 140.0,
                floating: false,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                title: AnimatedOpacity(
                  opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Каналы',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                centerTitle: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: ColoredBox(
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          controller: _tabScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: _categories.asMap().entries.map((entry) {
                              final index = entry.key;
                              final category = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _buildTabItem(category, index),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_showSearchBar ? Icons.search_off : Icons.search, size: 24),
                    onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
                    tooltip: 'Поиск',
                  ),
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view, size: 24),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    tooltip: 'Сменить вид',
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort, size: 24),
                    onPressed: _showSortBottomSheet,
                    tooltip: 'Сортировка',
                  ),
                  IconButton(
                    icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined, size: 24),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                    tooltip: 'Фильтры',
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle_rounded, size: 24),
                    onPressed: _showProfileMenu,
                    tooltip: 'Профиль',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.8),
                          theme.colorScheme.primary.withOpacity(0.4),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 20, bottom: 70),
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      'Каналы',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              if (_showFilters)
                SliverToBoxAdapter(
                  child: _buildFilterSection(),
                ),

              if (_showSearchBar)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Поиск каналов...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 24),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 22),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                              : null,
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_currentTabIndex != 0 || _searchQuery.isNotEmpty || _selectedSort != 'newest' || _activeFilters.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_currentTabIndex != 0)
                          FilterChip(
                            label: Text(
                              'Категория: ${_categories[_currentTabIndex].title}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _currentTabIndex = 0;
                                _selectedCategoryId = 'all';
                              });
                            },
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          ),
                        if (_searchQuery.isNotEmpty)
                          FilterChip(
                            label: Text(
                              'Поиск: "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            backgroundColor: Colors.green.withOpacity(0.1),
                            deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          ),
                        if (_selectedSort != 'newest')
                          FilterChip(
                            label: Text(
                              'Сортировка: ${_sortOptions.firstWhere((opt) => opt.id == _selectedSort).title}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedSort = 'newest';
                              });
                            },
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          ),
                        ..._activeFilters.map((filter) {
                          final option = _filterOptions.firstWhere((opt) => opt.id == filter);
                          return FilterChip(
                            label: Text(
                              option.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple[700],
                              ),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _activeFilters.remove(filter);
                              });
                            },
                            backgroundColor: Colors.purple.withOpacity(0.1),
                            deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
            ];
          },
          body: _isLoading
              ? _buildLoadingShimmer()
              : _buildCategoryContent(),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Фильтры:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filterOptions.map((option) {
              final isActive = _activeFilters.contains(option.id);
              return FilterChip(
                label: Text(option.title),
                selected: isActive,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _activeFilters.add(option.id);
                    } else {
                      _activeFilters.remove(option.id);
                    }
                  });
                },
                backgroundColor: isActive
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Colors.grey[200],
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                checkmarkColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                avatar: Icon(
                  option.icon,
                  size: 18,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(widget.userEmail),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Мой профиль'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Переход к профилю
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Избранное'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Переход к избранному
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('История просмотров'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Переход к истории
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Переход к настройкам
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Выйти', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Сортировка каналов',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map((option) => ListTile(
              leading: Icon(option.icon, color: Theme.of(context).colorScheme.primary),
              title: Text(option.title),
              trailing: _selectedSort == option.id
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedSort = option.id;
                });
                Navigator.pop(context);
              },
            )).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    final categoryChannels = _filteredChannels;

    if (categoryChannels.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'Каналы не найдены',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Попробуйте изменить параметры поиска\nили создать новый канал',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createNewChannel,
                icon: const Icon(Icons.add),
                label: const Text('Создать канал'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _isGridView ? _buildGridView(categoryChannels) : _buildListView(categoryChannels);
  }

  Widget _buildGridView(List<Channel> channels) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) => _buildChannelCard(channels[index], index),
    );
  }

  Widget _buildListView(List<Channel> channels) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: channels.length,
      itemBuilder: (context, index) => _buildChannelListItem(channels[index], index),
    );
  }

  Widget _buildChannelCard(Channel channel, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChannelDetailPage(channel: channel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                channel.cardColor.withOpacity(0.9),
                channel.cardColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -20,
                right: -20,
                child: Icon(
                  Icons.circle,
                  size: 80,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Channel header
                    Row(
                      children: [
                        // Channel avatar with verification badge
                        Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(channel.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            if (channel.isVerified)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified, size: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                channel.title,
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
                                channel.owner,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Favorite button
                        IconButton(
                          icon: Icon(
                            channel.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: channel.isFavorite ? Colors.red : Colors.white.withOpacity(0.8),
                          ),
                          onPressed: () => _toggleFavorite(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Channel stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.people,
                          '${_formatNumber(channel.subscribers)}',
                          'подписчиков',
                        ),
                        _buildStatItem(
                          Icons.video_library,
                          '${channel.videos}',
                          'видео',
                        ),
                        _buildStatItem(
                          Icons.star,
                          channel.rating.toStringAsFixed(1),
                          'рейтинг',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Channel description
                    Text(
                      channel.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: channel.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 10,
                          ),
                        ),
                      )).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Subscribe button and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(channel.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _toggleSubscription(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: channel.isSubscribed
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white,
                            foregroundColor: channel.isSubscribed
                                ? Colors.white
                                : channel.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          child: Text(
                            channel.isSubscribed ? 'Отписаться' : 'Подписаться',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildChannelListItem(Channel channel, int index) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChannelDetailPage(channel: channel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Channel avatar
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(channel.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (channel.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            channel.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            channel.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: channel.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.owner,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      channel.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildListStatItem(
                          Icons.people,
                          '${_formatNumber(channel.subscribers)}',
                        ),
                        const SizedBox(width: 16),
                        _buildListStatItem(
                          Icons.video_library,
                          '${channel.videos}',
                        ),
                        const SizedBox(width: 16),
                        _buildListStatItem(
                          Icons.star,
                          channel.rating.toStringAsFixed(1),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(channel.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: channel.tags.take(2).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 10,
                          ),
                        ),
                      )).toList(),
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

  Widget _buildListStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}г назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}мес назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else {
      return 'только что';
    }
  }
}

class RoomCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  RoomCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });
}

class SortOption {
  final String id;
  final String title;
  final IconData icon;

  SortOption({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class FilterOption {
  final String id;
  final String title;
  final IconData icon;

  FilterOption({
    required this.id,
    required this.title,
    required this.icon,
  });
}