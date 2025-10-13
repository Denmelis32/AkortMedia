import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_card.dart';

// Расширяем типы блоков
enum ContentBlockType { text, image, heading, subheading }

class ContentBlock {
  final ContentBlockType type;
  final String content;

  ContentBlock({required this.type, required this.content});
}

class AddArticlePage extends StatefulWidget {
  final List<String> categories;
  final List<String> emojis;
  final Function(Article) onArticleAdded;
  final String userName;
  final String? userAvatarUrl;

  const AddArticlePage({
    super.key,
    required this.categories,
    required this.emojis,
    required this.onArticleAdded,
    required this.userName,
    this.userAvatarUrl,
  });

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory = 'Программирование';
  String _selectedEmoji = '📊';
  AuthorLevel _selectedAuthorLevel = AuthorLevel.beginner;
  int _charCount = 0;
  bool _isImageLoading = false;
  bool _isImageValid = false;
  String? _imageError;

  final List<String> _popularImages = [
    'https://avatars.mds.yandex.net/i?id=726f36664cfa9350596fb7856ad6633a2625ef83-9555577-images-thumbs&n=13',
    'https://picsum.photos/500/300?grayscale',
    'https://picsum.photos/500/300?blur=2',
    'https://picsum.photos/500/300?random=1',
  ];

  final List<ContentBlock> _contentBlocks = [];

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
    _imageUrlController.text = _popularImages.first;
    _isImageValid = true;
    _contentBlocks.add(ContentBlock(type: ContentBlockType.text, content: ''));
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 16;
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

  // НОВЫЕ МЕТОДЫ ДЛЯ ДОБАВЛЕНИЯ РАЗЛИЧНЫХ БЛОКОВ
  void _addTextBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.text, content: ''));
    });
  }

  void _addHeadingBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.heading, content: ''));
    });
  }

  void _addSubheadingBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.subheading, content: ''));
    });
  }

  void _addImageBlock() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить изображение'),
        content: TextFormField(
          decoration: const InputDecoration(
            labelText: 'URL изображения',
            hintText: 'https://example.com/image.jpg',
          ),
          onChanged: (value) {
            if (value.isNotEmpty && value.startsWith('http')) {
              setState(() {
                _contentBlocks.add(ContentBlock(type: ContentBlockType.image, content: value));
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _removeBlock(int index) {
    setState(() {
      _contentBlocks.removeAt(index);
    });
  }

  void _updateBlockContent(int index, String content) {
    setState(() {
      _contentBlocks[index] = ContentBlock(
        type: _contentBlocks[index].type,
        content: content,
      );
    });
  }

  // ОБНОВЛЕННАЯ ВАЛИДАЦИЯ
  bool _validateForm() {
    if (_titleController.text.isEmpty || _titleController.text.length < 3) {
      _showValidationError('Заголовок должен содержать минимум 3 символа');
      return false;
    }

    if (_subtitleController.text.isEmpty || _subtitleController.text.length < 10) {
      _showValidationError('Подзаголовок должен содержать минимум 10 символов');
      return false;
    }

    if (_descriptionController.text.isEmpty || _descriptionController.text.length < 50) {
      _showValidationError('Описание должно содержать минимум 50 символов');
      return false;
    }

    // Проверяем, что есть хотя бы один текстовый блок с контентом
    final hasContent = _contentBlocks.any((block) =>
    (block.type == ContentBlockType.text ||
        block.type == ContentBlockType.heading ||
        block.type == ContentBlockType.subheading) &&
        block.content.trim().isNotEmpty);

    if (!hasContent) {
      _showValidationError('Добавьте содержание статьи');
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

  void _publishArticle() {
    if (_formKey.currentState!.validate() && _validateForm()) {
      final content = _contentBlocks.map((block) {
        switch (block.type) {
          case ContentBlockType.text:
            return block.content;
          case ContentBlockType.heading:
            return '[HEADING:${block.content}]';
          case ContentBlockType.subheading:
            return '[SUBHEADING:${block.content}]';
          case ContentBlockType.image:
            return '[IMAGE:${block.content}]';
        }
      }).join('\n\n');

      final article = Article(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _subtitleController.text,
        emoji: _selectedEmoji,
        content: content,
        views: 0,
        likes: 0,
        publishDate: DateTime.now(),
        category: _selectedCategory,
        author: widget.userName,
        imageUrl: _imageUrlController.text,
        authorLevel: _selectedAuthorLevel,
      );
      widget.onArticleAdded(article);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Статья "${_titleController.text}" успешно создана!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _requiredFieldDecoration(String labelText) {
    return InputDecoration(
      labelText: '$labelText *',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  // НОВЫЙ МЕТОД: Получение иконки для типа блока
  IconData _getBlockIcon(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.text:
        return Icons.text_fields;
      case ContentBlockType.heading:
        return Icons.title;
      case ContentBlockType.subheading:
        return Icons.subtitles;
      case ContentBlockType.image:
        return Icons.image;
    }
  }

  // НОВЫЙ МЕТОД: Получение цвета для типа блока
  Color _getBlockColor(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.text:
        return Colors.blue;
      case ContentBlockType.heading:
        return Colors.orange;
      case ContentBlockType.subheading:
        return Colors.purple;
      case ContentBlockType.image:
        return Colors.green;
    }
  }

  // НОВЫЙ МЕТОД: Получение названия типа блока
  String _getBlockTypeName(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.text:
        return 'Текст';
      case ContentBlockType.heading:
        return 'Заголовок';
      case ContentBlockType.subheading:
        return 'Подзаголовок';
      case ContentBlockType.image:
        return 'Изображение';
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Создание статьи',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _saveDraft,
                      child: const Text(
                        'Черновик',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ... остальные поля формы остаются без изменений ...
                                const Text(
                                  'Уровень автора *',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
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
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: Text(
                                          _getLevelText(AuthorLevel.beginner),
                                          style: TextStyle(
                                            color: _selectedAuthorLevel == AuthorLevel.beginner
                                                ? _getLevelColor(AuthorLevel.beginner)
                                                : Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: Text(
                                          _getLevelText(AuthorLevel.expert),
                                          style: TextStyle(
                                            color: _selectedAuthorLevel == AuthorLevel.expert
                                                ? _getLevelColor(AuthorLevel.expert)
                                                : Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
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
                                          if (value != null) setState(() => _selectedEmoji = value);
                                        },
                                        underline: const SizedBox(),
                                      ),
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
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _imageUrlController,
                                  decoration: InputDecoration(
                                    labelText: 'URL обложки *',
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
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _showImagePicker,
                                  icon: const Icon(Icons.image),
                                  label: const Text('Выбрать обложку'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[100],
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_imageUrlController.text.isNotEmpty && _isImageValid)
                                  Container(
                                    height: 200,
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
                                const SizedBox(height: 24),
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
                                TextFormField(
                                  controller: _subtitleController,
                                  decoration: _requiredFieldDecoration('Подзаголовок'),
                                  maxLines: 2,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Введите подзаголовок';
                                    if (value.length < 10) return 'Минимум 10 символов';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: _requiredFieldDecoration('Описание статьи'),
                                  maxLines: 3,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Введите описание';
                                    if (value.length < 50) return 'Минимум 50 символов';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // ОБНОВЛЕННЫЙ РАЗДЕЛ СОДЕРЖАНИЯ
                                const Text(
                                  'Содержание статьи *',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Добавляйте различные блоки в нужном порядке:',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // БЛОКИ СОДЕРЖАНИЯ
                                Column(
                                  children: _contentBlocks.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final block = entry.value;
                                    final blockColor = _getBlockColor(block.type);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // ЗАГОЛОВОК БЛОКА С ЦВЕТНЫМ ИНДИКАТОРОМ
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: blockColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: blockColor.withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(_getBlockIcon(block.type), size: 16, color: blockColor),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${_getBlockTypeName(block.type)} ${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: blockColor,
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (_contentBlocks.length > 1)
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                                    onPressed: () => _removeBlock(index),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // ПОЛЕ ВВОДА В ЗАВИСИМОСТИ ОТ ТИПА БЛОКА
                                          if (block.type == ContentBlockType.text)
                                            TextFormField(
                                              initialValue: block.content,
                                              maxLines: 4,
                                              decoration: const InputDecoration(
                                                hintText: 'Введите текст...',
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) => _updateBlockContent(index, value),
                                            )
                                          else if (block.type == ContentBlockType.heading)
                                            TextFormField(
                                              initialValue: block.content,
                                              maxLines: 2,
                                              decoration: const InputDecoration(
                                                hintText: 'Введите заголовок...',
                                                border: OutlineInputBorder(),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              onChanged: (value) => _updateBlockContent(index, value),
                                            )
                                          else if (block.type == ContentBlockType.subheading)
                                              TextFormField(
                                                initialValue: block.content,
                                                maxLines: 2,
                                                decoration: const InputDecoration(
                                                  hintText: 'Введите подзаголовок...',
                                                  border: OutlineInputBorder(),
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                onChanged: (value) => _updateBlockContent(index, value),
                                              )
                                            else // Image block
                                              Column(
                                                children: [
                                                  Container(
                                                    height: 150,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: Colors.grey[100],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        block.content,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Center(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const Icon(Icons.error, color: Colors.red),
                                                                const SizedBox(height: 8),
                                                                Text(
                                                                  'Ошибка загрузки',
                                                                  style: TextStyle(color: Colors.red[700]),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'URL: ${block.content}',
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                                // ОБНОВЛЕННЫЕ КНОПКИ ДОБАВЛЕНИЯ БЛОКОВ
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _addTextBlock,
                                      icon: const Icon(Icons.text_fields, size: 16),
                                      label: const Text('Текст'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[50],
                                        foregroundColor: Colors.blue,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _addHeadingBlock,
                                      icon: const Icon(Icons.title, size: 16),
                                      label: const Text('Заголовок'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[50],
                                        foregroundColor: Colors.orange,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _addSubheadingBlock,
                                      icon: const Icon(Icons.subtitles, size: 16),
                                      label: const Text('Подзаголовок'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple[50],
                                        foregroundColor: Colors.purple,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _addImageBlock,
                                      icon: const Icon(Icons.image, size: 16),
                                      label: const Text('Изображение'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[50],
                                        foregroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _publishArticle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Опубликовать статью',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}