import 'package:flutter/material.dart';
import 'package:my_app/providers/channel_state_provider.dart';
import 'package:my_app/providers/communities_provider.dart';
import 'package:my_app/providers/community_state_provider.dart';
import 'package:my_app/providers/news_providers/news_provider_factory.dart';
import 'package:my_app/providers/state_sync_provider.dart';
import 'package:my_app/providers/user_tags_provider.dart';
import 'package:provider/provider.dart';
import 'providers/news_providers/news_provider.dart';
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

// ДОБАВИТЬ: Импорт InteractionManager
import 'services/interaction_manager.dart';

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
      try {
        final chatController = Provider.of<ChatController>(_navigatorKey.currentContext!, listen: false);
        chatController.dispose();
      } catch (e) {
        // Игнорируем ошибки если провайдер не инициализирован
        print('Error disposing chat controller: $e');
      }

      // Очищаем другие провайдеры
      final communitiesProvider = Provider.of<CommuninitiesProvider>(_navigatorKey.currentContext!, listen: false);
      communitiesProvider.clearAllData();

      final communityStateProvider = Provider.of<CommunityStateProvider>(_navigatorKey.currentContext!, listen: false);
      communityStateProvider.clearData();

      final channelStateProvider = Provider.of<ChannelStateProvider>(_navigatorKey.currentContext!, listen: false);
      channelStateProvider.clearData();

      final newsProvider = Provider.of<NewsProvider>(_navigatorKey.currentContext!, listen: false);
      newsProvider.clearData();

      // Очищаем UserTagsProvider
      final userTagsProvider = Provider.of<UserTagsProvider>(_navigatorKey.currentContext!, listen: false);
      userTagsProvider.clearCurrentUserTags();

      // ДОБАВИТЬ: Очищаем InteractionManager
      final interactionManager = Provider.of<InteractionManager>(_navigatorKey.currentContext!, listen: false);
      interactionManager.clearAll();
    }

    setState(() {
      _isLoggedIn = false;
    });
  }

  // Создаем ChatController
  ChatController _createChatController() {
    // TODO: Настроить реальный API когда будет готов бэкенд
    // Временная заглушка для демонстрации
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

  // Инициализация провайдеров после входа пользователя
  Future<void> _initializeProvidersAfterLogin(BuildContext context, Map<String, dynamic> user) async {
    try {
      // Устанавливаем данные пользователя в провайдер
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = user['id']?.toString() ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

      userProvider.setUserData(
        user['name'] ?? 'Пользователь',
        user['email'] ?? '',
        userId: userId,
      );

      print('✅ UserProvider инициализирован: ${userProvider.userName}, ID: ${userProvider.userId}');

      // Инициализируем UserTagsProvider с данными пользователя
      final userTagsProvider = Provider.of<UserTagsProvider>(context, listen: false);
      await userTagsProvider.initializeWithUserId(userId);

      print('✅ UserTagsProvider инициализирован для пользователя: $userId');

      // Загружаем данные новостей
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.ensureDataPersistence();

      print('✅ NewsProvider инициализирован с ${newsProvider.news.length} новостями');

      // Инициализируем InteractionManager с данными новостей
      final interactionManager = Provider.of<InteractionManager>(context, listen: false);

      if (newsProvider.news.isNotEmpty) {
        // Конвертируем List<dynamic> в List<Map<String, dynamic>>
        final List<Map<String, dynamic>> newsList = newsProvider.news.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            // Если элемент не Map, конвертируем его
            return {'id': item.toString(), 'isLiked': false, 'isBookmarked': false};
          }
        }).toList();

        print('✅ InteractionManager инициализирован с ${newsList.length} постами');
      }

      // Инициализируем другие провайдеры
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      channelStateProvider.initialize();

      final communitiesProvider = Provider.of<CommuninitiesProvider>(context, listen: false);
      communitiesProvider.initialize();

      print('✅ Все провайдеры успешно инициализированы');

    } catch (e) {
      print('❌ Ошибка инициализации провайдеров: $e');
      // Показываем ошибку пользователю
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки данных: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Существующие провайдеры
        ChangeNotifierProvider(create: (_) => ChannelStateProvider()),
        ChangeNotifierProvider(create: (_) => NewsProviderFactory.create()),
        ChangeNotifierProvider(create: (_) => ChannelPostsProvider()),
        ChangeNotifierProvider(create: (_) => ArticlesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider(RoomService())),
        ChangeNotifierProvider(create: (_) => CommuninitiesProvider()),
        ChangeNotifierProvider(create: (_) => CommunityStateProvider()),
        ChangeNotifierProvider(create: (_) => UserTagsProvider()),
        ChangeNotifierProvider(create: (context) => StateSyncProvider()),

        // Новый провайдер для чата
        ChangeNotifierProvider(create: (_) => _createChatController()),

        // ДОБАВИТЬ: InteractionManager как синглтон
        ChangeNotifierProvider(create: (_) => InteractionManager()),
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
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Общие настройки для всего приложения
          scaffoldBackgroundColor: Colors.white,
          // ИСПРАВЛЕНО: CardTheme -> CardThemeData
          cardTheme: CardThemeData(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Настройки для текстовых полей
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          // Настройки кнопок
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // Настройки текста
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        navigatorKey: _navigatorKey,
        home: _isLoggedIn
            ? FutureBuilder(
          future: AuthService.getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Загрузка...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ошибка загрузки',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final user = snapshot.data;

            // Инициализируем провайдеры после получения данных пользователя
            if (user != null) {
              // Используем addPostFrameCallback чтобы дождаться построения виджета
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeProvidersAfterLogin(context, user);
              });
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
        // Глобальные настройки для всего приложения
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Фиксируем масштаб текста
            ),
            child: child!,
          );
        },
      ),
    );
  }
}