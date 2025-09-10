import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../services/api_service.dart';

class NewsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const NewsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _backgroundColor = const Color(0xFFF5F9FF);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _secondaryTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).loadNews();
    });
  }

  Future<void> _likeNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.likeNews(news['id'].toString());
      newsProvider.updateNewsLikes(index, news['likes'] + 1);
    } catch (e) {
      print('Error liking news: $e');
      newsProvider.updateNewsLikes(index, (news['likes'] ?? 0) + 1);
    }
  }

  Future<void> _addComment(int index, String commentText) async {
    if (commentText.trim().isEmpty) return;
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.addComment(news['id'].toString(), {
        'text': commentText.trim(),
        'author': widget.userName,
      });
      newsProvider.addCommentToNews(
        index,
        {
          'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
          'author': widget.userName,
          'text': commentText.trim(),
          'time': 'Только что',
        },
      );
      _commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
      newsProvider.addCommentToNews(
        index,
        {
          'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
          'author': widget.userName,
          'text': commentText.trim(),
          'time': 'Только что',
        },
      );
      _commentController.clear();
    }
  }

  Future<void> _addNews(String title, String description, String hashtags) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    try {
      final newNews = await ApiService.createNews({
        'title': title,
        'description': description,
        'hashtags': hashtags,
      });
      newsProvider.addNews({
        ...newNews,
        'comments': [],
      });
    } catch (e) {
      print('Error creating news: $e');
      newsProvider.addNews({
        "id": "local-${DateTime.now().millisecondsSinceEpoch}",
        "title": title,
        "description": description,
        "hashtags": hashtags,
        "likes": 0,
        "author_name": widget.userName,
        "created_at": DateTime.now().toIso8601String(),
        "comments": []
      });
    }
  }

  Future<void> _editNews(int index, String title, String description, String hashtags) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.updateNews(news['id'].toString(), {
        'title': title,
        'description': description,
        'hashtags': hashtags,
      });
      newsProvider.updateNews(
        index,
        {
          ...news,
          'title': title,
          'description': description,
          'hashtags': hashtags,
        },
      );
    } catch (e) {
      print('Error updating news: $e');
      newsProvider.updateNews(
        index,
        {
          ...news,
          'title': title,
          'description': description,
          'hashtags': hashtags,
        },
      );
    }
  }

  Future<void> _deleteNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.deleteNews(news['id'].toString());
      newsProvider.removeNews(index);
    } catch (e) {
      print('Error deleting news: $e');
      newsProvider.removeNews(index);
    }
  }

  void _showEditNewsDialog(int index) {
    final news = Provider.of<NewsProvider>(context, listen: false).news[index];
    final titleController = TextEditingController(text: news['title']);
    final descriptionController = TextEditingController(text: news['description']);
    final hashtagsController = TextEditingController(text: news['hashtags']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Редактировать новость',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Заголовок (необязательно)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    hintText: 'Введите заголовок новости (необязательно)',
                    hintStyle: TextStyle(color: _secondaryTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: _backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Текст новости (максимум 140 символов)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    hintText: 'Введите текст новости (максимум 140 символов)',
                    hintStyle: TextStyle(color: _secondaryTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: _backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    counterText: '${descriptionController.text.length}/140',
                  ),
                  maxLines: 4,
                  maxLength: 140,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Хештеги (через запятую, максимум 4)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hashtagsController,
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    hintText: '#новость, #событие, #факт',
                    hintStyle: TextStyle(color: _secondaryTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: _backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryColor,
                          side: BorderSide(color: _primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (descriptionController.text.isNotEmpty &&
                              descriptionController.text.length <= 140) {
                            _editNews(
                              index,
                              titleController.text,
                              descriptionController.text,
                              hashtagsController.text,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Новость успешно обновлена!'),
                                backgroundColor: _primaryColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        child: const Text('Сохранить'),
                      ),
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

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить новость?'),
        content: const Text('Вы уверены, что хотите удалить эту новость? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _deleteNews(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Новость удалена!'),
                  backgroundColor: _primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddNewsDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final hashtagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Создать новость',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Заголовок (необязательно)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        hintText: 'Введите заголовок новости (необязательно)',
                        hintStyle: TextStyle(color: _secondaryTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: _backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Текст новости (максимум 140 символов)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      style: TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        hintText: 'Введите текст новости (максимум 140 символов)',
                        hintStyle: TextStyle(color: _secondaryTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: _backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        counterText: '${descriptionController.text.length}/140',
                        errorText: descriptionController.text.length > 140
                            ? 'Превышено максимальное количество символов'
                            : null,
                      ),
                      maxLines: 4,
                      maxLength: 140,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Хештеги (через запятую, максимум 4)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: hashtagsController,
                      style: TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        hintText: '#новость, #событие, #факт',
                        hintStyle: TextStyle(color: _secondaryTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: _backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryColor,
                              side: BorderSide(color: _primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Отмена'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: descriptionController.text.isNotEmpty &&
                                  descriptionController.text.length <= 140
                                  ? _primaryColor
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              if (descriptionController.text.isNotEmpty &&
                                  descriptionController.text.length <= 140) {
                                _addNews(
                                  titleController.text,
                                  descriptionController.text,
                                  hashtagsController.text,
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Новость успешно добавлена!'),
                                    backgroundColor: _primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              }
                            },
                            child: const Text('Опубликовать'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'только что';
      if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
      if (difference.inHours < 24) return '${difference.inHours} ч назад';
      if (difference.inDays < 7) return '${difference.inDays} дн назад';

      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Новости',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: _textColor,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: _primaryColor),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundColor: _primaryColor.withOpacity(0.1),
              child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.logout, color: _primaryColor),
            onPressed: widget.onLogout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: newsProvider.isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(_primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Загрузка новостей...',
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => newsProvider.loadNews(),
        color: _primaryColor,
        backgroundColor: _cardColor,
        child: newsProvider.news.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article,
                size: 64,
                color: _primaryColor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Новостей пока нет',
                style: TextStyle(
                  fontSize: 18,
                  color: _secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Будьте первым, кто поделится новостью!',
                style: TextStyle(
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: newsProvider.news.length,
          itemBuilder: (context, index) {
            final news = newsProvider.news[index];
            return _NewsCard(
              news: news,
              userName: widget.userName,
              onLike: () => _likeNews(index),
              onComment: (comment) => _addComment(index, comment),
              onEdit: () => _showEditNewsDialog(index),
              onDelete: () => _showDeleteConfirmationDialog(index),
              formatDate: _formatDate,
              getTimeAgo: _getTimeAgo,
              primaryColor: _primaryColor,
              backgroundColor: _backgroundColor,
              cardColor: _cardColor,
              textColor: _textColor,
              secondaryTextColor: _secondaryTextColor,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNewsDialog,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
        elevation: 4,
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _NewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final String userName;
  final VoidCallback onLike;
  final Function(String) onComment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const _NewsCard({
    required this.news,
    required this.userName,
    required this.onLike,
    required this.onComment,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
    required this.getTimeAgo,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  final TextEditingController _commentController = TextEditingController();
  bool _isExpanded = false;
  bool _isLiked = false;
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    final comments = widget.news['comments'] ?? [];
    final hashtags = widget.news['hashtags']?.toString().split(',') ?? [];
    final isAuthor = widget.news['author_name'] == widget.userName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: widget.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with author and time
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.primaryColor.withOpacity(0.1),
                    child: Text(
                      widget.news['author_name']?[0]?.toUpperCase() ?? '?',
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.news['author_name'] ?? 'Неизвестно',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.textColor,
                          ),
                        ),
                        Text(
                          widget.getTimeAgo(widget.news['created_at']),
                          style: TextStyle(
                            color: widget.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAuthor)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: widget.secondaryTextColor),
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit();
                        } else if (value == 'delete') {
                          widget.onDelete();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: widget.primaryColor),
                              const SizedBox(width: 8),
                              const Text('Редактировать'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Удалить'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Title (only show if not empty)
              if (widget.news['title'] != null && widget.news['title'].toString().isNotEmpty)
                Column(
                  children: [
                    Text(
                      widget.news['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: widget.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // Description
              Text(
                widget.news['description'],
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: widget.textColor,
                ),
              ),

              const SizedBox(height: 16),

              // Hashtags at the bottom right
              if (hashtags.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final tag in hashtags.take(4))
                        if (tag.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${tag.trim()}',
                              style: TextStyle(
                                color: widget.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Stats and actions
              Row(
                children: [
                  // Like button
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? widget.primaryColor : widget.secondaryTextColor,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      widget.onLike();
                    },
                  ),
                  Text(
                    '${widget.news['likes'] ?? 0}',
                    style: TextStyle(
                      color: widget.secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Comment button
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.chat : Icons.chat_bubble_outline,
                      color: _isExpanded ? widget.primaryColor : widget.secondaryTextColor,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                  Text(
                    '${comments.length}',
                    style: TextStyle(
                      color: widget.secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),
                ],
              ),

              // Comments section
              if (_isExpanded) ...[
                const Divider(height: 24),
                if (comments.isNotEmpty)
                  Column(
                    children: [
                      ...comments.map((comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: widget.primaryColor.withOpacity(0.1),
                              child: Text(
                                comment['author']?[0]?.toUpperCase() ?? '?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['author'] ?? 'Неизвестно',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: widget.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['text'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: widget.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['time'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Add comment input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(color: widget.textColor),
                          decoration: InputDecoration(
                            hintText: 'Написать комментарий...',
                            hintStyle: TextStyle(color: widget.secondaryTextColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              widget.onComment(value);
                              _commentController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: widget.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, size: 20, color: Colors.white),
                          onPressed: () {
                            if (_commentController.text.trim().isNotEmpty) {
                              widget.onComment(_commentController.text);
                              _commentController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}