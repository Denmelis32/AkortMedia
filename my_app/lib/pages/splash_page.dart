// lib/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: 'Имя пользователя', // Получить из хранилища
            userEmail: 'user@example.com', // Получить из хранилища
            onLogout: () {
              // Логика выхода - возврат на сплеш скрин
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SplashPage()),
              );
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}