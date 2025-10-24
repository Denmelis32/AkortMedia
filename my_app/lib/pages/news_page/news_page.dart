import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/pages/profile/profile_menu_page.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'dialogs.dart';
import '../../providers/news_providers/news_provider.dart';
import '../../../services/api_service.dart';
import '../news_cards/news_card.dart';
import 'utils.dart';
import 'shimmer_loading.dart';
import 'animated_fab.dart';

// Импортируем новые модули
import 'state/news_state.dart';
import 'theme/news_theme.dart';
import 'widgets/empty_states.dart';
import 'widgets/loading_state.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/app_bar.dart';

// Импортируем ImageUtils для универсальной системы аватарок
import '../news_cards/utils/image_utils.dart';

// Оптимизированный NewsCardItem с анимацией появления
class NewsCardItem extends StatelessWidget {
  final Map<String, dynamic> news;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onRepost;
  final Function(String, String, String) onComment;
  final VoidCallback onFollow;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final Function(String, String, Color) onTagEdit;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final ScrollController scrollController;
  final VoidCallback onLogout;
  final int index; // 🎯 ДОБАВЛЕНО: индекс для staggered анимации

  const NewsCardItem({
    super.key,
    required this.news,
    required this.onLike,
    required this.onBookmark,
    required this.onRepost,
    required this.onComment,
    required this.onFollow,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onTagEdit,
    required this.formatDate,
    required this.getTimeAgo,
    required this.scrollController,
    required this.onLogout,
    required this.index, // 🎯 ДОБАВЛЕНО
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300 + (index * 100)), // 🎯 Staggered анимация
      opacity: 1.0,
      child: Transform.translate(
        offset: Offset(0, 0),
        child: NewsCard(
          key: ValueKey('news-${news['id']}-${news['likes']}-${news['isBookmarked']}'),
          news: news,
          onLike: onLike,
          onBookmark: onBookmark,
          onRepost: onRepost,
          onComment: onComment,
          onFollow: onFollow,
          onEdit: onEdit,
          onDelete: onDelete,
          onShare: onShare,
          onTagEdit: onTagEdit,
          formatDate: formatDate,
          getTimeAgo: getTimeAgo,
          scrollController: scrollController,
          onLogout: onLogout,
        ),
      ),
    );
  }
}

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
  bool _isMounted = false;
  bool _isInitialLoad = true; // 🎯 ДОБАВЛЕНО: флаг первой загрузки
  bool _isLoadingInProgress = false; // 🎯 ДОБАВЛЕНО: флаг текущей загрузки

  // Улучшенный кэш для отфильтрованных новостей
  final _newsCache = <String, List<dynamic>>{};
  String _lastCacheKey = '';
  int _lastNewsCount = 0;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _pageState = NewsPageState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // 🎯 ИСПРАВЛЕНО: Упрощенная инициализация без дублирования
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMounted) return;
      _initializeApp();
    });
  }

  // 🎯 НОВЫЙ МЕТОД: Упрощенная инициализация
  // 🎯 ОБНОВЛЕННЫЙ МЕТОД ИНИЦИАЛИЗАЦИИ
  Future<void> _initializeApp() async {
    try {
      print('🎯 NewsPage: Starting initialization...');

      // 1. Сначала загружаем данные
      await _ensureDataPersistence();

      // 2. Затем загружаем новости
      await _loadInitialNews();

      // 3. Синхронизируем локальные посты
      await _syncLocalPosts();

      // 4. Загружаем теги пользователя
      _safeProviderOperation((newsProvider) => newsProvider.loadUserTags());

      // 5. Запускаем анимацию
      _animationController.forward();

      _isInitialLoad = false;
      print('✅ NewsPage: Initialization completed successfully');

    } catch (e) {
      print('❌ NewsPage: Initialization error: $e');
    }
  }


  // 🎯 ДОБАВЬ ЭТОТ МЕТОД В _NewsPageState
  Future<void> _syncLocalPosts() async {
    try {
      print('🔄 Checking for local posts to sync...');

      _safeProviderOperation((newsProvider) {
        final localPosts = newsProvider.news.where((post) {
          final id = post['id']?.toString() ?? '';
          return id.startsWith('local-');
        }).toList();

        print('📱 Found ${localPosts.length} local posts to sync');

        for (final post in localPosts) {
          _trySyncLocalPost(post);
        }
      });
    } catch (e) {
      print('❌ Error syncing local posts: $e');
    }
  }

  Future<void> _trySyncLocalPost(Map<String, dynamic> post) async {
    try {
      final postId = post['id'].toString();
      print('🔄 Syncing local post: $postId');

      final serverNews = await ApiService.createNews({
        'title': post['title'],
        'description': post['description'],
        'hashtags': post['hashtags'] ?? [],
      });

      // 🎯 ЗАМЕНЯЕМ ЛОКАЛЬНЫЙ ПОСТ НА СЕРВЕРНЫЙ
      _safeProviderOperation((newsProvider) {
        final index = newsProvider.findNewsIndexById(postId);
        if (index != -1) {
          newsProvider.news[index] = {
            ...serverNews,
            'id': serverNews['id'], // 🎯 ВАЖНО: заменяем ID
            'isLiked': post['isLiked'] ?? false,
            'isBookmarked': post['isBookmarked'] ?? false,
            'isFollowing': post['isFollowing'] ?? false,
          };
          newsProvider.notifyListeners();
          print('✅ Local post synced: $postId → ${serverNews['id']}');
        }
      });

    } catch (e) {
      print('❌ Failed to sync local post ${post['id']}: $e');
    }
  }

  // 🎯 НОВЫЙ МЕТОД: Загрузка начальных новостей
  Future<void> _loadInitialNews() async {
    if (!_isMounted || _isLoadingInProgress) return;

    _isLoadingInProgress = true;

    try {
      _safeProviderOperation((newsProvider) {
        print('🔄 Setting loading state to true');
        newsProvider.setLoading(true);
      });

      await _safeProviderOperationAsync((newsProvider) => newsProvider.loadNews());
    } catch (e) {
      print('❌ Initial news load error: $e');
    } finally {
      _isLoadingInProgress = false;

      if (_isMounted) {
        _safeProviderOperation((newsProvider) {
          print('🔄 Setting loading state to false');
          newsProvider.setLoading(false);
        });
      }
    }
  }

  // 🔄 ГЕНЕРАЦИЯ USER_ID ДЛЯ УНИВЕРСАЛЬНОЙ СИСТЕМЫ АВАТАРОК
  String _generateUserId(String userEmail) {
    return 'user_${userEmail.trim().toLowerCase().hashCode.abs()}';
  }

  // 🎯 УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ
  String _getUniversalUserAvatarUrl(BuildContext context) {
    try {
      final userId = _generateUserId(widget.userEmail);
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      final directAvatar = newsProvider.getUserAvatarUrl(userId, widget.userName);

      if (directAvatar != null &&
          directAvatar.isNotEmpty &&
          !directAvatar.contains('assets/images/ava_news/') &&
          directAvatar.contains('yandex')) {
        return directAvatar;
      }

      final fallbackAvatar = ImageUtils.getUniversalAvatarUrl(
        context: context,
        userId: userId,
        userName: widget.userName,
      );

      return fallbackAvatar;

    } catch (e) {
      print('❌ NewsPage: Error getting universal avatar: $e');
      return ImageUtils.getFallbackAvatarUrl(widget.userName);
    }
  }

  // 🎯 ИСПРАВЛЕННЫЙ МЕТОД ЗАГРУЗКИ НОВОСТЕЙ
  Future<void> _loadNews({bool showLoading = false}) async {
    if (!_isMounted || _isLoadingInProgress) return;

    _isLoadingInProgress = true;

    try {
      if (showLoading) {
        _safeProviderOperation((newsProvider) {
          newsProvider.setLoading(true);
        });
      }

      await _safeProviderOperationAsync((newsProvider) => newsProvider.loadNews());
    } catch (e) {
      print('❌ Load news error: $e');
      if (_isMounted) {
        _showErrorSnackBar('Ошибка загрузки: ${e.toString()}');
      }
    } finally {
      _isLoadingInProgress = false;

      if (showLoading && _isMounted) {
        _safeProviderOperation((newsProvider) {
          newsProvider.setLoading(false);
        });
      }
    }
  }

  // 🎯 ИСПРАВЛЕННЫЙ МЕТОД ОБНОВЛЕНИЯ
  Future<void> _onRefresh() async {
    if (!_isMounted || _isLoadingInProgress) return;

    _isLoadingInProgress = true;

    try {
      await _safeProviderOperationAsync((newsProvider) => newsProvider.loadNews());
      if (_isMounted) {
        _refreshController.refreshCompleted();
        _showSuccessSnackBar('Новости обновлены');
      }
    } catch (e) {
      if (_isMounted) {
        _refreshController.refreshFailed();
        _showErrorSnackBar('Ошибка обновления: ${e.toString()}');
      }
    } finally {
      _isLoadingInProgress = false;
    }
  }

  // 🎯 УЛУЧШЕННЫЙ МЕТОД ДЛЯ ПОСТРОЕНИЯ UI
  Widget _buildNewsContent(NewsPageState pageState, NewsProvider newsProvider) {
    // Используем кэшированные данные
    final filteredNews = _getCachedFilteredNews(
        newsProvider.news,
        pageState.searchQuery,
        pageState.currentFilter
    );
    final hasActiveFilters = pageState.currentFilter != 0 || pageState.searchQuery.isNotEmpty;

    // 🎯 ПРОВЕРКА СОСТОЯНИЯ ЗАГРУЗКИ
    if (newsProvider.isLoading && newsProvider.news.isEmpty) {
      return _buildShimmerScaffold();
    }

    return Theme(
      data: NewsTheme.themeData,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: NewsAppBar(
          userName: widget.userName,
          userEmail: widget.userEmail,
          isSearching: pageState.isSearching,
          searchQuery: pageState.searchQuery,
          onSearchChanged: (query) {
            if (!_isMounted) return;
            pageState.setSearchQuery(query);
            if (query.isNotEmpty) {
              pageState.addToRecentSearches(query);
            }
          },
          onSearchToggled: () {
            if (!_isMounted) return;
            pageState.setSearching(!pageState.isSearching);
          },
          onProfilePressed: () => _showProfilePage(context),
          onClearFilters: _clearAllFilters,
          hasActiveFilters: hasActiveFilters,
          newMessagesCount: 3,
          profileImageUrl: newsProvider.profileImageUrl,
          profileImageFile: newsProvider.profileImageFile,
        ),
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
                slivers: _buildSliverContent(pageState, newsProvider, filteredNews, hasActiveFilters),
              ),
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
  }

  // 🎯 МЕТОД ДЛЯ ПОСТРОЕНИЯ SHIMMER SCAFFOLD
  Widget _buildShimmerScaffold() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Новости',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: const NewsShimmerLoader(),
    );
  }

  List<Widget> _buildSliverContent(NewsPageState pageState, NewsProvider newsProvider, List<dynamic> filteredNews, bool hasActiveFilters) {
    return [
      SliverToBoxAdapter(
        child: Column(
          children: [
            if (newsProvider.news.isNotEmpty)
              const FilterChipsRow(),

            if (hasActiveFilters && filteredNews.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width > 700 ? 600 : double.infinity,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: NewsTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NewsTheme.primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt_rounded, size: 16, color: NewsTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getFilterDescription(pageState.currentFilter, pageState.searchQuery, filteredNews.length),
                              style: TextStyle(
                                color: NewsTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearAllFilters,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: NewsTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Очистить',
                                style: TextStyle(
                                  color: NewsTheme.primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      // 🎯 УСЛОВНОЕ ОТОБРАЖЕНИЕ КОНТЕНТА
      if (newsProvider.news.isEmpty && !newsProvider.isLoading)
        SliverFillRemaining(
          child: EmptyNewsState(onCreateNews: _showAddNewsDialog),
        )
      else if (filteredNews.isEmpty && !newsProvider.isLoading)
        SliverFillRemaining(
          child: NoResultsState(
            searchQuery: pageState.searchQuery,
            onClearSearch: pageState.clearSearch,
          ),
        )
      else
        SliverPadding(
          padding: EdgeInsets.zero,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final news = Map<String, dynamic>.from(filteredNews[index]);
                final newsId = news['id'].toString();
                final originalIndex = newsProvider.findNewsIndexById(newsId);

                if (originalIndex == -1) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: _getNewsCardPadding(context, index, filteredNews.length),
                  child: NewsCardItem(
                    key: ValueKey('news-$newsId-$index-${news['likes']}-${news['isBookmarked']}'),
                    news: news,
                    index: index,
                    onLike: () => _safeNewsAction(originalIndex, _toggleLike),
                    onBookmark: () => _safeNewsAction(originalIndex, _toggleBookmark),
                    onRepost: () => _safeNewsAction(originalIndex, _toggleRepost),
                    onComment: (text, userName, userAvatar) => _safeNewsAction(
                        originalIndex,
                            (idx) => _addComment(idx, text, userName, userAvatar)
                    ),
                    onFollow: () => _safeNewsAction(originalIndex, _toggleFollow),
                    onEdit: () => _safeNewsAction(originalIndex, _showEditNewsDialog),
                    onDelete: () => _safeNewsAction(originalIndex, _showDeleteConfirmationDialog),
                    onShare: () => _safeNewsAction(originalIndex, _shareNews),
                    onTagEdit: (tagId, newTagName, color) =>
                        _safeNewsAction(originalIndex, (idx) => _editUserTag(idx, tagId, newTagName, color)),
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
        ),
    ];
  }

  // Оптимизированный кэш для отфильтрованных новостей
  List<dynamic> _getCachedFilteredNews(List<dynamic> news, String searchQuery, int currentFilter) {
    final cacheKey = '$searchQuery-$currentFilter-${news.length}';

    if (_lastCacheKey == cacheKey && _newsCache.containsKey(cacheKey) && _lastNewsCount == news.length) {
      return _newsCache[cacheKey]!;
    }

    final filteredNews = _performFiltering(news, searchQuery, currentFilter);
    _newsCache[cacheKey] = filteredNews;
    _lastCacheKey = cacheKey;
    _lastNewsCount = news.length;

    if (_newsCache.length > 3) {
      final keysToRemove = _newsCache.keys.toList()..remove(cacheKey);
      for (final key in keysToRemove.take(keysToRemove.length - 2)) {
        _newsCache.remove(key);
      }
    }

    return filteredNews;
  }

  List<dynamic> _performFiltering(List<dynamic> news, String searchQuery, int currentFilter) {
    if (searchQuery.isEmpty && currentFilter == 0) {
      return news;
    }

    List<dynamic> filtered = List.from(news);

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        final newsItem = Map<String, dynamic>.from(item);
        final title = newsItem['title']?.toString().toLowerCase() ?? '';
        final description = newsItem['description']?.toString().toLowerCase() ?? '';

        if (title.contains(query)) return true;
        if (description.contains(query)) return true;

        final hashtags = (newsItem['hashtags'] is List
            ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
            : '');
        if (hashtags.contains(query)) return true;

        final author = newsItem['author_name']?.toString().toLowerCase() ?? '';
        return author.contains(query);
      }).toList();
    }

    if (currentFilter != 0) {
      switch (currentFilter) {
        case 1: // Мои новости
          filtered = filtered.where((item) {
            final newsItem = Map<String, dynamic>.from(item);
            return newsItem['author_name'] == widget.userName;
          }).toList();
          break;
        case 2: // Популярные
          filtered = filtered.where((item) {
            final newsItem = Map<String, dynamic>.from(item);
            return (newsItem['likes'] ?? 0) > 5;
          }).toList();
          break;
        case 3: // Избранное
          filtered = filtered.where((item) {
            final newsItem = Map<String, dynamic>.from(item);
            return newsItem['isBookmarked'] == true;
          }).toList();
          break;
        case 4: // Подписки
          filtered = filtered.where((item) {
            final newsItem = Map<String, dynamic>.from(item);
            return newsItem['isFollowing'] == true;
          }).toList();
          break;
      }
    }

    return filtered;
  }

  // Безопасная операция с провайдером
  void _safeProviderOperation(Function(NewsProvider) operation) {
    if (!_isMounted) return;

    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (!newsProvider.isDisposed) {
        operation(newsProvider);
      }
    } catch (e) {
      print('❌ Safe provider operation error: $e');
    }
  }

  Future<void> _ensureDataPersistence() async {
    if (!_isMounted) return;

    try {
      await _safeProviderOperationAsync((newsProvider) => newsProvider.ensureDataPersistence());
    } catch (e) {
      print('❌ Ensure data persistence error: $e');
    }
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 16.0;
    return 0.0;
  }

  EdgeInsets _getNewsCardPadding(BuildContext context, int index, int totalCount) {
    final horizontalPadding = _getHorizontalPadding(context);
    return EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 0);
  }

  Future<void> _safeProviderOperationAsync(Future Function(NewsProvider) operation) async {
    if (!_isMounted) return;

    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (!newsProvider.isDisposed) {
        await operation(newsProvider);
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showErrorSnackBar(String message) {
    if (_isMounted && mounted) {
      try {
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
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        // Игнорируем ошибки показа снекбара
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (_isMounted && mounted) {
      try {
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
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Игнорируем ошибки показа снекбара
      }
    }
  }

  // Оптимизированные методы взаимодействия
  void _toggleLike(int index) {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
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
      }
    });
  }

  void _toggleBookmark(int index) {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final bool isCurrentlyBookmarked = news['isBookmarked'] ?? false;

      try {
        HapticFeedback.lightImpact();
        newsProvider.updateNewsBookmarkStatus(index, !isCurrentlyBookmarked);
      } catch (e) {
        newsProvider.updateNewsBookmarkStatus(index, isCurrentlyBookmarked);
      }
    });
  }

  void _toggleFollow(int index) {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final bool isCurrentlyFollowing = news['isFollowing'] ?? false;

      try {
        HapticFeedback.mediumImpact();
        newsProvider.updateNewsFollowStatus(index, !isCurrentlyFollowing);
      } catch (e) {
        newsProvider.updateNewsFollowStatus(index, isCurrentlyFollowing);
      }
    });
  }

  void _addComment(int index, String commentText, String userName, String userAvatar) {
    if (commentText.trim().isEmpty || !_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final newsId = news['id'].toString();

      try {
        final newComment = {
          'id': 'comment-${DateTime.now().millisecondsSinceEpoch}-${news['id']}',
          'author': userName,
          'text': commentText.trim(),
          'time': 'Только что',
          'author_avatar': userAvatar,
          'created_at': DateTime.now().toIso8601String(),
        };

        newsProvider.addCommentToNews(newsId, newComment);
      } catch (e) {
        print('❌ Add comment error: $e');
      }
    });
  }

  // 🎯 ОБНОВЛЕННЫЙ МЕТОД СОЗДАНИЯ НОВОСТИ
  // 🎯 УПРОЩЕННЫЙ МЕТОД СОЗДАНИЯ НОВОСТИ
  Future<void> _addNews(String title, String description, String hashtags) async {
    if (description.isEmpty || !_isMounted) return;

    final hashtagsArray = _formatHashtags(hashtags);

    _safeProviderOperation((newsProvider) => newsProvider.setLoading(true));

    try {
      final currentAvatarUrl = _getUniversalUserAvatarUrl(context);

      // 🎯 ПРЯМОЕ СОЗДАНИЕ НА СЕРВЕРЕ
      final newNews = await ApiService.createNews({
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
        'author_name': widget.userName,
        'author_id': _generateUserId(widget.userEmail),
        'author_avatar': currentAvatarUrl,
      });

      // 🎯 ДОБАВЛЯЕМ СРАЗУ В СПИСОК
      _safeProviderOperation((newsProvider) {
        newsProvider.addNews(newNews, context: context);
      });

      _showSuccessSnackBar('🎉 Новость успешно создана!');

    } catch (e) {
      print('❌ NewsPage: Error creating news via API: $e');

      // 🎯 ЕСЛИ ОШИБКА - СОЗДАЕМ ЛОКАЛЬНО И СРАЗУ СИНХРОНИЗИРУЕМ
      final currentAvatarUrl = _getUniversalUserAvatarUrl(context);

      final localNewsItem = {
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
        'author_name': widget.userName,
        'author_id': _generateUserId(widget.userEmail),
        'author_avatar': currentAvatarUrl,
        'likes': 0,
        'comments': [],
        'user_tags': <String, String>{},
        'created_at': DateTime.now().toIso8601String(),
        'isLiked': false,
        'isBookmarked': false,
        'isFollowing': false,
        'tag_color': _generateColorFromId('local-${DateTime.now().millisecondsSinceEpoch}').value,
        'is_channel_post': false,
      };

      _safeProviderOperation((newsProvider) {
        newsProvider.addNews(localNewsItem, context: context);
      });

      _showSuccessSnackBar('📝 Новость создана локально');

      // 🎯 ПЫТАЕМСЯ СИНХРОНИЗИРОВАТЬ СРАЗУ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _trySyncLocalPost(localNewsItem);
      });
    } finally {
      if (_isMounted) {
        _safeProviderOperation((newsProvider) => newsProvider.setLoading(false));
      }
    }
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

    return tags;
  }

  Future<void> _editNews(int index, String title, String description, String hashtags) async {
    if (description.isEmpty || !_isValidIndex(index) || !_isMounted) return;

    final hashtagsArray = _formatHashtags(hashtags);

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final newsId = news['id'].toString();

      if (newsId.startsWith('local-')) {
        newsProvider.updateNews(index, {
          ...news,
          'title': title,
          'description': description,
          'hashtags': hashtagsArray,
        });
        _showSuccessSnackBar('💾 Изменения сохранены локально');
      } else {
        try {
          ApiService.updateNews(newsId, {
            'title': title,
            'description': description,
            'hashtags': hashtagsArray,
          }).then((_) {
            newsProvider.updateNews(index, {
              ...news,
              'title': title,
              'description': description,
              'hashtags': hashtagsArray,
            });
            _showSuccessSnackBar('📝 Новость обновлена');
          }).catchError((e) {
            newsProvider.updateNews(index, {
              ...news,
              'title': title,
              'description': description,
              'hashtags': hashtagsArray,
            });
            _showSuccessSnackBar('💾 Изменения сохранены локально');
          });
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
    });
  }

  Future<void> _deleteNews(int index) async {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);

      try {
        ApiService.deleteNews(news['id'].toString()).then((_) {
          newsProvider.removeNews(index);
          _showSuccessSnackBar('🗑️ Новость удалена');
        }).catchError((e) {
          newsProvider.removeNews(index);
          _showSuccessSnackBar('🗑️ Новость удалена локально');
        });
      } catch (e) {
        newsProvider.removeNews(index);
        _showSuccessSnackBar('🗑️ Новость удалена локально');
      }
    });
  }

  void _editUserTag(int newsIndex, String tagId, String newTagName, Color color) {
    if (!_isValidIndex(newsIndex) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      try {
        newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
      } catch (e) {
        // Игнорируем ошибки
      }
    });
  }

  Future<void> _shareNews(int index) async {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);

      final title = news['title'] ?? '';
      final description = news['description'] ?? '';
      final url = 'https://example.com/news/${news['id']}';

      Share.share('$title\n\n$description\n\n$url');
    });
  }

  bool _isValidIndex(int index) {
    bool isValid = false;
    _safeProviderOperation((newsProvider) {
      isValid = index >= 0 && index < newsProvider.news.length;
    });
    return isValid;
  }

  void _safeNewsAction(int originalIndex, Function(int) action) {
    if (_isValidIndex(originalIndex) && _isMounted) {
      action(originalIndex);
    }
  }

  void _showAddNewsDialog() {
    if (!_isMounted) return;

    try {
      showDialog(
        context: context,
        builder: (context) => AddNewsDialog(
          onAddNews: _addNews,
        ),
      );
    } catch (e) {
      // Игнорируем ошибки показа диалога
    }
  }

  void _showEditNewsDialog(int index) {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);

      try {
        showDialog(
          context: context,
          builder: (context) => EditNewsDialog(
            news: news,
            onEditNews: (title, description, hashtags) => _editNews(index, title, description, hashtags),
          ),
        );
      } catch (e) {
        // Игнорируем ошибки показа диалога
      }
    });
  }

  void _showDeleteConfirmationDialog(int index) {
    if (!_isMounted) return;

    try {
      showDialog(
        context: context,
        builder: (context) => DeleteConfirmationDialog(
          onDelete: () => _deleteNews(index),
        ),
      );
    } catch (e) {
      // Игнорируем ошибки показа диалога
    }
  }

  void _showProfilePage(BuildContext context) {
    if (!_isMounted) return;

    _safeProviderOperation((newsProvider) {
      try {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userName: widget.userName,
              userEmail: widget.userEmail,
              onLogout: () {
                if (_isMounted) {
                  Navigator.pop(context);
                  widget.onLogout();
                }
              },
              newMessagesCount: 3,
              profileImageUrl: newsProvider.profileImageUrl,
              profileImageFile: newsProvider.profileImageFile,
              onProfileImageUrlChanged: (url) {
                _safeProviderOperation((provider) => provider.updateProfileImageUrl(url));
              },
              onProfileImageFileChanged: (file) {
                _safeProviderOperation((provider) => provider.updateProfileImageFile(file));
              },
              onMessagesTap: () {
                if (_isMounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Переход к сообщениям');
                }
              },
              onSettingsTap: () {
                if (_isMounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Переход к настройкам');
                }
              },
              onHelpTap: () {
                if (_isMounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Переход к разделу помощи');
                }
              },
              onAboutTap: () {
                if (_isMounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Информация о приложении');
                }
              },
            ),
          ),
        );
      } catch (e) {
        // Игнорируем ошибки навигации
      }
    });
  }

  void _scrollToTop() {
    if (!_isMounted) return;
    try {
      _pageState.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } catch (e) {
      // Игнорируем ошибки скролла
    }
  }

  void _toggleRepost(int index) {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final bool isCurrentlyReposted = news['isReposted'] ?? false;
      final int currentReposts = news['reposts'] ?? 0;

      try {
        HapticFeedback.lightImpact();
        newsProvider.updateNewsRepostStatus(
            index,
            !isCurrentlyReposted,
            isCurrentlyReposted ? currentReposts - 1 : currentReposts + 1
        );
      } catch (e) {
        newsProvider.updateNewsRepostStatus(index, isCurrentlyReposted, currentReposts);
      }
    });
  }

  void _clearAllFilters() {
    if (!_isMounted) return;
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
          duration: const Duration(milliseconds: 200),
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

  String _getFilterDescription(int filter, String searchQuery, int count) {
    final filterNames = ['Все новости', 'Мои новости', 'Популярные', 'Избранное', 'Подписки'];
    String description = '';

    if (filter != 0) {
      description = '${filterNames[filter]} • $count записей';
    }

    if (searchQuery.isNotEmpty) {
      if (description.isNotEmpty) {
        description += ' • Поиск: "$searchQuery"';
      } else {
        description = 'Поиск: "$searchQuery" • $count записей';
      }
    }

    return description;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _pageState,
      child: Consumer2<NewsPageState, NewsProvider>(
        builder: (context, pageState, newsProvider, child) {
          if (newsProvider.isDisposed) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Загрузка новостей...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          // Используем кэшированные данные
          final filteredNews = _getCachedFilteredNews(
              newsProvider.news,
              pageState.searchQuery,
              pageState.currentFilter
          );
          final hasActiveFilters = pageState.currentFilter != 0 || pageState.searchQuery.isNotEmpty;

          return Theme(
            data: NewsTheme.themeData,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: NewsAppBar(
                userName: widget.userName,
                userEmail: widget.userEmail,
                isSearching: pageState.isSearching,
                searchQuery: pageState.searchQuery,
                onSearchChanged: (query) {
                  if (!_isMounted) return;
                  pageState.setSearchQuery(query);
                  if (query.isNotEmpty) {
                    pageState.addToRecentSearches(query);
                  }
                },
                onSearchToggled: () {
                  if (!_isMounted) return;
                  pageState.setSearching(!pageState.isSearching);
                },
                onProfilePressed: () => _showProfilePage(context),
                onClearFilters: _clearAllFilters,
                hasActiveFilters: hasActiveFilters,
                newMessagesCount: 3,
                profileImageUrl: newsProvider.profileImageUrl,
                profileImageFile: newsProvider.profileImageFile,
              ),
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
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              if (newsProvider.news.isNotEmpty)
                                const FilterChipsRow(),

                              if (hasActiveFilters && filteredNews.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Center(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width > 700 ? 600 : double.infinity,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: NewsTheme.primaryColor.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: NewsTheme.primaryColor.withOpacity(0.1)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.filter_alt_rounded, size: 16, color: NewsTheme.primaryColor),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _getFilterDescription(pageState.currentFilter, pageState.searchQuery, filteredNews.length),
                                                style: TextStyle(
                                                  color: NewsTheme.primaryColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _clearAllFilters,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: NewsTheme.primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Очистить',
                                                  style: TextStyle(
                                                    color: NewsTheme.primaryColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if (newsProvider.isLoading && newsProvider.news.isEmpty)
                          const SliverFillRemaining(
                            child: NewsLoadingState(),
                          )
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
                            SliverPadding(
                              padding: EdgeInsets.zero,
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                    final news = Map<String, dynamic>.from(filteredNews[index]);
                                    final newsId = news['id'].toString();
                                    final originalIndex = newsProvider.findNewsIndexById(newsId);

                                    if (originalIndex == -1) {
                                      return const SizedBox.shrink();
                                    }

                                    return Padding(
                                      padding: _getNewsCardPadding(context, index, filteredNews.length),
                                      child: NewsCardItem(
                                        key: ValueKey('news-$newsId-$index-${news['likes']}-${news['isBookmarked']}'),
                                        news: news,
                                        index: index,
                                        onLike: () => _safeNewsAction(originalIndex, _toggleLike),
                                        onBookmark: () => _safeNewsAction(originalIndex, _toggleBookmark),
                                        onRepost: () => _safeNewsAction(originalIndex, _toggleRepost),
                                        onComment: (text, userName, userAvatar) => _safeNewsAction(
                                            originalIndex,
                                                (idx) => _addComment(idx, text, userName, userAvatar)
                                        ),
                                        onFollow: () => _safeNewsAction(originalIndex, _toggleFollow),
                                        onEdit: () => _safeNewsAction(originalIndex, _showEditNewsDialog),
                                        onDelete: () => _safeNewsAction(originalIndex, _showDeleteConfirmationDialog),
                                        onShare: () => _safeNewsAction(originalIndex, _shareNews),
                                        onTagEdit: (tagId, newTagName, color) =>
                                            _safeNewsAction(originalIndex, (idx) => _editUserTag(idx, tagId, newTagName, color)),
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
                            ),
                      ],
                    ),
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
    _isMounted = false;
    _refreshController.dispose();
    _pageState.dispose();
    _animationController.dispose();
    _newsCache.clear();
    super.dispose();
  }
}