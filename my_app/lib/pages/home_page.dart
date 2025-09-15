// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'news_page//news_page.dart';
import 'predictions_league_page/predictions_league_page.dart';
import 'profile_page.dart' hide NewsPage;
import 'articles_pages/articles_page.dart';
import 'rooms_pages/rooms_page.dart';
import 'rooms_pages/models_room/user_permissions.dart';
import 'cards_page/cards_page.dart'; // Импортируем новую страницу карточек

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

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    final userPermissions = UserPermissions(
      isSeniorDeveloper: true,
      isLongTermFan: false,
      joinDate: DateTime.now().subtract(const Duration(days: 45)),
      avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.userName)}&background=007AFF&color=fff',
      messagesCount: 0,
      topicsCreated: 0,
      userId: 'user_123456', // Заполняем userId
      userName: widget.userName, // Заполняем userName
      participatedCategories: {},
      achievements: {},
      subscribedChannels: ['channel_tech', 'channel_news'], // Заполняем subscribedChannels
    );


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
      CardsPage( // Новая страница карточек
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      RoomsPage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
        userPermissions: userPermissions,
      ),
      PredictionsLeaguePage(
        userId: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      ProfilePage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
    ];
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName || oldWidget.userEmail != widget.userEmail) {
      _initializePages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF396AA3),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Лента',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Статьи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library), // Или Icons.play_circle_fill
            label: 'Каналы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Обсуждение',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Прогнозы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}