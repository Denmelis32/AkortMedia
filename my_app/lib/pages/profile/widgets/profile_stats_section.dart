import 'package:flutter/material.dart';

class ProfileStatsSection extends StatelessWidget {
  final Map<String, int> stats;
  final double contentMaxWidth;
  final Color userColor;
  final Function(String)? onStatsTap;

  const ProfileStatsSection({
    super.key,
    required this.stats,
    required this.contentMaxWidth,
    required this.userColor,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: contentMaxWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.analytics_rounded, color: userColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Статистика профиля',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${stats['posts'] ?? 0}', 'Постов', Icons.article_rounded, 'posts'),
                  _buildStatItem('${stats['likes'] ?? 0}', 'Лайков', Icons.favorite_rounded, 'likes'),
                  _buildStatItem('${stats['comments'] ?? 0}', 'Комментариев', Icons.chat_rounded, 'comments'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, String statType) {
    return GestureDetector(
      onTap: () => onStatsTap?.call(statType),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: userColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: userColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}