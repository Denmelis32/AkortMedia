// 🔄 КОМПОНЕНТ КОНТЕНТА РЕПОСТА
// Элегантный дизайн с внутренней вертикальной линией

import 'package:flutter/material.dart';
import '../../models/news_card_enums.dart';
import '../../models/news_card_models.dart';
import '../../utils/image_utils.dart';
import '../../utils/layout_utils.dart';

class RepostContent extends StatelessWidget {
  final Map<String, dynamic> news;
  final CardDesign cardDesign;
  final ContentType contentType;

  const RepostContent({
    super.key,
    required this.news,
    required this.cardDesign,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    // 📊 ДАННЫЕ ОРИГИНАЛЬНОГО ПОСТА
    final originalAuthorName = _getStringValue(news['original_author_name']);
    final originalChannelName = _getStringValue(news['original_channel_name']);
    final isOriginalChannelPost = _getBoolValue(news['is_original_channel_post']);
    final originalCreatedAt = _getStringValue(news['original_created_at']);

    // 📝 КОНТЕНТ ОРИГИНАЛЬНОГО ПОСТА
    final title = _getStringValue(news['title']);
    final description = _getStringValue(news['description']);
    final hashtags = _parseHashtags(news['hashtags']);

    // 🎯 ОПРЕДЕЛЯЕМ ОТОБРАЖАЕМОЕ ИМЯ
    final displayName = isOriginalChannelPost && originalChannelName.isNotEmpty
        ? originalChannelName
        : originalAuthorName;

    final contentColor = LayoutUtils.getContentColor(contentType, cardDesign);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: _getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 📝 КОНТЕНТ ОРИГИНАЛЬНОГО ПОСТА С ОТСТУПОМ ДЛЯ ЛИНИИ
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 20, top: 20, bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🌈 ВЕРТИКАЛЬНАЯ ЛИНИЯ ВНУТРИ СЕКЦИИ
                Container(
                  width: 3,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        contentColor.withOpacity(0.8),
                        contentColor.withOpacity(0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // 📝 ОСНОВНОЙ КОНТЕНТ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👤 ШАПКА ОРИГИНАЛЬНОГО АВТОРА
                      _buildOriginalAuthorHeader(
                        displayName: displayName,
                        isOriginalChannelPost: isOriginalChannelPost,
                        originalCreatedAt: originalCreatedAt,
                        contentColor: contentColor,
                      ),

                      const SizedBox(height: 16),

                      // 📰 ЗАГОЛОВОК ОРИГИНАЛЬНОГО ПОСТА
                      if (title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: LayoutUtils.getTitleFontSize(context) + 1,
                              fontWeight: FontWeight.w700,
                              color: _getTextColor(context),
                              height: 1.3,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),

                      // 📝 ТЕКСТ ОРИГИНАЛЬНОГО ПОСТА
                      if (description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: LayoutUtils.getDescriptionFontSize(context),
                              color: _getTextColor(context).withOpacity(0.8),
                              height: 1.5,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),

                      // #️⃣ ХЕШТЕГИ ОРИГИНАЛЬНОГО ПОСТА (ОРИГИНАЛЬНЫЙ ДИЗАЙН)
                      if (hashtags.isNotEmpty)
                        _buildHashtags(hashtags, contentColor),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🎀 ДЕКОРАТИВНЫЙ ЭЛЕМЕНТ В ВЕРХНЕМ ПРАВОМ УГЛУ
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: contentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Icon(
                Icons.repeat_rounded,
                size: 12,
                color: contentColor.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 👤 СОЗДАЕТ ШАПКУ ОРИГИНАЛЬНОГО АВТОРА
  Widget _buildOriginalAuthorHeader({
    required String displayName,
    required bool isOriginalChannelPost,
    required String originalCreatedAt,
    required Color contentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🖼️ АВАТАР С ТОНКОЙ ОБВОДКОЙ
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: contentColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: _buildOriginalAuthorAvatar(
            displayName: displayName,
            isChannel: isOriginalChannelPost,
          ),
        ),

        const SizedBox(width: 12),

        // 📝 ИНФОРМАЦИЯ ОБ АВТОРЕ
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📛 ИМЯ АВТОРА/КАНАЛА
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: _getTextColor(null),
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 6),

              // 📊 МЕТА-ИНФОРМАЦИЯ
              _buildOriginalPostMetaInfo(
                isOriginalChannelPost: isOriginalChannelPost,
                originalCreatedAt: originalCreatedAt,
                contentColor: contentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🖼️ СОЗДАЕТ АВАТАР ОРИГИНАЛЬНОГО АВТОРА
  Widget _buildOriginalAuthorAvatar({
    required String displayName,
    required bool isChannel,
  }) {
    final avatarUrl = ImageUtils.getUserAvatarUrl(
      news: news,
      userName: displayName,
      isOriginalPost: true,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ImageUtils.buildUserAvatarWidget(
        avatarUrl: avatarUrl,
        displayName: displayName,
        size: 40,
        onTap: () {
          // TODO: Добавить переход к профилю оригинального автора
          print('👤 Переход к профилю: $displayName');
        },
      ),
    );
  }

  /// 📊 СОЗДАЕТ МЕТА-ИНФОРМАЦИЮ ОРИГИНАЛЬНОГО ПОСТА
  Widget _buildOriginalPostMetaInfo({
    required bool isOriginalChannelPost,
    required String originalCreatedAt,
    required Color contentColor,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // ⏰ ВРЕМЯ ОРИГИНАЛЬНОГО ПОСТА
        if (originalCreatedAt.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                _getTimeAgo(originalCreatedAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

        // 🏷️ ТИП АВТОРА (КАНАЛ ИЛИ ПОЛЬЗОВАТЕЛЬ)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOriginalChannelPost
                ? Colors.blue.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isOriginalChannelPost
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOriginalChannelPost ? Icons.record_voice_over_rounded : Icons.person_rounded,
                size: 10,
                color: isOriginalChannelPost ? Colors.blue : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                isOriginalChannelPost ? 'Канал' : 'Пользователь',
                style: TextStyle(
                  color: isOriginalChannelPost ? Colors.blue : Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// #️⃣ СОЗДАЕТ ВИДЖЕТЫ ХЕШТЕГОВ (ОРИГИНАЛЬНЫЙ ДИЗАЙН)
  Widget _buildHashtags(List<String> hashtags, Color contentColor) {
    final cleanedHashtags = _cleanHashtags(hashtags);
    if (cleanedHashtags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cleanedHashtags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: contentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: contentColor.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: contentColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 🎨 ЦВЕТ ФОНА КАРТОЧКИ
  Color _getCardBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? Colors.grey.withOpacity(0.08)
        : Colors.grey.withOpacity(0.12);
  }

  /// 🎨 ЦВЕТ ТЕКСТА
  Color _getTextColor(BuildContext? context) {
    if (context == null) return Colors.black87;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? Colors.black87 : Colors.white70;
  }

  /// ⏰ ФОРМАТИРУЕТ ВРЕМЯ
  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'только что';
      if (difference.inMinutes < 60) return '${difference.inMinutes} мин';
      if (difference.inHours < 24) return '${difference.inHours} ч';
      if (difference.inDays < 7) return '${difference.inDays} д';

      return '${difference.inDays ~/ 7} нед';
    } catch (e) {
      return 'недавно';
    }
  }

  /// 🧹 ОЧИЩАЕТ ХЕШТЕГИ
  List<String> _cleanHashtags(List<String> hashtags) {
    final cleanedTags = <String>[];

    for (var tag in hashtags) {
      var cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
      cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');

      if (cleanTag.isNotEmpty && !cleanedTags.contains(cleanTag)) {
        cleanedTags.add(cleanTag);
      }
    }

    return cleanedTags;
  }

  /// 📋 ПАРСИТ ХЕШТЕГИ
  List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is List) {
      return List<String>.from(hashtags).map((tag) => tag.toString().trim()).where((tag) => tag.isNotEmpty).toList();
    }
    if (hashtags is String) {
      return hashtags.split(RegExp(r'[,\s]+')).map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
    }
    return [];
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