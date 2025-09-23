import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_posts_provider.dart';
import '../../models/channel.dart';
import 'post_item.dart';

class AkorContent extends StatelessWidget {
  final Channel channel;

  const AkorContent({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelPostsProvider>(
      builder: (context, postsProvider, child) {
        final posts = postsProvider.getPostsForChannel(channel.id);

        if (posts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPostsList(posts);
      },
    );
  }

  Widget _buildPostsList(List<Map<String, dynamic>> posts) {
    // Сортируем посты по дате (новые сверху)
    final sortedPosts = List<Map<String, dynamic>>.from(posts);
    sortedPosts.sort((a, b) {
      final dateA = DateTime.parse(a['created_at']);
      final dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA); // Новые сверху
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedPosts.length,
      itemBuilder: (context, index) {
        return PostItem(
          post: sortedPosts[index],
          channel: channel,
          isAkorTab: true,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.newspaper, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Пока нет новостей',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите + чтобы создать первую новость!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}