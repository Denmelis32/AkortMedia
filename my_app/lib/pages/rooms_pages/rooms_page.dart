import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import '../communities/communities_page.dart';
import '../communities/models/community.dart';
import 'models/room.dart';
import 'models/room_category.dart';
import 'models/filter_option.dart';

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
  final Set<String> _activeFilters = {};
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

  // Опции фильтрации (оставляем только фильтры)
  final List<FilterOption> _filterOptions = [
    FilterOption(
        id: 'active', title: 'Только активные', icon: Icons.online_prediction),
    FilterOption(id: 'joined', title: 'Мои комнаты', icon: Icons.subscriptions),
    FilterOption(id: 'favorites', title: 'Избранное', icon: Icons.favorite),
  ];

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
    final userProvider = context.read<UserProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatPage(
            ),
      ),
    );
  }

  void _createNewRoom() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Создать комнату'),
            content: const Text(
                'Функционал создания комнаты будет реализован позже'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // НОВЫЙ МЕТОД: Открытие сообщества из комнаты
  void _openCommunityFromRoom(Room room) {
    // Если у комнаты есть сообщество, открываем его
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Сообщество комнаты'),
            content: Text('Переход в сообщество комнаты "${room.title}"'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрыть'),
              ),
            ],
          ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Открытие страницы сообществ
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

  // НОВЫЙ МЕТОД: Показать опции комнаты
  void _showRoomOptions(BuildContext context, Room room) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (room.hasCommunity)
                  ListTile(
                    leading: const Icon(Icons.group, color: Colors.blue),
                    title: const Text('Перейти в сообщество'),
                    onTap: () {
                      Navigator.pop(context);
                      _openCommunityFromRoom(room);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.green),
                  title: const Text('Информация о комнате'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRoomInfo(room);
                  },
                ),
                ListTile(
                  leading: Icon(
                    room.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: Colors.orange,
                  ),
                  title: Text(room.isPinned ? 'Открепить' : 'Закрепить'),
                  onTap: () {
                    Navigator.pop(context);
                    _togglePinRoom(room);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.purple),
                  title: const Text('Поделиться комнатой'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareRoom(room);
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.grey),
                  title: const Text('Закрыть'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _showRoomInfo(Room room) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(room.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Описание: ${room.description}'),
                  const SizedBox(height: 8),
                  Text('Категория: ${room.category.title}'),
                  const SizedBox(height: 8),
                  Text('Участников: ${room.currentParticipants}/${room
                      .maxParticipants}'),
                  const SizedBox(height: 8),
                  Text('Сообщений: ${room.messageCount}'),
                  const SizedBox(height: 8),
                  Text('Рейтинг: ${room.rating.toStringAsFixed(1)} (${room
                      .ratingCount} оценок)'),
                  const SizedBox(height: 8),
                  Text('Статус: ${room.status}'),
                  if (room.hasCommunity) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Принадлежит сообществу',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

  void _togglePinRoom(Room room) {
    final roomProvider = context.read<RoomProvider>();
    roomProvider.togglePinRoom(room.id);
  }

  void _shareRoom(Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Поделиться "${room.title}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ 3 КАРТОЧЕК В РЯД
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    if (width > 1200) return 3;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getCardAspectRatio(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1:
        return 0.75;
      case 2:
        return 0.8;
      case 3:
        return 0.85;
      default:
        return 0.8;
    }
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 16;
  }

  double _getCoverHeight(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1:
        return 140;
      case 2:
        return 130;
      case 3:
        return 120;
      default:
        return 130;
    }
  }

  double _getAvatarSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1:
        return 55;
      case 2:
        return 50;
      case 3:
        return 45;
      default:
        return 50;
    }
  }

  double _getTitleFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1:
        return 17;
      case 2:
        return 16;
      case 3:
        return 15;
      default:
        return 16;
    }
  }

  double _getDescriptionFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1:
        return 13;
      case 2:
        return 12;
      case 3:
        return 11;
      default:
        return 12;
    }
  }

  double _getStatFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1:
        return 11;
      case 2:
        return 10;
      case 3:
        return 9;
      default:
        return 10;
    }
  }

  // ФИЛЬТРАЦИЯ (без сортировки)
  List<Room> _getFilteredRooms(RoomProvider roomProvider) {
    return roomProvider.filteredRooms.where(_matchesFilters).toList();
  }

  bool _matchesFilters(Room room) {
    if (_selectedCategoryId != 'all' &&
        room.category?.id != _selectedCategoryId) {
      return false;
    }

    if (_activeFilters.contains('active') && !room.isActive) return false;
    if (_activeFilters.contains('joined') && !room.isJoined) return false;

    if (_searchQuery.isNotEmpty) {
      return room.title.toLowerCase().contains(_searchQuery) ||
          room.description.toLowerCase().contains(_searchQuery) ||
          room.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }

    return true;
  }

  // ОСНОВНОЙ ДИЗАЙН КАРТОЧКИ КОМНАТЫ
  Widget _buildRoomCard(Room room, int index, RoomProvider roomProvider) {
    final crossAxisCount = _getCrossAxisCount(context);
    final coverHeight = _getCoverHeight(context);
    final avatarSize = _getAvatarSize(context);
    final titleFontSize = _getTitleFontSize(context);
    final descriptionFontSize = _getDescriptionFontSize(context);
    final statFontSize = _getStatFontSize(context);

    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openChatPage(room),
          onLongPress: () => _showRoomOptions(context, room),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: coverHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(room.imageUrl.isNotEmpty
                            ? room.imageUrl
                            : 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -avatarSize * 0.3,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: avatarSize * 0.5,
                          backgroundColor: Theme
                              .of(context)
                              .primaryColor,
                          child: Text(
                            room.creatorName.isNotEmpty
                                ? room.creatorName[0].toUpperCase()
                                : 'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: avatarSize * 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        room.category?.title ?? 'Общее',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  if (room.hasCommunity)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _openCommunityFromRoom(room),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                  Icons.group, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Сообщество',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (room.isPinned)
                    Positioned(
                      top: room.hasCommunity ? 30 : 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.push_pin,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: avatarSize * 0.3),

              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: crossAxisCount >= 2 ? 12 : 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Text(
                          room.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        child: Text(
                          room.creatorName,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          room.description,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: _getDescriptionMaxLines(crossAxisCount),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '${room.currentParticipants}',
                                'участников',
                                fontSize: statFontSize,
                              ),
                            ),
                            Container(
                                width: 1, height: 20, color: Colors.grey[300]),
                            Expanded(
                              child: _buildStatItem(
                                '${room.messageCount}',
                                'сообщений',
                                fontSize: statFontSize,
                              ),
                            ),
                            Container(
                                width: 1, height: 20, color: Colors.grey[300]),
                            Expanded(
                              child: _buildStatItem(
                                room.rating.toStringAsFixed(1),
                                'рейтинг',
                                fontSize: statFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: () => _openChatPage(room),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: room.isJoined ? Colors
                                    .grey[100] : Theme
                                    .of(context)
                                    .primaryColor,
                                foregroundColor: room.isJoined ? Colors
                                    .grey[700] : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: room.isJoined
                                        ? Colors.grey[300]!
                                        : Theme
                                        .of(context)
                                        .primaryColor,
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: _getButtonPadding(context)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    room.isJoined ? Icons.chat : Icons.login,
                                    size: crossAxisCount >= 2 ? 16 : 18,
                                  ),
                                  SizedBox(width: crossAxisCount >= 2 ? 6 : 8),
                                  Text(
                                    room.isJoined
                                        ? 'Открыть чат'
                                        : 'Войти в комнату',
                                    style: TextStyle(
                                      fontSize: statFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (room.hasCommunity) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                onPressed: () => _openCommunityFromRoom(room),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue[50],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.blue[100]!),
                                  ),
                                  padding: EdgeInsets.all(
                                      _getButtonPadding(context)),
                                ),
                                icon: Icon(
                                  Icons.group,
                                  size: crossAxisCount >= 2 ? 16 : 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (room.hasCommunity) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _openCommunityFromRoom(room),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.group, size: 12,
                                    color: Colors.blue[700]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Часть сообщества',
                                    style: TextStyle(
                                      fontSize: statFontSize - 1,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 10,
                                    color: Colors.blue[700]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getDescriptionMaxLines(int crossAxisCount) {
    switch (crossAxisCount) {
      case 1:
        return 3;
      case 2:
        return 2;
      case 3:
        return 2;
      default:
        return 2;
    }
  }

  double _getButtonPadding(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1:
        return 12;
      case 2:
        return 10;
      case 3:
        return 8;
      default:
        return 10;
    }
  }

  Widget _buildStatItem(String value, String label,
      {required double fontSize}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: fontSize - 1,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _filterOptions.map(_buildFilterChip).toList(),
                ),
              ),
            ],
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
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _categories
                      .asMap()
                      .entries
                      .map((entry) {
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

  Widget _buildCategoryChip(RoomCategory category) {
    final isSelected = _selectedCategoryId == category.id;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => setState(() => _selectedCategoryId = category.id),
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
                Icon(category.icon, size: 16,
                    color: isSelected ? Colors.white : category.color),
                const SizedBox(width: 6),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildFilterChip(FilterOption filter) {
    final isActive = _activeFilters.contains(filter.id);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isActive) {
                _activeFilters.remove(filter.id);
              } else {
                _activeFilters.add(filter.id);
              }
            });
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
                Icon(filter.icon, size: 16,
                    color: isActive ? Colors.white : Colors.blue),
                const SizedBox(width: 6),
                Text(
                  filter.title,
                  style: TextStyle(
                    fontSize: 13,
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
          hintText: 'Поиск комнат...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
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
                  // AppBar как в ArticlesPage
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
                                Expanded(child: _buildSearchField()),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.close, color: Colors.black,
                                        size: 18),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
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
                                  child: const Icon(
                                      Icons.groups_rounded, color: Colors.black,
                                      size: 18),
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
                                  child: const Icon(
                                      Icons.search, color: Colors.black,
                                      size: 18),
                                ),
                                onPressed: () =>
                                    setState(() => _showSearchBar = true),
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
                                    _showFilters ? Icons.filter_alt_off : Icons
                                        .filter_alt,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                                onPressed: () =>
                                    setState(() =>
                                    _showFilters = !_showFilters),
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
                            child: _showFilters ? _buildFiltersCard(
                                horizontalPadding) : const SizedBox.shrink(),
                          ),

                          SliverToBoxAdapter(
                            child: _buildCategoriesCard(horizontalPadding),
                          ),

                          if (filteredRooms.isEmpty)
                            SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, size: 40,
                                        color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Комнаты не найдены',
                                      style: TextStyle(fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Попробуйте изменить параметры поиска',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding, vertical: 8),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _getCrossAxisCount(context),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: _getCardAspectRatio(
                                      context),
                                ),
                                delegate: SliverChildBuilderDelegate(
                                      (context, index) =>
                                      _buildRoomCard(
                                          filteredRooms[index], index,
                                          roomProvider),
                                  childCount: filteredRooms.length,
                                ),
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
          floatingActionButton: FloatingActionButton(
            onPressed: _createNewRoom,
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add, size: 24),
          ),
        );
      },
    );
  }

// Добавь этот метод для определения мобильного устройства
  bool _isMobile(BuildContext context) {
    return MediaQuery
        .of(context)
        .size
        .width <= 600;
  }
}