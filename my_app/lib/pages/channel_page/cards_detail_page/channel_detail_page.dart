import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

import '../../../providers/channel_provider/channel_detail_provider.dart';
import '../../../providers/articles_provider.dart';
import '../../../providers/news_providers/news_provider.dart';
import '../../../providers/channel_provider/channel_posts_provider.dart';
import '../../../providers/channel_provider/channel_state_provider.dart';
import '../../articles_pages/models/article.dart';
import '../../articles_pages/widgets/add_article_dialog.dart';
import 'models/channel.dart';
import 'models/chat_message.dart';

// Импорты виджетов
import 'widgets/shared/channel_header.dart';
import 'widgets/shared/content_tabs.dart';
import 'widgets/content_widgets/posts_list.dart';
import 'widgets/content_widgets/articles_grid.dart';
import 'widgets/shared/channel_members.dart';
import 'dialogs/notification_settings_bottom_sheet.dart';
import 'dialogs/chat_dialog.dart';

// Импорты новых компонентов
import 'widgets/page_sections/channel_info_section.dart';
import 'widgets/page_sections/action_buttons_section.dart';
import 'dialogs/content_type_dialog.dart';
import 'dialogs/channel_options_dialog.dart';

// Импорты вынесенных виджетов контента
import 'models/channel_detail_state.dart';


class ChannelDetailPage extends StatefulWidget {
  final Channel channel;

  const ChannelDetailPage({super.key, required this.channel});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ ОТСТУПОВ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  // НОВЫЙ МЕТОД: Загрузка изображений (локальных и сетевых)
  Widget _buildChannelImage(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    print('🖼️ Loading channel detail image: $imageUrl');

    try {
      if (imageUrl.startsWith('http')) {
        // Сетевые изображения
        return Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Network image error: $error');
            return _buildErrorImage(width: width, height: height);
          },
        );
      } else {
        // Локальные assets
        return Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Asset image error: $error for path: $imageUrl');
            return _buildErrorImage(width: width, height: height);
          },
        );
      }
    } catch (e) {
      print('❌ Exception loading image: $e');
      return _buildErrorImage(width: width, height: height);
    }
  }

  Widget _buildErrorImage({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            color: Colors.grey[500],
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Изображение\nне загружено',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Виджет поля поиска для AppBar
  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск в канале...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider(
      create: (context) => ChannelDetailProvider(widget.channel),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF5F5F5),
                Color(0xFFE8E8E8),
              ],
            ),
          ),
          child: _ChannelDetailContent(
            channel: widget.channel,
            animationController: _animationController,
            showSearchBar: _showSearchBar,
            searchController: _searchController,
            searchQuery: _searchQuery,
            onToggleSearch: () => setState(() => _showSearchBar = !_showSearchBar),
            buildChannelImage: _buildChannelImage,
          ),
        ),
      ),
    );
  }
}

class _ChannelDetailContent extends StatefulWidget {
  final Channel channel;
  final AnimationController animationController;
  final bool showSearchBar;
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onToggleSearch;
  final Widget Function(String imageUrl, {double? width, double? height, BoxFit fit}) buildChannelImage;

  const _ChannelDetailContent({
    required this.channel,
    required this.animationController,
    required this.showSearchBar,
    required this.searchController,
    required this.searchQuery,
    required this.onToggleSearch,
    required this.buildChannelImage,
  });

  @override
  State<_ChannelDetailContent> createState() => _ChannelDetailContentState();
}

class _ChannelDetailContentState extends State<_ChannelDetailContent> {
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController = TextEditingController();
  final TextEditingController _postHashtagsController = TextEditingController();

  // ТАКИЕ ЖЕ ОТСТУПЫ КАК В ПРОФИЛЕ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
    final channelDetailProvider = Provider.of<ChannelDetailProvider>(context, listen: false);

    _initializeChannelState(channelStateProvider);
    _syncProviderStates(channelStateProvider, channelDetailProvider);
  }

  void _initializeChannelState(ChannelStateProvider provider) {
    provider.initializeChannelIfNeeded(
      widget.channel.id.toString(),
      defaultAvatar: widget.channel.imageUrl,
      defaultCover: widget.channel.coverImageUrl,
      defaultTags: widget.channel.tags,
    );
  }

  void _syncProviderStates(ChannelStateProvider stateProvider, ChannelDetailProvider detailProvider) {
    final avatarUrl = stateProvider.getAvatarForChannel(widget.channel.id.toString());
    if (detailProvider.currentAvatarUrl != avatarUrl) {
      detailProvider.setAvatarUrl(avatarUrl);
    }

    final coverUrl = stateProvider.getCoverForChannel(widget.channel.id.toString());
    if (detailProvider.currentCoverUrl != coverUrl) {
      detailProvider.setCoverUrl(coverUrl);
    }

    final hashtags = stateProvider.getHashtagsForChannel(widget.channel.id.toString());
    if (!_listEquals(detailProvider.currentHashtags, hashtags)) {
      detailProvider.setHashtags(hashtags);
    }
  }

  bool _listEquals(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _postTitleController.dispose();
    _postDescriptionController.dispose();
    _postHashtagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChannelDetailProvider, ChannelStateProvider>(
      builder: (context, provider, stateProvider, child) {
        final state = provider.state;
        final theme = Theme.of(context);
        final horizontalPadding = _getHorizontalPadding(context);
        final contentMaxWidth = _getContentMaxWidth(context);

        return Stack(
          children: [
            CustomScrollView(
              controller: provider.scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                // APP BAR КАК В CARDS PAGE
                SliverToBoxAdapter(
                  child: _buildAppBar(context, provider, state, horizontalPadding),
                ),

                // ОБЛОЖКА С АВАТАРКОЙ
                SliverToBoxAdapter(
                  child: _buildCoverWithAvatar(context, provider, state, horizontalPadding),
                ),

                if (state.isLoading)
                  _buildLoadingSliver()
                else
                  _buildContentSliver(
                    context,
                    provider,
                    stateProvider,
                    state,
                    theme,
                    horizontalPadding,
                    contentMaxWidth,
                  ),
              ],
            ),
            _buildFloatingActionButtons(context, provider, state),
            _buildScrollToTopButton(provider, state),
          ],
        );
      },
    );
  }

  // APP BAR КАК В CARDS PAGE
  Widget _buildAppBar(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelDetailState state,
      double horizontalPadding,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          // КНОПКА BACK СЛЕВА
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),

          // Заголовок
          if (!widget.showSearchBar) ...[
            const Text(
              'Профиль',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],

          // Поле поиска или кнопки
          if (widget.showSearchBar)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchField(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                    onPressed: widget.onToggleSearch,
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  onPressed: widget.onToggleSearch,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: state.isFavorite ? Colors.red : Colors.black,
                      size: 18,
                    ),
                  ),
                  onPressed: provider.toggleFavorite,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  onPressed: () => _showChannelOptions(context, provider),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ОБЛОЖКА С АВАТАРКОЙ ВЫРОВНЕННОЙ ПО НАЗВАНИЮ
  Widget _buildCoverWithAvatar(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelDetailState state,
      double horizontalPadding,
      ) {
    final coverUrl = provider.currentCoverUrl ?? widget.channel.coverImageUrl;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ОБЛОЖКА
            Container(
              height: 140,
              width: double.infinity,
              child: coverUrl != null && coverUrl.isNotEmpty
                  ? widget.buildChannelImage(coverUrl, height: 140, fit: BoxFit.cover)
                  : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.channel.cardColor,
                      _darkenColor(widget.channel.cardColor, 0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Градиентный оверлей
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // АВАТАРКА И НАЗВАНИЕ - ВЫРОВНЕНЫ ПО ЦЕНТРУ
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // АВАТАРКА
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.buildChannelImage(
                        widget.channel.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // НАЗВАНИЕ КАНАЛА
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.channel.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${widget.channel.title.toLowerCase().replaceAll(' ', '')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: widget.searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск в канале...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () => widget.searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
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
      ChannelStateProvider stateProvider,
      ChannelDetailState state,
      ThemeData theme,
      double horizontalPadding,
      double contentMaxWidth,
      ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: 0, // Убрали отступ сверху, так как обложка уже есть
          bottom: 16,
        ),
        child: Column(
          children: [
            // КАРТОЧКА С ОПИСАНИЕМ КАНАЛА
            Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildDescriptionCard(),
            ),

            const SizedBox(height: 16),

            // СТАТИСТИКА КАНАЛА
            Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildEnhancedStatsSection(),
            ),

            const SizedBox(height: 16),

            // КНОПКИ ДЕЙСТВИЙ
            Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildEnhancedActionButtons(provider, state),
            ),

            const SizedBox(height: 16),

            // ВКЛАДКИ КОНТЕНТА
            Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildEnhancedContentTabs(state, provider),
            ),

            const SizedBox(height: 16),

            // КОНТЕНТ
            Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildContentByType(context, provider, stateProvider, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // НОВАЯ КАРТОЧКА С ОПИСАНИЕМ КАНАЛА
  Widget _buildDescriptionCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: widget.channel.cardColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Описание канала',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Текст описания
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Text(
              widget.channel.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // СЕКЦИЯ СТАТИСТИКИ
  Widget _buildEnhancedStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: widget.channel.cardColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Статистика канала',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${widget.channel.subscribers}',
                  'Подписчиков',
                  Icons.people_rounded,
                  widget.channel.cardColor,
                ),
                _buildStatItem(
                  '${widget.channel.videos}',
                  'Публикаций',
                  Icons.video_library_rounded,
                  widget.channel.cardColor,
                ),
                _buildStatItem(
                  '${widget.channel.views}',
                  'Просмотров',
                  Icons.remove_red_eye_rounded,
                  widget.channel.cardColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Хештеги канала
          if (widget.channel.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.channel.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.channel.cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.channel.cardColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: widget.channel.cardColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // КНОПКИ ДЕЙСТВИЙ
  Widget _buildEnhancedActionButtons(ChannelDetailProvider provider, ChannelDetailState state) {
    return ActionButtonsSection(
      channel: widget.channel,
      provider: provider,
      state: state,
    );
  }

  // ВКЛАДКИ КОНТЕНТА
  Widget _buildEnhancedContentTabs(ChannelDetailState state, ChannelDetailProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.dynamic_feed_rounded,
                color: widget.channel.cardColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Контент канала',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Вкладки
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildEnhancedTab('Стена', 0, state.currentContentType, provider),
                _buildEnhancedTab('Статьи', 1, state.currentContentType, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTab(String text, int index, int currentIndex, ChannelDetailProvider provider) {
    final isActive = currentIndex == index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? widget.channel.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: widget.channel.cardColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => provider.changeContentType(index),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentByType(
      BuildContext context,
      ChannelDetailProvider provider,
      ChannelStateProvider stateProvider,
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
            stateProvider,
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
      ChannelStateProvider stateProvider,
      ) {
    final avatarUrl = stateProvider.getAvatarForChannel(widget.channel.id.toString());

    switch (index) {
      case 0:
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
          heroTag: 'channel_fab_${widget.channel.id}',
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
        heroTag: 'scroll_top_${widget.channel.id}',
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поиск'),
        content: const Text('Функционал поиска будет реализован позже'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Чат с каналом'),
        content: const Text('Функционал чата будет реализован позже'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        onAddArticle: () => _showAddArticlePage(context),
        onAddDiscussion: () {},
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    _postTitleController.clear();
    _postDescriptionController.clear();
    _postHashtagsController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isMobile = MediaQuery.of(context).size.width < 600;
          final screenHeight = MediaQuery.of(context).size.height;
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 100,
              vertical: isMobile ? 16 : 50,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.8,
                maxWidth: isMobile ? double.infinity : 500,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Шапка диалога
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Создать новость',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Прокручиваемое содержимое
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Заголовок
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.title, size: 16, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Заголовок новости',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: _postTitleController,
                                  decoration: const InputDecoration(
                                    hintText: 'Введите заголовок...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  maxLength: 100,
                                  buildCounter: (
                                      BuildContext context, {
                                        required int currentLength,
                                        required int? maxLength,
                                        required bool isFocused,
                                      }) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                                      child: Text(
                                        '$currentLength/$maxLength',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: currentLength > maxLength!
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Описание
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.description, size: 16, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Описание новости',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: _postDescriptionController,
                                  decoration: const InputDecoration(
                                    hintText: 'Опишите вашу новость...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 4,
                                  maxLength: 500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Хештеги
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.tag, size: 16, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text(
                                    'Хештеги',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: _postHashtagsController,
                                  decoration: const InputDecoration(
                                    hintText: '#спорт #новости #события',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                  maxLength: 100,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Вводите хештеги через пробел, начиная с #',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Кнопки действий
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Text(
                              'Отмена',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final title = _postTitleController.text.trim();
                              final description = _postDescriptionController.text.trim();
                              final hashtags = _postHashtagsController.text.trim();

                              if (title.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Введите заголовок новости'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(context);
                              _addPost(context, title, description, hashtags);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Создать',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
        },
      ),
    );
  }

  void _addPost(BuildContext context, String title, String description, String hashtags) {
    final postsProvider = Provider.of<ChannelPostsProvider>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final stateProvider = Provider.of<ChannelStateProvider>(context, listen: false);

    final hashtagsArray = hashtags
        .split(' ')
        .where((tag) => tag.isNotEmpty)
        .toList();

    try {
      final currentAvatarUrl = stateProvider.getAvatarForChannel(widget.channel.id.toString());
      final avatarToUse = currentAvatarUrl ?? widget.channel.imageUrl;

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
        'channel_avatar': avatarToUse,
        'channel_image': avatarToUse,
        'channel_id': widget.channel.id.toString(),
      };

      postsProvider.addPostToChannel(widget.channel.id, newPost);


      _showSuccessSnackbar(context, 'Новость успешно создана и опубликована на Стене!');
    } catch (e) {
      debugPrint('Error creating post: $e');
      _showSuccessSnackbar(context, 'Ошибка при создании новости');
    }
  }

  void _showAddArticlePage(BuildContext context) {
    final stateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
    final currentAvatarUrl = stateProvider.getAvatarForChannel(widget.channel.id.toString());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddArticlePage(
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
          userAvatarUrl: currentAvatarUrl,
        ),
      ),
    );
  }

  void _addArticle(BuildContext context, Article article) async {
    if (!mounted) return;

    final articlesProvider = Provider.of<ArticlesProvider>(
      context,
      listen: false,
    );
    final stateProvider = Provider.of<ChannelStateProvider>(context, listen: false);

    try {
      final currentAvatarUrl = stateProvider.getAvatarForChannel(widget.channel.id.toString());
      final avatarToUse = currentAvatarUrl ?? widget.channel.imageUrl;

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
        "image_url": avatarToUse,
        "channel_id": widget.channel.id,
        "channel_name": widget.channel.title,
        "channel_image": avatarToUse,
        'is_channel_post': true,
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

  void _saveAvatarToDatabase(String avatarUrl) {
    debugPrint('Saving avatar to database: $avatarUrl');
  }

  void _saveCoverToDatabase(String coverUrl) {
    debugPrint('Saving cover to database: $coverUrl');
  }

  void _saveHashtagsToDatabase(List<String> hashtags) {
    debugPrint('Saving hashtags to database: $hashtags');
  }
}