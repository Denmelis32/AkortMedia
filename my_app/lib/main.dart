import 'package:flutter/material.dart';
import 'pages/splash_page.dart'; // Импортируем SplashPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashPage(), // Устанавливаем SplashPage как домашнюю
      debugShowCheckedModeBanner: false,
    );
  }
}