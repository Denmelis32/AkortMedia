import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import '../communities/communities_page.dart';
import '../communities/models/community.dart';
import '../communities_details_page/discussion.dart';
import '../communities_details_page/discussion_card.dart';
import 'models/room.dart';
import 'models/room_category.dart';
import 'models/filter_option.dart';
import 'widgets/create_room_button.dart';

class AdaptiveRoomsPage extends StatefulWidget {
  final VoidCallback onLogout;

  const AdaptiveRoomsPage({
    super.key,
    required this.onLogout,
  });

  @override
  State<AdaptiveRoomsPage> createState() => _AdaptiveRoomsPageState();
}

class _AdaptiveRoomsPageState extends State<AdaptiveRoomsPage>
    with TickerProviderStateMixin {
  // Константы для адаптивного дизайна
  static const _animationDuration = Duration(milliseconds: 300);
  static const _refreshDelay = Duration(seconds: 2);

  // Контроллеры
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Анимации
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;

  // Состояние
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showSearchBar = false;
  bool _showFilters = false;

  // Категории комнат (используем существующие из RoomCategory)
  final List<RoomCategory> _categories = [
    RoomCategory(
        id: 'all', title: 'Все', icon: Icons.explore, color: Colors.blue),
    RoomCategory(id: 'technology',
        title: 'Технологии',
        icon: Icons.memory,
        color: Colors.orange),
    RoomCategory(id: 'business',
        title: 'Бизнес',
        icon: Icons.business_center,
        color: Colors.purple),
    RoomCategory(id: 'education',
        title: 'Образование',
        icon: Icons.school,
        color: Colors.teal),
    RoomCategory(id: 'entertainment',
        title: 'Развлечения',
        icon: Icons.movie,
        color: Colors.pink),
    RoomCategory(id: 'sports',
        title: 'Спорт',
        icon: Icons.sports_soccer,
        color: Colors.red),
    RoomCategory(id: 'music',
        title: 'Музыка',
        icon: Icons.music_note,
        color: Colors.green),
  ];

  // Опции фильтрации
  final List<FilterOption> _filterOptions = [
    FilterOption(
        id: 'active', title: 'Только активные', icon: Icons.online_prediction),
    FilterOption(id: 'joined', title: 'Мои комнаты', icon: Icons.subscriptions),
    FilterOption(id: 'favorites', title: 'Избранное', icon: Icons.favorite),
  ];

  // ОТСТУПЫ: ДЛЯ ТЕЛЕФОНА 0, ДЛЯ КОМПЬЮТЕРА КАК БЫЛО
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 0; // НА ТЕЛЕФОНЕ БЕЗ ОТСТУПОВ
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 840;
    if (width > 1000) return 840;
    if (width > 700) return 840;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupEventListeners();
    _loadInitialData();
  }

  void _initializeControllers() {
    _fabAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fabAnimationController.forward();
  }

  void _setupEventListeners() {
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomsWithDelay();
    });
  }

  Future<void> _loadRoomsWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      context.read<RoomProvider>().loadRooms();
    }
  }

  void _onScroll() {
    // Логика скролла при необходимости
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  Future<void> _refreshRooms() async {
    setState(() => _isLoading = true);
    await context.read<RoomProvider>().loadRooms();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openChatPage(Room room) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          roomId: room.id,
          roomName: room.title,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ФИЛЬТРАЦИЯ с использованием RoomProvider
  List<Room> _getFilteredRooms(RoomProvider roomProvider) {
    return roomProvider.filteredRooms.where(_matchesFilters).toList();
  }

  bool _matchesFilters(Room room) {
    // Категория
    if (_selectedCategoryId != 'all' && room.category.id != _selectedCategoryId) {
      return false;
    }

    // Поиск
    if (_searchQuery.isNotEmpty) {
      return room.title.toLowerCase().contains(_searchQuery) ||
          room.description.toLowerCase().contains(_searchQuery) ||
          room.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }

    return true;
  }

  // ПРЕОБРАЗОВАНИЕ ROOM В DISCUSSION ДЛЯ DiscussionCard
  Discussion _roomToDiscussion(Room room) {
    return Discussion(
      id: room.id,
      title: room.title,
      content: room.description,
      imageUrl: room.imageUrl.isNotEmpty ? room.imageUrl : null,
      authorName: room.creatorName.isNotEmpty ? room.creatorName : 'Создатель комнаты',
      authorAvatarUrl: room.creatorAvatarUrl ?? 'https://via.placeholder.com/150/007bff/ffffff?text=R',
      communityId: room.communityId ?? "0",
      communityName: room.hasCommunity ? 'Сообщество ${room.title}' : 'Комната',
      tags: room.tags,
      likesCount: room.ratingCount,
      commentsCount: room.messageCount,
      viewsCount: room.currentParticipants,
      isPinned: room.isPinned,
      allowComments: true,
      isLiked: room.isJoined,
      isBookmarked: false,
      createdAt: room.createdAt,
      updatedAt: room.lastActivity,
    );
  }

  // ВИДЖЕТЫ ДЛЯ ФИЛЬТРОВ И КАТЕГОРИЙ - БЕЗ ОТСТУПОВ НА ТЕЛЕФОНЕ
  Widget _buildFiltersCard(double horizontalPadding, RoomProvider roomProvider) {
    if (!_showFilters) return const SizedBox.shrink();

    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 0 : 12)),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фильтры',
                style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _filterOptions.map((filter) => _buildFilterChip(filter, roomProvider, isMobile)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(double horizontalPadding) {
    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 0 : 12)),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Категории',
                style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _categories
                      .map((category) => _buildCategoryChip(category, isMobile))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(RoomCategory category, bool isMobile) {
    final isSelected = _selectedCategoryId == category.id;

    return Container(
      margin: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: InkWell(
          onTap: () => setState(() => _selectedCategoryId = category.id),
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
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
                    size: isMobile ? 14 : 16,
                    color: isSelected ? Colors.white : category.color
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
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

  Widget _buildFilterChip(FilterOption filter, RoomProvider roomProvider, bool isMobile) {
    final isActive = roomProvider.activeFilters.contains(filter.id);

    return Container(
      margin: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: InkWell(
          onTap: () => roomProvider.toggleFilter(filter.id),
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    filter.icon,
                    size: isMobile ? 14 : 16,
                    color: isActive ? Colors.white : Colors.blue
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  filter.title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
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

  // ПОЛЕ ПОИСКА
  Widget _buildSearchField(RoomProvider roomProvider) {
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
          hintText: 'Поиск комнат...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              roomProvider.setSearchQuery('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
        onChanged: (value) => roomProvider.setSearchQuery(value),
      ),
    );
  }

  // ВИДЖЕТ КАРТОЧКИ КОМНАТЫ - БЕЗ ОТСТУПОВ НА ТЕЛЕФОНЕ
  Widget _buildRoomCard(Room room, double horizontalPadding) {
    final discussion = _roomToDiscussion(room);
    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: isMobile ? 0 : 16, // НА ТЕЛЕФОНЕ БЕЗ ОТСТУПОВ СНИЗУ
      ),
      constraints: BoxConstraints(maxWidth: _getContentMaxWidth(context)),
      child: DiscussionCard(
        discussion: discussion,
        onTap: () => _openChatPage(room),
        onLike: () {
          // Логика лайка для комнаты
        },
        onComment: () => _openChatPage(room),
        onShare: () {
          // Логика поделиться комнатой
          _showShareDialog(room);
        },
        onMore: () {
          _showRoomOptions(room);
        },
      ),
    );
  }

  void _showShareDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поделиться комнатой'),
        content: Text('Поделиться комнатой "${room.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ссылка на комнату "${room.title}" скопирована'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Поделиться'),
          ),
        ],
      ),
    );
  }

  void _showRoomOptions(Room room) {
    final roomProvider = context.read<RoomProvider>();

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
            const SizedBox(height: 16),

            // Присоединиться/Покинуть
            ListTile(
              leading: Icon(
                room.isJoined ? Icons.exit_to_app : Icons.login,
                color: room.isJoined ? Colors.red : Colors.green,
              ),
              title: Text(room.isJoined ? 'Покинуть комнату' : 'Присоединиться'),
              onTap: () {
                Navigator.pop(context);
                roomProvider.toggleJoinRoom(room.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(room.isJoined ? 'Вы покинули комнату' : 'Вы присоединились к комнате'),
                    backgroundColor: room.isJoined ? Colors.orange : Colors.green,
                  ),
                );
              },
            ),

            // Закрепить/Открепить
            ListTile(
              leading: Icon(
                room.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Colors.orange,
              ),
              title: Text(room.isPinned ? 'Открепить комнату' : 'Закрепить комнату'),
              onTap: () {
                Navigator.pop(context);
                roomProvider.togglePinRoom(room.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(room.isPinned ? 'Комната откреплена' : 'Комната закреплена'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),

            // Пожаловаться
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Пожаловаться на комнату'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(room);
              },
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на комнату'),
        content: const Text('Пожалуйста, укажите причину жалобы'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Жалоба отправлена'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  // ВИДЖЕТ ПУСТОГО СОСТОЯНИЯ
  Widget _buildEmptyState(double horizontalPadding) {
    return SliverFillRemaining(
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
          constraints: BoxConstraints(maxWidth: _getContentMaxWidth(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Комнаты не найдены',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Попробуйте изменить параметры поиска или создать новую комнату',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RoomProvider>().clearAllFilters();
                  _searchController.clear();
                  setState(() {
                    _selectedCategoryId = 'all';
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Сбросить фильтры'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        final horizontalPadding = _getHorizontalPadding(context);
        final filteredRooms = _getFilteredRooms(roomProvider);
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
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        if (!_showSearchBar) ...[
                          const Text(
                            'Комнаты',
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
                                Expanded(child: _buildSearchField(roomProvider)),
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
                                  onPressed: () {
                                    _searchController.clear();
                                    roomProvider.setSearchQuery('');
                                    setState(() {
                                      _showSearchBar = false;
                                      _searchQuery = '';
                                    });
                                  },
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
                                  child: const Icon(Icons.groups_rounded, color: Colors.black, size: 18),
                                ),
                                onPressed: _openCommunities,
                                tooltip: 'Сообщества',
                              ),
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
                                tooltip: 'Поиск',
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
                                tooltip: 'Фильтры',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Контент
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _showFilters ? _buildFiltersCard(horizontalPadding, roomProvider) : const SizedBox.shrink(),
                          ),

                          SliverToBoxAdapter(
                            child: _buildCategoriesCard(horizontalPadding),
                          ),

                          if (filteredRooms.isEmpty)
                            _buildEmptyState(horizontalPadding)
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildRoomCard(filteredRooms[index], horizontalPadding),
                                childCount: filteredRooms.length,
                              ),
                            ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 80),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CreateRoomButton(
              onRoomCreated: (newRoom) {
                roomProvider.addRoomLocally(newRoom);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Комната "${newRoom.title}" создана!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Метод для определения мобильного устройства
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // Открытие страницы сообществ
  void _openCommunities() {
    final userProvider = context.read<UserProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CommunitiesPage(
              userName: userProvider.userName,
              userEmail: userProvider.userEmail,
              onLogout: widget.onLogout,
            ),
      ),
    );
  }
}