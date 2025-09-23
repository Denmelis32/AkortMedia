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
import 'models/discussion.dart';

// Импорты виджетов
import 'widgets/channel_header.dart';
import 'widgets/content_tabs.dart';
import 'widgets/posts_list.dart';
import 'widgets/articles_grid.dart';
import 'widgets/channel_members.dart';
import 'widgets/playlist_section.dart';
import 'widgets/notification_settings_bottom_sheet.dart';
import 'widgets/chat_dialog.dart';
import 'widgets/discussions_list.dart';

// Импорты новых компонентов
import 'widgets/sections/channel_info_section.dart';
import 'widgets/sections/members_section.dart';
import 'widgets/sections/playlists_section.dart';
import 'widgets/sections/action_buttons_section.dart';
import 'widgets/dialogs/content_type_dialog.dart';
import 'widgets/dialogs/channel_options_dialog.dart';

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
  @override
  void dispose() {
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
  SliverAppBar _buildAppBar(BuildContext context, ChannelDetailProvider provider, ChannelDetailState state) {
    return SliverAppBar(
      expandedHeight: 280,
      flexibleSpace: FlexibleSpaceBar(
        background: ChannelHeader(
          channel: widget.channel,
          initialHashtags: const ['Flutter', 'Dart', 'MobileDev'],
          initialCoverImageUrl: 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400',
          initialAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face', // НОВЫЙ АВАТАР
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

  List<Widget> _buildAppBarActions(BuildContext context, ChannelDetailProvider provider, ChannelDetailState state) {
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
              valueColor: AlwaysStoppedAnimation<Color>(widget.channel.cardColor),
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
            // Секция информации о канале
            ChannelInfoSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            // Секция участников
            MembersSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            // Секция плейлистов
            PlaylistsSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            // Секция кнопок действий
            ActionButtonsSection(
              channel: widget.channel,
              provider: provider,
              state: state,
            ),

            // Вкладки контента
            ContentTabs(
              currentIndex: state.currentContentType,
              onTabChanged: provider.changeContentType,
              channelColor: widget.channel.cardColor,
              tabs: const ['Новости', 'Статьи', 'Обсуждения'],
            ),

            // Динамический контент
            _buildContentByType(context, provider, state),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContentByType(BuildContext context, ChannelDetailProvider provider, ChannelDetailState state) {
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
          discussions: channelProvider.state.discussions,
          channel: widget.channel,
          onDiscussionTap: (discussion) => _showDiscussionDetail(context, discussion),
        );
      default:
        return const SizedBox(key: ValueKey('empty'));
    }
  }

  Widget _buildFloatingActionButtons(BuildContext context, ChannelDetailProvider provider, ChannelDetailState state) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add, size: 32),
          elevation: 8,
          highlightElevation: 16,
        ),
      ),
    );
  }

  Widget _buildScrollToTopButton(ChannelDetailProvider provider, ChannelDetailState state) {
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

  // === МЕТОДЫ ДИАЛОГОВ И ДЕЙСТВИЙ ===

  void _shareChannel(BuildContext context) async {
    try {
      await Share.share(
        'Посмотрите канал "${widget.channel.title}"!\n\n${widget.channel.description}\n\n#${widget.channel.title.replaceAll(' ', '')}',
        subject: 'Канал: ${widget.channel.title}',
      );
    } catch (e) {
      // Без уведомления об ошибке
    }
  }

  void _showChannelOptions(BuildContext context, ChannelDetailProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChannelOptionsDialog(
        channel: widget.channel,
        onReport: () => _showReportDialog(context),
        onBlock: () => _showBlockConfirmation(context),
        onCopyLink: () => _copyLinkToClipboard(context),
        onShowQR: () => _showQRCode(context),
        onNotificationSettings: () => _showNotificationSettings(context, provider),
      ),
    );
  }

  void _showContentTypeDialog(BuildContext context, ChannelDetailProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ContentTypeDialog(
        channel: widget.channel,
        onAddPost: () => _showAddPostDialog(context),
        onAddArticle: () => _showAddArticleDialog(context),
        onAddDiscussion: () => _createNewDiscussion(context, provider),
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    final postsProvider = Provider.of<ChannelPostsProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    showAddNewsDialog(
      context: context,
      onAdd: (title, description, hashtags) => _addPost(
          context, title, description, hashtags, postsProvider, newsProvider
      ),
      primaryColor: widget.channel.cardColor,
      cardColor: Colors.white,
      textColor: const Color(0xFF333333),
      secondaryTextColor: const Color(0xFF666666),
      backgroundColor: const Color(0xFFF5F9FF),
    );
  }

  void _addPost(
      BuildContext context,
      String title,
      String description,
      String hashtags,
      ChannelPostsProvider postsProvider,
      NewsProvider newsProvider,
      ) async {
    if (!mounted) return;

    final hashtagsArray = hashtags.split(' ').where((tag) => tag.isNotEmpty).toList();

    try {
      final newPost = await ApiService.createChannelPost({
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
        'channel_id': widget.channel.id,
      });

      if (!mounted) return;

      final channelPost = {
        ...newPost,
        'hashtags': hashtagsArray,
        'comments': [],
        'is_channel_post': true,
        'channel_name': widget.channel.title,
        'channel_image': widget.channel.imageUrl,
      };

      postsProvider.addPostToChannel(widget.channel.id, channelPost);
      newsProvider.addNews(channelPost);

      _showSuccessSnackbar(context, 'Новость успешно опубликована!');

    } catch (e) {
      debugPrint('Error creating post: $e');
      if (mounted) {
        _addLocalPost(context, title, description, hashtagsArray, postsProvider, newsProvider);
      }
    }
  }

  void _addLocalPost(
      BuildContext context,
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
    _showSuccessSnackbar(context, 'Новость добавлена локально');
  }

  void _showAddArticleDialog(BuildContext context) {
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
        onArticleAdded: (article) => _addArticle(context, article),
        userName: "Администратор канала",
        channelColor: widget.channel.cardColor,
      ),
    );
  }

  void _addArticle(BuildContext context, Article article) async {
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

      if (!mounted) return;

      final channelArticle = {
        ...newArticle,
        'channel_id': widget.channel.id,
        'channel_name': widget.channel.title,
        'channel_image': widget.channel.imageUrl,
      };

      articlesProvider.addArticleToChannel(widget.channel.id, channelArticle);
      articlesProvider.addArticle(channelArticle);

      _showSuccessSnackbar(context, 'Статья успешно опубликована!');

    } catch (e) {
      debugPrint('Error creating article: $e');
      if (mounted) {
        _addLocalArticle(context, article, articlesProvider);
      }
    }
  }

  void _addLocalArticle(BuildContext context, Article article, ArticlesProvider articlesProvider) {
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
    _showSuccessSnackbar(context, 'Статья добавлена локально');
  }

  void _createNewDiscussion(BuildContext context, ChannelDetailProvider provider) {
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
                        _addNewDiscussion(context, provider);
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

  void _addNewDiscussion(BuildContext context, ChannelDetailProvider provider) {
    final newDiscussion = Discussion(
      id: '${provider.state.discussions.length + 1}',
      title: 'Новое обсуждение',
      author: 'Вы',
      createdAt: DateTime.now(),
      commentsCount: 0,
      likes: 0,
    );

    provider.addDiscussion(newDiscussion);
    _showSuccessSnackbar(context, 'Обсуждение создано!');
  }

  void _showDiscussionDetail(BuildContext context, Discussion discussion) {
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
                  CircleAvatar(radius: 16),
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на канал'),
        content: const Text('Выберите причину жалобы. Мы рассмотрим вашу жалобу в течение 24 часов.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackbar(context, 'Жалоба отправлена на рассмотрение');
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
        content: Text('Вы больше не будете видеть контент канала "${widget.channel.title}".'),
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
            child: const Text('Заблокировать', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _copyLinkToClipboard(BuildContext context) {
    FlutterClipboard.copy('https://app.example.com/channel/${widget.channel.id}').then((_) {
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

  void _showNotificationSettings(BuildContext context, ChannelDetailProvider provider) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}