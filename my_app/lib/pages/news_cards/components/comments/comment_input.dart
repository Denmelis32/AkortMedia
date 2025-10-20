// ✍️ КОМПОНЕНТ ПОЛЯ ВВОДА КОММЕНТАРИЯ
// Поле для ввода нового комментария с кнопкой отправки

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../../models/news_card_models.dart';
import '../../utils/image_utils.dart';

class CommentInput extends StatelessWidget {
  final Function(String, String, String) onComment;
  final TextEditingController commentController;
  final CardDesign cardDesign;

  const CommentInput({
    super.key,
    required this.onComment,
    required this.commentController,
    required this.cardDesign,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 🖼️ АВАТАРКА ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ
    final currentUserAvatar = ImageUtils.getUserAvatarUrl(
      news: {},
      userName: userProvider.userName,
      isCurrentUser: true,
    );

    return Container(
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
      child: Row(
        children: [
          // 🖼️ АВАТАРКА ПОЛЬЗОВАТЕЛЯ
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: ImageUtils.buildImageWidget(
                currentUserAvatar,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 📝 ПОЛЕ ВВОДА ТЕКСТА
          Expanded(
            child: TextField(
              controller: commentController,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Напишите комментарий...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSubmitted: (text) => _handleCommentSubmission(
                context,
                text,
                userProvider.userName,
                currentUserAvatar,
              ),
            ),
          ),

          // 📤 КНОПКА ОТПРАВКИ
          _buildSendButton(
            context,
            userProvider.userName,
            currentUserAvatar,
          ),
        ],
      ),
    );
  }

  /// 📤 СОЗДАЕТ КНОПКУ ОТПРАВКИ КОММЕНТАРИЯ
  Widget _buildSendButton(BuildContext context, String userName, String userAvatar) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardDesign.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: cardDesign.gradient[0].withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
        onPressed: () => _handleCommentButtonPress(
          context,
          userName,
          userAvatar,
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  /// 🎯 ОБРАБОТЧИК НАЖАТИЯ КНОПКИ ОТПРАВКИ
  void _handleCommentButtonPress(BuildContext context, String userName, String userAvatar) {
    final text = commentController.text.trim();
    if (text.isNotEmpty) {
      _submitComment(context, text, userName, userAvatar);
    }
  }

  /// 🎯 ОБРАБОТЧИК ОТПРАВКИ ЧЕРЕЗ ENTER
  void _handleCommentSubmission(BuildContext context, String text, String userName, String userAvatar) {
    final trimmedText = text.trim();
    if (trimmedText.isNotEmpty) {
      _submitComment(context, trimmedText, userName, userAvatar);
    }
  }

  /// 📤 ОТПРАВЛЯЕТ КОММЕНТАРИЙ И ПОКАЗЫВАЕТ УВЕДОМЛЕНИЕ
  void _submitComment(BuildContext context, String text, String userName, String userAvatar) {
    // 📤 ВЫЗЫВАЕМ КОЛБЭК
    onComment(text, userName, userAvatar);

    // 🧹 ОЧИЩАЕМ ПОЛЕ ВВОДА
    commentController.clear();

    // 🔔 ПОКАЗЫВАЕМ УВЕДОМЛЕНИЕ
    _showSuccessSnackBar(context);
  }

  /// 🔔 ПОКАЗЫВАЕТ УВЕДОМЛЕНИЕ ОБ УСПЕШНОЙ ОТПРАВКЕ
  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 12),
            const Text('Комментарий отправлен'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}