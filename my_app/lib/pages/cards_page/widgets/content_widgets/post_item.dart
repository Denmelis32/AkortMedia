import 'package:flutter/material.dart';
import '../../../news_page/theme/news_theme.dart';
import '../../models/channel.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  final Channel channel;
  final bool isAkorTab;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final Function(String)? onComment;
  final VoidCallback? onShare;
  final String Function(String) getTimeAgo;
  final String? customAvatarUrl;

  const PostItem({
    super.key,
    required this.post,
    required this.channel,
    this.isAkorTab = false,
    this.onLike,
    this.onBookmark,
    this.onComment,
    this.onShare,
    required this.getTimeAgo,
    this.customAvatarUrl,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;
  bool _isLiked = false;
  bool _isBookmarked = false;
  List<dynamic> _localComments = [];

  // СОХРАНЯЕМ АВАТАРКУ В СОСТОЯНИИ
  String? _currentAvatarUrl;

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

    _isLiked = _getBoolValue(widget.post['isLiked']);
    _isBookmarked = _getBoolValue(widget.post['isBookmarked']);
    _localComments = List<dynamic>.from(widget.post['comments'] ?? []);

    // ИНИЦИАЛИЗИРУЕМ АВАТАРКУ ПРИ СОЗДАНИИ
    _currentAvatarUrl = widget.customAvatarUrl ?? widget.channel.imageUrl;
  }

  // ОБНОВЛЯЕМ ПРИ ИЗМЕНЕНИИ PROPS - ТЕПЕРЬ СОХРАНЯЕМ СОСТОЯНИЕ
  @override
  void didUpdateWidget(PostItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Если изменилась кастомная аватарка, обновляем состояние
    if (oldWidget.customAvatarUrl != widget.customAvatarUrl) {
      setState(() {
        _currentAvatarUrl = widget.customAvatarUrl ?? widget.channel.imageUrl;
      });
    }
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

  int _getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  Widget _buildCard({required Widget child}) {
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

  Widget _buildChannelHeader() {
    final channelName = widget.channel.title;
    final createdAt = _getStringValue(widget.post['created_at']);

    // ИСПОЛЬЗУЕМ СОХРАНЕННУЮ АВАТАРКУ
    final channelAvatar = _currentAvatarUrl;

    return Row(
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
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 12,
                    color: Colors.blue,
                  ),
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
            onPressed: _showOptionsMenu,
            padding: const EdgeInsets.all(6),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelAvatar(String? avatarUrl, String channelName) {
    return Container(
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
      children: cleanedHashtags.map((tag) => Container(
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
      )).toList(),
    );
  }

  Widget _buildPostActions({int commentCount = 0}) {
    final likes = _getIntValue(widget.post['likes']);

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
              widget.onLike?.call();
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
          const SizedBox(width: 8),
          _buildActionButton(
            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            count: 0,
            isActive: _isBookmarked,
            color: Colors.amber,
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              widget.onBookmark?.call();
            },
          ),
          const Spacer(),
          if (widget.isAkorTab)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 13, color: Colors.green),
                  const SizedBox(width: 5),
                  Text(
                    'Опубликовано на Стене',
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

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

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
              if (_localComments.isNotEmpty) ...[
                ..._localComments.map((comment) => _buildCommentItem(comment)),
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

  Widget _buildCommentInput() {
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
                  final newComment = {
                    'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
                    'author': 'Текущий пользователь',
                    'text': text,
                    'time': 'Только что',
                    'author_avatar': '',
                  };

                  setState(() {
                    _localComments.insert(0, newComment);
                  });

                  widget.onComment?.call(text);
                  _commentController.clear();
                }
              },
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
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

  void _showOptionsMenu() {
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
                  Icons.share_rounded,
                  'Поделиться',
                  Colors.blue,
                      () {
                    Navigator.pop(context);
                    widget.onShare?.call();
                  },
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
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
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

  @override
  Widget build(BuildContext context) {
    final title = _getStringValue(widget.post['title']);
    final description = _getStringValue(widget.post['description']);
    final hashtags = _parseHashtags(widget.post['hashtags']);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChannelHeader(),
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
                      fontSize: 18,
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
          _buildPostActions(commentCount: _localComments.length),
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