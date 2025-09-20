// lib/pages/rooms_pages/rooms_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'chat_page.dart';
import 'models/room.dart';
import '../../providers/room_provider.dart';
import '../../services/room_service.dart';
import 'widgets/room_card.dart';
import 'widgets/category_chip.dart';
import 'widgets/search_filter_chip.dart';
import 'create_room_bottom_sheet.dart';
import 'advanced_filters_bottom_sheet.dart';
import 'user_profile_dialog.dart';

class RoomsPage extends StatefulWidget {
  final VoidCallback onLogout;

  const RoomsPage({
    super.key,
    required this.onLogout,
  });

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabScrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<RoomProvider>().setSearchQuery(_searchController.text);
  }

  void _createNewRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateRoomBottomSheet(),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AdvancedFiltersBottomSheet(),
    );
  }

  void _showUserProfile() {
    showDialog(
      context: context,
      builder: (context) => UserProfileDialog(onLogout: widget.onLogout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: _buildFloatingActionButton(),
      body: RefreshIndicator(
        onRefresh: () => roomProvider.loadRooms(),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildAppBar(),
              _buildSearchSection(),
              _buildFilterChipsSection(roomProvider),
            ];
          },
          body: _buildRoomGrid(roomProvider),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Text(
        'Обсуждения',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
          tooltip: 'Уведомления',
        ),
        _buildUserAvatar(),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildCategoryTabs(),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: _showUserProfile,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue,
          child: Text(
            'U',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final roomProvider = context.read<RoomProvider>();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: RoomCategory.values.map((category) {
            return CategoryChip(
              category: category,
              isSelected: roomProvider.selectedCategory == category,
              onSelected: () => roomProvider.setCategory(category),
            );
          }).toList(),
        ),
      ),
    );
  }

  SliverPadding _buildSearchSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Поиск обсуждений...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _buildSearchSuffixIcon(),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSearchSuffixIcon() {
    final roomProvider = context.read<RoomProvider>();

    if (_searchController.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          _searchController.clear();
          roomProvider.setSearchQuery('');
        },
      );
    }

    return IconButton(
      icon: const Icon(Icons.filter_alt_outlined),
      onPressed: _showAdvancedFilters,
      tooltip: 'Расширенные фильтры',
    );
  }

  SliverToBoxAdapter _buildFilterChipsSection(RoomProvider roomProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (roomProvider.selectedCategory != RoomCategory.all)
              SearchFilterChip(
                label: 'Категория: ${roomProvider.selectedCategory.title}',
                color: Theme.of(context).colorScheme.primary,
                onRemove: () => roomProvider.setCategory(RoomCategory.all),
              ),
            if (roomProvider.searchQuery.isNotEmpty)
              SearchFilterChip(
                label: 'Поиск: "${roomProvider.searchQuery}"',
                color: Colors.green,
                onRemove: () {
                  _searchController.clear();
                  roomProvider.setSearchQuery('');
                },
              ),
            if (roomProvider.showJoinedOnly)
              SearchFilterChip(
                label: 'Только мои обсуждения',
                color: Colors.orange,
                onRemove: () => roomProvider.toggleShowJoinedOnly(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomGrid(RoomProvider roomProvider) {
    if (roomProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final rooms = roomProvider.filteredRooms;

    if (rooms.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return RoomCard(
          room: room,
          onTap: () => _openChatPage(room),
          onJoin: () => roomProvider.toggleJoinRoom(room.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'Обсуждения не найдены',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить параметры поиска',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _createNewRoom,
            child: const Text('Создать первое обсуждение'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _createNewRoom,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  void _openChatPage(Room room) {
    final userProvider = context.read<UserProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
          userName: userProvider.userName,
        ),
      ),
    );
  }
}

// Расширение для форматирования чисел
extension NumberFormatting on int {
  String formatCount() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}