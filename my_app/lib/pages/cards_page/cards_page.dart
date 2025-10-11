import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../rooms_pages/models/filter_option.dart';
import '../rooms_pages/models/room_category.dart';
import '../rooms_pages/models/sort_option.dart';
import 'channel_detail_page.dart';
import 'models/channel.dart';
import '../../providers/channel_state_provider.dart';

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

class _CardsPageState extends State<CardsPage> with TickerProviderStateMixin {
  // Константы для адаптивного дизайна
  static const _animationDuration = Duration(milliseconds: 300);
  static const _refreshDelay = Duration(seconds: 2);

  // Контроллеры
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Анимации
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;

  // Состояние
  int _currentTabIndex = 0;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  String _selectedSort = 'newest';
  final Set<String> _activeFilters = {};
  bool _isGridView = true;
  bool _isLoading = false;
  bool _showSearchBar = false;
  bool _showCreateButton = true;
  bool _showFilters = false;

  // Переменные для управления состоянием создания канала
  bool _isCreatingChannel = false;
  String? _selectedCategoryForCreation;

  // Кэшированные данные
  late final List<Channel> _channels;
  late final List<RoomCategory> _categories;
  late final List<SortOption> _sortOptions;
  late final List<FilterOption> _filterOptions;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeData() {
    _channels = _createSampleChannels();
    _categories = _createCategories();
    _sortOptions = _createSortOptions();
    _filterOptions = _createFilterOptions();
    _selectedCategoryForCreation = _categories.firstWhere((c) => c.id != 'all').id;
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  void _setupListeners() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });

    _titleController.addListener(_updateFormValidity);
    _descriptionController.addListener(_updateFormValidity);

    _scrollController.addListener(_handleScroll);
  }

  void _updateFormValidity() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleScroll() {
    // Убрана логика скрытия кнопки создания
  }

  // Создание тестовых данных
  List<Channel> _createSampleChannels() {
    return [
      Channel(
        id: 1,
        title: 'Спортивные новости',
        description: 'Последние события в мире спорта и аналитика матчей. Эксклюзивные интервью с атлетами.',
        imageUrl: 'https://avatars.mds.yandex.net/i?id=856af239789ab3f5f7962897c9a69647_l-12422990-images-thumbs&n=13',
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
        authorImageUrl: 'https://avatars.mds.yandex.net/i?id=856af239789ab3f5f7962897c9a69647_l-12422990-images-thumbs&n=13',
        tags: ['спорт', 'новости', 'аналитика', 'матчи'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://sport-news.ru',
        socialMedia: '@sport_news',
        commentsCount: 3200,
        coverImageUrl: 'https://avatars.mds.yandex.net/i?id=ea37c708c5ce62c18b1bdd46eee2f008f7be91ac-11389740-images-thumbs&n=13',
      ),
      Channel(
        id: 2,
        title: 'Игровые обзоры',
        description: 'Новинки игровой индустрии и геймплей по всем платформам. Только честные обзоры!',
        imageUrl: 'https://avatars.mds.yandex.net/get-yapic/43978/i5F2TxqvHEddRcAEUmpIFyO2tL0-1/orig',
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
        authorImageUrl: 'https://avatars.mds.yandex.net/get-yapic/43978/i5F2TxqvHEddRcAEUmpIFyO2tL0-1/orig',
        tags: ['игры', 'гейминг', 'обзоры', 'стримы'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://game-reviews.ru',
        socialMedia: '@game_reviews',
        commentsCount: 4500,
        coverImageUrl: 'https://avatars.mds.yandex.net/i?id=a8645c8c94fcb35eda1d8297057c76fed507e2d4-8821845-images-thumbs&n=13',
      ),
      Channel(
        id: 3,
        title: 'Акортовский Мемасник',
        description: 'Обсуждаем мемы и разные новости о МЮ.',
        imageUrl: 'https://avatars.mds.yandex.net/i?id=62ba1b69e7eacb8bfab63982c958d61b_l-5221158-images-thumbs&n=13',
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
        authorImageUrl: 'https://avatars.mds.yandex.net/i?id=b6988c99b85abf799a69c5470867357b_l-5235116-images-thumbs&n=13',
        tags: ['технологии', 'IT', 'инновации', 'робототехника'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://tech-future.ru',
        socialMedia: '@tech_future',
        commentsCount: 2300,
        coverImageUrl: 'https://avatars.mds.yandex.net/i?id=b6988c99b85abf799a69c5470867357b_l-5235116-images-thumbs&n=13',
      ),
      Channel(
        id: 4,
        title: 'Бизнес стратегии',
        description: 'Советы по ведению успешного бизнеса и инвестициям. Практические кейсы и экспертные мнения.',
        imageUrl: 'https://avatars.mds.yandex.net/i?id=3a067d8f05dc89fc808d473c592f2882_l-5042014-images-thumbs&n=13',
        subscribers: 8900,
        videos: 67,
        isSubscribed: false,
        isFavorite: true,
        cardColor: Colors.purple.shade700,
        categoryId: 'business',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        isVerified: false,
        rating: 4.5,
        views: 890000,
        likes: 32000,
        comments: 1500,
        owner: 'Мария Бизнесменова',
        author: 'Мария Бизнесменова',
        authorImageUrl: 'https://avatars.mds.yandex.net/i?id=3a067d8f05dc89fc808d473c592f2882_l-5042014-images-thumbs&n=13',
        tags: ['бизнес', 'инвестиции', 'стратегии', 'финансы'],
        isLive: false,
        liveViewers: 0,
        websiteUrl: 'https://business-strategy.ru',
        socialMedia: '@biz_strategy',
        commentsCount: 1500,
        coverImageUrl: 'https://avatars.mds.yandex.net/i?id=d61e4a456464cc5a8c7996728c9a4e3d_l-4835468-images-thumbs&n=13',
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
      RoomCategory(id: 'music', title: 'Музыка', icon: Icons.music_note, color: Colors.pink),
      RoomCategory(id: 'education', title: 'Образование', icon: Icons.school, color: Colors.teal),
    ];
  }

  List<SortOption> _createSortOptions() {
    return [
      SortOption(id: 'newest', title: 'Сначала новые', icon: Icons.new_releases),
      SortOption(id: 'popular', title: 'По популярности', icon: Icons.trending_up),
      SortOption(id: 'subscribers', title: 'По подписчикам', icon: Icons.people),
      SortOption(id: 'rating', title: 'По рейтингу', icon: Icons.star),
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
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ 3 КАРТОЧЕК В РЯД
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3; // Большие экраны - 3 карточки
    if (width > 800) return 3;  // Средние экраны - 3 карточки
    if (width > 600) return 2;  // Планшеты - 2 карточки
    return 1;                   // Мобильные - 1 карточка
  }

  // ОПТИМАЛЬНЫЕ ПРОПОРЦИИ ДЛЯ 3 КАРТОЧЕК
  double _getCardAspectRatio(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные - 1 карточка в ряд
        return 0.75; // ВЫСОКАЯ КАРТОЧКА
      case 2: // Планшеты - 2 карточки в ряд
        return 0.8;  // КВАДРАТНАЯ КАРТОЧКА
      case 3: // Десктоп - 3 карточки в ряд
        return 0.85; // ШИРОКАЯ КАРТОЧКА
      default:
        return 0.8;
    }
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200; // Большие экраны
    if (width > 800) return 100;  // Средние экраны
    if (width > 600) return 60;   // Планшеты
    return 16;                    // Мобильные
  }

  // Адаптивные размеры для карточек
  double _getCoverHeight(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные
        return 140;
      case 2: // Планшеты
        return 130;
      case 3: // Десктоп
        return 120;
      default:
        return 130;
    }
  }

  double _getAvatarSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные
        return 55;
      case 2: // Планшеты
        return 50;
      case 3: // Десктоп
        return 45;
      default:
        return 50;
    }
  }

  double _getTitleFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные
        return 17;
      case 2: // Планшеты
        return 16;
      case 3: // Десктоп
        return 15;
      default:
        return 16;
    }
  }

  double _getDescriptionFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные
        return 13;
      case 2: // Планшеты
        return 12;
      case 3: // Десктоп
        return 11;
      default:
        return 12;
    }
  }

  double _getStatFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные
        return 11;
      case 2: // Планшеты
        return 10;
      case 3: // Десктоп
        return 9;
      default:
        return 10;
    }
  }

  double _getButtonPadding(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    switch (crossAxisCount) {
      case 1: // Мобильные
        return 12;
      case 2: // Планшеты
        return 10;
      case 3: // Десктоп
        return 8;
      default:
        return 10;
    }
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
          channel.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
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
      case 'rating':
        channels.sort((a, b) => b.rating.compareTo(a.rating));
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

  // Создание канала
  void _createNewChannel() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedCategoryForCreation = _categories.firstWhere((c) => c.id != 'all').id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateChannelBottomSheet(),
    ).then((_) {
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  Widget _buildCreateChannelBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Создать новый канал',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildChannelForm(setModalState),
              const SizedBox(height: 24),
              _buildFormActions(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelForm(void Function(void Function()) setModalState) {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Название канала',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Введите название канала',
          ),
          onChanged: (value) {
            setModalState(() {});
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Описание',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Введите описание канала',
          ),
          maxLines: 3,
          onChanged: (value) {
            setModalState(() {});
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategoryForCreation,
          decoration: InputDecoration(
            labelText: 'Категория',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _categories.where((c) => c.id != 'all').map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
                children: [
                  Icon(category.icon, size: 18, color: category.color),
                  const SizedBox(width: 8),
                  Text(category.title),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategoryForCreation = value);
          },
        ),
      ],
    );
  }

  Widget _buildFormActions() {
    final isValid = _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Отмена'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isValid && !_isCreatingChannel ? _submitNewChannel : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: isValid ? Colors.blue : Colors.grey,
            ),
            child: _isCreatingChannel
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text(
              'Создать',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _submitNewChannel() {
    setState(() => _isCreatingChannel = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _channels.insert(0, _createNewChannelFromData(
            _titleController.text.trim(),
            _descriptionController.text.trim(),
          ));
          _isCreatingChannel = false;
        });
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Канал успешно создан!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });
  }

  Channel _createNewChannelFromData(String title, String description) {
    return Channel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      description: description,
      imageUrl: widget.userAvatarUrl,
      subscribers: 0,
      videos: 0,
      isSubscribed: false,
      isFavorite: false,
      cardColor: _getRandomColor(),
      categoryId: _selectedCategoryForCreation!,
      createdAt: DateTime.now(),
      isVerified: false,
      rating: 0.0,
      views: 0,
      likes: 0,
      comments: 0,
      owner: widget.userName,
      author: widget.userName,
      authorImageUrl: widget.userAvatarUrl,
      tags: ['новый'],
      isLive: false,
      liveViewers: 0,
      websiteUrl: '',
      socialMedia: '',
      commentsCount: 0,
      coverImageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
      Colors.teal.shade700,
      Colors.pink.shade700,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  // СОВЕРШЕННЫЙ ДИЗАЙН КАРТОЧКИ ДЛЯ 3 В РЯД
  Widget _buildChannelCard(Channel channel, int index, ChannelStateProvider stateProvider) {
    final actualChannel = _getChannelWithActualState(channel, stateProvider);

    // Адаптивные размеры
    final crossAxisCount = _getCrossAxisCount(context);
    final coverHeight = _getCoverHeight(context);
    final avatarSize = _getAvatarSize(context);
    final titleFontSize = _getTitleFontSize(context);
    final descriptionFontSize = _getDescriptionFontSize(context);
    final statFontSize = _getStatFontSize(context);
    final buttonPadding = _getButtonPadding(context);

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
                builder: (context) => ChannelDetailPage(channel: actualChannel),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ОБЛОЖКА С АВАТАРКОЙ
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // ОСНОВНАЯ ОБЛОЖКА
                  Container(
                    height: coverHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(actualChannel.coverImageUrl ?? actualChannel.imageUrl),
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

                  // АВАТАРКА - ПО ЦЕНТРУ ВНИЗУ
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
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: avatarSize * 0.5,
                              backgroundImage: NetworkImage(actualChannel.imageUrl),
                            ),
                            if (actualChannel.isVerified)
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
                ],
              ),

              // ОТСТУП ДЛЯ АВАТАРКИ
              SizedBox(height: avatarSize * 0.3),

              // КОНТЕНТ КАРТОЧКИ - ИДЕАЛЬНОЕ РАСПРЕДЕЛЕНИЕ ПРОСТРАНСТВА
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
                        actualChannel.title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // АВТОР
                      const SizedBox(height: 4),
                      Text(
                        actualChannel.author,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ОПИСАНИЕ
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          actualChannel.description,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: _getDescriptionMaxLines(crossAxisCount),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // СТАТИСТИКА
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                _formatNumber(actualChannel.subscribers),
                                'подписчиков',
                                fontSize: statFontSize,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                actualChannel.videos.toString(),
                                'видео',
                                fontSize: statFontSize,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                actualChannel.rating.toStringAsFixed(1),
                                'рейтинг',
                                fontSize: statFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // КНОПКА ПОДПИСКИ
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _toggleSubscription(index, stateProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actualChannel.isSubscribed
                                ? Colors.grey[100]
                                : Colors.blue,
                            foregroundColor: actualChannel.isSubscribed
                                ? Colors.grey[700]
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: actualChannel.isSubscribed
                                    ? Colors.grey[300]!
                                    : Colors.blue,
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                actualChannel.isSubscribed ? Icons.check : Icons.add,
                                size: crossAxisCount >= 2 ? 16 : 18,
                              ),
                              SizedBox(width: crossAxisCount >= 2 ? 6 : 8),
                              Text(
                                actualChannel.isSubscribed ? 'Вы подписаны' : 'Подписаться',
                                style: TextStyle(
                                  fontSize: statFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
      case 1: return 3;  // Мобильные - больше места
      case 2: return 2;  // Планшеты - среднее
      case 3: return 2;  // Десктоп - компактно
      default: return 2;
    }
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

  void _toggleFavorite(int index) {
    setState(() {
      _channels[index] = _channels[index].copyWith(
        isFavorite: !_channels[index].isFavorite,
      );
    });
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Виджет поля поиска для AppBar
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

  // ВИДЖЕТЫ ДЛЯ ФИЛЬТРОВ И КАТЕГОРИЙ
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Категории',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _categories.asMap().entries.map((entry) {
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
          onTap: () {
            setState(() {
              _selectedCategoryId = category.id;
            });
          },
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
                Icon(
                  filter.icon,
                  size: 16,
                  color: isActive ? Colors.white : Colors.blue,
                ),
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
                    // AppBar БЕЗ карточки - просто белый фон
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          // Заголовок
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

                          // Поле поиска или кнопки
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

                    // Контент
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: _buildContent(channelStateProvider, horizontalPadding),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Кнопка "+" всегда видимая и только с иконкой
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
        // Фильтры
        SliverToBoxAdapter(
          child: _buildFiltersCard(horizontalPadding),
        ),

        // Категории
        SliverToBoxAdapter(
          child: _buildCategoriesCard(horizontalPadding),
        ),

        // Карточки каналов или пустое состояние
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
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
            sliver: SliverGrid(
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