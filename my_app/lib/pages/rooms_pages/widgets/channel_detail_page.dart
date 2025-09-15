import 'dart:async';

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

// ДОБАВЛЯЕМ ИМПОРТ ДЛЯ НОВОСТЕЙ
import 'package:provider/provider.dart';
import '../../../providers/news_provider.dart';
import '../../../services/api_service.dart';

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
    debugPrint('ChannelDetailPage initState for channel: ${widget.channel.id}');
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Отложенная загрузка после построения виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChannelTopics();
    });
  }

  @override
  void didUpdateWidget(ChannelDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel.id != widget.channel.id) {
      debugPrint('Channel changed, reloading topics...');
      _loadChannelTopics();
    }
  }

  Future<void> _loadChannelTopics() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final topics = await _getTopicsForChannel(
        widget.channel.id,
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _topics = topics;
          _isLoading = false;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Таймаут загрузки данных')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  }

  Future<List<DiscussionTopic>> _getTopicsForChannel(String channelId) async {
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
            text:
            'Добро пожаловать в наш канал! Здесь мы обсуждаем интересные темы, связанные с ${widget.channel.tags.join(', ')}.',
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
              avatarUrl:
              'https://ui-avatars.com/api/?name=Mod&background=00AA00',
            ),
          ],
        ),
    ];
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging && mounted) {
      setState(() => _currentTabIndex = _tabController.index);
    }
  }

  bool get _isSubscribed =>
      ChannelService.isUserSubscribed(widget.channel, widget.userId);

  void _toggleSubscription() {
    if (!mounted) return;

    setState(() {
      ChannelService.toggleSubscription(widget.channel, widget.userId);
    });

    final newAchievements = AchievementService.checkSubscriptionAchievements(
      userPermissions: widget.userPermissions,
      channel: widget.channel,
      isSubscribing: !_isSubscribed,
    );

    if (newAchievements.isNotEmpty) {
      _showAchievements(newAchievements);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSubscribed ? 'Подписались на канал' : 'Отписались от канала',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
          children: achievements
              .map(
                (achievement) => Column(
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
            ),
          )
              .toList(),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildCreateOptionsSheet(context),
    );
  }

  Widget _buildCreateOptionsSheet(BuildContext sheetContext) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Создать в канале "${widget.channel.name}"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(sheetContext).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _createDiscussionTopic();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum, color: Colors.white),
                SizedBox(width: 10),
                Text('Обсуждение', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _createNewsPost();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article, color: Colors.white),
                SizedBox(width: 10),
                Text('Новость', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _createDiscussionTopic() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Создание новой темы')),
          body: Center(
            child: Text('Создание темы для канала: ${widget.channel.name}'),
          ),
        ),
      ),
    );
  }

  void _createNewsPost() {
    // Убираем задержку, так как она может вызывать проблемы
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildNewsCreationDialog(context),
    );
  }

  Widget _buildNewsCreationDialog(BuildContext dialogContext) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final hashtagsController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        bool _isDialogLoading = false;

        Future<void> _createNews() async {
          if (titleController.text.isEmpty ||
              descriptionController.text.isEmpty) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(
                content: Text('Заполните обязательные поля'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          setState(() => _isDialogLoading = true);

          try {
            final newsProvider = Provider.of<NewsProvider>(
              dialogContext,
              listen: false,
            );

            final newNews = await ApiService.createNews({
              'title': titleController.text,
              'description': descriptionController.text,
              'hashtags': hashtagsController.text.isNotEmpty
                  ? hashtagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .toList()
                  : [],
              'channel_id': widget.channel.id,
              'channel_name': widget.channel.name,
              'author_name': widget.userPermissions.userName,
            }).timeout(const Duration(seconds: 10));

            Navigator.of(dialogContext).pop();

            newsProvider.addNews({
              ...newNews,
              'comments': [],
              'likes': 0,
              'created_at': DateTime.now().toIso8601String(),
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Новость "${titleController.text}" создана!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } on TimeoutException {
            setState(() => _isDialogLoading = false);
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(content: Text('Таймаут при создании новости')),
            );
          } catch (e) {
            print('Error creating news: $e');
            setState(() => _isDialogLoading = false);

            final newsProvider = Provider.of<NewsProvider>(
              dialogContext,
              listen: false,
            );
            newsProvider.addNews({
              "id": "local-${DateTime.now().millisecondsSinceEpoch}",
              "title": titleController.text,
              "description": descriptionController.text,
              "hashtags": hashtagsController.text.isNotEmpty
                  ? hashtagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .toList()
                  : [],
              "channel_id": widget.channel.id,
              "channel_name": widget.channel.name,
              "likes": 0,
              "author_name": widget.userPermissions.userName,
              "created_at": DateTime.now().toIso8601String(),
              "comments": [],
            });

            Navigator.of(dialogContext).pop();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Новость создана (офлайн)'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        }

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.article, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Новость в канале ${widget.channel.name}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              if (!_isDialogLoading)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isDialogLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Публикация...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок новости*',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLength: 100,
                  enabled: !_isDialogLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Текст новости*',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                  enabled: !_isDialogLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hashtagsController,
                  decoration: const InputDecoration(
                    labelText: 'Теги (через запятую)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  enabled: !_isDialogLoading,
                ),
              ],
            ),
          ),
          actions: [
            if (!_isDialogLoading)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Отмена'),
              ),
            ElevatedButton(
              onPressed: _isDialogLoading ? null : _createNews,
              child: _isDialogLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Опубликовать'),
            ),
          ],
        );
      },
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
                Text(
                  '• Создан: ${DateFormat.yMd().format(widget.channel.createdAt)}',
                ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ссылка на канал "${widget.channel.name}" скопирована в буфер обмена',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
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
          ChannelHeader(
            channel: widget.channel,
            isSubscribed: _isSubscribed,
            onSubscribe: _toggleSubscription,
          ),
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ChannelTopicsList(
                  topics: _topics,
                  searchQuery: _searchQuery,
                  onCreateTopic: _createNewTopic,
                  channel: widget.channel,
                  userPermissions: widget.userPermissions,
                ),
                ChannelMembersSection(
                  channel: widget.channel,
                  userPermissions: widget.userPermissions,
                ),
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