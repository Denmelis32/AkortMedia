import 'package:flutter/material.dart';
import '../../models/channel.dart';

class PostItem extends StatelessWidget {
  final Map<String, dynamic> post;
  final Channel channel;
  final bool isAkorTab;

  const PostItem({
    super.key,
    required this.post,
    required this.channel,
    this.isAkorTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildTitle(),
          if (post['description'] != null && post['description'].toString().isNotEmpty)
            _buildDescription(),
          if (isAkorTab && post['hashtags'] != null && (post['hashtags'] as List).isNotEmpty)
            _buildHashtags(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
            Icons.newspaper,
            color: channel.cardColor,
            size: 16
        ),
        const SizedBox(width: 8),
        Text(
          isAkorTab ? 'Новость в Акорт' : 'Новость из Акорт',
          style: TextStyle(
            color: channel.cardColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(DateTime.parse(post['created_at'])),
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      post['title'] ?? 'Без названия',
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        post['description'].toString(),
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
        ),
        maxLines: isAkorTab ? 10 : 3, // Исправлено: null нельзя, используем большое число
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildHashtags() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        children: (post['hashtags'] as List).map<Widget>((hashtag) {
          return Chip(
            label: Text(
              '#$hashtag',
              style: TextStyle(
                fontSize: 12,
                color: channel.cardColor,
              ),
            ),
            backgroundColor: channel.cardColor.withOpacity(0.1),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.thumb_up, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${post['likes'] ?? 0}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(width: 16),
          Icon(Icons.comment, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${post['comments'] != null ? (post['comments'] as List).length : 0}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          if (isAkorTab) ...[
            const Spacer(),
            Text(
              'Опубликовано на Стене',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${date.day}.${date.month}.${date.year}';
    } else if (difference.inDays > 7) {
      return '${date.day}.${date.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'только что';
    }
  }
}