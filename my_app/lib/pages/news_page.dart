// lib/pages/news_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../services/api_service.dart';

class NewsPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const NewsPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Загружаем новости при инициализации
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
      // Fallback на локальное обновление
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
      // Fallback на локальное добавление
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

  Future<void> _addNews(String title, String description, String image) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    try {
      final newNews = await ApiService.createNews({
        'title': title,
        'description': description,
        'image': image,
      });

      newsProvider.addNews({
        ...newNews,
        'comments': [],
      });

    } catch (e) {
      print('Error creating news: $e');
      // Fallback на локальное добавление
      newsProvider.addNews({
        "id": "local-${DateTime.now().millisecondsSinceEpoch}",
        "title": title,
        "description": description,
        "image": image,
        "likes": 0,
        "author_name": widget.userName,
        "created_at": DateTime.now().toIso8601String(),
        "comments": []
      });
    }
  }

  void _showAddNewsDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить новость'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок новости',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание новости',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'Эмодзи (например: ⚽, 🏆)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  imageController.text.isNotEmpty) {
                _addNews(
                  titleController.text,
                  descriptionController.text,
                  imageController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Новость добавлена!')),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    if (newsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => newsProvider.loadNews(),
        child: ListView.builder(
          itemCount: newsProvider.news.length,
          itemBuilder: (context, index) {
            final news = newsProvider.news[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и автор
                    Text(
                      news['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Автор: ${news['author_name'] ?? 'Неизвестно'}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Эмодзи-изображение
                    Center(
                      child: Text(
                        news['image'],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Описание новости
                    Text(
                      news['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Время и лайки
                    Row(
                      children: [
                        Text(
                          _formatDate(news['created_at']),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () => _likeNews(index),
                        ),
                        Text('${news['likes'] ?? 0}'),
                      ],
                    ),

                    // Комментарии
                    if (news['comments'] != null && news['comments'].isNotEmpty) ...[
                      const Divider(),
                      const Text(
                        'Комментарии:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...(news['comments'] as List).map((comment) => ListTile(
                        title: Text(comment['author']),
                        subtitle: Text(comment['text']),
                        trailing: Text(
                          comment['time'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      )).toList(),
                    ],

                    // Поле для добавления комментария
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Добавить комментарий...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _addComment(index, _commentController.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNewsDialog,
        backgroundColor: const Color(0xFFA31525),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}