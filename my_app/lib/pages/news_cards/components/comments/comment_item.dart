// 💬 КОМПОНЕНТ ОДНОГО КОММЕНТАРИЯ
// Отображает отдельный комментарий с аватаркой, именем автора и текстом

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../../models/news_card_models.dart';
import '../../utils/image_utils.dart';

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final CardDesign cardDesign;

  const CommentItem({
    super.key,
    required this.comment,
    required this.cardDesign,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 📊 ПОЛУЧАЕМ ДАННЫЕ КОММЕНТАРИЯ
    final author = _getStringValue(comment['author']);
    final text = _getStringValue(comment['text']);
    final time = _getStringValue(comment['time']);
    final authorAvatar = _getStringValue(comment['author_avatar']);

    // Генерируем ID автора комментария для универсальной системы
    final authorId = _getAuthorId(comment, userProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ АВАТАРКА АВТОРА КОММЕНТАРИЯ С УНИВЕРСАЛЬНОЙ СИСТЕМОЙ
          ImageUtils.buildUserAvatarWidget(
            context: context,
            userId: authorId,
            userName: author,
            size: 44,
          ),

          const SizedBox(width: 16),

          // 📝 СОДЕРЖИМОЕ КОММЕНТАРИЯ
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 ИНФОРМАЦИЯ ОБ АВТОРЕ И ВРЕМЕНИ
                  _buildCommentHeader(author, time),

                  const SizedBox(height: 12),

                  // 📝 ТЕКСТ КОММЕНТАРИЯ
                  _buildCommentText(text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 👤 СОЗДАЕТ ШАПКУ КОММЕНТАРИЯ
  Widget _buildCommentHeader(String author, String time) {
    return Row(
      children: [
        // 📛 ИМЯ АВТОРА
        Text(
          author,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),

        const Spacer(),

        // ⏰ ВРЕМЯ КОММЕНТАРИЯ
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 📝 СОЗДАЕТ ТЕКСТ КОММЕНТАРИЯ
  Widget _buildCommentText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Colors.black87.withOpacity(0.8),
        height: 1.4,
      ),
    );
  }

  /// 🆔 ПОЛУЧАЕТ ID АВТОРА КОММЕНТАРИЯ
  String _getAuthorId(Map<String, dynamic> comment, UserProvider userProvider) {
    final author = _getStringValue(comment['author']);

    // Если комментарий от текущего пользователя, используем его ID
    if (author == userProvider.userName) {
      return userProvider.userId;
    }

    // Для других пользователей генерируем ID из имени
    return 'user_${author.hashCode.abs()}';
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }
}