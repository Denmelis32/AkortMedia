// 🏷️ КОМПОНЕНТ ДЛЯ ОТОБРАЖЕНИЯ ПЕРСОНАЛЬНЫХ ТЕГОВ
// Показывает пользовательские теги и позволяет их редактировать

import 'package:flutter/material.dart';
import '../../../../providers/user_tags_provider.dart';
import '../../dialogs/tag_edit_dialog.dart';
import '../../utils/layout_utils.dart';


class PersonalTagsSection extends StatelessWidget {
  final Map<String, String> userTags;
  final Map<String, dynamic> news;
  final UserTagsProvider? userTagsProvider;
  final bool showOnlyFirstTag;

  const PersonalTagsSection({
    super.key,
    required this.userTags,
    required this.news,
    this.userTagsProvider,
    this.showOnlyFirstTag = false,
  });

  @override
  Widget build(BuildContext context) {
    if (userTags.isEmpty) {
      return const SizedBox.shrink();
    }

    // ✅ Фильтруем теги - убираем пустые
    final filteredTags = _filterEmptyTags(userTags);
    if (filteredTags.isEmpty) {
      return const SizedBox.shrink();
    }

    // ✅ Если нужно показать только первый тег
    final tagsToShow = showOnlyFirstTag
        ? filteredTags.entries.take(1).toList()
        : filteredTags.entries.toList();

    return SizedBox(
      height: 28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: tagsToShow.length,
        itemBuilder: (context, index) {
          final entry = tagsToShow[index];
          final tagId = entry.key;
          final tagName = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              right: 8,
              left: index == 0 ? 0 : 0,
            ),
            child: PersonalTagChip(
              tagId: tagId,
              tagName: tagName,
              news: news,
              userTagsProvider: userTagsProvider,
              isSingleTag: showOnlyFirstTag,
            ),
          );
        },
      ),
    );
  }

  /// 🚫 ФИЛЬТРУЕТ ПУСТЫЕ ТЕГИ
  Map<String, String> _filterEmptyTags(Map<String, String> tags) {
    return Map<String, String>.fromEntries(
      tags.entries.where((entry) =>
      entry.value.isNotEmpty &&
          entry.value != 'Новый тег'
      ),
    );
  }
}

/// 🏷️ КОМПОНЕНТ ОДНОГО ТЕГА
class PersonalTagChip extends StatelessWidget {
  final String tagId;
  final String tagName;
  final Map<String, dynamic> news;
  final UserTagsProvider? userTagsProvider;
  final bool isSingleTag;

  const PersonalTagChip({
    super.key,
    required this.tagId,
    required this.tagName,
    required this.news,
    this.userTagsProvider,
    this.isSingleTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTagColor();

    return GestureDetector(
      onTap: () => _showTagEditDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎨 ТОЧКА ЦВЕТА (только для одиночного тега)
            if (isSingleTag) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],

            // 📝 ТЕКСТ ТЕГА
            Text(
              tagName,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),

            // ✏️ ИКОНКА РЕДАКТИРОВАНИЯ (только для одиночного тега)
            if (isSingleTag) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit_outlined,
                size: 10,
                color: color.withOpacity(0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🎨 ПОЛУЧАЕТ ЦВЕТ ДЛЯ ТЕГА
  Color _getTagColor() {
    final postId = _getStringValue(news['id']);
    final cardDesign = LayoutUtils.getCardDesign(news);

    if (userTagsProvider != null && userTagsProvider!.isInitialized) {
      try {
        final color = userTagsProvider!.getTagColorForPost(postId, tagId);
        if (color != null) {
          return color;
        }
      } catch (e) {
        print('❌ Ошибка получения цвета тега: $e');
      }
    }

    if (news['tag_color'] != null) {
      try {
        return Color(news['tag_color']);
      } catch (e) {
        print('❌ Ошибка парсинга цвета из новости: $e');
      }
    }

    return cardDesign.accentColor;
  }

  /// ✏️ ПОКАЗЫВАЕТ ДИАЛОГ РЕДАКТИРОВАНИЯ ТЕГА
  void _showTagEditDialog(BuildContext context) {
    final postId = _getStringValue(news['id']);
    final cardDesign = LayoutUtils.getCardDesign(news);

    print('📝 Открытие диалога редактирования тега: $tagName ($tagId) для поста $postId');

    showDialog(
      context: context,
      builder: (context) => TagEditDialog(
        initialTagName: tagName,
        tagId: tagId,
        initialColor: _getTagColor(),
        news: news,
        userTagsProvider: userTagsProvider,
        cardDesign: cardDesign,
      ),
    );
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }
}