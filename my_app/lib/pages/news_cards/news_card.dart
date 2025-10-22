// 🎯 ОПТИМИЗИРОВАННЫЙ NEWS CARD С МАКСИМАЛЬНОЙ ПРОИЗВОДИТЕЛЬНОСТЬЮ

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// МОДЕЛИ
import '../../providers/state_sync_provider.dart';
import '../../services/interaction_manager.dart' as im;
import '../../state_sync_mixin.dart';
import '../channel_page/cards_detail_page/channel_detail_page.dart';
import '../channel_page/cards_detail_page/models/channel.dart';
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
import '../../providers/news_providers/news_provider.dart';
import '../../providers/news_providers/user_tags_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/channel_provider/channel_state_provider.dart';

// СЕРВИСЫ
import '../../services/repost_manager.dart';

// КЛАСС ДЛЯ КЭШИРОВАНИЯ ДАННЫХ NEWS CARD
class _NewsCardCache {
  final Map<String, dynamic> news;

  _NewsCardCache(this.news) {
    _precomputeValues();
  }

  // КЭШИРОВАННЫЕ ЗНАЧЕНИЯ
  late final String postId;
  late final bool isRepost;
  late final bool isChannelPost;
  late final String channelId;
  late final String authorId;
  late final CardDesign cardDesign;
  late final ContentType contentType;
  late final String authorName;
  late final String channelName;
  late final String authorAvatar;

  void _precomputeValues() {
    postId = _getStringValue(news['id']);
    isRepost = _getBoolValue(news['is_repost']);
    isChannelPost = _getBoolValue(news['is_channel_post']);
    channelId = _getStringValue(news['channel_id']);
    authorId = _getStringValue(news['author_id']);
    cardDesign = LayoutUtils.getCardDesign(news);
    contentType = LayoutUtils.getContentType(news);
    authorName = _getStringValue(news['author_name']);
    channelName = _getStringValue(news['channel_name']);
    authorAvatar = _getStringValue(news['author_avatar']);
  }

  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }
}

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
  im.InteractionManager get interactionManager {
    // БЕЗОПАСНЫЙ ДОСТУП К ПРОВАЙДЕРУ
    if (_isDisposed) {
      return im.InteractionManager();
    }
    return Provider.of<NewsProvider>(context, listen: false).interactionManager;
  }

  // ИСПРАВЛЕНИЕ: Не используем _newsCache в геттере
  @override
  String get postId => _getStringValue(widget.news['id']);

  // КЭШ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
  late _NewsCardCache _newsCache;

  // СОСТОЯНИЕ
  bool _isExpanded = false;
  bool _isFollowing = false;
  bool _isHovered = false;
  bool _isReposting = false;

  // ФЛАГ БЕЗОПАСНОСТИ
  bool _isDisposed = false;

  // КЭШ ДЛЯ АВАТАРКИ КАНАЛА
  String? _cachedChannelAvatarUrl;

  @override
  void initState() {
    super.initState();

    // ИНИЦИАЛИЗАЦИЯ КЭША ПЕРВОЙ
    _newsCache = _NewsCardCache(widget.news);

    _initializeAnimations();
    _setupAuthorData();

    // print('✅ NewsCard initialized with caching for: ${_newsCache.postId}');
  }

  // ✅ ОБЯЗАТЕЛЬНЫЙ МЕТОД ДЛЯ MIXIN
  @override
  void _initializePostState() {
    // ИСПРАВЛЕНИЕ: Используем напрямую widget.news для инициализации
    if (_isDisposed) return;

    interactionManager.initializePostState(
      postId: postId,
      isLiked: _getBoolValue(widget.news['isLiked']),
      isBookmarked: _getBoolValue(widget.news['isBookmarked']),
      isReposted: _getBoolValue(widget.news['isReposted'] ?? false),
      likesCount: _getIntValue(widget.news['likes']),
      repostsCount: _getIntValue(widget.news['reposts'] ?? 0),
      comments: List<Map<String, dynamic>>.from(widget.news['comments'] ?? []),
    );
  }

  void _initializeAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOut,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _setupAuthorData() {
    _isFollowing = _getBoolValue(widget.news['isFollowing']);

    // ПРЕДВАРИТЕЛЬНО КЭШИРУЕМ АВАТАРКУ КАНАЛА
    if (_newsCache.isChannelPost && _newsCache.channelId.isNotEmpty) {
      _precacheChannelAvatar();
    }
  }

  void _precacheChannelAvatar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;

      try {
        final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
        _cachedChannelAvatarUrl = _getChannelAvatarUrlInternal(channelStateProvider);
      } catch (e) {
        // Игнорируем ошибки при предварительном кэшировании
      }
    });
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

  // ОПТИМИЗИРОВАННЫЕ ОБРАБОТЧИКИ СОБЫТИЙ
  void _handleLike() {
    if (_isDisposed) return;

    interactionManager.toggleLike(postId);
    _notifyStateSync();
  }

  void _handleBookmark() {
    if (_isDisposed) return;

    interactionManager.toggleBookmark(postId);
    _notifyStateSync();
  }

  void _handleRepost() {
    if (_isDisposed) return;
    _showRepostOptionsModal();
  }

  void _handleComment(String text, String author, String avatar) {
    if (_isDisposed) return;

    interactionManager.addComment(
      postId: postId,
      text: text,
      author: author,
      authorAvatar: avatar,
    );

    _notifyStateSync();
  }

  // БЕЗОПАСНЫЙ МЕТОД ДЛЯ УВЕДОМЛЕНИЯ STATE SYNC
  void _notifyStateSync() {
    if (_isDisposed) return;

    try {
      final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
      stateSync.notifyPostUpdated(postId);
    } catch (e) {
      // Игнорируем ошибки доступа к провайдеру
    }
  }

  void _toggleExpanded() {
    if (_isDisposed) return;

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
    if (_isDisposed) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUserId = userProvider.userId;

      final authorIdToUse = _newsCache.isRepost
          ? _getStringValue(widget.news['original_author_id'])
          : _newsCache.authorId;

      if (authorIdToUse == currentUserId) {
        return;
      }

      final channelIdToUse = _newsCache.isRepost
          ? _getStringValue(widget.news['original_channel_id'])
          : _newsCache.channelId;

      if (_newsCache.isChannelPost && channelIdToUse.isNotEmpty) {
        final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
        final currentSubscribers = channelStateProvider.getSubscribers(channelIdToUse) ?? 0;
        channelStateProvider.toggleSubscription(channelIdToUse, currentSubscribers);

        setState(() {
          _isFollowing = channelStateProvider.isSubscribed(channelIdToUse);
        });
      } else {
        setState(() {
          _isFollowing = !_isFollowing;
        });
        widget.onFollow?.call();
      }
    } catch (e) {
      // Игнорируем ошибки доступа к провайдеру
    }
  }

  // 🔄 ОПТИМИЗИРОВАННЫЕ МЕТОДЫ ДЛЯ РЕПОСТА
  void _showRepostOptionsModal() {
    if (_isDisposed) return;

    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => RepostOptionsModal(
          onSimpleRepost: _handleSimpleRepost,
          onRepostWithComment: _showRepostWithCommentDialog,
        ),
      );
    } catch (e) {
      // Игнорируем ошибки показа модального окна
    }
  }

  void _handleSimpleRepost() {
    if (_isDisposed) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      interactionManager.toggleRepost(
        postId: postId,
        currentUserId: userProvider.userId ?? '',
        currentUserName: userProvider.userName,
      );

      _showRepostSuccessSnackBar();
    } catch (e) {
      // Игнорируем ошибки доступа к провайдеру
    }
  }

  void _showRepostWithCommentDialog() {
    if (_isDisposed) return;

    try {
      showDialog(
        context: context,
        builder: (context) => RepostWithCommentDialog(
          cardDesign: _newsCache.cardDesign,
          onRepost: _handleRepostWithComment,
        ),
      );
    } catch (e) {
      // Игнорируем ошибки показа диалога
    }
  }

  void _handleRepostWithComment(String comment) {
    if (_isDisposed) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);

      final originalIndex = newsProvider.findNewsIndexById(postId);
      if (originalIndex == -1) {
        return;
      }

      if (_isReposting) return;

      _isReposting = true;

      final repostManager = RepostManager();
      repostManager.createRepostWithComment(
        newsProvider: newsProvider,
        originalIndex: originalIndex,
        currentUserId: userProvider.userId ?? '',
        currentUserName: userProvider.userName,
        comment: comment,
      ).then((_) {
        if (!_isDisposed) {
          _isReposting = false;
          _showEnhancedRepostSuccessSnackBar(comment);
        }
      }).catchError((error) {
        if (!_isDisposed) {
          _isReposting = false;
          _showRepostErrorSnackBar();
        }
      });
    } catch (e) {
      if (!_isDisposed) {
        _isReposting = false;
      }
    }
  }

  // МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ КАНАЛА С КЭШИРОВАНИЕМ
  String _getChannelAvatarUrl() {
    if (_isDisposed) {
      return _newsCache.authorAvatar;
    }

    // ИСПОЛЬЗУЕМ КЭШИРОВАННОЕ ЗНАЧЕНИЕ ЕСЛИ ЕСТЬ
    if (_cachedChannelAvatarUrl != null) {
      return _cachedChannelAvatarUrl!;
    }

    try {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      final avatarUrl = _getChannelAvatarUrlInternal(channelStateProvider);

      // КЭШИРУЕМ РЕЗУЛЬТАТ
      _cachedChannelAvatarUrl = avatarUrl;
      return avatarUrl;
    } catch (e) {
      return _newsCache.authorAvatar;
    }
  }

  String _getChannelAvatarUrlInternal(ChannelStateProvider channelStateProvider) {
    if (_newsCache.isRepost) {
      return _getRepostChannelAvatar(channelStateProvider);
    } else {
      return _getRegularChannelAvatar(channelStateProvider);
    }
  }

  String _getRepostChannelAvatar(ChannelStateProvider channelStateProvider) {
    final channelId = _getStringValue(widget.news['original_channel_id']);
    final channelAvatar = _getStringValue(widget.news['original_channel_avatar']);
    final isChannelPost = _getBoolValue(widget.news['is_original_channel_post']);

    if (isChannelPost && channelAvatar.isEmpty) {
      if (channelId.isNotEmpty) {
        final customAvatar = channelStateProvider.getAvatarForChannel(channelId);
        if (customAvatar != null && customAvatar.isNotEmpty) {
          return customAvatar;
        }
      }

      final originalChannelName = _getStringValue(widget.news['original_channel_name']);
      if (originalChannelName.isNotEmpty) {
        return ImageUtils.getUniversalAvatarUrl(
          context: context,
          userId: 'channel_${originalChannelName.hashCode.abs()}',
          userName: originalChannelName,
        );
      }
    }

    return channelAvatar.isNotEmpty ? channelAvatar : _newsCache.authorAvatar;
  }

  String _getRegularChannelAvatar(ChannelStateProvider channelStateProvider) {
    final channelId = _newsCache.channelId;
    final channelAvatar = _getStringValue(widget.news['channel_avatar']);

    if (channelId.isNotEmpty) {
      final customAvatar = channelStateProvider.getAvatarForChannel(channelId);
      if (customAvatar != null && customAvatar.isNotEmpty) {
        return customAvatar;
      }
    }

    if (channelAvatar.isNotEmpty) {
      return channelAvatar;
    }

    return _newsCache.authorAvatar;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _expandController.dispose();
    _commentController.dispose();

    // print('🔴 NewsCard disposed: ${_newsCache.postId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ИСПРАВЛЕНИЕ: Добавляем проверку mounted и isDisposed
    if (_isDisposed) {
      return _buildLoadingCard();
    }

    return Consumer<StateSyncProvider>(
      builder: (context, stateSync, child) {
        if (_isDisposed) {
          return _buildLoadingCard();
        }

        if (postState == null) {
          return _buildLoadingCard();
        }

        // ОПТИМИЗАЦИЯ: Используем кэшированные значения для определения типа поста
        if (_newsCache.isRepost) {
          return _buildRepost();
        } else {
          return _newsCache.isChannelPost ? _buildChannelPost() : _buildRegularPost();
        }
      },
    );
  }

  // ОПТИМИЗИРОВАННЫЕ МЕТОДЫ ПОСТРОЕНИЯ ВИДЖЕТОВ
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      margin: LayoutUtils.getCardMargin(context),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: LayoutUtils.getContentMaxWidth(context)),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(LayoutUtils.getCardBorderRadius(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoadingHeader(),
              _buildLoadingContent(),
              _buildLoadingActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
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
    );
  }

  Widget _buildLoadingContent() {
    return Container(
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
    );
  }

  Widget _buildLoadingActions() {
    return Container(
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
    );
  }

  Widget _buildRegularPost() {
    return Consumer2<UserProvider, UserTagsProvider>(
      builder: (context, userProvider, userTagsProvider, child) {
        final isAuthor = _newsCache.authorName == userProvider.userName;

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              NewsCardHeader(
                news: widget.news,
                onUserProfile: _openUserProfile,
                onChannelTap: _openChannel,
                onMenuPressed: _handleMenuSelection,
                formatDate: widget.formatDate,
                getTimeAgo: widget.getTimeAgo,
                userTagsProvider: userTagsProvider,
                isChannelPost: _newsCache.isChannelPost,
                customAvatarUrl: _getChannelAvatarUrl(),
              ),

              NewsCardContent(
                news: widget.news,
                cardDesign: _newsCache.cardDesign,
                contentType: _newsCache.contentType,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: NewsCardActions(
                  postState: postState!,
                  isAuthor: isAuthor,
                  isChannelPost: _newsCache.isChannelPost,
                  isFollowing: _isFollowing,
                  onLike: _handleLike,
                  onComment: _toggleExpanded,
                  onRepost: _handleRepost,
                  onBookmark: _handleBookmark,
                  onFollow: _toggleFollow,
                  showFollowButton: true,
                ),
              ),

              _buildCommentsSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepost() {
    return Consumer2<UserProvider, UserTagsProvider>(
      builder: (context, userProvider, userTagsProvider, child) {
        final isAuthor = _newsCache.authorName == userProvider.userName;

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RepostHeader(
                news: widget.news,
                onUserProfile: _openUserProfile,
                onChannelTap: _openChannel,
                onMenuPressed: _handleMenuSelection,
                getTimeAgo: widget.getTimeAgo,
                customAvatarUrl: _getChannelAvatarUrl(),
              ),

              RepostContent(
                news: widget.news,
                cardDesign: _newsCache.cardDesign,
                contentType: _newsCache.contentType,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: NewsCardActions(
                  postState: postState!,
                  isAuthor: isAuthor,
                  isChannelPost: _newsCache.isChannelPost,
                  isFollowing: _isFollowing,
                  onLike: _handleLike,
                  onComment: _toggleExpanded,
                  onRepost: _handleRepost,
                  onBookmark: _handleBookmark,
                  onFollow: _toggleFollow,
                  showFollowButton: true,
                ),
              ),

              _buildCommentsSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelPost() {
    return Consumer2<UserProvider, UserTagsProvider>(
      builder: (context, userProvider, userTagsProvider, child) {
        final isAuthor = _newsCache.authorName == userProvider.userName;

        return _buildCard(
          isChannel: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _openChannel,
                child: NewsCardHeader(
                  news: widget.news,
                  onUserProfile: _openUserProfile,
                  onChannelTap: _openChannel,
                  onMenuPressed: _handleMenuSelection,
                  formatDate: widget.formatDate,
                  getTimeAgo: widget.getTimeAgo,
                  userTagsProvider: userTagsProvider,
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
                      cardDesign: _newsCache.cardDesign,
                      contentType: _newsCache.contentType,
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

              _buildCommentsSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CommentsSection(
          comments: postState!.comments,
          onComment: _handleComment,
          commentController: _commentController,
          cardDesign: _newsCache.cardDesign,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, bool isChannel = false}) {
    return MouseRegion(
      onEnter: (_) {
        if (!_isDisposed) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!_isDisposed) setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: LayoutUtils.getCardMargin(context),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: LayoutUtils.getContentMaxWidth(context)),
            decoration: LayoutUtils.getCardDecoration(
              context: context,
              cardDesign: _newsCache.cardDesign,
              isHovered: _isHovered,
              isRepost: _newsCache.isRepost,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(LayoutUtils.getCardBorderRadius(context)),
              child: Stack(
                children: [
                  _buildCardBackground(),
                  ...LayoutUtils.buildCardDecorations(_newsCache.cardDesign, _isHovered),
                  _buildCardContent(child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBackground() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _newsCache.cardDesign.gradient[0].withOpacity(_isHovered ? 0.08 : 0.03),
              _newsCache.cardDesign.gradient[1].withOpacity(_isHovered ? 0.04 : 0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (LayoutUtils.shouldShowTopLine(context))
          LayoutUtils.buildTopLine(context, _newsCache.cardDesign),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: child,
        ),
      ],
    );
  }

  void _openChannel() {
    if (_isDisposed) return;

    if (_newsCache.channelId.isEmpty) {
      return;
    }

    try {
      final channel = Channel.fromPostData(widget.news);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChannelDetailPage(channel: channel),
        ),
      );
    } catch (e) {
      // Игнорируем ошибки навигации
    }
  }

  void _openUserProfile() {
    if (_isDisposed) return;
    // print('👤 Открытие профиля пользователя');
  }

  void _handleMenuSelection(String value) {
    if (_isDisposed) return;

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

  void _showRepostErrorSnackBar() {
    if (_isDisposed) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Ошибка при создании репоста')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Игнорируем ошибки показа снекбара
    }
  }

  void _showRepostSuccessSnackBar() {
    if (_isDisposed) return;

    try {
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
              Expanded(child: Text('Репостнул на свою страничку')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Игнорируем ошибки показа снекбара
    }
  }

  void _showEnhancedRepostSuccessSnackBar(String comment) {
    if (_isDisposed) return;

    final hasComment = comment.isNotEmpty;

    try {
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
                    Text(hasComment ? 'Репост с комментарием' : 'Репостнул на свою страничку'),
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
        ),
      );
    } catch (e) {
      // Игнорируем ошибки показа снекбара
    }
  }
}

// ВЫНЕСЕННЫЙ ВИДЖЕТ ДЛЯ МОДАЛЬНОГО ОКНА РЕПОСТА
class RepostOptionsModal extends StatelessWidget {
  final VoidCallback onSimpleRepost;
  final VoidCallback onRepostWithComment;

  const RepostOptionsModal({
    super.key,
    required this.onSimpleRepost,
    required this.onRepostWithComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onSimpleRepost,
            ),
            const SizedBox(height: 16),
            _buildRepostOption(
              Icons.edit_rounded,
              'Репост с комментарием',
              'Добавить свой комментарий к репосту',
              Colors.blue,
              onRepostWithComment,
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
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
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
}