import 'package:flutter/material.dart';
import 'discussion.dart';

class DiscussionCard extends StatefulWidget {
  final Discussion discussion;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;
  final VoidCallback? onBookmark;
  final VoidCallback? onSubscribe;

  const DiscussionCard({
    super.key,
    required this.discussion,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onMore,
    this.onBookmark,
    this.onSubscribe,
  });

  @override
  State<DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<DiscussionCard> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _isShared = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.discussion.isLiked ?? false;
    _isBookmarked = widget.discussion.isBookmarked ?? false;
    _isSubscribed = widget.discussion.isSubscribed ?? false;
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    widget.onLike?.call();
  }

  void _handleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    widget.onBookmark?.call();
  }

  void _handleShare() {
    setState(() {
      _isShared = true;
    });
    widget.onShare?.call();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isShared = false;
        });
      }
    });
  }

  void _handleSubscribe() {
    setState(() {
      _isSubscribed = !_isSubscribed;
    });
    widget.onSubscribe?.call();
  }

  String get _formattedLikes {
    final likesCount = widget.discussion.likesCount;
    if (likesCount < 1000) {
      return likesCount.toString();
    } else if (likesCount < 1000000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K'.replaceAll('.0', '');
    } else {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M'.replaceAll('.0', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 700;

    if (isMobile) {
      return _buildMobileCard();
    } else {
      return _buildDesktopCard();
    }
  }

  // КАРТОЧКА ДЛЯ ТЕЛЕФОНА
  Widget _buildMobileCard() {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ШАПКА С ИНФОРМАЦИЕЙ ОБ АВТОРЕ И КНОПКОЙ ПОДПИСКИ
                Row(
                  children: [
                    // АВАТАР АВТОРА
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.discussion.authorAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[400]!,
                                    Colors.blue[600]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ИМЯ АВТОРА И ВРЕМЯ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.discussion.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_formatTimeAgo(widget.discussion.createdAt)} • $_formattedLikes участников',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // КНОПКА ПОДПИСКИ - ПРОСТО +
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _isSubscribed
                            ? Colors.green[50]!
                            : Colors.blue[50]!,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isSubscribed
                              ? Colors.green[200]!
                              : Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _handleSubscribe,
                        icon: Icon(
                          _isSubscribed ? Icons.check : Icons.add,
                          size: 14,
                        ),
                        color: _isSubscribed
                            ? Colors.green[600]!
                            : Colors.blue[600]!,
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // КОНТЕНТ - ВЫРАВНЕН ПО ИМЕНИ АВТОРА
                Padding(
                  padding: const EdgeInsets.only(left: 44), // 36 (ширина аватарки) + 8 (отступ) = 44
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ЗАГОЛОВОК
                      Text(
                        widget.discussion.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // ОПИСАНИЕ
                      Text(
                        widget.discussion.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // ТЕГИ
                      if (widget.discussion.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: widget.discussion.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50]!,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[700]!,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // КНОПКИ ДЕЙСТВИЙ - РАСПРЕДЕЛЕНЫ ОТ ЛЕВОГО КРАЯ ДО СЕРЕДИНЫ КАРТОЧКИ
                Padding(
                  padding: const EdgeInsets.only(left: 44), // Тот же отступ, что и у контента
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5, // ЗАНИМАЕТ ПОЛОВИНУ ШИРИНЫ ЭКРАНА
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // РАВНОМЕРНОЕ РАСПРЕДЕЛЕНИЕ
                      children: [
                        // КНОПКА НРАВИТСЯ
                        _buildSmallActionButton(
                          icon: _isLiked ? Icons.favorite : Icons.favorite_outline,
                          isActive: _isLiked,
                          onPressed: _handleLike,
                          activeColor: Colors.red,
                        ),

                        // КНОПКА ИЗБРАННОЕ
                        _buildSmallActionButton(
                          icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          isActive: _isBookmarked,
                          onPressed: _handleBookmark,
                          activeColor: Colors.amber,
                        ),

                        // КНОПКА ПОДЕЛИТЬСЯ
                        _buildSmallActionButton(
                          icon: _isShared ? Icons.share : Icons.share_outlined,
                          isActive: _isShared,
                          onPressed: _handleShare,
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // КАРТОЧКА ДЛЯ ДЕСКТОПА
  Widget _buildDesktopCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ШАПКА С ИНФОРМАЦИЕЙ ОБ АВТОРЕ И КНОПКОЙ ПОДПИСКИ
                Row(
                  children: [
                    // АВАТАР АВТОРА
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.discussion.authorAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[400]!,
                                    Colors.blue[600]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ИНФОРМАЦИЯ ОБ АВТОРЕ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.discussion.authorName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatTimeAgo(widget.discussion.createdAt)} • $_formattedLikes участников',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // КНОПКА ПОДПИСКИ В ВЕРХНЕМ ПРАВОМ УГЛУ
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: _handleSubscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSubscribed
                              ? Colors.green[50]!
                              : Colors.blue[50]!,
                          foregroundColor: _isSubscribed
                              ? Colors.green[600]!
                              : Colors.blue[600]!,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: _isSubscribed
                                  ? Colors.green[200]!
                                  : Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: const Size(0, 0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSubscribed ? Icons.check : Icons.add,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isSubscribed ? 'Подписаны' : 'Подписаться',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // КОНТЕНТ - ВЫРАВНЕН ПО ИМЕНИ АВТОРА
                Padding(
                  padding: const EdgeInsets.only(left: 52), // 40 (ширина аватарки) + 12 (отступ) = 52
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ЗАГОЛОВОК
                      Text(
                        widget.discussion.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // ОПИСАНИЕ
                      Text(
                        widget.discussion.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // ТЕГИ
                      if (widget.discussion.tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: widget.discussion.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50]!,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.blue[100]!,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700]!,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // КНОПКИ ДЕЙСТВИЙ - ВЫРАВНЕНЫ ПО ЗАГОЛОВКУ И РАСПРЕДЕЛЕНЫ ДО СЕРЕДИНЫ
                Padding(
                  padding: const EdgeInsets.only(left: 52), // Тот же отступ, что и у контента
                  child: Container(
                    width: 200, // ФИКСИРОВАННАЯ ШИРИНА ДЛЯ РАСПРЕДЕЛЕНИЯ
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // РАВНОМЕРНОЕ РАСПРЕДЕЛЕНИЕ
                      children: [
                        // КНОПКА НРАВИТСЯ
                        _buildDesktopActionButton(
                          icon: _isLiked ? Icons.favorite : Icons.favorite_outline,
                          isActive: _isLiked,
                          onPressed: _handleLike,
                          tooltip: 'Нравится',
                        ),
                        // КНОПКА ИЗБРАННОЕ
                        _buildDesktopActionButton(
                          icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          isActive: _isBookmarked,
                          onPressed: _handleBookmark,
                          tooltip: 'В закладки',
                        ),
                        // КНОПКА ПОДЕЛИТЬСЯ
                        _buildDesktopActionButton(
                          icon: Icons.share_outlined,
                          isActive: _isShared,
                          onPressed: _handleShare,
                          tooltip: 'Поделиться',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // УМЕНЬШЕННАЯ КНОПКА ДЛЯ МОБИЛЬНОЙ ВЕРСИИ
  Widget _buildSmallActionButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.grey[50]!,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey[200]!,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isActive ? activeColor : Colors.grey[600]!,
        ),
      ),
    );
  }

  Widget _buildDesktopActionButton({
    required IconData icon,
    bool isActive = false,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[50]! : Colors.grey[50]!,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue[200]! : Colors.grey[200]!,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 18,
          color: isActive ? Colors.blue[600]! : Colors.grey[600]!,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            minimumSize: const Size(36, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин';
    if (difference.inHours < 24) return '${difference.inHours} ч';
    if (difference.inDays < 7) return '${difference.inDays} д';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} нед';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} мес';
    return '${(difference.inDays / 365).floor()} г';
  }
}