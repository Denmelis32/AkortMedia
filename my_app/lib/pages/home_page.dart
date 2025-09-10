// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'news_page.dart';
import 'predictions_league_page.dart';
import 'profile_page.dart';

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
        onLogout: widget.onLogout, // ← ДОБАВЛЯЕМ onLogout
      ),
      PredictionsLeaguePage(
        userName: widget.userName,       // ← ДОБАВЛЯЕМ
        userEmail: widget.userEmail,     // ← ДОБАВЛЯЕМ
        onLogout: widget.onLogout, // ← ДОБАВЛЯЕМ onLogout и УБИРАЕМ const
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
    String appBarTitle;
    switch (_currentIndex) {
      case 0:
        appBarTitle = 'Футбольные новости';
        break;
      case 1:
        appBarTitle = 'Лига Прогнозов';
        break;
      case 2:
        appBarTitle = 'Профиль';
        break;
      default:
        appBarTitle = 'Футбольные новости';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFFA31525),
        foregroundColor: Colors.white,
        actions: _currentIndex == 2
            ? [] // Скрываем кнопку выхода на других вкладках
            : [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выход'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onLogout();
                      },
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Выйти',
          ),
        ],
      ),
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
        selectedItemColor: const Color(0xFFA31525),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Новости',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Лига прогнозов',
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