import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';
import '../utils/profile_utils.dart';

class ProfileContentTabs extends StatelessWidget {
  final int selectedSection;
  final double contentMaxWidth;
  final Color userColor;
  final String userEmail;
  final Function(int) onSectionChanged;

  const ProfileContentTabs({
    super.key,
    required this.selectedSection,
    required this.contentMaxWidth,
    required this.userColor,
    required this.userEmail,
    required this.onSectionChanged,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.dynamic_feed_rounded, color: userColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Контент профиля',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: userColor, size: 20),
                  onPressed: () => _onRefreshPressed(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  _buildTab('Мои посты', 0, Icons.article_rounded),
                  _buildTab('Понравилось', 1, Icons.favorite_rounded),
                  _buildTab('Репосты', 2, Icons.repeat_rounded),
                  _buildTab('Информация', 3, Icons.info_rounded),
                ],
              ),
            ),
            _buildRepostStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index, IconData icon) {
    final isActive = selectedSection == index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? userColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [BoxShadow(color: userColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSectionChanged(index),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepostStats(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        final utils = ProfileUtils();
        final userReposts = utils.getUserReposts(newsProvider.news, userEmail);
        final totalReposts = newsProvider.news.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return newsItem['is_repost'] == true;
        }).length;

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Всего репостов в системе: $totalReposts',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                'Ваших репостов: ${userReposts.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: userColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onRefreshPressed(BuildContext context) {
    final utils = ProfileUtils();
    print('🔄 Manual refresh triggered');
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userReposts = utils.getUserReposts(newsProvider.news, userEmail);
    print('📊 Current user reposts: ${userReposts.length}');
  }
}