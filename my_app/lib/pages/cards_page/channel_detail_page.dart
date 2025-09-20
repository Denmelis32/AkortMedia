// lib/pages/cards_page/channel_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

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
  final ConfettiController _confettiController = ConfettiController();
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<Color?> _appBarColorAnimation;

  bool _isLoading = false;
  bool _showFullDescription = false;
  int _selectedStatPeriod = 0;
  double _appBarElevation = 0;
  bool _showAppBarTitle = false;
  double _headerHeight = 280;
  final Map<int, bool> _expandedSections = {
    0: false, // Статистика
    1: false, // Участники
    2: false, // Плейлисты
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isSubscribed.value = widget.channel.isSubscribed;
    _isFavorite.value = widget.channel.isFavorite;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _appBarColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.channel.cardColor.withOpacity(0.95),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _animationController.forward();
    });
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _appBarElevation = offset > 50 ? 6 : 0;
      _showAppBarTitle = offset > 100;

      // Параллакс эффект для заголовка
      if (offset <= _headerHeight - kToolbarHeight) {
        _animationController.value = offset / (_headerHeight - kToolbarHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _currentContentType.dispose();
    _isSubscribed.dispose();
    _notificationsEnabled.dispose();
    _isFavorite.dispose();
    _confettiController.dispose();
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
        _loadChannelMembers(),
        Future.delayed(const Duration(milliseconds: 500)), // Минимальная задержка для плавности
      ]);
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      _showErrorSnackbar('Ошибка загрузки данных');
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
      debugPrint('Error loading channel posts: $e');
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
      debugPrint('Error loading channel articles: $e');
    }
  }

  Future<void> _loadChannelStats() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _loadChannelMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleSubscription() async {
    final newValue = !_isSubscribed.value;
    _isSubscribed.value = newValue;

    if (newValue) {
      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(newValue ? Icons.check_circle : Icons.remove_circle,
                  color: Colors.white),
              const SizedBox(width: 8),
              Text(
                newValue
                    ? '✅ Подписались на ${widget.channel.title}'
                    : '❌ Отписались от ${widget.channel.title}',
              ),
            ],
          ),
          backgroundColor: newValue ? Colors.green : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    _isFavorite.value = !_isFavorite.value;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_isFavorite.value ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _isFavorite.value
                    ? '❤️ Добавлено в избранное'
                    : '💔 Удалено из избранного',
              ),
            ],
          ),
          backgroundColor: _isFavorite.value ? Colors.pink : Colors.grey[700],
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
          content: Row(
            children: [
              Icon(
                _notificationsEnabled.value
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _notificationsEnabled.value
                    ? '🔔 Уведомления включены'
                    : '🔕 Уведомления отключены',
              ),
            ],
          ),
          backgroundColor:
          _notificationsEnabled.value ? Colors.blue : Colors.grey[700],
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
        'channel_image': widget.channel.imageUrl,
      };

      channelPostsProvider.addPostToChannel(widget.channel.id, channelPost);
      newsProvider.addNews(channelPost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('📝 Пост успешно создан!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
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
      ScaffoldMessenger.of(context).showSnackBar(
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
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('📄 Статья успешно создана!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating article: $e');
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
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Создать контент',
                style: TextStyle(
                  fontSize: 22,
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
                gradient: LinearGradient(
                  colors: [
                    widget.channel.cardColor,
                    widget.channel.cardColor.withOpacity(0.8),
                  ],
                ),
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
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.purpleAccent],
                ),
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
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orangeAccent],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Создать плейлист',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.channel.cardColor,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Название плейлиста',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: widget.channel.cardColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: widget.channel.cardColor),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('🎵 Плейлист создан'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.channel.cardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('Создать',
                          style: TextStyle(color: Colors.white)),
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

  Widget _buildContentTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required Gradient gradient,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContentTypeChange(int index) {
    _currentContentType.value = index;
    // Плавная прокрутка к началу контента
    _scrollController.animateTo(
      280,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _shareChannel() async {
    try {
      await Share.share(
        'Посмотрите канал "${widget.channel.title}"!\n\n${widget.channel.description}\n\n#${widget.channel.title.replaceAll(' ', '')}',
        subject: 'Канал: ${widget.channel.title}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ошибка при попытке поделиться'),
          backgroundColor: Colors.red,
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
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Опции канала',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.report,
              title: 'Пожаловаться',
              color: Colors.orange,
              onTap: _showReportDialog,
            ),
            _buildOptionTile(
              icon: Icons.block,
              title: 'Заблокировать канал',
              color: Colors.red,
              onTap: _showBlockConfirmation,
            ),
            _buildOptionTile(
              icon: Icons.copy,
              title: 'Скопировать ссылку',
              color: Colors.blue,
              onTap: _copyLinkToClipboard,
            ),
            _buildOptionTile(
              icon: Icons.qr_code,
              title: 'Показать QR-код',
              color: Colors.green,
              onTap: _showQRCode,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          )),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  void _showReportDialog() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Пожаловаться на канал',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.channel.cardColor,
                ),
              ),
              const SizedBox(height: 16),
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
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ))
                  .toList(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
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

  void _showBlockConfirmation() {
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
              Icon(Icons.block, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Заблокировать канал?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Вы больше не будете видеть контент канала "${widget.channel.title}".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Канал "${widget.channel.title}" заблокирован'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Заблокировать',
                          style: TextStyle(color: Colors.white)),
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

  void _copyLinkToClipboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Ссылка скопирована в буфер обмена'),
          ],
        ),
        backgroundColor: Colors.green,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR-код канала',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 150,
                    color: widget.channel.cardColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.channel.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Отсканируйте для быстрого доступа',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.channel.cardColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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

  void _toggleSection(int sectionId) {
    setState(() {
      _expandedSections[sectionId] = !_expandedSections[sectionId]!;
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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



  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: _headerHeight,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      ChannelHeader(channel: widget.channel),
                      // Удален ConfettiWidget
                    ],
                  ),
                  title: AnimatedOpacity(
                    opacity: _showAppBarTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      widget.channel.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: _appBarColorAnimation.value,
                elevation: _appBarElevation,
                automaticallyImplyLeading: false,
                pinned: true,
                floating: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Назад',
                  ),
                  const Spacer(),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isFavorite,
                    builder: (context, isFavorite, child) {
                      return IconButton(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            if (isFavorite)
                              Positioned(
                                right: -5,
                                top: -5,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.pink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.channel.cardColor,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
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
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: currentIndex == 0
                                      ? PostsList(
                                    key: const ValueKey('posts'),
                                    posts: postsProvider.getPostsForChannel(
                                      widget.channel.id,
                                    ),
                                    channel: widget.channel,
                                    emptyMessage:
                                    'Пока нет постов. Будьте первым, кто поделится новостью!',
                                  )
                                      : ArticlesGrid(
                                    key: const ValueKey('articles'),
                                    articles: articlesProvider
                                        .getArticlesForChannel(
                                      widget.channel.id,
                                    ),
                                    channel: widget.channel,
                                    emptyMessage:
                                    'Пока нет статей. Создайте первую статью для этого канала!',
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Floating Action Button
          Positioned(
            bottom: 24,
            right: 24,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                onPressed: _showContentTypeDialog,
                backgroundColor: widget.channel.cardColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, size: 32),
                elevation: 8,
                highlightElevation: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildChannelInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'О КАНАЛЕ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.channel.cardColor,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: widget.channel.cardColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.channel.description,
            style: TextStyle(
              fontSize: 16,
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
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.people_alt_rounded,
            '${_formatNumber(widget.channel.subscribers)} подписчиков',
            widget.channel.cardColor,
          ),
          _buildInfoRow(
            Icons.video_library_rounded,
            '${widget.channel.videos} видео',
            widget.channel.cardColor,
          ),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Создан: ${_formatDate(DateTime(2022, 3, 15))}',
            widget.channel.cardColor,
          ),

          // Социальные ссылки
          if (widget.channel.socialMedia.isNotEmpty) ...[
            const SizedBox(height: 20),
            SocialLinks(channel: widget.channel),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return _buildCollapsibleSection(
      id: 0,
      title: 'СТАТИСТИКА КАНАЛА',
      icon: Icons.bar_chart_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 20),

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

          const SizedBox(height: 20),
          EngagementChart(channel: widget.channel),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return _buildCollapsibleSection(
      id: 1,
      title: 'УЧАСТНИКИ',
      count: 125,
      icon: Icons.people_rounded,
      content: Column(
        children: [
          const SizedBox(height: 16),
          ChannelMembers(channel: widget.channel),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: widget.channel.cardColor,
              ),
              child: const Text('Показать всех'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsSection() {
    return _buildCollapsibleSection(
      id: 2,
      title: 'ПЛЕЙЛИСТЫ',
      count: 8,
      icon: Icons.playlist_play_rounded,
      content: Column(
        children: [
          const SizedBox(height: 16),
          PlaylistSection(channel: widget.channel),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: widget.channel.cardColor,
              ),
              child: const Text('Все плейлисты'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required int id,
    required String title,
    required Widget content,
    int? count,
    IconData? icon,
  }) {
    final isExpanded = _expandedSections[id] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        key: ValueKey(id),
        initiallyExpanded: true,
        trailing: const SizedBox.shrink(),
        title: Row(
          children: [
            if (icon != null)
              Icon(icon, size: 18, color: widget.channel.cardColor),
            if (icon != null) const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            if (count != null)
              Text(
                _formatNumber(count),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.channel.cardColor,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: content,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.channel.cardColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? widget.channel.cardColor
                  : Colors.grey[300]!.withOpacity(0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? widget.channel.cardColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSubscribed,
              builder: (context, isSubscribed, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: isSubscribed
                        ? LinearGradient(
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[200]!,
                      ],
                    )
                        : LinearGradient(
                      colors: [
                        widget.channel.cardColor,
                        widget.channel.cardColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isSubscribed ? Colors.grey : widget.channel.cardColor)
                            .withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _toggleSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: isSubscribed ? Colors.grey[700] : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSubscribed ? Icons.check : Icons.person_add_alt_1,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isSubscribed ? 'ПОДПИСАН' : 'ПОДПИСАТЬСЯ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          ValueListenableBuilder<bool>(
            valueListenable: _notificationsEnabled,
            builder: (context, notificationsEnabled, child) {
              return _buildIconButton(
                icon: notificationsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                onPressed: _toggleNotifications,
                tooltip: 'Уведомления',
                color: notificationsEnabled
                    ? widget.channel.cardColor
                    : Colors.grey[600],
                isActive: notificationsEnabled,
              );
            },
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            icon: Icons.chat_bubble_outline_rounded,
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
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isActive
            ? Border.all(color: color ?? Colors.grey[700]!, width: 2)
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        color: color ?? Colors.grey[700],
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}