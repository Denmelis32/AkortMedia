import 'dart:io';import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/channel_provider/channel_state_provider.dart';
import '../../../../../providers/news_providers/news_provider.dart';
import '../../../../../providers/state_sync_provider.dart';
import '../../../../../providers/user_provider.dart';
import '../../../../../services/interaction_manager.dart' as im;
import '../../../../../state_sync_mixin.dart';
import '../../channel_detail_page.dart';
import '../../models/channel.dart';


// МОДЕЛИ ДЛЯ ДИЗАЙНА - ВЫНЕСЕНО НА ВЕРХНИЙ УРОВЕНЬ
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

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  final Channel channel;
  final bool isAkorTab;
  final VoidCallback? onShare;
  final VoidCallback? onRepost;
  final String Function(String) getTimeAgo;
  final String? customAvatarUrl;

  const PostItem({
    super.key,
    required this.post,
    required this.channel,
    this.isAkorTab = false,
    this.onShare,
    this.onRepost,
    required this.getTimeAgo,
    this.customAvatarUrl,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> with SingleTickerProviderStateMixin, StateSyncMixin {
  @override
  im.InteractionManager get interactionManager =>
      Provider.of<NewsProvider>(context, listen: false).interactionManager;

  @override
  String get postId => _getStringValue(widget.post['id']);

  @override
  void initState() {
    super.initState(); // StateSyncMixin инициализируется здесь

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    // Инициализация состояния поста через миксин
    _initializePostState();

    print('✅ PostItem initialized with state synchronization');
  }

  final TextEditingController _commentController = TextEditingController();
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

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
      gradient: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      pattern: PatternStyle.minimal,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF43e97b),
    ),
    CardDesign(
      gradient: [const Color(0xFFfa709a), const Color(0xFFfee140)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFFfa709a),
    ),
  ];

  CardDesign get _cardDesign {
    final id = widget.post['id']?.hashCode ?? 0;
    return _cardDesigns[id % _cardDesigns.length];
  }

  ContentType get _contentType {
    final title = _getStringValue(widget.post['title']).toLowerCase();
    final description = _getStringValue(widget.post['description']).toLowerCase();

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
      case ContentType.sports:
        return Color(0xFF2ECC71);
      case ContentType.tech:
        return Color(0xFF9B59B6);
      case ContentType.entertainment:
        return Color(0xFFE67E22);
      case ContentType.education:
        return Color(0xFF1ABC9C);
      default:
        return _cardDesign.accentColor;
    }
  }

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ ОТСТУПОВ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 0;
    if (width > 700) return 0;
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
    if (width > 700) return 0.0;
    return 0.0;
  }

  EdgeInsets _getCardMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return EdgeInsets.only(bottom: 0.0);
    return EdgeInsets.only(bottom: 0.0);
  }

  bool _shouldShowTopLine(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= 700;
  }

  @override
  void _initializePostState() {
    // ✅ Инициализация состояния поста если его нет
    interactionManager.initializePostState(
      postId: postId,
      isLiked: _getBoolValue(widget.post['isLiked']),
      isBookmarked: _getBoolValue(widget.post['isBookmarked']),
      isReposted: _getBoolValue(widget.post['isReposted'] ?? false),
      likesCount: _getIntValue(widget.post['likes']),
      repostsCount: _getIntValue(widget.post['reposts'] ?? 0),
      comments: List<Map<String, dynamic>>.from(widget.post['comments'] ?? []),
    );

    print('✅ PostItem post state initialized: $postId');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('✅ PostItem subscribed to post state changes: $postId');
  }

  @override
  void didUpdateWidget(PostItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем только если изменился ID поста или основные данные
    if (oldWidget.post['id'] != widget.post['id'] ||
        oldWidget.post['isLiked'] != widget.post['isLiked'] ||
        oldWidget.post['likes'] != widget.post['likes'] ||
        oldWidget.post['comments'] != widget.post['comments']) {

      // Переинициализируем через mixin
      _initializePostState();
      print('🔄 PostItem updated with new data');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _expandController.dispose();

    // StateSyncMixin сам удалит слушатели
    print('🔴 PostItem disposed: $postId');

    super.dispose();
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

  // ОБРАБОТЧИКИ ВЗАИМОДЕЙСТВИЙ ЧЕРЕЗ ОБЩИЙ INTERACTION MANAGER
  void _handleLike() {
    final postId = _getStringValue(widget.post['id']);

    // ✅ Используем ОБЩИЙ InteractionManager с принудительной синхронизацией
    interactionManager.toggleLike(postId);

    // ✅ ДОПОЛНИТЕЛЬНО УВЕДОМЛЯЕМ StateSyncProvider
    final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
    stateSync.notifyPostUpdated(postId);

    print('✅ PostItem like handled with FORCE SYNC: $postId');
  }

  void _handleBookmark() {
    final postId = _getStringValue(widget.post['id']);

    interactionManager.toggleBookmark(postId);

    // ✅ ДОПОЛНИТЕЛЬНО УВЕДОМЛЯЕМ StateSyncProvider
    final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
    stateSync.notifyPostUpdated(postId);

    print('✅ PostItem bookmark handled with FORCE SYNC: $postId');
  }

  void _handleRepost() {
    final postId = _getStringValue(widget.post['id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    interactionManager.toggleRepost(
      postId: postId,
      currentUserId: userProvider.userId ?? '',
      currentUserName: userProvider.userName,
    );

    // ✅ ДОПОЛНИТЕЛЬНО УВЕДОМЛЯЕМ StateSyncProvider
    final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
    stateSync.notifyPostUpdated(postId);

    // ПОКАЗЫВАЕМ УВЕДОМЛЕНИЕ О РЕПОСТЕ
    _showRepostSuccessSnackBar();

    // ВЫЗЫВАЕМ КОЛБЭК ЕСЛИ ОН ПРЕДОСТАВЛЕН
    if (widget.onRepost != null) {
      widget.onRepost!();
    }
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
    final postId = _getStringValue(widget.post['id']);

    interactionManager.addComment(
      postId: postId,
      text: text,
      author: author,
      authorAvatar: avatar,
    );

    // ✅ ДОПОЛНИТЕЛЬНО УВЕДОМЛЯЕМ StateSyncProvider
    final stateSync = Provider.of<StateSyncProvider>(context, listen: false);
    stateSync.notifyPostUpdated(postId);

    print('✅ PostItem comment handled with FORCE SYNC: $postId');
  }


  // УЛУЧШЕННАЯ ЗАГРУЗКА ИЗОБРАЖЕНИЙ
  Widget _buildNetworkImage(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    print('🖼️ Loading post image: $imageUrl');

    try {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Network image error: $error');
          return _buildErrorImage(width: width, height: height);
        },
      );
    } catch (e) {
      print('❌ Exception loading image: $e');
      return _buildErrorImage(width: width, height: height);
    }
  }

  Widget _buildAssetImage(String imagePath, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    print('🖼️ Loading asset image: $imagePath');

    try {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Asset image error: $error for path: $imagePath');
          return _buildErrorImage(width: width, height: height);
        },
      );
    } catch (e) {
      print('❌ Exception loading asset image: $e');
      return _buildErrorImage(width: width, height: height);
    }
  }

  Widget _buildErrorImage({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            color: Colors.grey[500],
            size: width != null ? width * 0.3 : 40,
          ),
          SizedBox(height: 8),
          Text(
            'Изображение\nне загружено',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: width != null ? width * 0.05 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final borderRadius = _getCardBorderRadius(context);
    final margin = _getCardMargin(context);
    final showTopLine = _shouldShowTopLine(context);

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
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTopLine)
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
        ),
      ),
    );
  }

  // УЛУЧШЕННАЯ ЗАГРУЗКА АВАТАРКИ КАНАЛА
  Widget _buildChannelHeader() {
    return Consumer<ChannelStateProvider>(
      builder: (context, channelStateProvider, child) {
        final channelName = widget.channel.title;
        final createdAt = _getStringValue(widget.post['created_at']);

        final isRepost = _getBoolValue(widget.post['is_repost']);
        final repostedByName = _getStringValue(widget.post['reposted_by_name']);
        final originalAuthorName = _getStringValue(widget.post['original_author_name']);
        final originalChannelName = _getStringValue(widget.post['original_channel_name']);
        final isOriginalChannelPost = _getBoolValue(widget.post['is_original_channel_post']);

        final repostComment = _getStringValue(widget.post['repost_comment']);
        final hasRepostComment = isRepost && repostComment.isNotEmpty;

        final currentAvatarUrl = channelStateProvider.getAvatarForChannel(widget.channel.id.toString());
        final channelAvatar = widget.customAvatarUrl ?? currentAvatarUrl ?? widget.channel.imageUrl;

        final avatarSize = _getAvatarSize(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRepost && repostedByName.isNotEmpty)
              _buildRepostHeader(repostedByName, createdAt, hasRepostComment ? repostComment : null),

            // ОБНОВЛЕННАЯ ШАПКА КАНАЛА С ПЕРЕХОДОМ
            GestureDetector(
              onTap: _openChannel, // 👈 ДОБАВЬТЕ ЭТОТ ОБРАБОТЧИК
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChannelAvatar(channelAvatar, channelName, avatarSize),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                channelName,
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
                            _buildMenuButton(),
                          ],
                        ),
                        const SizedBox(height: 2),
                        _buildChannelMetaInfo(isRepost, hasRepostComment, createdAt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // МЕТА-ИНФОРМАЦИЯ КАНАЛА С УЧЕТОМ РЕПОСТОВ
  Widget _buildChannelMetaInfo(bool isRepost, bool hasRepostComment, String createdAt) {
    return Container(
      height: 16,
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
              Icon(Icons.group_rounded, size: 12, color: Colors.blue), // Иконка канала
              SizedBox(width: 4),
              Text('Канал', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w700)),
              SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), shape: BoxShape.circle)),
              SizedBox(width: 8),
              Icon(
                  hasRepostComment ? Icons.edit_rounded : Icons.repeat_rounded,
                  size: 12,
                  color: hasRepostComment ? Colors.blue : Colors.green
              ),
              SizedBox(width: 4),
              Text(
                hasRepostComment ? 'Репост с комментарием' : 'Репост',
                style: TextStyle(
                    color: hasRepostComment ? Colors.blue : Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700
                ),
              ),
            ] else ...[
              // СТАТУС КАНАЛА ДЛЯ ОБЫЧНЫХ ПОСТОВ
              SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), shape: BoxShape.circle)),
              SizedBox(width: 8),
              Icon(Icons.verified_rounded, size: 12, color: Colors.blue),
              SizedBox(width: 4),
              Text('Канал', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w700)),
            ],

            // ТИП КОНТЕНТА
            if (_contentType != ContentType.general) ...[
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

  // КНОПКА МЕНЮ ДЛЯ КАНАЛЬНЫХ ПОСТОВ
  Widget _buildMenuButton() {
    return Container(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: Colors.grey[600],
          size: 18,
        ),
        onSelected: _handleMenuSelection,
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_rounded, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                const Text('Поделиться', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 140),
      ),
    );
  }

  void _openChannelProfile() {
    print('Opening channel profile: ${widget.channel.title}');
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'share':
        widget.onShare?.call();
        break;
    }
  }

  // УЛУЧШЕННАЯ ЗАГРУЗКА АВАТАРКИ
  Widget _buildChannelAvatar(String? avatarUrl, String channelName, double size) {
    return GestureDetector(
      onTap: _openChannelProfile,
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
          child: _buildAvatarImage(avatarUrl, channelName, size),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(String? avatarUrl, String name, double size) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return _buildGradientAvatar(name, size);
    }

    if (avatarUrl.startsWith('http')) {
      return _buildNetworkImage(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.startsWith('assets/')) {
      return _buildAssetImage(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.startsWith('/')) {
      // Локальный файл
      return _buildFileImage(avatarUrl, size);
    } else {
      return _buildGradientAvatar(name, size);
    }
  }

  Widget _buildFileImage(String filePath, double size) {
    return Image.file(
      File(filePath),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ File image error: $error for path: $filePath');
        return _buildGradientAvatar('', size);
      },
    );
  }

  Widget _buildGradientAvatar(String name, double size) {
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
          Icons.person_rounded,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildChannelGradientAvatar(String channelName, double size) {
    final gradientColors = _getAvatarGradient(channelName);

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
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.group_rounded,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

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
    final cleanedTags = <String>{};

    for (var tag in hashtags) {
      var cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
      cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
      cleanTag = cleanTag.replaceAll(RegExp(r'[^\wа-яА-ЯёЁ]'), '');

      if (cleanTag.isNotEmpty && cleanTag.length <= 20) {
        cleanedTags.add(cleanTag.toLowerCase());
      }
    }

    return cleanedTags.toList();
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

  // ОБНОВЛЕННЫЙ МЕТОД: Действия поста с использованием ОБЩЕГО Interaction Manager
  // ОБНОВЛЕННЫЙ МЕТОД: Действия поста с ПЕРЕСТАВЛЕННЫМИ кнопками
  Widget _buildPostActions({int commentCount = 0}) {
    if (postState == null) return _buildLoadingActions();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ❤️ ЛАЙКИ
          _buildActionButton(
            icon: postState!.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            count: postState!.likesCount,
            isActive: postState!.isLiked,
            color: Colors.red,
            onPressed: _handleLike,
          ),
          const SizedBox(width: 8),

          // 💬 КОММЕНТАРИИ (ПЕРЕМЕЩЕНЫ ВПЕРЕД)
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: postState!.comments.length,
            isActive: false,
            color: Colors.blue,
            onPressed: () {
              print('💬 Comment button pressed in PostItem');
              print('   Post ID: $postId');
              print('   Current expanded state: $_isExpanded');
              print('   Comments count: ${postState!.comments.length}');
              _toggleExpanded();
            },
          ),
          const SizedBox(width: 8),

          // 🔄 РЕПОСТЫ (ПЕРЕМЕЩЕНЫ НАЗАД)
          _buildActionButton(
            icon: Icons.repeat_rounded,
            count: postState!.repostsCount,
            isActive: false,
            color: Colors.green,
            onPressed: _handleRepost,
          ),
          const SizedBox(width: 8),

          // 🔖 ЗАКЛАДКИ
          _buildActionButton(
            icon: postState!.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            count: 0,
            isActive: postState!.isBookmarked,
            color: Colors.amber,
            onPressed: _handleBookmark,
          ),
          const Spacer(),

          // ✅ АКОР-ТАБ МЕТКА
          if (widget.isAkorTab)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'Опубликовано',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openChannel() {
    final channelId = _getStringValue(widget.post['channel_id']);
    final channelName = _getStringValue(widget.post['channel_name']);

    if (channelId.isEmpty) {
      print('❌ Channel ID is empty in PostItem');
      return;
    }

    print('🎯 PostItem opening channel: $channelName ($channelId)');

    // Создаем канал из данных поста
    final channel = Channel.fromPostData(widget.post);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelDetailPage(channel: channel),
      ),
    );
  }






  Widget _buildLoadingActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }



  Widget _buildLoadingPost() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Загрузочная шапка канала
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 8),
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
          Padding(
            padding: EdgeInsets.only(left: _getAvatarSize(context) + 12),
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
                const SizedBox(height: 16),
                _buildLoadingActions(),
              ],
            ),
          ),
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
    return GestureDetector(
      onTap: () {
        print('🎯 Action button tapped: $icon');
        onPressed();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
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
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Секция комментариев с использованием ОБЩЕГО Interaction Manager
  // ОБНОВЛЕННЫЙ МЕТОД: Секция комментариев с таким же дизайном как в NewsCard
  Widget _buildCommentsSection() {
    return Column(
      children: [
        const SizedBox(height: 24),

        // 📏 РАЗДЕЛИТЕЛЬНАЯ ЛИНИЯ (как в NewsCard)
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

        // 📝 СОДЕРЖИМОЕ СЕКЦИИ КОММЕНТАРИЕВ
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            children: [
              // 💬 СПИСОК КОММЕНТАРИЕВ
              if (postState!.comments.isNotEmpty) ...[
                ...postState!.comments.map((comment) => _buildCommentItem(comment)),
                const SizedBox(height: 20),
              ],

              // ✍️ ПОЛЕ ВВОДА КОММЕНТАРИЯ
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
      padding: const EdgeInsets.only(bottom: 20), // Увеличил отступ
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ АВАТАРКА АВТОРА КОММЕНТАРИЯ (как в NewsCard)
          _buildCommentAvatar(authorAvatar, author),

          const SizedBox(width: 16), // Увеличил отступ

          // 📝 СОДЕРЖИМОЕ КОММЕНТАРИЯ (как в NewsCard)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20), // Увеличил padding
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20), // Увеличил радиус
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [ // Добавил тень как в NewsCard
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
                  // 👤 ИНФОРМАЦИЯ ОБ АВТОРЕ И ВРЕМЕНИ (как в NewsCard)
                  Row(
                    children: [
                      Text(
                        author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15, // Увеличил размер шрифта
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13, // Увеличил размер шрифта
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Увеличил отступ

                  // 📝 ТЕКСТ КОММЕНТАРИЯ (как в NewsCard)
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15, // Увеличил размер шрифта
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
      width: 44, // Увеличил размер
      height: 44, // Увеличил размер
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [ // Добавил тень как в NewsCard
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarImage(avatarUrl, authorName, 44), // Обновил размер
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
        final currentUserAvatar = _getCurrentUserAvatarUrl(newsProvider);

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20), // Увеличил радиус
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [ // Добавил тень как в NewsCard
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🖼️ АВАТАРКА ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ (как в NewsCard)
              Container(
                width: 44, // Увеличил размер
                height: 44, // Увеличил размер
                margin: const EdgeInsets.only(left: 16), // Увеличил отступ
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
                  child: _buildAvatarImage(currentUserAvatar, userProvider.userName, 44),
                ),
              ),
              const SizedBox(width: 16), // Увеличил отступ

              // ✍️ ПОЛЕ ВВОДА ТЕКСТА (как в NewsCard)
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: TextStyle(color: Colors.black87, fontSize: 15), // Увеличил размер шрифта
                  decoration: InputDecoration(
                    hintText: 'Напишите комментарий...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15), // Увеличил размер шрифта
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Увеличил padding
                  ),
                ),
              ),

              // 📤 КНОПКА ОТПРАВКИ (как в NewsCard)
              Container(
                margin: const EdgeInsets.only(right: 16), // Увеличил отступ
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _cardDesign.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16), // Увеличил радиус
                  boxShadow: [
                    BoxShadow(
                      color: _cardDesign.gradient[0].withOpacity(0.3),
                      blurRadius: 8, // Увеличил размытие
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: Colors.white, size: 22), // Увеличил размер иконки
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty) {
                      _handleComment(text, userProvider.userName, currentUserAvatar);
                      _commentController.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Комментарий отправлен'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  padding: const EdgeInsets.all(12), // Увеличил padding
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCurrentUserAvatarUrl(NewsProvider? newsProvider) {
    try {
      if (newsProvider == null) {
        newsProvider = Provider.of<NewsProvider>(context, listen: false);
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentProfileImage = newsProvider.getCurrentProfileImage();

      if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
        return currentProfileImage;
      }

      if (currentProfileImage is File) {
        return currentProfileImage.path;
      }

      return _getFallbackAvatarUrl(userProvider.userName);
    } catch (e) {
      print('❌ Error getting user avatar: $e');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      return _getFallbackAvatarUrl(userProvider.userName);
    }
  }

  String _getFallbackAvatarUrl(String userName) {
    return 'https://ui-avatars.com/api/?name=$userName&background=667eea&color=ffffff&bold=true';
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

    print('🔄 Comments section toggled: $_isExpanded');
  }

  // ✅ Используем комментарии из ОБЩЕГО Interaction Manager
  List<dynamic> get _currentComments {
    return postState?.comments ?? []; // ✅ Используем postState из mixin
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

  @override
  Widget build(BuildContext context) {
    // ✅ Используем StateSyncProvider для принудительной синхронизации
    return Consumer<StateSyncProvider>(
      builder: (context, stateSync, child) {
        // Принудительное обновление при изменении в StateSyncProvider
        final lastUpdate = stateSync.getLastUpdate(postId);

        // ✅ ПРИНУДИТЕЛЬНОЕ ОБНОВЛЕНИЕ ПРИ КАЖДОМ ПОСТРОЕНИИ
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final currentState = interactionManager.getPostState(postId);
            if (currentState != null && postState != currentState) {
              setState(() {
                // postState обновляется через mixin
              });
              print('🔄 PostItem forced state update for: $postId');
            }
          }
        });

        final title = _getStringValue(widget.post['title']);
        final description = _getStringValue(widget.post['description']);
        final hashtags = _parseHashtags(widget.post['hashtags']);

        // ✅ ПРОВЕРКА НАЛИЧИЯ СОСТОЯНИЯ
        if (postState == null) {
          print('⚠️ PostItem: No post state for $postId, initializing...');
          _initializePostState();
          return _buildLoadingPost();
        }

        // ПРОВЕРЯЕМ РЕПОСТ
        final isRepost = _getBoolValue(widget.post['is_repost']);
        final originalAuthorName = _getStringValue(widget.post['original_author_name']);

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildChannelHeader(),
              Padding(
                padding: EdgeInsets.only(left: _getAvatarSize(context) + 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ДЛЯ РЕПОСТОВ ПОКАЗЫВАЕМ ОРИГИНАЛЬНОГО АВТОРА С ВЕРТИКАЛЬНОЙ ЛИНИЕЙ
                    if (isRepost && originalAuthorName.isNotEmpty)
                      _buildRepostedPostSection(originalAuthorName, title, description, hashtags)
                    else
                      _buildRegularPostContent(title, description, hashtags),

                    // ДЕЙСТВИЯ - ✅ Используем postState из mixin
                    _buildPostActions(commentCount: postState!.comments.length),
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
      },
    );
  }


  Widget _buildRegularPostContent(String title, String description, List<String> hashtags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ЗАГОЛОВОК ПОСТА
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

        // ОСНОВНОЙ ТЕКСТ
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

        // ХЕШТЕГИ
        if (hashtags.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildHashtags(hashtags),
          ),
        ],
      ],
    );
  }
  // ... остальные методы (_buildUserAvatar, _buildRepostHeader, _buildChannelAvatarForRepost, etc.)
  // остаются без изменений, так как они не связаны с InteractionManager

  Widget _buildUserAvatar(String avatarUrl, bool isChannelPost, String displayName, double size) {
    return Container(
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
        child: _buildAvatarImage(avatarUrl, displayName, size),
      ),
    );
  }

  Widget _buildRepostHeader(String repostedByName, String createdAt, String? repostComment) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isCurrentUser = repostedByName == userProvider.userName;

    return Column(
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
            padding: const EdgeInsets.only(bottom: 12),
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
    );
  }

  String _getChannelAvatarUrl(String channelId, String channelName) {
    try {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      final currentAvatarUrl = channelStateProvider.getAvatarForChannel(channelId);

      if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
        return currentAvatarUrl;
      }

      // Используем аватар из данных поста если есть
      final postChannelAvatar = _getStringValue(widget.post['original_channel_avatar']);
      if (postChannelAvatar.isNotEmpty) {
        return postChannelAvatar;
      }

      return _getFallbackAvatarUrl(channelName);
    } catch (e) {
      print('❌ Error getting channel avatar: $e');
      return _getFallbackAvatarUrl(channelName);
    }
  }

  String _getUserAvatarUrl(String userName, {bool isCurrentUser = false}) {
    try {
      // Если это текущий пользователь, пытаемся получить его аватар из провайдера
      if (isCurrentUser) {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        final currentProfileImage = newsProvider.getCurrentProfileImage();

        if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
          return currentProfileImage;
        }
        if (currentProfileImage is File) {
          return currentProfileImage.path;
        }
      }

      // Для канальных постов пытаемся получить аватар канала
      final isChannelPost = _getBoolValue(widget.post['is_original_channel_post']);
      if (isChannelPost) {
        final channelAvatar = _getStringValue(widget.post['original_channel_avatar']);
        if (channelAvatar.isNotEmpty) {
          return channelAvatar;
        }
      }

      // Используем fallback аватар
      return _getFallbackAvatarUrl(userName);
    } catch (e) {
      print('❌ Error getting user avatar: $e');
      return _getFallbackAvatarUrl(userName);
    }
  }

  Widget _buildRepostedPostSection(String originalAuthorName, String title, String description, List<String> hashtags) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ПОЛУЧАЕМ ИНФОРМАЦИЮ ОБ ОРИГИНАЛЬНОМ КАНАЛЕ
    final originalChannelName = _getStringValue(widget.post['original_channel_name']);
    final isOriginalChannelPost = _getBoolValue(widget.post['is_original_channel_post']);
    final originalChannelAvatar = _getStringValue(widget.post['original_channel_avatar']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
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
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар и имя оригинального автора/канала
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Аватар оригинального канала или пользователя
                      if (isOriginalChannelPost && originalChannelName.isNotEmpty)
                        _buildChannelAvatarForRepost(originalChannelAvatar, originalChannelName)
                      else
                        _buildUserAvatar(
                          _getUserAvatarUrl(originalAuthorName, isCurrentUser: originalAuthorName == userProvider.userName),
                          false,
                          originalAuthorName,
                          _getAvatarSize(context),
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
                            _buildOriginalPostMetaInfo(isOriginalChannelPost, originalChannelName, originalAuthorName),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ЗАГОЛОВОК ОРИГИНАЛЬНОГО ПОСТА
                if (title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 12),
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

                // ТЕКСТ ОРИГИНАЛЬНОГО ПОСТА
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 12),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: _getDescriptionFontSize(context),
                        color: Colors.black87.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),

                // ХЕШТЕГИ ОРИГИНАЛЬНОГО ПОСТА
                if (hashtags.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                    child: _buildHashtags(hashtags),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }












  Widget _buildChannelAvatarForRepost(String? avatarUrl, String channelName) {
    final size = _getAvatarSize(context);

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
          child: _buildAvatarImage(avatarUrl, channelName, size),
        ),
      ),
    );
  }

  Widget _buildOriginalPostMetaInfo(bool isOriginalChannelPost, String originalChannelName, String originalAuthorName) {
    final originalCreatedAt = _getStringValue(widget.post['original_created_at']);

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

        // ИНФОРМАЦИЯ ОБ АДМИНИСТРАТОРЕ КАНАЛА (если это канальный пост)
        if (isOriginalChannelPost && originalAuthorName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded, size: 12, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                'Администратор: $originalAuthorName',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}