import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../communities/models/community.dart';
import 'package:my_app/providers/communities_provider%20/community_state_provider.dart';
import 'discussion.dart';
import 'create_discussion_button.dart';
import 'discussion_card.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _isFavorite = false;
  bool _isMember = false;
  final List<Discussion> _discussions = [];

  // ОТСТУПЫ: ДЛЯ ТЕЛЕФОНА 0, ДЛЯ КОМПЬЮТЕРА КАК БЫЛО
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 0; // НА ТЕЛЕФОНЕ БЕЗ ОТСТУПОВ
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 840;
    if (width > 1000) return 840;
    if (width > 700) return 840;
    return double.infinity;
  }

  // Размеры шрифтов как в profile_page
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 20;
    if (width > 800) return 18;
    if (width > 600) return 16;
    return 16;
  }

  double _getDescriptionFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 16;
    if (width > 800) return 15;
    if (width > 600) return 14;
    return 14;
  }

  double _getContentFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 14;
    if (width > 800) return 13;
    if (width > 600) return 12;
    return 12;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCommunityData();
    _loadDiscussions();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCommunityData() async {
    // Загрузка дополнительных данных о сообществе
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _loadDiscussions() {
    // Тестовые данные обсуждений
    setState(() {
      _discussions.addAll([
        Discussion(
          id: '1',
          title: 'Flutter 3.0 - что нового и стоит ли обновляться?',
          content: 'Вышла новая версия Flutter 3.0 с поддержкой новых платформ и улучшениями производительности. Кто уже обновился? Какие впечатления? Есть ли критические баги? Поделитесь опытом миграции со старых версий.',
          imageUrl: 'https://avatars.mds.yandex.net/i?id=436dea0047dbc38fb8b10f9424ee76ed_l-4590371-images-thumbs&n=13',
          authorName: 'Анна Козлова',
          authorAvatarUrl: 'https://avatars.mds.yandex.net/i?id=6b4025dc5557cb5c94ac6e8eae4fbb37_l-9181638-images-thumbs&n=13',
          communityId: widget.community.id.toString(),
          communityName: widget.community.title,
          tags: ['flutter3', 'обновление', 'новости'],
          likesCount: 47,
          commentsCount: 23,
          viewsCount: 289,
          isPinned: true,
          allowComments: true,
          isLiked: true,
          isBookmarked: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Discussion(
          id: '2',
          title: 'Манчестер юнайтед победит Ливерпуль?',
          content: 'крутые бобры вижу и вы',
          imageUrl: 'https://avatars.mds.yandex.net/i?id=7fbf90fe711a546e3496edc03fa5c0c0_sr-4415285-images-thumbs&n=13',
          authorName: 'Сергей Новиков',
          authorAvatarUrl: 'https://avatars.mds.yandex.net/i?id=598f039122f976bb757018c0d0441a1a_l-5876532-images-thumbs&n=13',
          communityId: widget.community.id.toString(),
          communityName: widget.community.title,
          tags: ['statemanagement', 'riverpod', 'bloc', 'выбор'],
          likesCount: 52,
          commentsCount: 31,
          viewsCount: 324,
          isPinned: false,
          allowComments: true,
          isLiked: true,
          isBookmarked: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Discussion(
          id: '3',
          title: 'Лучшие пакеты для работы с API в 2024',
          content: 'Какие пакеты вы используете для работы с REST API? Интересуют современные решения с хорошей поддержкой, документацией и возможностями кэширования. Стоит ли использовать dio или есть более современные альтернативы?',
          imageUrl: 'https://avatars.mds.yandex.net/i?id=2713dcc98aec5ff3010e822d7d7349fbff129456-12714255-images-thumbs&n=13',
          authorName: 'Иван Кузнецов',
          authorAvatarUrl: 'https://avatars.mds.yandex.net/i?id=dc68d5f07bfdc06bb3824eae7911f4df_l-3566335-images-thumbs&n=13',
          communityId: widget.community.id.toString(),
          communityName: widget.community.title,
          tags: ['api', 'packages', 'http', 'dio'],
          likesCount: 38,
          commentsCount: 27,
          viewsCount: 245,
          isPinned: false,
          allowComments: true,
          isLiked: false,
          isBookmarked: false,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Color _getAppBarColor() {
    final progress = _scrollOffset.clamp(0, 200) / 200;
    return Color.lerp(
      Colors.transparent,
      widget.community.cardColor.withOpacity(0.95),
      progress,
    )!;
  }

  double _getAppBarElevation() {
    return _scrollOffset > 100 ? 4.0 : 0.0;
  }

  bool _showAppBarTitle() {
    return _scrollOffset > 150;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Добавлено в избранное' : 'Удалено из избранного'),
        backgroundColor: _isFavorite ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleMembership() {
    setState(() {
      _isMember = !_isMember;
    });

    final stateProvider = Provider.of<CommunityStateProvider>(context, listen: false);
    final currentMembersCount = widget.community.membersCount;
    final newMembersCount = _isMember ? currentMembersCount + 1 : currentMembersCount - 1;

    // Обновляем количество участников в провайдере
    stateProvider.updateMembersCount(
        widget.community.id.toString(),
        newMembersCount
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMember ? 'Вы вступили в сообщество' : 'Вы покинули сообщество'),
        backgroundColor: _isMember ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCommunity() {
    // Логика поделиться сообществом
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ссылка на сообщество скопирована'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Пожаловаться на сообщество'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: const Text('Заблокировать сообщество'),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog();
              },
            ),
            if (_isMember)
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.grey),
                title: const Text('Покинуть сообщество'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleMembership();
                },
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на сообщество'),
        content: const Text('Пожалуйста, укажите причину жалобы'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Жалоба отправлена'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заблокировать сообщество'),
        content: const Text('Вы больше не будете видеть это сообщество в ленте'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Сообщество заблокировано'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Заблокировать', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onDiscussionCreated(Discussion newDiscussion) {
    setState(() {
      _discussions.insert(0, newDiscussion);
    });
  }

  void _onDiscussionLike(String discussionId) {
    setState(() {
      final discussion = _discussions.firstWhere((d) => d.id == discussionId);
      final index = _discussions.indexOf(discussion);
      _discussions[index] = discussion.copyWith(
        likesCount: discussion.likesCount + 1,
        isLiked: true,
      );
    });
  }

  void _onDiscussionComment(String discussionId) {
    // Навигация к странице комментариев
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Переход к обсуждению #$discussionId'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : horizontalPadding,
                  vertical: 8,
                ),
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
                        child: Icon(
                          Icons.arrow_back,
                          color: widget.community.cardColor,
                          size: 18,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),

                    // Заголовок
                    AnimatedOpacity(
                      opacity: _showAppBarTitle() ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.community.title,
                        style: TextStyle(
                          color: _showAppBarTitle() ? Colors.black : Colors.transparent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Кнопки действий
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : widget.community.cardColor,
                          size: 18,
                        ),
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share,
                          color: widget.community.cardColor,
                          size: 18,
                        ),
                      ),
                      onPressed: _shareCommunity,
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: widget.community.cardColor,
                          size: 18,
                        ),
                      ),
                      onPressed: _showMoreOptions,
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ОБЛОЖКА СООБЩЕСТВА - БЕЗ ОТСТУПОВ НА ТЕЛЕФОНЕ
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: 16,
                          bottom: 16,
                        ),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                          ),
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          child: Consumer<CommunityStateProvider>(
                            builder: (context, stateProvider, child) {
                              final customAvatar = stateProvider.getAvatarForCommunity(widget.community.id.toString());
                              final customCover = stateProvider.getCoverForCommunity(widget.community.id.toString());

                              final communityWithCustomData = widget.community.copyWith(
                                imageUrl: customAvatar ?? widget.community.imageUrl,
                                coverImageUrl: customCover ?? widget.community.coverImageUrl,
                              );

                              return _buildSimplifiedCover(communityWithCustomData, context);
                            },
                          ),
                        ),
                      ),
                    ),

                    // КОНТЕНТ СООБЩЕСТВА - БЕЗ ОТСТУПОВ НА ТЕЛЕФОНЕ
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: 0,
                          bottom: 16,
                        ),
                        child: Column(
                          children: [
                            // КАРТОЧКА С ОПИСАНИЕМ
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: contentMaxWidth),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                                boxShadow: [
                                  if (!isMobile) // Тень только на компьютере
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: _buildInfoCard(context),
                            ),

                            SizedBox(height: isMobile ? 0 : 16), // На телефоне без отступов

                            // ТЕГИ
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: contentMaxWidth),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                                boxShadow: [
                                  if (!isMobile) // Тень только на компьютере
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: _buildTagsCard(context),
                            ),

                            SizedBox(height: isMobile ? 0 : 16), // На телефоне без отступов

                            // КНОПКИ ДЕЙСТВИЙ
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: contentMaxWidth),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                                boxShadow: [
                                  if (!isMobile) // Тень только на компьютере
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: _buildActionButtons(context),
                            ),

                            SizedBox(height: isMobile ? 16 : 24),
                          ],
                        ),
                      ),
                    ),

                    // ЗАГОЛОВОК РАЗДЕЛА ОБСУЖДЕНИЙ
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          bottom: 16,
                        ),
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: _buildDiscussionsHeader(),
                      ),
                    ),

                    // СПИСОК ОБСУЖДЕНИЙ - БЕЗ ОТСТУПОВ НА ТЕЛЕФОНЕ
                    _buildDiscussionsList(horizontalPadding, contentMaxWidth),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Кнопка создания обсуждения
      floatingActionButton: CreateDiscussionButton(
        community: widget.community,
        onDiscussionCreated: _onDiscussionCreated,
      ),
    );
  }

  // УПРОЩЕННАЯ ОБЛОЖКА БЕЗ ОПИСАНИЯ - БЕЗ ОТСТУПОВ НА ТЕЛЕФОНЕ
  Widget _buildSimplifiedCover(Community community, BuildContext context) {
    final coverUrl = community.coverImageUrl;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        image: coverUrl != null && coverUrl.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(coverUrl),
          fit: BoxFit.cover,
        )
            : null,
        gradient: coverUrl == null || coverUrl.isEmpty
            ? LinearGradient(
          colors: [
            community.cardColor,
            _darkenColor(community.cardColor, 0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
            : null,
      ),
      child: Container(
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
        child: Stack(
          children: [
            // НАЗВАНИЕ И УЧАСТНИКИ
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
                      child: community.imageUrl.isNotEmpty
                          ? Image.network(
                        community.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(community);
                        },
                      )
                          : _buildDefaultAvatar(community),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ИНФОРМАЦИЯ О СООБЩЕСТВЕ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          community.title,
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${community.membersCount} участников',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
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

            // ИКОНКА РЕДАКТИРОВАНИЯ
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: isMobile ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(Community community) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            community.cardColor,
            _darkenColor(community.cardColor, 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          community.title.isNotEmpty ? community.title[0].toUpperCase() : 'C',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Widget _buildDiscussionsHeader() {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: widget.community.cardColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            color: widget.community.cardColor,
            size: isMobile ? 16 : 18,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Text(
          'Обсуждения',
          style: TextStyle(
            fontSize: isMobile ? 16 : _getTitleFontSize(context),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 6 : 8,
            vertical: isMobile ? 2 : 2,
          ),
          decoration: BoxDecoration(
            color: widget.community.cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          ),
          child: Text(
            _discussions.length.toString(),
            style: TextStyle(
              fontSize: isMobile ? 10 : _getContentFontSize(context) - 2,
              color: widget.community.cardColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionsList(double horizontalPadding, double contentMaxWidth) {
    if (_discussions.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 16,
          ),
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
          child: _buildEmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Пока нет обсуждений',
            subtitle: 'Будьте первым, кто начнет обсуждение в этом сообществе',
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final discussion = _discussions[index];
          final isMobile = MediaQuery.of(context).size.width <= 600;

          return Container(
            margin: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: isMobile ? 0 : 16, // НА ТЕЛЕФОНЕ БЕЗ ОТСТУПОВ СНИЗУ
            ),
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: DiscussionCard(
              discussion: discussion,
              onTap: () => _onDiscussionComment(discussion.id),
              onLike: () => _onDiscussionLike(discussion.id),
              onComment: () => _onDiscussionComment(discussion.id),
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Поделиться обсуждением "${discussion.title}"'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              onMore: () {
                _showDiscussionOptions(discussion);
              },
            ),
          );
        },
        childCount: _discussions.length,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: widget.community.cardColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: widget.community.cardColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDiscussionOptions(Discussion discussion) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.blue),
              title: const Text('Сохранить обсуждение'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Обсуждение сохранено'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Пожаловаться на обсуждение'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Жалоба отправлена'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: const Text('Скрыть обсуждение'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _discussions.remove(discussion);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Обсуждение скрыто'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: widget.community.cardColor,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Информация о сообществе',
                style: TextStyle(
                  fontSize: isMobile ? 16 : _getTitleFontSize(context),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),

          // Текст описания
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.community.title,
                  style: TextStyle(
                    fontSize: isMobile ? 17 : _getTitleFontSize(context) + 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  widget.community.description,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : _getDescriptionFontSize(context),
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsCard(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.local_offer_rounded,
                color: widget.community.cardColor,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Теги сообщества',
                style: TextStyle(
                  fontSize: isMobile ? 16 : _getTitleFontSize(context),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),

          // Теги
          Wrap(
            spacing: isMobile ? 6 : 8,
            runSpacing: isMobile ? 6 : 8,
            children: widget.community.tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: widget.community.cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  border: Border.all(
                    color: widget.community.cardColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : _getContentFontSize(context) - 1,
                    color: widget.community.cardColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.settings_rounded,
                color: widget.community.cardColor,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Управление сообществом',
                style: TextStyle(
                  fontSize: isMobile ? 16 : _getTitleFontSize(context),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Кнопки действий
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleMembership,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMember ? Colors.grey : widget.community.cardColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 10 : 12)),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                  ),
                  icon: Icon(_isMember ? Icons.group_remove : Icons.group_add, size: isMobile ? 18 : 20),
                  label: Text(
                    _isMember ? 'Покинуть сообщество' : 'Вступить в сообщество',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : _getContentFontSize(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Настройки уведомлений'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: Icon(Icons.notifications_none, size: isMobile ? 20 : 24),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}