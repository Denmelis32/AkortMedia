import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/articles_provider.dart';
import '../../../../providers/channel_posts_provider.dart';
import '../../models/channel.dart';
import 'post_item.dart';
import 'article_item.dart';

class WallContent extends StatelessWidget {
  final Channel channel;
  final String? customAvatarUrl;

  const WallContent({
    super.key,
    required this.channel,
    this.customAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChannelPostsProvider, ArticlesProvider>(
      builder: (context, postsProvider, articlesProvider, child) {
        final posts = postsProvider.getPostsForChannel(channel.id);
        final articles = articlesProvider.getArticlesForChannel(channel.id);

        final allContent = _combineAndSortContent(posts, articles);

        if (allContent.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: allContent.length,
          itemBuilder: (context, index) {
            final item = allContent[index];
            return item['type'] == 'post'
                ? PostItem(
              post: item['data'],
              channel: channel,
              getTimeAgo: _getTimeAgo,
              onLike: () => _handlePostLike(item['data']['id'], postsProvider),
              onBookmark: () => _handlePostBookmark(item['data']['id'], postsProvider),
              // ИСПРАВЛЕНИЕ: Правильная сигнатура для onComment
              onComment: (text, userName, userAvatar) => _handlePostComment(
                context,
                item['data']['id'],
                text,
                userName,
                userAvatar,
                postsProvider,
              ),
              onShare: () => _handleShare(context, item['data']),
              customAvatarUrl: customAvatarUrl,
            )
                : ArticleItem(
              article: item['data'],
              channel: channel,
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _combineAndSortContent(
      List<Map<String, dynamic>> posts, List<Map<String, dynamic>> articles) {
    final allContent = <Map<String, dynamic>>[];

    for (final post in posts) {
      allContent.add({
        'type': 'post',
        'data': post,
        'date': DateTime.parse(post['created_at'])
      });
    }

    for (final article in articles) {
      allContent.add({
        'type': 'article',
        'data': article,
        'date': DateTime.parse(article['publish_date'])
      });
    }

    allContent.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });

    return allContent;
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
      ChannelPostsProvider postsProvider,
      ) {
    try {
      final newComment = {
        'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
        'author': userName.isNotEmpty ? userName : 'Пользователь',
        'text': commentText,
        'time': 'Только что',
        'author_avatar': userAvatar,
      };

      // Используем существующий метод addComment
      postsProvider.addComment(postId, commentText);

      // Показываем уведомление
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

  void _handleShare(BuildContext context, Map<String, dynamic> postData) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция шаринга скоро будет доступна!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Стена пока пустая',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Будьте первым, кто поделится контентом\nв этом канале!',
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
              _showCreateContentDialog(context);
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
              'Создать пост',
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

  void _showCreateContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать контент'),
        content: const Text('Выберите тип контента для создания:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showNotImplementedSnackbar(context, 'Создание поста');
            },
            child: const Text('Пост'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showNotImplementedSnackbar(context, 'Создание статьи');
            },
            child: const Text('Статья'),
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