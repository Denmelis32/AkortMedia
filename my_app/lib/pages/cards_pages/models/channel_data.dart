// lib/pages/cards_pages/models/channel_data.dart
import 'package:flutter/material.dart';
import '../../cards_detail_page/models/channel.dart';
import '../../rooms_pages/models/filter_option.dart';
import '../../rooms_pages/models/room_category.dart';
import '../../rooms_pages/models/sort_option.dart';

class ChannelDataManager {
  final List<RoomCategory> categories;
  final List<SortOption> sortOptions;
  final List<FilterOption> filterOptions;

  ChannelDataManager()
      : categories = _createCategories(),
        sortOptions = _createSortOptions(),
        filterOptions = _createFilterOptions();

  List<Channel> createSampleChannels() {
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

  // Мягкие цвета для карточек
  static final List<Color> _cardGradients = [
    const Color(0xFFE3F2FD), // Светло-голубой
    const Color(0xFFF3E5F5), // Светло-фиолетовый
    const Color(0xFFE8F5E8), // Светло-зеленый
    const Color(0xFFFFF3E0), // Светло-оранжевый
    const Color(0xFFFCE4EC), // Светло-розовый
    const Color(0xFFE0F2F1), // Светло-бирюзовый
    const Color(0xFFEDE7F6), // Светло-лавандовый
    const Color(0xFFFFF8E1), // Светло-желтый
  ];

  static final List<Color> _cardBorderColors = [
    const Color(0xFF90CAF9), // Голубой
    const Color(0xFFCE93D8), // Фиолетовый
    const Color(0xFFA5D6A7), // Зеленый
    const Color(0xFFFFCC80), // Оранжевый
    const Color(0xFFF48FB1), // Розовый
    const Color(0xFF80CBC4), // Бирюзовый
    const Color(0xFFB39DDB), // Лавандовый
    const Color(0xFFFFE082), // Желтый
  ];

  Color getCardColor(int index) {
    return _cardGradients[index % _cardGradients.length];
  }

  Color getCardBorderColor(int index) {
    return _cardBorderColors[index % _cardBorderColors.length];
  }

  static List<RoomCategory> _createCategories() {
    final primaryColor = const Color(0xFFFb5679);
    return [
      RoomCategory(id: 'all', title: 'Все', icon: Icons.explore, color: primaryColor),
      RoomCategory(id: 'sport', title: 'Спорт', icon: Icons.sports_soccer, color: const Color(0xFF42A5F5)),
      RoomCategory(id: 'games', title: 'Игры', icon: Icons.sports_esports, color: const Color(0xFF66BB6A)),
      RoomCategory(id: 'psychology', title: 'Психология', icon: Icons.psychology, color: const Color(0xFFAB47BC)),
      RoomCategory(id: 'tech', title: 'Технологии', icon: Icons.memory, color: const Color(0xFFFFA726)),
      RoomCategory(id: 'business', title: 'Бизнес', icon: Icons.business_center, color: const Color(0xFF26C6DA)),
      RoomCategory(id: 'art', title: 'Искусство', icon: Icons.palette, color: const Color(0xFFFF7043)),
    ];
  }

  static List<SortOption> _createSortOptions() {
    return [
      SortOption(id: 'newest', title: 'Сначала новые', icon: Icons.new_releases),
      SortOption(id: 'popular', title: 'По популярности', icon: Icons.trending_up),
      SortOption(id: 'subscribers', title: 'По подписчикам', icon: Icons.people),
    ];
  }

  static List<FilterOption> _createFilterOptions() {
    return [
      FilterOption(id: 'verified', title: 'Только проверенные', icon: Icons.verified),
      FilterOption(id: 'subscribed', title: 'Мои подписки', icon: Icons.subscriptions),
      FilterOption(id: 'favorites', title: 'Избранное', icon: Icons.favorite),
    ];
  }

  RoomCategory getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return RoomCategory(id: 'unknown', title: 'Неизвестно', icon: Icons.help, color: Colors.grey);
    }
  }

  String getCategoryTitle(String categoryId) {
    return getCategoryById(categoryId).title;
  }

  IconData getCategoryIcon(String categoryId) {
    return getCategoryById(categoryId).icon;
  }

  Color getCategoryColor(String categoryId) {
    return getCategoryById(categoryId).color;
  }
}