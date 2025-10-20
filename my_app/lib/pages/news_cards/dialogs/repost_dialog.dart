// 🔄 ДИАЛОГ РЕПОСТА С КОММЕНТАРИЕМ
// Позволяет пользователю добавить комментарий при репосте

import 'package:flutter/material.dart';
import '../models/news_card_models.dart';

class RepostWithCommentDialog extends StatefulWidget {
  final CardDesign cardDesign;
  final Function(String) onRepost;

  const RepostWithCommentDialog({
    super.key,
    required this.cardDesign,
    required this.onRepost,
  });

  @override
  State<RepostWithCommentDialog> createState() => _RepostWithCommentDialogState();
}

class _RepostWithCommentDialogState extends State<RepostWithCommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isDialogProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  /// 🎯 ПРОВЕРЯЕТ ДОСТУПНОСТЬ КНОПКИ ОТПРАВКИ
  bool get _isButtonEnabled {
    return _commentController.text.trim().isNotEmpty && !_isDialogProcessing;
  }

  /// 📤 ОБРАБОТЧИК РЕПОСТА
  void _handleRepost() {
    if (!_isButtonEnabled) return;

    setState(() {
      _isDialogProcessing = true;
    });

    final commentText = _commentController.text.trim();
    _commentFocusNode.unfocus();

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      if (mounted) {
        Navigator.pop(context);
        widget.onRepost(commentText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🎪 ШАПКА ДИАЛОГА
            _buildDialogHeader(),

            // 📝 СОДЕРЖИМОЕ ДИАЛОГА
            Expanded(
              child: _buildDialogContent(),
            ),

            // 🎯 КНОПКИ ДИАЛОГА
            _buildDialogActions(),
          ],
        ),
      ),
    );
  }

  /// 🎪 СОЗДАЕТ ШАПКУ ДИАЛОГА
  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.cardDesign.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Добавить комментарий к репосту',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 СОЗДАЕТ СОДЕРЖИМОЕ ДИАЛОГА
  Widget _buildDialogContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📋 ОПИСАНИЕ
          Text(
            'Ваш комментарий будет отображаться над репостом',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // ✍️ ПОЛЕ ВВОДА КОММЕНТАРИЯ
          _buildCommentInput(),
          const SizedBox(height: 12),

          // 🔢 СЧЕТЧИК СИМВОЛОВ
          _buildCharacterCounter(),

          // ⏳ ИНДИКАТОР ЗАГРУЗКИ
          if (_isDialogProcessing)
            _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// ✍️ СОЗДАЕТ ПОЛЕ ВВОДА КОММЕНТАРИЯ
  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 140,
          maxHeight: 200,
        ),
        child: TextField(
          controller: _commentController,
          focusNode: _commentFocusNode,
          maxLines: null,
          maxLength: 280,
          onChanged: (text) {
            setState(() {}); // Обновляем состояние при изменении текста
          },
          decoration: InputDecoration(
            hintText: 'Поделитесь своими мыслями...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(20),
            counterStyle: TextStyle(color: Colors.grey[500]),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  /// 🔢 СОЗДАЕТ СЧЕТЧИК СИМВОЛОВ
  Widget _buildCharacterCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_commentController.text.length}/280',
          style: TextStyle(
            color: _commentController.text.length > 250
                ? Colors.orange
                : Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (_commentController.text.length > 250)
          Text(
            'Слишком длинный комментарий',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  /// ⏳ СОЗДАЕТ ИНДИКАТОР ЗАГРУЗКИ
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.cardDesign.gradient[0]),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Создание репоста...',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎯 СОЗДАЕТ КНОПКИ ДЕЙСТВИЙ
  Widget _buildDialogActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // ❌ КНОПКА ОТМЕНЫ
          Expanded(
            child: OutlinedButton(
              onPressed: _isDialogProcessing ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Отмена',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ✅ КНОПКА РЕПОСТА
          Expanded(
            child: ElevatedButton(
              onPressed: _isButtonEnabled ? _handleRepost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.cardDesign.gradient[0],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: widget.cardDesign.gradient[0].withOpacity(0.4),
              ),
              child: _isDialogProcessing
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Репостнуть',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}