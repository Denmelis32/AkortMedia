// lib/pages/cards_page/channel_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

import '../../providers/articles_provider.dart';
import '../articles_pages/models/article.dart';
import '../articles_pages/widgets/add_article_dialog.dart';
import '../news_page/dialogs.dart';
import 'models/channel.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/channel_posts_provider.dart';
import '../../../services/api_service.dart';
import 'models/chat_message.dart';
import 'models/discussion.dart';
import 'widgets/channel_header.dart';
import 'widgets/content_tabs.dart';
import 'widgets/posts_list.dart';
import 'widgets/articles_grid.dart';
import 'widgets/channel_members.dart';
import 'widgets/playlist_section.dart';
import 'widgets/notification_settings_bottom_sheet.dart';
import 'widgets/chat_dialog.dart';
import 'widgets/discussions_list.dart';

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
  late Animation<Color?> _appBarColorAnimation;

  bool _isLoading = false;
  bool _showFullDescription = false;
  double _appBarElevation = 0;
  bool _showAppBarTitle = false;
  double _headerHeight = 320;
  final Map<int, bool> _expandedSections = {
    0: false, // Участники
    1: false, // Плейлисты
  };

  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  bool _showScrollToTop = false;

  final ValueNotifier<bool> _isEditingDescription = ValueNotifier<bool>(false);
  final TextEditingController _descriptionController = TextEditingController();

  // Состояние для чата
  final List<ChatMessage> _chatMessages = [];
  final List<Discussion> _discussions = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isSubscribed.value = widget.channel.isSubscribed;
    _isFavorite.value = widget.channel.isFavorite;
    _descriptionController.text = widget.channel.description;

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
      _addWelcomeMessage();
      _loadDiscussions();
    });
  }

  void _addWelcomeMessage() {
    _chatMessages.add(ChatMessage(
      text: 'Добро пожаловать в чат канала "${widget.channel.title}"! 🎉\nЗдесь вы можете общаться с другими участниками сообщества.',
      isMe: false,
      timestamp: DateTime.now(),
      senderName: 'Система',
      senderId: 'system_welcome',
    ));
  }

  void _loadDiscussions() {
    _discussions.addAll([
      Discussion(
        id: '1',
        title: 'Обсуждение нового функционала',
        author: 'Алексей Петров',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        commentsCount: 15,
        likes: 42,
        isPinned: true,
      ),
      Discussion(
        id: '2',
        title: 'Идеи для улучшения платформы',
        author: 'Мария Иванова',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        commentsCount: 8,
        likes: 27,
      ),
      Discussion(
        id: '3',
        title: 'Вопросы по использованию API',
        author: 'Дмитрий Сидоров',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        commentsCount: 23,
        likes: 19,
      ),
    ]);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    _scrollOffset.value = offset;

    setState(() {
      _appBarElevation = offset > 50 ? 4 : 0;
      _showAppBarTitle = offset > 100;
      _showScrollToTop = offset > 500;

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
    _animationController.dispose();
    _scrollOffset.dispose();
    _isEditingDescription.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadChannelPosts(),
        _loadChannelArticles(),
        Future.delayed(const Duration(milliseconds: 300)),
      ]);
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadChannelPosts() async {
    try {
      final posts = await ApiService.getChannelPosts(widget.channel.id.toString());
      if (mounted) {
        Provider.of<ChannelPostsProvider>(context, listen: false)
            .loadPostsForChannel(widget.channel.id, posts);
      }
    } catch (e) {
      debugPrint('Error loading channel posts: $e');
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
      debugPrint('Error loading channel articles: $e');
    }
  }

  Future<void> _toggleSubscription() async {
    final newValue = !_isSubscribed.value;
    _isSubscribed.value = newValue;

    // Анимация подписки
    if (newValue) {
      _showSubscriptionAnimation();
    }
  }

  void _showSubscriptionAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: widget.channel.cardColor,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Подписка оформлена!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.channel.cardColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Теперь вы будете получать уведомления о новых публикациях',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.channel.cardColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Отлично', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _toggleFavorite() async {
    _isFavorite.value = !_isFavorite.value;
  }

  Future<void> _toggleNotifications() async {
    _notificationsEnabled.value = !_notificationsEnabled.value;
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
        'channel_image': widget.channel.imageUrl,
      };

      channelPostsProvider.addPostToChannel(widget.channel.id, channelPost);
      newsProvider.addNews(channelPost);

      _showSuccessSnackbar('Новость успешно опубликована!');

    } catch (e) {
      debugPrint('Error creating post: $e');
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
      'channel_image': widget.channel.imageUrl,
    };

    channelPostsProvider.addPostToChannel(widget.channel.id, newPost);
    newsProvider.addNews(newPost);
    _showSuccessSnackbar('Новость добавлена локально');
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
        'channel_image': widget.channel.imageUrl,
      };

      articlesProvider.addArticleToChannel(widget.channel.id, channelArticle);
      articlesProvider.addArticle(channelArticle);

      _showSuccessSnackbar('Статья успешно опубликована!');

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
    _showSuccessSnackbar('Статья добавлена локально');
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                icon: Icons.forum_outlined,
                title: 'Создать обсуждение',
                subtitle: 'Начните новую дискуссию',
                onTap: _createNewDiscussion,
                color: Colors.orange,
              ),
              const SizedBox(height: 32),
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
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
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
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewDiscussion() {
    Navigator.pop(context);

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
                'Новое обсуждение',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.channel.cardColor,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Заголовок обсуждения',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
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
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: widget.channel.cardColor),
                  ),
                ),
                maxLines: 4,
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
                        _addNewDiscussion();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.channel.cardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('Создать', style: TextStyle(color: Colors.white)),
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

  void _addNewDiscussion() {
    final newDiscussion = Discussion(
      id: '${_discussions.length + 1}',
      title: 'Новое обсуждение',
      author: 'Вы',
      createdAt: DateTime.now(),
      commentsCount: 0,
      likes: 0,
    );

    setState(() {
      _discussions.insert(0, newDiscussion);
    });

    _currentContentType.value = 2; // Обсуждения
    _showSuccessSnackbar('Обсуждение создано!');
  }

  void _handleContentTypeChange(int index) {
    _currentContentType.value = index;
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
      // Без уведомления об ошибке
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
            _buildOptionTile(
              icon: Icons.settings,
              title: 'Настройки уведомлений',
              color: Colors.blueGrey,
              onTap: _showNotificationSettings,
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
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
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
                onTap: () => Navigator.pop(context),
              ))
                  .toList(),
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
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Заблокировать', style: TextStyle(color: Colors.white)),
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
    FlutterClipboard.copy('https://app.example.com/channel/${widget.channel.id}');
    _showSuccessSnackbar('Ссылка скопирована в буфер обмена');
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

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationSettingsBottomSheet(
        channel: widget.channel,
        isNotificationsEnabled: _notificationsEnabled.value,
        onNotificationsChanged: (value) {
          _notificationsEnabled.value = value;
        },
      ),
    );
  }

  void _toggleDescription() {
    setState(() {
      _showFullDescription = !_showFullDescription;
    });
  }

  void _toggleEditDescription() {
    _isEditingDescription.value = !_isEditingDescription.value;
    if (!_isEditingDescription.value) {
      _saveDescriptionChanges();
    }
  }

  void _saveDescriptionChanges() {
    // Логика сохранения описания
    _showSuccessSnackbar('Описание обновлено');
  }

  void _toggleSection(int sectionId) {
    setState(() {
      _expandedSections[sectionId] = !_expandedSections[sectionId]!;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (context) => ChatDialog(
        channel: widget.channel,
        messages: _chatMessages,
        onSendMessage: _sendChatMessage,
      ),
    );
  }

  void _sendChatMessage(String message) {
    if (message.trim().isEmpty) return;

    final newMessage = ChatMessage(
      text: message,
      isMe: true,
      timestamp: DateTime.now(),
      senderName: 'Вы',
      senderId: 'current_user_id',
    );

    setState(() {
      _chatMessages.add(newMessage);
    });

    _simulateSystemResponse();
  }

  void _simulateSystemResponse() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final responses = [
        'Отличное сообщение! 👍',
        'Спасибо за участие в обсуждении! 💬',
        'Интересная мысль! 🤔',
        'Рады видеть вас в нашем чате! 🎯',
        'Продолжайте в том же духе! 🔥'
      ];

      final randomResponse = responses[DateTime.now().millisecond % responses.length];

      final systemMessage = ChatMessage(
        text: randomResponse,
        isMe: false,
        timestamp: DateTime.now(),
        senderName: 'Модератор',
        senderId: 'moderator_id',
      );

      setState(() {
        _chatMessages.add(systemMessage);
      });
    });
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
                  background: ChannelHeader(
                    channel: widget.channel,
                    onFollow: _toggleSubscription,
                    isSubscribed: _isSubscribed.value,
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(widget.channel.cardColor),
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
                        _buildChannelInfoSection(),
                        _buildMembersSection(),
                        _buildPlaylistsSection(),
                        _buildActionButtonsSection(),

                        ValueListenableBuilder<int>(
                          valueListenable: _currentContentType,
                          builder: (context, currentIndex, child) {
                            return ContentTabs(
                              currentIndex: currentIndex,
                              onTabChanged: _handleContentTypeChange,
                              channelColor: widget.channel.cardColor,
                              tabs: const ['Новости', 'Статьи', 'Обсуждения'],
                            );
                          },
                        ),

                        Consumer2<ChannelPostsProvider, ArticlesProvider>(
                          builder: (context, postsProvider, articlesProvider, child) {
                            return ValueListenableBuilder<int>(
                              valueListenable: _currentContentType,
                              builder: (context, currentIndex, child) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: _getContentByIndex(currentIndex, postsProvider, articlesProvider),
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

          Positioned(
            bottom: 24,
            right: 24,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                onPressed: _showContentTypeDialog,
                backgroundColor: widget.channel.cardColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add, size: 32),
                elevation: 8,
                highlightElevation: 16,
              ),
            ),
          ),

          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, child) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                right: 24,
                bottom: _showScrollToTop ? 100 : -100,
                child: FloatingActionButton(
                  onPressed: _scrollToTop,
                  backgroundColor: widget.channel.cardColor,
                  foregroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.arrow_upward),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getContentByIndex(int index, ChannelPostsProvider postsProvider, ArticlesProvider articlesProvider) {
    switch (index) {
      case 0:
        return PostsList(
          key: const ValueKey('posts'),
          posts: postsProvider.getPostsForChannel(widget.channel.id),
          channel: widget.channel,
          emptyMessage: 'Пока нет постов. Будьте первым, кто поделится новостью!',
        );
      case 1:
        return ArticlesGrid(
          key: const ValueKey('articles'),
          articles: articlesProvider.getArticlesForChannel(widget.channel.id),
          channel: widget.channel,
          emptyMessage: 'Пока нет статей. Создайте первую статью для этого канала!',
        );
      case 2:
        return DiscussionsList(
          key: const ValueKey('discussions'),
          discussions: _discussions,
          channel: widget.channel,
          onDiscussionTap: (discussion) => _showDiscussionDetail(discussion),
        );
      default:
        return const SizedBox();
    }
  }

  void _showDiscussionDetail(Discussion discussion) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                discussion.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.channel.cardColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    discussion.author,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(discussion.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Это пример содержимого обсуждения. Здесь будет отображаться полный текст обсуждения и комментарии участников.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${discussion.likes}'),
                  const SizedBox(width: 16),
                  Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${discussion.commentsCount}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
            ],
          ),
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
              ValueListenableBuilder<bool>(
                valueListenable: _isEditingDescription,
                builder: (context, isEditing, child) {
                  return IconButton(
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      size: 18,
                      color: widget.channel.cardColor,
                    ),
                    onPressed: _toggleEditDescription,
                    tooltip: isEditing ? 'Сохранить' : 'Редактировать',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: _isEditingDescription,
            builder: (context, isEditing, child) {
              return isEditing
                  ? TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.channel.cardColor),
                  ),
                ),
              )
                  : Text(
                widget.channel.description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: _showFullDescription ? null : 3,
                overflow: _showFullDescription ? null : TextOverflow.ellipsis,
              );
            },
          ),
          if (widget.channel.description.length > 150 && !_isEditingDescription.value)
            TextButton(
              onPressed: _toggleDescription,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
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
          _buildInfoRow(Icons.people_alt_rounded, '${_formatNumber(widget.channel.subscribers)} подписчиков', widget.channel.cardColor),
          _buildInfoRow(Icons.video_library_rounded, '${widget.channel.videos} видео', widget.channel.cardColor),
          _buildInfoRow(Icons.calendar_today_rounded, 'Создан: ${_formatDate(DateTime(2022, 3, 15))}', widget.channel.cardColor),
          if (widget.channel.socialMedia.isNotEmpty) ...[
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return _buildCollapsibleSection(
      id: 0,
      title: 'УЧАСТНИКИ',
      count: 125,
      icon: Icons.people_rounded,
      content: Column(
        children: [
          const SizedBox(height: 16),
          ChannelMembers(channel: widget.channel),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.channel.cardColor,
                  side: BorderSide(color: widget.channel.cardColor),
                ),
                child: const Text('Пригласить'),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: widget.channel.cardColor),
                child: const Text('Показать всех'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsSection() {
    return _buildCollapsibleSection(
      id: 1,
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
              style: TextButton.styleFrom(foregroundColor: widget.channel.cardColor),
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
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        key: ValueKey(id),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) => _expandedSections[id] = expanded,
        trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[600]),
        title: Row(
          children: [
            if (icon != null) Icon(icon, size: 18, color: widget.channel.cardColor),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.channel.cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatNumber(count),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.channel.cardColor,
                  ),
                ),
              ),
          ],
        ),
        children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: content)],
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
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
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
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSubscribed,
            builder: (context, isSubscribed, child) {
              return SizedBox(
                width: 180,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: isSubscribed
                        ? LinearGradient(colors: [Colors.grey[300]!, Colors.grey[200]!])
                        : LinearGradient(colors: [widget.channel.cardColor, widget.channel.cardColor.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isSubscribed ? Colors.grey : widget.channel.cardColor).withOpacity(0.3),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isSubscribed ? Icons.check : Icons.person_add_alt_1, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isSubscribed ? 'ПОДПИСАН' : 'ПОДПИСАТЬСЯ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _notificationsEnabled,
            builder: (context, notificationsEnabled, child) {
              return _buildIconButton(
                icon: notificationsEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                onPressed: _toggleNotifications,
                tooltip: 'Уведомления',
                color: notificationsEnabled ? widget.channel.cardColor : Colors.grey[600],
                isActive: notificationsEnabled,
              );
            },
          ),
          _buildIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: _showChatDialog,
            tooltip: 'Чат',
            color: Colors.blue,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
        border: isActive ? Border.all(color: color ?? Colors.grey[700]!, width: 2) : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: color ?? Colors.grey[700],
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        tooltip: tooltip,
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}