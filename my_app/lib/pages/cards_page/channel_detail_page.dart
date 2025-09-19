// lib/pages/cards_page/channel_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/articles_provider.dart';
import '../articles_pages/models/article.dart';
import '../articles_pages/widgets/add_article_dialog.dart';
import '../news_page/dialogs.dart';
import 'models/channel.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/channel_posts_provider.dart';
import '../../../services/api_service.dart';
import 'widgets/channel_header.dart';
import 'widgets/content_tabs.dart';
import 'widgets/posts_list.dart';
import 'widgets/articles_grid.dart';

class ChannelDetailPage extends StatefulWidget {
  final Channel channel;

  const ChannelDetailPage({super.key, required this.channel});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentContentType = 0; // 0: Посты, 1: Статьи

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadChannelPosts(),
      _loadChannelArticles(),
    ]);
  }

  Future<void> _loadChannelPosts() async {
    try {
      final posts = await ApiService.getChannelPosts(widget.channel.id.toString());
      if (mounted) {
        Provider.of<ChannelPostsProvider>(context, listen: false)
            .loadPostsForChannel(widget.channel.id, posts);
      }
    } catch (e) {
      print('Error loading channel posts: $e');
    }
  }

  Future<void> _loadChannelArticles() async {
    try {
      final articles = await ApiService.getChannelArticles(widget.channel.id.toString());
      if (mounted) {
        Provider.of<ArticlesProvider>(context, listen: false)
            .loadArticlesForChannel(widget.channel.id, articles);
      }
    } catch (e) {
      print('Error loading channel articles: $e');
    }
  }

  Future<void> _addPost(String title, String description, String hashtags) async {
    if (!mounted) return;

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
      newsProvider.addNews(channelPost);

    } catch (e) {
      print('Error creating post: $e');
      _addLocalPost(title, description, hashtagsArray, channelPostsProvider, newsProvider);
    }
  }

  void _addLocalPost(
      String title,
      String description,
      List<String> hashtagsArray,
      ChannelPostsProvider channelPostsProvider,
      NewsProvider newsProvider,
      ) {
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

  Future<void> _addArticle(Article article) async {
    if (!mounted) return;

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

      articlesProvider.addArticleToChannel(widget.channel.id, channelArticle);
      articlesProvider.addArticle(channelArticle);

    } catch (e) {
      print('Error creating article: $e');
      _addLocalArticle(article, articlesProvider);
    }
  }

  void _addLocalArticle(Article article, ArticlesProvider articlesProvider) {
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

    articlesProvider.addArticleToChannel(widget.channel.id, newArticle);
    articlesProvider.addArticle(newArticle);
  }

  void _showAddPostDialog() {
    showAddNewsDialog(
      context: context,
      onAdd: _addPost,
      primaryColor: widget.channel.cardColor,
      cardColor: Colors.white,
      textColor: const Color(0xFF333333),
      secondaryTextColor: const Color(0xFF666666),
      backgroundColor: const Color(0xFFF5F9FF),
    );
  }

  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddArticleDialog(
        categories: const ['YouTube', 'Бизнес', 'Программирование', 'Общение', 'Спорт', 'Игры', 'Тактика', 'Аналитика'],
        emojis: const ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'],
        onArticleAdded: _addArticle,
        userName: "Администратор канала",
      ),
    );
  }

  void _showContentTypeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Создать контент',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildContentTypeOption(
              icon: Icons.article_outlined,
              title: 'Создать новость',
              subtitle: 'Поделитесь новостями с сообществом',
              onTap: () {
                Navigator.pop(context);
                _showAddPostDialog();
              },
              color: widget.channel.cardColor,
            ),
            const SizedBox(height: 12),
            _buildContentTypeOption(
              icon: Icons.library_books_outlined,
              title: 'Создать статью',
              subtitle: 'Напишите подробный материал',
              onTap: () {
                Navigator.pop(context);
                _showAddArticleDialog();
              },
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.grey[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContentTypeChange(int index) {
    setState(() {
      _currentContentType = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: ChannelHeader(channel: widget.channel),
            ),
            backgroundColor: widget.channel.cardColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Информация о канале
                  _buildChannelInfoSection(),

                  // Кнопки действий
                  _buildActionButtonsSection(),

                  // Табы контента
                  ContentTabs(
                    currentIndex: _currentContentType,
                    onTabChanged: _handleContentTypeChange,
                    channelColor: widget.channel.cardColor,
                  ),

                  // Контент
                  Consumer2<ChannelPostsProvider, ArticlesProvider>(
                    builder: (context, postsProvider, articlesProvider, child) {
                      return _currentContentType == 0
                          ? PostsList(
                        posts: postsProvider.getPostsForChannel(widget.channel.id),
                        channel: widget.channel,
                        emptyMessage: 'Пока нет постов. Будьте первым, кто поделится новостью!',
                      )
                          : ArticlesGrid(
                        articles: articlesProvider.getArticlesForChannel(widget.channel.id),
                        channel: widget.channel,
                        emptyMessage: 'Пока нет статей. Создайте первую статью для этого канала!',
                      );
                    },
                  ),

                  const SizedBox(height: 24),
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
        elevation: 8,
        highlightElevation: 12,
      ),
    );
  }

  Widget _buildChannelInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 16),
          Text(
            widget.channel.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.calendar_today, 'Создан: 15 марта 2022'),
          _buildInfoRow(Icons.location_on, 'Россия, Москва'),
          _buildInfoRow(Icons.link, 'www.example.com'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
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
      ),
    );
  }
}