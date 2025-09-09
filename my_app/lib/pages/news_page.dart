import 'package:flutter/material.dart';
import '../models/news_post.dart';
import 'home_page.dart';
import '../models/news_post.dart';



const backgroundColor = Color(0xFFFAEBD7); // #faebd7

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
  final List<NewsPost> _posts = [];
  final TextEditingController _postController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPosting = false;
  bool _showPostForm = false;

  void _togglePostForm() {
    setState(() {
      _showPostForm = !_showPostForm;
    });
  }

  void _addPost() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isPosting = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        final newPost = NewsPost(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: widget.userName,
          content: _postController.text,
          timestamp: DateTime.now(),
        );

        setState(() {
          _posts.insert(0, newPost);
          _postController.clear();
          _isPosting = false;
          _showPostForm = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пост добавлен!'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _cancelPost() {
    setState(() {
      _showPostForm = false;
      _postController.clear();
    });
  }

  void _likePost(int index) {
    setState(() {
      final post = _posts[index];
      if (post.likedBy.contains(widget.userEmail)) {
        _posts[index] = post.copyWith(
          likes: post.likes - 1,
          likedBy: List.from(post.likedBy)..remove(widget.userEmail),
        );
      } else {
        _posts[index] = post.copyWith(
          likes: post.likes + 1,
          likedBy: List.from(post.likedBy)..add(widget.userEmail),
        );
      }
    });
  }

  void _deletePost(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor, // Новый фон для диалога
        title: const Text('Удалить пост?'),
        content: const Text('Вы уверены, что хотите удалить этот пост?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _posts.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пост удален')),
              );
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 7) return '${difference.inDays} д назад';

    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: backgroundColor, // Новый фон для всей страницы
          child: Column(
            children: [
              // Форма для добавления поста
              if (_showPostForm)
                Container(
                  color: backgroundColor, // Новый фон для формы
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _postController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Напишите футбольную новость...',
                            hintText: 'Поделитесь последними новостями, прогнозами или мнениями',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white, // Белый фон для текстового поля
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите текст поста';
                            }
                            if (value.trim().length < 5) {
                              return 'Пост должен содержать минимум 5 символов';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancelPost,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                                onPressed: _isPosting ? null : _addPost,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isPosting
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                                    : const Text(
                                  'Опубликовать',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              if (_showPostForm) const Divider(height: 1),

              // Список постов
              Expanded(
                child: _posts.isEmpty && !_showPostForm
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Пока нет новостей',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Нажмите + чтобы добавить первую новость!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final isLiked = post.likedBy.contains(widget.userEmail);

                    return Card(
                      key: ValueKey(post.id),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white, // Белый фон для карточек постов
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок поста
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: primaryColor,
                                  child: Text(
                                    post.userName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                        post.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _formatDateTime(post.timestamp),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (post.userName == widget.userName)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _deletePost(index),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Текст поста
                            Text(
                              post.content,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Кнопки взаимодействий
                            Row(
                              children: [
                                // Кнопка лайка
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () => _likePost(index),
                                ),
                                Text(
                                  '${post.likes}',
                                  style: TextStyle(
                                    color: isLiked ? Colors.red : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Кнопка комментария - неактивна
                                IconButton(
                                  icon: Icon(
                                    Icons.comment,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: null,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const Spacer(),

                                // Кнопка поделиться - неактивна
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: null,
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
            ],
          ),
        ),

        // Плавающая кнопка добавления
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _togglePostForm,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            child: Icon(_showPostForm ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}