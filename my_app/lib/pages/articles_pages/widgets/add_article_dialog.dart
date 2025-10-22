import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_card.dart';

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
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory = 'Программирование';
  String _selectedEmoji = '📊';
  AuthorLevel _selectedAuthorLevel = AuthorLevel.beginner;
  bool _isImageValid = false;
  String? _imageError;

  final List<String> _popularImages = [
    'https://avatars.mds.yandex.net/i?id=726f36664cfa9350596fb7856ad6633a2625ef83-9555577-images-thumbs&n=13',
    'https://picsum.photos/500/300?grayscale',
    'https://picsum.photos/500/300?blur=2',
    'https://picsum.photos/500/300?random=1',
  ];

  final List<ContentBlock> _contentBlocks = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _subtitleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
    _imageUrlController.text = _popularImages.first;
    _isImageValid = true;
    _contentBlocks.add(ContentBlock(type: ContentBlockType.text, content: ''));

    // Автофокус на заголовок при открытии
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    });
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 20;
  }

  Color _getLevelColor(AuthorLevel level) {
    return level == AuthorLevel.expert
        ? const Color(0xFF4FC3F7)
        : const Color(0xFF78909C);
  }

  String _getLevelText(AuthorLevel level) {
    return level == AuthorLevel.expert ? 'ЭКСПЕРТ' : 'НОВИЧОК';
  }

  // УЛУЧШЕННЫЙ ВЫБОР ИЗОБРАЖЕНИЯ
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // ХЕДЕР
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Выберите обложку',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ПОПУЛЯРНЫЕ ИЗОБРАЖЕНИЯ
                      const Text(
                        'Популярные обложки',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _popularImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _imageUrlController.text = _popularImages[index];
                                setState(() {
                                  _isImageValid = true;
                                  _imageError = null;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _popularImages[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // СВОЙ URL
                      const Text(
                        'Или введите свой URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL изображения',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check_circle),
                            onPressed: () {
                              final url = _imageUrlController.text.trim();
                              if (url.isNotEmpty && url.startsWith('http')) {
                                setState(() {
                                  _isImageValid = true;
                                  _imageError = null;
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ПРЕДПРОСМОТР
                      if (_imageUrlController.text.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Предпросмотр',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Неверный URL',
                                            style: TextStyle(color: Colors.red.shade700),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // КНОПКИ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final url = _imageUrlController.text.trim();
                          if (url.isNotEmpty && url.startsWith('http')) {
                            setState(() {
                              _isImageValid = true;
                              _imageError = null;
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Применить',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ОСТАЛЬНЫЕ МЕТОДЫ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ...
  void _addTextBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.text, content: ''));
    });
    _scrollToBottom();
  }

  void _addHeadingBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.heading, content: ''));
    });
    _scrollToBottom();
  }

  void _addSubheadingBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.subheading, content: ''));
    });
    _scrollToBottom();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Черновик сохранен'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
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
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String labelText, {bool isRequired = true}) {
    return InputDecoration(
      labelText: isRequired ? '$labelText *' : labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
    );
  }

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
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFD),
              Color(0xFFF0F4F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // УЛУЧШЕННЫЙ ХЕДЕР
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black54),
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
                    OutlinedButton.icon(
                      onPressed: _saveDraft,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Черновик'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ОСНОВНАЯ ИНФОРМАЦИЯ
                        _buildSection(
                          title: 'Основная информация',
                          child: Column(
                            children: [
                              // УРОВЕНЬ АВТОРА
                              const Row(
                                children: [
                                  Icon(Icons.person_outline, size: 20, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    'Уровень автора',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildLevelButton(
                                      level: AuthorLevel.beginner,
                                      isSelected: _selectedAuthorLevel == AuthorLevel.beginner,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildLevelButton(
                                      level: AuthorLevel.expert,
                                      isSelected: _selectedAuthorLevel == AuthorLevel.expert,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // КАТЕГОРИЯ И EMOJI
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // EMOJI
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
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

                                  // КАТЕГОРИЯ
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
                                      decoration: _inputDecoration('Категория'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ОБЛОЖКА
                        _buildSection(
                          title: 'Обложка статьи',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _imageUrlController,
                                decoration: _inputDecoration('URL обложки').copyWith(
                                  suffixIcon: _isImageValid
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : const Icon(Icons.error_outline, color: Colors.red),
                                  errorText: _imageError,
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
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _showImagePicker,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Выбрать из галереи'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_imageUrlController.text.isNotEmpty && _isImageValid)
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey.shade100,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade100,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Ошибка загрузки',
                                                style: TextStyle(color: Colors.red.shade700),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ТЕКСТ СТАТЬИ
                        _buildSection(
                          title: 'Текст статьи',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _titleController,
                                focusNode: _titleFocusNode,
                                decoration: _inputDecoration('Заголовок статьи'),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Введите заголовок';
                                  if (value.length < 3) return 'Минимум 3 символа';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _subtitleController,
                                focusNode: _subtitleFocusNode,
                                decoration: _inputDecoration('Подзаголовок'),
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
                                focusNode: _descriptionFocusNode,
                                decoration: _inputDecoration('Описание статьи'),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Введите описание';
                                  if (value.length < 50) return 'Минимум 50 символов';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // СОДЕРЖАНИЕ
                        _buildSection(
                          title: 'Содержание статьи',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Добавляйте блоки в нужном порядке для структурирования статьи:',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // БЛОКИ СОДЕРЖАНИЯ
                              ..._contentBlocks.asMap().entries.map((entry) {
                                final index = entry.key;
                                final block = entry.value;
                                return _buildContentBlock(index, block);
                              }),

                              const SizedBox(height: 16),

                              // КНОПКИ ДОБАВЛЕНИЯ БЛОКОВ
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildAddBlockButton(
                                    icon: Icons.text_fields,
                                    label: 'Текст',
                                    color: Colors.blue,
                                    onTap: _addTextBlock,
                                  ),
                                  _buildAddBlockButton(
                                    icon: Icons.title,
                                    label: 'Заголовок',
                                    color: Colors.orange,
                                    onTap: _addHeadingBlock,
                                  ),
                                  _buildAddBlockButton(
                                    icon: Icons.subtitles,
                                    label: 'Подзаголовок',
                                    color: Colors.purple,
                                    onTap: _addSubheadingBlock,
                                  ),
                                  _buildAddBlockButton(
                                    icon: Icons.image,
                                    label: 'Изображение',
                                    color: Colors.green,
                                    onTap: _addImageBlock,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // КНОПКА ПУБЛИКАЦИИ
                        Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _publishArticle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Опубликовать статью',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
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

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton({required AuthorLevel level, required bool isSelected}) {
    final color = _getLevelColor(level);
    return OutlinedButton(
      onPressed: () => setState(() => _selectedAuthorLevel = level),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        side: BorderSide(color: isSelected ? color : Colors.grey.shade400, width: isSelected ? 2 : 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(
            level == AuthorLevel.expert ? Icons.workspace_premium : Icons.person,
            color: isSelected ? color : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            _getLevelText(level),
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBlock(int index, ContentBlock block) {
    final blockColor = _getBlockColor(block.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ХЕДЕР БЛОКА
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: blockColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: blockColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getBlockIcon(block.type), size: 16, color: blockColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_getBlockTypeName(block.type)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blockColor,
                  ),
                ),
                const Spacer(),
                if (_contentBlocks.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    onPressed: () => _removeBlock(index),
                    tooltip: 'Удалить блок',
                  ),
              ],
            ),
          ),

          // КОНТЕНТ БЛОКА
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBlockContent(index, block),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockContent(int index, ContentBlock block) {
    switch (block.type) {
      case ContentBlockType.text:
        return TextFormField(
          initialValue: block.content,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Введите текст...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          onChanged: (value) => _updateBlockContent(index, value),
        );
      case ContentBlockType.heading:
        return TextFormField(
          initialValue: block.content,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Введите заголовок...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          onChanged: (value) => _updateBlockContent(index, value),
        );
      case ContentBlockType.subheading:
        return TextFormField(
          initialValue: block.content,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Введите подзаголовок...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          onChanged: (value) => _updateBlockContent(index, value),
        );
      case ContentBlockType.image:
        return Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
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
                          const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Ошибка загрузки',
                            style: TextStyle(color: Colors.grey.shade600),
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
        );
    }
  }

  Widget _buildAddBlockButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
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
    _imageUrlController.dispose();
    _scrollController.dispose();
    _titleFocusNode.dispose();
    _subtitleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }
}