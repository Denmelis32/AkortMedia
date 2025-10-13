// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'news_page/news_page.dart';
import 'predictions_league_page/predictions_league_page.dart';
import 'articles_pages/articles_page.dart';
import 'rooms_pages/rooms_page.dart';
import 'cards_page/cards_page.dart';
import 'event_page/event_list_screen.dart'; // Импортируем нашу страницу событий

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
      AdaptiveRoomsPage(
        onLogout: widget.onLogout,
      ),
      PredictionsLeaguePage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      EventListScreen(
      ), // Заменили ProfilePage на нашу страницу событий
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
            icon: Icon(Icons.video_library),
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
            icon: Icon(Icons.event), // Изменили иконку с person на event
            label: 'События', // Изменили label с "Профиль" на "События"
          ),
        ],
      ),
    );
  }
}