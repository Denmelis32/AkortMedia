import 'package:flutter/material.dart';
import 'package:my_app/providers/communities_provider%20/communities_provider.dart';
import 'package:my_app/providers/communities_provider%20/community_state_provider.dart';
import 'package:provider/provider.dart';

// Импорты провайдеров
import 'providers/room_provider.dart';
import 'providers/user_provider.dart';
import 'providers/news_providers/news_provider.dart';
import 'providers/channel_provider/channel_state_provider.dart';
import 'providers/state_sync_provider.dart';
import 'providers/news_providers/user_tags_provider.dart';
import 'providers/channel_provider/channel_posts_provider.dart';
import 'providers/articles_provider.dart';

// Импорты страниц
import 'pages/home_page.dart';
import 'pages/login_page.dart';

// Импорты сервисов
import 'services/auth_service.dart';
import 'services/room_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🎯 ИНИЦИАЛИЗАЦИЯ ГЛОБАЛЬНОГО КЛЮЧА ДЛЯ NewsProvider
  NewsProvider.navigatorKey = GlobalKey<NavigatorState>();

  // Простая инициализация
  final isLoggedIn = await AuthService.isLoggedIn();
  print('App started - logged in: $isLoggedIn');

  runApp(MyApp(initialLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool initialLoggedIn;

  const MyApp({super.key, required this.initialLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  late UserProvider _userProvider;
  late NewsProvider _newsProvider;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.initialLoggedIn;

    // 🎯 СОЗДАЕМ ПРОВАЙДЕРЫ ВРУЧНУЮ ДЛЯ ПРАВИЛЬНОЙ СВЯЗИ
    _userProvider = UserProvider();
    _newsProvider = NewsProvider(userProvider: _userProvider);

    print('MyApp initialized - logged in: $_isLoggedIn');
  }

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout() async {
    await AuthService.logout();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🎯 ПЕРЕДАЕМ УЖЕ СОЗДАННЫЕ ПРОВАЙДЕРЫ
        ChangeNotifierProvider<UserProvider>.value(value: _userProvider),
        ChangeNotifierProvider<NewsProvider>.value(value: _newsProvider),

        ChangeNotifierProvider(create: (_) => ChannelStateProvider()),
        ChangeNotifierProvider(create: (_) => ChannelPostsProvider()),
        ChangeNotifierProvider(create: (_) => ArticlesProvider()),
        ChangeNotifierProvider(create: (_) => UserTagsProvider()),
        ChangeNotifierProvider(create: (_) => StateSyncProvider()),
        ChangeNotifierProvider(create: (_) => CommuninitiesProvider()),
        ChangeNotifierProvider(create: (_) => CommunityStateProvider()),

        // RoomProvider с зависимостью от UserProvider
        ChangeNotifierProxyProvider<UserProvider, RoomProvider>(
          create: (context) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            return RoomProvider(
              RoomService(),
              currentUserId: userProvider.userId,
            );
          },
          update: (context, userProvider, roomProvider) {
            return roomProvider!..updateCurrentUserId(userProvider.userId);
          },
        ),
      ],
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // 🎯 ИСПОЛЬЗУЕМ ГЛОБАЛЬНЫЙ КЛЮЧ ДЛЯ NewsProvider
        navigatorKey: NewsProvider.navigatorKey,
        home: _isLoggedIn
            ? Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            print('🎯 Building HomePage with user: ${userProvider.userName}');
            return HomePage(
              userName: userProvider.userName,
              userEmail: userProvider.userEmail,
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