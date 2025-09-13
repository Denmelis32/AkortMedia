import 'package:flutter/material.dart';
import 'package:my_app/services/channel_service.dart';
import 'package:my_app/services/achievement_service.dart';
import '../models_room/achievement.dart';
import '../models_room/channel.dart';
import '../models_room/discussion_topic.dart';
import '../models_room/message.dart';
import '../models_room/user_permissions.dart';
import '../widgets/channel_header.dart';
import '../widgets/channel_topics_list.dart';
import '../widgets/channel_members_section.dart';
import '../widgets/channel_about_section.dart';

class ChannelDetailPage extends StatefulWidget {
  final Channel channel;
  final String userId;
  final UserPermissions userPermissions;

  const ChannelDetailPage({
    super.key,
    required this.channel,
    required this.userId,
    required this.userPermissions,
  });

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  late TabController _tabController;
  int _currentTabIndex = 0;
  String _searchQuery = '';
  bool _isSubscribed = false;

  // Для демонстрации - в реальном приложении брать из базы
  final List<DiscussionTopic> _demoTopics = [
    DiscussionTopic(
      id: '1',
      title: 'Добро пожаловать в канал!',
      description: 'Первое обсуждение в нашем канале',
      author: 'Владелец канала',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['приветствие', 'новости'],
      categoryId: 'general',
      channelId: 'general',
      cardColor: Colors.blue,
      iconAsset: 'assets/icons/welcome.png', // Добавьте путь к иконке
      gradient: const LinearGradient( // Добавьте градиент
        colors: [Colors.blue, Colors.lightBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      messages: [
        Message(
          id: '1-1',
          text: 'Добро пожаловать в наш канал! Здесь мы обсуждаем интересные темы.',
          author: 'Владелец канала',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          avatarUrl: 'https://ui-avatars.com/api/?name=Owner&background=007AFF',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _isSubscribed = ChannelService.isUserSubscribed(widget.channel, widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentTabIndex = _tabController.index);
    }
  }

  void _toggleSubscription() {
    setState(() {
      ChannelService.toggleSubscription(widget.channel, widget.userId);
      _isSubscribed = ChannelService.isUserSubscribed(widget.channel, widget.userId);
    });

    // Проверка достижений
    final newAchievements = AchievementService.checkAchievements(
      userPermissions: widget.userPermissions.copyWith(
        messagesCount: widget.userPermissions.messagesCount,
      ),
      currentCategoryId: widget.channel.categoryId,
      messageTime: DateTime.now(),
    );

    if (newAchievements.isNotEmpty) {
      _showAchievements(newAchievements);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSubscribed ? 'Подписались на канал' : 'Отписались от канала'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAchievements(List<Achievement> achievements) {
    // Реализация показа достижений
  }

  void _createNewTopic() {
    // Навигация к созданию темы
  }

  void _showChannelSettings() {
    // Показать настройки канала (только для владельца)
    if (widget.channel.ownerId == widget.userId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Настройки канала'),
          content: const Text('Здесь будут настройки канала'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: [
          if (widget.channel.ownerId == widget.userId)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showChannelSettings,
              tooltip: 'Настройки канала',
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareChannel,
            tooltip: 'Поделиться каналом',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Обсуждения'),
            Tab(text: 'Участники'),
            Tab(text: 'О канале'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Шапка канала
          ChannelHeader(
            channel: widget.channel,
            isSubscribed: _isSubscribed,
            onSubscribe: _toggleSubscription,
          ),

          // Поле поиска
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск в канале...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                    _searchController.clear();
                  },
                )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Контент вкладок
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Вкладка обсуждений
                ChannelTopicsList(
                  topics: _demoTopics,
                  searchQuery: _searchQuery,
                  onCreateTopic: _createNewTopic,
                  channel: widget.channel,
                  userPermissions: widget.userPermissions,
                ),

                // Вкладка участников
                ChannelMembersSection(
                  channel: widget.channel,
                  userPermissions: widget.userPermissions,
                  parentContext: context, // Добавлен обязательный параметр
                ),

                // Вкладка о канале
                ChannelAboutSection(
                  channel: widget.channel,
                  onSubscribe: _toggleSubscription,
                  isSubscribed: _isSubscribed,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton(
        onPressed: _createNewTopic,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  void _shareChannel() {
    // Логика分享 канала
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция分享 будет реализована позже')),
    );
  }
}