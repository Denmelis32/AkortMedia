import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/news_theme.dart';

class AddNewsDialog extends StatefulWidget {
  final Function(String, String, String) onAddNews;

  const AddNewsDialog({super.key, required this.onAddNews});

  @override
  State<AddNewsDialog> createState() => _AddNewsDialogState();
}

class _AddNewsDialogState extends State<AddNewsDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();

  // Статический градиент (не меняется)
  final List<Color> _currentGradient = [const Color(0xFF667eea), const Color(0xFF764ba2)];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _descriptionController.text.isNotEmpty &&
        _descriptionController.text.length <= 240;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: NewsTheme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Градиентная полоса сверху - ТЕПЕРЬ ВНУТРИ ClipRRect
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _currentGradient),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Заголовок
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _currentGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.add_circle_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Создать новость',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: NewsTheme.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Поделитесь чем-то интересным с сообществом',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: NewsTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Поле заголовка
                          _buildTextField(
                            label: 'Заголовок (необязательно)',
                            hintText: 'Введите заголовок новости...',
                            controller: _titleController,
                            maxLines: 2,
                            maxLength: 20,
                            gradient: _currentGradient,
                            optional: true,
                          ),
                          const SizedBox(height: 16),

                          // Поле описания
                          _buildTextField(
                            label: 'Описание * (до 240 символов)',
                            hintText: 'О чем хотите рассказать?...',
                            controller: _descriptionController,
                            maxLines: 4,
                            maxLength: 240,
                            gradient: _currentGradient,
                            showCounter: true,
                          ),
                          const SizedBox(height: 16),

                          // Поле хештегов
                          _buildTextField(
                            label: 'Хештеги (через пробел, необязательно)',
                            hintText: 'спорт новости технологии',
                            controller: _hashtagsController,
                            gradient: _currentGradient,
                            prefixIcon: Icons.tag_rounded,
                            optional: true,
                          ),
                          const SizedBox(height: 20),

                          // Информационная панель
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Символов:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: NewsTheme.secondaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      '${_descriptionController.text.length}/240',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _descriptionController.text.length <= 240
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      isValid
                                          ? Icons.check_circle_rounded
                                          : Icons.info_rounded,
                                      size: 16,
                                      color: isValid
                                          ? Colors.green
                                          : NewsTheme.secondaryTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _descriptionController.text.isEmpty
                                            ? 'Введите описание новости'
                                            : _descriptionController.text.length > 240
                                            ? 'Превышен лимит символов'
                                            : 'Готово к публикации',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isValid
                                              ? Colors.green
                                              : NewsTheme.secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // Кнопки действий - ВНЕ ПРОКРУТКИ
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NewsTheme.secondaryTextColor,
                            side: BorderSide(
                              color: NewsTheme.secondaryTextColor.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValid
                                ? _currentGradient[0]
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: isValid ? 4 : 0,
                          ),
                          onPressed: isValid
                              ? () {
                            widget.onAddNews(
                              _titleController.text.trim(),
                              _descriptionController.text.trim(),
                              _hashtagsController.text.trim(),
                            );
                            Navigator.pop(context);
                          }
                              : null,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.publish_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Создать'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required List<Color> gradient,
    int maxLines = 1,
    int? maxLength,
    bool showCounter = false,
    IconData? prefixIcon,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NewsTheme.textColor,
              ),
            ),
            if (optional) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'необязательно',
                  style: TextStyle(
                    fontSize: 10,
                    color: NewsTheme.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: NewsTheme.textColor, fontSize: 15),
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: NewsTheme.secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gradient[0], width: 2),
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.02),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: gradient[0].withOpacity(0.7))
                : null,
            counterText: showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}

class EditNewsDialog extends StatefulWidget {
  final Map<String, dynamic> news;
  final Function(String, String, String) onEditNews;

  const EditNewsDialog({super.key, required this.news, required this.onEditNews});

  @override
  State<EditNewsDialog> createState() => _EditNewsDialogState();
}

class _EditNewsDialogState extends State<EditNewsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hashtagsController;

  // Статический градиент для редактирования (другой цвет)
  final List<Color> _currentGradient = [const Color(0xFF4facfe), const Color(0xFF00f2fe)];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.news['description'] ?? '');
    _hashtagsController = TextEditingController(
      text: (widget.news['hashtags'] is List
          ? (widget.news['hashtags'] as List).join(' ')
          : widget.news['hashtags']?.toString() ?? ''),
    );

    _descriptionController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _descriptionController.text.isNotEmpty &&
        _descriptionController.text.length <= 240;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: NewsTheme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Градиентная полоса сверху - ТЕПЕРЬ ВНУТРИ ClipRRect
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _currentGradient),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _currentGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Редактировать новость',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: NewsTheme.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Внесите необходимые изменения',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: NewsTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildTextField(
                            label: 'Заголовок (необязательно)',
                            hintText: 'Введите заголовок новости...',
                            controller: _titleController,
                            maxLines: 2,
                            maxLength: 20,
                            gradient: _currentGradient,
                            optional: true,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            label: 'Описание * (до 240 символов)',
                            hintText: 'Введите текст новости...',
                            controller: _descriptionController,
                            maxLines: 4,
                            maxLength: 240,
                            gradient: _currentGradient,
                            showCounter: true,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            label: 'Хештеги (через пробел, необязательно)',
                            hintText: 'спорт новости технологии',
                            controller: _hashtagsController,
                            gradient: _currentGradient,
                            prefixIcon: Icons.tag_rounded,
                            optional: true,
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Символов:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: NewsTheme.secondaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      '${_descriptionController.text.length}/240',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _descriptionController.text.length <= 240
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      isValid
                                          ? Icons.check_circle_rounded
                                          : Icons.info_rounded,
                                      size: 16,
                                      color: isValid
                                          ? Colors.green
                                          : NewsTheme.secondaryTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _descriptionController.text.isEmpty
                                            ? 'Введите описание новости'
                                            : _descriptionController.text.length > 240
                                            ? 'Превышен лимит символов'
                                            : 'Готово к сохранению',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isValid
                                              ? Colors.green
                                              : NewsTheme.secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // Кнопки действий - ВНЕ ПРОКРУТКИ
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NewsTheme.secondaryTextColor,
                            side: BorderSide(
                              color: NewsTheme.secondaryTextColor.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValid
                                ? _currentGradient[0]
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: isValid ? 4 : 0,
                          ),
                          onPressed: isValid
                              ? () {
                            widget.onEditNews(
                              _titleController.text.trim(),
                              _descriptionController.text.trim(),
                              _hashtagsController.text.trim(),
                            );
                            Navigator.pop(context);
                          }
                              : null,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Сохранить'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required List<Color> gradient,
    int maxLines = 1,
    int? maxLength,
    bool showCounter = false,
    IconData? prefixIcon,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NewsTheme.textColor,
              ),
            ),
            if (optional) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'необязательно',
                  style: TextStyle(
                    fontSize: 10,
                    color: NewsTheme.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: NewsTheme.textColor, fontSize: 15),
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: NewsTheme.secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gradient[0], width: 2),
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.02),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: gradient[0].withOpacity(0.7))
                : null,
            counterText: showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: NewsTheme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Красная полоса сверху - ТЕПЕРЬ ВНУТРИ ClipRRect
                Container(
                  height: 6,
                  width: double.infinity,
                  color: Colors.red,
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 36,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Удалить новость?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: NewsTheme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Это действие нельзя отменить. Новость будет удалена безвозвратно.',
                        style: TextStyle(
                          fontSize: 14,
                          color: NewsTheme.secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: NewsTheme.secondaryTextColor,
                                side: BorderSide(
                                  color: NewsTheme.secondaryTextColor.withOpacity(0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Отмена'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text('Удалить'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}