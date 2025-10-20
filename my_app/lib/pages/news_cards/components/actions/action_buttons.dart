// 🎯 ОТДЕЛЬНЫЕ КОМПОНЕНТЫ КНОПОК ДЕЙСТВИЙ
// Для переиспользования в других местах

import 'package:flutter/material.dart';

/// ❤️ КНОПКА ЛАЙКА
class LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onPressed;
  final bool isMobile;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.onPressed,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseActionButton(
      icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
      count: likesCount,
      isActive: isLiked,
      color: Colors.red,
      onPressed: onPressed,
      isMobile: isMobile,
    );
  }
}

/// 💬 КНОПКА КОММЕНТАРИЕВ
class CommentButton extends StatelessWidget {
  final int commentsCount;
  final VoidCallback onPressed;
  final bool isMobile;

  const CommentButton({
    super.key,
    required this.commentsCount,
    required this.onPressed,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseActionButton(
      icon: Icons.chat_bubble_outline_rounded,
      count: commentsCount,
      isActive: false,
      color: Colors.blue,
      onPressed: onPressed,
      isMobile: isMobile,
    );
  }
}

/// 🔄 КНОПКА РЕПОСТА
class RepostButton extends StatelessWidget {
  final bool isReposted;
  final int repostsCount;
  final VoidCallback onPressed;
  final bool isMobile;

  const RepostButton({
    super.key,
    required this.isReposted,
    required this.repostsCount,
    required this.onPressed,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseActionButton(
      icon: isReposted ? Icons.repeat_on_rounded : Icons.repeat_rounded,
      count: repostsCount,
      isActive: isReposted,
      color: Colors.green,
      onPressed: onPressed,
      isMobile: isMobile,
    );
  }
}

/// 🔖 КНОПКА ЗАКЛАДКИ
class BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onPressed;
  final bool isMobile;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onPressed,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseActionButton(
      icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
      count: 0,
      isActive: isBookmarked,
      color: Colors.amber,
      onPressed: onPressed,
      isMobile: isMobile,
    );
  }
}

/// 📢 КНОПКА ПОДПИСКИ
class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onPressed;
  final bool isMobile;
  final List<Color>? gradientColors;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onPressed,
    this.isMobile = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = const [Color(0xFF667eea), Color(0xFF764ba2)];
    final colors = gradientColors ?? defaultGradient;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          gradient: isFollowing ? null : LinearGradient(colors: colors),
          color: isFollowing ? Colors.green.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          border: Border.all(
            color: isFollowing ? Colors.green.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFollowing ? Icons.check_rounded : Icons.add_rounded,
              size: isMobile ? 14 : 16,
              color: isFollowing ? Colors.green : Colors.white,
            ),
            if (!isMobile) SizedBox(width: isFollowing ? 0 : 6),
            if (!isMobile)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isFollowing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: Text(
                  'Подписаться',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                secondChild: Text(
                  'Подписка',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🎯 БАЗОВАЯ КНОПКА ДЕЙСТВИЯ
class _BaseActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color color;
  final VoidCallback onPressed;
  final bool isMobile;

  const _BaseActionButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.color,
    required this.onPressed,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 14,
            vertical: isMobile ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
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
                size: isMobile ? 18 : 20,
                color: isActive ? color : Colors.grey[700],
              ),
              if (count > 0) ...[
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : Colors.grey[700],
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}