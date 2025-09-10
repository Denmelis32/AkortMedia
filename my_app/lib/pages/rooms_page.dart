import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Модель для категории (Ютуб, Спорт, Игры)
class RoomCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<DiscussionTopic> topics;

  RoomCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.topics = const [],
  });
}

// Модель для темы обсуждения (комнаты)
class DiscussionTopic {
  final String id;
  final String title;
  final String description;
  final String author;
  final DateTime createdAt;
  final List<Message> messages;
  final List<String> tags;
  final AccessLevel accessLevel;
  final Color cardColor;
  final String iconAsset;
  final LinearGradient gradient;
  final String categoryId; // ID категории, к которой принадлежит комната

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.createdAt,
    this.messages = const [],
    this.tags = const [],
    this.accessLevel = AccessLevel.everyone,
    this.cardColor = Colors.lightBlue,
    this.iconAsset = 'assets/icons/default_room.png',
    required this.gradient,
    required this.categoryId,
  });

  DiscussionTopic copyWith({
    List<Message>? messages,
  }) {
    return DiscussionTopic(
      id: id,
      title: title,
      description: description,
      author: author,
      createdAt: createdAt,
      messages: messages ?? this.messages,
      tags: tags,
      accessLevel: accessLevel,
      cardColor: cardColor,
      iconAsset: iconAsset,
      gradient: gradient,
      categoryId: categoryId,
    );
  }
}

// Модель для сообщения
class Message {
  final String id;
  final String text;
  final String author;
  final DateTime timestamp;
  final String? avatarUrl;

  Message({
    required this.id,
    required this.text,
    required this.author,
    required this.timestamp,
    this.avatarUrl,
  });
}

// Уровни доступа к теме
enum AccessLevel {
  everyone('Для всех', Icons.public, Colors.green),
  seniorOnly('Только сеньоры', Icons.engineering, Colors.blue),
  longTermFans('Долгосрочные фанаты', Icons.favorite, Colors.pink);

  final String label;
  final IconData icon;
  final Color color;

  const AccessLevel(this.label, this.icon, this.color);
}

// Заглушка для проверки прав пользователя
class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String? avatarUrl;

  UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    this.avatarUrl,
  });
}

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
    // Создаем категории и добавляем демо-комнаты
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
      // Находим категорию и тему для обновления
      for (var i = 0; i < _categories.length; i++) {
        final category = _categories[i];
        final topicIndex = category.topics.indexWhere((t) => t.id == _selectedTopic!.id);
        if (topicIndex != -1) {
          // Обновляем тему с новым сообщением
          final updatedTopic = category.topics[topicIndex].copyWith(
            messages: [...category.topics[topicIndex].messages, newMessage],
          );

          // Обновляем список тем
          final updatedTopics = List<DiscussionTopic>.from(category.topics);
          updatedTopics[topicIndex] = updatedTopic;

          // Обновляем категорию
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
                return _buildCategoryCard(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(RoomCategory category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [category.color.withOpacity(0.8), category.color],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -10,
                child: Icon(
                  category.icon,
                  size: 80,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      category.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${category.topics.length} комнат',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
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

  Widget _buildRoomsList() {
    final category = _selectedCategory!;
    final accessibleTopics = category.topics.where((topic) => _hasAccessToTopic(topic)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showTopicCreation) _buildTopicCreationCard(),
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
                  return _buildTopicCard(topic, textColor);
                },
              )
            else
              _buildEmptyCategoryState(),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicCard(DiscussionTopic topic, Color textColor) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedTopic = topic),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: topic.gradient,
            boxShadow: [
              BoxShadow(
                color: topic.gradient.colors.first.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: textColor,
                            size: 24,
                          ),
                        ),
                        if (topic.accessLevel != AccessLevel.everyone)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              topic.accessLevel.icon,
                              size: 16,
                              color: textColor,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      topic.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.description.isNotEmpty ? topic.description : 'Без описания',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.9),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 6,
                      children: topic.tags.take(2).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${topic.messages.length} сообщ.',
                          style: TextStyle(
                            fontSize: 11,
                            color: textColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('dd.MM').format(topic.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: textColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildTopicCreationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Создать новую комнату в ${_selectedCategory?.title}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _topicTitleController,
              decoration: InputDecoration(
                labelText: 'Название комнаты*',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _topicDescriptionController,
              decoration: InputDecoration(
                labelText: 'Описание',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Теги:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) => FilterChip(
                label: Text(tag),
                selected: _selectedTags.contains(tag),
                onSelected: (_) => _toggleTag(tag),
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.blue[100],
                labelStyle: TextStyle(
                  color: _selectedTags.contains(tag)
                      ? Colors.blue
                      : Colors.black87,
                  fontWeight: _selectedTags.contains(tag)
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Уровень доступа:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AccessLevel.values.map((level) => FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(level.icon, size: 16, color: level.color),
                    const SizedBox(width: 6),
                    Text(level.label),
                  ],
                ),
                selected: _selectedAccessLevel == level,
                onSelected: (_) => setState(() => _selectedAccessLevel = level),
                backgroundColor: Colors.grey[100],
                selectedColor: level.color.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _selectedAccessLevel == level
                      ? level.color
                      : Colors.black87,
                  fontWeight: _selectedAccessLevel == level
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelTopicCreation,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _createNewTopic,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Создать комнату'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoom() {
    final primaryColor = _selectedTopic!.gradient.colors.first;
    final textColor = _getTextColorForBackground(primaryColor);

    return Column(
        children: [
    Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
    gradient: _selectedTopic!.gradient,
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
    ),
    ],
    ),
    child: SafeArea(
    bottom: false,
    child: Row(
    children: [
    IconButton(
    icon: Icon(Icons.arrow_back, color: textColor),
    onPressed: () => setState(() => _selectedTopic = null),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    _selectedTopic!.title,
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
    ),
    overflow: TextOverflow.ellipsis,
    ),
    Text(
    '${_selectedTopic!.messages.length} сообщений',
    style: TextStyle(
    fontSize: 14,
    color: textColor.withOpacity(0.9),
    ),
    ),
    ],
    ),
    ),
    if (_selectedTopic!.accessLevel != AccessLevel.everyone)
    Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
    _selectedTopic!.accessLevel.icon,
    color: textColor,
    size: 20,
    ),
    ),
    ],
    ),
    ),
    ),
    if (_selectedTopic!.description.isNotEmpty)
    Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: primaryColor.withOpacity(0.05),
    border: Border(
    bottom: BorderSide(color: Colors.grey[200]!),
    ),
    ),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Icon(Icons.info_outline, color: primaryColor, size: 20),
    const SizedBox(width: 12),
    Expanded(
    child: Text(
    _selectedTopic!.description,
    style: TextStyle(
    color: Colors.grey[700],
    fontSize: 14,
    ),
    ),
    ),
    ],
    ),
    ),
    Expanded(
    child: Container(
    color: Colors.grey[50],
    child: _selectedTopic!.messages.isNotEmpty
    ? ListView.builder(
    padding: const EdgeInsets.all(16),
    reverse: false,
    itemCount: _selectedTopic!.messages.length,
    itemBuilder: (context, index) {
    final message = _selectedTopic!.messages[index];
    final isCurrentUser = message.author == widget.userName;
    return _buildMessageBubble(message, isCurrentUser, primaryColor);
    },
    )
        : Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [                         Text(
      'Пока нет сообщений',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
      ),
    ),
      const SizedBox(height: 8),
      Text(
        'Будьте первым, кто напишет!',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
        ),
      ),
    ],
    ),
    ),
    ),
    ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: primaryColor),
                          onPressed: _sendMessage,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }

  Widget _buildMessageBubble(Message message, bool isCurrentUser, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: primaryColor.withOpacity(0.2),
                backgroundImage: message.avatarUrl != null
                    ? NetworkImage(message.avatarUrl!)
                    : null,
                child: message.avatarUrl == null
                    ? Text(
                  message.author[0].toUpperCase(),
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.author,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCurrentUser ? Colors.white : Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  if (!isCurrentUser) const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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