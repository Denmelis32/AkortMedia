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

  @override
  Widget build(BuildContext context) {
    final comments = widget.news['comments'] ?? [];
    final hashtags = widget.news['hashtags']?.toString().split(',') ?? [];
    final isAuthor = widget.news['author_name'] == widget.userName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: widget.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with author and time
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.primaryColor.withOpacity(0.1),
                    child: Text(
                      widget.news['author_name']?[0]?.toUpperCase() ?? '?',
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontWeight: FontWeight.bold,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.textColor,
                          ),
                        ),
                        Text(
                          widget.getTimeAgo(widget.news['created_at']),
                          style: TextStyle(
                            color: widget.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAuthor)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: widget.secondaryTextColor),
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit();
                        } else if (value == 'delete') {
                          widget.onDelete();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: widget.primaryColor),
                              const SizedBox(width: 8),
                              const Text('Редактировать'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Удалить'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Title (only show if not empty)
              if (widget.news['title'] != null && widget.news['title'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.news['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: widget.textColor,
                    ),
                  ),
                ),

              // Description with increased left padding
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Text(
                  widget.news['description'],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: widget.textColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Hashtags at the bottom right
              if (hashtags.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final tag in hashtags.take(4))
                        if (tag.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${tag.trim()}',
                              style: TextStyle(
                                color: widget.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Stats and actions
              Row(
                children: [
                  // Like button
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? widget.primaryColor : widget.secondaryTextColor,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      widget.onLike();
                    },
                  ),
                  Text(
                    '${widget.news['likes'] ?? 0}',
                    style: TextStyle(
                      color: widget.secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Comment button
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.chat : Icons.chat_bubble_outline,
                      color: _isExpanded ? widget.primaryColor : widget.secondaryTextColor,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                  Text(
                    '${comments.length}',
                    style: TextStyle(
                      color: widget.secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),
                ],
              ),

              // Comments section
              if (_isExpanded) ...[
                const Divider(height: 24),
                if (comments.isNotEmpty)
                  Column(
                    children: [
                      ...comments.map((comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: widget.primaryColor.withOpacity(0.1),
                              child: Text(
                                comment['author']?[0]?.toUpperCase() ?? '?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['author'] ?? 'Неизвестно',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: widget.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['text'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: widget.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['time'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.secondaryTextColor,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(color: widget.textColor),
                          decoration: InputDecoration(
                            hintText: 'Написать комментарий...',
                            hintStyle: TextStyle(color: widget.secondaryTextColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              widget.onComment(value);
                              _commentController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: widget.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, size: 20, color: Colors.white),
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
            ],
          ),
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