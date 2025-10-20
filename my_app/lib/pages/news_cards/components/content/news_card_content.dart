// 📝 КОМПОНЕНТ ОСНОВНОГО КОНТЕНТА ПОСТА
// Отображает заголовок, текст и хештеги обычного поста

import 'package:flutter/material.dart';
import '../../models/news_card_enums.dart';
import '../../models/news_card_models.dart';
import '../../utils/layout_utils.dart';

class NewsCardContent extends StatelessWidget {
  final Map<String, dynamic> news;
  final CardDesign cardDesign;
  final ContentType contentType;
  final bool isRepost;
  final String? originalAuthorName;

  const NewsCardContent({
    super.key,
    required this.news,
    required this.cardDesign,
    required this.contentType,
    this.isRepost = false,
    this.originalAuthorName,
  });

  @override
  Widget build(BuildContext context) {
    // 📊 ПОЛУЧАЕМ ДАННЫЕ КОНТЕНТА
    final title = _getStringValue(news['title']);
    final description = _getStringValue(news['description']);
    final hashtags = _parseHashtags(news['hashtags']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📰 ЗАГОЛОВОК ПОСТА (если есть)
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: LayoutUtils.getTitleFontSize(context),
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),

        // 📝 ОСНОВНОЙ ТЕКСТ ПОСТА
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              description,
              style: TextStyle(
                fontSize: LayoutUtils.getDescriptionFontSize(context),
                color: Colors.black87.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),

        // #️⃣ ХЕШТЕГИ (если есть)
        if (hashtags.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _buildHashtags(hashtags),
          ),
        ],
      ],
    );
  }

  /// #️⃣ СОЗДАЕТ ВИДЖЕТЫ ХЕШТЕГОВ
  Widget _buildHashtags(List<String> hashtags) {
    final cleanedHashtags = _cleanHashtags(hashtags);
    if (cleanedHashtags.isEmpty) return const SizedBox.shrink();

    final contentColor = LayoutUtils.getContentColor(contentType, cardDesign);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
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
              height: 1.0,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 🧹 ОЧИЩАЕТ ХЕШТЕГИ ОТ ЛИШНИХ СИМВОЛОВ
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

  /// 📋 ПАРСИТ ХЕШТЕГИ ИЗ РАЗЛИЧНЫХ ФОРМАТОВ
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
  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }
}