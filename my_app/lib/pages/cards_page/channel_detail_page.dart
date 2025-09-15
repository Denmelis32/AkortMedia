// lib/pages/cards_page/channel_detail_page.dart
import 'package:flutter/material.dart';
import 'package:my_app/pages/news_page/dialogs.dart';
import 'package:provider/provider.dart';
import 'models/channel.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/channel_posts_provider.dart';
import '../../../services/api_service.dart';
// Импортируем диалоги из news_page

class ChannelDetailPage extends StatefulWidget {
  final Channel channel;

  const ChannelDetailPage({super.key, required this.channel});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _backgroundColor = const Color(0xFFF5F9FF);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _secondaryTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChannelPosts();
    });
  }

  Future<void> _loadChannelPosts() async {
    try {
      final posts = await ApiService.getChannelPosts(widget.channel.id.toString());
      // Загружаем посты ТОЛЬКО для этого канала
      Provider.of<ChannelPostsProvider>(context, listen: false)
          .loadPostsForChannel(widget.channel.id, posts);
    } catch (e) {
      print('Error loading channel posts: $e');
    }
  }

  Future<void> _addPost(String title, String description, String hashtags) async {
    final channelPostsProvider = Provider.of<ChannelPostsProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    // Преобразуем хештеги из строки в массив для API
    final hashtagsArray = hashtags.split(' ').where((tag) => tag.isNotEmpty).toList();

    try {
      // Создаем пост через API
      final newPost = await ApiService.createChannelPost({
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
        'channel_id': widget.channel.id,
      });

      // Явно добавляем хештеги в правильном формате для канала
      final channelPost = {
        ...newPost,
        'hashtags': hashtagsArray, // гарантируем правильный формат
        'comments': [],
        'is_channel_post': true,
        'channel_name': widget.channel.title,
      };

      // Добавляем пост ТОЛЬКО в этот конкретный канал
      channelPostsProvider.addPostToChannel(widget.channel.id, channelPost);

      // Также добавляем в общие новости с правильными хештегами
      final newsPost = {
        ...newPost,
        'hashtags': hashtagsArray, // гарантируем правильный формат
        'comments': [],
        'is_channel_post': true,
        'channel_name': widget.channel.title,
      };
      newsProvider.addNews(newsPost);

    } catch (e) {
      print('Error creating post: $e');

      // Локальное добавление в случае ошибки сети
      final newPost = {
        "id": "channel-${DateTime.now().millisecondsSinceEpoch}",
        "title": title,
        "description": description,
        "hashtags": hashtagsArray, // используем массив и для локального хранения
        "likes": 0,
        "author_name": "Администратор канала",
        "created_at": DateTime.now().toIso8601String(),
        "comments": [],
        "is_channel_post": true,
        "channel_name": widget.channel.title,
      };

      // Добавляем ТОЛЬКО в этот канал
      channelPostsProvider.addPostToChannel(widget.channel.id, newPost);

      // Также добавляем в общие новости
      newsProvider.addNews(newPost);
    }
  }


  List<String> _parseHashtags(dynamic hashtags) {
    if (hashtags is String) {
      return hashtags.split(' ').where((tag) => tag.isNotEmpty).toList();
    } else if (hashtags is List) {
      return hashtags.map((tag) => tag.toString()).where((tag) => tag.isNotEmpty).toList();
    }
    return [];
  }

  void _showAddPostDialog() {
    showAddNewsDialog(
      context: context,
      onAdd: _addPost,
      primaryColor: widget.channel.cardColor,
      // Используем цвет канала
      cardColor: _cardColor,
      textColor: _textColor,
      secondaryTextColor: _secondaryTextColor,
      backgroundColor: _backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final channelPostsProvider = Provider.of<ChannelPostsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Заголовок с обложкой канала
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.channel.cardColor.withOpacity(0.9),
                      widget.channel.cardColor.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Фоновое изображение с размытием
                    Positioned.fill(
                      child: Image.network(
                        widget.channel.imageUrl,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.2),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    // Затемнение градиента
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    // Контент заголовка
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Аватар канала
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                widget.channel.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Название канала
                          Text(
                            widget.channel.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Статистика канала
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatItem(
                                icon: Icons.people_outline,
                                value: '${widget.channel.subscribers}',
                                label: 'подписчиков',
                              ),
                              const SizedBox(width: 20),
                              _buildStatItem(
                                icon: Icons.video_library_outlined,
                                value: '${widget.channel.videos}',
                                label: 'видео',
                              ),
                              const SizedBox(width: 20),
                              _buildStatItem(
                                icon: Icons.visibility_outlined,
                                value: '2.5M',
                                label: 'просмотров',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание канала
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),

                  // Кнопки действий
                  _buildActionButtons(),
                  const SizedBox(height: 32),

                  // Вкладки
                  _buildTabSection(),
                  const SizedBox(height: 24),

                  // Контент сообщества (теперь показываем посты)
                  _buildPostsContent(channelPostsProvider.getPostsForChannel(widget.channel.id)),
                ],
              ),
            ),
          ),
        ],
      ),
      // Кнопка добавления поста
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: widget.channel.cardColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
        elevation: 4,
      ),
    );
  }

  Widget _buildStatItem(
      {required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О КАНАЛЕ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.channel.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Дополнительная информация
          _buildInfoRow(Icons.calendar_today, 'Создан: 15 марта 2022'),
          _buildInfoRow(Icons.location_on, 'Россия, Москва'),
          _buildInfoRow(Icons.link, 'www.example.com'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.channel.cardColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: widget.channel.cardColor.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, size: 20),
                SizedBox(width: 8),
                Text(
                  'ПОДПИСАТЬСЯ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Кнопка уведомлений
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, size: 24),
            color: Colors.grey[700],
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Кнопка меню
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 24),
            color: Colors.grey[700],
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Expanded(
            child: _buildTabButton('Сообщество', true),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? widget.channel.cardColor : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? widget.channel.cardColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsContent(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Посты канала',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Пока нет постов. Будьте первым, кто поделится новостью!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: posts.map((post) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.channel.cardColor.withOpacity(0.1),
                    backgroundImage: NetworkImage(widget.channel.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.channel.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formatDate(DateTime.parse(post['created_at'])),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post['description'],
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              if (post['hashtags'] != null && post['hashtags'].isNotEmpty)
                Wrap(
                  children: _parseHashtags(post['hashtags']).map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.channel.cardColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: widget.channel.cardColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up_outlined, size: 20,
                        color: Colors.grey[600]),
                    onPressed: () {},
                  ),
                  Text('${post['likes'] ?? 0}'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.comment_outlined, size: 20,
                        color: Colors.grey[600]),
                    onPressed: () {},
                  ),
                  Text('${post['comments']?.length ?? 0}'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Добавляем вспомогательные функции для форматирования даты
String formatDate(DateTime date) {
  return '${date.day}.${date.month}.${date.year}';
}

String getTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays}д назад';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}ч назад';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}м назад';
  } else {
    return 'Только что';
  }
}