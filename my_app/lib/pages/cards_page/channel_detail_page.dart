// lib/pages/cards_page/channel_detail_page.dart
import 'package:flutter/material.dart';
import 'package:my_app/pages/news_page/dialogs.dart';
import 'package:provider/provider.dart';
import '../../providers/articles_provider.dart';
import '../articles_pages/models/article.dart';
import '../articles_pages/widgets/add_article_dialog.dart';
import 'models/channel.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/channel_posts_provider.dart';
import '../../../services/api_service.dart';

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

  int _currentContentType = 0; // 0: Посты, 1: Статьи
  final List<String> _contentTypes = ['Сообщество', 'Статьи'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChannelPosts();
      _loadChannelArticles();
    });
  }

  Future<void> _loadChannelPosts() async {
    try {
      final posts = await ApiService.getChannelPosts(widget.channel.id.toString());
      Provider.of<ChannelPostsProvider>(context, listen: false)
          .loadPostsForChannel(widget.channel.id, posts);
    } catch (e) {
      print('Error loading channel posts: $e');
    }
  }

  Future<void> _loadChannelArticles() async {
    try {
      final articles = await ApiService.getChannelArticles(widget.channel.id.toString());
      Provider.of<ArticlesProvider>(context, listen: false)
          .loadArticlesForChannel(widget.channel.id, articles);
    } catch (e) {
      print('Error loading channel articles: $e');
    }
  }

  Future<void> _addPost(String title, String description, String hashtags) async {
    final channelPostsProvider = Provider.of<ChannelPostsProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    final hashtagsArray = hashtags.split(' ').where((tag) => tag.isNotEmpty).toList();

    try {
      final newPost = await ApiService.createChannelPost({
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
        'channel_id': widget.channel.id,
      });

      final channelPost = {
        ...newPost,
        'hashtags': hashtagsArray,
        'comments': [],
        'is_channel_post': true,
        'channel_name': widget.channel.title,
      };

      channelPostsProvider.addPostToChannel(widget.channel.id, channelPost);

      final newsPost = {
        ...newPost,
        'hashtags': hashtagsArray,
        'comments': [],
        'is_channel_post': true,
        'channel_name': widget.channel.title,
      };
      newsProvider.addNews(newsPost);

    } catch (e) {
      print('Error creating post: $e');

      final newPost = {
        "id": "channel-${DateTime.now().millisecondsSinceEpoch}",
        "title": title,
        "description": description,
        "hashtags": hashtagsArray,
        "likes": 0,
        "author_name": "Администратор канала",
        "created_at": DateTime.now().toIso8601String(),
        "comments": [],
        'is_channel_post': true,
        'channel_name': widget.channel.title,
      };

      channelPostsProvider.addPostToChannel(widget.channel.id, newPost);
      newsProvider.addNews(newPost);
    }
  }

  Future<void> _addArticle(Article article) async {
    final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);

    try {
      final newArticle = await ApiService.createChannelArticle({
        'title': article.title,
        'description': article.description,
        'content': article.content,
        'emoji': article.emoji,
        'category': article.category,
        'channel_id': widget.channel.id,
      });

      final channelArticle = {
        ...newArticle,
        'channel_id': widget.channel.id,
        'channel_name': widget.channel.title,
      };

      // Добавляем статью и в канал, и в общий список
      articlesProvider.addArticleToChannel(widget.channel.id, channelArticle);
      articlesProvider.addArticle(channelArticle);

    } catch (e) {
      print('Error creating article: $e');

      final newArticle = {
        "id": "article-${DateTime.now().millisecondsSinceEpoch}",
        "title": article.title,
        "description": article.description,
        "content": article.content,
        "emoji": article.emoji,
        "category": article.category,
        "views": 0,
        "likes": 0,
        "author": "Администратор канала",
        "publish_date": DateTime.now().toIso8601String(),
        "image_url": widget.channel.imageUrl,
        "channel_id": widget.channel.id,
        "channel_name": widget.channel.title,
      };

      // Добавляем статью и в канал, и в общий список
      articlesProvider.addArticleToChannel(widget.channel.id, newArticle);
      articlesProvider.addArticle(newArticle);
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
      cardColor: _cardColor,
      textColor: _textColor,
      secondaryTextColor: _secondaryTextColor,
      backgroundColor: _backgroundColor,
    );
  }

  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddArticleDialog(
        categories: ['YouTube', 'Бизнес', 'Программирование', 'Общение', 'Спорт', 'Игры', 'Тактика', 'Аналитика'],
        emojis: ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'],
        onArticleAdded: _addArticle,
        userName: "Администратор канала",
      ),
    );
  }

  void _showContentTypeDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Создать новость'),
              onTap: () {
                Navigator.pop(context);
                _showAddPostDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: const Text('Создать статью'),
              onTap: () {
                Navigator.pop(context);
                _showAddArticleDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final channelPostsProvider = Provider.of<ChannelPostsProvider>(context);
    final articlesProvider = Provider.of<ArticlesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
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
                    Positioned.fill(
                      child: Image.network(
                        widget.channel.imageUrl,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.2),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                  _buildTabSection(),
                  const SizedBox(height: 24),
                  _buildContentSection(channelPostsProvider, articlesProvider),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showContentTypeDialog,
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
        children: _contentTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;
          return Expanded(
            child: _buildTabButton(text, _currentContentType == index, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive, int index) {
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
        onPressed: () {
          setState(() {
            _currentContentType = index;
          });
        },
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

  Widget _buildContentSection(ChannelPostsProvider postsProvider, ArticlesProvider articlesProvider) {
    if (_currentContentType == 0) {
      // Показываем посты
      final posts = postsProvider.getPostsForChannel(widget.channel.id);
      return _buildPostsContent(posts);
    } else {
      // Показываем статьи
      final articles = articlesProvider.getArticlesForChannel(widget.channel.id);
      return _buildArticlesContent(articles);
    }
  }

  Widget _buildPostsContent(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return _buildEmptyContent('Посты канала', 'Пока нет постов. Будьте первым, кто поделится новостью!');
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
                    icon: Icon(Icons.thumb_up_outlined, size: 20, color: Colors.grey[600]),
                    onPressed: () {},
                  ),
                  Text('${post['likes'] ?? 0}'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
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

  Widget _buildArticlesContent(List<Map<String, dynamic>> articles) {
    if (articles.isEmpty) {
      return _buildEmptyContent('Статьи канала', 'Пока нет статей. Создайте первую статью для этого канала!');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildArticleCard(article);
      },
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final gradientColors = _getArticleGradientColors(article['category'] ?? 'YouTube');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradientColors[0].withOpacity(0.95),
                    gradientColors[1].withOpacity(0.95),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(article['image_url'] ?? widget.channel.imageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  (article['category'] ?? 'Статья').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  article['emoji'] ?? '📝',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['title'] ?? 'Без названия',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article['description'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _buildArticleStatItem(
                                Icons.remove_red_eye_rounded,
                                '${article['views'] ?? 0}',
                                Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 12),
                              _buildArticleStatItem(
                                Icons.favorite_rounded,
                                '${article['likes'] ?? 0}',
                                Colors.white.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent(String title, String message) {
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
            _currentContentType == 0 ? Icons.article_outlined : Icons.library_books_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
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

  List<Color> _getArticleGradientColors(String category) {
    final Map<String, List<Color>> gradients = {
      'YouTube': [const Color(0xFFFF0000), const Color(0xFFFF5252)],
      'Бизнес': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
      'Программирование': [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
      'Общение': [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
      'Спорт': [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
      'Игры': [const Color(0xFF9C27B0), const Color(0xFFE1BEE7)],
      'Тактика': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      'Аналитика': [const Color(0xFF059669), const Color(0xFF10B981)],
    };

    return gradients[category] ?? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
  }
}

String formatDate(DateTime date) {
  return '${date.day}.${date.month}.${date.year}';
}