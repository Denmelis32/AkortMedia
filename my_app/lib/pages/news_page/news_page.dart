import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/pages/news_page/profile_menu_page.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'dialogs.dart';
import '../../../providers/news_provider.dart';
import '../../../services/api_service.dart';
import 'news_card.dart';
import 'utils.dart';
import 'shimmer_loading.dart';
import 'animated_fab.dart';
import 'search_delegate.dart';

// Импортируем новые модули
import 'state/news_state.dart';
import 'theme/news_theme.dart';
import 'widgets/empty_states.dart';
import 'widgets/app_bar.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/loading_state.dart';

class NewsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const NewsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with SingleTickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late NewsPageState _pageState;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageState = NewsPageState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureDataPersistence();
      _loadNews(showLoading: true);
      Provider.of<NewsProvider>(context, listen: false).loadUserTags();
      _animationController.forward();
    });
  }

  Future<void> _ensureDataPersistence() async {
    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.ensureDataPersistence();
    } catch (e) {
      print('Error ensuring data persistence: $e');
    }
  }

  Future<void> _loadNews({bool showLoading = false}) async {
    try {
      if (showLoading) {
        Provider.of<NewsProvider>(context, listen: false).setLoading(true);
      }
      await Provider.of<NewsProvider>(context, listen: false).loadNews();
    } catch (e) {
      _showErrorSnackBar('Ошибка загрузки: ${e.toString()}');
    } finally {
      if (showLoading) {
        Provider.of<NewsProvider>(context, listen: false).setLoading(false);
      }
    }
  }

  Future<void> _onRefresh() async {
    try {
      await Provider.of<NewsProvider>(context, listen: false).loadNews();
      _refreshController.refreshCompleted();
      _showSuccessSnackBar('Новости обновлены');
    } catch (e) {
      _refreshController.refreshFailed();
      _showErrorSnackBar('Ошибка обновления: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: NewsTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: NewsTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ========== УЛУЧШЕННЫЕ МЕТОДЫ ВЗАИМОДЕЙСТВИЯ С НОВОСТЯМИ ==========

  Future<void> _toggleLike(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyLiked = news['isLiked'] ?? false;
    final int currentLikes = news['likes'] ?? 0;

    try {
      HapticFeedback.lightImpact();
      newsProvider.updateNewsLikeStatus(
          index,
          !isCurrentlyLiked,
          isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1
      );
    } catch (e) {
      newsProvider.updateNewsLikeStatus(index, isCurrentlyLiked, currentLikes);
      _showErrorSnackBar('Не удалось поставить лайк');
    }
  }

  Future<void> _toggleBookmark(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyBookmarked = news['isBookmarked'] ?? false;

    try {
      HapticFeedback.lightImpact();
      newsProvider.updateNewsBookmarkStatus(index, !isCurrentlyBookmarked);
      _showSuccessSnackBar(
          !isCurrentlyBookmarked
              ? 'Добавлено в избранное'
              : 'Удалено из избранного'
      );
    } catch (e) {
      newsProvider.updateNewsBookmarkStatus(index, isCurrentlyBookmarked);
      _showErrorSnackBar('Не удалось добавить в закладки');
    }
  }

  Future<void> _toggleFollow(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyFollowing = news['isFollowing'] ?? false;

    try {
      HapticFeedback.mediumImpact();
      newsProvider.updateNewsFollowStatus(index, !isCurrentlyFollowing);
      final isChannelPost = news['is_channel_post'] == true;
      final targetName = isChannelPost
          ? news['channel_name'] ?? 'канал'
          : news['author_name'] ?? 'пользователя';

      if (!isCurrentlyFollowing) {
        _showSuccessSnackBar('✅ Вы подписались на $targetName');
      } else {
        _showSuccessSnackBar('❌ Вы отписались от $targetName');
      }
    } catch (e) {
      newsProvider.updateNewsFollowStatus(index, isCurrentlyFollowing);
      _showErrorSnackBar('Не удалось изменить подписку');
    }
  }

  Future<void> _addComment(int index, String commentText) async {
    if (commentText.trim().isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final newsId = news['id'].toString();

    try {
      final commentId = 'comment-${DateTime.now().millisecondsSinceEpoch}-${news['id']}';

      final newComment = {
        'id': commentId,
        'author': widget.userName,
        'text': commentText.trim(),
        'time': 'Только что',
        'author_avatar': _getUserAvatarUrl(widget.userName),
      };

      // Используем новый метод с newsId для лучшей синхронизации
      newsProvider.addCommentToNews(newsId, newComment);
      _showSuccessSnackBar('Комментарий добавлен');

    } catch (e) {
      print('❌ Ошибка добавления комментария: $e');
      _showErrorSnackBar('Не удалось добавить комментарий');
    }
  }


  String _getUserAvatarUrl(String userName) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final currentProfileImage = newsProvider.getCurrentProfileImage();

    if (currentProfileImage is File) {
      return _getFallbackAvatarUrl(userName);
    } else if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
      return currentProfileImage;
    } else {
      return _getFallbackAvatarUrl(userName);
    }
  }

  Future<void> _addNews(String title, String description, String hashtags) async {
    if (description.isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final hashtagsArray = _formatHashtags(hashtags);

    try {
      final newNews = await ApiService.createNews({
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
      });

      final currentProfileImage = newsProvider.getCurrentProfileImage();
      String authorAvatarUrl;

      if (currentProfileImage is File) {
        authorAvatarUrl = _getFallbackAvatarUrl(widget.userName);
      } else if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
        authorAvatarUrl = currentProfileImage;
      } else {
        authorAvatarUrl = _getFallbackAvatarUrl(widget.userName);
      }

      final Map<String, dynamic> newsItem = _convertToStringDynamicMap({
        ...newNews,
        'author_name': widget.userName,
        'author_avatar': authorAvatarUrl,
        'isLiked': false,
        'isBookmarked': false,
        'isFollowing': false,
        'likes': 0,
        'comments': [],
        'user_tags': {'tag1': 'Новый тег'},
        'tag_color': _generateColorFromId(newNews['id']?.toString() ?? '').value,
      });

      newsProvider.addNews(newsItem);
      _showSuccessSnackBar('🎉 Новость успешно создана!');

    } catch (e) {
      print('❌ Ошибка создания новости: $e');

      final currentProfileImage = newsProvider.getCurrentProfileImage();
      String authorAvatarUrl;

      if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
        authorAvatarUrl = currentProfileImage;
      } else {
        authorAvatarUrl = _getFallbackAvatarUrl(widget.userName);
      }

      final Map<String, dynamic> localNewsItem = _convertToStringDynamicMap({
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
        'author_name': widget.userName,
        'author_avatar': authorAvatarUrl,
        'likes': 0,
        'comments': [],
        'user_tags': {'tag1': 'Новый тег'},
        'created_at': DateTime.now().toIso8601String(),
        'isLiked': false,
        'isBookmarked': false,
        'isFollowing': false,
        'tag_color': _generateColorFromId('local-${DateTime.now().millisecondsSinceEpoch}').value,
      });

      newsProvider.addNews(localNewsItem);
      _showSuccessSnackBar('📝 Новость создана локально');
    }
  }

  String _getFallbackAvatarUrl(String userName) {
    return 'https://ui-avatars.com/api/?name=$userName&background=667eea&color=ffffff';
  }

  Map<String, dynamic> _convertToStringDynamicMap(Map<dynamic, dynamic> input) {
    final Map<String, dynamic> result = {};

    input.forEach((key, value) {
      final String stringKey = key.toString();

      if (value is Map<dynamic, dynamic>) {
        result[stringKey] = _convertToStringDynamicMap(value);
      } else if (value is List) {
        result[stringKey] = _convertList(value);
      } else {
        result[stringKey] = value;
      }
    });

    return result;
  }

  List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<dynamic, dynamic>) {
        return _convertToStringDynamicMap(item);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
  }

  Color _generateColorFromId(String id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }

  List<String> _formatHashtags(String hashtags) {
    final tags = hashtags
        .split(RegExp(r'[,\s]+'))
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) {
      var cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
      cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
      return cleanTag;
    })
        .where((tag) => tag.isNotEmpty)
        .toList();

    print('🎯 Formatted hashtags: $tags');
    return tags;
  }

  Future<void> _editNews(int index, String title, String description, String hashtags) async {
    if (description.isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final hashtagsArray = _formatHashtags(hashtags);

    try {
      await ApiService.updateNews(news['id'].toString(), {
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
      });

      newsProvider.updateNews(index, {
        ...news,
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
      });

      _showSuccessSnackBar('📝 Новость обновлена');
    } catch (e) {
      newsProvider.updateNews(index, {
        ...news,
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
      });
      _showSuccessSnackBar('💾 Изменения сохранены локально');
    }
  }

  Future<void> _deleteNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);

    try {
      await ApiService.deleteNews(news['id'].toString());
      newsProvider.removeNews(index);
      _showSuccessSnackBar('🗑️ Новость удалена');
    } catch (e) {
      newsProvider.removeNews(index);
      _showSuccessSnackBar('🗑️ Новость удалена локально');
    }
  }

  void _editUserTag(int newsIndex, String tagId, String newTagName, Color color) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    try {
      newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
      _showSuccessSnackBar('🏷️ Тег обновлен');
    } catch (e) {
      newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
    }
  }

  Future<void> _shareNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);

    final title = news['title'] ?? '';
    final description = news['description'] ?? '';
    final url = 'https://example.com/news/${news['id']}';

    await Share.share('$title\n\n$description\n\n$url');
    _showSuccessSnackBar('📤 Новость опубликована');
  }

  // ========== УЛУЧШЕННЫЕ ДИАЛОГИ ==========
  void _showAddNewsDialog() {
    showDialog(
      context: context,
      builder: (context) => AddNewsDialog(
        onAddNews: _addNews,
      ),
    );
  }

  void _showEditNewsDialog(int index) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);

    showDialog(
      context: context,
      builder: (context) => EditNewsDialog(
        news: news,
        onEditNews: (title, description, hashtags) => _editNews(index, title, description, hashtags),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        onDelete: () => _deleteNews(index),
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Открытие страницы профиля вместо модального окна
  void _showProfilePage(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          onLogout: () {
            // Возвращаемся на предыдущую страницу перед выходом
            Navigator.pop(context);
            widget.onLogout();
          },
          newMessagesCount: 3,
          profileImageUrl: newsProvider.profileImageUrl,
          profileImageFile: newsProvider.profileImageFile,
          onProfileImageUrlChanged: (url) {
            newsProvider.updateProfileImageUrl(url);
          },
          onProfileImageFileChanged: (file) {
            newsProvider.updateProfileImageFile(file);
          },
          onMessagesTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Переход к сообщениям');
          },
          onSettingsTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Переход к настройкам');
          },
          onHelpTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Переход к разделу помощи');
          },
          onAboutTap: () {
            Navigator.pop(context);
            _showSuccessSnackBar('Информация о приложении');
          },
        ),
      ),
    );
  }

  // ========== УЛУЧШЕННАЯ ФИЛЬТРАЦИЯ ==========

  List<dynamic> _getFilteredNews(List<dynamic> news) {
    List<dynamic> filtered = news;

    if (_pageState.searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final newsItem = Map<String, dynamic>.from(item);
        final title = newsItem['title']?.toString().toLowerCase() ?? '';
        final description = newsItem['description']?.toString().toLowerCase() ?? '';
        final hashtags = (newsItem['hashtags'] is List
            ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
            : '');
        final author = newsItem['author_name']?.toString().toLowerCase() ?? '';
        final userTags = (newsItem['user_tags'] is Map
            ? (newsItem['user_tags'] as Map).values.join(' ').toLowerCase()
            : '');

        return title.contains(_pageState.searchQuery.toLowerCase()) ||
            description.contains(_pageState.searchQuery.toLowerCase()) ||
            hashtags.contains(_pageState.searchQuery.toLowerCase()) ||
            author.contains(_pageState.searchQuery.toLowerCase()) ||
            userTags.contains(_pageState.searchQuery.toLowerCase());
      }).toList();
    }

    switch (_pageState.currentFilter) {
      case 1: // Мои новости
        return filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return newsItem['author_name'] == widget.userName;
        }).toList();
      case 2: // Популярные
        return filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return (newsItem['likes'] ?? 0) > 5;
        }).toList();
      case 3: // Избранное
        return filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return newsItem['isBookmarked'] == true;
        }).toList();
      case 4: // Подписки
        return filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return newsItem['isFollowing'] == true;
        }).toList();
      default: // Все новости
        return filtered;
    }
  }

  // ========== НОВЫЕ ФУНКЦИИ ==========

  void _scrollToTop() {
    _pageState.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _clearAllFilters() {
    _pageState.setFilter(0);
    _pageState.clearSearch();
    _showSuccessSnackBar('Фильтры сброшены');
  }

  Widget _buildScrollToTopButton() {
    return AnimatedBuilder(
      animation: _pageState.scrollController,
      builder: (context, child) {
        final showButton = _pageState.scrollController.hasClients &&
            _pageState.scrollController.offset > 200;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showButton ? 1.0 : 0.0,
          child: Visibility(
            visible: showButton,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: NewsTheme.primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.arrow_upward_rounded),
              heroTag: 'scroll_to_top',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _pageState,
      child: Consumer2<NewsPageState, NewsProvider>(
        builder: (context, pageState, newsProvider, child) {
          final filteredNews = _getFilteredNews(newsProvider.news);
          final hasActiveFilters = pageState.currentFilter != 0 || pageState.searchQuery.isNotEmpty;

          return Theme(
            data: NewsTheme.themeData,
            child: Scaffold(
              backgroundColor: NewsTheme.backgroundColor,
              appBar: NewsAppBar(
                userName: widget.userName,
                userEmail: widget.userEmail,
                isSearching: pageState.isSearching,
                searchQuery: pageState.searchQuery,
                onSearchChanged: pageState.setSearchQuery,
                onSearchToggled: () => pageState.setSearching(!pageState.isSearching),
                // ОБНОВЛЕНО: Используем новую функцию для открытия страницы профиля
                onProfilePressed: () => _showProfilePage(context),
                onClearFilters: hasActiveFilters ? _clearAllFilters : null,
                profileImageUrl: newsProvider.profileImageUrl,
                profileImageFile: newsProvider.profileImageFile,
              ),
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: const ClassicHeader(
                    completeText: 'Обновлено',
                    refreshingText: 'Обновление...',
                    releaseText: 'Отпустите для обновления',
                    idleText: 'Потяните для обновления',
                    completeIcon: Icon(Icons.check_rounded, color: Colors.green),
                    refreshingIcon: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: () => _refreshController.loadComplete(),
                  child: CustomScrollView(
                    controller: pageState.scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Фильтры - ВСЕГДА видимы, даже при поиске
                      if (newsProvider.news.isNotEmpty)
                        const SliverToBoxAdapter(child: FilterChipsRow()),

                      // Индикатор активных фильтров
                      if (hasActiveFilters && filteredNews.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt_rounded,
                                    size: 16, color: NewsTheme.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Найдено: ${filteredNews.length}',
                                  style: TextStyle(
                                    color: NewsTheme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _clearAllFilters,
                                  child: Text(
                                    'Очистить',
                                    style: TextStyle(
                                      color: NewsTheme.secondaryTextColor,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Состояния загрузки
                      if (newsProvider.isLoading && newsProvider.news.isEmpty)
                        const SliverFillRemaining(child: NewsLoadingState())
                      else if (newsProvider.news.isEmpty)
                        SliverFillRemaining(
                          child: EmptyNewsState(onCreateNews: _showAddNewsDialog),
                        )
                      else if (filteredNews.isEmpty)
                          SliverFillRemaining(
                            child: NoResultsState(
                              searchQuery: pageState.searchQuery,
                              onClearSearch: pageState.clearSearch,
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final news = Map<String, dynamic>.from(filteredNews[index]);
                                final newsId = news['id'].toString();
                                final originalIndex = newsProvider.findNewsIndexById(newsId);

                                return Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      index == filteredNews.length - 1 ? 16 : 8
                                  ),
                                  child: NewsCard(
                                    key: ValueKey('${news['id']}-$index'),
                                    news: news,
                                    userName: widget.userName,
                                    userEmail: widget.userEmail,
                                    onLike: () => _toggleLike(originalIndex),
                                    onBookmark: () => _toggleBookmark(originalIndex),
                                    onFollow: () => _toggleFollow(originalIndex),
                                    onComment: (comment) => _addComment(originalIndex, comment),
                                    onEdit: () => _showEditNewsDialog(originalIndex),
                                    onDelete: () => _showDeleteConfirmationDialog(originalIndex),
                                    onShare: () => _shareNews(originalIndex),
                                    onTagEdit: (tagId, newTagName, color) =>
                                        _editUserTag(originalIndex, tagId, newTagName, color),
                                    formatDate: formatDate,
                                    getTimeAgo: getTimeAgo,
                                    scrollController: pageState.scrollController,
                                    onLogout: widget.onLogout,
                                  ),
                                );
                              },
                              childCount: filteredNews.length,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildScrollToTopButton(),
                  const SizedBox(height: 16),
                  AnimatedFAB(
                    onPressed: _showAddNewsDialog,
                    tooltip: 'Создать новость',
                    icon: Icons.add_rounded,
                    scrollController: pageState.scrollController,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _pageState.dispose();
    _animationController.dispose();
    super.dispose();
  }
}