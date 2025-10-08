import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/user_provider.dart';
import '../cards_page/channel_detail_page.dart';
import '../cards_page/models/channel.dart';
import 'theme/news_theme.dart';
import '../../providers/channel_state_provider.dart';

// Импортируем ProfilePage
import 'profile_menu_page.dart';

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final Function(String, String, String) onComment; // ИСПРАВЛЕНО: правильная сигнатура
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final Function(String, String, Color) onTagEdit;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final ScrollController scrollController;
  final VoidCallback onFollow;
  final VoidCallback onLogout;

  const NewsCard({
    super.key,
    required this.news,
    required this.onLike,
    required this.onBookmark,
    required this.onComment,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onTagEdit,
    required this.formatDate,
    required this.getTimeAgo,
    required this.scrollController,
    required this.onFollow,
    required this.onLogout,
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
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _isFollowing = false;
  double _readingProgress = 0.0;
  String _editingTagId = '';

  // УДАЛЕНО: локальное состояние комментариев

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

  @override
  void initState() {
    super.initState();

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

    _isLiked = _getBoolValue(widget.news['isLiked']);
    _isBookmarked = _getBoolValue(widget.news['isBookmarked']);
    _isFollowing = _getBoolValue(widget.news['isFollowing'] ?? false);
    _readingProgress = (widget.news['read_progress'] ?? 0.0).toDouble();
  }

  // ИСПРАВЛЕНИЕ: Убираем слушатель провайдера, т.к. он вызывает лишние перестроения
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // УДАЛЕНО: слушатель channelStateProvider
  }

  // ИСПРАВЛЕНИЕ: Обновляем состояние при изменении props
  @override
  void didUpdateWidget(NewsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем состояние только если данные действительно изменились
    if (oldWidget.news['isLiked'] != widget.news['isLiked']) {
      _isLiked = _getBoolValue(widget.news['isLiked']);
    }
    if (oldWidget.news['isBookmarked'] != widget.news['isBookmarked']) {
      _isBookmarked = _getBoolValue(widget.news['isBookmarked']);
    }
    if (oldWidget.news['isFollowing'] != widget.news['isFollowing']) {
      _isFollowing = _getBoolValue(widget.news['isFollowing'] ?? false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tagEditController.dispose();
    _expandController.dispose();

    // УДАЛЕНО: удаление слушателя channelStateProvider

    super.dispose();
  }

  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    widget.onFollow();
  }

  // ИСПРАВЛЕНИЕ: Правильное получение аватарки для каждого пользователя
  void _openUserProfile() {
    final authorName = _getStringValue(widget.news['author_name']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final channelId = _getStringValue(widget.news['channel_id']);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ЕСЛИ ЭТО КАНАЛЬНЫЙ ПОСТ - ПЕРЕХОДИМ НА СТРАНИЦУ КАНАЛА
    if (isChannelPost && channelId.isNotEmpty && channelName.isNotEmpty) {
      _openChannelPage(channelId, channelName);
      return;
    }

    // Для обычных постов - оставляем старую логику с переходом на профиль
    final targetUserName = authorName;
    final isCurrentUser = authorName == userProvider.userName;

    if (isCurrentUser) {
      _showProfilePage(context);
    } else {
      _showOtherUserProfile(context, targetUserName);
    }
  }

  // НОВЫЙ МЕТОД ДЛЯ ОТКРЫТИЯ СТРАНИЦЫ КАНАЛА
  void _openChannelPage(String channelId, String channelName) {
    if (channelId.isEmpty || channelName.isEmpty) {
      print('❌ Missing channel data: id=$channelId, name=$channelName');
      return;
    }

    try {
      final tempChannel = Channel.simple(
        id: int.tryParse(channelId) ?? 0,
        title: channelName,
        description: 'Официальный канал',
        imageUrl: _getStringValue(widget.news['channel_avatar']),
        cardColor: Colors.blue,
        subscribers: _getIntValue(widget.news['channel_subscribers'] ?? 0),
        videos: _getIntValue(widget.news['channel_videos'] ?? 0),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChannelDetailPage(
            channel: tempChannel,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to channel: $e');
      _showChannelInfoDialog(channelName);
    }
  }

  void _showChannelInfoDialog(String channelName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Канал: $channelName'),
        content: Text('Информация о канале "$channelName"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  // ИСПРАВЛЕНИЕ: Упрощенный метод профиля
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
            widget.onLogout();
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

  // ИСПРАВЛЕНИЕ: Упрощенный метод для профиля другого пользователя
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ИСПРАВЛЕНИЕ: Правильное получение аватарки для каждого пользователя
  String _getUserAvatarUrl(String userName, {bool isCurrentUser = false}) {
    if (isCurrentUser) {
      // Для текущего пользователя используем его аватар
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      final currentProfileImage = newsProvider.getCurrentProfileImage();

      if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
        return currentProfileImage;
      }
    }

    // Для других пользователей используем fallback аватар на основе их имени
    return _getFallbackAvatarUrl(userName);
  }

  // УЛУЧШЕННЫЙ КОМПАКТНЫЙ ДИЗАЙН КАРТОЧЕК
  Widget _buildCard({required Widget child, bool isChannel = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: NewsTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: _cardDesign.gradient[0].withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _cardDesign.gradient[0].withOpacity(0.04),
                      _cardDesign.gradient[0].withOpacity(0.01),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _cardDesign.gradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ИСПРАВЛЕНИЕ: Правильное получение аватарки для каждого типа поста
  Widget _buildPostHeader(bool isAuthor, Map<String, String> userTags, Color tagColor) {
    final authorName = _getStringValue(widget.news['author_name']);
    final createdAt = _getStringValue(widget.news['created_at']);
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final channelId = _getStringValue(widget.news['channel_id']);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ИСПРАВЛЕНИЕ: Правильное определение аватарки
    String authorAvatar;
    String displayName;

    if (isChannelPost && channelId.isNotEmpty) {
      // Для канальных постов используем аватарку канала
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      final currentAvatarUrl = channelStateProvider.getAvatarForChannel(channelId);
      authorAvatar = currentAvatarUrl ?? _getStringValue(widget.news['channel_avatar']) ?? _getFallbackAvatarUrl(channelName);
      displayName = channelName;
    } else {
      // Для обычных постов используем аватарку автора
      final isCurrentUser = authorName == userProvider.userName;
      authorAvatar = _getUserAvatarUrl(authorName, isCurrentUser: isCurrentUser);
      displayName = authorName;
    }

    return Row(
      children: [
        _buildUserAvatar(authorAvatar, isChannelPost, displayName),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openUserProfile,
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: NewsTheme.textColor,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: NewsTheme.secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.getTimeAgo(createdAt),
                    style: TextStyle(
                      color: NewsTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  if (_contentType != ContentType.general) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: NewsTheme.secondaryTextColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _contentIcon,
                      size: 12,
                      color: _contentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getContentTypeText(),
                      style: TextStyle(
                        color: _contentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (userTags.isNotEmpty && userTags.values.first.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildUserTag(userTags.values.first, userTags.keys.first, tagColor),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black.withOpacity(0.06),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: NewsTheme.secondaryTextColor,
              size: 18,
            ),
            onPressed: () => _showAdvancedOptionsMenu(context),
            padding: const EdgeInsets.all(6),
          ),
        ),
      ],
    );
  }

  String _getFallbackAvatarUrl(String userName) {
    return 'https://ui-avatars.com/api/?name=$userName&background=667eea&color=ffffff';
  }

  Widget _buildUserAvatar(String avatarUrl, bool isChannelPost, String displayName) {
    return GestureDetector(
      onTap: _openUserProfile,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
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
          child: avatarUrl.isNotEmpty && avatarUrl.startsWith('http')
              ? Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildGradientAvatar(isChannelPost, displayName);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildGradientAvatar(isChannelPost, displayName);
            },
          )
              : _buildGradientAvatar(isChannelPost, displayName),
        ),
      ),
    );
  }

  Widget _buildGradientAvatar(bool isChannelPost, String displayName) {
    final gradientColors = _getAvatarGradient(displayName);

    return Container(
      width: 44,
      height: 44,
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
          isChannelPost ? Icons.group_rounded : Icons.person_rounded,
          color: Colors.white,
          size: 20,
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

  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }

  Widget _buildUserTag(String tag, String tagId, Color color) {
    return GestureDetector(
      onTap: () => _showTagEditDialog(tag, tagId, color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _contentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: _contentColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ИСПРАВЛЕНИЕ: Используем актуальные комментарии из props
  List<dynamic> get _currentComments {
    return List<dynamic>.from(widget.news['comments'] ?? []);
  }

  Widget _buildPostActions({int commentCount = 0, bool showBookmark = true, bool isAuthor = false}) {
    final likes = _getIntValue(widget.news['likes']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            count: likes,
            isActive: _isLiked,
            color: Colors.red,
            onPressed: () {
              setState(() => _isLiked = !_isLiked);
              widget.onLike();
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: commentCount,
            isActive: _isExpanded,
            color: Colors.blue,
            onPressed: _toggleExpanded,
          ),
          if (showBookmark) const SizedBox(width: 8),
          if (showBookmark)
            _buildActionButton(
              icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              count: 0,
              isActive: _isBookmarked,
              color: Colors.amber,
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
                widget.onBookmark();
              },
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
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color.withOpacity(0.25) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? color : NewsTheme.secondaryTextColor,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyle(
                  color: isActive ? color : NewsTheme.secondaryTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    final isChannelPost = _getBoolValue(widget.news['is_channel_post']);

    return GestureDetector(
      onTap: _toggleFollow,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
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
            color: _isFollowing ? Colors.green : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isFollowing ? Icons.check_rounded : Icons.add_rounded,
              size: 13,
              color: _isFollowing ? Colors.green : Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              _isFollowing ? 'Подписан' : 'Подписаться',
              style: TextStyle(
                color: _isFollowing ? Colors.green : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
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

  int _getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  // УЛУЧШЕННЫЕ ДИАЛОГИ
  void _showAdvancedOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: NewsTheme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NewsTheme.secondaryTextColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuOption(
                  Icons.edit_rounded,
                  'Редактировать',
                  _contentColor,
                  widget.onEdit,
                ),
                _buildMenuOption(
                  Icons.share_rounded,
                  'Поделиться',
                  Colors.blue,
                  widget.onShare,
                ),
                _buildMenuOption(
                  Icons.delete_rounded,
                  'Удалить',
                  Colors.red,
                  widget.onDelete,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NewsTheme.secondaryTextColor,
                    side: BorderSide(color: NewsTheme.secondaryTextColor.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: NewsTheme.textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showTagEditDialog(String tag, String tagId, Color currentColor) {
    _tagEditController.text = tag;
    _editingTagId = tagId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color dialogSelectedColor = currentColor;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: NewsTheme.cardColor,
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
                      Text(
                        'Редактировать тег',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: NewsTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tagEditController,
                        style: TextStyle(color: NewsTheme.textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Название тега',
                          hintStyle: TextStyle(color: NewsTheme.secondaryTextColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: NewsTheme.secondaryTextColor.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _contentColor, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Выберите цвет:',
                        style: TextStyle(
                          color: NewsTheme.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableColors.length,
                          itemBuilder: (context, index) {
                            final color = _availableColors[index];
                            return GestureDetector(
                              onTap: () => setState(() => dialogSelectedColor = color),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: dialogSelectedColor == color ? Colors.white : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
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
                                foregroundColor: NewsTheme.secondaryTextColor,
                                side: BorderSide(color: NewsTheme.secondaryTextColor.withOpacity(0.2)),
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
                                widget.onTagEdit(_editingTagId, text, dialogSelectedColor);
                                Navigator.pop(context);
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _contentColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
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

  // ИСПРАВЛЕНИЕ: Используем актуальные комментарии из props
  Widget _buildCommentsSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _cardDesign.gradient[0].withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              if (_currentComments.isNotEmpty) ...[
                ..._currentComments.map((comment) => _buildCommentItem(comment)),
                const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentAvatar(authorAvatar, author),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withOpacity(0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        author,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: NewsTheme.textColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: NewsTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: NewsTheme.textColor.withOpacity(0.8),
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
    if (avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildCommentGradientAvatar(authorName);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildCommentGradientAvatar(authorName);
            },
          ),
        ),
      );
    }

    return _buildCommentGradientAvatar(authorName);
  }

  Widget _buildCommentGradientAvatar(String authorName) {
    final gradientColors = _getAvatarGradient(authorName);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _convertToMap(dynamic item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return item.cast<String, dynamic>();
    return {};
  }

  // ИСПРАВЛЕНИЕ: Правильная обработка комментариев
  Widget _buildCommentInput() {
    return Consumer2<NewsProvider, UserProvider>(
      builder: (context, newsProvider, userProvider, child) {
        // ИСПРАВЛЕНИЕ: Для комментариев всегда используем аватарку текущего пользователя
        final currentUserAvatar = _getUserAvatarUrl(userProvider.userName, isCurrentUser: true);

        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withOpacity(0.04),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: currentUserAvatar.isNotEmpty && currentUserAvatar.startsWith('http')
                      ? Image.network(
                    currentUserAvatar,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildCommentGradientAvatar(userProvider.userName);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildCommentGradientAvatar(userProvider.userName);
                    },
                  )
                      : _buildCommentGradientAvatar(userProvider.userName),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: TextStyle(color: NewsTheme.textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Напишите комментарий...',
                    hintStyle: TextStyle(color: NewsTheme.secondaryTextColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _cardDesign.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty) {
                      // ИСПРАВЛЕНИЕ: Передаем все три параметра в onComment
                      widget.onComment(
                        text,
                        userProvider.userName, // имя пользователя
                        currentUserAvatar, // аватар пользователя
                      );
                      _commentController.clear();

                      // Показываем уведомление
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Комментарий отправлен'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
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
    if (userTags is Map) {
      return userTags.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {'tag1': 'Фанат Манчестера'};
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  // ПОСТРОЕНИЕ КАРТОЧЕК
  Widget _buildRegularPost() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final hashtags = _parseHashtags(widget.news['hashtags']);
    final userTags = _parseUserTags(widget.news['user_tags']);
    final tagColor = _selectedTagColor;

    final authorName = _getStringValue(widget.news['author_name']);
    final isAuthor = authorName == userProvider.userName;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(isAuthor, userTags, tagColor),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_getStringValue(widget.news['title']).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _getStringValue(widget.news['title']),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: NewsTheme.textColor,
                      height: 1.3,
                    ),
                  ),
                ),
              Text(
                _getStringValue(widget.news['description']),
                style: TextStyle(
                  fontSize: 14,
                  color: NewsTheme.textColor.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildHashtags(hashtags),
          ],
          const SizedBox(height: 16),
          // ИСПРАВЛЕНИЕ: Используем актуальное количество комментариев
          _buildPostActions(commentCount: _currentComments.length, isAuthor: isAuthor),
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

  // ОБНОВЛЕННЫЙ МЕТОД ДЛЯ КАНАЛЬНЫХ ПОСТОВ С ИСПОЛЬЗОВАНИЕМ ПРОВАЙДЕРА
  Widget _buildChannelPost() {
    final title = _getStringValue(widget.news['title']);
    final description = _getStringValue(widget.news['description']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final createdAt = _getStringValue(widget.news['created_at']);
    final hashtags = _parseHashtags(widget.news['hashtags']);
    final channelId = _getStringValue(widget.news['channel_id']);

    // ПОЛУЧАЕМ АКТУАЛЬНУЮ АВАТАРКУ ИЗ ПРОВАЙДЕРА
    final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
    final currentAvatarUrl = channelStateProvider.getAvatarForChannel(channelId);
    final channelAvatar = currentAvatarUrl ?? _getStringValue(widget.news['channel_avatar']);

    return _buildCard(
      isChannel: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _openUserProfile,
            child: Row(
              children: [
                _buildChannelAvatar(channelAvatar, channelName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channelName,
                        style: TextStyle(
                          color: NewsTheme.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'Официальный канал',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: NewsTheme.secondaryTextColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.getTimeAgo(createdAt),
                            style: TextStyle(
                              color: NewsTheme.secondaryTextColor,
                              fontSize: 11,
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
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: NewsTheme.textColor,
                      height: 1.3,
                    ),
                  ),
                ),
              if (description.isNotEmpty)
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: NewsTheme.textColor.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
            ],
          ),
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildHashtags(hashtags),
          ],
          const SizedBox(height: 16),
          // ИСПРАВЛЕНИЕ: Используем актуальное количество комментариев
          _buildPostActions(
              commentCount: _currentComments.length,
              showBookmark: true,
              isAuthor: false
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

  Widget _buildChannelAvatar(String? avatarUrl, String channelName) {
    return GestureDetector(
      onTap: _openUserProfile,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
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
          child: avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl.startsWith('http')
              ? Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildChannelGradientAvatar(channelName);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildChannelGradientAvatar(channelName);
            },
          )
              : _buildChannelGradientAvatar(channelName),
        ),
      ),
    );
  }

  Widget _buildChannelGradientAvatar(String channelName) {
    final gradientColors = _getAvatarGradient(channelName);

    return Container(
      width: 44,
      height: 44,
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
          size: 20,
        ),
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