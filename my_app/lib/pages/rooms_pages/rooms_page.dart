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
import 'widgets/room_stats_dialog.dart';

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
      builder: (context) => AdvancedFiltersBottomSheet(
        onFiltersApplied: () => setState(() {}), // Исправлено
      ),
    );
  }

  void _showUserProfile() {
    showDialog(
      context: context,
      builder: (context) => UserProfileDialog(onLogout: widget.onLogout),
    );
  }

  void _showSortDialog() {
    final roomProvider = context.read<RoomProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сортировка комнат'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RoomSortBy.values.map((sortBy) {
            return ListTile(
              leading: Icon(sortBy.icon, color: Theme.of(context).primaryColor),
              title: Text(sortBy.title),
              trailing: roomProvider.sortBy == sortBy
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                roomProvider.setSortBy(sortBy);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => RoomStatsDialog(
        stats: context.read<RoomProvider>().getRoomStats(),
      ),
    );
  }

  void _editRoom(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать "${room.title}"'),
        content: const Text('Функция редактирования в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareRoom(Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на "${room.title}" скопирована'),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {},
        ),
      ),
    );
  }

  void _pinRoom(String roomId) {
    context.read<RoomProvider>().togglePinRoom(roomId);
  }

  void _reportRoom(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на комнату'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите причину жалобы:'),
            const SizedBox(height: 16),
            ...['Спам', 'Неуместный контент', 'Нарушение правил', 'Другое']
                .map((reason) => ListTile(
              title: Text(reason),
              leading: const Icon(Icons.report),
              onTap: () {
                Navigator.pop(context);
                _submitReport(room, reason);
              },
            ))
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _submitReport(Room room, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Жалоба на "${room.title}" отправлена'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final theme = Theme.of(context); // Получаем theme из контекста

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: _buildFloatingActionButton(roomProvider, theme),
      body: RefreshIndicator(
        onRefresh: () => roomProvider.loadRooms(),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildAppBar(theme, roomProvider),
              _buildSearchSection(theme),
              _buildFilterChipsSection(roomProvider, theme),
              _buildStatsSection(roomProvider, theme),
            ];
          },
          body: _buildRoomGrid(roomProvider, theme),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, RoomProvider roomProvider) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Обсуждения',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withOpacity(0.1),
                theme.primaryColor.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: _showStatsDialog,
          tooltip: 'Статистика',
        ),
        IconButton(
          icon: const Icon(Icons.sort_rounded),
          onPressed: _showSortDialog,
          tooltip: 'Сортировка',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
          tooltip: 'Уведомления',
        ),
        _buildUserAvatar(theme),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildCategoryTabs(roomProvider, theme),
      ),
    );
  }

  Widget _buildUserAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: _showUserProfile,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
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

  Widget _buildCategoryTabs(RoomProvider roomProvider, ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
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

  SliverPadding _buildSearchSection(ThemeData theme) {
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          onPressed: _showAdvancedFilters,
          tooltip: 'Расширенные фильтры',
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildFilterChipsSection(RoomProvider roomProvider, ThemeData theme) {
    final activeFilters = [
      if (roomProvider.selectedCategory != RoomCategory.all)
        SearchFilterChip(
          label: 'Категория: ${roomProvider.selectedCategory.title}',
          color: theme.primaryColor,
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
      if (!roomProvider.showActiveOnly)
        SearchFilterChip(
          label: 'Показывать неактивные',
          color: Colors.grey,
          onRemove: () => roomProvider.toggleShowActiveOnly(),
        ),
    ];

    if (activeFilters.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Активные фильтры:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: roomProvider.resetFilters,
                  child: const Text('Сбросить все'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activeFilters,
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStatsSection(RoomProvider roomProvider, ThemeData theme) {
    final stats = roomProvider.getRoomStats();
    if (roomProvider.filteredRooms.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              _buildStatItem(Icons.forum, '${stats['totalRooms']}', 'Комнат', theme),
              _buildStatItem(Icons.people, '${stats['activeRooms']}', 'Активных', theme),
              _buildStatItem(Icons.star, '${stats['averageRating']}', 'Рейтинг', theme),
              _buildStatItem(Icons.push_pin, '${stats['pinnedRooms']}', 'Закреп.', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomGrid(RoomProvider roomProvider, ThemeData theme) {
    if (roomProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final rooms = roomProvider.filteredRooms;

    if (rooms.isEmpty) {
      return _buildEmptyState(roomProvider, theme);
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
          onEdit: () => _editRoom(room),
          onShare: () => _shareRoom(room),
          onPin: () => _pinRoom(room.id),
          onReport: () => _reportRoom(room),
        );
      },
    );
  }

  Widget _buildEmptyState(RoomProvider roomProvider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'Обсуждения не найдены',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(roomProvider),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _createNewRoom,
                  child: const Text('Создать обсуждение'),
                ),
                OutlinedButton(
                  onPressed: roomProvider.resetFilters,
                  child: const Text('Сбросить фильтры'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateMessage(RoomProvider roomProvider) {
    if (roomProvider.searchQuery.isNotEmpty) {
      return 'Попробуйте изменить поисковый запрос или сбросить фильтры';
    }
    if (roomProvider.selectedCategory != RoomCategory.all) {
      return 'В этой категории пока нет обсуждений';
    }
    if (roomProvider.showJoinedOnly) {
      return 'Вы еще не присоединились ни к одному обсуждению';
    }
    return 'Будьте первым, кто создаст обсуждение в этом сообществе';
  }

  Widget _buildFloatingActionButton(RoomProvider roomProvider, ThemeData theme) {
    return FloatingActionButton(
      onPressed: _createNewRoom,
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      child: Badge(
        isLabelVisible: roomProvider.getScheduledRooms().isNotEmpty,
        label: Text(roomProvider.getScheduledRooms().length.toString()),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  void _openChatPage(Room room) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId; // Получаем userId из провайдера

    // Проверка доступа для защищенных комнат
    if (room.requiresPassword) {
      _showPasswordDialog(room, userProvider);
      return;
    }

    // Проверка доступа для приватных комнат
    if (room.accessLevel == RoomAccessLevel.private &&
        !room.hasAccess(userId)) { // Используем полученный userId
      _showAccessDeniedDialog(room);
      return;
    }

    // Проверка на заполненность комнаты
    if (room.isFull) {
      _showRoomFullDialog(room);
      return;
    }

    // Проверка на запланированную комнату
    if (room.isScheduled && !room.isExpired) {
      _showScheduledRoomDialog(room);
      return;
    }

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

  void _showPasswordDialog(Room room, UserProvider userProvider) {
    final passwordController = TextEditingController();
    final userId = userProvider.userId; // Получаем userId

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Вход в "${room.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Эта комната защищена паролем'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (room.hasAccess(userId, inputPassword: passwordController.text)) {
                Navigator.pop(context);
                _openChatPage(room.copyWith(
                  // Временный доступ после ввода пароля
                  accessLevel: RoomAccessLevel.public,
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Неверный пароль')),
                );
              }
            },
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }

  void _showAccessDeniedDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Доступ ограничен'),
        content: Text('Комната "${room.title}" является приватной. Обратитесь к создателю для получения доступа.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRoomFullDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Комната заполнена'),
        content: Text('В комнате "${room.title}" достигнут лимит участников (${room.maxParticipants}).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showScheduledRoomDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Комната запланирована'),
        content: Text('Комната "${room.title}" начнется ${room.formattedStartTime}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Напоминание установлено')),
              );
            },
            child: const Text('Напомнить'),
          ),
        ],
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