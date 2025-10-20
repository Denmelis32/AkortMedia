import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/news_provider.dart';
import '../../providers/user_tags_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/repost_manager.dart';
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

  bool _isHovered = false;
  // КЭШ ДЛЯ ОПТИМИЗАЦИИ
  final _avatarCache = <String, String>{};
  final _tagColorCache = <String, Color>{};

  // ИСПОЛЬЗУЕМ INTERACTION MANAGER ВМЕСТО ЛОКАЛЬНОГО СОСТОЯНИЯ
  late InteractionManager _interactionManager;
  late PostInteractionState? _postState;

  // СПИСОК ЛОКАЛЬНЫХ АВАТАРОК ИЗ ASSETS
  final List<String> _localAvatars = [
    'assets/images/ava_news/ava1.png',
    'assets/images/ava_news/ava2.png',
    'assets/images/ava_news/ava3.png',
    'assets/images/ava_news/ava4.png',
    'assets/images/ava_news/ava5.png',
    'assets/images/ava_news/ava6.png',
    'assets/images/ava_news/ava7.png',
    'assets/images/ava_news/ava8.png',
    'assets/images/ava_news/ava9.png',
    'assets/images/ava_news/ava10.png',
    'assets/images/ava_news/ava11.png',
    'assets/images/ava_news/ava12.png',
    'assets/images/ava_news/ava13.png',
    'assets/images/ava_news/ava14.png',
    'assets/images/ava_news/ava15.png',
    'assets/images/ava_news/ava16.png',
    'assets/images/ava_news/ava17.png',
    'assets/images/ava_news/ava18.png',
    'assets/images/ava_news/ava19.png',
    'assets/images/ava_news/ava20.png',
    'assets/images/ava_news/ava21.png',
    'assets/images/ava_news/ava22.png',
    'assets/images/ava_news/ava23.png',
    'assets/images/ava_news/ava24.png',
    'assets/images/ava_news/ava25.png',
    'assets/images/ava_news/ava26.png',
    'assets/images/ava_news/ava27.png',
    'assets/images/ava_news/ava28.png',
    'assets/images/ava_news/ava29.png',
    'assets/images/ava_news/ava30.png',
  ];

  final List<CardDesign> _cardDesigns = [
    CardDesign(
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      pattern: PatternStyle.minimal,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF667eea),
      backgroundColor: Color(0xFFFAFBFF),
    ),
    CardDesign(
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF4facfe),
      backgroundColor: Color(0xFFF7FDFF),
    ),
    CardDesign(
      gradient: [Color(0xFFfa709a), Color(0xFFfee140)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFFfa709a),
      backgroundColor: Color(0xFFFFFBF9),
    ),
    CardDesign(
      gradient: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      pattern: PatternStyle.minimal,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF8E2DE2),
      backgroundColor: Color(0xFFFBF7FF),
    ),
    CardDesign(
      gradient: [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF3A1C71),
      backgroundColor: Color(0xFFFDF7FB),
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

  // УЛУЧШЕННЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ
  // ИСПРАВЛЕННЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ
  String _getUserAvatarUrl(String userName, {bool isCurrentUser = false, bool isOriginalPost = false}) {
    try {
      print('🔍 Получение аватарки для: $userName, текущий пользователь: $isCurrentUser, оригинальный пост: $isOriginalPost');

      // ДЛЯ РЕПОСТОВ - ОРИГИНАЛЬНЫЙ АВТОР/КАНАЛ
      if (isOriginalPost) {
        final isOriginalChannelPost = _getBoolValue(widget.news['is_original_channel_post']);
        print('   Оригинальный канальный пост: $isOriginalChannelPost');

        if (isOriginalChannelPost) {
          // АВАТАР ОРИГИНАЛЬНОГО КАНАЛА
          final originalChannelAvatar = _getStringValue(widget.news['original_channel_avatar']);
          final originalChannelId = _getStringValue(widget.news['original_channel_id']);
          final originalChannelName = _getStringValue(widget.news['original_channel_name']);

          print('   Оригинальный канал: $originalChannelName, ID: $originalChannelId');
          print('   Аватар канала из данных: $originalChannelAvatar');

          // ПРИОРИТЕТ 1: Аватар из ChannelStateProvider
          if (originalChannelId.isNotEmpty) {
            try {
              final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
              final providerAvatar = channelStateProvider.getAvatarForChannel(originalChannelId);
              if (providerAvatar != null && providerAvatar.isNotEmpty) {
                print('   ✅ Используем аватар канала из провайдера: $providerAvatar');
                return providerAvatar;
              }
            } catch (e) {
              print('   ⚠️ Ошибка получения аватарки канала из провайдера: $e');
            }
          }

          // ПРИОРИТЕТ 2: Аватар из данных поста
          if (originalChannelAvatar.isNotEmpty) {
            print('   ✅ Используем аватар канала из данных поста: $originalChannelAvatar');
            return originalChannelAvatar;
          }

          // ПРИОРИТЕТ 3: Fallback для канала
          print('   🎯 Используем fallback аватар для канала: $originalChannelName');
          return _getFallbackAvatarUrl(originalChannelName);
        } else {
          // АВАТАР ОРИГИНАЛЬНОГО ПОЛЬЗОВАТЕЛЯ
          final originalAuthorAvatar = _getStringValue(widget.news['original_author_avatar']);
          final originalAuthorName = _getStringValue(widget.news['original_author_name']);

          print('   Оригинальный автор: $originalAuthorName');
          print('   Аватар автора из данных: $originalAuthorAvatar');

          // ПРИОРИТЕТ 1: Аватар из данных поста
          if (originalAuthorAvatar.isNotEmpty) {
            print('   ✅ Используем аватар автора из данных поста: $originalAuthorAvatar');
            return originalAuthorAvatar;
          }

          // ПРИОРИТЕТ 2: Fallback для пользователя
          print('   🎯 Используем fallback аватар для автора: $originalAuthorName');
          return _getFallbackAvatarUrl(originalAuthorName);
        }
      }

      // ДЛЯ ОСНОВНЫХ ПОСТОВ - КАНАЛЫ
      final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
      final channelId = _getStringValue(widget.news['channel_id']);
      final channelName = _getStringValue(widget.news['channel_name']);

      if (isChannelPost && channelId.isNotEmpty) {
        print('   🔍 Это канальный пост, канал: $channelName, ID: $channelId');

        // ПРИОРИТЕТ 1: Аватар из ChannelStateProvider
        try {
          final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
          final providerAvatar = channelStateProvider.getAvatarForChannel(channelId);
          if (providerAvatar != null && providerAvatar.isNotEmpty) {
            print('   ✅ Используем аватар канала из провайдера: $providerAvatar');
            return providerAvatar;
          }
        } catch (e) {
          print('   ⚠️ Ошибка получения аватарки канала: $e');
        }

        // ПРИОРИТЕТ 2: Аватар канала из данных поста
        final channelAvatar = _getStringValue(widget.news['channel_avatar']);
        if (channelAvatar.isNotEmpty) {
          print('   ✅ Используем аватар канала из данных поста: $channelAvatar');
          return channelAvatar;
        }

        // ПРИОРИТЕТ 3: Fallback для канала
        print('   🎯 Используем fallback аватар для канала: $channelName');
        return _getFallbackAvatarUrl(channelName);
      }

      // ДЛЯ ОБЫЧНЫХ ПОЛЬЗОВАТЕЛЕЙ
      final authorAvatar = _getStringValue(widget.news['author_avatar']);
      final authorName = _getStringValue(widget.news['author_name']);

      print('   Автор: $authorName');
      print('   Аватар автора из данных: $authorAvatar');

      // ПРИОРИТЕТ 1: Аватар из данных поста
      if (authorAvatar.isNotEmpty) {
        return authorAvatar;
      }

      // ПРИОРИТЕТ 2: Fallback для пользователя
      print('   🎯 Используем fallback аватар для пользователя: $authorName');
      return _getFallbackAvatarUrl(authorName);

    } catch (e) {
      print('❌ Ошибка получения аватарки пользователя: $e');
      return _getFallbackAvatarUrl(userName);
    }
  }




  // ДОБАВЬТЕ ЭТОТ МЕТОД ДЛЯ ОТЛАДКИ
  void _debugAvatarInfo() {
    final isRepost = _getBoolValue(widget.news['is_repost']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    final isOriginalChannelPost = _getBoolValue(widget.news['is_original_channel_post']);

    print('=== DEBUG AVATAR INFO ===');
    print('isRepost: $isRepost');
    print('isChannelPost: $isChannelPost');
    print('isOriginalChannelPost: $isOriginalChannelPost');

    if (isRepost) {
      print('ORIGINAL POST DATA:');
      print('  original_author_name: ${_getStringValue(widget.news['original_author_name'])}');
      print('  original_author_avatar: ${_getStringValue(widget.news['original_author_avatar'])}');
      print('  original_channel_name: ${_getStringValue(widget.news['original_channel_name'])}');
      print('  original_channel_avatar: ${_getStringValue(widget.news['original_channel_avatar'])}');
      print('  original_channel_id: ${_getStringValue(widget.news['original_channel_id'])}');
    } else {
      print('REGULAR POST DATA:');
      print('  author_name: ${_getStringValue(widget.news['author_name'])}');
      print('  author_avatar: ${_getStringValue(widget.news['author_avatar'])}');
      print('  channel_name: ${_getStringValue(widget.news['channel_name'])}');
      print('  channel_avatar: ${_getStringValue(widget.news['channel_avatar'])}');
      print('  channel_id: ${_getStringValue(widget.news['channel_id'])}');
    }
    print('========================');
  }

  // УЛУЧШЕННЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ FALLBACK АВАТАРКИ
  String _getFallbackAvatarUrl(String userName) {
    // Всегда возвращаем локальные аватары из assets
    final index = userName.hashCode.abs() % _localAvatars.length;
    return _localAvatars[index];
  }

  // УЛУЧШЕННЫЙ ВИДЖЕТ ДЛЯ ОТОБРАЖЕНИЯ ИЗОБРАЖЕНИЙ
  Widget _buildImageWidget(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (imageUrl.isEmpty) {
      return _buildErrorImage(width: width, height: height);
    }

    print('🖼️ Загрузка изображения: $imageUrl');

    try {
      if (_isAssetImage(imageUrl)) {
        // ЛОКАЛЬНЫЕ АССЕТЫ
        return Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: width != null ? (width * 2).toInt() : null,
          cacheHeight: height != null ? (height * 2).toInt() : null,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Ошибка загрузки asset изображения: $error для пути: $imageUrl');
            return _buildErrorImage(width: width, height: height);
          },
        );
      } else if (_isNetworkImage(imageUrl)) {
        // СЕТЕВЫЕ ИЗОБРАЖЕНИЯ
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildLoadingPlaceholder(width: width, height: height),
          errorWidget: (context, url, error) {
            print('❌ Ошибка загрузки network изображения: $error для URL: $imageUrl');
            return _buildErrorImage(width: width, height: height);
          },
        );
      } else if (_isFileImage(imageUrl)) {
        // ФАЙЛЫ С УСТРОЙСТВА
        return Image.file(
          File(imageUrl),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Ошибка загрузки file изображения: $error для пути: $imageUrl');
            return _buildErrorImage(width: width, height: height);
          },
        );
      } else {
        // FALLBACK
        print('⚠️ Неизвестный тип изображения: $imageUrl');
        return _buildErrorImage(width: width, height: height);
      }
    } catch (e) {
      print('❌ Исключение при загрузке изображения: $e');
      return _buildErrorImage(width: width, height: height);
    }
  }

  // УЛУЧШЕННЫЙ ВИДЖЕТ ДЛЯ АВАТАРКИ ПОЛЬЗОВАТЕЛЯ
  Widget _buildUserAvatar(String avatarUrl, bool isChannelPost, String displayName, double size, {bool isOriginalPost = false}) {
    print('🔄 Создание аватарки для $displayName: $avatarUrl');
    print('   Канальный пост: $isChannelPost, Оригинальный пост: $isOriginalPost');

    return GestureDetector(
      onTap: isOriginalPost ? null : _openUserProfile,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildImageWidgetWithFallback(avatarUrl, displayName, size: size),
        ),
      ),
    );
  }

  // ВИДЖЕТ С FALLBACK ДЛЯ АВАТАРКИ
  Widget _buildImageWidgetWithFallback(String imageUrl, String displayName, {double? size}) {
    if (imageUrl.isEmpty) {
      return _buildGradientFallbackAvatar(displayName, size ?? 40);
    }

    return _buildImageWidget(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }

  // ГРАДИЕНТНЫЙ FALLBACK ДЛЯ АВАТАРКИ
  Widget _buildGradientFallbackAvatar(String name, double size) {
    final gradientColors = _getAvatarGradient(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: name.isNotEmpty
            ? Text(
          name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
          ),
        )
            : Icon(
          Icons.group_rounded,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  // ПОЛУЧЕНИЕ ГРАДИЕНТА ДЛЯ АВАТАРКИ
  List<Color> _getAvatarGradient(String name) {
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];

    final index = name.isEmpty ? 0 : name.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  // ПРОВЕРКА ТИПОВ ИЗОБРАЖЕНИЙ
  bool _isAssetImage(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    return imageUrl.startsWith('assets/') ||
        imageUrl.startsWith('assets/images/') ||
        (imageUrl.contains('.png') && !imageUrl.contains('://')) ||
        (imageUrl.contains('.jpg') && !imageUrl.contains('://')) ||
        (imageUrl.contains('.jpeg') && !imageUrl.contains('://'));
  }

  bool _isNetworkImage(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    return imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://') ||
        imageUrl.contains('ui-avatars.com') ||
        imageUrl.contains('://');
  }

  bool _isFileImage(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    return imageUrl.startsWith('/') ||
        (imageUrl.contains(RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false)) &&
            !_isAssetImage(imageUrl) &&
            !_isNetworkImage(imageUrl));
  }

  // ВИДЖЕТ ЗАГРУЗКИ
  Widget _buildLoadingPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_cardDesign.gradient[0]),
          ),
        ),
      ),
    );
  }

  // ВИДЖЕТ ОШИБКИ
  Widget _buildErrorImage({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.grey[500],
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'Ошибка\nзагрузки',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _setupUserTagsListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userTagsProvider = Provider.of<UserTagsProvider>(context, listen: false);
        _userTagsProvider = userTagsProvider;

        if (!userProvider.isLoggedIn) {
          print('⚠️ UserProvider не инициализирован, устанавливаем временные данные');
          userProvider.setUserData(
            'Гость',
            'guest@example.com',
            userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        if (!userTagsProvider.isInitialized) {
          await userTagsProvider.initialize(userProvider);
        } else {
          print('✅ UserTagsProvider уже инициализирован');
        }

        userTagsProvider.addListener(_onUserTagsChanged);

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
      final isRepost = _getBoolValue(widget.news['is_repost']);
      final postId = _getStringValue(widget.news['id']);

      // ДЛЯ ОТЛАДКИ: всегда показываем теги
      print('🔍 GET USER TAGS CALLED:');
      print('   - postId: $postId');
      print('   - isChannelPost: $isChannelPost');
      print('   - isRepost: $isRepost');
      print('   - userTagsProvider initialized: ${_userTagsProvider?.isInitialized ?? false}');

      if (_userTagsProvider != null && _userTagsProvider!.isInitialized) {
        final personalTags = _userTagsProvider!.getTagsForPost(postId);

        print('✅ Personal tags from provider: $personalTags');

        if (personalTags is Map<String, String> && personalTags.isNotEmpty) {
          print('✅ Используем ПЕРСОНАЛЬНЫЕ теги для поста $postId:');
          personalTags.forEach((key, value) {
            print('   - $key: $value');
          });
          return Map<String, String>.from(personalTags);
        } else {
          print('ℹ️ Для поста $postId нет сохраненных персональных тегов');
          // Возвращаем мок теги для демонстрации
          return _getMockTagsForDebug(postId);
        }
      } else {
        print('⚠️ UserTagsProvider не инициализирован для поста $postId');
        // Возвращаем мок теги для демонстрации
        return _getMockTagsForDebug(_getStringValue(widget.news['id']));
      }
    } catch (e) {
      print('❌ Ошибка получения тегов из UserTagsProvider: $e');
      // Возвращаем мок теги для демонстрации
      return _getMockTagsForDebug(_getStringValue(widget.news['id']));
    }
  }

  // Временный метод для отладки
  Map<String, String> _getMockTagsForDebug(String postId) {
    final mockTags = {
      'tag1': 'Личный тег 1',
      'tag2': 'Мои интересы',
      'tag3': 'Обсуждение'
    };
    print('🎯 Using mock tags for debug: $mockTags');
    return mockTags;
  }

  Widget _buildPersonalTags(Map<String, String> userTags, Color tagColor) {
    if (userTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 28, // Фиксированная высота для одной строки
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: userTags.length,
        itemBuilder: (context, index) {
          final tagId = userTags.keys.elementAt(index);
          final tagName = userTags.values.elementAt(index);
          final color = _getTagColor(tagId);

          return Padding(
            padding: EdgeInsets.only(
              right: 8,
              left: index == 0 ? 0 : 0, // Первый элемент без левого отступа
            ),
            child: _buildUserTag(tagName, tagId, color, false),
          );
        },
      ),
    );
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

    if (isChannelPost) {
      _tagColorCache[cacheKey] = _cardDesign.accentColor;
      return _cardDesign.accentColor;
    }

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

    final designColor = _cardDesign.accentColor;
    print('✅ NewsCard: цвет тега $tagId из дизайна карточки: $designColor');
    _tagColorCache[cacheKey] = designColor;
    return designColor;
  }

  void _showRepostWithCommentDialog() {
    final TextEditingController commentController = TextEditingController();
    final FocusNode commentFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return RepostWithCommentDialog(
          cardDesign: _cardDesign,
          onRepost: (String comment) {
            _handleRepostWithComment(comment);
          },
        );
      },
    ).then((_) {
      commentController.dispose();
      commentFocusNode.dispose();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentFocusNode.requestFocus();
    });
  }

  bool _isReposting = false;

  void _handleRepostWithComment(String comment) {
    if (!mounted) return;

    final postId = _getStringValue(widget.news['id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    final originalIndex = newsProvider.findNewsIndexById(postId);
    if (originalIndex == -1) return;

    if (_isReposting) {
      print('⚠️ Repost already in progress, skipping...');
      return;
    }

    _isReposting = true;

    final repostManager = RepostManager();
    repostManager.createRepostWithComment(
      newsProvider: newsProvider,
      originalIndex: originalIndex,
      currentUserId: userProvider.userId ?? '',
      currentUserName: userProvider.userName,
      comment: comment,
    ).then((_) {
      if (mounted) {
        _isReposting = false;
        _showEnhancedRepostSuccessSnackBar(comment);
      }
    }).catchError((error) {
      if (mounted) {
        _isReposting = false;
        print('❌ Error in repost: $error');
      }
    });

    print('🔄 Repost with comment initiated: "$comment"');
  }

  void _showEnhancedRepostSuccessSnackBar(String comment) {
    final hasComment = comment.isNotEmpty;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasComment ? Icons.edit_rounded : Icons.repeat_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hasComment ? 'Репост с комментарием' : 'Репостнул на свою страничку',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (hasComment) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    comment,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        backgroundColor: hasComment ? Colors.blue : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: hasComment ? 4 : 3),
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

  void _verifyRepostData() {
    final isRepost = _getBoolValue(widget.news['is_repost']);
    final repostComment = _getStringValue(widget.news['repost_comment']);
    final comments = List<Map<String, dynamic>>.from(widget.news['comments'] ?? []);

    if (isRepost && repostComment.isNotEmpty && comments.isNotEmpty) {
      print('❌ [VERIFICATION] DUPLICATION DETECTED in UI!');
      print('   Repost comment: "$repostComment"');
      print('   Regular comments: ${comments.length}');
    }
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
    if (width > 700) return 20.0;
    return 0.0;
  }

  EdgeInsets _getCardMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return EdgeInsets.only(bottom: 20.0);
    return EdgeInsets.only(bottom: 0.0);
  }

  bool _shouldShowTopLine(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= 700;
  }

  @override
  void initState() {
    super.initState();

    _interactionManager = InteractionManager();
    _verifyRepostData();

    // ДОБАВЬТЕ ОТЛАДКУ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugAvatarInfo();
    });

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userTags = _getUserTags();
      print('🎯 INIT USER TAGS: $userTags');
    });

    _setupUserTagsListener();

    _isFollowing = _getBoolValue(widget.news['isFollowing'] ?? false);
    _readingProgress = (widget.news['read_progress'] ?? 0.0).toDouble();

    _isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    _channelId = _getStringValue(widget.news['channel_id']);

    _initializePostState();

    if (_isChannelPost && _channelId.isNotEmpty) {
      _setupChannelListener();
    }
  }

  void _initializePostState() {
    final postId = _getStringValue(widget.news['id']);

    _interactionManager.initializePostState(
      postId: postId,
      isLiked: _getBoolValue(widget.news['isLiked']),
      isBookmarked: _getBoolValue(widget.news['isBookmarked']),
      isReposted: _getBoolValue(widget.news['isReposted'] ?? false),
      likesCount: _getIntValue(widget.news['likes']),
      repostsCount: _getIntValue(widget.news['reposts'] ?? 0),
      comments: List<Map<String, dynamic>>.from(widget.news['comments'] ?? []),
    );

    _postState = _interactionManager.getPostState(postId);
  }

  void _setupChannelListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      _channelStateProvider = channelStateProvider;

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

    if (oldWidget.news['id'] != widget.news['id']) {
      _isFollowing = _getBoolValue(widget.news['isFollowing'] ?? false);
      _initializePostState();
      _clearCaches();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _commentController.dispose();
    _tagEditController.dispose();

    _clearCaches();

    if (_channelStateProvider != null) {
      _channelStateProvider!.removeListener(_onChannelStateChanged);
    }

    if (_userTagsProvider != null) {
      _userTagsProvider!.removeListener(_onUserTagsChanged);
    }

    final postId = _getStringValue(widget.news['id']);
    _interactionManager.removePostListener(_onPostStateChanged);

    super.dispose();
  }

  void _clearCaches() {
    _avatarCache.clear();
    _tagColorCache.clear();
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 0;
  }

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

  void _handleLike() {
    final postId = _getStringValue(widget.news['id']);
    _interactionManager.toggleLike(postId);
    widget.onLike?.call();
  }

  void _handleBookmark() {
    final postId = _getStringValue(widget.news['id']);
    _interactionManager.toggleBookmark(postId);
    widget.onBookmark?.call();
  }

  void _handleRepost() {
    _showRepostOptionsModal();
  }

  void _showRepostOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Как хотите репостнуть?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildRepostOption(
                Icons.repeat_rounded,
                'Простой репост',
                'Поделиться постом без комментария',
                Colors.green,
                    () {
                  Navigator.pop(context);
                  _handleSimpleRepost();
                },
              ),
              const SizedBox(height: 16),
              _buildRepostOption(
                Icons.edit_rounded,
                'Репост с комментарием',
                'Добавить свой комментарий к репосту',
                Colors.blue,
                    () {
                  Navigator.pop(context);
                  _showRepostWithCommentDialog();
                },
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.grey[50],
                ),
                child: const Text(
                  'Отмена',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSimpleRepost() {
    final postId = _getStringValue(widget.news['id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    _interactionManager.toggleRepost(
      postId: postId,
      currentUserId: userProvider.userId ?? '',
      currentUserName: userProvider.userName,
    );

    _showRepostSuccessSnackBar();
  }

  Widget _buildRepostOption(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showRepostSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.repeat_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Репостнул на свою страничку',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
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

    widget.onComment?.call(text, author, avatar);
  }

  void _toggleFollow() {
    if (_isChannelPost && _channelId.isNotEmpty && _channelStateProvider != null) {
      final currentSubscribers = _channelStateProvider!.getSubscribers(_channelId) ?? 0;
      _channelStateProvider!.toggleSubscription(_channelId, currentSubscribers);

      setState(() {
        _isFollowing = _channelStateProvider!.isSubscribed(_channelId);
      });
    } else {
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
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _cardDesign.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.group_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'Канал: $channelName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Информация о канале "$channelName"',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardDesign.gradient[0],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
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
        content: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildCard({required Widget child, bool isChannel = false}) {
    final isRepost = _getBoolValue(widget.news['is_repost']);

    // ВЫЧИСЛЯЕМ ВСЕ НЕОБХОДИМЫЕ ЗНАЧЕНИЯ ВНУТРИ МЕТОДА
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final borderRadius = _getCardBorderRadius(context);
    final margin = _getCardMargin(context);
    final showTopLine = _shouldShowTopLine(context);
    final isMobile = MediaQuery.of(context).size.width <= 700;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width: double.infinity,
        margin: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
        ).add(margin),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            decoration: BoxDecoration(
              color: _cardDesign.backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: isRepost ? Border.all(
                color: Colors.blue.withOpacity(0.3), // Акцент для репостов
                width: 1.5,
              ) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                  blurRadius: _isHovered ? 25 : 16,
                  offset: Offset(0, _isHovered ? 8 : 4),
                  spreadRadius: _isHovered ? 1 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  // Фоновая градиентная текстура с анимацией
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 600),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _cardDesign.gradient[0].withOpacity(_isHovered ? 0.08 : 0.03),
                            _cardDesign.gradient[1].withOpacity(_isHovered ? 0.04 : 0.01),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Акцентные элементы
                  Positioned(
                    top: -60,
                    right: -60,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 800),
                      width: _isHovered ? 160 : 120,
                      height: _isHovered ? 160 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _cardDesign.gradient[0].withOpacity(_isHovered ? 0.12 : 0.08),
                            _cardDesign.gradient[0].withOpacity(0.02),
                          ],
                          stops: const [0.1, 1.0],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -40,
                    left: -40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _cardDesign.gradient[1].withOpacity(0.06),
                            _cardDesign.gradient[1].withOpacity(0.01),
                          ],
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
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _cardDesign.gradient[0].withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: child,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(bool isAuthor, Map<String, String> userTags, Color tagColor) {
    final authorName = _getStringValue(widget.news['author_name']);
    final createdAt = _getStringValue(widget.news['created_at']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final channelId = _getStringValue(widget.news['channel_id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final isRepost = _getBoolValue(widget.news['is_repost']);
    final repostedByName = _getStringValue(widget.news['reposted_by_name']);
    final originalAuthorName = _getStringValue(widget.news['original_author_name']);
    final originalChannelName = _getStringValue(widget.news['original_channel_name']);
    final isOriginalChannelPost = _getBoolValue(widget.news['is_original_channel_post']);

    final repostComment = _getStringValue(widget.news['repost_comment']);
    final hasRepostComment = isRepost && repostComment.isNotEmpty;

    // Если это репост, показываем информацию о том, кто репостнул ОТДЕЛЬНО
    if (isRepost && repostedByName.isNotEmpty) {
      return _buildRepostHeader(
          repostedByName,
          createdAt,
          hasRepostComment ? repostComment : null,
          originalAuthorName,
          originalChannelName,
          isOriginalChannelPost
      );
    }

    // Обычный пост (не репост) - ТАКИЕ ЖЕ отступы
    String authorAvatar;
    String displayName;

    if (isChannelPost && channelId.isNotEmpty) {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), // ФИКСИРОВАННЫЕ отступы
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatar(authorAvatar, isChannelPost, displayName, avatarSize),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    if (!isRepost || displayName == userProvider.userName)
                      _buildMenuButton(),
                  ],
                ),
                const SizedBox(height: 4),
                _buildPostMetaInfo(false, isChannelPost, createdAt, false, userTags),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepostHeader(
      String repostedByName,
      String createdAt,
      String? repostComment,
      String originalAuthorName,
      String originalChannelName,
      bool isOriginalChannelPost
      ) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isCurrentUser = repostedByName == userProvider.userName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ИНФОРМАЦИЯ О ТОМ, КТО РЕПОСТНУЛ
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватарка того, кто репостнул
                _buildUserAvatar(
                  _getUserAvatarUrl(repostedByName, isCurrentUser: isCurrentUser),
                  false,
                  repostedByName,
                  _getAvatarSize(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              repostedByName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: _getTitleFontSize(context),
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _buildMenuButton(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            widget.getTimeAgo(createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Icon(Icons.repeat_rounded, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'репостнул',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // КОММЕНТАРИЙ РЕПОСТА (если есть) - БЕЗ белой секции
          if (repostComment != null && repostComment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 52), // Отступ слева для выравнивания с текстом
              child: Text(
                repostComment,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, String> _getUserTagsForOriginalPost(String originalPostId) {
    try {
      if (_userTagsProvider != null && _userTagsProvider!.isInitialized) {
        final originalTags = _userTagsProvider!.getTagsForPost(originalPostId);

        if (originalTags is Map<String, String> && originalTags.isNotEmpty) {
          print('✅ NewsCard: теги оригинального поста $originalPostId: $originalTags');
          return Map<String, String>.from(originalTags);
        }
      }
    } catch (e) {
      print('❌ Ошибка получения тегов оригинального поста: $e');
    }

    // Возвращаем пустые теги если не удалось получить
    return <String, String>{};
  }

  Widget _buildRepostCommentSection(String repostComment, String repostedByName,
      String originalAuthorName, String originalChannelName, bool isOriginalChannelPost) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: _getAvatarSize(context) + 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватарка пользователя, сделавшего репост (уменьшенная)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: ClipOval(
                child: _buildImageWidget(
                  _getUserAvatarUrl(repostedByName, isCurrentUser: repostedByName == userProvider.userName),
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Никнейм и комментарий
                  Text(
                    repostedByName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    repostComment,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleRepostHeader(String repostedByName, bool hasRepostComment) {
    return Padding(
      padding: EdgeInsets.only(bottom: hasRepostComment ? 4 : 8, left: _getAvatarSize(context) + 16),
      child: Row(
        children: [
          Icon(
            Icons.repeat_rounded,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            repostedByName,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostMetaInfo(bool isRepost, bool isChannelPost, String createdAt, bool hasRepostComment, Map<String, String> userTags) {
    final hasPersonalTags = userTags.isNotEmpty && !isRepost; // УБИРАЕМ теги для репостов

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
                const SizedBox(width: 4),
                Text(
                  widget.getTimeAgo(createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // ПЕРСОНАЛЬНЫЕ ТЕГИ ТОЛЬКО ДЛЯ НЕ-РЕПОСТОВ
            if (hasPersonalTags) ...[
              const SizedBox(width: 12),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              ...userTags.entries.map((entry) {
                final tagId = entry.key;
                final tagName = entry.value;
                final color = _getTagColor(tagId);

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildUserTag(tagName, tagId, color, false),
                );
              }),
            ],

            // Только для каналов и типов контента (если не репост)
            if (!isRepost) ...[
              if (isChannelPost) ...[
                const SizedBox(width: 12),
                Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Icon(Icons.group_rounded, size: 12, color: Colors.blue),
                const SizedBox(width: 4),
                Text('Канал', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w700)),
              ] else if (_contentType != ContentType.general) ...[
                const SizedBox(width: 12),
                Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Icon(_contentIcon, size: 12, color: _contentColor),
                const SizedBox(width: 4),
                Text(_getContentTypeText(), style: TextStyle(color: _contentColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildMenuButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600], size: 18),
        onSelected: _handleMenuSelection,
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.share_rounded, color: Colors.blue, size: 14),
                ),
                const SizedBox(width: 12),
                Text('Поделиться', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 160),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddTagDialog() {
    if (!mounted) return;

    final postId = _getStringValue(widget.news['id']);
    _tagEditController.text = '';
    _editingTagId = 'tag1';

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
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _cardDesign.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.local_offer_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Добавить персональный тег',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _tagEditController,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Название тега',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: _contentColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Выберите цвет:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _userTagsProvider?.availableColors.length ?? _availableColors.length,
                          itemBuilder: (context, index) {
                            final color = _userTagsProvider?.availableColors[index] ?? _availableColors[index];
                            return GestureDetector(
                              onTap: () => setState(() => dialogSelectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: dialogSelectedColor == color ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: dialogSelectedColor == color
                                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                side: BorderSide(color: Colors.grey[400]!),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: const Text('Отмена', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _tagEditController.text.trim().isNotEmpty ? () {
                                final text = _tagEditController.text.trim();

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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                                shadowColor: _contentColor.withOpacity(0.4),
                              ),
                              child: const Text(
                                'Сохранить',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _contentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _contentColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              size: 14,
              color: _contentColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Добавить тег',
              style: TextStyle(
                color: _contentColor,
                fontSize: 12,
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

  Widget _buildUserTag(String tag, String tagId, Color color, bool isChannelPost) {
    return GestureDetector(
      onTap: () => _showTagEditDialog(tag, tagId, color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Уменьшенные отступы
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8), // Уменьшенный радиус
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, // Уменьшенный размер точки
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6), // Уменьшенный отступ
            Text(
              tag,
              style: TextStyle(
                color: color,
                fontSize: 11, // Уменьшенный размер шрифта
                fontWeight: FontWeight.w600,
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
      runSpacing: 8,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: cleanedHashtags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _contentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _contentColor.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: _contentColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<dynamic> get _currentComments {
    return _postState?.comments ?? [];
  }

  Widget _buildPostActions({bool showBookmark = true, bool isAuthor = false}) {
    if (_postState == null) return const SizedBox();

    final isMobile = MediaQuery.of(context).size.width <= 700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start, // Выравнивание по левому краю
        children: [
          _buildActionButton(
            icon: _postState!.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            count: _postState!.likesCount,
            isActive: _postState!.isLiked,
            color: Colors.red,
            onPressed: _handleLike,
            isMobile: isMobile,
          ),
          const SizedBox(width: 12), // Увеличил отступ между кнопками
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: _postState!.comments.length,
            isActive: _isExpanded,
            color: Colors.blue,
            onPressed: _toggleExpanded,
            isMobile: isMobile,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: _postState!.isReposted ? Icons.repeat_on_rounded : Icons.repeat_rounded,
            count: _postState!.repostsCount,
            isActive: _postState!.isReposted,
            color: Colors.green,
            onPressed: _handleRepost,
            isMobile: isMobile,
          ),
          if (showBookmark) const SizedBox(width: 12),
          if (showBookmark)
            _buildActionButton(
              icon: _postState!.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              count: 0,
              isActive: _postState!.isBookmarked,
              color: Colors.amber,
              onPressed: _handleBookmark,
              isMobile: isMobile,
            ),
          const Spacer(),
          if (_shouldShowFollowButton(isAuthor))
            _buildFollowButton(isMobile: isMobile),
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
    bool isMobile = false,
  }) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 14,
            vertical: isMobile ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
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
                size: isMobile ? 18 : 20, // Увеличил размер иконок
                color: isActive ? color : Colors.grey[700],
              ),
              if (count > 0) ...[
                SizedBox(width: isMobile ? 6 : 8), // Увеличил отступ
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : Colors.grey[700],
                    fontSize: isMobile ? 13 : 14, // Увеличил размер шрифта
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

  Widget _buildFollowButton({bool isMobile = false}) {
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);

    return GestureDetector(
      onTap: _toggleFollow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          gradient: _isFollowing
              ? null
              : LinearGradient(
            colors: _cardDesign.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: _isFollowing ? Colors.green.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          border: Border.all(
            color: _isFollowing ? Colors.green.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isFollowing ? Icons.check_rounded : Icons.add_rounded,
              size: isMobile ? 14 : 16,
              color: _isFollowing ? Colors.green : Colors.white,
            ),
            if (!isMobile) SizedBox(width: _isFollowing ? 0 : 6),
            if (!isMobile)
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                crossFadeState: _isFollowing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: Text(
                  'Подписаться',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                secondChild: Text(
                  'Подписка',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _cardDesign.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.edit_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Редактировать персональный тег',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _tagEditController,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Название тега',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: _contentColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Выберите цвет:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _userTagsProvider?.availableColors.length ?? _availableColors.length,
                          itemBuilder: (context, index) {
                            final color = _userTagsProvider?.availableColors[index] ?? _availableColors[index];
                            return GestureDetector(
                              onTap: () => setState(() => dialogSelectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: dialogSelectedColor == color ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: dialogSelectedColor == color
                                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sync_rounded,
                              color: updateGlobally ? _contentColor : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Обновить во всех постах',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
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
                        const SizedBox(height: 12),
                        const Text(
                          'Этот тег будет обновлен во всех ваших постах',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                side: BorderSide(color: Colors.grey[400]!),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: const Text('Отмена', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _tagEditController.text.trim().isNotEmpty ? () {
                                final text = _tagEditController.text.trim();

                                if (_userTagsProvider != null) {
                                  _userTagsProvider!.updateTagForPost(
                                    postId: postId,
                                    tagId: _editingTagId,
                                    newName: text,
                                    color: dialogSelectedColor,
                                    updateGlobally: updateGlobally,
                                    context: context,
                                  );
                                }

                                Navigator.pop(context);

                                if (updateGlobally) {
                                  _showSuccessSnackBar('Тег обновлен во всех постах');
                                } else {
                                  _showSuccessSnackBar('Тег обновлен только в этом посте');
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _contentColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                                shadowColor: _contentColor.withOpacity(0.4),
                              ),
                              child: const Text(
                                'Сохранить',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
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

  Widget _buildCommentsSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _cardDesign.gradient[0].withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            children: [
              if (_currentComments.isNotEmpty) ...[
                ..._currentComments.map((comment) => _buildCommentItem(comment)),
                const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentAvatar(authorAvatar, author),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildImageWidget(
          avatarUrl,
          width: 44,
          height: 44,
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _buildImageWidget(
                    currentUserAvatar,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Напишите комментарий...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _cardDesign.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _cardDesign.gradient[0].withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty && mounted) {
                      _handleComment(text, userProvider.userName, currentUserAvatar);
                      _commentController.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.check_rounded, color: Colors.white, size: 14),
                              ),
                              const SizedBox(width: 12),
                              const Text('Комментарий отправлен'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }
                  },
                  padding: const EdgeInsets.all(12),
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

    final isRepost = _getBoolValue(widget.news['is_repost']);
    final originalAuthorName = _getStringValue(widget.news['original_author_name']);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ЗАГОЛОВОК
          _buildPostHeader(isAuthor, userTags, tagColor),

          // СОДЕРЖИМОЕ ПОСТА
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Для репостов показываем оригинального автора с вертикальной линией и темным фоном
                if (isRepost && originalAuthorName.isNotEmpty)
                  _buildRepostedPostSection(originalAuthorName)
                else
                  _buildRegularPostContent(hashtags, isAuthor),
              ],
            ),
          ),

          // КОММЕНТАРИИ
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

  Widget _buildRegularPostContent(List<String> hashtags, bool isAuthor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ЗАГОЛОВОК ПОСТА
        if (_getStringValue(widget.news['title']).isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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

        // ОСНОВНОЙ ТЕКСТ
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            _getStringValue(widget.news['description']),
            style: TextStyle(
              fontSize: _getDescriptionFontSize(context),
              color: Colors.black87.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ),

        // ХЕШТЕГИ
        if (hashtags.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _buildHashtags(hashtags),
          ),
        ],

        // КНОПКИ ДЕЙСТВИЙ
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: _buildPostActions(isAuthor: isAuthor),
        ),
      ],
    );
  }

  Widget _buildRepostedPostSection(String originalAuthorName) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final hashtags = _parseHashtags(widget.news['hashtags']);

    // ПОЛУЧАЕМ ИНФОРМАЦИЮ ОБ ОРИГИНАЛЬНОМ КАНАЛЕ
    final originalChannelName = _getStringValue(widget.news['original_channel_name']);
    final isOriginalChannelPost = _getBoolValue(widget.news['is_original_channel_post']);
    final originalCreatedAt = _getStringValue(widget.news['original_created_at']);

    // ОТЛАДКА
    print('🔄 Building repost section:');
    print('   originalChannelName: $originalChannelName');
    print('   isOriginalChannelPost: $isOriginalChannelPost');
    print('   originalAuthorName: $originalAuthorName');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // ВЕРТИКАЛЬНАЯ ЛИНИЯ СЛЕВА
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _cardDesign.gradient[0].withOpacity(0.6),
                    _cardDesign.gradient[1].withOpacity(0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 12, right: 16, top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар и имя оригинального автора/канала
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Аватар оригинального канала или пользователя
                    if (isOriginalChannelPost && originalChannelName.isNotEmpty)
                      _buildChannelAvatarForRepost(originalChannelName)
                    else
                      _buildUserAvatar(
                        _getUserAvatarUrl(originalAuthorName, isOriginalPost: true),
                        false,
                        originalAuthorName,
                        _getAvatarSize(context),
                        isOriginalPost: true,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Название канала или имя пользователя
                          Text(
                            isOriginalChannelPost && originalChannelName.isNotEmpty
                                ? originalChannelName
                                : originalAuthorName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: _getTitleFontSize(context),
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Мета-информация с указанием типа и администратора
                          _buildOriginalPostMetaInfo(isOriginalChannelPost, originalChannelName, originalAuthorName, originalCreatedAt),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ЗАГОЛОВОК ОРИГИНАЛЬНОГО ПОСТА (если есть)
                if (_getStringValue(widget.news['title']).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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

                // ТЕКСТ ОРИГИНАЛЬНОГО ПОСТА
                if (_getStringValue(widget.news['description']).isNotEmpty)
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

                // ХЕШТЕГИ ОРИГИНАЛЬНОГО ПОСТА
                if (hashtags.isNotEmpty) ...[
                  _buildHashtags(hashtags),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalPostMetaInfo(bool isOriginalChannelPost, String originalChannelName, String originalAuthorName, String originalCreatedAt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ВРЕМЯ ОРИГИНАЛЬНОГО ПОСТА
            if (originalCreatedAt.isNotEmpty) ...[
              Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                widget.getTimeAgo(originalCreatedAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            // УКАЗАНИЕ ТИПА (КАНАЛ ИЛИ ПОЛЬЗОВАТЕЛЬ)
            if (isOriginalChannelPost && originalChannelName.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Icon(Icons.group_rounded, size: 12, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                'Канал',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Icon(Icons.person_rounded, size: 12, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Пользователь',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ОБНОВИТЕ МЕТОД ДЛЯ КАНАЛЬНЫХ АВАТАРОК В РЕПОСТАХ
  Widget _buildChannelAvatarForRepost(String channelName) {
    final size = _getAvatarSize(context);

    // Получаем правильный URL для канала в репосте
    final avatarUrl = _getUserAvatarUrl(channelName, isOriginalPost: true);

    print('🔄 Building channel avatar for repost: $channelName');
    print('   Avatar URL: $avatarUrl');

    return GestureDetector(
      onTap: () {
        // Можно добавить переход к каналу
        print('Opening original channel: $channelName');
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildImageWidgetWithFallback(
              avatarUrl,
              channelName,
              size: size
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleOriginalPostMetaInfo() {
    final originalCreatedAt = _getStringValue(widget.news['original_created_at']);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ТОЛЬКО время оригинального поста
        if (originalCreatedAt.isNotEmpty) ...[
          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            widget.getTimeAgo(originalCreatedAt),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChannelPost() {
    final title = _getStringValue(widget.news['title']);
    final description = _getStringValue(widget.news['description']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final createdAt = _getStringValue(widget.news['created_at']);
    final hashtags = _parseHashtags(widget.news['hashtags']);
    final channelId = _getStringValue(widget.news['channel_id']);

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
          _buildPostHeader(false, userTags, tagColor),
          Padding(
            padding: EdgeInsets.only(left: _getAvatarSize(context) + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 12),
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
                    padding: const EdgeInsets.only(bottom: 16),
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
                    padding: const EdgeInsets.only(bottom: 16), // Уменьшенный отступ
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
  final Color backgroundColor;

  const CardDesign({
    required this.gradient,
    required this.pattern,
    required this.decoration,
    required this.accentColor,
    required this.backgroundColor,
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

class RepostWithCommentDialog extends StatefulWidget {
  final CardDesign cardDesign;
  final Function(String) onRepost;

  const RepostWithCommentDialog({
    super.key,
    required this.cardDesign,
    required this.onRepost,
  });

  @override
  State<RepostWithCommentDialog> createState() => _RepostWithCommentDialogState();
}

class _RepostWithCommentDialogState extends State<RepostWithCommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isDialogProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  bool get _isButtonEnabled {
    return _commentController.text.trim().isNotEmpty && !_isDialogProcessing;
  }

  void _handleRepost() {
    if (!_isButtonEnabled) return;

    setState(() {
      _isDialogProcessing = true;
    });

    final commentText = _commentController.text.trim();
    _commentFocusNode.unfocus();

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      if (mounted) {
        Navigator.pop(context);
        widget.onRepost(commentText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ШАПКА ДИАЛОГА
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.cardDesign.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Добавить комментарий к репосту',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // СОДЕРЖИМОЕ ДИАЛОГА
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ваш комментарий будет отображаться над репостом',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ПОЛЕ ВВОДА КОММЕНТАРИЯ
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 140,
                          maxHeight: 200,
                        ),
                        child: TextField(
                          controller: _commentController,
                          focusNode: _commentFocusNode,
                          maxLines: null,
                          maxLength: 280,
                          onChanged: (text) {
                            setState(() {}); // Обновляем состояние при изменении текста
                          },
                          decoration: InputDecoration(
                            hintText: 'Поделитесь своими мыслями...',
                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                            counterStyle: TextStyle(color: Colors.grey[500]),
                          ),
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // СЧЕТЧИК СИМВОЛОВ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_commentController.text.length}/280',
                          style: TextStyle(
                            color: _commentController.text.length > 250
                                ? Colors.orange
                                : Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_commentController.text.length > 250)
                          Text(
                            'Слишком длинный комментарий',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),

                    // ИНДИКАТОР ЗАГРУЗКИ
                    if (_isDialogProcessing) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(widget.cardDesign.gradient[0]),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Создание репоста...',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // КНОПКИ ДИАЛОГА
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isDialogProcessing ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? _handleRepost : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.cardDesign.gradient[0],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: widget.cardDesign.gradient[0].withOpacity(0.4),
                      ),
                      child: _isDialogProcessing
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Репостнуть',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}