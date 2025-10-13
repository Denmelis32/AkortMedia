import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/news_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../news_page/theme/news_theme.dart';
import '../../models/channel.dart';
import '../../../../providers/channel_state_provider.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  final Channel channel;
  final bool isAkorTab;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final Function(String, String, String)? onComment;
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
    if (width > 1000) return 0; // УБИРАЕМ ОТСТУПЫ НА КОМПЬЮТЕРЕ
    if (width > 700) return 0;  // УБИРАЕМ ОТСТУПЫ НА ПЛАНШЕТАХ
    return 0;                    // НЕТ ОТСТУПОВ НА МОБИЛЬНЫХ
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  // Twitter-like размеры элементов
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

  // АДАПТИВНЫЕ СТИЛИ ДЛЯ КАРТОЧЕК - УБИРАЕМ СКОЛЛ И ДЕЛАЕМ КАК В ОРИГИНАЛЕ
  double _getCardBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 0.0; // НЕТ ЗАКРУГЛЕНИЙ НА КОМПЬЮТЕРЕ
    return 0.0;                   // НЕТ ЗАКРУГЛЕНИЙ НА МОБИЛЬНЫХ
  }

  EdgeInsets _getCardMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return EdgeInsets.only(bottom: 0.0); // НЕТ ОТСТУПОВ МЕЖДУ ПОСТАМИ
    return EdgeInsets.only(bottom: 0.0);                   // НЕТ ОТСТУПОВ МЕЖДУ ПОСТАМИ
  }

  bool _shouldShowTopLine(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= 700;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
    channelStateProvider.addListener(_onChannelStateChanged);
  }

  void _onChannelStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(PostItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post['isLiked'] != widget.post['isLiked']) {
      _isLiked = _getBoolValue(widget.post['isLiked']);
    }
    if (oldWidget.post['isBookmarked'] != widget.post['isBookmarked']) {
      _isBookmarked = _getBoolValue(widget.post['isBookmarked']);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _expandController.dispose();

    try {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      channelStateProvider.removeListener(_onChannelStateChanged);
    } catch (e) {
      print('⚠️ ChannelStateProvider already disposed: $e');
    }

    super.dispose();
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

  List<dynamic> get _currentComments {
    return List<dynamic>.from(widget.post['comments'] ?? []);
  }

  // УПРОЩЕННАЯ КАРТОЧКА БЕЗ ОТСТУПОВ И ТЕНИ - КАК В ОРИГИНАЛЕ
  // УПРОЩЕННАЯ КАРТОЧКА БЕЗ ОТСТУПОВ И ТЕНИ - КАК В ОРИГИНАЛЕ
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
              // ТОНКАЯ ТЕМНО-СЕРАЯ ЛИНИЯ ТОЛЬКО НА ТЕЛЕФОНЕ
              if (showTopLine)
                Container(
                  height: 1, // Тонкая линия
                  margin: const EdgeInsets.symmetric(horizontal: 16), // Отступы от краев
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Темно-серый цвет
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

  // ЗАГОЛОВОК КАНАЛА
  Widget _buildChannelHeader() {
    return Consumer<ChannelStateProvider>(
      builder: (context, channelStateProvider, child) {
        final channelName = widget.channel.title;
        final createdAt = _getStringValue(widget.post['created_at']);

        // Получаем актуальную аватарку из провайдера
        final currentAvatarUrl = channelStateProvider.getAvatarForChannel(widget.channel.id.toString());
        final channelAvatar = widget.customAvatarUrl ?? currentAvatarUrl ?? widget.channel.imageUrl;

        final avatarSize = _getAvatarSize(context);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChannelAvatar(channelAvatar, channelName, avatarSize),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Первая строка: название канала и кнопка меню
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _openChannelProfile,
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
                      ),
                      // Кнопка трех точек
                      Container(
                        width: 28,
                        height: 28,
                        child: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          onSelected: (value) {
                            _handleMenuSelection(value);
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share_rounded, color: Colors.blue, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Поделиться', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 140),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Вторая строка: мета-информация
                  Container(
                    height: 16,
                    child: Row(
                      children: [
                        // Время
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.getTimeAgo(createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        // Канал
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Канал',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                        // Тип контента
                        if (_contentType != ContentType.general) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ],
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

  void _openChannelProfile() {
    // Навигация к странице канала
    print('Opening channel profile: ${widget.channel.title}');
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'share':
        widget.onShare?.call();
        break;
    }
  }

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
          child: avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl.startsWith('http')
              ? Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildChannelGradientAvatar(channelName, size);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildChannelGradientAvatar(channelName, size);
            },
          )
              : _buildChannelGradientAvatar(channelName, size),
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

  // ДЕЙСТВИЯ
  Widget _buildPostActions({int commentCount = 0}) {
    final likes = _getIntValue(widget.post['likes']);
    final reposts = _getIntValue(widget.post['reposts'] ?? 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            icon: Icons.repeat_rounded,
            count: reposts,
            isActive: false,
            color: Colors.green,
            onPressed: () {
              // Функционал репоста
            },
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

  // СЕКЦИЯ КОММЕНТАРИЕВ
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
                        style: TextStyle(
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
    if (avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
    return Consumer2<NewsProvider, UserProvider>(
      builder: (context, newsProvider, userProvider, child) {
        final currentUserAvatar = _getCurrentUserAvatarUrl(newsProvider);

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
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: TextStyle(color: Colors.black87, fontSize: 14),
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
                  icon: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty) {
                      widget.onComment?.call(
                        text,
                        userProvider.userName,
                        currentUserAvatar,
                      );
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
                  padding: const EdgeInsets.all(10),
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
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChannelHeader(),
          // ФИКСИРОВАННЫЙ ОТСТУП ПОД АВАТАРОМ
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
                _buildPostActions(commentCount: _currentComments.length),
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