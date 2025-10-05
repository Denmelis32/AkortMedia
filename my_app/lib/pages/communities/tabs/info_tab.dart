import 'package:flutter/material.dart';
import '../models/community.dart';
import '../widgets/info_section.dart';
import '../widgets/stat_card.dart';


class InfoTab extends StatelessWidget {
  final Community community;

  const InfoTab({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSection(
            title: 'О сообществе',
            icon: Icons.info_rounded,
            color: Colors.blue,
            children: [
              _buildInfoRow(
                icon: Icons.person_rounded,
                title: 'Создатель',
                value: community.creatorName,
              ),
              _buildInfoRow(
                icon: Icons.calendar_today_rounded,
                title: 'Создано',
                value: community.formattedCreatedAt,
              ),
              _buildInfoRow(
                icon: Icons.category_rounded,
                title: 'Категория',
                value: community.category,
              ),
            ],
          ),

          const SizedBox(height: 20),

          InfoSection(
            title: 'Статистика',
            icon: Icons.analytics_rounded,
            color: Colors.green,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatCard(
                    value: community.stats.totalMessages.toString(),
                    label: 'Всего сообщений',
                    icon: Icons.chat_rounded,
                    color: Colors.blue,
                  ),
                  StatCard(
                    value: community.stats.dailyActiveUsers.toString(),
                    label: 'Активных сегодня',
                    icon: Icons.trending_up_rounded,
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),

          if (community.rules != null) ...[
            const SizedBox(height: 20),
            InfoSection(
              title: 'Правила сообщества',
              icon: Icons.rule_rounded,
              color: Colors.orange,
              children: [
                Text(community.rules!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}