import 'package:flutter/material.dart';
import 'package:my_app/pages/profile_page.dart';
import 'articles_page.dart';
import 'news_page.dart';
import 'predictions_league_page.dart'; // ДОБАВЬТЕ ЭТОТ ИМПОРТ

const primaryColor = Color(0xFFA31525);
const secondaryColor = Colors.grey;
const backgroundColor = Color(0xFFFAEBD7);

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      NewsPage(userName: widget.userName, userEmail: widget.userEmail),
      ArticlesPage(userName: widget.userName, userEmail: widget.userEmail),
      // ЗАМЕНИТЕ заглушку на настоящую страницу:
      PredictionLeaguePage(userName: widget.userName, userEmail: widget.userEmail),
      ProfilePage(userName: widget.userName, userEmail: widget.userEmail),
    ];
  }

  // Этот метод больше не нужен, но можно оставить для других случаев
  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Раздел "$title" в разработке',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Футбольные новости';
      case 1:
        return 'Статьи';
      case 2:
        return 'Лига Прогнозов';
      case 3:
        return 'Профиль';
      default:
        return 'Футбольные новости';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
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
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Новости',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Статьи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Лига',
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