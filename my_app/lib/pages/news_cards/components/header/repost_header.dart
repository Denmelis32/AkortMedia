// 🔄 КОМПОНЕНТ ШАПКИ РЕПОСТА
// Отображает информацию о том, кто репостнул и оригинальный пост

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../../utils/image_utils.dart';
import '../../utils/layout_utils.dart';

class RepostHeader extends StatelessWidget {
  final Map<String, dynamic> news;
  final VoidCallback onUserProfile;
  final Function(String) onMenuPressed;
  final String Function(String) getTimeAgo;

  const RepostHeader({
    super.key,
    required this.news,
    required this.onUserProfile,
    required this.onMenuPressed,
    required this.getTimeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 📊 ДАННЫЕ РЕПОСТА
    final repostedByName = _getStringValue(news['reposted_by_name']);
    final createdAt = _getStringValue(news['created_at']);
    final repostComment = _getStringValue(news['repost_comment']);
    final hasRepostComment = repostComment.isNotEmpty;

    // 🖼️ АВАТАРКА ТОГО, КТО РЕПОСТНУЛ
    final isCurrentUser = repostedByName == userProvider.userName;
    final reposterAvatarUrl = ImageUtils.getUserAvatarUrl(
      news: news,
      userName: repostedByName,
      isCurrentUser: isCurrentUser,
    );

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
                // 🖼️ АВАТАРКА РЕПОСТЕРА
                ImageUtils.buildUserAvatarWidget(
                  avatarUrl: reposterAvatarUrl,
                  displayName: repostedByName,
                  size: LayoutUtils.getAvatarSize(context),
                  onTap: onUserProfile,
                ),

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
                      _buildRepostMetaInfo(createdAt),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 💬 КОММЕНТАРИЙ РЕПОСТА (если есть)
          if (hasRepostComment)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 52), // 40 + 12
              child: Text(
                repostComment,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 📊 СОЗДАЕТ МЕТА-ИНФОРМАЦИЮ РЕПОСТА
  Widget _buildRepostMetaInfo(String createdAt) {
    return Row(
      children: [
        // ⏰ ВРЕМЯ РЕПОСТА
        Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          getTimeAgo(createdAt),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 8),
        Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle)),
        const SizedBox(width: 8),

        // 🔄 ИКОНКА РЕПОСТА
        Icon(Icons.repeat_rounded, size: 12, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          'репостнул',
          style: TextStyle(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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