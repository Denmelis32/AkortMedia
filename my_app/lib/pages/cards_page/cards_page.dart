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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();
  int _currentTabIndex = 0;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  List<Channel> get _filteredChannels {
    List<Channel> filtered = _channels;

    // Фильтрация по категории
    if (_selectedCategoryId != 'all') {
      filtered = filtered
          .where((channel) => channel.categoryId == _selectedCategoryId)
          .toList();
    }

    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((channel) {
        return channel.title.toLowerCase().contains(_searchQuery) ||
            channel.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
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
          _searchController.clear(); // Очищаем поиск при смене категории
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
            // Исправленный заголовок "Каналы" вверху
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              title: Text(
                'Каналы',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
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
                  icon: Icon(Icons.filter_list_rounded,
                      size: 24,
                      color: Colors.grey[700]),
                  onPressed: _showFilterBottomSheet,
                  tooltip: 'Фильтры',
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск каналов...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 22),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_currentTabIndex != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Категория: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _categories[_currentTabIndex].title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentTabIndex = 0;
                                });
                              },
                              child: const Icon(Icons.close_rounded, size: 14),
                            ),
                          ],
                        ),
                      ),
                    if (_searchQuery.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Поиск: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '"$_searchQuery"',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(Icons.close_rounded, size: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _buildCategoryContent(),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),
            Text('Фильтр по категориям',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) => _buildCategoryChip(category)).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(RoomCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = _categories.indexOf(category);
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          category.title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    final category = _categories[_currentTabIndex];
    final categoryChannels = _filteredChannels;

    return categoryChannels.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Каналы не найдены',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить параметры поиска',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    )
        : GridView.builder(
      padding: const EdgeInsets.all(16),
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