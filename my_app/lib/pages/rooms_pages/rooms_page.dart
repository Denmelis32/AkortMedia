import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import 'models/room.dart';
import 'models/room_category.dart';
import 'models/sort_option.dart';
import 'models/filter_option.dart';
import 'widgets/create_room_button.dart';
import 'widgets/app_bar.dart';
import 'widgets/categories_section.dart';
import 'widgets/filters_section.dart';
import 'widgets/rooms_grid.dart';
import 'utils/layout_utils.dart';
import 'utils/room_utils.dart';

class AdaptiveRoomsPage extends StatefulWidget {
  final VoidCallback onLogout;

  const AdaptiveRoomsPage({
    super.key,
    required this.onLogout,
  });

  @override
  State<AdaptiveRoomsPage> createState() => _AdaptiveRoomsPageState();
}

class _AdaptiveRoomsPageState extends State<AdaptiveRoomsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  String _selectedSort = 'newest';
  final Set<String> _activeFilters = {};
  bool _isLoading = false;
  bool _showSearchBar = false;
  bool _showFilters = false;
  bool _isMounted = false;

  final RoomUtils _roomUtils = RoomUtils();
  final LayoutUtils _layoutUtils = LayoutUtils();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomsWithDelay();
    });
  }

  Future<void> _loadRoomsWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_isMounted) {
      context.read<RoomProvider>().loadRooms();
    }
  }

  void _onSearchChanged() {
    if (!_isMounted) return;
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  Future<void> _refreshRooms() async {
    if (!_isMounted) return;
    setState(() => _isLoading = true);
    await context.read<RoomProvider>().loadRooms();
    if (_isMounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openChatPage(Room room) {
    if (!_roomUtils.checkRoomAccess(context, room)) {
      return;
    }

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

  void _toggleRoomJoin(Room room, RoomProvider roomProvider) {
    if (!_isMounted) return;

    if (!_roomUtils.checkRoomAccessForJoin(context, room)) {
      return;
    }

    roomProvider.toggleJoinRoom(room.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          room.isJoined
              ? '✅ Присоединились к комнате ${room.title}'
              : '❌ Покинули комнату ${room.title}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Room> _getFilteredRooms(RoomProvider roomProvider) {
    final rooms = roomProvider.filteredRooms.where(_matchesFilters).toList();
    _roomUtils.sortRooms(rooms, _selectedSort);
    return rooms;
  }

  bool _matchesFilters(Room room) {
    if (_selectedCategoryId != 'all' && room.category.id != _selectedCategoryId) {
      return false;
    }

    if (_activeFilters.contains('active') && room.currentParticipants == 0) return false;
    if (_activeFilters.contains('joined') && !room.isJoined) return false;

    if (_searchQuery.isNotEmpty) {
      return room.title.toLowerCase().contains(_searchQuery) ||
          room.description.toLowerCase().contains(_searchQuery) ||
          room.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }

    return true;
  }

  void _showSortBottomSheet() {
    if (!_isMounted) return;

    final sortOptions = [
      SortOption(id: 'newest', title: 'Сначала новые', icon: Icons.new_releases),
      SortOption(id: 'popular', title: 'По популярности', icon: Icons.trending_up),
      SortOption(id: 'participants', title: 'По участникам', icon: Icons.people),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: _layoutUtils.surfaceColor,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _layoutUtils.textColor),
            ),
            const SizedBox(height: 16),
            ...sortOptions.map((option) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _layoutUtils.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, size: 20, color: _layoutUtils.primaryColor),
              ),
              title: Text(
                option.title,
                style: TextStyle(fontSize: 15, color: _layoutUtils.textColor, fontWeight: FontWeight.w500),
              ),
              trailing: _selectedSort == option.id
                  ? Icon(Icons.check, color: _layoutUtils.primaryColor, size: 20)
                  : null,
              onTap: () {
                if (!_isMounted) return;
                setState(() => _selectedSort = option.id);
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
  void dispose() {
    _isMounted = false;
    _searchController.dispose();
    _scrollController.dispose();
    _roomUtils.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        final horizontalPadding = _layoutUtils.getHorizontalPadding(context);
        final isMobile = _layoutUtils.isMobile(context);
        final filteredRooms = _getFilteredRooms(roomProvider);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: RoomsAppBar(
            searchController: _searchController,
            showSearchBar: _showSearchBar,
            onSearchBarToggle: (value) => setState(() => _showSearchBar = value),
            layoutUtils: _layoutUtils,
            onSortPressed: _showSortBottomSheet,
            onFilterToggle: () => setState(() => _showFilters = !_showFilters),
            showFilters: _showFilters,
            title: 'Комнаты',
          ),
          body: Container(
            constraints: BoxConstraints(
              minWidth: _layoutUtils.minContentWidth,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _layoutUtils.backgroundColor,
                  _layoutUtils.backgroundColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: isMobile
                  ? _buildMobileLayout(horizontalPadding, roomProvider, filteredRooms)
                  : _layoutUtils.buildDesktopLayout(_buildDesktopContent(horizontalPadding, roomProvider, filteredRooms)),
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
                    backgroundColor: _layoutUtils.primaryColor,
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

  Widget _buildMobileLayout(double horizontalPadding, RoomProvider roomProvider, List<Room> rooms) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildMobileContent(roomProvider, horizontalPadding, rooms),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(RoomProvider roomProvider, double horizontalPadding, List<Room> rooms) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: FiltersSection(
            showFilters: _showFilters,
            activeFilters: _activeFilters,
            onFilterToggle: (filterId) {
              setState(() {
                if (_activeFilters.contains(filterId)) {
                  _activeFilters.remove(filterId);
                } else {
                  _activeFilters.add(filterId);
                }
              });
            },
            layoutUtils: _layoutUtils,
            isMobile: true,
          ),
        ),
        SliverToBoxAdapter(
          child: CategoriesSection(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (categoryId) => setState(() => _selectedCategoryId = categoryId),
            layoutUtils: _layoutUtils,
            isMobile: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            color: Colors.grey.shade100,
          ),
        ),
        RoomsGrid(
          rooms: rooms,
          roomProvider: roomProvider,
          horizontalPadding: horizontalPadding,
          isMobile: true,
          onRoomTap: _openChatPage,
          onRoomJoinToggle: _toggleRoomJoin,
          layoutUtils: _layoutUtils,
          roomUtils: _roomUtils,
        ),
      ],
    );
  }

  Widget _buildDesktopContent(double horizontalPadding, RoomProvider roomProvider, List<Room> rooms) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildDesktopContentBody(horizontalPadding, roomProvider, rooms),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContentBody(double horizontalPadding, RoomProvider roomProvider, List<Room> rooms) {
    return _layoutUtils.buildDesktopLayout(
      CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FiltersSection(
              showFilters: _showFilters,
              activeFilters: _activeFilters,
              onFilterToggle: (filterId) {
                setState(() {
                  if (_activeFilters.contains(filterId)) {
                    _activeFilters.remove(filterId);
                  } else {
                    _activeFilters.add(filterId);
                  }
                });
              },
              layoutUtils: _layoutUtils,
              isMobile: false,
            ),
          ),
          SliverToBoxAdapter(
            child: CategoriesSection(
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (categoryId) => setState(() => _selectedCategoryId = categoryId),
              layoutUtils: _layoutUtils,
              isMobile: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              color: Colors.grey.shade100,
            ),
          ),
          RoomsGrid(
            rooms: rooms,
            roomProvider: roomProvider,
            horizontalPadding: horizontalPadding,
            isMobile: false,
            onRoomTap: _openChatPage,
            onRoomJoinToggle: _toggleRoomJoin,
            layoutUtils: _layoutUtils,
            roomUtils: _roomUtils,
          ),
        ],
      ),
    );
  }
}