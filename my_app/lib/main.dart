import 'package:flutter/material.dart';
import 'package:my_app/providers/channel_state_provider.dart';
import 'package:my_app/providers/communities_provider.dart';
import 'package:my_app/providers/community_state_provider.dart';
import 'package:provider/provider.dart';
import 'providers/news_provider.dart';
import 'providers/channel_posts_provider.dart';
import 'providers/articles_provider.dart';
import 'providers/user_provider.dart';
import 'providers/room_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/room_service.dart';

// Импорты для чата
import 'pages/chat/chat_controller.dart';
import 'pages/chat/services/chat_api_service.dart';
import 'pages/chat/cache/chat_cache_manager.dart';

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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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

    // Используем глобальный ключ для доступа к провайдерам
    if (_navigatorKey.currentContext != null) {
      final channelPostsProvider = Provider.of<ChannelPostsProvider>(_navigatorKey.currentContext!, listen: false);
      channelPostsProvider.clearAll();

      final articlesProvider = Provider.of<ArticlesProvider>(_navigatorKey.currentContext!, listen: false);
      articlesProvider.clearAll();

      final userProvider = Provider.of<UserProvider>(_navigatorKey.currentContext!, listen: false);
      userProvider.clearUserData();

      final roomProvider = Provider.of<RoomProvider>(_navigatorKey.currentContext!, listen: false);
      roomProvider.clearAllData();

      // Очищаем провайдеры чата
      // Очищаем ChatController
      final chatController = Provider.of<ChatController>(_navigatorKey.currentContext!, listen: false);
      chatController.dispose();
    }

    setState(() {
      _isLoggedIn = false;
    });
  }

  // Создаем ChatController
  ChatController _createChatController() {
    // TODO: Настроить реальный API когда будет готов бэкенд
    final apiService = ChatApiService(
      baseUrl: 'https://your-real-api.com/api', // Замените на ваш URL
      authToken: 'your-auth-token', // Замените на реальный токен
    );

    final cacheManager = ChatCacheManager();

    return ChatController(
      apiService: apiService,
      cacheManager: cacheManager,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Существующие провайдеры
        ChangeNotifierProvider(create: (_) => ChannelStateProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => ChannelPostsProvider()),
        ChangeNotifierProvider(create: (_) => ArticlesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider(RoomService())),
        ChangeNotifierProvider(create: (_) => CommuninitiesProvider()),
        ChangeNotifierProvider(create: (_) => CommunityStateProvider()),

        // Новый провайдер для чата
        ChangeNotifierProvider(create: (_) => _createChatController()),
      ],
      child: MaterialApp(
        title: 'Football App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Дополнительные настройки темы для чата
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            foregroundColor: Colors.black,
          ),
        ),
        navigatorKey: _navigatorKey,
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
                userId: user['id'] ?? 'current-user', // Передаем userId если есть
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