import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // Данные
  late List<Channel> _channels;
  late final List<RoomCategory> _categories;
  late final List<SortOption> _sortOptions;
  late final List<FilterOption> _filterOptions;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupListeners();
  }

  void _initializeData() {
    _channels = _createSampleChannels();
    _categories = _createCategories();
    _sortOptions = _createSortOptions();
    _filterOptions = _createFilterOptions();
  }

  void _setupListeners() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  List<Channel> _createSampleChannels() {
    return [
      Channel(
        id: 1,
        title: 'Спортивные новости',
        description: 'Последние события в мире спорта и аналитика матчей. Эксклюзивные интервью с атлетами.',
        imageUrl: 'assets/images/cards_image/avatarka/sportAvatarka.png',
        subscribers: 17800,
        videos: 95,
        isSubscribed: true,
        isFavorite: false,
        cardColor: Colors.blue.shade700,
        categoryId: 'sport',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isVerified: true,
        rating: 4.6,
        views: 1980000,
        likes: 67000,
        comments: 3200,
        owner: 'Дмитрий Спортивный',
        author: 'Дмитрий Спортивный',
        authorImageUrl: 'assets/images/cards_image/avatarka/sportAvatarka.png',
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
        imageUrl: 'assets/images/cards_image/avatarka/avatarka1.png',
        subscribers: 15600,
        videos: 120,
        isSubscribed: false,
        isFavorite: true,
        cardColor: Colors.green.shade700,
        categoryId: 'games',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isVerified: true,
        rating: 4.9,
        views: 2100000,
        likes: 89000,
        comments: 4500,
        owner: 'Алексей Геймеров',
        author: 'Алексей Геймеров',
        authorImageUrl: 'assets/images/cards_image/avatarka/avatarka1.png',
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
        imageUrl: 'assets/images/cards_image/avatarka/avatarka2.png',
        subscribers: 12450,
        videos: 89,
        isSubscribed: false,
        isFavorite: false,
        cardColor: Colors.orange.shade700,
        categoryId: 'tech',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isVerified: true,
        rating: 4.8,
        views: 1250000,
        likes: 45000,
        comments: 2300,
        owner: 'Иван Технолог',
        author: 'Иван Технолог',
        authorImageUrl: 'assets/images/cards_image/avatarka/avatarka2.png',
        tags: ['технологии', 'IT', 'инновации', 'робототехника'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://tech-future.ru',
        socialMedia: '@tech_future',
        commentsCount: 2300,
        coverImageUrl: 'assets/images/cards_image/owner/the_soul_channel.png',
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
        cardColor: Colors.purple.shade700,
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
        cardColor: Colors.teal.shade700,
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
        coverImageUrl: 'assets/images/cards_image/owner/sptort_channel.png',
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
        cardColor: Colors.pink.shade700,
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
        coverImageUrl: 'assets/images/cards_image/owner/game_channel.png',
      ),
    ];
  }

  List<RoomCategory> _createCategories() {
    return [
      RoomCategory(id: 'all', title: 'Все', icon: Icons.explore, color: Colors.blue),
      RoomCategory(id: 'sport', title: 'Спорт', icon: Icons.sports_soccer, color: Colors.red),
      RoomCategory(id: 'games', title: 'Игры', icon: Icons.sports_esports, color: Colors.green),
      RoomCategory(id: 'tech', title: 'Технологии', icon: Icons.memory, color: Colors.orange),
      RoomCategory(id: 'business', title: 'Бизнес', icon: Icons.business_center, color: Colors.purple),
    ];
  }

  List<SortOption> _createSortOptions() {
    return [
      SortOption(id: 'newest', title: 'Сначала новые', icon: Icons.new_releases),
      SortOption(id: 'popular', title: 'По популярности', icon: Icons.trending_up),
      SortOption(id: 'subscribers', title: 'По подписчикам', icon: Icons.people),
    ];
  }

  List<FilterOption> _createFilterOptions() {
    return [
      FilterOption(id: 'verified', title: 'Только проверенные', icon: Icons.verified),
      FilterOption(id: 'subscribed', title: 'Мои подписки', icon: Icons.subscriptions),
      FilterOption(id: 'favorites', title: 'Избранное', icon: Icons.favorite),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // АДАПТИВНЫЕ МЕТОДЫ
  bool get _isMobile => MediaQuery.of(context).size.width <= 600;

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getCardAspectRatio(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1: return 0.75;
      case 2: return 0.8;
      case 3: return 0.85;
      default: return 0.8;
    }
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  // Основные методы
  List<Channel> _getFilteredChannels(ChannelStateProvider stateProvider) {
    final filtered = _channels.map((channel) =>
        _getChannelWithActualState(channel, stateProvider)
    ).where(_matchesFilters).toList();

    _sortChannels(filtered);
    return filtered;
  }

  bool _matchesFilters(Channel channel) {
    if (_selectedCategoryId != 'all' && channel.categoryId != _selectedCategoryId) {
      return false;
    }

    if (_activeFilters.contains('verified') && !channel.isVerified) return false;
    if (_activeFilters.contains('subscribed') && !channel.isSubscribed) return false;
    if (_activeFilters.contains('favorites') && !channel.isFavorite) return false;

    if (_searchQuery.isNotEmpty) {
      return channel.title.toLowerCase().contains(_searchQuery) ||
          channel.description.toLowerCase().contains(_searchQuery) ||
          (channel.tags ?? []).any((tag) => tag.toLowerCase().contains(_searchQuery));
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

  Channel _getChannelWithActualState(Channel channel, ChannelStateProvider stateProvider) {
    final channelId = channel.id.toString();
    final isSubscribed = stateProvider.isSubscribed(channelId);
    final subscribers = stateProvider.getSubscribers(channelId) ?? channel.subscribers;

    return channel.copyWith(
      isSubscribed: isSubscribed,
      subscribers: subscribers,
    );
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

  // НОВЫЙ МЕТОД: Создание нового канала через диалог
  void _createNewChannel() {
    showDialog(
      context: context,
      builder: (context) => CreateChannelDialog(
        userName: widget.userName,
        userAvatarUrl: widget.userAvatarUrl,
        categories: _categories,
        onCreateChannel: _addNewChannel,
      ),
    );
  }

  // НОВЫЙ МЕТОД: Добавление нового канала в список
  // В методе _addNewChannel
  void _addNewChannel(String title, String description, String categoryId, String? avatarUrl, String? coverUrl) {
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

    // Показать уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Канал "$title" успешно создан!'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {
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

  // ДОБАВЛЕННЫЙ МЕТОД: Построение карточки канала
  Widget _buildChannelCard(Channel channel, int index, ChannelStateProvider stateProvider) {
    return _isMobile
        ? _buildMobileChannelCard(channel, index, stateProvider)
        : _buildDesktopChannelCard(channel, index, stateProvider);
  }

  Widget _buildMobileChannelCard(Channel channel, int index, ChannelStateProvider stateProvider) {
    final categoryColor = _getCategoryColor(channel.categoryId);
    final categoryIcon = _getCategoryIcon(channel.categoryId);
    final categoryTitle = _getCategoryTitle(channel.categoryId);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelDetailPage(channel: channel),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ОБЛОЖКА КАНАЛА С ИНФОРМАЦИЕЙ В ЛЕВОМ НИЖНЕМ УГЛУ
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(channel.coverImageUrl ?? channel.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Категория в левом верхнем углу
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categoryIcon,
                            size: 10,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            categoryTitle.toUpperCase(),
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Аватарка, название и количество участников в левом нижнем углу
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Аватарка
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              children: [
                                Image.network(
                                  channel.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                if (channel.isVerified)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Название и количество участников
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Название канала
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    channel.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Количество участников
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${_formatNumber(channel.subscribers)} участников',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[300],
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ОСНОВНОЙ КОНТЕНТ ПОД ОБЛОЖКОЙ - ВЫРАВНЕН ПО АВАТАРКЕ
              Container(
                padding: const EdgeInsets.only(
                  left: 68, // 8 (left обложки) + 50 (ширина аватарки) + 10 (отступ) = 68
                  right: 12,
                  top: 12,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Описание канала
                    Text(
                      channel.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // ХЕШТЕГИ
                    if (channel.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: channel.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[100]!,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700]!,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Строка с информацией и кнопками
                    Row(
                      children: [
                        // Информация о канале
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Владелец: ${channel.owner}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Кнопки действий
                        Row(
                          children: [
                            // Кнопка репоста
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Репост канала ${channel.title}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.share_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Кнопка подписки
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: channel.isSubscribed
                                    ? Colors.grey[100]
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: channel.isSubscribed
                                      ? Colors.grey[300]!
                                      : Colors.blue,
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () => _toggleSubscription(index, stateProvider),
                                icon: Icon(
                                  channel.isSubscribed ? Icons.check : Icons.add,
                                  size: 16,
                                  color: channel.isSubscribed
                                      ? Colors.grey[700]
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopChannelCard(Channel channel, int index, ChannelStateProvider stateProvider) {
    final crossAxisCount = _getCrossAxisCount(context);
    final coverHeight = 120.0;
    final avatarSize = 45.0;

    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelDetailPage(channel: channel),
              ),
            );
          },
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
                        image: NetworkImage(channel.coverImageUrl ?? channel.imageUrl),
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
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            children: [
                              Image.network(
                                channel.imageUrl,
                                width: avatarSize,
                                height: avatarSize,
                                fit: BoxFit.cover,
                              ),
                              if (channel.isVerified)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: avatarSize * 0.25,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
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
                      // НАЗВАНИЕ КАНАЛА
                      Text(
                        channel.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // АВТОР
                      Text(
                        channel.author,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // ОПИСАНИЕ
                      Expanded(
                        child: Text(
                          channel.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // СТАТИСТИКА
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                _formatNumber(channel.subscribers),
                                'подписчиков',
                                fontSize: 10,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                channel.videos.toString(),
                                'видео',
                                fontSize: 10,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                channel.rating.toStringAsFixed(1),
                                'рейтинг',
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // КНОПКА ПОДПИСКИ
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _toggleSubscription(index, stateProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: channel.isSubscribed
                                ? Colors.grey[100]
                                : Colors.blue,
                            foregroundColor: channel.isSubscribed
                                ? Colors.grey[700]
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: channel.isSubscribed
                                    ? Colors.grey[300]!
                                    : Colors.blue,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                channel.isSubscribed ? Icons.check : Icons.add,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                channel.isSubscribed ? 'Вы подписаны' : 'Подписаться',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ХЕШТЕГИ
                      if (channel.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: channel.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50]!,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue[100]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700]!,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
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

  Widget _buildStatItem(String value, String label, {required double fontSize}) {
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

  // Вспомогательные методы
  void _toggleSubscription(int index, ChannelStateProvider stateProvider) {
    final filteredChannels = _getFilteredChannels(stateProvider);
    final channel = filteredChannels[index];
    final globalIndex = _channels.indexWhere((c) => c.id == channel.id);

    if (globalIndex != -1) {
      final channelId = channel.id.toString();
      final currentSubscribers = channel.subscribers;

      stateProvider.toggleSubscription(channelId, currentSubscribers);

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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск каналов...',
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

  // УЛУЧШЕННЫЕ ВИДЖЕТЫ ФИЛЬТРОВ И КАТЕГОРИЙ - КАК В ROOM_PAGE
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: _isMobile ? 0 : horizontalPadding,
          vertical: 8
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isMobile ? 0 : 12),
        ),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(_isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фильтры',
                style: TextStyle(
                  fontSize: _isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: _isMobile ? 36 : 40,
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
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: _isMobile ? 0 : horizontalPadding,
          vertical: 8
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isMobile ? 0 : 12),
        ),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(_isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Категории',
                style: TextStyle(
                  fontSize: _isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: _isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _categories
                      .map((category) => _buildCategoryChip(category))
                      .toList(),
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
      margin: EdgeInsets.only(right: _isMobile ? 6 : 8),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
        child: InkWell(
          onTap: () => setState(() => _selectedCategoryId = category.id),
          borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobile ? 12 : 16,
              vertical: _isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: _isMobile ? 14 : 16,
                  color: isSelected ? Colors.white : category.color,
                ),
                SizedBox(width: _isMobile ? 4 : 6),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: _isMobile ? 12 : 13,
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
      margin: EdgeInsets.only(right: _isMobile ? 6 : 8),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
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
          borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobile ? 12 : 16,
              vertical: _isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter.icon,
                  size: _isMobile ? 14 : 16,
                  color: isActive ? Colors.white : Colors.blue,
                ),
                SizedBox(width: _isMobile ? 4 : 6),
                Text(
                  filter.title,
                  style: TextStyle(
                    fontSize: _isMobile ? 12 : 13,
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChannelStateProvider(),
      child: Consumer<ChannelStateProvider>(
        builder: (context, channelStateProvider, child) {
          final horizontalPadding = _getHorizontalPadding(context);

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
                    // AppBar
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: _isMobile ? 16 : horizontalPadding,
                          vertical: 8
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          if (!_showSearchBar) ...[
                            const Text(
                              'Каналы',
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
                                  Expanded(
                                    child: _buildSearchField(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                    ),
                                    onPressed: () => setState(() {
                                      _showSearchBar = false;
                                      _searchController.clear();
                                      _searchQuery = '';
                                    }),
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
                                      Icons.search,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: () => setState(() => _showSearchBar = true),
                                ),
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: () => setState(() => _showFilters = !_showFilters),
                                ),
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sort,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: _showSortBottomSheet,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildContent(channelStateProvider, horizontalPadding),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _createNewChannel,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 24),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ChannelStateProvider stateProvider, double horizontalPadding) {
    final channels = _getFilteredChannels(stateProvider);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildFiltersCard(horizontalPadding),
        ),
        SliverToBoxAdapter(
          child: _buildCategoriesCard(horizontalPadding),
        ),
        if (channels.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  const Text(
                    'Каналы не найдены',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Попробуйте изменить параметры поиска',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createNewChannel,
                    child: const Text('Создать первый канал'),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobile ? 0 : horizontalPadding,
              vertical: _isMobile ? 0 : 8,
            ),
            sliver: _isMobile
                ? SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildChannelCard(
                  channels[index],
                  index,
                  stateProvider,
                ),
                childCount: channels.length,
              ),
            )
                : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: _getCardAspectRatio(context),
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildChannelCard(
                  channels[index],
                  index,
                  stateProvider,
                ),
                childCount: channels.length,
              ),
            ),
          ),
      ],
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            const Text(
              'Сортировка',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._sortOptions.map((option) => ListTile(
              leading: Icon(option.icon, size: 18),
              title: Text(
                option.title,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: _selectedSort == option.id
                  ? const Icon(Icons.check, color: Colors.blue, size: 18)
                  : null,
              onTap: () {
                setState(() => _selectedSort = option.id);
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }
}