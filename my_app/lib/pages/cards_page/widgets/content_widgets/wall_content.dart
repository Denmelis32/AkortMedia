import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/articles_provider.dart';
import '../../../../providers/channel_posts_provider.dart';
import '../../models/channel.dart';
import 'post_item.dart';
import 'article_item.dart';

class WallContent extends StatelessWidget {
  final Channel channel;

  const WallContent({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChannelPostsProvider, ArticlesProvider>(
      builder: (context, postsProvider, articlesProvider, child) {
        final posts = postsProvider.getPostsForChannel(channel.id);
        final articles = articlesProvider.getArticlesForChannel(channel.id);

        final allContent = _combineAndSortContent(posts, articles);

        if (allContent.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allContent.length,
          itemBuilder: (context, index) {
            final item = allContent[index];
            return item['type'] == 'post'
                ? PostItem(post: item['data'], channel: channel)
                : ArticleItem(article: item['data'], channel: channel);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _combineAndSortContent(
      List<Map<String, dynamic>> posts, List<Map<String, dynamic>> articles) {
    final allContent = <Map<String, dynamic>>[];

    // Добавляем посты
    for (final post in posts) {
      allContent.add({
        'type': 'post',
        'data': post,
        'date': DateTime.parse(post['created_at'])
      });
    }

    // Добавляем статьи
    for (final article in articles) {
      allContent.add({
        'type': 'article',
        'data': article,
        'date': DateTime.parse(article['publish_date'])
      });
    }

    // Сортируем по дате (новые сверху)
    allContent.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA); // Новые сверху
    });

    return allContent;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.dashboard, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Стена пока пустая',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Будьте первым, кто поделится контентом!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}