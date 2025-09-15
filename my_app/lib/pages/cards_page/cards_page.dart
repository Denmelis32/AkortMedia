// lib/pages/cards_page/cards_page.dart
import 'package:flutter/material.dart';
import 'models/channel.dart';
import 'channel_detail_page.dart';

class CardsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const CardsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final List<Channel> _channels = [
    Channel(
      id: 1,
      title: 'Технологии будущего',
      description: 'Обсуждаем новейшие технологии и инновации',
      imageUrl:
      'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      subscribers: 12450,
      videos: 89,
      isSubscribed: true,
      cardColor: Colors.blue.shade800,
      categoryId: 'youtube',
    ),
    Channel(
      id: 2,
      title: 'Бизнес стратегии',
      description: 'Советы по ведению успешного бизнеса',
      imageUrl:
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
      subscribers: 8900,
      videos: 67,
      isSubscribed: false,
      cardColor: Colors.purple.shade700,
      categoryId: 'business',
    ),
    Channel(
      id: 3,
      title: 'Игровые обзоры',
      description: 'Новинки игровой индустрии и геймплей',
      imageUrl:
      'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400',
      subscribers: 15600,
      videos: 120,
      isSubscribed: true,
      cardColor: Colors.red.shade800,
      categoryId: 'games',
    ),
    Channel(
      id: 4,
      title: 'Программирование',
      description: 'Уроки и советы по разработке ПО',
      imageUrl:
      'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=400',
      subscribers: 23400,
      videos: 156,
      isSubscribed: false,
      cardColor: Colors.teal.shade700,
      categoryId: 'programming',
    ),
    Channel(
      id: 5,
      title: 'Спортивные новости',
      description: 'Последние события в мире спорта',
      imageUrl:
      'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400',
      subscribers: 17800,
      videos: 95,
      isSubscribed: true,
      cardColor: Colors.orange.shade800,
      categoryId: 'sport',
    ),
    Channel(
      id: 6,
      title: 'Психология общения',
      description: 'Как улучшить коммуникативные навыки',
      imageUrl:
      'https://images.unsplash.com/photo-1545239351-ef35f43d514b?w=400',
      subscribers: 6700,
      videos: 45,
      isSubscribed: false,
      cardColor: Colors.green.shade800,
      categoryId: 'communication',
    ),
  ];

  final List<RoomCategory> _categories = [
    RoomCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive,
      color: Colors.blue,
    ),
    RoomCategory(
      id: 'youtube',
      title: 'YouTube',
      description: 'Обсуждение видео и блогеров',
      icon: Icons.video_library,
      color: Colors.red,
    ),
    RoomCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Стартапы и инвестиции',
      icon: Icons.business,
      color: Colors.orange,
    ),
    RoomCategory(
      id: 'games',
      title: 'Игры',
      description: 'Игровая индустрия',
      icon: Icons.sports_esports,
      color: Colors.purple,
    ),
    RoomCategory(
      id: 'programming',
      title: 'Программирование',
      description: 'Разработка и IT',
      icon: Icons.code,
      color: Colors.blue,
    ),
    RoomCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer,
      color: Colors.green,
    ),
    RoomCategory(
      id: 'communication',
      title: 'Общение',
      description: 'Психология и отношения',
      icon: Icons.chat,
      color: Colors.pink,
    ),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();
  int _currentTabIndex = 0;
  String _selectedCategoryId = 'all';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  List<Channel> get _filteredChannels {
    if (_selectedCategoryId == 'all') {
      return _channels;
    }
    return _channels
        .where((channel) => channel.categoryId == _selectedCategoryId)
        .toList();
  }

  void _createNewChannel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать новый канал'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название канала',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _addNewChannel(
                  _titleController.text,
                  _descriptionController.text,
                );
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _addNewChannel(String title, String description) {
    final newChannel = Channel(
      id: _channels.length + 1,
      title: title,
      description: description,
      imageUrl:
      'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      subscribers: 0,
      videos: 0,
      isSubscribed: false,
      cardColor: _getRandomColor(),
      categoryId: _selectedCategoryId == 'all' ? 'youtube' : _selectedCategoryId,
    );

    setState(() {
      _channels.add(newChannel);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Канал создан!')),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade800,
      Colors.purple.shade700,
      Colors.red.shade800,
      Colors.teal.shade700,
      Colors.orange.shade800,
      Colors.green.shade800,
    ];
    return colors[_channels.length % colors.length];
  }

  void _toggleSubscription(int index) {
    final channel = _filteredChannels[index];
    final globalIndex = _channels.indexWhere((c) => c.id == channel.id);

    if (globalIndex != -1) {
      setState(() {
        _channels[globalIndex] = _channels[globalIndex].copyWith(
          isSubscribed: !_channels[globalIndex].isSubscribed,
          subscribers: _channels[globalIndex].isSubscribed
              ? _channels[globalIndex].subscribers - 1
              : _channels[globalIndex].subscribers + 1,
        );
      });
    }
  }

  Widget _buildTabItem(RoomCategory category, int index) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
          _selectedCategoryId = category.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? category.color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? category.color : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              category.title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChannel,
        backgroundColor: const Color(0xFF396AA3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Каналы',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF007AFF),
                        Color(0xFF5856D6),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Привет, ${widget.userName}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: ColoredBox(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return _buildTabItem(category, index);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app_rounded),
                  onPressed: widget.onLogout,
                  tooltip: 'Выйти',
                ),
              ],
            ),
          ];
        },
        body: _buildCategoryContent(),
      ),
    );
  }

  Widget _buildCategoryContent() {
    final category = _categories[_currentTabIndex];
    final categoryChannels = _filteredChannels;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок категории (только для конкретных категорий, не для "Все")
          if (_currentTabIndex != 0) ...[
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
              category.description ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
          ],

          // Сетка каналов
          if (categoryChannels.isNotEmpty)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: categoryChannels.length,
                itemBuilder: (context, index) {
                  final channel = categoryChannels[index];
                  return _buildChannelCard(channel, index);
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category.icon, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    Text(
                      'Пока нет каналов',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentTabIndex == 0
                          ? 'Каналы появятся после создания'
                          : 'Создайте первый канал в этой категории!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChannelCard(Channel channel, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChannelDetailPage(channel: channel),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                channel.cardColor,
                channel.cardColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    '${channel.subscribers} подписчиков',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(channel.imageUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      channel.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      channel.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.video_library,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${channel.videos} видео',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _toggleSubscription(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: channel.isSubscribed
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white,
                        foregroundColor: channel.isSubscribed
                            ? Colors.white
                            : const Color(0xFF396AA3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 36),
                      ),
                      child: Text(
                        channel.isSubscribed ? 'Отписаться' : 'Подписаться',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
}

// Модель категории
class RoomCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  RoomCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });
}