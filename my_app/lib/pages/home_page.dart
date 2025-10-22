import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'news_page/news_page.dart';
import 'predictions_league_page/predictions_league_page.dart';
import 'articles_pages/articles_page.dart';
import 'rooms_pages/rooms_page.dart';
import 'cards_pages/cards_page.dart';
import 'event_page/event_list_screen.dart';
import 'media_gallery_page.dart'; // ДОБАВЛЯЕМ ИМПОРТ

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  bool _isSidebarVisible = true;

  // Определяем, является ли устройство компьютером
  bool get _isDesktop {
    final width = MediaQuery.of(context).size.width;
    return width > 1024;
  }

  // ОБНОВЛЕННЫЕ ЦВЕТА ДЛЯ КАЖДОЙ ВКЛАДКИ (добавляем цвет для медиа)
  final List<Color> _tabColors = [
    const Color(0xFF7E57C2), // NewsPage - фиолетовый
    const Color(0xFF2E8B57), // ArticlesPage - зеленый
    const Color(0xFFFb5679), // CardsPage - розовый
    const Color(0xFF26A69A), // AdaptiveRoomsPage - бирюзовый
    const Color(0xFF9E2C21), // PredictionsLeaguePage - красный
    const Color(0xFF1B2A30), // EventListScreen - темный сине-зеленый
    const Color(0xFF2196F3), // MediaGalleryPage - синий (НОВАЯ ВКЛАДКА)
  ];

  // Иконки для боковой панели (добавляем иконку для медиа)
  final List<IconData> _tabIcons = [
    Icons.newspaper_rounded,
    Icons.article_rounded,
    Icons.video_library_rounded,
    Icons.chat_rounded,
    Icons.sports_soccer_rounded,
    Icons.event_rounded,
    Icons.photo_library_rounded, // НОВАЯ ИКОНКА ДЛЯ МЕДИА
  ];

  // Названия для боковой панели (добавляем название для медиа)
  final List<String> _tabLabels = [
    'Лента',
    'Статьи',
    'Каналы',
    'Обсуждение',
    'Прогнозы',
    'События',
    'Медиа', // НОВАЯ ВКЛАДКА
  ];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      NewsPage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      ArticlesPage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      CardsPage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
        userAvatarUrl: '',
      ),
      AdaptiveRoomsPage(onLogout: widget.onLogout),
      PredictionsLeaguePage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      EventListScreen(),
      MediaGalleryPage(userName: widget.userName), // НОВАЯ СТРАНИЦА
    ];
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName ||
        oldWidget.userEmail != widget.userEmail) {
      _initializePages();
    }
  }

  // Виджет плавающей кнопки для показа боковой панели
  Widget _buildSidebarToggleButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarVisible ? 280 : 20,
      top: 20,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isSidebarVisible = !_isSidebarVisible;
          });
        },
        backgroundColor: _tabColors[_currentIndex],
        foregroundColor: Colors.white,
        mini: true,
        child: Icon(
          _isSidebarVisible ? Icons.menu_open_rounded : Icons.menu_rounded,
        ),
      ),
    );
  }

  // Виджет боковой панели для компьютера
  Widget _buildDesktopSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSidebarVisible ? 280 : 0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _tabColors[_currentIndex].withOpacity(0.95),
            _darkenColor(_tabColors[_currentIndex], 0.2).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: _isSidebarVisible
          ? Column(
              children: [
                // Заголовок и кнопка закрытия
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Меню',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSidebarVisible = false;
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        tooltip: 'Скрыть панель',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Навигационные пункты - УПРОЩЕННАЯ СТРУКТУРА
                Expanded(
                  child: ListView.builder(
                    itemCount: _tabLabels.length,
                    itemBuilder: (context, index) {
                      final isSelected = _currentIndex == index;
                      return _buildDesktopNavItem(
                        icon: _tabIcons[index],
                        label: _tabLabels[index],
                        index: index,
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),

                // Информация о пользователе
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: _tabColors[_currentIndex],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDesktopNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Виджет для мобильных устройств
  Widget _buildMobileBottomNav() {
    final currentColor = _tabColors[_currentIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            currentColor.withOpacity(0.95),
            _darkenColor(currentColor, 0.2).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
          items: [
            _buildBottomNavItem(
              icon: Icons.newspaper_rounded,
              label: 'Лента',
              index: 0,
              currentColor: currentColor,
            ),
            _buildBottomNavItem(
              icon: Icons.article_rounded,
              label: 'Статьи',
              index: 1,
              currentColor: currentColor,
            ),
            _buildBottomNavItem(
              icon: Icons.video_library_rounded,
              label: 'Каналы',
              index: 2,
              currentColor: currentColor,
            ),
            _buildBottomNavItem(
              icon: Icons.chat_rounded,
              label: 'Обсуждение',
              index: 3,
              currentColor: currentColor,
            ),
            _buildBottomNavItem(
              icon: Icons.sports_soccer_rounded,
              label: 'Прогнозы',
              index: 4,
              currentColor: currentColor,
            ),
            _buildBottomNavItem(
              icon: Icons.event_rounded,
              label: 'События',
              index: 5,
              currentColor: currentColor,
            ),
            _buildBottomNavItem(
              // НОВАЯ КНОПКА ДЛЯ МЕДИА
              icon: Icons.photo_library_rounded,
              label: 'Медиа',
              index: 6,
              currentColor: currentColor,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color currentColor,
  }) {
    final isSelected = _currentIndex == index;
    final itemColor = isSelected ? Colors.white : Colors.white.withOpacity(0.7);
    final backgroundColor = isSelected
        ? Colors.white.withOpacity(0.3)
        : Colors.transparent;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Icon(icon, size: 22, color: itemColor),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.3),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
      label: label,
    );
  }

  Color _darkenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Для компьютера используем боковую панель
    if (_isDesktop) {
      return Scaffold(
        appBar: null,
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Боковая панель навигации
                _buildDesktopSidebar(),

                // Основной контент - УПРОЩЕННАЯ СТРУКТУРА
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    child: _pages[_currentIndex],
                  ),
                ),
              ],
            ),

            // Плавающая кнопка для показа/скрытия панели
            _buildSidebarToggleButton(),
          ],
        ),
      );
    }

    // Для мобильных устройств используем старый дизайн с нижней навигацией
    return Scaffold(
      appBar: null,
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _buildMobileBottomNav(),
    );
  }
}
