import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import 'article_card.dart';

enum ContentBlockType { text, image, heading1, heading2, heading3, quote, link, code, divider }

class ContentBlock {
  final ContentBlockType type;
  final String content;
  final String? extra;

  ContentBlock({required this.type, required this.content, this.extra});

  ContentBlock copyWith({ContentBlockType? type, String? content, String? extra}) {
    return ContentBlock(
      type: type ?? this.type,
      content: content ?? this.content,
      extra: extra ?? this.extra,
    );
  }
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
    'https://avatars.mds.yandex.net/i?id=428b91f28c0d53eef74258629e71789d_l-5275490-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=081e78a338934d66f3c74787c390ebb9_l-5437458-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=3997640509660414271ff6e5fd5453e7_l-5235251-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=2e0e387e1de7d776436ac269f6f78473_l-16397087-images-thumbs&n=13',
  ];

  final List<ContentBlock> _contentBlocks = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _subtitleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  // Переменные для перетаскивания
  int? _draggedIndex;
  int? _targetIndex;

  // Контроллеры для диалогов
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _codeLanguageController = TextEditingController();
  final TextEditingController _linkUrlController = TextEditingController();
  final TextEditingController _linkTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
    _imageUrlController.text = _popularImages.first;
    _isImageValid = true;
    _contentBlocks.add(ContentBlock(type: ContentBlockType.text, content: ''));

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

  // МЕТОДЫ ДЛЯ БЛОКОВ СОДЕРЖАНИЯ
  void _addTextBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.text, content: ''));
    });
    _scrollToBottom();
  }

  void _addHeading1Block() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.heading1, content: ''));
    });
    _scrollToBottom();
  }

  void _addHeading2Block() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.heading2, content: ''));
    });
    _scrollToBottom();
  }

  void _addHeading3Block() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.heading3, content: ''));
    });
    _scrollToBottom();
  }

  void _addImageBlock() {
    showDialog(
      context: context,
      builder: (context) => _buildImageDialog(),
    );
  }

  void _addQuoteBlock() {
    showDialog(
      context: context,
      builder: (context) => _buildQuoteDialog(),
    );
  }

  void _addCodeBlock() {
    showDialog(
      context: context,
      builder: (context) => _buildCodeDialog(),
    );
  }

  void _addDividerBlock() {
    setState(() {
      _contentBlocks.add(ContentBlock(type: ContentBlockType.divider, content: ''));
    });
    _scrollToBottom();
  }

  // МЕТОДЫ ПЕРЕТАСКИВАНИЯ
  void _onDragStarted(int index) {
    setState(() {
      _draggedIndex = index;
    });
  }

  void _onDragEnd(int index) {
    setState(() {
      _draggedIndex = null;
      _targetIndex = null;
    });
  }

  void _onDragAccept(int index) {
    if (_draggedIndex != null && _draggedIndex != index) {
      setState(() {
        final draggedItem = _contentBlocks[_draggedIndex!];
        _contentBlocks.removeAt(_draggedIndex!);
        final newIndex = index > _draggedIndex! ? index - 1 : index;
        _contentBlocks.insert(newIndex, draggedItem);
        _draggedIndex = null;
        _targetIndex = null;
      });
    }
  }

  void _onDragEnter(int index) {
    setState(() {
      _targetIndex = index;
    });
  }

  void _onDragLeave(int index) {
    setState(() {
      if (_targetIndex == index) {
        _targetIndex = null;
      }
    });
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
      _contentBlocks[index] = _contentBlocks[index].copyWith(content: content);
    });
  }

  void _updateBlockExtra(int index, String extra) {
    setState(() {
      _contentBlocks[index] = _contentBlocks[index].copyWith(extra: extra);
    });
  }

  // ДИАЛОГИ
  Widget _buildImageDialog() {
    String imageUrl = '';
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить изображение',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'URL изображения',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) => imageUrl = value,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
                        setState(() {
                          _contentBlocks.add(ContentBlock(type: ContentBlockType.image, content: imageUrl));
                        });
                        Navigator.pop(context);
                        _scrollToBottom();
                      }
                    },
                    child: const Text('Добавить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить цитату',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: TextField(
                controller: _quoteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Текст цитаты',
                  hintText: 'Введите цитату...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_quoteController.text.isNotEmpty) {
                        setState(() {
                          _contentBlocks.add(ContentBlock(type: ContentBlockType.quote, content: _quoteController.text));
                        });
                        _quoteController.clear();
                        Navigator.pop(context);
                        _scrollToBottom();
                      }
                    },
                    child: const Text('Добавить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить код',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeLanguageController,
              decoration: const InputDecoration(
                labelText: 'Язык программирования',
                hintText: 'dart, javascript, python...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: TextField(
                controller: _codeController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Код',
                  hintText: 'Введите код...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_codeController.text.isNotEmpty) {
                        setState(() {
                          _contentBlocks.add(ContentBlock(
                            type: ContentBlockType.code,
                            content: _codeController.text,
                            extra: _codeLanguageController.text.isEmpty ? 'text' : _codeLanguageController.text,
                          ));
                        });
                        _codeController.clear();
                        _codeLanguageController.clear();
                        Navigator.pop(context);
                        _scrollToBottom();
                      }
                    },
                    child: const Text('Добавить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // МЕТОДЫ ДЛЯ ССЫЛОК В ТЕКСТЕ
  void _showLinkDialog(BuildContext context, TextEditingController controller) {
    String url = '';
    String text = '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Добавить ссылку',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'URL ссылки',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) => url = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Текст ссылки',
                  hintText: 'Описание ссылки',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) => text = value,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (url.isNotEmpty && text.isNotEmpty) {
                          final link = '<a href="$url">$text</a>';
                          final newText = '${controller.text} $link';
                          controller.text = newText;
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Добавить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLinkConfirmation(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Перейти по ссылке?'),
        content: Text('Вы действительно хотите перейти по адресу:\n$url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(url);
            },
            child: const Text('Перейти'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildRichText(String text, Function(String) onLinkTap) {
    final linkRegex = RegExp(r'<a href="([^"]+)">([^<]+)</a>');
    final parts = text.split(linkRegex);
    final matches = linkRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return Text(text);
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            TextSpan(text: parts[i]),
            if (i < matches.length)
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => onLinkTap(matches[i].group(1)!),
                  child: Text(
                    matches[i].group(2)!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ВАЛИДАЦИЯ И СОХРАНЕНИЕ
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
        block.type == ContentBlockType.heading1 ||
        block.type == ContentBlockType.heading2 ||
        block.type == ContentBlockType.heading3) &&
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

  // ИСПРАВЛЕННЫЙ МЕТОД: Правильное форматирование контента
  void _publishArticle() {
    if (_formKey.currentState!.validate() && _validateForm()) {
      final content = _contentBlocks.map((block) {
        switch (block.type) {
          case ContentBlockType.text:
            return block.content;
          case ContentBlockType.heading1:
            return '[HEADING:${block.content}]';
          case ContentBlockType.heading2:
            return '[SUBHEADING:${block.content}]';
          case ContentBlockType.heading3:
            return '[SUBHEADING:${block.content}]';
          case ContentBlockType.image:
            return '[IMAGE:${block.content}]';
          case ContentBlockType.quote:
            return '[QUOTE:${block.content}]';
          case ContentBlockType.link:
            return '[LINK:${block.content}:${block.extra ?? ""}]';
          case ContentBlockType.code:
          // ЗАМЕНЯЕМ ПЕРЕНОСЫ СТРОК НА СПЕЦИАЛЬНЫЙ СИМВОЛ
            final escapedCode = block.content.replaceAll('\n', '\\n');
            return '[CODE:${block.extra ?? "text"}:$escapedCode]';
          case ContentBlockType.divider:
            return '[DIVIDER]';
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
      case ContentBlockType.heading1:
        return Icons.title;
      case ContentBlockType.heading2:
        return Icons.format_size;
      case ContentBlockType.heading3:
        return Icons.text_format;
      case ContentBlockType.image:
        return Icons.image;
      case ContentBlockType.quote:
        return Icons.format_quote;
      case ContentBlockType.code:
        return Icons.code;
      case ContentBlockType.divider:
        return Icons.horizontal_rule;
      case ContentBlockType.link:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _getBlockColor(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.text:
        return Colors.blue;
      case ContentBlockType.heading1:
        return Colors.orange;
      case ContentBlockType.heading2:
        return Colors.deepOrange;
      case ContentBlockType.heading3:
        return Colors.red;
      case ContentBlockType.image:
        return Colors.green;
      case ContentBlockType.quote:
        return Colors.amber;
      case ContentBlockType.code:
        return Colors.brown;
      case ContentBlockType.divider:
        return Colors.grey;
      case ContentBlockType.link:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _getBlockTypeName(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.text:
        return 'Текст';
      case ContentBlockType.heading1:
        return 'Заголовок 1';
      case ContentBlockType.heading2:
        return 'Заголовок 2';
      case ContentBlockType.heading3:
        return 'Заголовок 3';
      case ContentBlockType.image:
        return 'Изображение';
      case ContentBlockType.quote:
        return 'Цитата';
      case ContentBlockType.code:
        return 'Код';
      case ContentBlockType.divider:
        return 'Разделитель';
      case ContentBlockType.link:
        // TODO: Handle this case.
        throw UnimplementedError();
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
              // ХЕДЕР
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
                    if (isDesktop)
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
                    if (!isDesktop)
                      IconButton(
                        onPressed: _saveDraft,
                        icon: const Icon(Icons.save, color: Colors.blue),
                        tooltip: 'Сохранить черновик',
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
                              ReorderableListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }
                                    final item = _contentBlocks.removeAt(oldIndex);
                                    _contentBlocks.insert(newIndex, item);
                                  });
                                },
                                children: [
                                  for (int index = 0; index < _contentBlocks.length; index++)
                                    _buildContentBlock(index, _contentBlocks[index]),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // КНОПКИ ДОБАВЛЕНИЯ БЛОКОВ
                              _buildBlockButtonsGrid(isDesktop),
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
      key: Key('block_$index'),
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
                Icon(
                  Icons.drag_handle,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
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
        final controller = TextEditingController(text: block.content);
        return Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Введите текст...',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => _showLinkDialog(context, controller),
                  tooltip: 'Добавить ссылку',
                ),
              ),
              onChanged: (value) => _updateBlockContent(index, value),
            ),
            if (block.content.contains('<a href="'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildRichText(block.content, _showLinkConfirmation),
              ),
          ],
        );
      case ContentBlockType.heading1:
        return TextField(
          controller: TextEditingController(text: block.content),
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Введите заголовок 1 уровня...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          onChanged: (value) => _updateBlockContent(index, value),
        );
      case ContentBlockType.heading2:
        return TextField(
          controller: TextEditingController(text: block.content),
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Введите заголовок 2 уровня...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          onChanged: (value) => _updateBlockContent(index, value),
        );
      case ContentBlockType.heading3:
        return TextField(
          controller: TextEditingController(text: block.content),
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Введите заголовок 3 уровня...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
      case ContentBlockType.quote:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: Colors.amber.shade400, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.format_quote, color: Colors.amber.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Цитата',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                block.content,
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
            ],
          ),
        );
      case ContentBlockType.code:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Код ${block.extra != null ? '(${block.extra})' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  block.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      case ContentBlockType.divider:
        return Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade500,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      case ContentBlockType.link:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Widget _buildBlockButtonsGrid(bool isDesktop) {
    final buttons = [
      _buildAddBlockButton(
        icon: Icons.text_fields,
        label: 'Текст',
        color: Colors.blue,
        onTap: _addTextBlock,
      ),
      _buildAddBlockButton(
        icon: Icons.title,
        label: 'Заголовок 1',
        color: Colors.orange,
        onTap: _addHeading1Block,
      ),
      _buildAddBlockButton(
        icon: Icons.format_size,
        label: 'Заголовок 2',
        color: Colors.deepOrange,
        onTap: _addHeading2Block,
      ),
      _buildAddBlockButton(
        icon: Icons.text_format,
        label: 'Заголовок 3',
        color: Colors.red,
        onTap: _addHeading3Block,
      ),
      _buildAddBlockButton(
        icon: Icons.image,
        label: 'Изображение',
        color: Colors.green,
        onTap: _addImageBlock,
      ),
      _buildAddBlockButton(
        icon: Icons.format_quote,
        label: 'Цитата',
        color: Colors.amber,
        onTap: _addQuoteBlock,
      ),
      _buildAddBlockButton(
        icon: Icons.code,
        label: 'Код',
        color: Colors.brown,
        onTap: _addCodeBlock,
      ),
      _buildAddBlockButton(
        icon: Icons.horizontal_rule,
        label: 'Разделитель',
        color: Colors.grey,
        onTap: _addDividerBlock,
      ),
    ];

    if (isDesktop) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: buttons,
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
        children: buttons,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
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
    _quoteController.dispose();
    _linkUrlController.dispose();
    _linkTextController.dispose();
    _codeController.dispose();
    _codeLanguageController.dispose();
    super.dispose();
  }
}