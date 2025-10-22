import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import '../communities/communities_page.dart';
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

class _AdaptiveRoomsPageState extends State<AdaptiveRoomsPage> {
  // Контроллеры
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Состояние
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  String _selectedSort = 'newest';
  final Set<String> _activeFilters = {};
  bool _isLoading = false;
  bool _showSearchBar = false;
  bool _showFilters = false;
  bool _isMounted = false;

  // БИРЮЗОВАЯ ЦВЕТОВАЯ СХЕМА КАК В CARDS_PAGE
  final Color _primaryColor = const Color(0xFF26A69A); // Основной бирюзовый
  final Color _secondaryColor = const Color(0xFF80CBC4); // Светло-бирюзовый
  final Color _backgroundColor = const Color(0xFFF5F7FA); // Светлый фон
  final Color _surfaceColor = Colors.white; // Цвет поверхностей
  final Color _textColor = const Color(0xFF37474F); // Темно-серый для текста

  // Мягкие бирюзовые градиенты для карточек
  final List<Color> _cardGradients = [
    const Color(0xFFE0F2F1), // Светло-бирюзовый
    const Color(0xFFE0F7FA), // Светло-голубой
    const Color(0xFFE8F5E8), // Светло-зеленый
    const Color(0xFFF3E5F5), // Светло-фиолетовый
    const Color(0xFFFFF3E0), // Светло-оранжевый
    const Color(0xFFE3F2FD), // Светло-синий
    const Color(0xFFEDE7F6), // Светло-лавандовый
    const Color(0xFFFFF8E1), // Светло-желтый
  ];

  final List<Color> _cardBorderColors = [
    const Color(0xFF80CBC4), // Бирюзовый
    const Color(0xFF4DB6AC), // Средний бирюзовый
    const Color(0xFF26A69A), // Основной бирюзовый
    const Color(0xFF00897B), // Темный бирюзовый
    const Color(0xFF80DEEA), // Светло-голубой
    const Color(0xFF4DD0E1), // Голубой
    const Color(0xFF26C6DA), // Бирюзово-голубой
    const Color(0xFF00ACC1), // Сине-бирюзовый
  ];

  // Категории комнат
  final List<RoomCategory> _categories = [
    RoomCategory(id: 'all', title: 'Все', icon: Icons.explore, color: const Color(0xFF26A69A)),
    RoomCategory(id: 'technology', title: 'Технологии', icon: Icons.memory, color: Colors.orange),
    RoomCategory(id: 'business', title: 'Бизнес', icon: Icons.business_center, color: const Color(0xFF9C27B0)),
    RoomCategory(id: 'education', title: 'Образование', icon: Icons.school, color: Colors.teal),
    RoomCategory(id: 'entertainment', title: 'Развлечения', icon: Icons.movie, color: Colors.pink),
    RoomCategory(id: 'sports', title: 'Спорт', icon: Icons.sports_soccer, color: Colors.red),
    RoomCategory(id: 'music', title: 'Музыка', icon: Icons.music_note, color: Colors.green),
  ];

  // Опции сортировки
  final List<SortOption> _sortOptions = [
    SortOption(id: 'newest', title: 'Сначала новые', icon: Icons.new_releases),
    SortOption(id: 'popular', title: 'По популярности', icon: Icons.trending_up),
    SortOption(id: 'participants', title: 'По участникам', icon: Icons.people),
  ];

  // Опции фильтрации
  final List<FilterOption> _filterOptions = [
    FilterOption(id: 'active', title: 'Только активные', icon: Icons.online_prediction),
    FilterOption(id: 'joined', title: 'Мои комнаты', icon: Icons.subscriptions),
  ];

  // ФИКСИРОВАННАЯ МАКСИМАЛЬНАЯ ШИРИНА ДЛЯ ДЕСКТОПА
  double get _maxContentWidth => 1200;
  double get _minContentWidth => 320;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _setupEventListeners();
    _loadInitialData();
  }

  void _setupEventListeners() {
    _searchController.addListener(_onSearchChanged);
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

  // АДАПТИВНЫЕ МЕТОДЫ КАК В CARDS_PAGE
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // ШИРИНА КОНТЕНТА С УЧЕТОМ ОГРАНИЧЕНИЙ
  double _getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > _maxContentWidth) return _maxContentWidth;
    return screenWidth;
  }

  int _getCrossAxisCount(BuildContext context) {
    final contentWidth = _getContentWidth(context);
    if (contentWidth > 1000) return 3;
    if (contentWidth > 700) return 2;
    return 1;
  }

  // АДАПТИВНЫЕ ОТСТУПЫ
  double _getHorizontalPadding(BuildContext context) {
    final contentWidth = _getContentWidth(context);
    if (contentWidth > 1000) return 24;
    if (contentWidth > 800) return 20;
    if (contentWidth > 600) return 16;
    return 12;
  }

  // ОСНОВНОЙ LAYOUT С ФИКСИРОВАННОЙ ШИРИНОЙ
  Widget _buildDesktopLayout(Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _maxContentWidth,
          minWidth: _minContentWidth,
        ),
        child: content,
      ),
    );
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
    final rooms = roomProvider.filteredRooms.where(_matchesFilters).toList();
    _sortRooms(rooms);
    return rooms;
  }

  bool _matchesFilters(Room room) {
    // Категория
    if (_selectedCategoryId != 'all' && room.category.id != _selectedCategoryId) {
      return false;
    }

    // Активные фильтры
    if (_activeFilters.contains('active') && room.currentParticipants == 0) return false;
    if (_activeFilters.contains('joined') && !room.isJoined) return false;

    // Поиск
    if (_searchQuery.isNotEmpty) {
      return room.title.toLowerCase().contains(_searchQuery) ||
          room.description.toLowerCase().contains(_searchQuery) ||
          room.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }

    return true;
  }

  void _sortRooms(List<Room> rooms) {
    switch (_selectedSort) {
      case 'newest':
        rooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popular':
        rooms.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
      case 'participants':
        rooms.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
        break;
    }
  }

  // Получение цвета для карточки
  Color _getCardColor(int index) {
    return _cardGradients[index % _cardGradients.length];
  }

  Color _getCardBorderColor(int index) {
    return _cardBorderColors[index % _cardBorderColors.length];
  }

  // Вспомогательные методы для безопасного доступа к данным
  RoomCategory _getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return RoomCategory(id: 'unknown', title: 'Неизвестно', icon: Icons.help, color: Colors.grey);
    }
  }

  String _getCategoryTitle(String categoryId) {
    return _getCategoryById(categoryId).title;
  }

  IconData _getCategoryIcon(String categoryId) {
    return _getCategoryById(categoryId).icon;
  }

  Color _getCategoryColor(String categoryId) {
    return _getCategoryById(categoryId).color;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // ПОСТРОЕНИЕ КАРТОЧКИ КОМНАТЫ В СТИЛЕ CARDS_PAGE
  Widget _buildRoomCard(Room room, int index, RoomProvider roomProvider) {
    return _isMobile(context)
        ? _buildMobileRoomCard(room, index, roomProvider)
        : _buildDesktopRoomCard(room, index, roomProvider);
  }

  Widget _buildMobileRoomCard(Room room, int index, RoomProvider roomProvider) {
    final categoryColor = _getCategoryColor(room.category.id);
    final categoryIcon = _getCategoryIcon(room.category.id);
    final categoryTitle = _getCategoryTitle(room.category.id);
    final cardColor = _getCardColor(index);
    final borderColor = _getCardBorderColor(index);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openChatPage(room),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ОБЛОЖКА КОМНАТЫ
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: _buildRoomCover(room),
                      ),
                    ),
                    // Категория в левом верхнем углу
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcon,
                              size: 14,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              categoryTitle.toUpperCase(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Онлайн статус
                    if (room.currentParticipants > 0)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${room.currentParticipants} онлайн',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // ОСНОВНОЙ КОНТЕНТ
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок и аватар
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Аватарка
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildRoomAvatar(room),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Название и описание
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _textColor,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  room.creatorName.isNotEmpty ? room.creatorName : 'Создатель комнаты',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _textColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Описание комнаты
                      Text(
                        room.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textColor.withOpacity(0.8),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // ХЕШТЕГИ
                      if (room.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: room.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: borderColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // СТАТИСТИКА И КНОПКИ
                      Row(
                        children: [
                          // Статистика
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  _formatNumber(room.currentParticipants),
                                  'участников',
                                  icon: Icons.people_outline,
                                  color: borderColor,
                                ),
                                _buildStatItem(
                                  room.messageCount.toString(),
                                  'сообщений',
                                  icon: Icons.chat_bubble_outline,
                                  color: borderColor,
                                ),
                                _buildStatItem(
                                  room.ratingCount.toString(),
                                  'лайков',
                                  icon: Icons.thumb_up,
                                  color: borderColor,
                                ),
                              ],
                            ),
                          ),
                          // Кнопка присоединения
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: room.isJoined
                                  ? Colors.white.withOpacity(0.8)
                                  : _primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: room.isJoined
                                    ? borderColor.withOpacity(0.5)
                                    : _primaryColor,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => _toggleRoomJoin(room, roomProvider),
                              icon: Icon(
                                room.isJoined ? Icons.check : Icons.add,
                                size: 18,
                                color: room.isJoined
                                    ? borderColor
                                    : Colors.white,
                              ),
                              padding: EdgeInsets.zero,
                              style: IconButton.styleFrom(
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      ),
    );
  }

  Widget _buildDesktopRoomCard(Room room, int index, RoomProvider roomProvider) {
    // ФИКСИРОВАННЫЕ РАЗМЕРЫ КАК В CARDS_PAGE
    final double cardWidth = 360.0;
    final double fixedCardHeight = 460;

    final cardColor = _getCardColor(index);
    final borderColor = _getCardBorderColor(index);
    final categoryColor = _getCategoryColor(room.category.id);

    return Container(
      width: cardWidth,
      height: fixedCardHeight,
      margin: const EdgeInsets.all(2),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(24),
        color: cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => _openChatPage(room),
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Обложка - ФИКСИРОВАННАЯ ВЫСОТА
                    Container(
                      height: 160,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                        child: _buildRoomCover(room),
                      ),
                    ),
                    // Категория
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(room.category.id),
                              size: 14,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getCategoryTitle(room.category.id).toUpperCase(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Онлайн статус
                    if (room.currentParticipants > 0)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${room.currentParticipants} онлайн',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Аватар
                    Positioned(
                      bottom: -30,
                      left: 16,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildRoomAvatar(room),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // НАЗВАНИЕ И АВТОР
                        Text(
                          room.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.creatorName.isNotEmpty ? room.creatorName : 'Создатель комнаты',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // ОПИСАНИЕ
                        Expanded(
                          child: Text(
                            room.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: _textColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // СТАТИСТИКА
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                _formatNumber(room.currentParticipants),
                                'участников',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                room.messageCount.toString(),
                                'сообщений',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                room.ratingCount.toString(),
                                'лайков',
                                fontSize: 10,
                                color: borderColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // КНОПКА ПРИСОЕДИНЕНИЯ И ХЕШТЕГИ
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: room.tags.take(2).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: borderColor.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: borderColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // КНОПКА ПРИСОЕДИНЕНИЯ
                            Container(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () => _toggleRoomJoin(room, roomProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: room.isJoined
                                      ? Colors.white.withOpacity(0.8)
                                      : _primaryColor,
                                  foregroundColor: room.isJoined
                                      ? borderColor
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: room.isJoined
                                          ? borderColor.withOpacity(0.5)
                                          : _primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      room.isJoined ? Icons.check : Icons.add,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      room.isJoined ? 'Присоединен' : 'Присоединиться',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {double fontSize = 12, Color? color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: color,
            ),
            const SizedBox(height: 2),
          ],
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color ?? _textColor,
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
              color: (color ?? _textColor).withOpacity(0.7),
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

  Widget _buildRoomAvatar(Room room) {
    final avatarUrl = room.creatorAvatarUrl ?? 'https://via.placeholder.com/150/26A69A/ffffff?text=R';

    return Image.network(
      avatarUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        );
      },
    );
  }

  Widget _buildRoomCover(Room room) {
    final coverUrl = room.imageUrl.isNotEmpty ? room.imageUrl : 'https://via.placeholder.com/400x200/26A69A/ffffff?text=Room';

    return Image.network(
      coverUrl,
      width: double.infinity,
      height: 140,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Icon(Icons.photo_library, color: Colors.grey[600], size: 40),
        );
      },
    );
  }

  void _toggleRoomJoin(Room room, RoomProvider roomProvider) {
    if (!_isMounted) return;

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

  // ВИДЖЕТЫ ФИЛЬТРОВ И КАТЕГОРИЙ В СТИЛЕ CARDS_PAGE
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _surfaceColor,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _filterOptions.map((filter) => _buildFilterChip(filter)).toList(),
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
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _surfaceColor,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Категории',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // АДАПТИВНЫЙ СПИСОК КАТЕГОРИЙ
              if (isMobile)
                _buildMobileCategories()
              else
                _buildDesktopCategories(),
            ],
          ),
        ),
      ),
    );
  }

  // ГОРИЗОНТАЛЬНЫЙ СКРОЛЛ КАТЕГОРИЙ ДЛЯ ТЕЛЕФОНА
  Widget _buildMobileCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildMobileCategoryChip(category);
        },
      ),
    );
  }

  // КАТЕГОРИИ ДЛЯ ДЕСКТОПА
  Widget _buildDesktopCategories() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) => _buildDesktopCategoryChip(category)).toList(),
    );
  }

  Widget _buildMobileCategoryChip(RoomCategory category) {
    final isSelected = _selectedCategoryId == category.id;

    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (!_isMounted) return;
            setState(() => _selectedCategoryId = category.id);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 14,
                  color: isSelected ? Colors.white : category.color,
                ),
                const SizedBox(width: 4),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCategoryChip(RoomCategory category) {
    final isSelected = _selectedCategoryId == category.id;

    return Material(
      color: isSelected ? category.color : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          if (!_isMounted) return;
          setState(() => _selectedCategoryId = category.id);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? category.color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 16,
                color: isSelected ? Colors.white : category.color,
              ),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : _textColor,
                ),
              ),
            ],
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
        color: isActive ? _primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (!_isMounted) return;
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
                color: isActive ? _primaryColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter.icon,
                  size: 16,
                  color: isActive ? Colors.white : _primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  filter.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Виджет поля поиска
  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск комнат...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: _primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  // КОМПАКТНЫЙ APP BAR В СТИЛЕ CARDS_PAGE
  Widget _buildCompactAppBar(double horizontalPadding, bool isMobile) {
    // Вычисляем отступ для выравнивания с категориями
    final categoriesCardMargin = isMobile ? 12.0 : horizontalPadding;
    final categoriesContentPadding = isMobile ? 12.0 : 16.0;
    final categoriesTitlePadding = 4.0;

    // Общий отступ от левого края до текста "Категории"
    final totalCategoriesLeftPadding = categoriesCardMargin +
        categoriesContentPadding + categoriesTitlePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!_showSearchBar) ...[
            // Заголовок "Комнаты" с фоном и выравниванием по категориям
            Padding(
              padding: EdgeInsets.only(left: totalCategoriesLeftPadding -
                  (isMobile ? 12 : horizontalPadding)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Комнаты',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Правый контент выровненный по правому краю категорий
            Container(
              margin: EdgeInsets.only(right: totalCategoriesLeftPadding -
                  (isMobile ? 12 : horizontalPadding)),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => setState(() => _showSearchBar = true),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _showFilters
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.sort_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: _showSortBottomSheet,
                  ),
                ],
              ),
            ),
          ],

          if (_showSearchBar)
            Expanded(
              child: Row(
                children: [
                  // Поле поиска с выравниванием
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding),
                        right: 8,
                      ),
                      child: _buildSearchField(),
                    ),
                  ),
                  // Кнопка закрытия с выравниванием
                  Padding(
                    padding: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: () => setState(() {
                        _showSearchBar = false;
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showSortBottomSheet() {
    if (!_isMounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map((option) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, size: 20, color: _primaryColor),
              ),
              title: Text(
                option.title,
                style: TextStyle(fontSize: 15, color: _textColor, fontWeight: FontWeight.w500),
              ),
              trailing: _selectedSort == option.id
                  ? Icon(Icons.check, color: _primaryColor, size: 20)
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

  // Открытие страницы сообществ
  void _openCommunities() {
    final userProvider = context.read<UserProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunitiesPage(
          userName: userProvider.userName,
          userEmail: userProvider.userEmail,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        final horizontalPadding = _getHorizontalPadding(context);
        final isMobile = _isMobile(context);
        final filteredRooms = _getFilteredRooms(roomProvider);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            constraints: BoxConstraints(
              minWidth: _minContentWidth,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColor,
                  _backgroundColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: isMobile
                  ? _buildMobileLayout(horizontalPadding, roomProvider, filteredRooms)
                  : _buildDesktopLayout(_buildDesktopContent(horizontalPadding, roomProvider, filteredRooms)),
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
                    backgroundColor: _primaryColor,
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
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, true),
        // Контент
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
        // Фильтры
        SliverToBoxAdapter(child: _buildFiltersCard(horizontalPadding)),

        // Категории
        SliverToBoxAdapter(child: _buildCategoriesCard(horizontalPadding)),

        // Разделитель
        SliverToBoxAdapter(
          child: Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            color: Colors.grey.shade100,
          ),
        ),

        // Карточки комнат
        _buildRoomsGrid(roomProvider, horizontalPadding, rooms, true),
      ],
    );
  }

  Widget _buildDesktopContent(double horizontalPadding, RoomProvider roomProvider, List<Room> rooms) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, false),
        // Контент
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
    return _buildDesktopLayout(
      CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Фильтры
          SliverToBoxAdapter(child: _buildFiltersCard(horizontalPadding)),

          // Категории
          SliverToBoxAdapter(child: _buildCategoriesCard(horizontalPadding)),

          // Разделитель
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              color: Colors.grey.shade100,
            ),
          ),

          // Карточки комнат
          _buildRoomsGrid(roomProvider, horizontalPadding, rooms, false),
        ],
      ),
    );
  }

  Widget _buildRoomsGrid(RoomProvider roomProvider, double horizontalPadding, List<Room> rooms, bool isMobile) {
    if (rooms.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chat_rounded, size: 48, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Комнаты не найдены',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить параметры поиска\nили выбрать другую категорию',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ДЛЯ МОБИЛЬНЫХ - ИСПОЛЬЗУЕМ SliverList
    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= rooms.length) return const SizedBox.shrink();
            final room = rooms[index];
            return _buildRoomCard(room, index, roomProvider);
          },
          childCount: rooms.length,
        ),
      );
    }

    // ДЛЯ ПЛАНШЕТОВ И КОМПЬЮТЕРОВ - ИСПОЛЬЗУЕМ SliverGrid С ТАКИМИ ЖЕ ОТСТУПАМИ КАК В CARDS_PAGE
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 360 / 460, // ФИКСИРОВАННОЕ СООТНОШЕНИЕ как в CardsPage
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= rooms.length) return const SizedBox.shrink();
            final room = rooms[index];
            return Padding(
              padding: const EdgeInsets.all(2),
              child: _buildRoomCard(room, index, roomProvider),
            );
          },
          childCount: rooms.length,
        ),
      ),
    );
  }
}

// Класс SortOption
class SortOption {
  final String id;
  final String title;
  final IconData icon;

  const SortOption({
    required this.id,
    required this.title,
    required this.icon,
  });
}