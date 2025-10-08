import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_posts_provider.dart';
import '../../models/channel.dart';
import 'post_item.dart';

class AkorContent extends StatelessWidget {
  final Channel channel;
  final String? customAvatarUrl;

  const AkorContent({
    super.key,
    required this.channel,
    this.customAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelPostsProvider>(
      builder: (context, postsProvider, child) {
        final posts = postsProvider.getPostsForChannel(channel.id);

        if (posts.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildPostsList(context, posts, postsProvider);
      },
    );
  }

  Widget _buildPostsList(BuildContext context, List<Map<String, dynamic>> posts, ChannelPostsProvider postsProvider) {
    final sortedPosts = List<Map<String, dynamic>>.from(posts);
    sortedPosts.sort((a, b) {
      final dateA = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
      final dateB = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: sortedPosts.length,
      itemBuilder: (context, index) {
        return PostItem(
          post: sortedPosts[index],
          channel: channel,
          isAkorTab: true,
          getTimeAgo: _getTimeAgo,
          onLike: () => _handlePostLike(sortedPosts[index]['id'], postsProvider),
          onBookmark: () => _handlePostBookmark(sortedPosts[index]['id'], postsProvider),
          // ИСПРАВЛЕНИЕ: Правильная сигнатура для onComment
          onComment: (text, userName, userAvatar) => _handlePostComment(
            context,
            sortedPosts[index]['id'],
            text,
            userName,
            userAvatar,
            postsProvider,
          ),
          onShare: () => _handleShare(context, sortedPosts[index]),
          customAvatarUrl: customAvatarUrl,
        );
      },
    );
  }

  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years ${_getRussianWord(years, ['год', 'года', 'лет'])} назад';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months ${_getRussianWord(months, ['месяц', 'месяца', 'месяцев'])} назад';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${_getRussianWord(difference.inDays, ['день', 'дня', 'дней'])} назад';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${_getRussianWord(difference.inHours, ['час', 'часа', 'часов'])} назад';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${_getRussianWord(difference.inMinutes, ['минуту', 'минуты', 'минут'])} назад';
      } else {
        return 'только что';
      }
    } catch (e) {
      return 'недавно';
    }
  }

  String _getRussianWord(int number, List<String> words) {
    if (number % 10 == 1 && number % 100 != 11) {
      return words[0];
    } else if (number % 10 >= 2 && number % 10 <= 4 && (number % 100 < 10 || number % 100 >= 20)) {
      return words[1];
    } else {
      return words[2];
    }
  }

  void _handlePostLike(String postId, ChannelPostsProvider provider) {
    provider.toggleLike(postId);
  }

  void _handlePostBookmark(String postId, ChannelPostsProvider provider) {
    provider.toggleBookmark(postId);
  }

  // ИСПРАВЛЕНИЕ: Правильная сигнатура метода
  void _handlePostComment(
      BuildContext context,
      String postId,
      String commentText,
      String userName,
      String userAvatar,
      ChannelPostsProvider provider,
      ) {
    try {
      // Используем существующий метод addComment
      provider.addComment(postId, commentText);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Комментарий добавлен'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Ошибка добавления комментария: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка при добавлении комментария'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleShare(BuildContext context, Map<String, dynamic> content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Поделиться: ${content['title']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.newspaper_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Пока нет новостей в Акорт',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Нажмите + чтобы создать первую новость\nи поделиться ей на стене канала!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _showCreatePostDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: channel.cardColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Создать новость',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать новость в Акорт'),
        content: const Text('Новость будет автоматически опубликована на стене канала.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showNotImplementedSnackbar(context, 'Создание новости');
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _showNotImplementedSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature скоро будет доступно!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}