// 👤 КОМПОНЕНТ ШАПКИ ОБЫЧНОГО ПОСТА
// Отображает аватар, имя автора, время публикации и мета-информацию

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_tags_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../providers/channel_state_provider.dart';
import '../../dialogs/tag_edit_dialog.dart';
import '../../models/news_card_enums.dart';
import '../../utils/image_utils.dart';
import '../../utils/layout_utils.dart';
import '../tags/personal_tags.dart';

class NewsCardHeader extends StatelessWidget {
  final Map<String, dynamic> news;
  final VoidCallback onUserProfile;
  final VoidCallback onChannelTap;
  final Function(String) onMenuPressed;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final UserTagsProvider? userTagsProvider;
  final bool isChannelPost;
  final bool isRepost;
  final String? customAvatarUrl;

  const NewsCardHeader({
    super.key,
    required this.news,
    required this.onUserProfile,
    required this.onChannelTap,
    required this.onMenuPressed,
    required this.formatDate,
    required this.getTimeAgo,
    this.userTagsProvider,
    this.isChannelPost = false,
    this.isRepost = false,
    this.customAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final authorName = _getStringValue(news['author_name']);
    final channelName = _getStringValue(news['channel_name']);
    final channelId = _getStringValue(news['channel_id']);
    final createdAt = _getStringValue(news['created_at']);

    final displayName = isChannelPost && channelName.isNotEmpty ? channelName : authorName;
    final isCurrentUser = authorName == userProvider.userName;

    final avatarUrl = _getAvatarUrl(context, displayName, isCurrentUser);
    final userTags = _getUserTags();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ АВАТАРКА С ВОЗМОЖНОСТЬЮ ПЕРЕХОДА В КАНАЛ
          GestureDetector(
            onTap: isChannelPost ? onChannelTap : onUserProfile,
            child: MouseRegion(
              cursor: isChannelPost ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: ImageUtils.buildUserAvatarWidget(
                avatarUrl: avatarUrl,
                displayName: displayName,
                size: LayoutUtils.getAvatarSize(context),
                onTap: isChannelPost ? onChannelTap : onUserProfile,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 👤 ИМЯ КАНАЛА С ВОЗМОЖНОСТЬЮ ПЕРЕХОДА
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: isChannelPost ? onChannelTap : onUserProfile,
                        child: MouseRegion(
                          cursor: isChannelPost ? SystemMouseCursors.click : SystemMouseCursors.basic,
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: LayoutUtils.getTitleFontSize(context),
                              color: isChannelPost ? Colors.blue.shade700 : Colors.black87, // 🎯 СИНИЙ ЦВЕТ БЕЗ ПОДЧЕРКИВАНИЯ
                              letterSpacing: -0.3,
                              height: 1.1,
                              // ❌ УБРАНО ПОДЧЕРКИВАНИЕ
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    if (!isRepost || displayName == userProvider.userName)
                      _buildMenuButton(context),
                  ],
                ),

                const SizedBox(height: 4),

                _buildMetaInfo(
                  context: context,
                  isRepost: isRepost,
                  isChannelPost: isChannelPost,
                  createdAt: createdAt,
                  userTags: userTags,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🖼️ ПОЛУЧАЕТ АВАТАРКУ С ПРИОРИТЕТОМ КАСТОМНОЙ АВАТАРКИ
  String _getAvatarUrl(BuildContext context, String displayName, bool isCurrentUser) {
    // 1. ПРИОРИТЕТ: кастомная аватарка, переданная из NewsCard
    if (customAvatarUrl != null && customAvatarUrl!.isNotEmpty) {
      return customAvatarUrl!;
    }

    // 2. ДЛЯ КАНАЛЬНЫХ ПОСТОВ: используем ChannelStateProvider
    if (isChannelPost) {
      try {
        final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
        final channelId = _getStringValue(news['channel_id']);

        if (channelId.isNotEmpty) {
          final customAvatar = channelStateProvider.getAvatarForChannel(channelId);
          if (customAvatar != null && customAvatar.isNotEmpty) {
            return customAvatar;
          }
        }

        // Fallback: используем аватар из данных новости
        final channelAvatar = _getStringValue(news['channel_avatar']);
        if (channelAvatar.isNotEmpty) {
          return channelAvatar;
        }
      } catch (e) {
        print('❌ NewsCardHeader: Error getting channel avatar: $e');
      }
    }

    // 3. СТАНДАРТНАЯ ЛОГИКА ДЛЯ ВСЕХ ПОСТОВ
    return ImageUtils.getUserAvatarUrl(
      news: news,
      userName: displayName,
      isCurrentUser: isCurrentUser,
    );
  }

  // 📊 СОЗДАЕТ СЕКЦИЮ МЕТА-ИНФОРМАЦИИ (остается без изменений)
  Widget _buildMetaInfo({
    required BuildContext context,
    required bool isRepost,
    required bool isChannelPost,
    required String createdAt,
    required Map<String, String> userTags,
  }) {
    final hasPersonalTags = userTags.isNotEmpty &&
        userTags.values.any((tag) => tag.isNotEmpty && tag != 'Новый тег') &&
        !isRepost;

    final shouldShowContentType = !isRepost && _shouldShowContentType();

    return Container(
      height: LayoutUtils.getTagsSectionHeight(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ⏰ ВРЕМЯ ПУБЛИКАЦИИ
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  getTimeAgo(createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // 🏷️ ПЕРСОНАЛЬНЫЕ ТЕГИ
            if (hasPersonalTags) ...[
              const SizedBox(width: 12),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    shape: BoxShape.circle
                ),
              ),
              const SizedBox(width: 8),
              PersonalTagsSection(
                userTags: userTags,
                news: news,
                userTagsProvider: userTagsProvider,
                showOnlyFirstTag: true,
              ),
            ],

            // ➕ КНОПКА ДОБАВИТЬ ТЕГ
            if (!hasPersonalTags && !isRepost && !isChannelPost) ...[
              const SizedBox(width: 12),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    shape: BoxShape.circle
                ),
              ),
              const SizedBox(width: 8),
              _buildAddTagButton(context),
            ],

            // 📢 ИНФОРМАЦИЯ О ТИПЕ КОНТЕНТА
            if (!isRepost) ...[
              if (isChannelPost) ...[
                const SizedBox(width: 12),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      shape: BoxShape.circle
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.group_rounded, size: 12, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  'Канал',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700
                  ),
                ),
              ] else if (shouldShowContentType) ...[
                _buildContentTypeInfo(context),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // 🎪 ОПРЕДЕЛЯЕТ НУЖНО ЛИ ПОКАЗЫВАТЬ ТИП КОНТЕНТА (остается без изменений)
  bool _shouldShowContentType() {
    final contentType = LayoutUtils.getContentType(news);
    return contentType != ContentType.general;
  }

  // 🎪 СОЗДАЕТ ИНФОРМАЦИЮ О ТИПЕ КОНТЕНТА (остается без изменений)
  Widget _buildContentTypeInfo(BuildContext context) {
    final contentType = LayoutUtils.getContentType(news);
    final contentColor = LayoutUtils.getContentColor(contentType, LayoutUtils.getCardDesign(news));
    final contentIcon = LayoutUtils.getContentIcon(contentType);
    final contentTypeText = LayoutUtils.getContentTypeText(contentType);

    return Row(
      children: [
        const SizedBox(width: 12),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              shape: BoxShape.circle
          ),
        ),
        const SizedBox(width: 8),
        Icon(contentIcon, size: 12, color: contentColor),
        const SizedBox(width: 4),
        Text(
          contentTypeText,
          style: TextStyle(
            color: contentColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ➕ СОЗДАЕТ КНОПКУ "ДОБАВИТЬ ТЕГ" (остается без изменений)
  Widget _buildAddTagButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('➕ Добавить тег');
        _showAddTagDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'добавить тег',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎪 ПОКАЗЫВАЕТ ДИАЛОГ ДОБАВЛЕНИЯ ТЕГА (остается без изменений)
  void _showAddTagDialog(BuildContext context) {
    final postId = _getStringValue(news['id']);
    final cardDesign = LayoutUtils.getCardDesign(news);

    print('➕ Открытие диалога добавления тега для поста $postId');

    showDialog(
      context: context,
      builder: (context) => TagEditDialog(
        initialTagName: 'Новый тег',
        tagId: 'tag1',
        initialColor: cardDesign.accentColor,
        news: news,
        userTagsProvider: userTagsProvider,
        cardDesign: cardDesign,
      ),
    );
  }

  // 🎯 СОЗДАЕТ КНОПКУ МЕНЮ (остается без изменений)
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

  // 🏷️ ПОЛУЧАЕТ ПЕРВЫЙ ТЕГ ИЗ ПЕРСОНАЛЬНЫХ ТЕГОВ (остается без изменений)
  Map<String, String> _getUserTags() {
    try {
      final isChannelPost = _getBoolValue(news['is_channel_post']);
      final postId = _getStringValue(news['id']);

      print('🔍 NewsCardHeader - получение тегов:');
      print('   - postId: $postId');
      print('   - isChannelPost: $isChannelPost');
      print('   - isRepost: $isRepost');

      if (isRepost || isChannelPost) {
        return <String, String>{};
      }

      if (userTagsProvider != null && userTagsProvider!.isInitialized) {
        final allTags = userTagsProvider!.getTagsForPost(postId);

        print('✅ Все теги из provider: $allTags');

        final firstNonEmptyTag = allTags.entries
            .firstWhere(
              (entry) => entry.value.isNotEmpty && entry.value != 'Новый тег',
          orElse: () => MapEntry('', ''),
        );

        if (firstNonEmptyTag.key.isNotEmpty) {
          final singleTag = {firstNonEmptyTag.key: firstNonEmptyTag.value};
          print('✅ Показан первый тег: $singleTag');
          return singleTag;
        }

        print('ℹ️ Все теги пустые, показываем кнопку добавления');
        return <String, String>{};
      }

      return <String, String>{};
    } catch (e) {
      print('❌ Ошибка получения тегов: $e');
      return <String, String>{};
    }
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ (остаются без изменений)
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