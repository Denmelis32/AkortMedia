// 🎯 ГЛАВНЫЙ ВИДЖЕТ NEWS CARD - точка входа и координатор всех компонентов

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// МОДЕЛИ
import '../../providers/state_sync_provider.dart';
import '../../services/interaction_manager.dart' as im;
import '../../state_sync_mixin.dart';
import '../cards_page/channel_detail_page.dart';
import '../cards_page/models/channel.dart';
import 'components/header/repost_header.dart';
import 'models/news_card_models.dart' hide PostInteractionState;
import 'models/news_card_enums.dart';

// КОМПОНЕНТЫ
import 'components/header/news_card_header.dart';
import 'components/content/news_card_content.dart';
import 'components/content/repost_content.dart';
import 'components/actions/news_card_actions.dart';
import 'components/comments/comments_section.dart';

// ДИАЛОГИ
import 'dialogs/repost_dialog.dart';

// УТИЛИТЫ
import 'utils/layout_utils.dart';
import 'utils/image_utils.dart';

// ПРОВАЙДЕРЫ
import '../../providers/news_provider.dart';
import '../../providers/user_tags_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/channel_state_provider.dart';

// СЕРВИСЫ
import '../../services/repost_manager.dart';

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

class _NewsCardState extends State<NewsCard>
    with SingleTickerProviderStateMixin, StateSyncMixin {

  // КОНТРОЛЛЕРЫ
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  // ✅ ОБЯЗАТЕЛЬНЫЕ ПЕРЕОПРЕДЕЛЕНИЯ ДЛЯ MIXIN
  @override
  im.InteractionManager get interactionManager =>
      Provider.of<NewsProvider>(context, listen: false).interactionManager;

  @override
  String get postId => _getStringValue(widget.news['id']);

  // СОСТОЯНИЕ
  bool _isExpanded = false;
  bool _isFollowing = false;
  double _readingProgress = 0.0;
  bool _isHovered = false;
  bool _isReposting = false;

  // ПРОВАЙДЕРЫ И СЕРВИСЫ
  ChannelStateProvider? _channelStateProvider;
  UserTagsProvider? _userTagsProvider;

  // ФЛАГИ
  bool _isChannelPost = false;
  String _channelId = '';
  String _authorId = '';

  @override
  void initState() {
    super.initState(); // StateSyncMixin инициализируется здесь

    _initializeAnimations();
    _setupUserTagsListener();
    _setupAuthorData();

    print('✅ NewsCard initialized with state synchronization for: $postId');
  }

  // МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ КАНАЛА
  String _getChannelAvatarUrl() {
    // Проверяем mounted перед доступом к контексту
    if (!mounted) {
      print('⚠️ NewsCard: Widget not mounted, returning fallback avatar');
      return _getStringValue(widget.news['author_avatar']);
    }

    try {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);

      final isRepost = _getBoolValue(widget.news['is_repost']);

      String channelId;
      String channelAvatar;
      String authorAvatar;
      bool isChannelPost;

      if (isRepost) {
        // ДЛЯ РЕПОСТОВ: используем данные оригинального канального поста
        channelId = _getStringValue(widget.news['original_channel_id']);
        channelAvatar = _getStringValue(widget.news['original_channel_avatar']);
        authorAvatar = _getStringValue(widget.news['original_author_avatar']);
        isChannelPost = _getBoolValue(widget.news['is_original_channel_post']);

        print('🔍 NewsCard (репост) - получение аватарки для ОРИГИНАЛЬНОГО контента:');
        print('   - original_channel_id: $channelId');
        print('   - original_channel_avatar: $channelAvatar');
        print('   - original_author_avatar: $authorAvatar');
        print('   - is_original_channel_post: $isChannelPost');

        // ❗ ВАЖНОЕ ИСПРАВЛЕНИЕ: Если это канальный репост, но channel_avatar пустой,
        // используем логику для получения аватарки канала
        if (isChannelPost && channelAvatar.isEmpty) {
          print('🔄 NewsCard: Канальный репост без channel_avatar, используем логику канала');

          // Пытаемся получить кастомную аватарку из ChannelStateProvider
          if (channelId.isNotEmpty) {
            final customAvatar = channelStateProvider.getAvatarForChannel(channelId);
            if (customAvatar != null && customAvatar.isNotEmpty) {
              print('✅ NewsCard: Используется кастомная аватарка канала: $customAvatar');
              return customAvatar;
            }
          }

          // Если не нашли кастомную, используем стандартную логику для канала
          final originalChannelName = _getStringValue(widget.news['original_channel_name']);
          if (originalChannelName.isNotEmpty) {
            final channelFallbackAvatar = ImageUtils.getUserAvatarUrl(
              news: widget.news,
              userName: originalChannelName,
              isCurrentUser: false,
              isChannel: true,
            );
            print('✅ NewsCard: Используется fallback аватарка канала: $channelFallbackAvatar');
            return channelFallbackAvatar;
          }
        }
      } else {
        // ДЛЯ ОБЫЧНЫХ ПОСТОВ: используем стандартные данные
        channelId = _getStringValue(widget.news['channel_id']);
        channelAvatar = _getStringValue(widget.news['channel_avatar']);
        authorAvatar = _getStringValue(widget.news['author_avatar']);
        isChannelPost = _getBoolValue(widget.news['is_channel_post']);

        print('🔍 NewsCard (обычный) - получение аватарки:');
        print('   - channel_id: $channelId');
        print('   - channel_avatar: $channelAvatar');
        print('   - is_channel_post: $isChannelPost');
      }

      // 1. Пытаемся получить кастомную аватарку из ChannelStateProvider
      if (channelId.isNotEmpty) {
        final customAvatar = channelStateProvider.getAvatarForChannel(channelId);
        if (customAvatar != null && customAvatar.isNotEmpty) {
          print('✅ NewsCard: Используется кастомная аватарка: $customAvatar');
          return customAvatar;
        }
      }

      // 2. Fallback: используем аватар канала из данных
      if (channelAvatar.isNotEmpty) {
        print('✅ NewsCard: Используется аватарка канала из данных: $channelAvatar');
        return channelAvatar;
      }

      // 3. Final fallback
      final fallbackAvatar = authorAvatar.isNotEmpty ? authorAvatar : _getStringValue(widget.news['author_avatar']);
      print('⚠️ NewsCard: Используется fallback аватарка: $fallbackAvatar');
      return fallbackAvatar;

    } catch (e) {
      print('❌ Error getting channel avatar in NewsCard: $e');
      return _getStringValue(widget.news['author_avatar']);
    }
  }

  // ✅ ОБЯЗАТЕЛЬНЫЙ МЕТОД ДЛЯ MIXIN
  @override
  void _initializePostState() {
    // ✅ Инициализация состояния поста если его нет
    interactionManager.initializePostState(
      postId: postId,
      isLiked: _getBoolValue(widget.news['isLiked']),
      isBookmarked: _getBoolValue(widget.news['isBookmarked']),
      isReposted: _getBoolValue(widget.news['isReposted'] ?? false),
      likesCount: _getIntValue(widget.news['likes']),
      repostsCount: _getIntValue(widget.news['reposts'] ?? 0),
      comments: List<Map<String, dynamic>>.from(widget.news['comments'] ?? []),
    );

    print('✅ NewsCard post state initialized: $postId');
  }

  void _initializeAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

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
  }

  void _setupUserTagsListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userTagsProvider = Provider.of<UserTagsProvider>(context, listen: false);
        _userTagsProvider = userTagsProvider;

        if (!userProvider.isLoggedIn) {
          userProvider.setUserData(
            'Гость',
            'guest@example.com',
            userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        if (!userTagsProvider.isInitialized) {
          await userTagsProvider.initialize(userProvider);
        }

        userTagsProvider.addListener(_onUserTagsChanged);

        if (mounted) setState(() {});
      } catch (e) {
        print('❌ Ошибка инициализации UserTagsProvider: $e');
      }
    });
  }

  void _setupAuthorData() {
    final isRepost = _getBoolValue(widget.news['is_repost']);

    if (isRepost) {
      // ДЛЯ РЕПОСТОВ: используем данные оригинального поста
      _isChannelPost = _getBoolValue(widget.news['is_original_channel_post']);
      _channelId = _getStringValue(widget.news['original_channel_id']);
      _authorId = _getStringValue(widget.news['original_author_id'] ?? widget.news['reposted_by']);
    } else {
      // ДЛЯ ОБЫЧНЫХ ПОСТОВ: используем стандартные данные
      _isChannelPost = _getBoolValue(widget.news['is_channel_post']);
      _channelId = _getStringValue(widget.news['channel_id']);
      _authorId = _getStringValue(widget.news['author_id']);
    }

    _isFollowing = _getBoolValue(widget.news['isFollowing'] ?? false);
    _readingProgress = (widget.news['read_progress'] ?? 0.0).toDouble();

    // Для каналов настраиваем слушатель состояния
    if (_isChannelPost && _channelId.isNotEmpty) {
      _setupChannelListener();
    }

    print('🔍 NewsCard setupAuthorData:');
    print('   - isRepost: $isRepost');
    print('   - isChannelPost: $_isChannelPost');
    print('   - channelId: $_channelId');
    print('   - authorId: $_authorId');
  }

  void _setupChannelListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      _channelStateProvider = channelStateProvider;

      // Для репостов используем original_channel_id для подписки
      final channelIdToUse = _getBoolValue(widget.news['is_repost'])
          ? _getStringValue(widget.news['original_channel_id'])
          : _channelId;

      if (channelIdToUse.isNotEmpty) {
        final isSubscribed = channelStateProvider.isSubscribed(channelIdToUse);
        if (_isFollowing != isSubscribed) {
          setState(() {
            _isFollowing = isSubscribed;
          });
        }

        channelStateProvider.addListener(_onChannelStateChanged);
      }
    });
  }

  void _onUserTagsChanged() {
    if (mounted) setState(() {});
  }

  void _onChannelStateChanged() {
    if (!mounted) return;

    // Для репостов используем original_channel_id
    final channelIdToUse = _getBoolValue(widget.news['is_repost'])
        ? _getStringValue(widget.news['original_channel_id'])
        : _channelId;

    if (_isChannelPost && channelIdToUse.isNotEmpty && _channelStateProvider != null) {
      final isSubscribed = _channelStateProvider!.isSubscribed(channelIdToUse);
      if (_isFollowing != isSubscribed) {
        setState(() {
          _isFollowing = isSubscribed;
        });
      }
    }
  }

  // ОБРАБОТЧИКИ СОБЫТИЙ
  void _handleLike() {
    final postId = _getStringValue(widget.news['id']);

    // ✅ Используем ОБЩИЙ InteractionManager с принудительной синхронизацией
    interactionManager.toggleLike(postId);

    // ✅ ДОПОЛНИТЕЛЬНО УВЕДОМЛЯЕМ StateSyncProvider
    final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
    stateSync.notifyPostUpdated(postId);

    print('✅ NewsCard like handled with FORCE SYNC: $postId');
  }

  void _handleBookmark() {
    final postId = _getStringValue(widget.news['id']);

    interactionManager.toggleBookmark(postId);

    // ✅ ДОПОЛНИТЕЛЬНО УВЕДОМЛЯЕМ StateSyncProvider
    final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
    stateSync.notifyPostUpdated(postId);

    print('✅ NewsCard bookmark handled with FORCE SYNC: $postId');
  }

  void _handleRepost() {
    _showRepostOptionsModal();
  }

  void _handleComment(String text, String author, String avatar) {
    final postId = _getStringValue(widget.news['id']);

    interactionManager.addComment(
      postId: postId,
      text: text,
      author: author,
      authorAvatar: avatar,
    );

    // ✅ ДОПОЛНИТЕЛЬНО УВЕДОМЛЯЕМ StateSyncProvider
    final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
    stateSync.notifyPostUpdated(postId);

    print('✅ NewsCard comment handled with FORCE SYNC: $postId');
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

  void _toggleFollow() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.userId;

    // Для репостов используем original_author_id
    final authorIdToUse = _getBoolValue(widget.news['is_repost'])
        ? _getStringValue(widget.news['original_author_id'])
        : _authorId;

    // Не даем подписываться на самого себя
    if (authorIdToUse == currentUserId) {
      return;
    }

    // Для репостов используем original_channel_id
    final channelIdToUse = _getBoolValue(widget.news['is_repost'])
        ? _getStringValue(widget.news['original_channel_id'])
        : _channelId;

    if (_isChannelPost && channelIdToUse.isNotEmpty && _channelStateProvider != null) {
      // Подписка на канал
      final currentSubscribers = _channelStateProvider!.getSubscribers(channelIdToUse) ?? 0;
      _channelStateProvider!.toggleSubscription(channelIdToUse, currentSubscribers);

      setState(() {
        _isFollowing = _channelStateProvider!.isSubscribed(channelIdToUse);
      });
    } else {
      // Подписка на пользователя
      setState(() {
        _isFollowing = !_isFollowing;
      });
      widget.onFollow?.call();
    }
  }

  // 🔄 МЕТОДЫ ДЛЯ РЕПОСТА
  void _showRepostOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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

  void _handleSimpleRepost() {
    final postId = _getStringValue(widget.news['id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    interactionManager.toggleRepost(
      postId: postId,
      currentUserId: userProvider.userId ?? '',
      currentUserName: userProvider.userName,
    );

    _showRepostSuccessSnackBar();
  }

  void _showRepostWithCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => RepostWithCommentDialog(
        cardDesign: _cardDesign,
        onRepost: _handleRepostWithComment,
      ),
    );
  }

  void _handleRepostWithComment(String comment) {
    if (!mounted) return;

    final postId = _getStringValue(widget.news['id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    final originalIndex = newsProvider.findNewsIndexById(postId);
    if (originalIndex == -1) {
      print('❌ Original post not found: $postId');
      return;
    }

    if (_isReposting) {
      print('⚠️ Repost already in progress, skipping...');
      return;
    }

    _isReposting = true;

    print('🔄 Starting repost with comment: "$comment"');

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

        // ❗ УБРАТЬ ЭТОТ БЛОК - InteractionManager сам обновит счетчик
        /*
      // Обновляем состояние InteractionManager
      interactionManager.updateRepostState(
        postId: postId,
        isReposted: true,
        repostsCount: (postState?.repostsCount ?? 0) + 1,
      );
      */
      }
    }).catchError((error) {
      if (mounted) {
        _isReposting = false;
        print('❌ Error in repost with comment: $error');
        _showRepostErrorSnackBar();
      }
    });
  }

  void _showRepostErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ошибка при создании репоста',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
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

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
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

  // ПОЛУЧЕНИЕ ДАННЫХ ДЛЯ КОМПОНЕНТОВ
  CardDesign get _cardDesign => LayoutUtils.getCardDesign(widget.news);
  ContentType get _contentType => LayoutUtils.getContentType(widget.news);

  @override
  void dispose() {
    _expandController.dispose();
    _commentController.dispose();

    if (_channelStateProvider != null) {
      _channelStateProvider!.removeListener(_onChannelStateChanged);
    }

    if (_userTagsProvider != null) {
      _userTagsProvider!.removeListener(_onUserTagsChanged);
    }

    // StateSyncMixin сам удалит слушатели
    print('🔴 NewsCard disposed: $postId');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Используем StateSyncProvider для принудительной синхронизации
    return Consumer<StateSyncProvider>(
      builder: (context, stateSync, child) {
        // Проверяем mounted перед любыми операциями
        if (!mounted) {
          return _buildLoadingCard();
        }

        final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
        final isRepost = _getBoolValue(widget.news['is_repost']);

        // ✅ ПРОВЕРКА НАЛИЧИЯ СОСТОЯНИЯ
        if (postState == null) {
          return _buildLoadingCard();
        }

        if (isRepost) {
          return _buildRepost();
        } else {
          return isChannelPost ? _buildChannelPost() : _buildRegularPost();
        }
      },
    );
  }

  Widget _buildLoadingCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Загрузочная шапка
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Загрузочный контент
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),

          // Загрузочные действия
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 32,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 32,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 32,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularPost() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authorName = _getStringValue(widget.news['author_name']);
    final isAuthor = authorName == userProvider.userName;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ШАПКА ПОСТА
          NewsCardHeader(
            news: widget.news,
            onUserProfile: _openUserProfile,
            onChannelTap: _openChannel, // 🆕 ПЕРЕДАЕМ ОБРАБОТЧИК ПЕРЕХОДА В КАНАЛ
            onMenuPressed: _handleMenuSelection,
            formatDate: widget.formatDate,
            getTimeAgo: widget.getTimeAgo,
            userTagsProvider: _userTagsProvider,
            isChannelPost: _isChannelPost,
            customAvatarUrl: _getChannelAvatarUrl(),
          ),

          // СОДЕРЖИМОЕ ПОСТА
          NewsCardContent(
            news: widget.news,
            cardDesign: _cardDesign,
            contentType: _contentType,
          ),

          // ДЕЙСТВИЯ - ✅ Используем postState из mixin
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: NewsCardActions(
              postState: postState!,
              isAuthor: isAuthor,
              isChannelPost: _isChannelPost,
              isFollowing: _isFollowing,
              onLike: _handleLike,
              onComment: _toggleExpanded,
              onRepost: _handleRepost,
              onBookmark: _handleBookmark,
              onFollow: _toggleFollow,
              showFollowButton: true,
            ),
          ),

          // КОММЕНТАРИИ - ✅ Используем postState из mixin
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CommentsSection(
                comments: postState!.comments,
                onComment: _handleComment,
                commentController: _commentController,
                cardDesign: _cardDesign,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepost() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authorName = _getStringValue(widget.news['author_name']);
    final isAuthor = authorName == userProvider.userName;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ШАПКА РЕПОСТА
          RepostHeader(
            news: widget.news,
            onUserProfile: _openUserProfile,
            onChannelTap: _openChannel, // 🆕 ПЕРЕДАЕМ ОБРАБОТЧИК ПЕРЕХОДА В КАНАЛ
            onMenuPressed: _handleMenuSelection,
            getTimeAgo: widget.getTimeAgo,
            customAvatarUrl: _getChannelAvatarUrl(),
          ),

          // КОНТЕНТ РЕПОСТА
          RepostContent(
            news: widget.news,
            cardDesign: _cardDesign,
            contentType: _contentType,
          ),

          // ДЕЙСТВИЯ - ✅ Используем postState из mixin
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: NewsCardActions(
              postState: postState!,
              isAuthor: isAuthor,
              isChannelPost: _isChannelPost,
              isFollowing: _isFollowing,
              onLike: _handleLike,
              onComment: _toggleExpanded,
              onRepost: _handleRepost,
              onBookmark: _handleBookmark,
              onFollow: _toggleFollow,
              showFollowButton: true,
            ),
          ),

          // КОММЕНТАРИИ - ✅ Используем postState из mixin
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CommentsSection(
                comments: postState!.comments,
                onComment: _handleComment,
                commentController: _commentController,
                cardDesign: _cardDesign,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelPost() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authorName = _getStringValue(widget.news['author_name']);
    final isAuthor = authorName == userProvider.userName;

    return _buildCard(
      isChannel: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ОБНОВЛЕННАЯ ШАПКА С ВОЗМОЖНОСТЬЮ ПЕРЕХОДА В КАНАЛ
          GestureDetector(
            onTap: _openChannel, // 👈 ДОБАВЬТЕ ЭТОТ ОБРАБОТЧИК
            child: NewsCardHeader(
              news: widget.news,
              onUserProfile: _openUserProfile,
              onChannelTap: _openChannel, // 🆕 ПЕРЕДАЕМ ОБРАБОТЧИК ПЕРЕХОДА В КАНАЛ
              onMenuPressed: _handleMenuSelection,
              formatDate: widget.formatDate,
              getTimeAgo: widget.getTimeAgo,
              userTagsProvider: _userTagsProvider,
              isChannelPost: true,
              customAvatarUrl: _getChannelAvatarUrl(),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: LayoutUtils.getAvatarSize(context) + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                NewsCardContent(
                  news: widget.news,
                  cardDesign: _cardDesign,
                  contentType: _contentType,
                ),

                NewsCardActions(
                  postState: postState!,
                  isAuthor: isAuthor,
                  isChannelPost: true,
                  isFollowing: _isFollowing,
                  onLike: _handleLike,
                  onComment: _toggleExpanded,
                  onRepost: _handleRepost,
                  onBookmark: _handleBookmark,
                  onFollow: _toggleFollow,
                  showFollowButton: true,
                ),
              ],
            ),
          ),

          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CommentsSection(
                comments: postState!.comments,
                onComment: _handleComment,
                commentController: _commentController,
                cardDesign: _cardDesign,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChannel() {
    if (!mounted) return;

    final channelId = _getStringValue(widget.news['channel_id']);
    final channelName = _getStringValue(widget.news['channel_name']);

    if (channelId.isEmpty) {
      print('❌ Channel ID is empty');
      return;
    }

    print('🎯 Opening channel: $channelName ($channelId)');

    // Создаем канал из данных поста
    final channel = Channel.fromPostData(widget.news);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelDetailPage(channel: channel),
      ),
    );
  }


  Widget _buildCard({required Widget child, bool isChannel = false}) {
    final isRepost = _getBoolValue(widget.news['is_repost']);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity,
        margin: LayoutUtils.getCardMargin(context),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: LayoutUtils.getContentMaxWidth(context)),
            decoration: LayoutUtils.getCardDecoration(
              context: context,
              cardDesign: _cardDesign,
              isHovered: _isHovered,
              isRepost: isRepost,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(LayoutUtils.getCardBorderRadius(context)),
              child: Stack(
                children: [
                  // ФОН
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
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

                  // ДЕКОРАТИВНЫЕ ЭЛЕМЕНТЫ
                  ...LayoutUtils.buildCardDecorations(_cardDesign, _isHovered),

                  // КОНТЕНТ
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (LayoutUtils.shouldShowTopLine(context))
                        LayoutUtils.buildTopLine(context, _cardDesign),
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

  // ВРЕМЕННЫЕ МЕТОДЫ ДЛЯ КОМПИЛЯЦИИ
  void _openUserProfile() {
    // TODO: Реализовать переход к профилю
    print('👤 Открытие профиля пользователя');
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'share':
        widget.onShare?.call();
        break;
      case 'edit':
        widget.onEdit?.call();
        break;
      case 'delete':
        widget.onDelete?.call();
        break;
    }
  }
}