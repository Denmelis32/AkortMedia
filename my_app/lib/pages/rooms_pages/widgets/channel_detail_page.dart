import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class _ChannelDetailPageState extends State<ChannelDetailPage>
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  late TabController _tabController;
  int _currentTabIndex = 0;
  String _searchQuery = '';
  List<DiscussionTopic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadChannelTopics();
  }

  @override
  void didUpdateWidget(ChannelDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel.id != widget.channel.id) {
      _loadChannelTopics();
    }
  }

  Future<void> _loadChannelTopics() async {
    setState(() => _isLoading = true);

    // Имитация загрузки данных из базы/API
    await Future.delayed(const Duration(milliseconds: 500));

    final topics = await _getTopicsForChannel(widget.channel.id);

    setState(() {
      _topics = topics;
      _isLoading = false;
    });
  }

  Future<List<DiscussionTopic>> _getTopicsForChannel(String channelId) async {
    // В реальном приложении здесь будет запрос к API/базе данных
    return [
      DiscussionTopic(
        id: '${channelId}_1',
        title: 'Добро пожаловать в канал ${widget.channel.name}!',
        description: 'Первое обсуждение в нашем канале. Расскажите о себе!',
        author: widget.channel.ownerName,
        createdAt: widget.channel.createdAt,
        tags: ['приветствие', 'новости', 'знакомство'],
        categoryId: widget.channel.categoryId,
        channelId: widget.channel.id,
        cardColor: Colors.blue,
        iconAsset: 'assets/icons/welcome.png',
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        messages: [
          Message(
            id: '${channelId}_1-1',
            text: 'Добро пожаловать в наш канал! Здесь мы обсуждаем интересные темы, связанные с ${widget.channel.tags.join(', ')}.',
            author: widget.channel.ownerName,
            timestamp: widget.channel.createdAt,
            avatarUrl: widget.channel.ownerAvatarUrl,
          ),
        ],
      ),
      if (widget.channel.recentTopicIds.isNotEmpty)
        DiscussionTopic(
          id: '${channelId}_2',
          title: 'Актуальные обсуждения',
          description: 'Самые интересные темы этого месяца',
          author: 'Модератор',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          tags: ['актуальное', 'обсуждение'],
          categoryId: widget.channel.categoryId,
          channelId: widget.channel.id,
          cardColor: Colors.green,
          iconAsset: 'assets/icons/discussion.png',
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          messages: [
            Message(
              id: '${channelId}_2-1',
              text: 'Что вы думаете о последних событиях в нашей теме?',
              author: 'Модератор',
              timestamp: DateTime.now().subtract(const Duration(days: 3)),
              avatarUrl: 'https://ui-avatars.com/api/?name=Mod&background=00AA00',
            ),
          ],
        ),
    ];
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentTabIndex = _tabController.index);
    }
  }

  bool get _isSubscribed => ChannelService.isUserSubscribed(widget.channel, widget.userId);

  void _toggleSubscription() {
    setState(() {
      ChannelService.toggleSubscription(widget.channel, widget.userId);
    });

    // Проверка достижений, связанных с подписками
    final newAchievements = AchievementService.checkSubscriptionAchievements(
      userPermissions: widget.userPermissions,
      channel: widget.channel,
      isSubscribing: !_isSubscribed, // Передаем было ли это подпиской или отпиской
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
            const Text('🎉', style: TextStyle(fontSize: 40)),
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
          children: achievements.map((achievement) => Column(
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
              const SizedBox(height: 16),
            ],
          )).toList(),
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

  void _createNewTopic() {
    // Навигация к созданию темы
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold( // Заглушка для создания темы
          appBar: AppBar(title: const Text('Создание новой темы')),
          body: Center(
            child: Text('Создание темы для канала: ${widget.channel.name}'),
          ),
        ),
      ),
    );
  }

  void _showChannelSettings() {
    if (widget.channel.ownerId == widget.userId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Настройки канала "${widget.channel.name}"'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Здесь будут настройки канала:'),
                const SizedBox(height: 16),
                Text('• Подписчиков: ${widget.channel.subscribersCount}'),
                Text('• Тем: ${_topics.length}'),
                Text('• Создан: ${DateFormat.yMd().format(widget.channel.createdAt)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Настройки сохранены')),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      );
    }
  }

  void _shareChannel() {
    // В реальном приложении используйте package:share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на канал "${widget.channel.name}" скопирована в буфер обмена'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Имитация копирования ссылки
    // Clipboard.setData(ClipboardData(text: 'https://app.com/channel/${widget.channel.id}'));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
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
            Tab(icon: Icon(Icons.forum), text: 'Обсуждения'),
            Tab(icon: Icon(Icons.people), text: 'Участники'),
            Tab(icon: Icon(Icons.info), text: 'О канале'),
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
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ChannelTopicsList(
                  topics: _topics,
                  searchQuery: _searchQuery,
                  onCreateTopic: _createNewTopic,
                  channel: widget.channel,
                  userPermissions: widget.userPermissions,
                ),

                // Вкладка участников
                ChannelMembersSection(
                  channel: widget.channel,
                  userPermissions: widget.userPermissions,
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
      floatingActionButton: _currentTabIndex == 0 && !_isLoading
          ? FloatingActionButton(
        onPressed: _createNewTopic,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}