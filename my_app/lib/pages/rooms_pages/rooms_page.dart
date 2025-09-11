import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models_room/room_category.dart';
import 'models_room/discussion_topic.dart';
import 'models_room/message.dart';
import 'models_room/access_level.dart';
import 'models_room/user_permissions.dart';
import 'widgets/category_card.dart';
import 'widgets/topic_card.dart';
import 'widgets/topic_creation_card.dart';
import 'widgets/chat_room.dart';

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

class _RoomsPageState extends State<RoomsPage> {
  final List<RoomCategory> _categories = [];
  final _topicTitleController = TextEditingController();
  final _topicDescriptionController = TextEditingController();
  final _messageController = TextEditingController();

  RoomCategory? _selectedCategory;
  DiscussionTopic? _selectedTopic;
  bool _showTopicCreation = false;
  AccessLevel _selectedAccessLevel = AccessLevel.everyone;
  final List<String> _selectedTags = [];
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
    'Киберспорт'
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
  ];

  @override
  void initState() {
    super.initState();
    _initializeCategories();
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
          description: 'Делимся находками и открытиями в мире технологических каналов',
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
              timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
              avatarUrl: 'https://ui-avatars.com/api/?name=Tech&background=random',
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
          description: 'Кто смотрел вчерашний матч? Давайте обсудим ключевые моменты!',
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
              timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
              avatarUrl: 'https://ui-avatars.com/api/?name=Fan1&background=random',
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
          description: 'Делимся опытом и лучшими практиками в разработке на Flutter',
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
              text: 'Рекомендую использовать Riverpod для управления состоянием',
              author: 'Профи',
              timestamp: DateTime.now().subtract(const Duration(hours: 10)),
              avatarUrl: 'https://ui-avatars.com/api/?name=Pro&background=random',
            ),
          ],
        ),
      ],
    );

    setState(() {
      _categories.addAll([
        youtubeCategory,
        sportCategory,
        gamesCategory,
        programmingCategory,
      ]);
    });
  }

  @override
  void dispose() {
    _topicTitleController.dispose();
    _topicDescriptionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _hasAccessToTopic(DiscussionTopic topic) {
    switch (topic.accessLevel) {
      case AccessLevel.everyone:
        return true;
      case AccessLevel.seniorOnly:
        return widget.userPermissions.isSeniorDeveloper;
      case AccessLevel.longTermFans:
        return widget.userPermissions.isLongTermFan ||
            DateTime.now().difference(widget.userPermissions.joinDate).inDays > 30;
    }
  }

  void _createNewTopic() {
    if (_topicTitleController.text.isEmpty || _selectedCategory == null) return;

    final randomGradient = _appleGradients[_selectedCategory!.topics.length % _appleGradients.length];

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
      categoryId: _selectedCategory!.id,
    );

    setState(() {
      final categoryIndex = _categories.indexWhere((c) => c.id == _selectedCategory!.id);
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

    setState(() {
      for (var i = 0; i < _categories.length; i++) {
        final category = _categories[i];
        final topicIndex = category.topics.indexWhere((t) => t.id == _selectedTopic!.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedCategory != null
            ? Text(_selectedCategory!.title)
            : const Text('Категории комнат'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: _selectedCategory != null || _selectedTopic != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedTopic != null) {
              setState(() => _selectedTopic = null);
            } else if (_selectedCategory != null) {
              setState(() => _selectedCategory = null);
            }
          },
        )
            : null,
        actions: [
          if (_selectedCategory != null && _selectedTopic == null && !_showTopicCreation)
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
      floatingActionButton: _selectedCategory != null &&
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
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
                  onTap: () => setState(() => _selectedCategory = category),
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
    final accessibleTopics = category.topics.where((topic) => _hasAccessToTopic(topic)).toList();

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
            Row(
              children: [
                Icon(category.icon, color: category.color, size: 32),
                const SizedBox(width: 12),
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              category.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (accessibleTopics.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: accessibleTopics.length,
                itemBuilder: (context, index) {
                  final topic = accessibleTopics[index];
                  final textColor = _getTextColorForBackground(topic.gradient.colors.first);
                  return TopicCard(
                    topic: topic,
                    textColor: textColor,
                    onTap: () => setState(() => _selectedTopic = topic),
                  );
                },
              )
            else
              _buildEmptyCategoryState(),
          ],
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
          Icon(
            _selectedCategory!.icon,
            size: 64,
            color: Colors.grey[300],
          ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
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
}