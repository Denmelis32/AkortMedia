// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/news_provider.dart';
import 'providers/channel_posts_provider.dart';
import 'providers/articles_provider.dart'; // Добавьте этот импорт
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Проверяем авторизацию при запуске
  final isLoggedIn = await AuthService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
  }

  void _handleLoginSuccess() async {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout() async {
    await AuthService.logout();

    // Очищаем данные провайдеров при выходе
    final channelPostsProvider = Provider.of<ChannelPostsProvider>(context as BuildContext, listen: false);
    channelPostsProvider.clearAll();

    // Также очищаем ArticlesProvider
    final articlesProvider = Provider.of<ArticlesProvider>(context as BuildContext, listen: false);
    articlesProvider.clearAll();

    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => ChannelPostsProvider()),
        ChangeNotifierProvider(create: (_) => ArticlesProvider()), // Добавьте эту строку
      ],
      child: MaterialApp(
        title: 'Football App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: _isLoggedIn
            ? FutureBuilder(
          future: AuthService.getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = snapshot.data;
            return HomePage(
              userName: user?['name'] ?? 'Пользователь',
              userEmail: user?['email'] ?? '',
              onLogout: _handleLogout,
            );
          },
        )
            : LoginPage(onLoginSuccess: _handleLoginSuccess),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}