import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/news_theme.dart'; // Добавляем импорт темы

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final String userName;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final Function(String) onComment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final Function(String, String, Color) onTagEdit;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final ScrollController scrollController;

  const NewsCard({
    super.key,
    required this.news,
    required this.userName,
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
  String _editingTagId = '';

  final List<Color> _availableColors = NewsTheme.tagColors;

  Color get _selectedTagColor {
    if (widget.news['tag_color'] != null) {
      return Color(widget.news['tag_color']);
    }
    return NewsTheme.primaryColor;
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

    // Безопасное получение значений
    _isLiked = _getBoolValue(widget.news['isLiked']);
    _isBookmarked = _getBoolValue(widget.news['isBookmarked']);
  }

  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tagEditController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is String) {
      return hashtags
          .replaceAll('#', '')
          .split(RegExp(r'[,\s]+'))
          .where((tag) => tag.trim().isNotEmpty)
          .toList();
    } else if (hashtags is List) {
      return hashtags
          .map((tag) => tag.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, String> _parseUserTags(dynamic userTags) {
    if (userTags is Map) {
      return userTags.map((key, value) =>
          MapEntry(key.toString(), value.toString()));
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
              backgroundColor: NewsTheme.cardColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎨 Редактировать тег',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: NewsTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Поле ввода названия тега
                    TextField(
                      controller: _tagEditController,
                      style: TextStyle(color: NewsTheme.textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Введите название тега',
                        hintStyle: TextStyle(color: NewsTheme.secondaryTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: NewsTheme.primaryColor.withOpacity(0.3)),
                        ),
                        filled: true,
                        fillColor: NewsTheme.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      maxLength: 20,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      onChanged: (value) {
                        setState(() {}); // Обновляем состояние для кнопки сохранения
                      },
                    ),
                    const SizedBox(height: 20),

                    // Заголовок выбора цвета
                    Text(
                      'Выберите цвет:',
                      style: TextStyle(
                        color: NewsTheme.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Палитра цветов
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableColors.length,
                        itemBuilder: (context, index) {
                          final color = _availableColors[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                dialogSelectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: dialogSelectedColor == color ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: dialogSelectedColor == color
                                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Предпросмотр тега
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: dialogSelectedColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: dialogSelectedColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        _tagEditController.text.isNotEmpty ? _tagEditController.text : 'Пример тега',
                        style: TextStyle(
                          color: _getTagTextColor(dialogSelectedColor),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Кнопки действий
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: NewsTheme.primaryColor),
                            ),
                            child: Text(
                              'Отмена',
                              style: TextStyle(color: NewsTheme.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _tagEditController.text.trim().isNotEmpty
                                ? () {
                              final text = _tagEditController.text.trim();
                              widget.onTagEdit(_editingTagId, text, dialogSelectedColor);
                              Navigator.pop(context);

                              // Показываем уведомление об успехе
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Тег "$text" сохранен!'),
                                  backgroundColor: NewsTheme.successColor,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                                : null, // Кнопка неактивна если текст пустой
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NewsTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NewsTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuOption(Icons.edit, 'Редактировать', NewsTheme.primaryColor, widget.onEdit),
              _buildMenuOption(Icons.delete, 'Удалить', NewsTheme.errorColor, widget.onDelete),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NewsTheme.secondaryTextColor,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String text, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(text, style: TextStyle(color: NewsTheme.textColor, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: NewsTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget _buildPostHeader(bool isAuthor, Map<String, String> userTags, Color tagColor) {
    final authorName = _getStringValue(widget.news['author_name']);
    final createdAt = _getStringValue(widget.news['created_at']);

    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [NewsTheme.primaryColor.withOpacity(0.8), NewsTheme.primaryColor.withOpacity(0.4)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Center(
            child: Text(
              authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(authorName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: NewsTheme.textColor)),
              const SizedBox(height: 2),
              Text(widget.getTimeAgo(createdAt), style: TextStyle(color: NewsTheme.secondaryTextColor, fontSize: 13)),
            ],
          ),
        ),
        if (userTags.isNotEmpty && userTags.values.first.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildUserTag(userTags.values.first, userTags.keys.first, tagColor),
          ),
        if (isAuthor)
          IconButton(
            icon: Icon(Icons.more_vert, color: NewsTheme.secondaryTextColor, size: 22),
            onPressed: () => _showOptionsMenu(context),
          ),
      ],
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_getTagIcon(tag, color) != null) ...[
              _getTagIcon(tag, color)!,
              const SizedBox(width: 6),
            ],
            Text(
              tag,
              style: TextStyle(
                color: _getTagTextColor(color),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: _getTagTextColor(color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtags(List<String> hashtags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hashtags.map((tag) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NewsTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: NewsTheme.primaryColor.withOpacity(0.2), width: 1),
            ),
            child: Text('#${tag.trim()}', style: TextStyle(color: NewsTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPostActions({int commentCount = 0, bool showBookmark = true}) {
    final likes = _getIntValue(widget.news['likes']);

    return Row(
      children: [
        _buildActionButton(
          icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          count: likes,
          isActive: _isLiked,
          onPressed: () {
            setState(() => _isLiked = !_isLiked);
            widget.onLike();
          },
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: _isExpanded ? Icons.chat_rounded : Icons.chat_bubble_outline_rounded,
          count: commentCount,
          isActive: _isExpanded,
          onPressed: _toggleExpanded,
        ),
        if (showBookmark) const SizedBox(width: 16),
        if (showBookmark)
          _buildActionButton(
            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            count: 0,
            isActive: _isBookmarked,
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              widget.onBookmark();
            },
          ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.share_rounded, size: 22, color: NewsTheme.secondaryTextColor),
          onPressed: widget.onShare,
          splashRadius: 20,
        ),
      ],
    );
  }

  int _getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Widget _buildActionButton({required IconData icon, required int count, required bool isActive, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? NewsTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isActive ? NewsTheme.primaryColor : NewsTheme.secondaryTextColor),
            if (count > 0) const SizedBox(width: 6),
            if (count > 0)
              Text(_formatCount(count), style: TextStyle(color: isActive ? NewsTheme.primaryColor : NewsTheme.secondaryTextColor, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  Widget _buildCommentsSection(List<dynamic> comments) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              if (comments.isNotEmpty) ...[
                ...comments.map((comment) => _buildCommentItem(comment)),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [NewsTheme.primaryColor.withOpacity(0.8), NewsTheme.secondaryColor.withOpacity(0.6)]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(author.isNotEmpty ? author[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NewsTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(author, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: NewsTheme.textColor)),
                      const Spacer(),
                      Text(time, style: TextStyle(fontSize: 11, color: NewsTheme.secondaryTextColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(text, style: TextStyle(fontSize: 14, color: NewsTheme.textColor.withOpacity(0.9), height: 1.4)),
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: NewsTheme.backgroundColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(color: NewsTheme.textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Написать комментарий...',
                hintStyle: TextStyle(color: NewsTheme.secondaryTextColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              ),
              maxLines: 1,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onComment(value);
                  _commentController.clear();
                }
              },
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [NewsTheme.primaryColor, NewsTheme.primaryColor.withOpacity(0.8)]),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
              onPressed: () {
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  widget.onComment(text);
                  _commentController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTagTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Widget? _getTagIcon(String tag, Color color) {
    final lowerTag = tag.toLowerCase();
    final textColor = _getTagTextColor(color);

    if (lowerTag.contains('манчестер')) return Icon(Icons.sports_soccer_rounded, size: 16, color: textColor);
    if (lowerTag.contains('фанат')) return Icon(Icons.people_alt_rounded, size: 16, color: textColor);
    if (lowerTag.contains('премиум') || lowerTag.contains('золот')) return Icon(Icons.star_rounded, size: 16, color: textColor);
    if (lowerTag.contains('спорт')) return Icon(Icons.fitness_center_rounded, size: 16, color: textColor);
    return null;
  }

  Widget _buildChannelPost() {
    final title = _getStringValue(widget.news['title']);
    final description = _getStringValue(widget.news['description']);
    final channelName = _getStringValue(widget.news['channel_name']);
    final createdAt = _getStringValue(widget.news['created_at']);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NewsTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.group, color: NewsTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Канальный пост', style: TextStyle(color: NewsTheme.textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(channelName, style: TextStyle(color: NewsTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(widget.getTimeAgo(createdAt), style: TextStyle(color: NewsTheme.secondaryTextColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: NewsTheme.textColor, height: 1.4)),
            ),
          if (description.isNotEmpty)
            Text(description, style: TextStyle(fontSize: 15, color: NewsTheme.textColor.withOpacity(0.9), height: 1.5)),
          const SizedBox(height: 16),
          _buildPostActions(showBookmark: false),
        ],
      ),
    );
  }

  Widget _buildRegularPost() {
    final comments = widget.news['comments'] ?? [];
    final hashtags = _parseHashtags(widget.news['hashtags']);
    final userTags = _parseUserTags(widget.news['user_tags']);
    final tagColor = _selectedTagColor;
    final isAuthor = _getStringValue(widget.news['author_name']) == widget.userName;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(isAuthor, userTags, tagColor),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_getStringValue(widget.news['title']).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _getStringValue(widget.news['title']),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3, color: NewsTheme.textColor),
                    ),
                  ),
                Text(
                  _getStringValue(widget.news['description']),
                  style: TextStyle(fontSize: 16, height: 1.6, color: NewsTheme.textColor.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (hashtags.isNotEmpty) _buildHashtags(hashtags),
          const SizedBox(height: 20),
          _buildPostActions(commentCount: comments.length),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCommentsSection(comments),
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