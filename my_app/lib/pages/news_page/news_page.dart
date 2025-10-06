import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import ' dialogs.dart';
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
import 'dialogs.dart';
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

class _NewsPageState extends State<NewsPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late NewsPageState _pageState;

  @override
  void initState() {
    super.initState();
    _pageState = NewsPageState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNews(showLoading: true);
      Provider.of<NewsProvider>(context, listen: false).loadUserTags();
    });
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
    } catch (e) {
      _refreshController.refreshFailed();
      _showErrorSnackBar('Ошибка обновления: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: NewsTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: NewsTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ========== ОСНОВНЫЕ МЕТОДЫ ВЗАИМОДЕЙСТВИЯ С НОВОСТЯМИ ==========

  Future<void> _toggleLike(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyLiked = news['isLiked'] ?? false;
    final int currentLikes = news['likes'] ?? 0;

    try {
      // Оптимистичное обновление UI
      newsProvider.updateNewsLikeStatus(
          index,
          !isCurrentlyLiked,
          isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1
      );

      // await ApiService.toggleLikeNews(news['id'].toString(), !isCurrentlyLiked);
    } catch (e) {
      // Откатываем изменения при ошибке
      newsProvider.updateNewsLikeStatus(index, isCurrentlyLiked, currentLikes);
      _showErrorSnackBar('Не удалось поставить лайк');
    }
  }

  Future<void> _toggleBookmark(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyBookmarked = news['isBookmarked'] ?? false;

    try {
      newsProvider.updateNewsBookmarkStatus(index, !isCurrentlyBookmarked);
      // await ApiService.toggleBookmarkNews(news['id'].toString(), !isCurrentlyBookmarked);
    } catch (e) {
      newsProvider.updateNewsBookmarkStatus(index, isCurrentlyBookmarked);
      _showErrorSnackBar('Не удалось добавить в закладки');
    }
  }

  Future<void> _addComment(int index, String commentText) async {
    if (commentText.trim().isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);

    try {
      final newComment = {
        'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
        'author': widget.userName,
        'text': commentText.trim(),
        'time': 'Только что',
        'author_avatar': _getUserAvatarUrl(widget.userName),
      };

      newsProvider.addCommentToNews(index, newComment);
      // await ApiService.addComment(news['id'].toString(), {...});
    } catch (e) {
      newsProvider.removeCommentFromNews(index, 'comment-${DateTime.now().millisecondsSinceEpoch}');
      _showErrorSnackBar('Не удалось добавить комментарий');
    }
  }

  String _getUserAvatarUrl(String userName) {
    // В реальном приложении здесь будет URL аватара пользователя
    return 'https://ui-avatars.com/api/?name=$userName&background=${NewsTheme.primaryColor.value.toRadixString(16).substring(2)}&color=ffffff';
  }

  Future<void> _addNews(String title, String description, String hashtags) async {
    if (title.isEmpty || description.isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final hashtagsArray = _formatHashtags(hashtags);

    try {
      final newNews = await ApiService.createNews({
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
      });

      newsProvider.addNews({
        ...newNews,
        'author_name': widget.userName,
        'author_avatar': _getUserAvatarUrl(widget.userName),
        'isLiked': false,
        'isBookmarked': false,
      });

      _showSuccessSnackBar('Новость успешно создана!');
    } catch (e) {
      print('Ошибка создания новости: $e');

      // Fallback: создаем новость локально
      newsProvider.addNews({
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
        'author_name': widget.userName,
        'author_avatar': _getUserAvatarUrl(widget.userName),
        'likes': 0,
        'comments': [],
        'user_tags': {'tag1': 'Новый тег'},
        'created_at': DateTime.now().toIso8601String(),
        'isLiked': false,
        'isBookmarked': false,
      });

      _showSuccessSnackBar('Новость создана локально');
    }
  }

  List<String> _formatHashtags(String hashtags) {
    return hashtags.split(' ')
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.startsWith('#') ? tag : '#$tag')
        .toList();
  }

  Future<void> _editNews(int index, String title, String description, String hashtags) async {
    if (title.isEmpty || description.isEmpty) return;

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

      _showSuccessSnackBar('Новость обновлена');
    } catch (e) {
      // Fallback: обновляем локально
      newsProvider.updateNews(index, {
        ...news,
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
      });
      _showSuccessSnackBar('Изменения сохранены локально');
    }
  }

  Future<void> _deleteNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index]);

    try {
      await ApiService.deleteNews(news['id'].toString());
      newsProvider.removeNews(index);
      _showSuccessSnackBar('Новость удалена');
    } catch (e) {
      newsProvider.removeNews(index);
      _showSuccessSnackBar('Новость удалена локально');
    }
  }

  void _editUserTag(int newsIndex, String tagId, String newTagName, Color color) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    try {
      newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
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
  }

  // ========== ДИАЛОГИ ==========
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

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NewsTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProfileMenu(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
    );
  }

  // ========== ПОИСК И ФИЛЬТРАЦИЯ ==========

  List<dynamic> _getFilteredNews(List<dynamic> news) {
    List<dynamic> filtered = news;

    // Применяем текстовый поиск
    if (_pageState.searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final newsItem = Map<String, dynamic>.from(item);
        final title = newsItem['title']?.toString().toLowerCase() ?? '';
        final description = newsItem['description']?.toString().toLowerCase() ?? '';
        final hashtags = (newsItem['hashtags'] is List
            ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
            : '');

        return title.contains(_pageState.searchQuery.toLowerCase()) ||
            description.contains(_pageState.searchQuery.toLowerCase()) ||
            hashtags.contains(_pageState.searchQuery.toLowerCase());
      }).toList();
    }

    // Применяем выбранный фильтр
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
      default: // Все новости
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _pageState,
      child: Consumer2<NewsPageState, NewsProvider>(
        builder: (context, pageState, newsProvider, child) {
          final filteredNews = _getFilteredNews(newsProvider.news);

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
                onProfilePressed: () => _showProfileMenu(context),
              ),
              body: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: const ClassicHeader(
                  completeText: 'Обновлено',
                  refreshingText: 'Обновление...',
                  releaseText: 'Отпустите для обновления',
                  idleText: 'Потяните для обновления',
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: () => _refreshController.loadComplete(),
                child: CustomScrollView(
                  controller: pageState.scrollController,
                  slivers: [
                    if (newsProvider.news.isNotEmpty && !pageState.isSearching)
                      const SliverToBoxAdapter(child: FilterChipsRow()),

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
                              final originalIndex = newsProvider.news.indexOf(filteredNews[index]);

                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    index == filteredNews.length - 1 ? 16 : 8
                                ),
                                child: NewsCard(
                                  key: ValueKey(news['id'] ?? index),
                                  news: news,
                                  userName: widget.userName,
                                  onLike: () => _toggleLike(originalIndex),
                                  onBookmark: () => _toggleBookmark(originalIndex),
                                  onComment: (comment) => _addComment(originalIndex, comment),
                                  onEdit: () => _showEditNewsDialog(originalIndex),
                                  onDelete: () => _showDeleteConfirmationDialog(originalIndex),
                                  onShare: () => _shareNews(originalIndex),
                                  onTagEdit: (tagId, newTagName, color) =>
                                      _editUserTag(originalIndex, tagId, newTagName, color),
                                  formatDate: formatDate,
                                  getTimeAgo: getTimeAgo,
                                  scrollController: pageState.scrollController,
                                ),
                              );
                            },
                            childCount: filteredNews.length,
                          ),
                        ),
                  ],
                ),
              ),
              floatingActionButton: AnimatedFAB(
                onPressed: _showAddNewsDialog,
                tooltip: 'Создать новость',
                icon: Icons.add,
                scrollController: pageState.scrollController,
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
    super.dispose();
  }
}