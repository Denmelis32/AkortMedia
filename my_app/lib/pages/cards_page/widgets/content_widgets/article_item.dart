import 'package:flutter/material.dart';
import '../../models/channel.dart';

class ArticleItem extends StatelessWidget {
  final Map<String, dynamic> article;
  final Channel channel;

  const ArticleItem({
    super.key,
    required this.article,
    required this.channel,
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
          if (article['description'] != null && article['description'].toString().isNotEmpty)
            _buildDescription(),
          if (article['category'] != null && article['category'].toString().isNotEmpty)
            _buildCategory(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.article, color: Colors.purple, size: 16),
        const SizedBox(width: 8),
        Text(
          'Статья',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(DateTime.parse(article['publish_date'])),
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        if (article['emoji'] != null && article['emoji'].toString().isNotEmpty)
          Text(
            article['emoji'].toString(),
            style: const TextStyle(fontSize: 20),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            article['title'] ?? 'Без названия',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        article['description'].toString(),
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCategory() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          article['category'].toString(),
          style: TextStyle(
            color: Colors.purple,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${article['views'] ?? 0}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(width: 16),
          Icon(Icons.thumb_up, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${article['likes'] ?? 0}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
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