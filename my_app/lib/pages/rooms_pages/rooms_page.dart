// lib/pages/rooms_page/rooms_page.dart
import 'package:flutter/material.dart';
import 'models/room.dart';
import 'chat_page.dart';

class RoomsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const RoomsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final List<Room> _rooms = [
    Room(
      id: 1,
      title: 'Технологии будущего',
      description: 'Обсуждаем новейшие технологии и инновации',
      imageUrl:
      'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      participants: 12450,
      messages: 89456,
      isJoined: true,
      cardColor: Colors.blue.shade800,
      categoryId: 'tech',
      lastActivity: '5 минут назад',
    ),
    Room(
      id: 2,
      title: 'Бизнес стратегии',
      description: 'Советы по ведению успешного бизнеса',
      imageUrl:
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
      participants: 8900,
      messages: 45678,
      isJoined: false,
      cardColor: Colors.purple.shade700,
      categoryId: 'business',
      lastActivity: '2 часа назад',
    ),
    Room(
      id: 3,
      title: 'Игровые обзоры',
      description: 'Новинки игровой индустрии и геймплей',
      imageUrl:
      'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400',
      participants: 15600,
      messages: 120345,
      isJoined: true,
      cardColor: Colors.red.shade800,
      categoryId: 'games',
      lastActivity: '10 минут назад',
    ),
    Room(
      id: 4,
      title: 'Программирование',
      description: 'Уроки и советы по разработке ПО',
      imageUrl:
      'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=400',
      participants: 23400,
      messages: 156789,
      isJoined: false,
      cardColor: Colors.teal.shade700,
      categoryId: 'programming',
      lastActivity: '30 минут назад',
    ),
    Room(
      id: 5,
      title: 'Спортивные новости',
      description: 'Последние события в мире спорта',
      imageUrl:
      'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400',
      participants: 17800,
      messages: 95678,
      isJoined: true,
      cardColor: Colors.orange.shade800,
      categoryId: 'sport',
      lastActivity: '1 час назад',
    ),
    Room(
      id: 6,
      title: 'Психология общения',
      description: 'Как улучшить коммуникативные навыки',
      imageUrl:
      'https://images.unsplash.com/photo-1545239351-ef35f43d514b?w=400',
      participants: 6700,
      messages: 45678,
      isJoined: false,
      cardColor: Colors.green.shade800,
      categoryId: 'psychology',
      lastActivity: '3 часа назад',
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
      id: 'tech',
      title: 'Технологии',
      description: 'Обсуждение технологий',
      icon: Icons.smartphone,
      color: Colors.blue,
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
      color: Colors.teal,
    ),
    RoomCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer,
      color: Colors.green,
    ),
    RoomCategory(
      id: 'psychology',
      title: 'Психология',
      description: 'Общение и отношения',
      icon: Icons.psychology,
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

  List<Room> get _filteredRooms {
    List<Room> filtered = _rooms;

    if (_selectedCategoryId != 'all') {
      filtered = filtered
          .where((room) => room.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((room) {
        return room.title.toLowerCase().contains(_searchQuery) ||
            room.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  void _createNewRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать новое обсуждение'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название обсуждения',
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
                _addNewRoom(
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

  void _addNewRoom(String title, String description) {
    final newRoom = Room(
      id: _rooms.length + 1,
      title: title,
      description: description,
      imageUrl:
      'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      participants: 0,
      messages: 0,
      isJoined: false,
      cardColor: _getRandomColor(),
      categoryId: _selectedCategoryId == 'all' ? 'tech' : _selectedCategoryId,
      lastActivity: 'только что',
    );

    setState(() {
      _rooms.add(newRoom);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Обсуждение создано!')),
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
      Colors.indigo.shade700,
      Colors.pink.shade700,
      Colors.cyan.shade700,
    ];
    return colors[_rooms.length % colors.length];
  }

  void _toggleJoin(int index) {
    final room = _filteredRooms[index];
    final globalIndex = _rooms.indexWhere((r) => r.id == room.id);

    if (globalIndex != -1) {
      setState(() {
        _rooms[globalIndex] = _rooms[globalIndex].copyWith(
          isJoined: !_rooms[globalIndex].isJoined,
          participants: _rooms[globalIndex].isJoined
              ? _rooms[globalIndex].participants - 1
              : _rooms[globalIndex].participants + 1,
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
          _searchController.clear();
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

  void _openChatPage(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
          userName: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRoom,
        backgroundColor: const Color(0xFF396AA3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              title: Text(
                'Обсуждения',
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
                      hintText: 'Поиск обсуждений...',
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
    final categoryRooms = _filteredRooms;

    return categoryRooms.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Обсуждения не найдены',
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
        childAspectRatio: 0.75,
      ),
      itemCount: categoryRooms.length,
      itemBuilder: (context, index) {
        final room = categoryRooms[index];
        return _buildRoomCard(room, index);
      },
    );
  }

  Widget _buildRoomCard(Room room, int index) {
    return GestureDetector(
      onTap: () => _openChatPage(room),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 0.95, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    room.cardColor.withOpacity(0.9),
                    room.cardColor.withOpacity(0.7),
                    room.cardColor.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: room.cardColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Декоративные элементы
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),

                  // Основной контент
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Аватарка с бейджем участников
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  room.imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Бейдж участников
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${room.participants.formatCount()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Заголовок
                        Text(
                          room.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Описание
                        Text(
                          room.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        // Статистика
                        Row(
                          children: [
                            // Сообщения
                            _buildStatItem(
                              Icons.chat_bubble_outline_rounded,
                              '${room.messages.formatCount()}',
                              Colors.white.withOpacity(0.8),
                            ),

                            const SizedBox(width: 16),

                            // Активность
                            _buildStatItem(
                              Icons.access_time_rounded,
                              room.lastActivity,
                              Colors.white.withOpacity(0.8),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Кнопка присоединения
                        ElevatedButton(
                          onPressed: () => _toggleJoin(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: room.isJoined
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white,
                            foregroundColor: room.isJoined
                                ? Colors.white
                                : room.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(double.infinity, 44),
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                room.isJoined ? Icons.check_circle_rounded : Icons.add_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                room.isJoined ? 'Вы участвуете' : 'Присоединиться',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Индикатор новой активности
                  if (room.lastActivity.contains('минут') || room.lastActivity.contains('только что'))
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

// Расширение для форматирования чисел
extension NumberFormatting on int {
  String formatCount() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}