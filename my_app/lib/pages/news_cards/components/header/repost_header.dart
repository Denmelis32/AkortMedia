// 🔄 КОМПОНЕНТ ШАПКИ РЕПОСТА
// Использует универсальную систему изображений

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../providers/channel_provider/channel_state_provider.dart';
import '../../../../providers/news_providers/news_provider.dart';
import '../../utils/image_utils.dart';
import '../../utils/layout_utils.dart';

class RepostHeader extends StatelessWidget {
  final Map<String, dynamic> news;
  final VoidCallback onUserProfile;
  final VoidCallback onChannelTap;
  final Function(String) onMenuPressed;
  final String Function(String) getTimeAgo;
  final String? customAvatarUrl;

  const RepostHeader({
    super.key,
    required this.news,
    required this.onUserProfile,
    required this.onChannelTap,
    required this.onMenuPressed,
    required this.getTimeAgo,
    this.customAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 📊 ДАННЫЕ РЕПОСТА
    final repostedByName = _getStringValue(news['reposted_by_name']);
    final repostedById = _getStringValue(news['reposted_by']);
    final createdAt = _getStringValue(news['created_at']);
    final repostComment = _getStringValue(news['repost_comment']);
    final hasRepostComment = repostComment.isNotEmpty;

    // 🎯 ПРОВЕРЯЕМ, ЯВЛЯЕТСЯ ЛИ ОРИГИНАЛЬНЫЙ ПОСТ КАНАЛЬНЫМ
    final isOriginalChannelPost = _getBoolValue(news['is_original_channel_post']);
    final originalChannelName = _getStringValue(news['original_channel_name']);
    final originalChannelId = _getStringValue(news['original_channel_id']);

    // 🖼️ АВАТАРКА ТОГО, КТО РЕПОСТНУЛ - ВСЕГДА АВАТАРКА ПОЛЬЗОВАТЕЛЯ
    final isCurrentUser = repostedByName == userProvider.userName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 ИНФОРМАЦИЯ О ТОМ, КТО РЕПОСТНУЛ
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ АВАТАРКА РЕПОСТЕРА (ВСЕГДА ПОЛЬЗОВАТЕЛЬ)
                _buildReposterAvatar(context, repostedByName, repostedById, isCurrentUser),

                const SizedBox(width: 12),

                // 📝 ИНФОРМАЦИЯ О РЕПОСТЕРЕ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👤 ИМЯ И КНОПКА МЕНЮ
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              repostedByName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: LayoutUtils.getTitleFontSize(context),
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // 🎯 КНОПКА МЕНЮ (только если это репост текущего пользователя)
                          if (isCurrentUser)
                            _buildMenuButton(context),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // 📊 МЕТА-ИНФОРМАЦИЯ РЕПОСТА
                      _buildRepostMetaInfo(
                          createdAt,
                          isOriginalChannelPost,
                          originalChannelName,
                          hasRepostComment
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 💬 КОММЕНТАРИЙ РЕПОСТА (если есть)
          if (hasRepostComment)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 52),
              child: Text(
                repostComment,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

          // 🎯 ИНФОРМАЦИЯ ОБ ОРИГИНАЛЬНОМ КАНАЛЕ (если репост из канала)
          if (isOriginalChannelPost && originalChannelName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 52),
              child: GestureDetector(
                onTap: onChannelTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🖼️ СОЗДАЕТ ВИДЖЕТ АВАТАРКИ РЕПОСТЕРА
  Widget _buildReposterAvatar(BuildContext context, String reposterName, String reposterId, bool isCurrentUser) {
    return ImageUtils.buildUserAvatarWidget(
      context: context,
      userId: reposterId,
      userName: reposterName,
      size: LayoutUtils.getAvatarSize(context),
      onTap: onUserProfile,
    );
  }

  /// 📊 СОЗДАЕТ МЕТА-ИНФОРМАЦИЮ РЕПОСТА
  Widget _buildRepostMetaInfo(String createdAt, bool isOriginalChannelPost, String originalChannelName, bool hasRepostComment) {
    return Container(
      height: 16,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ⏰ ВРЕМЯ РЕПОСТА
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  getTimeAgo(createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), shape: BoxShape.circle)),
            const SizedBox(width: 8),

            // 🔄 ИКОНКА РЕПОСТА
            Icon(
                hasRepostComment ? Icons.edit_rounded : Icons.repeat_rounded,
                size: 12,
                color: hasRepostComment ? Colors.blue : Colors.green
            ),
            const SizedBox(width: 4),
            Text(
              hasRepostComment ? 'Репост' : 'Репост',
              style: TextStyle(
                color: hasRepostComment ? Colors.blue : Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),

            // 🎯 ИНФОРМАЦИЯ О КАНАЛЕ (если репост из канала)
            if (isOriginalChannelPost && originalChannelName.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Icon(Icons.group_rounded, size: 12, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                'Канал',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🎯 СОЗДАЕТ КНОПКУ МЕНЮ
  Widget _buildMenuButton(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600], size: 18),
        onSelected: onMenuPressed,
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.share_rounded, color: Colors.blue, size: 14),
                ),
                const SizedBox(width: 12),
                Text('Поделиться', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 160),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }
}