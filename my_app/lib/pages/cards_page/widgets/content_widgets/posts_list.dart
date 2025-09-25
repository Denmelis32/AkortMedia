// lib/pages/cards_page/widgets/posts_list.dart
import 'package:flutter/material.dart';
import 'package:my_app/pages/rooms_pages/rooms_page.dart';
import '../../../news_page/utils.dart'; // Импорт функций formatDate и getTimeAgo
import '../../models/channel.dart';

class PostsList extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final Channel channel;
  final String emptyMessage;

  const PostsList({
    super.key,
    required this.posts,
    required this.channel,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _buildEmptyContent('Посты канала', emptyMessage);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: posts.map((post) => _buildPostCard(post)).toList(),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: channel.cardColor.withOpacity(0.1),
                backgroundImage: NetworkImage(channel.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatPostDate(post['created_at']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            post['description'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (post['hashtags'] != null && post['hashtags'].isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _parseHashtags(post['hashtags']).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: channel.cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: channel.cardColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildReactionButton(
                icon: Icons.thumb_up_outlined,
                count: post['likes'] ?? 0,
                onPressed: () {},
                color: Colors.grey[600]!,
              ),
              const SizedBox(width: 16),
              _buildReactionButton(
                icon: Icons.comment_outlined,
                count: post['comments']?.length ?? 0,
                onPressed: () {},
                color: Colors.grey[600]!,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPostDate(dynamic dateData) {
    if (dateData == null) return 'Нет даты';

    try {
      if (dateData is DateTime) {
        // Используем getTimeAgo для отображения относительного времени
        return getTimeAgo(dateData.toIso8601String());
      } else if (dateData is String) {
        // Используем getTimeAgo для строкового формата даты
        return getTimeAgo(dateData);
      } else {
        return dateData.toString();
      }
    } catch (e) {
      return 'Неверный формат даты';
    }
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        NumberFormatting(count).formatCount(),
        style: TextStyle(color: color, fontSize: 14),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 0),
      ),
    );
  }

  List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is String) {
      return hashtags.split(' ').where((tag) => tag.isNotEmpty).toList();
    } else if (hashtags is List) {
      return hashtags
          .map((tag) => tag.toString())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return [];
  }

  Widget _buildEmptyContent(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Extension для форматирования чисел (лайков, комментариев)
extension NumberFormatting on int {
  String formatCount() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}