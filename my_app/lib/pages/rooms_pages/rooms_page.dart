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
  bool _showQuickActionsFab = false;
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _quickActionsFabController;
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

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _quickActionsFabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scrollController.addListener(_onScroll);

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

  void _createNewRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateRoomBottomSheet(
        onRoomCreated: _onRoomCreated,
      ),
    );
  }

  void _onRoomCreated(Room newRoom) {

    // Показываем уведомление о успешном создании
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Комната "${newRoom.title}" создана!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Плавно скроллим к началу, чтобы показать новую комнату
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }



  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersBottomSheet(
        onFiltersApplied: () {
          if (mounted) {
            setState(() {});
          }
        },
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
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sort_rounded, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Сортировка комнат',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...RoomSortBy.values.map((sortBy) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: roomProvider.sortBy == sortBy
                              ? theme.primaryColor.withOpacity(0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: roomProvider.sortBy == sortBy
                                ? theme.primaryColor.withOpacity(0.1)
                                : theme.colorScheme.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            sortBy.icon,
                            color: roomProvider.sortBy == sortBy
                                ? theme.primaryColor
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          sortBy.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: roomProvider.sortBy == sortBy
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          sortBy.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        trailing: roomProvider.sortBy == sortBy
                            ? Icon(
                          Icons.check_circle_rounded,
                          color: theme.primaryColor,
                        )
                            : null,
                        onTap: () {
                          roomProvider.setSortBy(sortBy);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: const Text('Закрыть'),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  void _showQuickActionsMenu() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flash_on_rounded, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Быстрые действия',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildQuickActionItem(
                        icon: Icons.add_rounded,
                        label: 'Создать',
                        color: theme.primaryColor,
                        onTap: _createNewRoom,
                      ),
                      _buildQuickActionItem(
                        icon: Icons.tune_rounded,
                        label: 'Фильтры',
                        color: Colors.blue,
                        onTap: _showAdvancedFilters,
                      ),
                      _buildQuickActionItem(
                        icon: Icons.sort_rounded,
                        label: 'Сортировка',
                        color: Colors.green,
                        onTap: _showSortDialog,
                      ),
                      _buildQuickActionItem(
                        icon: Icons.analytics_rounded,
                        label: 'Статистика',
                        color: Colors.orange,
                        onTap: _showStatsDialog,
                      ),
                      _buildQuickActionItem(
                        icon: Icons.notifications_rounded,
                        label: 'Уведомления',
                        color: Colors.purple,
                        onTap: _showNotifications,
                      ),
                      _buildQuickActionItem(
                        icon: Icons.refresh_rounded,
                        label: 'Обновить',
                        color: Colors.teal,
                        onTap: _refreshRooms,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: const Text('Закрыть'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshRooms() async {
    final roomProvider = context.read<RoomProvider>();

    // Показываем индикатор загрузки
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

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      surfaceTintColor: color.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Уведомления',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildNotificationItem(
                    icon: Icons.people_rounded,
                    title: 'Приглашения в комнаты',
                    subtitle: 'Уведомления о новых приглашениях',
                    enabled: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.schedule_rounded,
                    title: 'Напоминания о начале',
                    subtitle: 'За 15 минут до начала обсуждения',
                    enabled: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.message_rounded,
                    title: 'Новые сообщения',
                    subtitle: 'В избранных комнатах',
                    enabled: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.trending_up_rounded,
                    title: 'Популярные обсуждения',
                    subtitle: 'Рекомендации по активности',
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            foregroundColor: theme.colorScheme.onSurface,
                            side: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: const Text('Закрыть'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (value) {},
          activeColor: theme.primaryColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
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
            ScaleTransition(
              scale: _quickActionsFabController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  onPressed: _showQuickActionsMenu,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  mini: true,
                  child: const Icon(Icons.flash_on_rounded, size: 20),
                ),
              ),
            ),
          _buildFloatingActionButton(roomProvider, theme),
        ],
      ),
      body: SafeArea( // Добавьте SafeArea здесь
        bottom: false, // Отключите снизу, если не нужно
        child: RefreshIndicator(
          onRefresh: _refreshRooms,
          color: theme.primaryColor,
          backgroundColor: theme.colorScheme.surface,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              _buildAppBar(theme, roomProvider, userProvider),
              _buildCategorySection(roomProvider, theme),
              _buildSearchSection(theme),
              _buildActiveFiltersSection(roomProvider, theme),
              _buildStatsSection(roomProvider, theme),
              _buildRoomsGrid(roomProvider, theme),
              // Добавьте пустой Sliver для дополнительного пространства снизу
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, RoomProvider roomProvider, UserProvider userProvider) {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: theme.colorScheme.surface,
      elevation: 1, // Добавьте тень для лучшего визуального разделения
      surfaceTintColor: theme.colorScheme.surfaceTint,
      // Добавьте этот параметр для лучшего поведения при скролле
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, top: 16),
        // Добавьте отступ сверху для статус бара
        expandedTitleScale: 1.1,
        title: AnimatedOpacity(
          opacity: _isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Обсуждения',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (roomProvider.filteredRooms.isNotEmpty)
                      Text(
                        '${roomProvider.filteredRooms.length} активных комнат',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.08),
                theme.colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        AnimatedOpacity(
          opacity: _isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _showStatsDialog,
            tooltip: 'Статистика',
          ),
        ),
        AnimatedOpacity(
          opacity: _isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: _showSortDialog,
            tooltip: 'Сортировка',
          ),
        ),
        AnimatedOpacity(
          opacity: _isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: _buildUserAvatar(theme, userProvider),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildUserAvatar(ThemeData theme, UserProvider userProvider) {
    return GestureDetector(
      onTap: _showUserProfile,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: theme.primaryColor,
          child: Text(
            userProvider.userName.isNotEmpty
                ? userProvider.userName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategorySection(RoomProvider roomProvider, ThemeData theme) {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isSearchExpanded ? 0 : null,
        // Добавьте ограничение минимальной высоты
        constraints: _isSearchExpanded
            ? const BoxConstraints(maxHeight: 0)
            : const BoxConstraints(minHeight: 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: RoomCategory.values.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: CategoryChip(
                  category: category,
                  isSelected: roomProvider.selectedCategory == category,
                  onSelected: () => roomProvider.setCategory(category),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isSearchExpanded ? 70 : 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_isSearchExpanded ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isSearchExpanded ? 0.15 : 0.1),
                blurRadius: _isSearchExpanded ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Поиск по названию, тегам, автору...',
              prefixIcon: IconButton(
                icon: Icon(_isSearchExpanded ? Icons.arrow_back_rounded : Icons.search_rounded),
                onPressed: _toggleSearchExpanded,
              ),
              suffixIcon: _buildSearchSuffix(),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_isSearchExpanded ? 20 : 16),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isSearchExpanded ? 0 : null,
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
    if (roomProvider.filteredRooms.isEmpty || _isSearchExpanded) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GestureDetector(
          onTap: _showStatsDialog,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withOpacity(0.05),
                    theme.colorScheme.surface,
                  ],
                ),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.analytics, size: 20, color: theme.primaryColor),
                  ),
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
                          '${stats['totalRooms']} комнат • ${stats['totalParticipants']} участников • ${stats['activeNow']} онлайн',
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
    if (roomProvider.isLoading && roomProvider.filteredRooms.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Загрузка комнат...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
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
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
        top: 8, // Добавьте верхний отступ для фиксированного AppBar
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.crossAxisExtent;
          final crossAxisCount = maxWidth > 1000
              ? 4
              : maxWidth > 800
              ? 3
              : maxWidth > 600
              ? 2
              : 1;
          final childAspectRatio = maxWidth > 1000
              ? 0.9
              : maxWidth > 800
              ? 0.85
              : maxWidth > 600
              ? 0.75
              : 1.1;

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
    final hasActiveFilters = roomProvider.searchQuery.isNotEmpty ||
        roomProvider.selectedCategory != RoomCategory.all ||
        roomProvider.hasActiveAdvancedFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActiveFilters ? Icons.search_off_rounded : Icons.forum_outlined,
                size: 60,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _getEmptyStateTitle(roomProvider, hasActiveFilters),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getEmptyStateMessage(roomProvider, hasActiveFilters),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            if (!hasActiveFilters)
              FilledButton.icon(
                onPressed: _createNewRoom,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Создать обсуждение'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (hasActiveFilters) ...[
              FilledButton(
                onPressed: roomProvider.resetAllFilters,
                child: const Text('Сбросить фильтры'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _createNewRoom,
                child: const Text('Создать комнату для этой темы'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getEmptyStateTitle(RoomProvider roomProvider, bool hasActiveFilters) {
    if (hasActiveFilters) return 'Ничего не найдено';
    if (roomProvider.selectedCategory != RoomCategory.all) return 'Категория пуста';
    return 'Обсуждения не найдены';
  }

  String _getEmptyStateMessage(RoomProvider roomProvider, bool hasActiveFilters) {
    if (hasActiveFilters) {
      return 'Попробуйте изменить параметры поиска или сбросить фильтры для просмотра всех доступных комнат';
    }
    if (roomProvider.selectedCategory != RoomCategory.all) {
      return 'В этой категории пока нет обсуждений. Будьте первым, кто создаст комнату!';
    }
    return 'Пока нет активных обсуждений. Создайте первую комнату и начните общение!';
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
        child: Badge(
          isLabelVisible: roomProvider.hasNewInvites,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          label: const Text('!'),
          offset: const Offset(4, -4),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
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

  void _showQuickActions(Room room) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.quickreply_rounded, color: theme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Быстрые действия',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _buildQuickRoomActionItem(
                        icon: Icons.info_outline_rounded,
                        label: 'Инфо',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          _showRoomPreview(room);
                        },
                      ),
                      _buildQuickRoomActionItem(
                        icon: Icons.link_rounded,
                        label: 'Ссылка',
                        color: Colors.green,
                        onTap: () {
                          Navigator.pop(context);
                          _copyRoomLink(room);
                        },
                      ),
                      if (room.canEdit(userId))
                        _buildQuickRoomActionItem(
                          icon: Icons.edit_rounded,
                          label: 'Редакт.',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.pop(context);
                            _editRoom(room);
                          },
                        ),
                      if (room.canPin(userId))
                        _buildQuickRoomActionItem(
                          icon: Icons.push_pin_rounded,
                          label: room.isPinned ? 'Открепить' : 'Закрепить',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pop(context);
                            _pinRoom(room.id);
                          },
                        ),
                      _buildQuickRoomActionItem(
                        icon: Icons.notifications_rounded,
                        label: 'Напомнить',
                        color: Colors.teal,
                        onTap: () {
                          Navigator.pop(context);
                          _setRoomReminder(room);
                        },
                      ),
                      _buildQuickRoomActionItem(
                        icon: Icons.share_rounded,
                        label: 'Поделиться',
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.pop(context);
                          _shareRoom(room);
                        },
                      ),
                      _buildQuickRoomActionItem(
                        icon: Icons.people_rounded,
                        label: 'Участники',
                        color: Colors.cyan,
                        onTap: () {
                          Navigator.pop(context);
                          _showRoomParticipants(room);
                        },
                      ),
                      _buildQuickRoomActionItem(
                        icon: Icons.report_rounded,
                        label: 'Пожаловаться',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _reportRoom(room);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: const Text('Закрыть'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoomActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      surfaceTintColor: color.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(Room room, UserProvider userProvider) {
    final passwordController = TextEditingController();
    final userId = userProvider.userId;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Text('Защищённая комната'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Эта комната защищена паролем. Введите пароль для входа:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.password_rounded),
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility_rounded),
                  onPressed: () {
                    // TODO: Toggle password visibility
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Обратитесь к создателю комнаты, если забыли пароль',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (room.hasAccess(userId, inputPassword: passwordController.text)) {
                Navigator.pop(context);
                _openChatPage(room);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Неверный пароль'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }

  void _editRoom(Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Редактировать комнату',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Функция редактирования находится в разработке. Скоро вы сможете:'),
            const SizedBox(height: 12),
            _buildFeatureItem('Изменить название и описание комнаты'),
            _buildFeatureItem('Настроить параметры приватности'),
            _buildFeatureItem('Обновить теги и категорию'),
            _buildFeatureItem('Управлять участниками'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Редактирование "${room.title}" запущено'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Открыть черновик'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _shareRoom(Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на "${room.title}" скопирована в буфер обмена'),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _pinRoom(String roomId) {
    final roomProvider = context.read<RoomProvider>();
    final room = roomProvider.getRoomById(roomId);

    if (room != null) {
      roomProvider.togglePinRoom(roomId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(room.isPinned
              ? 'Комната "${room.title}" закреплена'
              : 'Комната "${room.title}" откреплена'),
          backgroundColor: room.isPinned ? Colors.green : Colors.blue,
        ),
      );
    }
  }

  void _setRoomReminder(Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Напоминание для "${room.title}" установлено'),
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
        content: Text('Ссылка на "${room.title}" скопирована в буфер обмена'),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showRoomParticipants(Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Text('Участники комнаты'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"${room.title}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: theme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${room.currentParticipants} из ${room.maxParticipants} участников',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Функция управления участниками в разработке'),
            ],
          ),
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

  void _reportRoom(Room room) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.report_rounded, color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Пожаловаться на комнату',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '"${room.title}"',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Выберите причину жалобы:'),
                  const SizedBox(height: 16),
                  ...[
                    _buildReportReason('Спам', 'Некорректная реклама, рассылка',
                        Icons.block_rounded),
                    _buildReportReason('Неуместный контент',
                        'Оскорбления, нецензурная лексика', Icons.warning_rounded),
                    _buildReportReason('Нарушение правил',
                        'Нарушение правил сообщества', Icons.gavel_rounded),
                    _buildReportReason(
                        'Мошенничество', 'Обман, ввод в заблуждение', Icons.security_rounded),
                    _buildReportReason('Другое', 'Иная причина', Icons.more_horiz_rounded),
                  ].map((widget) => Column(
                    children: [
                      widget,
                      const SizedBox(height: 8),
                    ],
                  )).toList(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            foregroundColor: theme.colorScheme.onSurface,
                            side: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _submitReport(room, 'Выбранная причина');
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Пожаловаться'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportReason(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: Radio(
          value: title,
          groupValue: null,
          onChanged: (value) {},
          activeColor: Colors.red,
        ),
        onTap: () {
          // Обработка выбора причины
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  void _submitReport(Room room, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Жалоба на "${room.title}" отправлена'),
            Text(
              'Причина: $reason',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAccessDeniedDialog(Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.private_connectivity_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Text('Приватная комната'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Эта комната является приватной. Для получения доступа необходимо:'),
            const SizedBox(height: 12),
            _buildAccessItem('Быть приглашённым создателем комнаты'),
            _buildAccessItem('Иметь специальную ссылку-приглашение'),
            _buildAccessItem('Получить разрешение от модератора'),
            const SizedBox(height: 8),
            Text(
              'Обратитесь к создателю комнаты для получения доступа',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showRoomPreview(room);
            },
            child: const Text('Посмотреть информацию'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showRoomFullDialog(Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people_alt_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text('Комната заполнена'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'В комнате достигнут лимит участников (${room.maxParticipants}).',
            ),
            const SizedBox(height: 8),
            const Text('Попробуйте зайти позже или найдите другую комнату.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _setRoomReminder(room);
            },
            child: const Text('Установить напоминание'),
          ),
        ],
      ),
    );
  }

  void _showScheduledRoomDialog(Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Text('Комната запланирована'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text('Комната начнётся ${room.formattedStartTime}.'),
            const SizedBox(height: 8),
            const Text('Вы можете установить напоминание или подождать начала.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _setRoomReminder(room);
            },
            child: const Text('Напомнить'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showRoomPreview(room);
            },
            child: const Text('Информация'),
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