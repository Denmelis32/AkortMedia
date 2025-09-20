import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/news_provider.dart';
import 'providers/channel_posts_provider.dart';
import 'providers/articles_provider.dart';
import 'providers/user_provider.dart';
import 'providers/room_provider.dart'; // Добавьте этот импорт
import 'services/room_service.dart'; // Добавьте этот импорт
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
  late RoomService _roomService;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _roomService = RoomService(); // Инициализируем сервис комнат
  }

  void _handleLoginSuccess() async {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout() async {
    await AuthService.logout();

    // Используем глобальный ключ для доступа к провайдерам
    final navigatorKey = GlobalKey<NavigatorState>();

    if (navigatorKey.currentContext != null) {
      final channelPostsProvider = Provider.of<ChannelPostsProvider>(navigatorKey.currentContext!, listen: false);
      channelPostsProvider.clearAll();

      final articlesProvider = Provider.of<ArticlesProvider>(navigatorKey.currentContext!, listen: false);
      articlesProvider.clearAll();

      final userProvider = Provider.of<UserProvider>(navigatorKey.currentContext!, listen: false);
      userProvider.clearUserData();

      final roomProvider = Provider.of<RoomProvider>(navigatorKey.currentContext!, listen: false);
      // Добавьте метод очистки в RoomProvider если нужно
    }

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
        ChangeNotifierProvider(create: (_) => ArticlesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider(_roomService)), // Добавьте эту строку
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

            // Устанавливаем данные пользователя в провайдер
            if (user != null) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.setUserData(
                user['name'] ?? 'Пользователь',
                user['email'] ?? '',
              );
            }

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