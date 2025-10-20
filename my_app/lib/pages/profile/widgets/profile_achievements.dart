import 'package:flutter/material.dart';

class ProfileAchievements extends StatelessWidget {
  final Map<String, dynamic> achievements;
  final double contentMaxWidth;
  final Color userColor;

  const ProfileAchievements({
    super.key,
    required this.achievements,
    required this.contentMaxWidth,
    required this.userColor,
  });

  @override
  Widget build(BuildContext context) {
    final achievedCount = achievements.values.where((achieved) => achieved == true).length;
    final totalCount = achievements.length;

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
                Icon(Icons.emoji_events_rounded, color: userColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Достижения',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '$achievedCount/$totalCount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
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
              child: Column(
                children: [
                  _buildAchievementRow(
                    'Первый пост',
                    'Опубликуйте свой первый пост',
                    achievements['first_post'] ?? false,
                    Icons.create_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementRow(
                    'Популярный автор',
                    'Соберите 100 лайков',
                    achievements['popular_author'] ?? false,
                    Icons.trending_up_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementRow(
                    'Активный комментатор',
                    'Оставьте 50 комментариев',
                    achievements['active_commenter'] ?? false,
                    Icons.chat_bubble_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementRow(String title, String description, bool achieved, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: achieved ? userColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: achieved ? userColor : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: achieved ? Colors.black87 : Colors.grey[600],
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Icon(
          achieved ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: achieved ? Colors.green : Colors.grey[400],
          size: 20,
        ),
      ],
    );
  }
}