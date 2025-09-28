import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'chat_page.dart';
import 'models/room.dart';
import 'models/room_filters.dart';
import '../../providers/room_provider.dart';
import 'widgets/animated_room_card.dart';
import 'widgets/category_chip.dart';
import 'widgets/search_filter_chip.dart';
import 'widgets/tag_chip.dart';
import 'create_room_bottom_sheet.dart';
import 'advanced_filters_bottom_sheet.dart';
import 'user_profile_dialog.dart';
import 'widgets/room_stats_dialog.dart';
import 'widgets/room_preview_dialog.dart';

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
  late AnimationController _fabAnimationController;
  final Map<String, dynamic> _expensiveComputationCache = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<RoomProvider>().setSearchQuery(_searchController.text);
  }

  void _createNewRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateRoomBottomSheet(),
    ).then((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersBottomSheet(
        onFiltersApplied: () => setState(() {}),
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
              subtitle: Text(sortBy.description),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
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

  void _showQuickActions(Room room) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                    title: const Text('Информация о комнате'),
                    onTap: () {
                      Navigator.pop(context);
                      _showRoomPreview(room);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.link, color: Theme.of(context).primaryColor),
                    title: const Text('Копировать ссылку'),
                    onTap: () {
                      Navigator.pop(context);
                      _copyRoomLink(room);
                    },
                  ),
                  if (room.canEdit(userId))
                    ListTile(
                      leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                      title: const Text('Редактировать'),
                      onTap: () {
                        Navigator.pop(context);
                        _editRoom(room);
                      },
                    ),
                  if (room.canPin(userId))
                    ListTile(
                      leading: Icon(Icons.push_pin, color: Theme.of(context).primaryColor),
                      title: Text(room.isPinned ? 'Открепить' : 'Закрепить'),
                      onTap: () {
                        Navigator.pop(context);
                        _pinRoom(room.id);
                      },
                    ),
                  ListTile(
                    leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                    title: const Text('Установить напоминание'),
                    onTap: () {
                      Navigator.pop(context);
                      _setRoomReminder(room);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.share, color: Theme.of(context).primaryColor),
                    title: const Text('Поделиться'),
                    onTap: () {
                      Navigator.pop(context);
                      _shareRoom(room);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.report, color: Colors.red),
                    title: const Text('Пожаловаться'),
                    onTap: () {
                      Navigator.pop(context);
                      _reportRoom(room);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.close, color: Colors.grey),
                    title: const Text('Отмена'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRoomPreview(Room room) {
    showDialog(
      context: context,
      builder: (context) => RoomPreviewDialog(
        room: room,
        onJoin: () => _openChatPage(room),
      ),
    );
  }

  void _copyRoomLink(Room room) {
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

  void _setRoomReminder(Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Напоминание для "${room.title}" установлено'),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Уведомления'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Система уведомлений в разработке'),
            SizedBox(height: 16),
            Text('Будут доступны:'),
            ListTile(
              leading: Icon(Icons.people, size: 16),
              title: Text('Приглашения в комнаты'),
            ),
            ListTile(
              leading: Icon(Icons.schedule, size: 16),
              title: Text('Напоминания о начале обсуждений'),
            ),
            ListTile(
              leading: Icon(Icons.message, size: 16),
              title: Text('Новые сообщения в избранных комнатах'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
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

  void _showPasswordDialog(Room room, UserProvider userProvider) {
    final passwordController = TextEditingController();
    final userId = userProvider.userId;

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
                _openChatPage(room);
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final roomProvider = context.watch<RoomProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: _buildFloatingActionButton(roomProvider, theme),
      body: RefreshIndicator(
        onRefresh: () async => roomProvider.loadRooms(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(theme, roomProvider),
            _buildCategorySection(roomProvider, theme),
            _buildSearchSection(theme),
            _buildActiveFiltersSection(roomProvider, theme),
            _buildStatsSection(roomProvider, theme),
            _buildRoomsGrid(roomProvider, theme),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, RoomProvider roomProvider) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, top: 16),
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
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
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
        _buildUserAvatar(theme),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildUserAvatar(ThemeData theme) {
    final userProvider = context.read<UserProvider>();

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
        child: CircleAvatar(
          radius: 16,
          backgroundColor: theme.primaryColor,
          child: Text(
            userProvider.userName.isNotEmpty
                ? userProvider.userName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategorySection(RoomProvider roomProvider, ThemeData theme) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: RoomCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CategoryChip(
                category: category,
                isSelected: roomProvider.selectedCategory == category,
                onSelected: () => roomProvider.setCategory(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Поиск по названию, тегам, автору...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _buildSearchSuffix(),
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

  Widget _buildSearchSuffix() {
    final roomProvider = context.read<RoomProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              _searchController.clear();
              roomProvider.setSearchQuery('');
            },
          ),
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          onPressed: _showAdvancedFilters,
          tooltip: 'Расширенные фильтры',
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildActiveFiltersSection(RoomProvider roomProvider, ThemeData theme) {
    final activeFilters = _getActiveFilters(roomProvider, theme);

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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: roomProvider.resetAllFilters,
                  child: const Text('Сбросить все'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
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

  List<Widget> _getActiveFilters(RoomProvider roomProvider, ThemeData theme) {
    final filters = <Widget>[];

    if (roomProvider.selectedCategory != RoomCategory.all) {
      filters.add(SearchFilterChip(
        label: 'Категория: ${roomProvider.selectedCategory.title}',
        color: theme.primaryColor,
        onRemove: () => roomProvider.setCategory(RoomCategory.all),
      ));
    }

    if (roomProvider.searchQuery.isNotEmpty) {
      filters.add(SearchFilterChip(
        label: 'Поиск: "${roomProvider.searchQuery}"',
        color: Colors.green,
        onRemove: () {
          _searchController.clear();
          roomProvider.setSearchQuery('');
        },
      ));
    }

    if (roomProvider.showJoinedOnly) {
      filters.add(SearchFilterChip(
        label: 'Только мои обсуждения',
        color: Colors.orange,
        onRemove: () => roomProvider.toggleShowJoinedOnly(),
      ));
    }

    return filters;
  }

  SliverToBoxAdapter _buildStatsSection(RoomProvider roomProvider, ThemeData theme) {
    final stats = roomProvider.getRoomStats();
    if (roomProvider.filteredRooms.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GestureDetector(
          onTap: _showStatsDialog,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics, size: 20, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статистика сообщества',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${stats['totalRooms']} комнат, ${stats['totalParticipants']} участников',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomsGrid(RoomProvider roomProvider, ThemeData theme) {
    if (roomProvider.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(theme.primaryColor),
          ),
        ),
      );
    }

    final rooms = roomProvider.filteredRooms;

    if (rooms.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(roomProvider, theme),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.crossAxisExtent;
          final crossAxisCount = maxWidth > 800 ? 3 : maxWidth > 600 ? 2 : 1;
          final childAspectRatio = maxWidth > 800 ? 0.85 : maxWidth > 600 ? 0.75 : 1.1;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final room = rooms[index];
                return AnimatedRoomCard(
                  room: room,
                  index: index,
                  onTap: () => _openChatPage(room),
                  onJoin: () => roomProvider.toggleJoinRoom(room.id),
                  onLongPress: () => _showQuickActions(room),
                );
              },
              childCount: rooms.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(RoomProvider roomProvider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyStateTitle(roomProvider),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getEmptyStateMessage(roomProvider),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _createNewRoom,
              icon: const Icon(Icons.add),
              label: const Text('Создать обсуждение'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateTitle(RoomProvider roomProvider) {
    if (roomProvider.searchQuery.isNotEmpty) return 'Ничего не найдено';
    if (roomProvider.selectedCategory != RoomCategory.all) return 'Категория пуста';
    return 'Обсуждения не найдены';
  }

  String _getEmptyStateMessage(RoomProvider roomProvider) {
    if (roomProvider.searchQuery.isNotEmpty) {
      return 'Попробуйте изменить поисковый запрос или сбросить фильтры';
    }
    if (roomProvider.selectedCategory != RoomCategory.all) {
      return 'В этой категории пока нет обсуждений';
    }
    return 'Будьте первым, кто создаст обсуждение в этом сообществе';
  }

  Widget _buildFloatingActionButton(RoomProvider roomProvider, ThemeData theme) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutBack,
      ),
      child: FloatingActionButton(
        onPressed: _createNewRoom,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  void _openChatPage(Room room) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId;

    if (room.requiresPassword) {
      _showPasswordDialog(room, userProvider);
      return;
    }

    if (room.accessLevel == RoomAccessLevel.private && !room.hasAccess(userId)) {
      _showAccessDeniedDialog(room);
      return;
    }

    if (room.isFull) {
      _showRoomFullDialog(room);
      return;
    }

    if (room.isScheduled && !room.isExpired) {
      _showScheduledRoomDialog(room);
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          room: room,
          userName: userProvider.userName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
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