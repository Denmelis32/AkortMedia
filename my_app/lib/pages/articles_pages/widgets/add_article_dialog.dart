import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_card.dart';

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
    _imageUrlController.text = _popularImages.first;
    _isImageValid = true;
  }

  // Адаптивные методы как в CardsPage
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

  bool _validateForm() {
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

  void _publishArticle() {
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
              // AppBar как в CardsPage - БЕЗ карточки, просто белый фон
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

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Карточка с формой как в CardsPage
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
                                // Уровень автора
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

                                // Эмодзи и категория
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
                                  label: const Text('Выбрать изображение'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[100],
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Превью изображения
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
                                  maxLines: 3,
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
                                  maxLines: 8,
                                  onChanged: (value) => setState(() => _charCount = value.length),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Введите содержание';
                                    if (value.length < 300) return 'Минимум 300 символов';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_charCount/300 символов',
                                  style: TextStyle(
                                    color: _charCount >= 300 ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Кнопка публикации
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
    _descriptionController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}