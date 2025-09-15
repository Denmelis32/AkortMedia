import 'package:flutter/material.dart';

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final String userName;
  final VoidCallback onLike;
  final Function(String) onComment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String, String, Color) onTagEdit;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const NewsCard({
    super.key,
    required this.news,
    required this.userName,
    required this.onLike,
    required this.onComment,
    required this.onEdit,
    required this.onDelete,
    required this.onTagEdit,
    required this.formatDate,
    required this.getTimeAgo,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _tagEditController = TextEditingController();
  bool _isExpanded = false;
  bool _isLiked = false;
  bool _isBookmarked = false;
  String _editingTagId = '';
  Color _selectedTagColor = const Color(0xFF2196F3);

  List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is String) {
      // Убираем лишние пробелы и разделяем по запятым или пробелам
      return hashtags
          .replaceAll('#', '') // Убираем символы # если они есть
          .split(RegExp(r'[,\s]+'))
          .where((tag) => tag.trim().isNotEmpty)
          .toList();
    } else if (hashtags is List) {
      return hashtags
          .map((tag) => tag.toString())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return [];
  }

  void _showTagEditDialog(String tag, String tagId, Color currentColor) {
    _tagEditController.text = tag;
    _editingTagId = tagId;
    _selectedTagColor = currentColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: widget.cardColor,
              title: Text(
                'Редактировать тег',
                style: TextStyle(color: widget.textColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _tagEditController,
                    style: TextStyle(color: widget.textColor),
                    decoration: InputDecoration(
                      hintText: 'Введите название тега',
                      hintStyle: TextStyle(color: widget.secondaryTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Выберите цвет тега:',
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildColorOption(
                        const Color(0xFFDA291C),
                        'Красный',
                        setState,
                      ),
                      _buildColorOption(
                        const Color(0xFF6C1D45),
                        'Фиолетовый',
                        setState,
                      ),
                      _buildColorOption(
                        const Color(0xFFFFD700),
                        'Золотой',
                        setState,
                      ),
                      _buildColorOption(
                        widget.primaryColor,
                        'Основной',
                        setState,
                      ),
                      _buildColorOption(Colors.green, 'Зеленый', setState),
                      _buildColorOption(Colors.blue, 'Синий', setState),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Отмена',
                    style: TextStyle(color: widget.secondaryTextColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_tagEditController.text.trim().isNotEmpty) {
                      widget.onTagEdit(
                        _editingTagId,
                        _tagEditController.text.trim(),
                        _selectedTagColor,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                  ),
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.topRight(Offset.zero),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, color: widget.primaryColor),
              const SizedBox(width: 8),
              Text('Редактировать', style: TextStyle(color: widget.textColor)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text('Удалить', style: TextStyle(color: widget.textColor)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        widget.onEdit();
      } else if (value == 'delete') {
        widget.onDelete();
      }
    });
  }

  Widget _buildColorOption(Color color, String label, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTagColor = color;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedTagColor == color
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _getTextColorForBackground(color),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    // Проверка на канальный пост
    if (widget.news['is_channel_post'] == true) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.group, color: widget.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Пост из канала',
                      style: TextStyle(
                        color: widget.secondaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.news['channel_name'] ?? 'Неизвестный канал',
                        style: TextStyle(
                          color: widget.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: widget.secondaryTextColor,
                      ),
                      onPressed: () {
                        // Дополнительные действия для канального поста
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.news['title'] != null &&
                    widget.news['title'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      widget.news['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                      ),
                    ),
                  ),
                if (widget.news['description'] != null)
                  Text(
                    widget.news['description'],
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.textColor.withOpacity(0.9),
                    ),
                  ),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildActionButton(
                      icon: _isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      count: widget.news['likes'] ?? 0,
                      isActive: _isLiked,
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                        widget.onLike();
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.share_rounded,
                      count: 0,
                      isActive: false,
                      onPressed: () {},
                    ),
                    const Spacer(),
                    Text(
                      widget.getTimeAgo(widget.news['created_at']),
                      style: TextStyle(
                        color: widget.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Оригинальная реализация для обычных постов
    final comments = widget.news['comments'] ?? [];
    final hashtags = _parseHashtags(widget.news['hashtags']);
    final userTags = widget.news['user_tags'] is Map
        ? (widget.news['user_tags'] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : {'tag1': 'Фанат Манчестера'};

    final tagColor = widget.news['tag_color'] != null
        ? Color(widget.news['tag_color'])
        : _getTagColor(userTags.values.first);

    final isAuthor = widget.news['author_name'] == widget.userName;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.primaryColor.withOpacity(0.8),
                                widget.primaryColor.withOpacity(0.4),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.news['author_name']?[0]?.toUpperCase() ??
                                  '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.news['author_name'] ?? 'Неизвестно',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: widget.textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.getTimeAgo(widget.news['created_at']),
                                style: TextStyle(
                                  color: widget.secondaryTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // User Tags - ПРАВЕЕ (компактное расположение)
                        if (userTags.isNotEmpty &&
                            userTags.values.first.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            // Компактный отступ
                            child: GestureDetector(
                              onTap: () => _showTagEditDialog(
                                userTags.values.first,
                                userTags.keys.first,
                                tagColor,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: tagColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: tagColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_getTagIcon(
                                          userTags.values.first,
                                          tagColor,
                                        ) !=
                                        null) ...[
                                      _getTagIcon(
                                        userTags.values.first,
                                        tagColor,
                                      )!,
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      userTags.values.first,
                                      style: TextStyle(
                                        color: _getTagTextColor(tagColor),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // More options button - ТРИ ТОЧКИ
                        if (isAuthor)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.more_horiz,
                                size: 20,
                                color: widget.secondaryTextColor,
                              ),
                              onPressed: () {
                                _showOptionsMenu(context);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        if (widget.news['title'] != null &&
                            widget.news['title'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              widget.news['title'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                color: widget.textColor,
                              ),
                            ),
                          ),

                        // Description
                        Text(
                          widget.news['description'],
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: widget.textColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Hashtags
                  if (hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: hashtags.map((tag) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: widget.primaryColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#${tag.trim()}',
                                style: TextStyle(
                                  color: widget.primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Stats and actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Like button
                        _buildActionButton(
                          icon: _isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          count: widget.news['likes'] ?? 0,
                          isActive: _isLiked,
                          onPressed: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                            widget.onLike();
                          },
                        ),

                        const SizedBox(width: 16),

                        // Comment button
                        _buildActionButton(
                          icon: _isExpanded
                              ? Icons.chat_rounded
                              : Icons.chat_bubble_outline_rounded,
                          count: comments.length,
                          isActive: _isExpanded,
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),

                        const SizedBox(width: 16),

                        // Bookmark button
                        _buildActionButton(
                          icon: _isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          count: 0,
                          isActive: _isBookmarked,
                          onPressed: () {
                            setState(() {
                              _isBookmarked = !_isBookmarked;
                            });
                          },
                        ),

                        const Spacer(),

                        // Share button
                        IconButton(
                          icon: Icon(
                            Icons.share_rounded,
                            size: 22,
                            color: widget.secondaryTextColor,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Comments section
                  if (_isExpanded) ...[
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (comments.isNotEmpty)
                            Column(
                              children: [
                                ...comments.map(
                                  (comment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Comment avatar
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blue.withOpacity(0.8),
                                                Colors.blue.withOpacity(0.4),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              comment['author']?[0]
                                                      ?.toUpperCase() ??
                                                  '?',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: widget.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment['author'] ??
                                                      'Неизвестно',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: widget.textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  comment['text'],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    height: 1.4,
                                                    color: widget.textColor
                                                        .withOpacity(0.9),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  comment['time'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: widget
                                                        .secondaryTextColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Add comment input
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: widget.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Написать комментарий...',
                                      hintStyle: TextStyle(
                                        color: widget.secondaryTextColor,
                                        fontSize: 15,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: widget.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.send_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (_commentController.text
                                          .trim()
                                          .isNotEmpty) {
                                        widget.onComment(
                                          _commentController.text,
                                        );
                                        _commentController.clear();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    if (tag.toLowerCase().contains('манчестер')) {
      return const Color(0xFFDA291C);
    } else if (tag.toLowerCase().contains('фанат')) {
      return const Color(0xFF6C1D45);
    } else if (tag.toLowerCase().contains('премиум')) {
      return const Color(0xFFFFD700);
    } else {
      return widget.primaryColor;
    }
  }

  Color _getTagTextColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  Widget? _getTagIcon(String tag, Color color) {
    final textColor = _getTagTextColor(color);
    if (tag.toLowerCase().contains('манчестер')) {
      return Icon(Icons.sports_soccer, size: 14, color: textColor);
    } else if (tag.toLowerCase().contains('фанат')) {
      return Icon(Icons.people, size: 14, color: textColor);
    } else if (tag.toLowerCase().contains('премиум')) {
      return Icon(Icons.star, size: 14, color: textColor);
    }
    return null;
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? widget.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? widget.primaryColor : widget.secondaryTextColor,
            ),
            if (count > 0) const SizedBox(width: 6),
            if (count > 0)
              Text(
                count.toString(),
                style: TextStyle(
                  color: isActive
                      ? widget.primaryColor
                      : widget.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tagEditController.dispose();
    super.dispose();
  }
}
