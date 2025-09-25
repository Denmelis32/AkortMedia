// lib/pages/cards_page/widgets/discussions_list.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/discussion.dart';
import '../../models/channel.dart';

class DiscussionsList extends StatelessWidget {
  final List<Discussion> discussions;
  final Channel channel;
  final ValueChanged<Discussion> onDiscussionTap;
  final VoidCallback? onCreateDiscussion;
  final bool showCreateButton;

  const DiscussionsList({
    super.key,
    required this.discussions,
    required this.channel,
    required this.onDiscussionTap,
    this.onCreateDiscussion,
    this.showCreateButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final pinnedDiscussions = discussions.where((d) => d.isPinned).toList();
    final regularDiscussions = discussions.where((d) => !d.isPinned).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with create button
          _BuildHeader(
            channel: channel,
            discussionCount: discussions.length,
            onCreateDiscussion: onCreateDiscussion,
            showCreateButton: showCreateButton,
          ),

          const SizedBox(height: 20),

          // Content
          if (discussions.isEmpty)
            _EmptyDiscussionsState(channel: channel, onCreateDiscussion: onCreateDiscussion)
          else
            Column(
              children: [
                // Pinned discussions
                if (pinnedDiscussions.isNotEmpty) ...[
                  _buildSectionTitle('Закрепленные'),
                  const SizedBox(height: 12),
                  ...pinnedDiscussions.map((discussion) =>
                      _DiscussionCard(
                        discussion: discussion,
                        channel: channel,
                        onTap: onDiscussionTap,
                        isPinned: true,
                      ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Regular discussions
                if (regularDiscussions.isNotEmpty) ...[
                  if (pinnedDiscussions.isNotEmpty)
                    _buildSectionTitle('Все обсуждения'),
                  ...regularDiscussions.map((discussion) =>
                      _DiscussionCard(
                        discussion: discussion,
                        channel: channel,
                        onTap: onDiscussionTap,
                        isPinned: false,
                      ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  final Channel channel;
  final int discussionCount;
  final VoidCallback? onCreateDiscussion;
  final bool showCreateButton;

  const _BuildHeader({
    required this.channel,
    required this.discussionCount,
    this.onCreateDiscussion,
    required this.showCreateButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Title with count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Обсуждения канала',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: channel.cardColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getDiscussionCountText(discussionCount),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Create button
        if (showCreateButton && onCreateDiscussion != null)
          FloatingActionButton.small(
            onPressed: onCreateDiscussion,
            backgroundColor: channel.cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
      ],
    );
  }

  String _getDiscussionCountText(int count) {
    if (count == 0) return 'Нет обсуждений';
    if (count % 10 == 1 && count % 100 != 11) return '$count обсуждение';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return '$count обсуждения';
    }
    return '$count обсуждений';
  }
}

class _DiscussionCard extends StatelessWidget {
  final Discussion discussion;
  final Channel channel;
  final ValueChanged<Discussion> onTap;
  final bool isPinned;

  const _DiscussionCard({
    required this.discussion,
    required this.channel,
    required this.onTap,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isPinned ? channel.cardColor.withOpacity(0.03) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onTap(discussion),
          borderRadius: BorderRadius.circular(16),
          splashColor: channel.cardColor.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isPinned
                  ? Border.all(color: channel.cardColor.withOpacity(0.2))
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with pin icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPinned) ...[
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: channel.cardColor,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        discussion.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: isPinned ? channel.cardColor : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Status badge (closed/resolved if applicable)
                    if (discussion.isClosed != null && discussion.isClosed!)
                      _buildStatusBadge('Закрыто', Colors.grey),
                    if (discussion.isResolved != null && discussion.isResolved!)
                      _buildStatusBadge('Решено', Colors.green),
                  ],
                ),

                const SizedBox(height: 12),

                // Author and preview
                Row(
                  children: [
                    // Author avatar
                    _AuthorAvatar(author: discussion.author),

                    const SizedBox(width: 8),

                    // Author info and preview
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discussion.author,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (discussion.previewText != null && discussion.previewText!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              discussion.previewText!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Date
                    Text(
                      _formatDate(discussion.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Stats and tags
                Row(
                  children: [
                    // Stats
                    _DiscussionStats(
                      likes: discussion.likes,
                      commentsCount: discussion.commentsCount,
                      color: Colors.grey.shade600,
                    ),

                    const Spacer(),

                    // Category badge (using discussion category if available)
                    if (discussion.category != null && discussion.category!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: channel.cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discussion.category!,
                          style: TextStyle(
                            fontSize: 10,
                            color: channel.cardColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$yearsг';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$monthsмес';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м';
    } else {
      return 'только что';
    }
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String author;

  const _AuthorAvatar({required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _getAvatarColor(author),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          author.isNotEmpty ? author[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade500,
      Colors.green.shade500,
      Colors.orange.shade500,
      Colors.purple.shade500,
      Colors.red.shade500,
    ];
    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }
}

class _DiscussionStats extends StatelessWidget {
  final int likes;
  final int commentsCount;
  final Color color;

  const _DiscussionStats({
    required this.likes,
    required this.commentsCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Likes
        if (likes > 0) ...[
          _StatItem(
            icon: Icons.thumb_up_outlined,
            count: likes,
            color: color,
          ),
          const SizedBox(width: 12),
        ],

        // Comments
        _StatItem(
          icon: Icons.comment_outlined,
          count: commentsCount,
          color: color,
        ),

        // Views if available
        if (commentsCount == 0 && likes == 0)
          _StatItem(
            icon: Icons.remove_red_eye_outlined,
            count: 0,
            color: Colors.grey.shade400,
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _EmptyDiscussionsState extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onCreateDiscussion;

  const _EmptyDiscussionsState({
    required this.channel,
    this.onCreateDiscussion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Пока нет обсуждений',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Будьте первым, кто начнет обсуждение в этом канале!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          if (onCreateDiscussion != null)
            FilledButton.icon(
              onPressed: onCreateDiscussion,
              style: FilledButton.styleFrom(
                backgroundColor: channel.cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Создать обсуждение'),
            ),
        ],
      ),
    );
  }
}