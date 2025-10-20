// ⚡ КОМПОНЕНТ ДЕЙСТВИЙ С ПОСТОМ
// Отображает кнопки лайков, комментариев, репостов, закладок и подписки

import 'package:flutter/material.dart';
import '../../../../services/interaction_manager.dart';
import '../../utils/layout_utils.dart';

class NewsCardActions extends StatelessWidget {
  final PostInteractionState? postState;
  final bool isAuthor;
  final bool isChannelPost;
  final bool isFollowing;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onBookmark;
  final VoidCallback onFollow;
  final bool showFollowButton; // ✅ Новый параметр

  const NewsCardActions({
    super.key,
    required this.postState,
    required this.isAuthor,
    required this.isChannelPost,
    required this.isFollowing,
    required this.onLike,
    required this.onComment,
    required this.onRepost,
    required this.onBookmark,
    required this.onFollow,
    this.showFollowButton = false, // ✅ По умолчанию false
  });

  @override
  Widget build(BuildContext context) {
    if (postState == null) return const SizedBox();

    final isMobile = MediaQuery.of(context).size.width <= LayoutUtils.mobileBreakpoint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ❤️ ЛАЙК
          _buildActionButton(
            icon: postState!.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            count: postState!.likesCount,
            isActive: postState!.isLiked,
            color: Colors.red,
            onPressed: onLike,
            isMobile: isMobile,
          ),
          const SizedBox(width: 12),

          // 💬 КОММЕНТАРИИ
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: postState!.comments.length,
            isActive: false, // Комментарии не имеют постоянного активного состояния
            color: Colors.blue,
            onPressed: onComment,
            isMobile: isMobile,
          ),
          const SizedBox(width: 12),

          // 🔄 РЕПОСТ
          _buildActionButton(
            icon: postState!.isReposted ? Icons.repeat_on_rounded : Icons.repeat_rounded,
            count: postState!.repostsCount,
            isActive: postState!.isReposted,
            color: Colors.green,
            onPressed: onRepost,
            isMobile: isMobile,
          ),
          const SizedBox(width: 12),

          // 🔖 ЗАКЛАДКА
          _buildActionButton(
            icon: postState!.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            count: 0, // Закладки обычно не показывают счетчик
            isActive: postState!.isBookmarked,
            color: Colors.amber,
            onPressed: onBookmark,
            isMobile: isMobile,
          ),

          const Spacer(),

          // 📢 КНОПКА ПОДПИСКИ (если нужно)
          if (_shouldShowFollowButton())
            _buildFollowButton(isMobile: isMobile),
        ],
      ),
    );
  }

  /// 🎯 СОЗДАЕТ КНОПКУ ДЕЙСТВИЯ
  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onPressed,
    bool isMobile = false,
  }) {
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

  /// 📢 СОЗДАЕТ КНОПКУ ПОДПИСКИ
  Widget _buildFollowButton({bool isMobile = false}) {
    return GestureDetector(
      onTap: onFollow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          gradient: isFollowing
              ? null
              : const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: isFollowing ? Colors.green.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          border: Border.all(
            color: isFollowing ? Colors.green.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
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

  /// 🔢 ФОРМАТИРУЕТ ЧИСЛА ДЛЯ ОТОБРАЖЕНИЯ
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// 🎯 ОПРЕДЕЛЯЕТ НУЖНО ЛИ ПОКАЗЫВАТЬ КНОПКУ ПОДПИСКИ
  bool _shouldShowFollowButton() {
    // ✅ Используем переданный параметр showFollowButton
    // и дополнительно проверяем, что пользователь не автор
    return showFollowButton && !isAuthor;
  }
}