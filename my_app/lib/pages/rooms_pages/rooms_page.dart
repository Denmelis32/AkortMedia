import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import '../communities/ sections/communities_section.dart';
import 'models/room.dart';
import '../../providers/room_provider.dart';
import 'widgets/app_bar/rooms_app_bar.dart';
import 'widgets/sections/category_section.dart';
import 'widgets/sections/search_section.dart';
import 'widgets/sections/filters_section.dart';
import 'widgets/sections/stats_section.dart';
import 'widgets/sections/rooms_grid_section.dart';
import 'widgets/floating_actions/main_fab.dart';
import 'widgets/floating_actions/quick_actions_fab.dart';
import 'utils/room_navigation.dart';
// Импорты для сообществ
import '../communities/models/community.dart';
import '../communities/utils/community_navigation.dart';

class RoomsPage extends StatefulWidget {
  final VoidCallback onLogout;

  const RoomsPage({
    super.key,
    required this.onLogout,
  });

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearchExpanded = false;
  bool _showQuickActionsFab = false;
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _quickActionsFabController;

  final RoomNavigation _roomNavigation = RoomNavigation();
  final CommunityNavigation _communityNavigation = CommunityNavigation();

  // Контроллеры для вкладок
  late TabController _tabController;
  final List<String> _mainTabs = ['Все комнаты', 'Сообщества'];

  // Пример данных сообществ с улучшенной структурой
  final List<Community> _communities = [
    Community(
      id: '1',
      name: 'Крутые бобры',
      description: 'Сообщество для обсуждения технологий и программирования',
      imageUrl: '',
      category: 'Технологии',
      memberCount: 3456,
      onlineCount: 127,
      tags: ['технологии', 'программирование', 'IT'],
      isUserMember: true,
      isPrivate: false,
      creatorId: 'user1',
      creatorName: 'Алексей',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      rooms: [
        Room(
          id: '1-1',
          title: 'Общий чат',
          description: 'Основной чат для общения',
          imageUrl: '',
          currentParticipants: 89,
          messageCount: 15700,
          isJoined: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastActivity: DateTime.now().subtract(const Duration(minutes: 17)),
          category: RoomCategory.technology,
          creatorId: 'user1',
          creatorName: 'Алексей',
          tags: ['общение'],
          maxParticipants: 5000,
          isActive: true,
          rating: 4.8,
          ratingCount: 234,
          accessLevel: RoomAccessLevel.public,
          hasPendingInvite: false,
        ),
        Room(
          id: '1-2',
          title: 'Помощь новичкам',
          description: 'Помощь новичкам и ответы на вопросы',
          imageUrl: '',
          currentParticipants: 23,
          messageCount: 4500,
          isJoined: true,
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
          category: RoomCategory.technology,
          creatorId: 'user1',
          creatorName: 'Алексей',
          tags: ['помощь', 'вопросы'],
          maxParticipants: 100,
          isActive: true,
          rating: 4.9,
          ratingCount: 156,
          accessLevel: RoomAccessLevel.public,
          hasPendingInvite: false,
        ),
      ],
      stats: const CommunityStats(
        totalMessages: 20200,
        dailyActiveUsers: 89,
        weeklyActiveUsers: 567,
        weeklyGrowth: 0.12,
        newMembersThisWeek: 45,
        roomsCreated: 2,
        eventsHosted: 3,
      ),
      settings: const CommunitySettings(
        allowUserRooms: true,
        requireApproval: false,
        enableModeration: true,
        enableEvents: true,
        showOnlineMembers: true,
        allowFileSharing: true,
        maxRoomSize: 5000,
      ),
      level: CommunityLevel.advanced,
      isVerified: true,
    ),
    Community(
      id: '2',
      name: 'Давай жить дружно',
      description: 'Общение, знакомства, социальные проекты и волонтерство',
      imageUrl: '',
      category: 'Социальное',
      memberCount: 1890,
      onlineCount: 45,
      tags: ['общение', 'знакомства', 'волонтерство'],
      isUserMember: false,
      isPrivate: false,
      creatorId: 'user2',
      creatorName: 'Мария',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      rooms: [
        Room(
          id: '2-1',
          title: 'Знакомства',
          description: 'Знакомства и общение',
          imageUrl: '',
          currentParticipants: 67,
          messageCount: 8900,
          isJoined: false,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
          category: RoomCategory.social,
          creatorId: 'user2',
          creatorName: 'Мария',
          tags: ['знакомства', 'общение'],
          maxParticipants: 100,
          isActive: true,
          rating: 4.7,
          ratingCount: 89,
          accessLevel: RoomAccessLevel.public,
          hasPendingInvite: false,
        ),
      ],
      stats: const CommunityStats(
        totalMessages: 8900,
        dailyActiveUsers: 67,
        weeklyActiveUsers: 234,
        weeklyGrowth: 0.08,
        newMembersThisWeek: 23,
        roomsCreated: 1,
        eventsHosted: 1,
      ),
      settings: const CommunitySettings(
        allowUserRooms: true,
        requireApproval: false,
        enableModeration: true,
        enableEvents: false,
        showOnlineMembers: true,
        allowFileSharing: true,
        maxRoomSize: 100,
      ),
      level: CommunityLevel.intermediate,
      isVerified: false,
    ),
    Community(
      id: '3',
      name: 'Путешественники',
      description: 'Обмен опытом путешествий и советы туристам',
      imageUrl: '',
      category: 'Путешествия',
      memberCount: 890,
      onlineCount: 23,
      tags: ['путешествия', 'туризм', 'советы'],
      isUserMember: true,
      isPrivate: false,
      creatorId: 'user3',
      creatorName: 'Дмитрий',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      rooms: [
        Room(
          id: '3-1',
          title: 'Советы путешественникам',
          description: 'Полезные советы для путешествий',
          imageUrl: '',
          currentParticipants: 34,
          messageCount: 1200,
          isJoined: true,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
          category: RoomCategory.travel,
          creatorId: 'user3',
          creatorName: 'Дмитрий',
          tags: ['советы', 'путешествия'],
          maxParticipants: 200,
          isActive: true,
          rating: 4.6,
          ratingCount: 45,
          accessLevel: RoomAccessLevel.public,
          hasPendingInvite: false,
        ),
      ],
      stats: const CommunityStats(
        totalMessages: 1200,
        dailyActiveUsers: 34,
        weeklyActiveUsers: 156,
        weeklyGrowth: 0.15,
        newMembersThisWeek: 67,
        roomsCreated: 1,
        eventsHosted: 0,
      ),
      settings: const CommunitySettings(
        allowUserRooms: true,
        requireApproval: false,
        enableModeration: true,
        enableEvents: true,
        showOnlineMembers: true,
        allowFileSharing: true,
        maxRoomSize: 200,
      ),
      level: CommunityLevel.beginner,
      isVerified: false,
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupEventListeners();
    _loadInitialData();
  }

  void _initializeControllers() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _quickActionsFabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _tabController = TabController(
      length: _mainTabs.length,
      vsync: this,
    );
  }

  void _setupEventListeners() {
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomsWithDelay();
      _fabAnimationController.forward();
    });
  }

  Future<void> _loadRoomsWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      context.read<RoomProvider>().loadRooms();
    }
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final showThreshold = 100.0;

    if (scrollOffset > showThreshold && !_showQuickActionsFab) {
      setState(() {
        _showQuickActionsFab = true;
      });
      _quickActionsFabController.forward();
    } else if (scrollOffset <= showThreshold && _showQuickActionsFab) {
      _quickActionsFabController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showQuickActionsFab = false;
          });
        }
      });
    }
  }

  void _onSearchChanged() {
    final roomProvider = context.read<RoomProvider>();
    roomProvider.setSearchQuery(_searchController.text);
  }

  void _toggleSearchExpanded() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (_isSearchExpanded) {
      _searchAnimationController.forward();
      _searchFocusNode.requestFocus();
    } else {
      _searchAnimationController.reverse();
      _searchFocusNode.unfocus();
      _searchController.clear();
      context.read<RoomProvider>().setSearchQuery('');
    }
  }

  Future<void> _refreshRooms() async {
    final roomProvider = context.read<RoomProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Обновление комнат...'),
        duration: Duration(seconds: 2),
      ),
    );

    await roomProvider.loadRooms();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Обновлено ${roomProvider.filteredRooms.length} комнат'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openChatPage(Room room) {
    _roomNavigation.openChatPage(
      context: context,
      room: room,
      userName: context.read<UserProvider>().userName,
    );
  }

  void _openCommunityDetail(Community community) {
    _communityNavigation.openCommunityDetail(
      context: context,
      community: community,
      selectedTab: 0,
    );
  }

  void _createNewCommunity() {
    _communityNavigation.createNewCommunity(context);
  }

  void _joinCommunity(Community community) {
    _communityNavigation.joinCommunity(context, community);
  }

  void _leaveCommunity(Community community) {
    _communityNavigation.leaveCommunity(context, community);
  }

  // Методы-обертки для вызовов навигации с контекстом
  void _showQuickActionsMenu() {
    _roomNavigation.showQuickActionsMenu(context);
  }

  void _createNewRoom() {
    _roomNavigation.createNewRoom(context);
  }

  void _showStatsDialog() {
    _roomNavigation.showStatsDialog(context);
  }

  void _showSortDialog() {
    _roomNavigation.showSortDialog(context);
  }

  void _showAdvancedFilters() {
    _roomNavigation.showAdvancedFilters(context);
  }

  void _showRoomQuickActions(Room room) {
    _roomNavigation.showRoomQuickActions(context, room);
  }

  // Виджет для вкладок
  Widget _buildMainTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _mainTabs.map((tab) => Tab(text: tab)).toList(),
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        indicatorColor: Theme.of(context).primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    _quickActionsFabController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final roomProvider = context.watch<RoomProvider>();
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: _tabController.index == 0
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showQuickActionsFab)
            QuickActionsFab(
              controller: _quickActionsFabController,
              onPressed: _showQuickActionsMenu,
            ),
          const SizedBox(height: 8),
          MainFab(
            controller: _fabAnimationController,
            roomProvider: roomProvider,
            onPressed: _createNewRoom,
          ),
        ],
      )
          : FloatingActionButton(
        onPressed: _createNewCommunity,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Вкладки
            _buildMainTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Вкладка "Все комнаты"
                  RefreshIndicator(
                    onRefresh: _refreshRooms,
                    color: theme.primaryColor,
                    backgroundColor: theme.colorScheme.surface,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        RoomsAppBar(
                          roomProvider: roomProvider,
                          userProvider: userProvider,
                          isSearchExpanded: _isSearchExpanded,
                          onLogout: widget.onLogout,
                          onStatsPressed: _showStatsDialog,
                          onSortPressed: _showSortDialog,
                        ),
                        CategorySection(
                          roomProvider: roomProvider,
                          isSearchExpanded: _isSearchExpanded,
                        ),
                        SearchSection(
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                          isSearchExpanded: _isSearchExpanded,
                          onToggleSearch: _toggleSearchExpanded,
                          onShowFilters: _showAdvancedFilters,
                        ),
                        FiltersSection(
                          roomProvider: roomProvider,
                          searchController: _searchController,
                          isSearchExpanded: _isSearchExpanded,
                        ),
                        StatsSection(
                          roomProvider: roomProvider,
                          isSearchExpanded: _isSearchExpanded,
                          onTap: _showStatsDialog,
                        ),
                        RoomsGridSection(
                          roomProvider: roomProvider,
                          isSearchExpanded: _isSearchExpanded,
                          onRoomTap: _openChatPage,
                          onRoomLongPress: _showRoomQuickActions,
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80), // Отступ для FAB
                        ),
                      ],
                    ),
                  ),
                  // Вкладка "Сообщества"
                  CommunitiesSection(
                    communities: _communities,
                    onCommunityTap: _openCommunityDetail,
                    onCreateCommunity: _createNewCommunity,
                    onJoinCommunity: _joinCommunity,
                    onLeaveCommunity: _leaveCommunity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}