import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/news_provider.dart';
import '../../providers/user_tags_provider.dart';
import '../../providers/user_provider.dart';
import '../cards_page/channel_detail_page.dart';
import '../cards_page/models/channel.dart';
import 'mock_news_data.dart';
import 'theme/news_theme.dart';
import '../../providers/channel_state_provider.dart';
import '../../services/interaction_manager.dart';

// Импортируем ProfilePage
import 'profile_menu_page.dart';

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onRepost;
  final Function(String, String, String)? onComment;
  final VoidCallback? onFollow;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final Function(String, String, Color)? onTagEdit;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final ScrollController scrollController;
  final VoidCallback? onLogout;

  const NewsCard({
    super.key,
    required this.news,
    this.onLike,
    this.onBookmark,
    this.onRepost,
    this.onComment,
    this.onFollow,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onTagEdit,
    required this.formatDate,
    required this.getTimeAgo,
    required this.scrollController,
    this.onLogout,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _tagEditController = TextEditingController();
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;
  bool _isFollowing = false;
  double _readingProgress = 0.0;
  String _editingTagId = '';
  ChannelStateProvider? _channelStateProvider;
  bool _isChannelPost = false;
  String _channelId = '';
  UserTagsProvider? _userTagsProvider;

  // КЭШ ДЛЯ ОПТИМИЗАЦИИ
  final _avatarCache = <String, String>{};
  final _tagColorCache = <String, Color>{};

  // ИСПОЛЬЗУЕМ INTERACTION MANAGER ВМЕСТО ЛОКАЛЬНОГО СОСТОЯНИЯ
  late InteractionManager _interactionManager;
  late PostInteractionState? _postState;

  final List<CardDesign> _cardDesigns = [
    CardDesign(
      gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      pattern: PatternStyle.minimal,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF667eea),
    ),
    CardDesign(
      gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF4facfe),
    ),
    CardDesign(
      gradient: [const Color(0xFFfa709a), const Color(0xFFfee140)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFFfa709a),
    ),
    CardDesign(
      gradient: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
      pattern: PatternStyle.minimal,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF8E2DE2),
    ),
    CardDesign(
      gradient: [const Color(0xFF3A1C71), const Color(0xFFD76D77), const Color(0xFFFFAF7B)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF3A1C71),
    ),
  ];

  final List<Color> _availableColors = NewsTheme.tagColors;

  CardDesign get _cardDesign {
    final id = widget.news['id']?.hashCode ?? 0;
    return _cardDesigns[id % _cardDesigns.length];
  }

  Color get _selectedTagColor {
    if (widget.news['tag_color'] != null) {
      return Color(widget.news['tag_color']);
    }
    return _cardDesign.accentColor;
  }

  ContentType get _contentType {
    final title = _getStringValue(widget.news['title']).toLowerCase();
    final description = _getStringValue(widget.news['description']).toLowerCase();

    if (title.contains('важн') || title.contains('срочн')) return ContentType.important;
    if (title.contains('новость') || description.contains('новость')) return ContentType.news;
    if (title.contains('спорт') || description.contains('спорт')) return ContentType.sports;
    if (title.contains('техн') || description.contains('техн')) return ContentType.tech;
    if (title.contains('развлеч') || description.contains('развлеч')) return ContentType.entertainment;
    if (title.contains('образован') || description.contains('образован')) return ContentType.education;

    return ContentType.general;
  }

  IconData get _contentIcon {
    switch (_contentType) {
      case ContentType.important:
        return Icons.warning_amber_rounded;
      case ContentType.news:
        return Icons.article_rounded;
      case ContentType.sports:
        return Icons.sports_soccer_rounded;
      case ContentType.tech:
        return Icons.memory_rounded;
      case ContentType.entertainment:
        return Icons.movie_rounded;
      case ContentType.education:
        return Icons.school_rounded;
      default:
        return Icons.trending_up_rounded;
    }
  }

  Color get _contentColor {
    switch (_contentType) {
      case ContentType.important:
        return Color(0xFFE74C3C);
      case ContentType.news:
        return Color(0xFF3498DB);
      case ContentType.tech:
        return Color(0xFF9B59B6);
      case ContentType.entertainment:
        return Color(0xFFE67E22);
      default:
        return _cardDesign.accentColor;
    }
  }

  void _setupUserTagsListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userTagsProvider = Provider.of<UserTagsProvider>(context, listen: false);
        _userTagsProvider = userTagsProvider;

        // Убедимся, что UserProvider имеет данные
        if (!userProvider.isLoggedIn) {
          print('⚠️ UserProvider не инициализирован, устанавливаем временные данные');
          userProvider.setUserData(
            'Гость',
            'guest@example.com',
            userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        // Инициализируем провайдер с UserProvider
        if (!userTagsProvider.isInitialized) {
          await userTagsProvider.initialize(userProvider);
        } else {
          print('✅ UserTagsProvider уже инициализирован');
        }

        userTagsProvider.addListener(_onUserTagsChanged);

        // Форсируем обновление UI после инициализации
        if (mounted) {
          setState(() {});
        }

        print('✅ UserTagsProvider listener установлен для пользователя: ${userTagsProvider.currentUserId}');
      } catch (e) {
        print('❌ Ошибка инициализации UserTagsProvider: $e');
      }
    });
  }

  Map<String, String> _getUserTags() {
    try {
      final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
      final postId = _getStringValue(widget.news['id']);

      // ДЛЯ КАНАЛЬНЫХ ПОСТОВ ВОЗВРАЩАЕМ ПУСТОЙ MAP
      if (isChannelPost) {
        return <String, String>{};
      }

      // Для обычных постов используем персональные теги
      if (_userTagsProvider != null && _userTagsProvider!.isInitialized) {
        final personalTags = _userTagsProvider!.getTagsForPost(postId);

        // Явная проверка типа
        if (personalTags is Map<String, String> && personalTags.isNotEmpty) {
          print('✅ Используем ПЕРСОНАЛЬНЫЕ теги для поста $postId:');
          personalTags.forEach((key, value) {
            print('   - $key: $value');
          });
          return Map<String, String>.from(personalTags);
        } else {
          print('ℹ️ Для поста $postId нет сохраненных персональных тегов, используем ПУСТЫЕ теги');
          return <String, String>{};
        }
      } else {
        print('⚠️ UserTagsProvider не инициализирован для поста $postId');
        return <String, String>{};
      }
    } catch (e) {
      print('❌ Ошибка получения тегов из UserTagsProvider: $e');
      return <String, String>{};
    }
  }

  void _onUserTagsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Color _getTagColor(String tagId) {
    final cacheKey = '${widget.news['id']}-$tagId';
    if (_tagColorCache.containsKey(cacheKey)) {
      return _tagColorCache[cacheKey]!;
    }

    final postId = _getStringValue(widget.news['id']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);

    // ДЛЯ КАНАЛЬНЫХ ПОСТОВ ИСПОЛЬЗУЕМ ЦВЕТ ИЗ ДИЗАЙНА
    if (isChannelPost) {
      _tagColorCache[cacheKey] = _cardDesign.accentColor;
      return _cardDesign.accentColor;
    }

    // ПРИОРИТЕТ 1: Цвет из персональных тегов ДЛЯ КОНКРЕТНОГО ПОСТА
    if (_userTagsProvider != null && _userTagsProvider!.isInitialized) {
      try {
        final color = _userTagsProvider!.getTagColorForPost(postId, tagId);
        if (color != null) {
          print('✅ NewsCard: цвет тега $tagId из UserTagsProvider: $color');
          _tagColorCache[cacheKey] = color;
          return color;
        }
      } catch (e) {
        print('❌ Ошибка получения цвета тега из UserTagsProvider: $e');
      }
    }

    // ПРИОРИТЕТ 2: Цвет из данных новости
    if (widget.news['tag_color'] != null) {
      try {
        final color = Color(widget.news['tag_color']);
        print('✅ NewsCard: цвет тега $tagId из данных новости: $color');
        _tagColorCache[cacheKey] = color;
        return color;
      } catch (e) {
        print('❌ Ошибка парсинга цвета из новости: $e');
      }
    }

    // ПРИОРИТЕТ 3: Цвет из дизайна карточки
    final designColor = _cardDesign.accentColor;
    print('✅ NewsCard: цвет тега $tagId из дизайна карточки: $designColor');
    _tagColorCache[cacheKey] = designColor;
    return designColor;
  }



  // ДОБАВЬТЕ ЭТОТ МЕТОД В КЛАСС _NewsCardState (после других методов)
  Widget _buildEnhancedRepostHeader() {
    final repostedByName = _getStringValue(widget.news['reposted_by_name']);
    final originalAuthorName = _getStringValue(widget.news['original_author_name']);
    final originalChannelName = _getStringValue(widget.news['original_channel_name']);
    final isOriginalChannelPost = _getBoolValue(widget.news['is_original_channel_post']);

    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: _getAvatarSize(context) + 12),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat_rounded, size: 14, color: Colors.green),
            SizedBox(width: 6),
            Text('Репост от ', style: TextStyle(color: Colors.green, fontSize: 12)),
            Text(repostedByName,
                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.green),
            SizedBox(width: 4),
            if (isOriginalChannelPost && originalChannelName.isNotEmpty)
              Text(originalChannelName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12))
            else if (originalAuthorName.isNotEmpty)
              Text(originalAuthorName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12))
            else
              Text('оригинальный пост',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ ОТСТУПОВ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 0;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  double _getAvatarSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 40;
    return 44;
  }

  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 15;
    return 15;
  }

  double _getDescriptionFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 15;
    return 14;
  }

  double _getCardBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 16.0;
    return 0.0;
  }

  EdgeInsets _getCardMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return EdgeInsets.only(bottom: 16.0);
    return EdgeInsets.only(bottom: 0.0);
  }

  bool _shouldShowTopLine(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= 700;
  }

  @override
  void initState() {
    super.initState();

    // ИНИЦИАЛИЗАЦИЯ INTERACTION MANAGER
    _interactionManager = InteractionManager();

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..addStatusListener((status) {
      // Обработка статусов анимации
      if (status == AnimationStatus.completed) {
        print('✅ Анимация раскрытия завершена');
      }
    });

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.fastOutSlowIn,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );

    _setupUserTagsListener();

    // ИСПОЛЬЗУЕМ INTERACTION MANAGER ВМЕСТО ЛОКАЛЬНОГО СОСТОЯНИЯ
    _isFollowing = _getBoolValue(widget.news['isFollowing'] ?? false);
    _readingProgress = (widget.news['read_progress'] ?? 0.0).toDouble();

    // Определяем, является ли пост канальным
    _isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    _channelId = _getStringValue(widget.news['channel_id']);

    // Инициализация состояния поста
    _initializePostState();

    if (_isChannelPost && _channelId.isNotEmpty) {
      _setupChannelListener();
    }
  }

  void _initializePostState() {
    final postId = _getStringValue(widget.news['id']);

    // Инициализируем состояние поста в менеджере
    _interactionManager.initializePostState(
      postId: postId,
      isLiked: _getBoolValue(widget.news['isLiked']),
      isBookmarked: _getBoolValue(widget.news['isBookmarked']),
      isReposted: _getBoolValue(widget.news['isReposted'] ?? false),
      likesCount: _getIntValue(widget.news['likes']),
      repostsCount: _getIntValue(widget.news['reposts'] ?? 0),
      comments: List<Map<String, dynamic>>.from(widget.news['comments'] ?? []),
    );

    // Получаем текущее состояние
    _postState = _interactionManager.getPostState(postId);
  }

  void _setupChannelListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      _channelStateProvider = channelStateProvider;

      // Обновляем состояние подписки из провайдера
      final isSubscribed = channelStateProvider.isSubscribed(_channelId);
      if (_isFollowing != isSubscribed) {
        setState(() {
          _isFollowing = isSubscribed;
        });
      }

      channelStateProvider.addListener(_onChannelStateChanged);
    });
  }

  void _onChannelStateChanged() {
    if (!mounted) return;

    if (_isChannelPost && _channelId.isNotEmpty && _channelStateProvider != null) {
      // Обновляем состояние подписки при изменении в провайдере
      final isSubscribed = _channelStateProvider!.isSubscribed(_channelId);
      if (_isFollowing != isSubscribed) {
        setState(() {
          _isFollowing = isSubscribed;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Подписываемся на изменения состояния поста
    final postId = _getStringValue(widget.news['id']);
    _interactionManager.addPostListener(postId, _onPostStateChanged);
  }

  void _onPostStateChanged() {
    if (mounted) {
      setState(() {
        final postId = _getStringValue(widget.news['id']);
        _postState = _interactionManager.getPostState(postId);
      });
    }
  }

  @override
  void didUpdateWidget(NewsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем только если изменился ID поста или основные данные
    if (oldWidget.news['id'] != widget.news['id']) {
      _isFollowing = _getBoolValue(widget.news['isFollowing'] ?? false);
      _initializePostState();
      _clearCaches(); // Очищаем кэш при обновлении виджета
    }
  }

  @override
  void dispose() {
    _expandController.dispose();

    // Безопасная очистка контроллеров
    _commentController.dispose();
    _tagEditController.dispose();

    // Очистка кэшей
    _clearCaches();

    // Удаляем слушатель провайдера каналов
    if (_channelStateProvider != null) {
      _channelStateProvider!.removeListener(_onChannelStateChanged);
    }

    // Удаляем слушатель провайдера тегов
    if (_userTagsProvider != null) {
      _userTagsProvider!.removeListener(_onUserTagsChanged);
    }

    // Удаляем слушатель interaction manager
    final postId = _getStringValue(widget.news['id']);
    _interactionManager.removePostListener(_onPostStateChanged);

    super.dispose();
  }

  void _clearCaches() {
    _avatarCache.clear();
    _tagColorCache.clear();
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ТИПОВ
  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  int _getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }

  // ОБРАБОТЧИКИ ВЗАИМОДЕЙСТВИЙ ЧЕРЕЗ INTERACTION MANAGER
  void _handleLike() {
    final postId = _getStringValue(widget.news['id']);
    _interactionManager.toggleLike(postId);

    // Вызываем колбэк для дополнительной логики
    widget.onLike?.call();
  }

  void _handleBookmark() {
    final postId = _getStringValue(widget.news['id']);
    _interactionManager.toggleBookmark(postId);

    widget.onBookmark?.call();
  }

  // В КЛАССЕ _NewsCardState ДОБАВИТЬ ТАКОЙ ЖЕ МЕТОД
  void _handleRepost() {
    final postId = _getStringValue(widget.news['id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    _interactionManager.toggleRepost(
      postId: postId,
      currentUserId: userProvider.userId ?? '',
      currentUserName: userProvider.userName,
    );

    // ПОКАЗЫВАЕМ УВЕДОМЛЕНИЕ О РЕПОСТЕ
    _showRepostSuccessSnackBar();

    widget.onRepost?.call();
  }

// ДОБАВИТЬ МЕТОД ДЛЯ ПОКАЗА УВЕДОМЛЕНИЯ О РЕПОСТЕ
  void _showRepostSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.repeat_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Репостнул на свою страничку',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'ОК',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _handleComment(String text, String author, String avatar) {
    final postId = _getStringValue(widget.news['id']);
    _interactionManager.addComment(
      postId: postId,
      text: text,
      author: author,
      authorAvatar: avatar,
    );

    // Вызываем колбэк для дополнительной логики
    widget.onComment?.call(text, author, avatar);
  }

  void _toggleFollow() {
    if (_isChannelPost && _channelId.isNotEmpty && _channelStateProvider != null) {
      // Для канальных постов используем ChannelStateProvider
      final currentSubscribers = _channelStateProvider!.getSubscribers(_channelId) ?? 0;
      _channelStateProvider!.toggleSubscription(_channelId, currentSubscribers);

      // Обновляем локальное состояние
      setState(() {
        _isFollowing = _channelStateProvider!.isSubscribed(_channelId);
      });
    } else {
      // Для обычных постов используем callback
      setState(() {
        _isFollowing = !_isFollowing;
      });
      widget.onFollow?.call();
    }
  }

  void _openUserProfile() {
    final authorName = _getStringValue(widget.news['author_name']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final channelId = _getStringValue(widget.news['channel_id']);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (isChannelPost && channelId.isNotEmpty && channelName.isNotEmpty) {
      _openChannelPage(channelId, channelName);
      return;
    }

    final targetUserName = authorName;
    final isCurrentUser = authorName == userProvider.userName;

    if (isCurrentUser) {
      _showProfilePage(context);
    } else {
      _showOtherUserProfile(context, targetUserName);
    }
  }

  void _openChannelPage(String channelId, String channelName) {
    if (channelId.isEmpty || channelName.isEmpty) {
      print('❌ Missing channel data: id=$channelId, name=$channelName');
      return;
    }

    try {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      final currentAvatarUrl = channelStateProvider.getAvatarForChannel(channelId);

      final tempChannel = Channel.simple(
        id: int.tryParse(channelId) ?? 0,
        title: channelName,
        description: 'Канал',
        imageUrl: currentAvatarUrl ?? _getStringValue(widget.news['channel_avatar']),
        cardColor: Colors.blue,
        subscribers: _getIntValue(widget.news['channel_subscribers'] ?? 0),
        videos: _getIntValue(widget.news['channel_videos'] ?? 0),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChannelDetailPage(channel: tempChannel),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to channel: $e');
      _showChannelInfoDialog(channelName);
    }
  }

  void _showChannelInfoDialog(String channelName) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Канал: $channelName'),
        content: Text('Информация о канале "$channelName"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showProfilePage(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userName: userProvider.userName,
          userEmail: userProvider.userEmail,
          onLogout: () {
            Navigator.pop(context);
            widget.onLogout?.call();
          },
          newMessagesCount: 3,
          profileImageUrl: newsProvider.profileImageUrl,
          profileImageFile: newsProvider.profileImageFile,
          onProfileImageUrlChanged: (url) {
            newsProvider.updateProfileImageUrl(url);
          },
          onProfileImageFileChanged: (file) {
            newsProvider.updateProfileImageFile(file);
          },
          onMessagesTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Переход к сообщениям');
          },
          onSettingsTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Переход к настройкам');
          },
          onHelpTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Переход к разделу помощи');
          },
          onAboutTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Информация о приложении');
          },
        ),
      ),
    );
  }

  void _showOtherUserProfile(BuildContext context, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userName: userName,
          userEmail: '$userName@user.com',
          onLogout: () {
            Navigator.pop(context);
          },
          newMessagesCount: 0,
          profileImageUrl: null,
          profileImageFile: null,
          onProfileImageUrlChanged: null,
          onProfileImageFileChanged: null,
          onMessagesTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Сообщения для $userName');
          },
          onSettingsTap: null,
          onHelpTap: null,
          onAboutTap: null,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getUserAvatarUrl(String userName, {bool isCurrentUser = false}) {
    final cacheKey = '$userName-$isCurrentUser';
    if (_avatarCache.containsKey(cacheKey)) {
      return _avatarCache[cacheKey]!;
    }

    // ПЕРВЫЙ ПРИОРИТЕТ: Для текущего пользователя используем фото профиля
    if (isCurrentUser) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      final currentProfileImage = newsProvider.getCurrentProfileImage();

      if (currentProfileImage != null) {
        if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
          // Проверяем, это локальный asset или файл
          if (currentProfileImage.startsWith('assets/')) {
            _avatarCache[cacheKey] = currentProfileImage;
            return currentProfileImage;
          }
          // Если это URL, игнорируем и используем локальные аватарки
        } else if (currentProfileImage is File) {
          // Используем путь к файлу
          _avatarCache[cacheKey] = currentProfileImage.path;
          return currentProfileImage.path;
        }
      }
    }

    // ВТОРОЙ ПРИОРИТЕТ: Всегда используем аватарки из MockNewsData
    try {
      final authorAvatar = MockNewsData.getAuthorAvatar(userName);
      if (authorAvatar.isNotEmpty) {
        print('✅ Используем аватар из MockNewsData для $userName: $authorAvatar');
        _avatarCache[cacheKey] = authorAvatar;
        return authorAvatar;
      }
    } catch (e) {
      print('❌ Ошибка получения аватара из MockNewsData: $e');
    }

    // Fallback на случай ошибки
    const fallbackAvatar = 'assets/images/ava_news/ava1.png';
    _avatarCache[cacheKey] = fallbackAvatar;
    return fallbackAvatar;
  }

  // УЛУЧШЕННЫЙ МЕТОД ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ
  Widget _buildImageWidget(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (imageUrl.isEmpty) {
      return _buildErrorImage(width: width, height: height);
    }

    print('🖼️ Loading image: $imageUrl');

    try {
      // ВСЕГДА используем локальные assets
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width != null ? (width * 2).toInt() : null,
        cacheHeight: height != null ? (height * 2).toInt() : null,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Asset image error: $error for path: $imageUrl');
          return _buildErrorImage(width: width, height: height);
        },
      );
    } catch (e) {
      print('❌ Exception loading image: $e');
      return _buildErrorImage(width: width, height: height);
    }
  }

  Widget _buildUserAvatar(String avatarUrl, bool isChannelPost, String displayName, double size) {
    print('🔄 Building avatar for $displayName: $avatarUrl');

    return GestureDetector(
      onTap: _openUserProfile,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildImageWidgetWithFallback(
              avatarUrl,
              displayName,
              size: size
          ),
        ),
      ),
    );
  }

  // Новый метод с улучшенной обработкой fallback
  Widget _buildImageWidgetWithFallback(String imageUrl, String displayName, {double? size}) {
    return _buildImageWidget(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }

  Widget _buildLoadingPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          const Text(
            'Ошибка\nзагрузки',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Адаптивная карточка
  Widget _buildCard({required Widget child, bool isChannel = false}) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final borderRadius = _getCardBorderRadius(context);
    final margin = _getCardMargin(context);
    final showTopLine = _shouldShowTopLine(context);
    final isMobile = MediaQuery.of(context).size.width <= 700;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
      ).add(margin),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                // Фоновая градиентная текстура
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _cardDesign.gradient[0].withOpacity(0.02),
                          _cardDesign.gradient[1].withOpacity(0.01),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Акцентный элемент в углу
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _cardDesign.gradient[0].withOpacity(0.08),
                          _cardDesign.gradient[0].withOpacity(0.02),
                        ],
                        stops: const [0.1, 1.0],
                      ),
                    ),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showTopLine)
                      Container(
                        height: 1,
                        margin: EdgeInsets.only(
                          left: isMobile ? (_getAvatarSize(context) + 12 + 16) : 0,
                          right: isMobile ? 16 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: child,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Построение заголовка
  Widget _buildPostHeader(bool isAuthor, Map<String, String> userTags, Color tagColor) {
    final authorName = _getStringValue(widget.news['author_name']);
    final createdAt = _getStringValue(widget.news['created_at']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final channelId = _getStringValue(widget.news['channel_id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ПРОСТАЯ ПРОВЕРКА РЕПОСТА
    final isRepost = _getBoolValue(widget.news['is_repost']);
    final repostedByName = _getStringValue(widget.news['reposted_by_name']);
    final originalAuthorName = _getStringValue(widget.news['original_author_name']);
    final originalChannelName = _getStringValue(widget.news['original_channel_name']);
    final isOriginalChannelPost = _getBoolValue(widget.news['is_original_channel_post']);

    // ОТЛАДКА ДАННЫХ РЕПОСТА
    if (isRepost) {
      print('🎯 REPOST HEADER DATA:');
      print('   reposted_by_name: $repostedByName');
      print('   original_author_name: $originalAuthorName');
      print('   original_channel_name: $originalChannelName');
      print('   is_original_channel_post: $isOriginalChannelPost');
    }

    String authorAvatar;
    String displayName;

    // ДЛЯ РЕПОСТОВ: используем данные репостнувшего пользователя
    if (isRepost) {
      final isCurrentUser = repostedByName == userProvider.userName;
      authorAvatar = _getUserAvatarUrl(repostedByName, isCurrentUser: isCurrentUser);
      displayName = repostedByName;
    } else if (isChannelPost && channelId.isNotEmpty) {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      final currentAvatarUrl = channelStateProvider.getAvatarForChannel(channelId);
      authorAvatar = currentAvatarUrl ?? _getStringValue(widget.news['channel_avatar']) ?? _getFallbackAvatarUrl(channelName);
      displayName = channelName;
    } else {
      final isCurrentUser = authorName == userProvider.userName;
      authorAvatar = _getUserAvatarUrl(authorName, isCurrentUser: isCurrentUser);
      displayName = authorName;
    }

    final avatarSize = _getAvatarSize(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ИНФОРМАЦИЯ О РЕПОСТЕ - УЛУЧШЕННЫЙ ВАРИАНТ
        if (isRepost && repostedByName.isNotEmpty)
          _buildEnhancedRepostHeader(),

        // ОСНОВНАЯ ИНФОРМАЦИЯ О ПОСТЕ
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserAvatar(authorAvatar, isChannelPost, displayName, avatarSize),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ИМЯ АВТОРА
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _openUserProfile,
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: _getTitleFontSize(context),
                              color: Colors.black87,
                              letterSpacing: -0.3,
                              height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // КНОПКА МЕНЮ
                      if (!isRepost || displayName == userProvider.userName)
                        _buildMenuButton(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // ВРЕМЯ И СТАТУС
                  _buildPostMetaInfo(isRepost, isChannelPost, createdAt),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildPostMetaInfo(bool isRepost, bool isChannelPost, String createdAt) {
    return Container(
      height: 28,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ВРЕМЯ
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  widget.getTimeAgo(createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // СТАТУС РЕПОСТА ИЛИ КАНАЛА
            if (isRepost) ...[
              SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), shape: BoxShape.circle)),
              SizedBox(width: 8),
              Icon(Icons.repeat_rounded, size: 12, color: Colors.green),
              SizedBox(width: 4),
              Text('Репост', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
            ] else if (isChannelPost) ...[
              SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), shape: BoxShape.circle)),
              SizedBox(width: 8),
              Icon(Icons.group_rounded, size: 12, color: Colors.blue),
              SizedBox(width: 4),
              Text('Канал', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w700)),
            ] else if (_contentType != ContentType.general) ...[
              SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), shape: BoxShape.circle)),
              SizedBox(width: 8),
              Icon(_contentIcon, size: 12, color: _contentColor),
              SizedBox(width: 4),
              Text(_getContentTypeText(), style: TextStyle(color: _contentColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }




  // ВЫНЕСИТЕ КНОПКУ МЕНЮ В ОТДЕЛЬНЫЙ МЕТОД
  Widget _buildMenuButton() {
    return Container(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600], size: 18),
        onSelected: _handleMenuSelection,
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_rounded, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text('Поделиться', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 140),
      ),
    );
  }

  void _showAddTagDialog() {
    if (!mounted) return;

    final postId = _getStringValue(widget.news['id']);
    _tagEditController.text = '';
    _editingTagId = 'tag1'; // Используем tag1 для нового тега

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color dialogSelectedColor = _contentColor;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Добавить персональный тег',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tagEditController,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Название тега',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _contentColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Выберите цвет:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _userTagsProvider?.availableColors.length ?? _availableColors.length,
                          itemBuilder: (context, index) {
                            final color = _userTagsProvider?.availableColors[index] ?? _availableColors[index];
                            return GestureDetector(
                              onTap: () => setState(() => dialogSelectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: dialogSelectedColor == color ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: dialogSelectedColor == color
                                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                side: BorderSide(color: Colors.grey[400]!),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Отмена', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _tagEditController.text.trim().isNotEmpty ? () {
                                final text = _tagEditController.text.trim();

                                // Сохраняем в персональные теги ДЛЯ КОНКРЕТНОГО ПОСТА
                                if (_userTagsProvider != null) {
                                  _userTagsProvider!.updateTagForPost(
                                    postId: postId,
                                    tagId: _editingTagId,
                                    newName: text,
                                    color: dialogSelectedColor,
                                  );
                                }

                                Navigator.pop(context);
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _contentColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                shadowColor: _contentColor.withOpacity(0.4),
                              ),
                              child: const Text(
                                'Сохранить',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddTagButton() {
    return GestureDetector(
      onTap: () => _showAddTagDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _contentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _contentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              size: 12,
              color: _contentColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Добавить тег',
              style: TextStyle(
                color: _contentColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        widget.onEdit?.call();
        break;
      case 'share':
        widget.onShare?.call();
        break;
      case 'delete':
        widget.onDelete?.call();
        break;
    }
  }

  String _getFallbackAvatarUrl(String userName) {
    final encodedName = Uri.encodeComponent(userName);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=667eea&color=ffffff&bold=true';
  }

  Widget _buildUserTag(String tag, String tagId, Color color, bool isChannelPost) {
    return GestureDetector(
      onTap: () => _showTagEditDialog(tag, tagId, color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              tag,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getContentTypeText() {
    switch (_contentType) {
      case ContentType.important:
        return 'Важное';
      case ContentType.news:
        return 'Новости';
      case ContentType.sports:
        return 'Спорт';
      case ContentType.tech:
        return 'Технологии';
      case ContentType.entertainment:
        return 'Развлечения';
      case ContentType.education:
        return 'Образование';
      default:
        return 'Общее';
    }
  }

  List<String> _cleanHashtags(List<String> hashtags) {
    final cleanedTags = <String>[];

    for (var tag in hashtags) {
      var cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
      cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');

      if (cleanTag.isNotEmpty && !cleanedTags.contains(cleanTag)) {
        cleanedTags.add(cleanTag);
      }
    }

    return cleanedTags;
  }

  Widget _buildHashtags(List<String> hashtags) {
    final cleanedHashtags = _cleanHashtags(hashtags);
    if (cleanedHashtags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: cleanedHashtags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _contentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _contentColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: _contentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ИСПОЛЬЗУЕМ КОММЕНТАРИИ ИЗ INTERACTION MANAGER
  List<dynamic> get _currentComments {
    return _postState?.comments ?? [];
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Действия поста с использованием Interaction Manager
  Widget _buildPostActions({bool showBookmark = true, bool isAuthor = false}) {
    if (_postState == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: _postState!.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            count: _postState!.likesCount,
            isActive: _postState!.isLiked,
            color: Colors.red,
            onPressed: _handleLike,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: _postState!.comments.length,
            isActive: _isExpanded,
            color: Colors.blue,
            onPressed: _toggleExpanded,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: _postState!.isReposted ? Icons.repeat_on_rounded : Icons.repeat_rounded,
            count: _postState!.repostsCount,
            isActive: _postState!.isReposted,
            color: Colors.green,
            onPressed: _handleRepost,
          ),
          if (showBookmark) const SizedBox(width: 8),
          if (showBookmark)
            _buildActionButton(
              icon: _postState!.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              count: 0,
              isActive: _postState!.isBookmarked,
              color: Colors.amber,
              onPressed: _handleBookmark,
            ),
          const Spacer(),
          if (_shouldShowFollowButton(isAuthor))
            _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: isActive ? 'Убрать действие' : 'Выполнить действие',
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? color.withOpacity(0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? color : Colors.grey[700],
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);

    return GestureDetector(
      onTap: _toggleFollow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: _isFollowing
              ? null
              : LinearGradient(
            colors: _cardDesign.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: _isFollowing ? Colors.green.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isFollowing ? Colors.green.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
          boxShadow: _isFollowing
              ? []
              : [
            BoxShadow(
              color: _cardDesign.gradient[0].withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _isFollowing ? Icons.check_rounded : Icons.add_rounded,
              size: 14,
              color: _isFollowing ? Colors.green : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowFollowButton(bool isAuthor) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authorName = _getStringValue(widget.news['author_name']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);

    if (isChannelPost) return true;

    final shouldShow = !isAuthor &&
        authorName.isNotEmpty &&
        authorName != userProvider.userName;

    return shouldShow;
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  void _showTagEditDialog(String tag, String tagId, Color currentColor) {
    if (!mounted) return;

    final postId = _getStringValue(widget.news['id']);
    _tagEditController.text = tag;
    _editingTagId = tagId;

    // НОВАЯ ПЕРЕМЕННАЯ ДЛЯ ВЫБОРА ОБНОВЛЕНИЯ
    bool updateGlobally = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color dialogSelectedColor = currentColor;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Редактировать персональный тег',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tagEditController,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Название тега',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _contentColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Выберите цвет:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _userTagsProvider?.availableColors.length ?? _availableColors.length,
                          itemBuilder: (context, index) {
                            final color = _userTagsProvider?.availableColors[index] ?? _availableColors[index];
                            return GestureDetector(
                              onTap: () => setState(() => dialogSelectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: dialogSelectedColor == color ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: dialogSelectedColor == color
                                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),

                      // НОВЫЙ ПЕРЕКЛЮЧАТЕЛЬ ДЛЯ ГЛОБАЛЬНОГО ОБНОВЛЕНИЯ
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sync_rounded,
                              color: updateGlobally ? _contentColor : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Обновить во всех постах',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch(
                              value: updateGlobally,
                              onChanged: (value) => setState(() => updateGlobally = value),
                              activeColor: _contentColor,
                            ),
                          ],
                        ),
                      ),
                      if (updateGlobally) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Этот тег будет обновлен во всех ваших постах',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                side: BorderSide(color: Colors.grey[400]!),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Отмена', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _tagEditController.text.trim().isNotEmpty ? () {
                                final text = _tagEditController.text.trim();

                                // Сохраняем в персональные теги ДЛЯ КОНКРЕТНОГО ПОСТА
                                if (_userTagsProvider != null) {
                                  _userTagsProvider!.updateTagForPost(
                                    postId: postId,
                                    tagId: _editingTagId,
                                    newName: text,
                                    color: dialogSelectedColor,
                                    updateGlobally: updateGlobally,
                                    context: context, // ПЕРЕДАЕМ CONTEXT ДЛЯ ГЛОБАЛЬНОГО ОБНОВЛЕНИЯ
                                  );
                                }

                                Navigator.pop(context);

                                // Показываем уведомление
                                if (updateGlobally) {
                                  _showSuccessSnackBar('Тег обновлен во всех постах');
                                } else {
                                  _showSuccessSnackBar('Тег обновлен только в этом посте');
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _contentColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                shadowColor: _contentColor.withOpacity(0.4),
                              ),
                              child: const Text(
                                'Сохранить',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Секция комментариев с использованием Interaction Manager
  Widget _buildCommentsSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _cardDesign.gradient[0].withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              if (_currentComments.isNotEmpty) ...[
                ..._currentComments.map((comment) => _buildCommentItem(comment)),
                const SizedBox(height: 16),
              ],
              _buildCommentInput(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(dynamic comment) {
    final commentMap = _convertToMap(comment);
    final author = _getStringValue(commentMap['author']);
    final text = _getStringValue(commentMap['text']);
    final time = _getStringValue(commentMap['time']);
    final authorAvatar = _getStringValue(commentMap['author_avatar']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentAvatar(authorAvatar, author),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentAvatar(String avatarUrl, String authorName) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildImageWidget(
          avatarUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Map<String, dynamic> _convertToMap(dynamic item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return item.cast<String, dynamic>();
    return {};
  }

  Widget _buildCommentInput() {
    return Consumer2<NewsProvider, UserProvider>(
      builder: (context, newsProvider, userProvider, child) {
        final currentUserAvatar = _getUserAvatarUrl(userProvider.userName, isCurrentUser: true);

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _buildImageWidget(
                    currentUserAvatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Напишите комментарий...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _cardDesign.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _cardDesign.gradient[0].withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty && mounted) {
                      _handleComment(text, userProvider.userName, currentUserAvatar);
                      _commentController.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Комментарий отправлен'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is List) {
      return List<String>.from(hashtags).map((tag) => tag.toString().trim()).where((tag) => tag.isNotEmpty).toList();
    }
    if (hashtags is String) {
      return hashtags.split(RegExp(r'[,\s]+')).map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, String> _parseUserTags(dynamic userTags) {
    if (userTags is Map<String, String>) {
      return userTags;
    }

    if (userTags is Map) {
      try {
        return userTags.map((key, value) => MapEntry(
            key.toString(),
            value.toString()
        ));
      } catch (e) {
        print('❌ Ошибка парсинга userTags: $e');
      }
    }

    // Возвращаем пустой Map вместо стандартных тегов
    return {};
  }

  void _toggleExpanded() {
    if (!mounted) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  Widget _buildRegularPost() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final hashtags = _parseHashtags(widget.news['hashtags']);
    final userTags = _getUserTags();
    final tagColor = _selectedTagColor;

    final authorName = _getStringValue(widget.news['author_name']);
    final isAuthor = authorName == userProvider.userName;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPostHeader(isAuthor, userTags, tagColor),
          Padding(
            padding: EdgeInsets.only(left: _getAvatarSize(context) + 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_getStringValue(widget.news['title']).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      _getStringValue(widget.news['title']),
                      style: TextStyle(
                        fontSize: _getTitleFontSize(context),
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _getStringValue(widget.news['description']),
                    style: TextStyle(
                      fontSize: _getDescriptionFontSize(context),
                      color: Colors.black87.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
                if (hashtags.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildHashtags(hashtags),
                  ),
                ],
                _buildPostActions(isAuthor: isAuthor),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCommentsSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelPost() {
    final title = _getStringValue(widget.news['title']);
    final description = _getStringValue(widget.news['description']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final createdAt = _getStringValue(widget.news['created_at']);
    final hashtags = _parseHashtags(widget.news['hashtags']);
    final channelId = _getStringValue(widget.news['channel_id']);

    // ДЛЯ КАНАЛЬНЫХ ПОСТОВ НЕ ИСПОЛЬЗУЕМ ТЕГИ - ЯВНО УКАЗЫВАЕМ ТИП
    final Map<String, String> userTags = <String, String>{};
    final tagColor = _cardDesign.accentColor;

    final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
    final currentAvatarUrl = channelStateProvider.getAvatarForChannel(channelId);
    final channelAvatar = currentAvatarUrl ?? _getStringValue(widget.news['channel_avatar']);

    return _buildCard(
      isChannel: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ДЛЯ КАНАЛЬНЫХ ПОСТОВ ПЕРЕДАЕМ ПУСТЫЕ ТЕГИ
          _buildPostHeader(false, userTags, tagColor),
          Padding(
            padding: EdgeInsets.only(left: _getAvatarSize(context) + 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: _getTitleFontSize(context),
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: _getDescriptionFontSize(context),
                        color: Colors.black87.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                if (hashtags.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildHashtags(hashtags),
                  ),
                ],
                _buildPostActions(
                    showBookmark: true,
                    isAuthor: false
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCommentsSection(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    return isChannelPost ? _buildChannelPost() : _buildRegularPost();
  }
}

// МОДЕЛИ ДЛЯ ДИЗАЙНА
class CardDesign {
  final List<Color> gradient;
  final PatternStyle pattern;
  final DecorationStyle decoration;
  final Color accentColor;

  const CardDesign({
    required this.gradient,
    required this.pattern,
    required this.decoration,
    required this.accentColor,
  });
}

enum PatternStyle {
  minimal,
  geometric,
  none,
}

enum DecorationStyle {
  modern,
  classic,
}

enum ContentType {
  important,
  news,
  sports,
  tech,
  entertainment,
  education,
  general,
}