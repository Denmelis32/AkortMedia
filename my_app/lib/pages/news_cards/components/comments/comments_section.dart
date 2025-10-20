// 💬 КОМПОНЕНТ СЕКЦИИ КОММЕНТАРИЕВ
// Отображает список комментариев и поле ввода нового комментария

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/news_card_models.dart';
import 'comment_input.dart';
import 'comment_item.dart';

class CommentsSection extends StatelessWidget {
  final List<dynamic> comments;
  final Function(String, String, String) onComment;
  final TextEditingController commentController;
  final CardDesign cardDesign;

  const CommentsSection({
    super.key,
    required this.comments,
    required this.onComment,
    required this.commentController,
    required this.cardDesign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),

        // 📏 РАЗДЕЛИТЕЛЬНАЯ ЛИНИЯ
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                cardDesign.gradient[0].withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // 📝 СОДЕРЖИМОЕ СЕКЦИИ КОММЕНТАРИЕВ
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            children: [
              // 💬 СПИСОК КОММЕНТАРИЕВ
              if (comments.isNotEmpty) ...[
                ...comments.map((comment) => CommentItem(
                  comment: _convertToMap(comment),
                  cardDesign: cardDesign,
                )),
                const SizedBox(height: 20),
              ],

              // ✍️ ПОЛЕ ВВОДА КОММЕНТАРИЯ
              CommentInput(
                onComment: onComment,
                commentController: commentController,
                cardDesign: cardDesign,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔄 КОНВЕРТИРУЕТ КОММЕНТАРИЙ В MAP
  Map<String, dynamic> _convertToMap(dynamic item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return item.cast<String, dynamic>();
    return {};
  }
}