import 'dart:io';
import 'dart:async';
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
  final TextEditingController _tagsController = TextEditingController();

  String _selectedCategory = 'Тактика';
  String _selectedEmoji = '📊';
  AuthorLevel _selectedAuthorLevel = AuthorLevel.beginner;
  int _charCount = 0;
  bool _isImageLoading = false;
  bool _isImageValid = false;
  List<String> _selectedTags = [];
  String? _imageError;

  // Простые тестовые изображения
  final List<String> _popularImages = [
    'https://avatars.mds.yandex.net/i?id=726f36664cfa9350596fb7856ad6633a2625ef83-9555577-images-thumbs&n=13',
    'https://picsum.photos/500/300?grayscale',
    'https://picsum.photos/500/300?blur=2',
    'https://picsum.photos/500/300?random=1',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
    // Устанавливаем первое изображение по умолчанию
    _imageUrlController.text = _popularImages.first;
    // Помечаем как валидное
    _isImageValid = true;
  }

  Color _getLevelColor(AuthorLevel level) {
    return level == AuthorLevel.expert
        ? const Color(0xFF4FC3F7)
        : const Color(0xFFB0BEC5);
  }

  String _getLevelText(AuthorLevel level) {
    return level == AuthorLevel.expert ? 'ЭКСПЕРТ' : 'НОВИЧОК';
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выберите изображение',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Готовые изображения
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _popularImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _imageUrlController.text = _popularImages[index];
                        setState(() {
                          _isImageValid = true;
                          _isImageLoading = false;
                          _imageError = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _popularImages[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.blue),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Поле для своей ссылки
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Введите URL изображения',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final url = _imageUrlController.text.trim();
                      if (url.isNotEmpty) {
                        // Простая проверка - только начинается с http
                        final isValid = url.startsWith('http');

                        setState(() {
                          _isImageValid = isValid;
                          _imageError = isValid ? null : 'URL должен начинаться с http или https';
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Введите URL изображения')),
                        );
                      }
                    },
                    child: const Text('Применить'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _requiredFieldDecoration(String labelText) {
    return InputDecoration(
      labelText: '$labelText *',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(16),
    );
  }


  void _showPreview() {
    if (_validateForm()) {
      final previewArticle = Article(
        id: 'preview',
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
        authorLevel: _selectedAuthorLevel,
      );

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Предпросмотр статьи',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ArticleCard(
                      article: previewArticle,
                      onTap: () {},
                      onLongPress: () {},
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все обязательные поля корректно'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool _validateForm() {
    // Валидация формы для предпросмотра
    if (_titleController.text.isEmpty || _titleController.text.length < 3) {
      _showValidationError('Заголовок должен содержать минимум 3 символа');
      return false;
    }

    if (_descriptionController.text.isEmpty || _descriptionController.text.length < 10) {
      _showValidationError('Описание должно содержать минимум 10 символов');
      return false;
    }

    if (_contentController.text.isEmpty || _contentController.text.length < 300) {
      _showValidationError('Содержание должно содержать минимум 300 символов');
      return false;
    }

    if (!_isImageValid) {
      _showValidationError(_imageError ?? 'Пожалуйста, введите корректный URL изображения');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Черновик сохранен'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Новая статья',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Уровень автора
                const Text('Уровень автора *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _selectedAuthorLevel = AuthorLevel.beginner),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _selectedAuthorLevel == AuthorLevel.beginner
                              ? _getLevelColor(AuthorLevel.beginner).withOpacity(0.1)
                              : null,
                          side: BorderSide(
                            color: _selectedAuthorLevel == AuthorLevel.beginner
                                ? _getLevelColor(AuthorLevel.beginner)
                                : Colors.grey,
                          ),
                        ),
                        child: Text(_getLevelText(AuthorLevel.beginner)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _selectedAuthorLevel = AuthorLevel.expert),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _selectedAuthorLevel == AuthorLevel.expert
                              ? _getLevelColor(AuthorLevel.expert).withOpacity(0.1)
                              : null,
                          side: BorderSide(
                            color: _selectedAuthorLevel == AuthorLevel.expert
                                ? _getLevelColor(AuthorLevel.expert)
                                : Colors.grey,
                          ),
                        ),
                        child: Text(_getLevelText(AuthorLevel.expert)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Эмодзи и категория
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedEmoji,
                      items: widget.emojis.map((emoji) {
                        return DropdownMenuItem(
                          value: emoji,
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedEmoji = value);
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: widget.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedCategory = value);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Категория *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Изображение
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL изображения *',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isImageLoading
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : _isImageValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.error_outline, color: Colors.red),
                    errorText: _imageError,
                    hintText: 'https://picsum.photos/500/300',
                  ),
                  onChanged: (value) {
                    // Простая проверка - только начинается с http
                    if (value.startsWith('http')) {
                      setState(() {
                        _isImageValid = true;
                        _imageError = null;
                      });
                    } else if (value.isNotEmpty) {
                      setState(() {
                        _isImageValid = false;
                        _imageError = 'URL должен начинаться с http или https';
                      });
                    } else {
                      setState(() {
                        _isImageValid = false;
                        _imageError = 'URL не может быть пустым';
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _showImagePicker,
                  icon: const Icon(Icons.image),
                  label: const Text('Выбрать изображение'),
                ),
                const SizedBox(height: 16),

                // Превью изображения
                if (_imageUrlController.text.isNotEmpty && _isImageValid)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'Не удалось загрузить',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'URL: ${_imageUrlController.text}',
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Заголовок
                TextFormField(
                  controller: _titleController,
                  decoration: _requiredFieldDecoration('Заголовок статьи'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Введите заголовок';
                    if (value.length < 3) return 'Минимум 3 символа';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Описание
                TextFormField(
                  controller: _descriptionController,
                  decoration: _requiredFieldDecoration('Описание'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Введите описание';
                    if (value.length < 10) return 'Минимум 10 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Содержание
                TextFormField(
                  controller: _contentController,
                  decoration: _requiredFieldDecoration('Содержание'),
                  maxLines: 5,
                  onChanged: (value) => setState(() => _charCount = value.length),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Введите содержание';
                    if (value.length < 300) return 'Минимум 300 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text('$_charCount/300 символов'),

                const SizedBox(height: 24),

                // Кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _showPreview,
                      child: const Text('Предпросмотр'),
                    ),
                    ElevatedButton(
                      onPressed: _saveDraft,
                      child: const Text('Черновик'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && _validateForm()) {
                          final article = Article(
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
                            authorLevel: _selectedAuthorLevel,
                          );
                          widget.onArticleAdded(article);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Опубликовать'),
                    ),
                  ],
                ),
              ],
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
    _tagsController.dispose();
    super.dispose();
  }
}