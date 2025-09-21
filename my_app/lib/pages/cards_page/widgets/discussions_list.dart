// lib/pages/cards_page/widgets/discussions_list.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/discussion.dart';
import '../models/channel.dart';

class DiscussionsList extends StatelessWidget {
  final List<Discussion> discussions;
  final Channel channel;
  final Function(Discussion) onDiscussionTap;

  const DiscussionsList({
    super.key,
    required this.discussions,
    required this.channel,
    required this.onDiscussionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Обсуждения',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: channel.cardColor,
            ),
          ),
          const SizedBox(height: 16),

          if (discussions.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: discussions.length,
              itemBuilder: (context, index) {
                final discussion = discussions[index];
                return _buildDiscussionCard(discussion);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет обсуждений',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Будьте первым, кто начнет обсуждение!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionCard(Discussion discussion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => onDiscussionTap(discussion),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (discussion.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 16,
                      color: channel.cardColor,
                    ),
                  if (discussion.isPinned) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      discussion.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Author and date
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      discussion.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(discussion.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.thumb_up_outlined,
                    count: discussion.likes,
                    color: Colors.grey[600]!,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    icon: Icons.comment_outlined,
                    count: discussion.commentsCount,
                    color: Colors.grey[600]!,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: channel.cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Обсуждение',
                      style: TextStyle(
                        fontSize: 11,
                        color: channel.cardColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          _formatCount(count),
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}г назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}мес назад';
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

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}