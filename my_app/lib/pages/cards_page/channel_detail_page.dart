// lib/pages/cards_page/channel_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shimmer/shimmer.dart';
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
import 'widgets/stats_widget.dart';
import 'widgets/engagement_chart.dart';
import 'widgets/social_links.dart';
import 'widgets/channel_members.dart';
import 'widgets/playlist_section.dart';

class ChannelDetailPage extends StatefulWidget {
  final Channel channel;

  const ChannelDetailPage({super.key, required this.channel});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentContentType = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isSubscribed = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _notificationsEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isFavorite = ValueNotifier<bool>(false);
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;

  bool _isLoading = false;
  bool _showFullDescription = false;
  int _selectedStatPeriod = 0;
  double _appBarElevation = 0;
  bool _showAppBarTitle = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isSubscribed.value = widget.channel.isSubscribed;
    _isFavorite.value = widget.channel.isFavorite;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _scrollController.addListener(() {
      setState(() {
        _appBarElevation = _scrollController.offset > 100 ? 4 : 0;
        _showAppBarTitle = _scrollController.offset > 150;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _currentContentType.dispose();
    _isSubscribed.dispose();
    _notificationsEnabled.dispose();
    _isFavorite.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadChannelPosts(),
        _loadChannelArticles(),
        _loadChannelStats(),
        _loadChannelMembers()
      ]);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadChannelPosts() async {
    try {
      final posts = await ApiService.getChannelPosts(
        widget.channel.id.toString(),
      );
      if (mounted) {
        Provider.of<ChannelPostsProvider>(
          context,
          listen: false,
        ).loadPostsForChannel(widget.channel.id, posts);
      }
    } catch (e) {
      print('Error loading channel posts: $e');
    }
  }

  Future<void> _loadChannelArticles() async {
    try {
      final articles = await ApiService.getChannelArticles(
        widget.channel.id.toString(),
      );
      if (mounted) {
        Provider.of<ArticlesProvider>(
          context,
          listen: false,
        ).loadArticlesForChannel(widget.channel.id, articles);
      }
    } catch (e) {
      print('Error loading channel articles: $e');
    }
  }

  Future<void> _loadChannelStats() async {
    // Simulate loading additional stats
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _loadChannelMembers() async {
    // Simulate loading channel members
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _toggleSubscription() async {
    _isSubscribed.value = !_isSubscribed.value;
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSubscribed.value
                ? '✅ Подписались на ${widget.channel.title}'
                : '❌ Отписались от ${widget.channel.title}',
          ),
          backgroundColor: _isSubscribed.value
              ? Colors.green
              : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    _isFavorite.value = !_isFavorite.value;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite.value
                ? '❤️ Добавлено в избранное'
                : '💔 Удалено из избранного',
          ),
          backgroundColor: _isFavorite.value
              ? Colors.pink
              : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _toggleNotifications() async {
    _notificationsEnabled.value = !_notificationsEnabled.value;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _notificationsEnabled.value
                ? '🔔 Уведомления включены'
                : '🔕 Уведомления отключены',
          ),
          backgroundColor: _notificationsEnabled.value
              ? Colors.blue
              : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _addPost(
      String title,
      String description,
      String hashtags,
      ) async {
    if (!mounted) return;

    final channelPostsProvider = Provider.of<ChannelPostsProvider>(
      context,
      listen: false,
    );
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    final hashtagsArray = hashtags
        .split(' ')
        .where((tag) => tag.isNotEmpty)
        .toList();

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
        'channel_image': widget.channel.imageUrl,
      };

      channelPostsProvider.addPostToChannel(widget.channel.id, channelPost);
      newsProvider.addNews(channelPost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📝 Пост успешно создан!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Error creating post: $e');
      _addLocalPost(
        title,
        description,
        hashtagsArray,
        channelPostsProvider,
        newsProvider,
      );
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
      'channel_image': widget.channel.imageUrl,
    };

    channelPostsProvider.addPostToChannel(widget.channel.id, newPost);
    newsProvider.addNews(newPost);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: const Text('📝 Пост создан локально'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _addArticle(Article article) async {
    if (!mounted) return;

    final articlesProvider = Provider.of<ArticlesProvider>(
      context,
      listen: false,
    );

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
        'channel_image': widget.channel.imageUrl,
      };

      articlesProvider.addArticleToChannel(widget.channel.id, channelArticle);
      articlesProvider.addArticle(channelArticle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📄 Статья успешно создана!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
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
      "channel_image": widget.channel.imageUrl,
    };

    articlesProvider.addArticleToChannel(widget.channel.id, newArticle);
    articlesProvider.addArticle(newArticle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('📄 Статья создана локально'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
        categories: const [
          'YouTube',
          'Бизнес',
          'Программирование',
          'Общение',
          'Спорт',
          'Игры',
          'Тактика',
          'Аналитика',
        ],
        emojis: const ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'],
        onArticleAdded: _addArticle,
        userName: "Администратор канала",
        channelColor: widget.channel.cardColor,
      ),
    );
  }

  void _showContentTypeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
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
              const SizedBox(height: 20),
              Text(
                'Создать контент',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              _buildContentTypeOption(
                icon: Icons.playlist_play,
                title: 'Создать плейлист',
                subtitle: 'Соберите коллекцию видео',
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog();
                },
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom : 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Создать плейлист',
          style: TextStyle(color: widget.channel.cardColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Название плейлиста',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🎵 Плейлист создан'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.channel.cardColor,
            ),
            child: const Text('Создать', style: TextStyle(color: Colors.white)),
          ),
        ],
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
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContentTypeChange(int index) {
    _currentContentType.value = index;
  }

  Future<void> _shareChannel() async {
    try {
      await Share.share(
        'Посмотрите канал "${widget.channel.title}"!\n\n${widget.channel.description}',
        subject: 'Канал: ${widget.channel.title}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ошибка при попытке поделиться'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showChannelOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
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
            const SizedBox(height: 20),
            Text(
              'Опции канала',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.report, color: Colors.orange[300]),
              title: Text('Пожаловаться', style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red[300]),
              title: Text('Заблокировать канал', style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirmation();
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.blue[300]),
              title: Text('Скопировать ссылку', style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
              onTap: () {
                Navigator.pop(context);
                _copyLinkToClipboard();
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code, color: Colors.green[300]),
              title: Text('Показать QR-код', style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
              onTap: () {
                Navigator.pop(context);
                _showQRCode();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Пожаловаться на канал',
          style: TextStyle(color: widget.channel.cardColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите причину жалобы:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ...['Спам', 'Мошенничество', 'Неуместный контент', 'Другое']
                .map((reason) => ListTile(
              title: Text(reason),
              leading: Radio<String>(
                value: reason,
                groupValue: '',
                onChanged: (value) {},
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Жалоба отправлена: $reason'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ))
                .toList(),
          ],
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

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заблокировать канал?'),
        content: Text(
          'Вы больше не будете видеть контент канала "${widget.channel.title}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Канал "${widget.channel.title}" заблокирован'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text(
              'Заблокировать',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLinkToClipboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ссылка скопирована в буфер обмена'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR-код канала',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 150,
                    color: widget.channel.cardColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.channel.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Отсканируйте для быстрого доступа',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.channel.cardColor,
                ),
                child: const Text('Закрыть', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDescription() {
    setState(() {
      _showFullDescription = !_showFullDescription;
    });
  }

  void _changeStatPeriod(int period) {
    setState(() {
      _selectedStatPeriod = period;
    });
  }

  Widget _buildLoadingIndicator() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Channel info shimmer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            flexibleSpace: FlexibleSpaceBar(
              background: ChannelHeader(channel: widget.channel),
              title: _showAppBarTitle
                  ? Text(
                widget.channel.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
                  : null,
              centerTitle: true,
            ),
            backgroundColor: widget.channel.cardColor,
            elevation: _appBarElevation,
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: _isFavorite,
                builder: (context, isFavorite, child) {
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                    tooltip: isFavorite ? 'В избранном' : 'Добавить в избранное',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareChannel,
                tooltip: 'Поделиться',
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: _showChannelOptions,
                tooltip: 'Опции',
              ),
            ],
          ),

          if (_isLoading)
            SliverToBoxAdapter(child: _buildLoadingIndicator())
          else
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Информация о канале
                    _buildChannelInfoSection(),

                    // Статистика канала
                    _buildStatsSection(),

                    // Участники канала
                    _buildMembersSection(),

                    // Плейлисты
                    _buildPlaylistsSection(),

                    // Кнопки действий
                    _buildActionButtonsSection(),

                    // Табы контента
                    ValueListenableBuilder<int>(
                      valueListenable: _currentContentType,
                      builder: (context, currentIndex, child) {
                        return ContentTabs(
                          currentIndex: currentIndex,
                          onTabChanged: _handleContentTypeChange,
                          channelColor: widget.channel.cardColor,
                        );
                      },
                    ),

                    // Контент
                    Consumer2<ChannelPostsProvider, ArticlesProvider>(
                      builder: (context, postsProvider, articlesProvider, child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: _currentContentType,
                          builder: (context, currentIndex, child) {
                            return currentIndex == 0
                                ? PostsList(
                              posts: postsProvider.getPostsForChannel(
                                widget.channel.id,
                              ),
                              channel: widget.channel,
                              emptyMessage:
                              'Пока нет постов. Будьте первым, кто поделится новостью!',
                            )
                                : ArticlesGrid(
                              articles: articlesProvider
                                  .getArticlesForChannel(
                                widget.channel.id,
                              ),
                              channel: widget.channel,
                              emptyMessage:
                              'Пока нет статей. Создайте первую статью для этого канала!',
                            );
                          },
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

      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _showContentTypeDialog,
          backgroundColor: widget.channel.cardColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28),
          elevation: 4,
          highlightElevation: 8,
        ),
      ),
    );
  }

  Widget _buildChannelInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'О КАНАЛЕ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.channel.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: _showFullDescription ? null : 3,
            overflow: _showFullDescription ? null : TextOverflow.ellipsis,
          ),
          if (widget.channel.description.length > 150)
            TextButton(
              onPressed: _toggleDescription,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
              ),
              child: Text(
                _showFullDescription ? 'Свернуть' : 'Читать далее',
                style: TextStyle(
                  color: widget.channel.cardColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.people_alt,
            '${_formatNumber(widget.channel.subscribers)} подписчиков',
          ),
          _buildInfoRow(Icons.video_library, '${widget.channel.videos} видео'),
          _buildInfoRow(
            Icons.calendar_today,
            'Создан: ${_formatDate(DateTime(2022, 3, 15))}',
          ),

          // Социальные ссылки
          if (widget.channel.socialMedia.isNotEmpty)
            SocialLinks(channel: widget.channel),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'СТАТИСТИКА КАНАЛА',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.bar_chart_rounded,
                size: 16,
                color: widget.channel.cardColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Периоды статистики
          Row(
            children: [
              _buildStatPeriodButton('Неделя', 0),
              const SizedBox(width: 8),
              _buildStatPeriodButton('Месяц', 1),
              const SizedBox(width: 8),
              _buildStatPeriodButton('Год', 2),
            ],
          ),
          const SizedBox(height: 16),

          // Виджеты статистики
          const Row(
            children: [
              Expanded(
                child: StatsWidget(
                  title: 'Просмотры',
                  value: '12.4K',
                  icon: Icons.visibility,
                  trend: 12.5,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsWidget(
                  title: 'Лайки',
                  value: '2.8K',
                  icon: Icons.favorite,
                  trend: 8.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: StatsWidget(
                  title: 'Комментарии',
                  value: '456',
                  icon: Icons.comment,
                  trend: -3.4,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsWidget(
                  title: 'Вовлеченность',
                  value: '8.2%',
                  icon: Icons.trending_up,
                  trend: 5.7,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          EngagementChart(channel: widget.channel),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'УЧАСТНИКИ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatNumber(125)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.channel.cardColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChannelMembers(channel: widget.channel),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Показать всех',
                style: TextStyle(color: widget.channel.cardColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ПЛЕЙЛИСТЫ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatNumber(8)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.channel.cardColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PlaylistSection(channel: widget.channel),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Все плейлисты',
                style: TextStyle(color: widget.channel.cardColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPeriodButton(String text, int period) {
    final isSelected = _selectedStatPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeStatPeriod(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.channel.cardColor.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? widget.channel.cardColor : Colors.grey[300]!,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? widget.channel.cardColor : Colors.grey[600],
            ),
          ),
        ),
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSubscribed,
              builder: (context, isSubscribed, child) {
                return ElevatedButton(
                  onPressed: _toggleSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSubscribed
                        ? Colors.grey[200]
                        : widget.channel.cardColor,
                    foregroundColor: isSubscribed
                        ? Colors.grey[700]
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSubscribed ? Icons.check : Icons.person_add_alt_1,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSubscribed ? 'ПОДПИСАН' : 'ПОДПИСАТЬСЯ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          ValueListenableBuilder<bool>(
            valueListenable: _notificationsEnabled,
            builder: (context, notificationsEnabled, child) {
              return _buildIconButton(
                icon: notificationsEnabled
                    ? Icons.notifications
                    : Icons.notifications_off,
                onPressed: _toggleNotifications,
                tooltip: 'Уведомления',
                color: notificationsEnabled
                    ? widget.channel.cardColor
                    : Colors.grey[600],
              );
            },
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.chat,
            onPressed: () {},
            tooltip: 'Чат',
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: color ?? Colors.grey[700],
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(12),
        ),
        tooltip: tooltip,
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}