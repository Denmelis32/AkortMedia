import 'package:flutter/material.dart';

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final String userName;
  final VoidCallback onLike;
  final Function(String) onComment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
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
  bool _isExpanded = false;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final comments = widget.news['comments'] ?? [];
    final hashtags = widget.news['hashtags']?.toString().split(',') ?? [];
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
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar with gradient
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
                          widget.news['author_name']?[0]?.toUpperCase() ?? '?',
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
                    // More options button
                    if (isAuthor)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.more_horiz,
                              size: 20,
                              color: widget.secondaryTextColor),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _buildOptionsSheet(),
                            );
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
                    if (widget.news['title'] != null && widget.news['title'].toString().isNotEmpty)
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

              // Hashtags - ВЫРАВНЕНЫ ПО ПРАВОМУ КРАЮ
              if (hashtags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight, // Выравнивание по правому краю
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.end, // Выравнивание элементов по правому краю
                      children: [
                        for (final tag in hashtags.take(5))
                          if (tag.trim().isNotEmpty)
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            ),
                      ],
                    ),
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
                      icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
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
                      icon: _isExpanded ? Icons.chat_rounded : Icons.chat_bubble_outline_rounded,
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
                      icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
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
                      icon: Icon(Icons.share_rounded,
                          size: 22,
                          color: widget.secondaryTextColor),
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
                            ...comments.map((comment) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        comment['author']?[0]?.toUpperCase() ?? '?',
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
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment['author'] ?? 'Неизвестно',
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
                                              color: widget.textColor.withOpacity(0.9),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            comment['time'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: widget.secondaryTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
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
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                                icon: const Icon(Icons.send_rounded,
                                    size: 18,
                                    color: Colors.white),
                                onPressed: () {
                                  if (_commentController.text.trim().isNotEmpty) {
                                    widget.onComment(_commentController.text);
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
      ),
    );
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
          color: isActive ? widget.primaryColor.withOpacity(0.1) : Colors.transparent,
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
                  color: isActive ? widget.primaryColor : widget.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
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
          _buildOptionItem(
            icon: Icons.edit_rounded,
            title: 'Редактировать',
            color: widget.primaryColor,
            onTap: widget.onEdit,
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            icon: Icons.delete_rounded,
            title: 'Удалить',
            color: Colors.red,
            onTap: widget.onDelete,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
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
    super.dispose();
  }
}