import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../rooms_pages/models/filter_option.dart';
import '../rooms_pages/models/room_category.dart';
import '../rooms_pages/models/sort_option.dart';
import 'channel_detail_page.dart';
import 'dialogs/channel_utils.dart';
import 'models/channel.dart';
import '../../providers/channel_state_provider.dart';
import 'dialogs/create_channel_dialog.dart';

class CardsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userAvatarUrl;
  final VoidCallback onLogout;

  const CardsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userAvatarUrl,
    required this.onLogout,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
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

  // Данные
  late List<Channel> _channels;
  late final List<RoomCategory> _categories;
  late final List<SortOption> _sortOptions;
  late final List<FilterOption> _filterOptions;

  // Новые цвета - пастельная палитра
  final Color _primaryColor = const Color(0xFFFb5679); // Розовый цвет
  final Color _secondaryColor = const Color(0xFFF8BBD0); // Светло-розовый
  final Color _backgroundColor = const Color(
      0xFFF5F7FA); // Очень светлый серо-голубой
  final Color _surfaceColor = Colors.white; // Цвет поверхностей
  final Color _textColor = const Color(0xFF37474F); // Темно-серый для текста

  // Мягкие цвета для карточек
  final List<Color> _cardGradients = [
    const Color(0xFFE3F2FD), // Светло-голубой
    const Color(0xFFF3E5F5), // Светло-фиолетовый
    const Color(0xFFE8F5E8), // Светло-зеленый
    const Color(0xFFFFF3E0), // Светло-оранжевый
    const Color(0xFFFCE4EC), // Светло-розовый
    const Color(0xFFE0F2F1), // Светло-бирюзовый
    const Color(0xFFEDE7F6), // Светло-лавандовый
    const Color(0xFFFFF8E1), // Светло-желтый
  ];

  final List<Color> _cardBorderColors = [
    const Color(0xFF90CAF9), // Голубой
    const Color(0xFFCE93D8), // Фиолетовый
    const Color(0xFFA5D6A7), // Зеленый
    const Color(0xFFFFCC80), // Оранжевый
    const Color(0xFFF48FB1), // Розовый
    const Color(0xFF80CBC4), // Бирюзовый
    const Color(0xFFB39DDB), // Лавандовый
    const Color(0xFFFFE082), // Желтый
  ];

  // ФИКСИРОВАННАЯ МАКСИМАЛЬНАЯ ШИРИНА ДЛЯ ДЕСКТОПА
  double get _maxContentWidth => 1200;

  // МИНИМАЛЬНАЯ ШИРИНА ДЛЯ ЗАЩИТЫ ОТ OVERFLOW
  double get _minContentWidth => 320;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _initializeData();
    _setupListeners();

    // Добавляем слушатель изменений провайдера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChannelStateProvider>(
          context, listen: false);
      provider.addListener(_onChannelStateChanged);
    });
  }

  void _initializeData() {
    _channels = _createSampleChannels();
    _categories = _createCategories();
    _sortOptions = _createSortOptions();
    _filterOptions = _createFilterOptions();
  }

  void _setupListeners() {
    _searchController.addListener(() {
      if (!_isMounted) return;
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  void _onChannelStateChanged() {
    if (_isMounted) {
      setState(() {
        // Принудительное обновление при изменении состояния каналов
      });
    }
  }

  // Создание тестовых данных с локальными изображениями
  List<Channel> _createSampleChannels() {
    return [
      Channel(
        id: 1,
        title: 'Спортивные новости',
        description: 'Последние события в мире спорта и аналитика матчей. Эксклюзивные интервью с атлетами.',
        imageUrl: 'assets/images/cards_image/avatarka/ava2.png',
        subscribers: 17800,
        videos: 95,
        isSubscribed: true,
        isFavorite: false,
        cardColor: _cardGradients[0],
        categoryId: 'sport',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isVerified: true,
        rating: 4.6,
        views: 1980000,
        likes: 67000,
        comments: 3200,
        owner: 'Дмитрий Спортивный',
        author: 'Дмитрий Спортивный',
        authorImageUrl: 'assets/images/cards_image/avatarka/ava2.png',
        tags: ['спорт', 'новости', 'аналитика', 'матчи'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://sport-news.ru',
        socialMedia: '@sport_news',
        commentsCount: 3200,
        coverImageUrl: 'assets/images/cards_image/owner/sptort_channel.png',
      ),
      Channel(
        id: 2,
        title: 'Игровые обзоры',
        description: 'Новинки игровой индустрии и геймплей по всем платформам. Только честные обзоры!',
        imageUrl: 'assets/images/cards_image/avatarka/ava1.png',
        subscribers: 15600,
        videos: 120,
        isSubscribed: false,
        isFavorite: true,
        cardColor: _cardGradients[1],
        categoryId: 'games',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isVerified: true,
        rating: 4.9,
        views: 2100000,
        likes: 89000,
        comments: 4500,
        owner: 'Алексей Геймеров',
        author: 'Алексей Геймеров',
        authorImageUrl: 'assets/images/cards_image/avatarka/ava1.png',
        tags: ['игры', 'гейминг', 'обзоры', 'стримы'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://game-reviews.ru',
        socialMedia: '@game_reviews',
        commentsCount: 4500,
        coverImageUrl: 'assets/images/cards_image/owner/game_channel.png',
      ),
      Channel(
        id: 3,
        title: 'Акортовский Мемасник',
        description: 'Обсуждаем мемы и разные новости о МЮ.',
        imageUrl: 'assets/images/cards_image/avatarka/ava3.png',
        subscribers: 12450,
        videos: 89,
        isSubscribed: false,
        isFavorite: false,
        cardColor: _cardGradients[2],
        categoryId: 'tech',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isVerified: true,
        rating: 4.8,
        views: 1250000,
        likes: 45000,
        comments: 2300,
        owner: 'Иван Технолог',
        author: 'Иван Технолог',
        authorImageUrl: 'assets/images/cards_image/avatarka/ava3.png',
        tags: ['технологии', 'IT', 'инновации', 'робототехника'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://tech-future.ru',
        socialMedia: '@tech_future',
        commentsCount: 2300,
        coverImageUrl: 'assets/images/cards_image/owner/kote.png',
      ),
      Channel(
        id: 4,
        title: 'The Soul Channel',
        description: 'Психология, саморазвитие и духовные практики для гармоничной жизни.',
        imageUrl: 'assets/images/cards_image/avatarka/avatarka1.png',
        subscribers: 21500,
        videos: 150,
        isSubscribed: true,
        isFavorite: true,
        cardColor: _cardGradients[3],
        categoryId: 'psychology',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        isVerified: true,
        rating: 4.7,
        views: 2850000,
        likes: 92000,
        comments: 3800,
        owner: 'Мария Психологова',
        author: 'Мария Психологова',
        authorImageUrl: 'assets/images/cards_image/avatarka/avatarka1.png',
        tags: ['психология', 'саморазвитие', 'медитация', 'гармония'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://the-soul.ru',
        socialMedia: '@the_soul',
        commentsCount: 3800,
        coverImageUrl: 'assets/images/cards_image/owner/the_soul_channel.png',
      ),
      Channel(
        id: 5,
        title: 'Бизнес и финансы',
        description: 'Анализ рынков, инвестиционные стратегии и успешные кейсы бизнеса.',
        imageUrl: 'assets/images/cards_image/avatarka/avatarka2.png',
        subscribers: 18900,
        videos: 110,
        isSubscribed: false,
        isFavorite: false,
        cardColor: _cardGradients[4],
        categoryId: 'business',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        isVerified: true,
        rating: 4.5,
        views: 1670000,
        likes: 51000,
        comments: 2900,
        owner: 'Сергей Финансов',
        author: 'Сергей Финансов',
        authorImageUrl: 'assets/images/cards_image/avatarka/avatarka2.png',
        tags: ['бизнес', 'финансы', 'инвестиции', 'экономика'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://business-finance.ru',
        socialMedia: '@business_finance',
        commentsCount: 2900,
        coverImageUrl: 'assets/images/cards_image/owner/joker.png',
      ),
      Channel(
        id: 6,
        title: 'Творчество и искусство',
        description: 'Рисование, музыка, фотография и другие виды творчества. Вдохновляем и учим.',
        imageUrl: 'assets/images/cards_image/avatarka/sportAvatarka.png',
        subscribers: 13200,
        videos: 75,
        isSubscribed: true,
        isFavorite: false,
        cardColor: _cardGradients[5],
        categoryId: 'art',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        isVerified: false,
        rating: 4.4,
        views: 980000,
        likes: 38000,
        comments: 2100,
        owner: 'Анна Художникова',
        author: 'Анна Художникова',
        authorImageUrl: 'assets/images/cards_image/avatarka/sportAvatarka.png',
        tags: ['искусство', 'творчество', 'рисование', 'вдохновение'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://art-creative.ru',
        socialMedia: '@art_creative',
        commentsCount: 2100,
        coverImageUrl: 'assets/images/cards_image/owner/pingvin_pistolet.png',
      ),
    ];
  }

  List<RoomCategory> _createCategories() {
    return [
      RoomCategory(
          id: 'all', title: 'Все', icon: Icons.explore, color: _primaryColor),
      RoomCategory(id: 'sport',
          title: 'Спорт',
          icon: Icons.sports_soccer,
          color: const Color(0xFF42A5F5)),
      RoomCategory(id: 'games',
          title: 'Игры',
          icon: Icons.sports_esports,
          color: const Color(0xFF66BB6A)),
      RoomCategory(id: 'psychology',
          title: 'Психология',
          icon: Icons.psychology,
          color: const Color(0xFFAB47BC)),
      RoomCategory(id: 'tech',
          title: 'Технологии',
          icon: Icons.memory,
          color: const Color(0xFFFFA726)),
      RoomCategory(id: 'business',
          title: 'Бизнес',
          icon: Icons.business_center,
          color: const Color(0xFF26C6DA)),
      RoomCategory(id: 'art',
          title: 'Искусство',
          icon: Icons.palette,
          color: const Color(0xFFFF7043)),
    ];
  }

  List<SortOption> _createSortOptions() {
    return [
      SortOption(
          id: 'newest', title: 'Сначала новые', icon: Icons.new_releases),
      SortOption(
          id: 'popular', title: 'По популярности', icon: Icons.trending_up),
      SortOption(
          id: 'subscribers', title: 'По подписчикам', icon: Icons.people),
    ];
  }

  List<FilterOption> _createFilterOptions() {
    return [
      FilterOption(
          id: 'verified', title: 'Только проверенные', icon: Icons.verified),
      FilterOption(
          id: 'subscribed', title: 'Мои подписки', icon: Icons.subscriptions),
      FilterOption(id: 'favorites', title: 'Избранное', icon: Icons.favorite),
    ];
  }

  @override
  void dispose() {
    _isMounted = false;
    final provider = Provider.of<ChannelStateProvider>(context, listen: false);
    provider.removeListener(_onChannelStateChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // АДАПТИВНЫЕ МЕТОДЫ
  bool _isMobile(BuildContext context) {
    return MediaQuery
        .of(context)
        .size
        .width <= 600;
  }

  // ШИРИНА КОНТЕНТА С УЧЕТОМ ОГРАНИЧЕНИЙ
  double _getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
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

  // ОТСТУПЫ МЕЖДУ КАРТОЧКАМИ
  double _getGridSpacing(BuildContext context) {
    if (_isMobile(context)) return 8;
    return 6;
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

  // УЛУЧШЕННЫЕ МЕТОДЫ ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ
  Widget _buildChannelAvatar(Channel channel,
      ChannelStateProvider stateProvider, {double size = 50}) {
    final channelId = channel.id.toString();
    final customAvatar = stateProvider.getAvatarForChannel(channelId);
    final avatarUrl = customAvatar ?? channel.imageUrl;

    return ClipOval(
      child: _buildChannelImage(avatarUrl, size),
    );
  }

  Widget _buildChannelCover(Channel channel, ChannelStateProvider stateProvider,
      {double height = 120}) {
    final channelId = channel.id.toString();
    final customCover = stateProvider.getCoverForChannel(channelId);
    final coverUrl = customCover ?? channel.coverImageUrl ?? channel.imageUrl;

    return _buildChannelImage(coverUrl, height, isCover: true);
  }

  Widget _buildChannelImage(String imageUrl, double size,
      {bool isCover = false}) {
    print('🖼️ Loading channel image: $imageUrl');

    try {
      if (imageUrl.startsWith('http')) {
        // Сетевые изображения с кэшированием
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          placeholder: (context, url) =>
              _buildLoadingPlaceholder(size, isCover: isCover),
          errorWidget: (context, url, error) {
            print('❌ Network image error: $error');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      } else if (imageUrl.startsWith('assets/')) {
        // Локальные assets
        return Image.asset(
          imageUrl,
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Asset image error: $error for path: $imageUrl');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      } else if (imageUrl.startsWith('/') ||
          imageUrl.contains(RegExp(r'[a-zA-Z]:\\'))) {
        // Локальные файлы
        return Image.file(
          File(imageUrl),
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ File image error: $error for path: $imageUrl');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      } else {
        // Попытка загрузить как asset, если путь не указан явно
        return Image.asset(
          imageUrl,
          width: isCover ? double.infinity : size,
          height: isCover ? size : size,
          fit: isCover ? BoxFit.cover : BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Image loading failed: $error');
            return _buildErrorImage(size, isCover: isCover);
          },
        );
      }
    } catch (e) {
      print('❌ Exception loading image: $e');
      return _buildErrorImage(size, isCover: isCover);
    }
  }

  Widget _buildLoadingPlaceholder(double size, {bool isCover = false}) {
    return Container(
      width: isCover ? double.infinity : size,
      height: size,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isCover ? 30 : 20,
            height: isCover ? 30 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
          if (isCover) ...[
            SizedBox(height: 8),
            Text(
              'Загрузка...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorImage(double size, {bool isCover = false}) {
    return Container(
      width: isCover ? double.infinity : size,
      height: size,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCover ? Icons.photo_library : Icons.person,
            color: Colors.grey[500],
            size: isCover ? 40 : 24,
          ),
          if (isCover) ...[
            SizedBox(height: 8),
            Text(
              'Обложка не загружена',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Основные методы
  List<Channel> _getFilteredChannels(ChannelStateProvider stateProvider) {
    if (stateProvider.isDisposed) {
      return _channels;
    }

    // Используем актуальное состояние из провайдера
    final filtered = _channels.map((channel) {
      final channelId = channel.id.toString();

      return channel.copyWith(
        isSubscribed: stateProvider.isSubscribed(channelId),
        subscribers: stateProvider.getSubscribers(channelId) ??
            channel.subscribers,
        imageUrl: stateProvider.getAvatarForChannel(channelId) ??
            channel.imageUrl,
      );
    }).where(_matchesFilters).toList();

    _sortChannels(filtered);
    return filtered;
  }

  bool _matchesFilters(Channel channel) {
    if (_selectedCategoryId != 'all' &&
        channel.categoryId != _selectedCategoryId) {
      return false;
    }

    if (_activeFilters.contains('verified') && !channel.isVerified)
      return false;
    if (_activeFilters.contains('subscribed') && !channel.isSubscribed)
      return false;
    if (_activeFilters.contains('favorites') && !channel.isFavorite)
      return false;

    if (_searchQuery.isNotEmpty) {
      return channel.title.toLowerCase().contains(_searchQuery) ||
          channel.description.toLowerCase().contains(_searchQuery) ||
          (channel.tags ?? []).any((tag) =>
              tag.toLowerCase().contains(_searchQuery));
    }

    return true;
  }

  void _sortChannels(List<Channel> channels) {
    switch (_selectedSort) {
      case 'newest':
        channels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popular':
        channels.sort((a, b) => b.views.compareTo(a.views));
        break;
      case 'subscribers':
        channels.sort((a, b) => b.subscribers.compareTo(a.subscribers));
        break;
    }
  }

  void _updateChannelInList(Channel updatedChannel) {
    final index = _channels.indexWhere((c) => c.id == updatedChannel.id);
    if (index != -1) {
      setState(() {
        _channels[index] = updatedChannel;
      });
    }
  }

  // Вспомогательные методы для безопасного доступа к данным
  RoomCategory _getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return RoomCategory(id: 'unknown',
          title: 'Неизвестно',
          icon: Icons.help,
          color: Colors.grey);
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

  // Получение цвета для карточки
  Color _getCardColor(int index) {
    return _cardGradients[index % _cardGradients.length];
  }

  Color _getCardBorderColor(int index) {
    return _cardBorderColors[index % _cardBorderColors.length];
  }

  // Создание нового канала через диалог
  void _createNewChannel() {
    if (!_isMounted) return;

    showDialog(
      context: context,
      builder: (context) =>
          CreateChannelDialog(
            userName: widget.userName,
            userAvatarUrl: widget.userAvatarUrl,
            categories: _categories,
            onCreateChannel: _addNewChannel,
          ),
    );
  }

  // Добавление нового канала в список
  void _addNewChannel(String title, String description, String categoryId,
      String? avatarUrl, String? coverUrl) {
    if (!_isMounted) return;

    final newChannel = ChannelUtils.createNewChannel(
      id: _channels.length + 1,
      title: title,
      description: description,
      categoryId: categoryId,
      userName: widget.userName,
      userAvatarUrl: widget.userAvatarUrl,
      customAvatarUrl: avatarUrl,
      customCoverUrl: coverUrl,
    );

    setState(() {
      _channels.insert(0, newChannel);
    });

    // Сохраняем в провайдер
    final stateProvider = Provider.of<ChannelStateProvider>(
        context, listen: false);
    final channelId = newChannel.id.toString();
    if (avatarUrl != null) {
      stateProvider.setAvatarForChannel(channelId, avatarUrl);
    }
    if (coverUrl != null) {
      stateProvider.setCoverForChannel(channelId, coverUrl);
    }

    if (_isMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Канал "$title" успешно создан!'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Открыть',
            onPressed: () {
              if (!_isMounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChannelDetailPage(channel: newChannel),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  // ОРИГИНАЛЬНЫЙ ДИЗАЙН КАРТОЧКИ КАНАЛА
  Widget _buildChannelCard(Channel channel, int index,
      ChannelStateProvider stateProvider) {
    final categoryColor = _getCategoryColor(channel.categoryId);
    final categoryIcon = _getCategoryIcon(channel.categoryId);
    final categoryTitle = _getCategoryTitle(channel.categoryId);
    final cardColor = _getCardColor(index);
    final borderColor = _getCardBorderColor(index);

    if (_isMobile(context)) {
      return _buildMobileChannelCard(
          channel,
          categoryColor,
          categoryIcon,
          categoryTitle,
          cardColor,
          borderColor,
          index,
          stateProvider);
    } else {
      return _buildDesktopChannelCard(
          channel,
          categoryColor,
          categoryIcon,
          categoryTitle,
          cardColor,
          borderColor,
          index,
          stateProvider);
    }
  }

  Widget _buildMobileChannelCard(Channel channel,
      Color categoryColor,
      IconData categoryIcon,
      String categoryTitle,
      Color cardColor,
      Color borderColor,
      int index,
      ChannelStateProvider stateProvider,) {
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
          onTap: () {
            if (!_isMounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelDetailPage(channel: channel),
              ),
            );
          },
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
                // ОБЛОЖКА КАНАЛА
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
                        child: _buildChannelCover(
                            channel, stateProvider, height: 140),
                      ),
                    ),
                    // Категория в левом верхнем углу
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
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
                            child: Stack(
                              children: [
                                _buildChannelAvatar(
                                    channel, stateProvider, size: 50),
                                if (channel.isVerified)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Название и описание
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  channel.title,
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
                                  channel.author,
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
                      // Описание канала
                      Text(
                        channel.description,
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
                      if (channel.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: channel.tags.take(3).map((tag) {
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
                                  _formatNumber(channel.subscribers),
                                  'подписчиков',
                                  icon: Icons.people_outline,
                                  color: borderColor,
                                ),
                                _buildStatItem(
                                  channel.videos.toString(),
                                  'видео',
                                  icon: Icons.video_library,
                                  color: borderColor,
                                ),
                                _buildStatItem(
                                  channel.rating.toStringAsFixed(1),
                                  'рейтинг',
                                  icon: Icons.star,
                                  color: borderColor,
                                ),
                              ],
                            ),
                          ),
                          // Кнопка подписки
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: channel.isSubscribed
                                  ? Colors.white.withOpacity(0.8)
                                  : _primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: channel.isSubscribed
                                    ? borderColor.withOpacity(0.5)
                                    : _primaryColor,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () =>
                                  _toggleSubscription(index, stateProvider),
                              icon: Icon(
                                channel.isSubscribed ? Icons.check : Icons.add,
                                size: 18,
                                color: channel.isSubscribed
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

  Widget _buildDesktopChannelCard(
      Channel channel,
      Color categoryColor,
      IconData categoryIcon,
      String categoryTitle,
      Color cardColor,
      Color borderColor,
      int index,
      ChannelStateProvider stateProvider,
      ) {
    // ФИКСИРОВАННЫЕ РАЗМЕРЫ КАК В ARTICLESPAGE
    final double cardWidth = 360.0;
    final double fixedCardHeight = 460;

    return Container(
      width: cardWidth,
      height: fixedCardHeight,
      margin: const EdgeInsets.all(2), // ТАКОЙ ЖЕ ОТСТУП КАК В ARTICLESPAGE
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
            onTap: () {
              if (!_isMounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChannelDetailPage(channel: channel),
                ),
              );
            },
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
                        child: _buildChannelCover(channel, stateProvider, height: 160),
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
                        child: Stack(
                          children: [
                            _buildChannelAvatar(channel, stateProvider, size: 60),
                            if (channel.isVerified)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
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
                          channel.title,
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
                          channel.author,
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
                            channel.description,
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
                                _formatNumber(channel.subscribers),
                                'подписчиков',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                channel.videos.toString(),
                                'видео',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                channel.rating.toStringAsFixed(1),
                                'рейтинг',
                                fontSize: 10,
                                color: borderColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // КНОПКА ПОДПИСКИ И ХЕШТЕГИ
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: channel.tags.take(2).map((tag) {
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
                            // КНОПКА ПОДПИСКИ
                            Container(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () => _toggleSubscription(index, stateProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: channel.isSubscribed
                                      ? Colors.white.withOpacity(0.8)
                                      : _primaryColor,
                                  foregroundColor: channel.isSubscribed
                                      ? borderColor
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: channel.isSubscribed
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
                                      channel.isSubscribed ? Icons.check : Icons.add,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      channel.isSubscribed ? 'Подписка' : 'Подписаться',
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

  Widget _buildStatItem(String value, String label,
      {double fontSize = 12, Color? color, IconData? icon}) {
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

  // Вспомогательные методы
  void _toggleSubscription(int index, ChannelStateProvider stateProvider) {
    if (!_isMounted || stateProvider.isDisposed) return;

    final filteredChannels = _getFilteredChannels(stateProvider);
    final channel = filteredChannels[index];
    final channelId = channel.id.toString();

    // Получаем актуальное количество подписчиков
    final currentSubscribers = stateProvider.getSubscribers(channelId) ??
        channel.subscribers;

    // Переключаем подписку через ChannelStateProvider
    stateProvider.toggleSubscription(channelId, currentSubscribers);

    // Принудительно обновляем состояние
    if (_isMounted) {
      setState(() {
        // Обновляем локальный список каналов
        final originalIndex = _channels.indexWhere((c) => c.id == channel.id);
        if (originalIndex != -1) {
          _channels[originalIndex] = _channels[originalIndex].copyWith(
            isSubscribed: stateProvider.isSubscribed(channelId),
            subscribers: stateProvider.getSubscribers(channelId) ??
                _channels[originalIndex].subscribers,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stateProvider.isSubscribed(channelId)
                ? '✅ Подписались на ${channel.title}'
                : '❌ Отписались от ${channel.title}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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
          hintText: 'Поиск каналов...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          prefixIcon: Icon(
              Icons.search_rounded, size: 20, color: _primaryColor),
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

  // ВИДЖЕТЫ ФИЛЬТРОВ И КАТЕГОРИЙ В СТИЛЕ ARTICLESPAGE
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
                  children: _filterOptions.map((filter) =>
                      _buildFilterChip(filter)).toList(),
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
      children: _categories.map((category) =>
          _buildDesktopCategoryChip(category)).toList(),
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

  // КОМПАКТНЫЙ APP BAR В СТИЛЕ ARTICLESPAGE
  // APP BAR С ФОНОМ И ВЫРАВНИВАНИЕМ ПРАВОГО КОНТЕНТА КАК В ARTICLESPAGE
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
            // Заголовок "Каналы" с фоном и выравниванием по категориям
            Padding(
              padding: EdgeInsets.only(left: totalCategoriesLeftPadding -
                  (isMobile ? 12 : horizontalPadding)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
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
                      Icons.play_circle_filled_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Каналы',
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
                      child: Icon(
                          Icons.search_rounded, color: Colors.white, size: 18),
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
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          Icons.sort_rounded, color: Colors.white, size: 18),
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
                        left: totalCategoriesLeftPadding -
                            (isMobile ? 12 : horizontalPadding),
                        right: 8,
                      ),
                      child: _buildSearchField(),
                    ),
                  ),
                  // Кнопка закрытия с выравниванием
                  Padding(
                    padding: EdgeInsets.only(right: totalCategoriesLeftPadding -
                        (isMobile ? 12 : horizontalPadding)),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: () =>
                          setState(() {
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
      builder: (context) =>
          Container(
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
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor),
                ),
                const SizedBox(height: 16),
                ..._sortOptions.map((option) =>
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                            option.icon, size: 20, color: _primaryColor),
                      ),
                      title: Text(
                        option.title,
                        style: TextStyle(fontSize: 15,
                            color: _textColor,
                            fontWeight: FontWeight.w500),
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

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final isMobile = _isMobile(context);

    return Consumer<ChannelStateProvider>(
      builder: (context, channelStateProvider, child) {
        // Проверяем состояние провайдера перед использованием
        if (channelStateProvider.isDisposed) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка каналов...',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Принудительно обновляем каналы при каждом изменении состояния
        final channels = _getFilteredChannels(channelStateProvider);


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
                  ? _buildMobileLayout(
                  horizontalPadding, channelStateProvider, channels)
                  : _buildDesktopLayout(_buildDesktopContent(
                  horizontalPadding, channelStateProvider, channels)),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _createNewChannel,
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(double horizontalPadding,
      ChannelStateProvider stateProvider, List<Channel> channels) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, true),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildMobileContent(
                stateProvider, horizontalPadding, channels),
          ),
        ),
      ],
    );
  }


  Widget _buildMobileContent(ChannelStateProvider stateProvider,
      double horizontalPadding, List<Channel> channels) {
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

        // Карточки каналов
        _buildChannelsGrid(stateProvider, horizontalPadding, channels, true),
      ],
    );
  }

  Widget _buildDesktopContent(double horizontalPadding,
      ChannelStateProvider stateProvider, List<Channel> channels) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, false),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildDesktopContentBody(
                stateProvider, horizontalPadding, channels),
          ),
        ),
      ],
    );
  }


  Widget _buildDesktopContentBody(ChannelStateProvider stateProvider,
      double horizontalPadding, List<Channel> channels) {
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

          // Карточки каналов
          _buildChannelsGrid(stateProvider, horizontalPadding, channels, false),
        ],
      ),
    );
  }

  Widget _buildChannelsGrid(ChannelStateProvider stateProvider, double horizontalPadding, List<Channel> channels, bool isMobile) {
    if (channels.isEmpty) {
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
                  child: Icon(Icons.play_circle_filled_rounded, size: 48, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Каналы не найдены',
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
            if (index >= channels.length) return const SizedBox.shrink();

            final channel = channels[index];
            // Обновляем канал актуальным состоянием
            final updatedChannel = channel.copyWith(
              isSubscribed: stateProvider.isSubscribed(channel.id.toString()),
              subscribers: stateProvider.getSubscribers(channel.id.toString()) ?? channel.subscribers,
            );

            return _buildChannelCard(updatedChannel, index, stateProvider);
          },
          childCount: channels.length,
        ),
      );
    }

    // ДЛЯ ПЛАНШЕТОВ И КОМПЬЮТЕРОВ - ИСПОЛЬЗУЕМ SliverGrid С ТАКИМИ ЖЕ ОТСТУПАМИ КАК В ARTICLESPAGE
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16, // ТАКОЙ ЖЕ ВЕРТИКАЛЬНЫЙ ОТСТУП КАК В ARTICLESPAGE
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16, // ТАКОЙ ЖЕ ГОРИЗОНТАЛЬНЫЙ ОТСТУП КАК В ARTICLESPAGE
          mainAxisSpacing: 16,  // ТАКОЙ ЖЕ ВЕРТИКАЛЬНЫЙ ОТСТУП КАК В ARTICLESPAGE
          childAspectRatio: 360 / 460, // ФИКСИРОВАННОЕ СООТНОШЕНИЕ как в ArticlesPage
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= channels.length) return const SizedBox.shrink();

            final channel = channels[index];
            // Обновляем канал актуальным состоянием
            final updatedChannel = channel.copyWith(
              isSubscribed: stateProvider.isSubscribed(channel.id.toString()),
              subscribers: stateProvider.getSubscribers(channel.id.toString()) ?? channel.subscribers,
            );

            return Padding(
              padding: const EdgeInsets.all(2), // ТАКОЙ ЖЕ ВНУТРЕННИЙ ОТСТУП КАК В ARTICLESPAGE
              child: _buildChannelCard(updatedChannel, index, stateProvider),
            );
          },
          childCount: channels.length,
        ),
      ),
    );
  }
}