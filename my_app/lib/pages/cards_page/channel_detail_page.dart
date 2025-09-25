import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

import '../../providers/channel_detail_provider.dart';
import '../../providers/articles_provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/channel_posts_provider.dart';
import '../../services/api_service.dart';
import '../articles_pages/models/article.dart';
import '../articles_pages/widgets/add_article_dialog.dart';
import '../news_page/dialogs.dart';
import 'models/channel.dart';
import 'models/chat_message.dart';

// Импорты виджетов
import 'widgets/shared/channel_header.dart';
import 'widgets/shared/content_tabs.dart';
import 'widgets/content_widgets/posts_list.dart';
import 'widgets/content_widgets/articles_grid.dart';
import 'widgets/shared/channel_members.dart';
import 'widgets/page_sections/playlist_section.dart';
import 'dialogs/notification_settings_bottom_sheet.dart';
import 'dialogs/chat_dialog.dart';

// Импорты новых компонентов
import 'widgets/page_sections/channel_info_section.dart';
import 'widgets/page_sections/members_section.dart';
import 'widgets/page_sections/playlists_section.dart';
import 'widgets/page_sections/action_buttons_section.dart';
import 'dialogs/content_type_dialog.dart';
import 'dialogs/channel_options_dialog.dart';

// Импорты вынесенных виджетов контента
import 'models/channel_detail_state.dart';
import 'widgets/content_widgets/wall_content.dart';
import 'widgets/content_widgets/akor_content.dart';

class ChannelDetailPage extends StatefulWidget {
  final Channel channel;

  const ChannelDetailPage({super.key, required this.channel});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider(
      create: (context) => ChannelDetailProvider(widget.channel),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: _ChannelDetailContent(
          channel: widget.channel,
          animationController: _animationController,
        ),
      ),
    );
  }
}

class _ChannelDetailContent extends StatefulWidget {
  final Channel channel;
  final AnimationController animationController;

  const _ChannelDetailContent({
    required this.channel,
    required this.animationController,
  });

  @override
  State<_ChannelDetailContent> createState() => _ChannelDetailContentState();
}

class _ChannelDetailContentState extends State<_ChannelDetailContent> {
  // Переменные для хранения введенных данных
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController = TextEditingController();
  final TextEditingController _postHashtagsController = TextEditingController();

  @override
  void dispose() {
    _postTitleController.dispose();
    _postDescriptionController.dispose();
    _postHashtagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelDetailProvider>(
      builder: (context, provider, child) {
        final state = provider.state;
        final theme = Theme.of(context);

        return Stack(
          children: [
            CustomScrollView(
              controller: provider.scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                _buildAppBar(context, provider, state),
                if (state.isLoading)
                  _buildLoadingSliver()
                else
                  _buildContentSliver(context, provider, state, theme),
              ],
            ),
            _buildFloatingActionButtons(context, provider, state),
            _buildScrollToTopButton(provider, state),
          ],
        );
      },
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelDetailState state,
      ) {
    return SliverAppBar(
      expandedHeight: 280,
      flexibleSpace: FlexibleSpaceBar(
        background: ChannelHeader(
          channel: widget.channel,
          initialHashtags: const ['Flutter', 'Dart', 'MobileDev'],
          initialCoverImageUrl:
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400',
          editable: true,
        ),
        title: AnimatedOpacity(
          opacity: state.showAppBarTitle ? 1.0 : 0.0,
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
      backgroundColor: _getAppBarColor(state),
      elevation: state.appBarElevation,
      automaticallyImplyLeading: false,
      pinned: true,
      floating: false,
      actions: _buildAppBarActions(context, provider, state),
    );
  }

  Color? _getAppBarColor(ChannelDetailState state) {
    final progress = state.scrollOffset.clamp(0, 200) / 200;
    return Color.lerp(
      Colors.transparent,
      widget.channel.cardColor.withOpacity(0.95),
      progress,
    );
  }

  List<Widget> _buildAppBarActions(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelDetailState state,
      ) {
    return [
      IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Назад',
      ),
      const Spacer(),
      IconButton(
        icon: Icon(
          state.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
        onPressed: provider.toggleFavorite,
        tooltip: state.isFavorite ? 'В избранном' : 'Добавить в избранное',
      ),
      IconButton(
        icon: const Icon(Icons.share, color: Colors.white),
        onPressed: () => _shareChannel(context),
        tooltip: 'Поделиться',
      ),
      IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: () => _showChannelOptions(context, provider),
        tooltip: 'Опции',
      ),
    ];
  }

  SliverToBoxAdapter _buildLoadingSliver() {
    return SliverToBoxAdapter(
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
    );
  }

  SliverToBoxAdapter _buildContentSliver(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelDetailState state,
      ThemeData theme,
      ) {
    return SliverToBoxAdapter(
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
            ChannelInfoSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            MembersSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            PlaylistsSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            ActionButtonsSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            ContentTabs(
              currentIndex: state.currentContentType,
              onTabChanged: provider.changeContentType,
              channelColor: widget.channel.cardColor,
              tabs: const ['Стена', 'Акорта', 'Статьи'],
            ),

            _buildContentByType(context, provider, state),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContentByType(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelDetailState state,
      ) {
    return Consumer2<ChannelPostsProvider, ArticlesProvider>(
      builder: (context, postsProvider, articlesProvider, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getContentByIndex(
            state.currentContentType,
            postsProvider,
            articlesProvider,
            provider,
          ),
        );
      },
    );
  }

  Widget _getContentByIndex(
      int index,
      ChannelPostsProvider postsProvider,
      ArticlesProvider articlesProvider,
      ChannelDetailProvider channelProvider,
      ) {
    switch (index) {
      case 0:
        return WallContent(channel: widget.channel);

      case 1:
        return AkorContent(channel: widget.channel);

      case 2:
        return ArticlesGrid(
          key: const ValueKey('articles'),
          articles: articlesProvider.getArticlesForChannel(widget.channel.id),
          channel: widget.channel,
          emptyMessage:
          'Пока нет статей. Создайте первую статью для этого канала!',
        );

      default:
        return const SizedBox(key: ValueKey('empty'));
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${date.day}.${date.month}.${date.year}';
    } else if (difference.inDays > 7) {
      return '${date.day}.${date.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'только что';
    }
  }

  Widget _buildFloatingActionButtons(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelDetailState state,
      ) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: widget.animationController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton(
          onPressed: () => _showContentTypeDialog(context, provider),
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
    );
  }

  Widget _buildScrollToTopButton(
      ChannelDetailProvider provider,
      ChannelDetailState state,
      ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: 24,
      bottom: state.showScrollToTop ? 100 : -100,
      child: FloatingActionButton(
        onPressed: provider.scrollToTop,
        backgroundColor: widget.channel.cardColor,
        foregroundColor: Colors.white,
        mini: true,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  void _shareChannel(BuildContext context) async {
    try {
      await Share.share(
        'Посмотрите канал "${widget.channel.title}"!\n\n${widget.channel.description}',
        subject: 'Канал: ${widget.channel.title}',
      );
    } catch (e) {
      // ignore
    }
  }

  void _showChannelOptions(
      BuildContext context,
      ChannelDetailProvider provider,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChannelOptionsDialog(
        channel: widget.channel,
        onReport: () => _showReportDialog(context),
        onBlock: () => _showBlockConfirmation(context),
        onCopyLink: () => _copyLinkToClipboard(context),
        onShowQR: () => _showQRCode(context),
        onNotificationSettings: () =>
            _showNotificationSettings(context, provider),
      ),
    );
  }

  void _showContentTypeDialog(
      BuildContext context,
      ChannelDetailProvider provider,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ContentTypeDialog(
        channel: widget.channel,
        onAddPost: () => _showAddPostDialog(context),
        onAddArticle: () => _showAddArticleDialog(context),
        onAddDiscussion: () {}, // Убрано создание обсуждений
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    // Сброс контроллеров при открытии диалога
    _postTitleController.clear();
    _postDescriptionController.clear();
    _postHashtagsController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Создать новость'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _postTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок новости',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _postDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание новости',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _postHashtagsController,
                  decoration: const InputDecoration(
                    labelText: 'Хештеги (через пробел)',
                    border: OutlineInputBorder(),
                  ),
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
                  final title = _postTitleController.text.trim();
                  final description = _postDescriptionController.text.trim();
                  final hashtags = _postHashtagsController.text.trim();

                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Введите заголовок новости')),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  _addPost(context, title, description, hashtags);
                },
                child: const Text('Создать новость'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addPost(BuildContext context, String title, String description, String hashtags) {
    final postsProvider = Provider.of<ChannelPostsProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    final hashtagsArray = hashtags
        .split(' ')
        .where((tag) => tag.isNotEmpty)
        .toList();

    try {
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

      // Публикуем новость и в Акорт и на Стену
      postsProvider.addPostToChannel(widget.channel.id, newPost);
      newsProvider.addNews(newPost);

      _showSuccessSnackbar(context, 'Новость успешно создана и опубликована в Акорт и на Стене!');
    } catch (e) {
      debugPrint('Error creating post: $e');
      _showSuccessSnackbar(context, 'Ошибка при создании новости');
    }
  }

  void _showAddArticleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddArticleDialog(
        categories: const [
          'YouTube',
          'Бизнес',
          'Игры',
          'Программирование',
          'Спорт',
          'Общение',
          'Общее'
        ],
        emojis: const ['📊', '⭐', '🏆', '🚀', '💡', '📱', '🌐', '💻', '📈', '🎯', '🎮', '⚽'],
        onArticleAdded: (article) => _addArticle(context, article),
        userName: "Администратор канала",
        channelColor: widget.channel.cardColor,
      ),
    );
  }

  void _addArticle(BuildContext context, Article article) async {
    if (!mounted) return;

    final articlesProvider = Provider.of<ArticlesProvider>(
      context,
      listen: false,
    );

    try {
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

      _showSuccessSnackbar(context, 'Статья успешно создана и добавлена на Стену!');
    } catch (e) {
      debugPrint('Error creating article: $e');
      _showSuccessSnackbar(context, 'Статья добавлена локально');
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на канал'),
        content: const Text(
          'Выберите причину жалобы. Мы рассмотрим вашу жалобу в течение 24 часов.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackbar(
                context,
                'Жалоба отправлена на рассмотрение',
              );
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context) {
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackbar(context, 'Канал заблокирован');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Заблокировать',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLinkToClipboard(BuildContext context) {
    FlutterClipboard.copy(
      'https://app.example.com/channel/${widget.channel.id}',
    ).then((_) {
      _showSuccessSnackbar(context, 'Ссылка скопирована в буфер обмена');
    });
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR-код канала',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.channel.cardColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.qr_code,
                    size: 100,
                    color: widget.channel.cardColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.channel.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Отсканируйте QR-код для доступа'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings(
      BuildContext context,
      ChannelDetailProvider provider,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Настройки уведомлений',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.channel.cardColor,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Уведомления о новых постах'),
              value: provider.state.notificationsEnabled,
              onChanged: (value) => provider.toggleNotifications(),
            ),
            SwitchListTile(
              title: const Text('Уведомления о комментариях'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Email-уведомления'),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Готово'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
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
}