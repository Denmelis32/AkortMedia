// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'news_page//news_page.dart';
import 'predictions_league_page/predictions_league_page.dart';
import 'profile_page.dart' hide NewsPage;
import 'articles_pages/articles_page.dart'; // Импортируем существующую страницу статей
import 'rooms_pages/rooms_page.dart';
import 'rooms_pages/models_room/user_permissions.dart';// Создайте этот файл для комнат

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
      ArticlesPage( // Используем вашу существующую страницу статей
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      RoomsPage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
        userPermissions: UserPermissions(
          userId: 'user123',
          userName: widget.userName,
          isSeniorDeveloper: true, // или false, в зависимости от пользователя
          isLongTermFan: false, // или true
          joinDate: DateTime.now().subtract(Duration(days: 45)), // пример даты регистрации
          avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.userName)}&background=007AFF&color=fff', // URL аватара
          messagesCount: 0, // начальное количество сообщений
          topicsCreated: 0, // начальное количество созданных тем
          participatedCategories: {}, // пустой набор для категорий
          achievements: {}, // пустой Map для достижений
          subscribedChannels: [], // пустой список для подписанных каналов
        ),
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
            icon: Icon(Icons.chat),
            label: 'Комнаты',
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