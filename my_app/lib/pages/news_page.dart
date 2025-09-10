// lib/pages/news_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  final Map<String, TextEditingController> _commentControllers = {};
  bool _showAddNewsForm = false;

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
      // Безопасное преобразование ID
      final newsId = news['id'] is int ? news['id'].toString() : news['id'] as String;
      await ApiService.likeNews(newsId);

      // Безопасное обновление лайков
      final currentLikes = news['likes'] is int ? news['likes'] : int.tryParse(news['likes'].toString()) ?? 0;
      newsProvider.updateNewsLikes(index, currentLikes + 1);
    } catch (e) {
      print('Error liking news: $e');
      final currentLikes = news['likes'] is int ? news['likes'] : int.tryParse(news['likes'].toString()) ?? 0;
      newsProvider.updateNewsLikes(index, currentLikes + 1);
    }
  }

  Future<void> _addComment(int index, String commentText) async {
    if (commentText.trim().isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];

    try {
      // Безопасное преобразование ID
      final newsId = news['id'] is int ? news['id'].toString() : news['id'] as String;
      await ApiService.addComment(newsId, {
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

      _commentControllers[newsId]?.clear();
    } catch (e) {
      print('Error adding comment: $e');
      final newsId = news['id'] is int ? news['id'].toString() : news['id'] as String;
      newsProvider.addCommentToNews(
        index,
        {
          'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
          'author': widget.userName,
          'text': commentText.trim(),
          'time': 'Только что',
        },
      );
      _commentControllers[newsId]?.clear();
    }
  }

  Future<void> _addNews(String title, String description) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    try {
      final newNews = await ApiService.createNews({
        'title': title,
        'description': description,
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
        "likes": 0,
        "author_name": widget.userName,
        "created_at": DateTime.now().toIso8601String(),
        "comments": []
      });
    }
  }

  void _toggleAddNewsForm() {
    setState(() {
      _showAddNewsForm = !_showAddNewsForm;
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'только что';
      if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
      if (difference.inHours < 24) return '${difference.inHours} ч назад';
      if (difference.inDays < 7) return '${difference.inDays} д назад';

      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildNewsCard(Map<String, dynamic> news, int index, BuildContext context) {
    final isLiked = false;
    final comments = news['comments'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и автор
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      (news['author_name'] ?? 'Н')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
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
                          news['author_name'] ?? 'Неизвестный автор',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _formatDate(news['created_at']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (news['author_name'] == widget.userName)
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                      onPressed: () => _showNewsOptions(context, index),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Заголовок новости
              Text(
                news['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Описание новости
              Text(
                news['description'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Статистика и действия
              Row(
                children: [
                  // Лайки
                  _buildActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    count: news['likes'] is int ? news['likes'] : int.tryParse(news['likes'].toString()) ?? 0,
                    color: isLiked ? Colors.red : Colors.grey[600]!,
                    onPressed: () => _likeNews(index),
                  ),
                  const SizedBox(width: 16),

                  // Комментарии
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    count: comments.length,
                    color: Colors.grey[600]!,
                    onPressed: () => _toggleComments(news['id'].toString()),
                  ),

                  const Spacer(),

                  // Тег
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#новости',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Комментарии
              if (comments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                ...comments.map((comment) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green[100],
                        child: Text(
                          comment['author'][0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment['author'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              comment['text'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              comment['time'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],

              // Поле для комментария
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      widget.userName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _commentControllers[news['id'].toString()] ??= TextEditingController(),
                      decoration: InputDecoration(
                        hintText: 'Напишите комментарий...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF1E88E5)),
                    onPressed: () => _addComment(
                      index,
                      _commentControllers[news['id'].toString()]?.text ?? '',
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    int count = 0,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNewsOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                _editNews(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить'),
              onTap: () {
                Navigator.pop(context);
                _deleteNews(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editNews(int index) {
    // Редактирование новости
    // TODO: реализовать редактирование
  }

  void _deleteNews(int index) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.removeNews(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Новость удалена')),
    );
  }

  void _toggleComments(String newsId) {
    // Логика показа/скрытия комментариев
    // TODO: реализовать переключение комментариев
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Список новостей
              newsProvider.isLoading
                  ? SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF1E88E5)),
                    ),
                  ),
                ),
              )
                  : newsProvider.news.isEmpty
                  ? SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Пока нет новостей',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Будьте первым, кто поделится\nфутбольными новостями!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final news = newsProvider.news[index];
                    return _buildNewsCard(news, index, context);
                  },
                  childCount: newsProvider.news.length,
                ),
              ),
            ],
          ),

          // Плавающая кнопка
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleAddNewsForm,
              backgroundColor: const Color(0xFF1E88E5),
              child: Icon(
                _showAddNewsForm ? Icons.close : Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Модальное окно для добавления новости
          if (_showAddNewsForm)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: _buildAddNewsForm(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddNewsForm() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Создать новость',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: titleController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Заголовок новости',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Текст новости',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _toggleAddNewsForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    _addNews(
                      titleController.text,
                      descriptionController.text,
                    );
                    _toggleAddNewsForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Новость добавлена! 🎉')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Опубликовать',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}