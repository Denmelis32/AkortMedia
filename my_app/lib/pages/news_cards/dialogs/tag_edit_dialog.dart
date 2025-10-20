// 🏷️ ДИАЛОГ РЕДАКТИРОВАНИЯ ТЕГА
// Позволяет пользователю изменить название и цвет персонального тега

import 'package:flutter/material.dart';
import '../../../providers/user_tags_provider.dart';
import '../models/news_card_models.dart';

class TagEditDialog extends StatefulWidget {
  final String initialTagName;
  final String tagId;
  final Color initialColor;
  final Map<String, dynamic> news;
  final UserTagsProvider? userTagsProvider;
  final CardDesign cardDesign;

  const TagEditDialog({
    super.key,
    required this.initialTagName,
    required this.tagId,
    required this.initialColor,
    required this.news,
    this.userTagsProvider,
    required this.cardDesign,
  });

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends State<TagEditDialog> {
  final TextEditingController _tagEditController = TextEditingController();
  late Color _selectedColor;
  late bool _updateGlobally;

  @override
  void initState() {
    super.initState();
    _tagEditController.text = widget.initialTagName;
    _selectedColor = widget.initialColor;
    _updateGlobally = true;

    // ✅ ИНИЦИАЛИЗИРУЕМ ТЕГИ ДЛЯ ПОСТА ПРИ ОТКРЫТИИ ДИАЛОГА
    _initializeTagsForPost();
  }

  /// 🎯 ИНИЦИАЛИЗАЦИЯ ТЕГОВ ДЛЯ ПОСТА
  void _initializeTagsForPost() async {
    final postId = _getStringValue(widget.news['id']);

    if (widget.userTagsProvider != null && postId.isNotEmpty) {
      try {
        await widget.userTagsProvider!.initializeTagsForNewPost(postId);
        print('✅ TagEditDialog: теги инициализированы для поста $postId');
      } catch (e) {
        print('❌ TagEditDialog: ошибка инициализации тегов для поста $postId: $e');
      }
    }
  }

  @override
  void dispose() {
    _tagEditController.dispose();
    super.dispose();
  }

  /// 🎯 ПРОВЕРЯЕТ ДОСТУПНОСТЬ КНОПКИ СОХРАНЕНИЯ
  bool get _isSaveEnabled {
    return _tagEditController.text.trim().isNotEmpty;
  }

  /// 💾 ОБРАБОТЧИК СОХРАНЕНИЯ ТЕГА
  void _handleSave() {
    if (!_isSaveEnabled) return;

    final text = _tagEditController.text.trim();
    final postId = _getStringValue(widget.news['id']);

    if (widget.userTagsProvider != null) {
      widget.userTagsProvider!.updateTagForPost(
        postId: postId,
        tagId: widget.tagId,
        newName: text,
        color: _selectedColor,
        updateGlobally: _updateGlobally,
        context: context,
      );
    }

    Navigator.pop(context);

    // 🔔 ПОКАЗЫВАЕМ УВЕДОМЛЕНИЕ
    _showSuccessSnackBar();
  }

  /// 🔔 ПОКАЗЫВАЕТ УВЕДОМЛЕНИЕ ОБ УСПЕХЕ
  void _showSuccessSnackBar() {
    final message = _updateGlobally
        ? 'Тег обновлен во всех постах'
        : 'Тег обновлен только в этом посте';

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
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎪 ЗАГОЛОВОК ДИАЛОГА
              _buildDialogHeader(),
              const SizedBox(height: 16),

              // 📝 ПОЛЕ ВВОДА НАЗВАНИЯ ТЕГА
              _buildTagNameInput(),
              const SizedBox(height: 20),

              // 🎨 ВЫБОР ЦВЕТА
              _buildColorSelection(),
              const SizedBox(height: 20),

              // 🌍 НАСТРОЙКА ОБЛАСТИ ПРИМЕНЕНИЯ
              _buildGlobalUpdateSetting(),
              const SizedBox(height: 24),

              // 🎯 КНОПКИ ДЕЙСТВИЙ
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎪 СОЗДАЕТ ЗАГОЛОВОК ДИАЛОГА
  Widget _buildDialogHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.cardDesign.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        const Text(
          'Редактировать персональный тег',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  /// 📝 СОЗДАЕТ ПОЛЕ ВВОДА НАЗВАНИЯ ТЕГА
  Widget _buildTagNameInput() {
    return TextField(
      controller: _tagEditController,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Название тега',
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: widget.cardDesign.accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onChanged: (text) => setState(() {}),
    );
  }

  /// 🎨 СОЗДАЕТ ВЫБОР ЦВЕТА
  Widget _buildColorSelection() {
    final availableColors = widget.userTagsProvider?.availableColors ?? _getDefaultColors();

    return Column(
      children: [
        const Text(
          'Выберите цвет:',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedColor == color ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _selectedColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 🌍 СОЗДАЕТ НАСТРОЙКУ ОБЛАСТИ ПРИМЕНЕНИЯ
  Widget _buildGlobalUpdateSetting() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sync_rounded,
                color: _updateGlobally ? widget.cardDesign.accentColor : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Обновить во всех постах',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: _updateGlobally,
                onChanged: (value) => setState(() => _updateGlobally = value),
                activeColor: widget.cardDesign.accentColor,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎯 СОЗДАЕТ КНОПКИ ДЕЙСТВИЙ
  Widget _buildActionButtons() {
    return Row(
      children: [
        // ❌ КНОПКА ОТМЕНЫ
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
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

        // 💾 КНОПКА СОХРАНЕНИЯ
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaveEnabled ? _handleSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.cardDesign.accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: widget.cardDesign.accentColor.withOpacity(0.4),
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  /// 🎨 ПОЛУЧАЕТ ДЕФОЛТНЫЕ ЦВЕТА
  List<Color> _getDefaultColors() {
    return const [
      Color(0xFF667eea),
      Color(0xFF4facfe),
      Color(0xFFfa709a),
      Color(0xFF8E2DE2),
      Color(0xFF3A1C71),
      Color(0xFF43e97b),
      Color(0xFFf093fb),
      Color(0xFF30cfd0),
    ];
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }
}