import 'package:flutter/material.dart';
import 'package:my_app/providers/channel_provider/channel_state_provider.dart';
import 'package:my_app/providers/communities_provider%20/communities_provider.dart';
import 'package:my_app/providers/communities_provider%20/community_state_provider.dart';
import 'package:my_app/providers/news_providers/news_provider_factory.dart';
import 'package:my_app/providers/state_sync_provider.dart';
import 'package:my_app/providers/news_providers/user_tags_provider.dart';
import 'package:provider/provider.dart';
import 'providers/news_providers/news_provider.dart';
import 'providers/channel_provider/channel_posts_provider.dart';
import 'providers/articles_provider.dart';
import 'providers/user_provider.dart';
import 'providers/room_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/room_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.initialLoggedIn;
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
        ChangeNotifierProvider(create: (_) => ChannelStateProvider()),
        ChangeNotifierProvider(create: (_) => NewsProviderFactory.create()),
        ChangeNotifierProvider(create: (_) => ChannelPostsProvider()),
        ChangeNotifierProvider(create: (_) => ArticlesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (context) {
          final userProvider = context.read<UserProvider>();
          return RoomProvider(
            RoomService(),
            currentUserId: userProvider.userId,
          );
        }),
        ChangeNotifierProvider(create: (_) => CommuninitiesProvider()),
        ChangeNotifierProvider(create: (_) => CommunityStateProvider()),
        ChangeNotifierProvider(create: (_) => UserTagsProvider()),
        ChangeNotifierProvider(create: (_) => StateSyncProvider()),
      ],
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: _isLoggedIn
            ? HomePage(
          userName: 'Пользователь',
          userEmail: '',
          onLogout: _handleLogout,
        )
            : LoginPage(onLoginSuccess: _handleLoginSuccess),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}