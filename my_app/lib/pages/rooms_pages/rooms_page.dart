import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/achievement_service.dart';
import 'models_room/room_category.dart';
import 'models_room/discussion_topic.dart';
import 'models_room/message.dart';
import 'models_room/access_level.dart';
import 'models_room/user_permissions.dart';
import 'models_room/achievement.dart'; // Добавляем импорт achievement
import 'widgets/category_card.dart';
import 'widgets/topic_card.dart';
import 'widgets/topic_creation_card.dart';
import 'widgets/chat_room.dart';
import 'widgets/achievements_screen.dart'; // Добавляем экран достижений

class RoomsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  final UserPermissions userPermissions;

  const RoomsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
    required this.userPermissions,
  });

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage>
    with SingleTickerProviderStateMixin {
  final List<RoomCategory> _categories = [];
  final _topicTitleController = TextEditingController();
  final _topicDescriptionController = TextEditingController();
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();

  RoomCategory? _selectedCategory;
  DiscussionTopic? _selectedTopic;
  bool _showTopicCreation = false;
  AccessLevel _selectedAccessLevel = AccessLevel.everyone;
  final List<String> _selectedTags = [];
  int _currentTabIndex = 0;
  String _searchQuery = '';
  SortType _currentSort = SortType.newest;
  TabController? _tabController;
  DateTime? _lastMessageTime; // Для отслеживания времени последнего сообщения
  Map<AchievementType, DateTime> _userAchievements = {}; // Локальные достижения

  final List<String> _availableTags = [
    'Футбол',
    'Твич',
    'Программирование',
    'Flutter',
    'Dart',
    'Игры',
    'Технологии',
    'Стримы',
    'Обсуждение',
    'Ютуб',
    'Спорт',
    'Киберспорт',
    'Бизнес',
    'Стартапы',
    'Инвестиции',
    'Маркетинг',
    'Карьера',
    'Общение',
    'Психология',
    'Отношения',
    'Социум',
    'Саморазвитие',
    'Книги',
    'Мотивация',
    'Здоровье',
    'Медитация',
  ];

  // Градиенты в стиле Apple для разных комнат
  final List<LinearGradient> _appleGradients = [
    LinearGradient(
      colors: [const Color(0xFF007AFF), const Color(0xFF0055D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFFFF2D55), const Color(0xFFD70040)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFF34C759), const Color(0xFF00A650)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFFFF9500), const Color(0xFFFF7000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFFAF52DE), const Color(0xFF9A45D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFFFF2D55), const Color(0xFFFF3B30)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFFFFD60A), const Color(0xFFFFB900)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFF30B0C7), const Color(0xFF0584B0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [const Color(0xFF8E8E93), const Color(0xFF6C6C70)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _userAchievements = Map.from(widget.userPermissions.achievements);

    // TabController будет создан после инициализации категорий
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_categories.isNotEmpty) {
        setState(() {
          _tabController = TabController(
            length: _categories.length,
            vsync: this,
            initialIndex: 0,
          );

          _tabController!.addListener(() {
            if (_tabController!.indexIsChanging) {
              setState(() {
                _currentTabIndex = _tabController!.index;
                _selectedCategory = _categories[_tabController!.index];
              });
            }
          });

          // Устанавливаем первую категорию как выбранную
          if (_selectedCategory == null) {
            _selectedCategory = _categories[0];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _topicTitleController.dispose();
    _topicDescriptionController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeCategories() {
    // Категория YouTube
    final youtubeCategory = RoomCategory(
      id: 'youtube',
      title: 'YouTube',
      description: 'Обсуждение видео, блогеров и трендов YouTube',
      icon: Icons.video_library,
      color: Colors.red,
      topics: [
        DiscussionTopic(
          id: '1',
          title: 'Лучшие YouTube каналы о технологиях',
          description:
              'Делимся находками и открытиями в мире технологических каналов',
          author: 'Техно-энтузиаст',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          tags: ['Ютуб', 'Технологии', 'Обсуждение'],
          cardColor: const Color(0xFFFF2D55),
          iconAsset: 'assets/icons/youtube.png',
          gradient: LinearGradient(
            colors: [const Color(0xFFFF2D55), const Color(0xFFD70040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'youtube',
          messages: [
            Message(
              id: '1-1',
              text: 'Обязательно посмотрите канал Marques Brownlee!',
              author: 'Техноблогер',
              timestamp: DateTime.now().subtract(
                const Duration(days: 1, hours: 5),
              ),
              avatarUrl:
                  'https://ui-avatars.com/api/?name=Tech&background=random',
            ),
          ],
        ),
        DiscussionTopic(
          id: '2',
          title: 'Топ YouTube стримеры этого месяца',
          description: 'Кого смотрим в этом месяце? Давайте составим рейтинг!',
          author: 'Стримолюб',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          tags: ['Ютуб', 'Стримы', 'Игры'],
          accessLevel: AccessLevel.longTermFans,
          cardColor: const Color(0xFFAF52DE),
          iconAsset: 'assets/icons/stream.png',
          gradient: LinearGradient(
            colors: [const Color(0xFFAF52DE), const Color(0xFF9A45D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'youtube',
        ),
      ],
    );

    // Категория Спорт
    final sportCategory = RoomCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Обсуждение спортивных событий и матчей',
      icon: Icons.sports_soccer,
      color: Colors.green,
      topics: [
        DiscussionTopic(
          id: '3',
          title: 'Обсуждаем последний матч Лиги Чемпионов',
          description:
              'Кто смотрел вчерашний матч? Давайте обсудим ключевые моменты!',
          author: 'Футбольный эксперт',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          tags: ['Футбол', 'Обсуждение'],
          cardColor: const Color(0xFF34C759),
          iconAsset: 'assets/icons/soccer.png',
          gradient: LinearGradient(
            colors: [const Color(0xFF34C759), const Color(0xFF00A650)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'sport',
          messages: [
            Message(
              id: '3-1',
              text: 'Отличный матч, просто невероятная концовка!',
              author: 'Фанат1',
              timestamp: DateTime.now().subtract(
                const Duration(days: 1, hours: 5),
              ),
              avatarUrl:
                  'https://ui-avatars.com/api/?name=Fan1&background=random',
            ),
          ],
        ),
      ],
    );

    // Категория Игры
    final gamesCategory = RoomCategory(
      id: 'games',
      title: 'Игры',
      description: 'Обсуждение видеоигр и игровой индустрии',
      icon: Icons.sports_esports,
      color: Colors.purple,
      topics: [
        DiscussionTopic(
          id: '4',
          title: 'Новые игровые релизы',
          description: 'Обсуждаем последние новинки игровой индустрии',
          author: 'Геймер',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          tags: ['Игры', 'Технологии'],
          cardColor: const Color(0xFFFF9500),
          iconAsset: 'assets/icons/game.png',
          gradient: LinearGradient(
            colors: [const Color(0xFFFF9500), const Color(0xFFFF7000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'games',
        ),
        DiscussionTopic(
          id: '5',
          title: 'Киберспортивные события',
          description: 'Обсуждаем турниры и чемпионаты по киберспорту',
          author: 'Киберспортсмен',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['Игры', 'Киберспорт'],
          accessLevel: AccessLevel.seniorOnly,
          cardColor: const Color(0xFF007AFF),
          iconAsset: 'assets/icons/esports.png',
          gradient: LinearGradient(
            colors: [const Color(0xFF007AFF), const Color(0xFF0055D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'games',
        ),
      ],
    );

    // Категория Программирование
    final programmingCategory = RoomCategory(
      id: 'programming',
      title: 'Программирование',
      description: 'Обсуждение разработки и IT технологий',
      icon: Icons.code,
      color: Colors.blue,
      topics: [
        DiscussionTopic(
          id: '6',
          title: 'Лучшие практики Flutter разработки',
          description:
              'Делимся опытом и лучшими практиками в разработке на Flutter',
          author: 'Senior Flutter Dev',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['Flutter', 'Программирование', 'Dart'],
          accessLevel: AccessLevel.seniorOnly,
          cardColor: const Color(0xFF007AFF),
          iconAsset: 'assets/icons/code.png',
          gradient: LinearGradient(
            colors: [const Color(0xFF007AFF), const Color(0xFF0055D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'programming',
          messages: [
            Message(
              id: '6-1',
              text:
                  'Рекомендую использовать Riverpod для управления состоянием',
              author: 'Профи',
              timestamp: DateTime.now().subtract(const Duration(hours: 10)),
              avatarUrl:
                  'https://ui-avatars.com/api/?name=Pro&background=random',
            ),
          ],
        ),
      ],
    );

    // Категория Бизнес
    final businessCategory = RoomCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Обсуждение бизнеса, стартапов и инвестиций',
      icon: Icons.business,
      color: Colors.orange,
      topics: [
        DiscussionTopic(
          id: '7',
          title: 'Стартапы и привлечение инвестиций',
          description: 'Делимся опытом создания бизнеса и поиска инвесторов',
          author: 'Предприниматель',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['Бизнес', 'Стартапы', 'Инвестиции'],
          cardColor: const Color(0xFFFF9500),
          iconAsset: 'assets/icons/business.png',
          gradient: LinearGradient(
            colors: [const Color(0xFFFF9500), const Color(0xFFFF7000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'business',
          messages: [
            Message(
              id: '7-1',
              text: 'Какие ниши сейчас наиболее перспективны для стартапов?',
              author: 'Начинающий',
              timestamp: DateTime.now().subtract(const Duration(hours: 5)),
              avatarUrl:
                  'https://ui-avatars.com/api/?name=Startup&background=random',
            ),
          ],
        ),
        DiscussionTopic(
          id: '8',
          title: 'Маркетинг и продвижение',
          description: 'Стратегии маркетинга и привлечения клиентов',
          author: 'Маркетолог',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          tags: ['Бизнес', 'Маркетинг', 'Карьера'],
          accessLevel: AccessLevel.seniorOnly,
          cardColor: const Color(0xFFFFD60A),
          iconAsset: 'assets/icons/marketing.png',
          gradient: LinearGradient(
            colors: [const Color(0xFFFFD60A), const Color(0xFFFFB900)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'business',
        ),
      ],
    );

    // Категория Общение
    final communicationCategory = RoomCategory(
      id: 'communication',
      title: 'Общение',
      description: 'Обсуждение отношений, психологии и социальных тем',
      icon: Icons.chat,
      color: Colors.pink,
      topics: [
        DiscussionTopic(
          id: '9',
          title: 'Психология общения',
          description:
              'Как улучшить навыки коммуникации и понимать людей лучше',
          author: 'Психолог',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['Общение', 'Психология', 'Отношения'],
          cardColor: const Color(0xFFFF2D55),
          iconAsset: 'assets/icons/psychology.png',
          gradient: LinearGradient(
            colors: [const Color(0xFFFF2D55), const Color(0xFFD70040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'communication',
          messages: [
            Message(
              id: '9-1',
              text: 'Активное слушание - ключ к успешному общению!',
              author: 'Эксперт',
              timestamp: DateTime.now().subtract(const Duration(hours: 3)),
              avatarUrl:
                  'https://ui-avatars.com/api/?name=Expert&background=random',
            ),
          ],
        ),
        DiscussionTopic(
          id: '10',
          title: 'Социальные отношения',
          description: 'Обсуждаем межличностные отношения в современном мире',
          author: 'Социолог',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          tags: ['Общение', 'Социум', 'Отношения'],
          cardColor: const Color(0xFFAF52DE),
          iconAsset: 'assets/icons/social.png',
          gradient: LinearGradient(
            colors: [const Color(0xFFAF52DE), const Color(0xFF9A45D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'communication',
        ),
      ],
    );

    // Категория Саморазвитие
    final selfDevelopmentCategory = RoomCategory(
      id: 'self_development',
      title: 'Саморазвитие',
      description: 'Личностный рост, мотивация и развитие навыков',
      icon: Icons.self_improvement,
      color: Colors.teal,
      topics: [
        DiscussionTopic(
          id: '11',
          title: 'Книги для саморазвития',
          description: 'Рекомендуем книги, которые меняют мышление и жизнь',
          author: 'Книголюб',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          tags: ['Саморазвитие', 'Книги', 'Мотивация'],
          cardColor: const Color(0xFF34C759),
          iconAsset: 'assets/icons/books.png',
          gradient: LinearGradient(
            colors: [const Color(0xFF34C759), const Color(0xFF00A650)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'self_development',
          messages: [
            Message(
              id: '11-1',
              text: '"Атомные привычки" - must read для всех!',
              author: 'Читатель',
              timestamp: DateTime.now().subtract(const Duration(hours: 8)),
              avatarUrl:
                  'https://ui-avatars.com/api/?name=Reader&background=random',
            ),
          ],
        ),
        DiscussionTopic(
          id: '12',
          title: 'Здоровый образ жизни',
          description: 'Спорт, питание и ментальное здоровье',
          author: 'ЗОЖник',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          tags: ['Саморазвитие', 'Здоровье', 'Медитация'],
          accessLevel: AccessLevel.everyone,
          cardColor: const Color(0xFF30B0C7),
          iconAsset: 'assets/icons/health.png',
          gradient: LinearGradient(
            colors: [const Color(0xFF30B0C7), const Color(0xFF0584B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          categoryId: 'self_development',
        ),
      ],
    );

    setState(() {
      _categories.addAll([
        youtubeCategory,
        sportCategory,
        gamesCategory,
        programmingCategory,
        businessCategory,
        communicationCategory,
        selfDevelopmentCategory,
      ]);

      // Устанавливаем первую категорию как выбранную
      if (_categories.isNotEmpty && _selectedCategory == null) {
        _selectedCategory = _categories[0];
      }
    });
  }

  bool _hasAccessToTopic(DiscussionTopic topic) {
    switch (topic.accessLevel) {
      case AccessLevel.everyone:
        return true;
      case AccessLevel.seniorOnly:
        return widget.userPermissions.isSeniorDeveloper;
      case AccessLevel.longTermFans:
        return widget.userPermissions.isLongTermFan ||
            DateTime.now().difference(widget.userPermissions.joinDate).inDays >
                30;
    }
  }

  void _createNewTopic() {
    if (_topicTitleController.text.isEmpty || _selectedCategory == null) return;

    final randomGradient =
        _appleGradients[_selectedCategory!.topics.length %
            _appleGradients.length];

    final newTopic = DiscussionTopic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _topicTitleController.text,
      description: _topicDescriptionController.text,
      author: widget.userName,
      createdAt: DateTime.now(),
      tags: List.from(_selectedTags),
      accessLevel: _selectedAccessLevel,
      gradient: randomGradient,
      cardColor: randomGradient.colors.first,
      iconAsset: 'assets/icons/default.png',
      categoryId: _selectedCategory!.id,
      isFavorite: false,
    );

    setState(() {
      final categoryIndex = _categories.indexWhere(
        (c) => c.id == _selectedCategory!.id,
      );
      if (categoryIndex != -1) {
        _categories[categoryIndex] = RoomCategory(
          id: _categories[categoryIndex].id,
          title: _categories[categoryIndex].title,
          description: _categories[categoryIndex].description,
          icon: _categories[categoryIndex].icon,
          color: _categories[categoryIndex].color,
          topics: [..._categories[categoryIndex].topics, newTopic],
        );
        _selectedTopic = newTopic;
      }
      _showTopicCreation = false;
      _selectedTags.clear();
      _selectedAccessLevel = AccessLevel.everyone;
    });

    _topicTitleController.clear();
    _topicDescriptionController.clear();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty || _selectedTopic == null) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text,
      author: widget.userName,
      timestamp: DateTime.now(),
      avatarUrl: widget.userPermissions.avatarUrl,
    );

    // Обновляем статистику пользователя
    final updatedUserPermissions = widget.userPermissions.copyWith(
      messagesCount: widget.userPermissions.messagesCount + 1,
      participatedCategories: {
        ...widget.userPermissions.participatedCategories,
        _selectedCategory!.id,
      },
    );

    // Проверяем достижения
    final newAchievements = AchievementService.checkAchievements(
      userPermissions: updatedUserPermissions,
      currentCategoryId: _selectedCategory!.id,
      messageTime: DateTime.now(),
      lastMessageTime: _lastMessageTime,
      currentTopicMessageCount: _selectedTopic!.messages.length + 1,
    );

    // Показываем полученные достижения
    if (newAchievements.isNotEmpty) {
      _showAchievements(newAchievements);
      // Обновляем локальные достижения
      setState(() {
        for (final achievement in newAchievements) {
          _userAchievements[achievement.type] = achievement.earnedAt;
        }
      });
    }

    setState(() {
      // Обновляем время последнего сообщения
      _lastMessageTime = DateTime.now();

      for (var i = 0; i < _categories.length; i++) {
        final category = _categories[i];
        final topicIndex = category.topics.indexWhere(
          (t) => t.id == _selectedTopic!.id,
        );
        if (topicIndex != -1) {
          final updatedTopic = category.topics[topicIndex].copyWith(
            messages: [...category.topics[topicIndex].messages, newMessage],
          );

          final updatedTopics = List<DiscussionTopic>.from(category.topics);
          updatedTopics[topicIndex] = updatedTopic;

          _categories[i] = RoomCategory(
            id: category.id,
            title: category.title,
            description: category.description,
            icon: category.icon,
            color: category.color,
            topics: updatedTopics,
          );

          _selectedTopic = updatedTopic;
          break;
        }
      }
    });

    _messageController.clear();
  }

  void _cancelTopicCreation() {
    setState(() {
      _showTopicCreation = false;
      _topicTitleController.clear();
      _topicDescriptionController.clear();
      _selectedTags.clear();
      _selectedAccessLevel = AccessLevel.everyone;
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _changeAccessLevel(AccessLevel level) {
    setState(() {
      _selectedAccessLevel = level;
    });
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  void _showAchievements(List<Achievement> achievements) {
    for (final achievement in achievements) {
      _showAchievementDialog(achievement);
    }
  }

  void _showAchievementDialog(Achievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.amber[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.amber, width: 3),
        ),
        title: Column(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              'Достижение разблокировано!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Круто!',
              style: TextStyle(
                color: Colors.amber[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedTopic != null
            ? Text(_selectedTopic!.title)
            : const Text('Категории комнат'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: _selectedTopic != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _selectedTopic = null);
                },
              )
            : null,
        bottom:
            _selectedTopic == null &&
                !_showTopicCreation &&
                _categories.isNotEmpty &&
                _tabController != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: ColoredBox(
                  color: Colors.white,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController!,
                        isScrollable: true,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _categories[_currentTabIndex].color,
                              width: 3,
                            ),
                          ),
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        tabs: _categories.map((category) {
                          final index = _categories.indexOf(category);
                          return Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category.icon,
                                  size: 18,
                                  color: index == _currentTabIndex
                                      ? category.color
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(category.title),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        actions: [
          if (_selectedCategory != null &&
              _selectedTopic == null &&
              !_showTopicCreation)
            IconButton(
              icon: const Icon(Icons.emoji_events, color: Colors.amber),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AchievementsScreen(achievements: _userAchievements),
                ),
              ),
              tooltip: 'Мои достижения',
            ),
          if (_selectedCategory != null &&
              _selectedTopic == null &&
              !_showTopicCreation)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () => setState(() => _showTopicCreation = true),
              tooltip: 'Создать комнату',
            ),
          if (_selectedCategory == null && _selectedTopic == null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.blue),
              onPressed: widget.onLogout,
              tooltip: 'Выйти',
            ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton:
          _selectedCategory != null &&
              _selectedTopic == null &&
              !_showTopicCreation
          ? FloatingActionButton(
              onPressed: () => setState(() => _showTopicCreation = true),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              elevation: 2,
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_selectedTopic != null) {
      return _buildChatRoom();
    } else if (_selectedCategory != null) {
      return _buildRoomsList();
    } else {
      return _buildCategoriesList();
    }
  }

  Widget _buildCategoriesList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Категории комнат',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите категорию для обсуждения',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () {
                    final categoryIndex = _categories.indexWhere(
                      (c) => c.id == category.id,
                    );
                    if (categoryIndex != -1 && _tabController != null) {
                      setState(() {
                        _tabController!.animateTo(categoryIndex);
                        _selectedCategory = category;
                        _currentTabIndex = categoryIndex;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList() {
    final category = _selectedCategory!;
    final accessibleTopics = category.topics
        .where((topic) => _hasAccessToTopic(topic))
        .toList();

    // Применяем поиск если нужно
    final filteredTopics = _searchQuery.isEmpty
        ? accessibleTopics
        : accessibleTopics
              .where(
                (topic) =>
                    topic.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    topic.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    topic.tags.any(
                      (tag) => tag.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();

    // Сортируем topics
    final sortedTopics = _sortTopics(filteredTopics);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showTopicCreation)
            TopicCreationCard(
              titleController: _topicTitleController,
              descriptionController: _topicDescriptionController,
              selectedTags: _selectedTags,
              availableTags: _availableTags,
              selectedAccessLevel: _selectedAccessLevel,
              onCreate: _createNewTopic,
              onCancel: _cancelTopicCreation,
              onToggleTag: _toggleTag,
              onAccessLevelChanged: _changeAccessLevel,
              categoryTitle: category.title,
            ),
          if (!_showTopicCreation) ...[
            // Заголовок категории
            Row(
              children: [
                Icon(category.icon, color: category.color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              category.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Поисковая строка
            _buildSearchField(),

            // Сортировка
            const SizedBox(height: 16),
            _buildSortButtons(),

            const SizedBox(height: 24),

            if (sortedTopics.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: sortedTopics.length,
                itemBuilder: (context, index) {
                  final topic = sortedTopics[index];
                  final textColor = _getTextColorForBackground(
                    topic.gradient.colors.first,
                  );
                  return TopicCard(
                    topic: topic,
                    textColor: textColor,
                    onTap: () => setState(() => _selectedTopic = topic),
                    onFavoriteToggle: () => _toggleFavorite(topic),
                  );
                },
              )
            else if (_searchQuery.isNotEmpty)
              _buildNoSearchResults()
            else
              _buildEmptyCategoryState(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Поиск комнат...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  FocusScope.of(context).unfocus();
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _selectedCategory?.color ?? Colors.blue,
          ),
        ),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildSortButtons() {
    return Row(
      children: [
        _buildSortButton('Новые', SortType.newest),
        const SizedBox(width: 8),
        _buildSortButton('Популярные', SortType.popular),
        const SizedBox(width: 8),
        _buildSortButton('А-Я', SortType.alphabetical),
      ],
    );
  }

  Widget _buildSortButton(String text, SortType type) {
    final isSelected = _currentSort == type;
    return GestureDetector(
      onTap: () => setState(() => _currentSort = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (_selectedCategory?.color ?? Colors.blue).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (_selectedCategory?.color ?? Colors.blue)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? (_selectedCategory?.color ?? Colors.blue)
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  List<DiscussionTopic> _sortTopics(List<DiscussionTopic> topics) {
    switch (_currentSort) {
      case SortType.newest:
        return topics..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortType.popular:
        return topics
          ..sort((a, b) => b.messages.length.compareTo(a.messages.length));
      case SortType.alphabetical:
        return topics..sort((a, b) => a.title.compareTo(b.title));
    }
  }

  Widget _buildNoSearchResults() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Ничего не найдено',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Попробуйте изменить поисковый запрос',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoom() {
    return ChatRoom(
      topic: _selectedTopic!,
      messageController: _messageController,
      onSendMessage: _sendMessage,
      onBack: () => setState(() => _selectedTopic = null),
      userName: widget.userName,
      userAvatarUrl: widget.userPermissions.avatarUrl,
    );
  }

  Widget _buildEmptyCategoryState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_selectedCategory!.icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Пока нет комнат',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Будьте первым, кто создаст комнату в этой категории!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _showTopicCreation = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedCategory!.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Создать первую комнату'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(DiscussionTopic topic) {
    setState(() {
      for (var i = 0; i < _categories.length; i++) {
        final category = _categories[i];
        final topicIndex = category.topics.indexWhere((t) => t.id == topic.id);
        if (topicIndex != -1) {
          final updatedTopic = category.topics[topicIndex].copyWith(
            isFavorite: !category.topics[topicIndex].isFavorite,
          );

          final updatedTopics = List<DiscussionTopic>.from(category.topics);
          updatedTopics[topicIndex] = updatedTopic;

          _categories[i] = RoomCategory(
            id: category.id,
            title: category.title,
            description: category.description,
            icon: category.icon,
            color: category.color,
            topics: updatedTopics,
          );

          // Обновляем selectedTopic если это текущая тема
          if (_selectedTopic?.id == topic.id) {
            _selectedTopic = updatedTopic;
          }
          break;
        }
      }
    });

    // Показываем snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          topic.isFavorite ? 'Убрано из избранного' : 'Добавлено в избранное',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// Добавляем enum для сортировки
enum SortType { newest, popular, alphabetical }
