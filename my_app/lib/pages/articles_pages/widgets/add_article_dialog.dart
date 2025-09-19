import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_card.dart';

class AddArticleDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> emojis;
  final Function(Article) onArticleAdded;
  final String userName;

  const AddArticleDialog({
    super.key,
    required this.categories,
    required this.emojis,
    required this.onArticleAdded,
    required this.userName,
  });

  @override
  State<AddArticleDialog> createState() => _AddArticleDialogState();
}

class _AddArticleDialogState extends State<AddArticleDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory = 'Тактика';
  String _selectedEmoji = '📊';
  AuthorLevel _selectedAuthorLevel = AuthorLevel.beginner; // Добавлен выбор уровня
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    // Установим значение по умолчанию для изображения
    _imageUrlController.text = 'https://images.unsplash.com/photo-1552667466-07770ae110d0?w=500&h=300&fit=crop';

    // Установим первую категорию из списка как выбранную по умолчанию
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
  }

  // Цвета для уровней авторов
  Color _getLevelColor(AuthorLevel level) {
    return level == AuthorLevel.expert
        ? const Color(0xFF4FC3F7) // Бриллиантовый синий
        : const Color(0xFFB0BEC5); // Серебрянный
  }

  // Иконка уровня автора
  IconData _getLevelIcon(AuthorLevel level) {
    return level == AuthorLevel.expert
        ? Icons.diamond_rounded
        : Icons.auto_awesome_rounded;
  }

  // Текст уровня автора
  String _getLevelText(AuthorLevel level) {
    return level == AuthorLevel.expert
        ? 'ЭКСПЕРТ'
        : 'НОВИЧОК';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Новая статья',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Уровень автора (новый выбор)
                  Text(
                    'Уровень автора',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Кнопка "Новичок"
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAuthorLevel = AuthorLevel.beginner;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedAuthorLevel == AuthorLevel.beginner
                                  ? _getLevelColor(AuthorLevel.beginner).withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedAuthorLevel == AuthorLevel.beginner
                                    ? _getLevelColor(AuthorLevel.beginner)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getLevelIcon(AuthorLevel.beginner),
                                  size: 18,
                                  color: _getLevelColor(AuthorLevel.beginner),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getLevelText(AuthorLevel.beginner),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getLevelColor(AuthorLevel.beginner),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Кнопка "Эксперт"
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAuthorLevel = AuthorLevel.expert;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedAuthorLevel == AuthorLevel.expert
                                  ? _getLevelColor(AuthorLevel.expert).withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedAuthorLevel == AuthorLevel.expert
                                    ? _getLevelColor(AuthorLevel.expert)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getLevelIcon(AuthorLevel.expert),
                                  size: 18,
                                  color: _getLevelColor(AuthorLevel.expert),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getLevelText(AuthorLevel.expert),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getLevelColor(AuthorLevel.expert),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Эмодзи и категория
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedEmoji,
                          items: widget.emojis.map((emoji) {
                            return DropdownMenuItem(
                              value: emoji,
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEmoji = value!;
                            });
                          },
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              items: widget.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Категория',
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // URL изображения
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL изображения',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите URL изображения';
                      }
                      if (!value.startsWith('http')) {
                        return 'Введите корректный URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Заголовок
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Заголовок статьи',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите заголовок статьи';
                      }
                      if (value.length < 10) {
                        return 'Заголовок должен содержать минимум 10 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Описание
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Краткое описание',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите описание статьи';
                      }
                      if (value.length < 20) {
                        return 'Описание должно содержать минимум 20 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Контент
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Содержание статьи',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 6,
                        style: const TextStyle(fontSize: 16),
                        onChanged: (value) {
                          setState(() {
                            _charCount = value.length;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите содержание статьи';
                          }
                          if (value.length < 100) {
                            return 'Статья должна содержать минимум 100 символов';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _charCount / 100,
                              backgroundColor: Colors.grey[300],
                              color: _charCount >= 100
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$_charCount/100',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Минимум 100 символов',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Кнопки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newArticle = Article(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: _titleController.text,
                              description: _descriptionController.text,
                              emoji: _selectedEmoji,
                              content: _contentController.text,
                              views: 0,
                              likes: 0,
                              publishDate: DateTime.now(),
                              category: _selectedCategory,
                              author: widget.userName,
                              imageUrl: _imageUrlController.text,
                              authorLevel: _selectedAuthorLevel,  // Добавлен уровень автора
                            );

                            widget.onArticleAdded(newArticle);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Статья успешно добавлена!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Опубликовать'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}