import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
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
  final Map<String, dynamic> _expensiveComputationCache = {};

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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showQuickActionsFab)
            QuickActionsFab(
              controller: _quickActionsFabController,
              onPressed: _showQuickActionsMenu, // Используем обертку
            ),
          MainFab(
            controller: _fabAnimationController,
            roomProvider: roomProvider,
            onPressed: _createNewRoom, // Используем обертку
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
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
                onStatsPressed: _showStatsDialog, // Используем обертку
                onSortPressed: _showSortDialog, // Используем обертку
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
                onShowFilters: _showAdvancedFilters, // Используем обертку
              ),
              FiltersSection(
                roomProvider: roomProvider,
                searchController: _searchController,
                isSearchExpanded: _isSearchExpanded,
              ),
              StatsSection(
                roomProvider: roomProvider,
                isSearchExpanded: _isSearchExpanded,
                onTap: _showStatsDialog, // Используем обертку
              ),
              RoomsGridSection(
                roomProvider: roomProvider,
                isSearchExpanded: _isSearchExpanded,
                onRoomTap: _openChatPage,
                onRoomLongPress: _showRoomQuickActions, // Используем обертку
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}