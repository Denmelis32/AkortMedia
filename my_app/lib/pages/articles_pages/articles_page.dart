import 'package:flutter/material.dart';
import 'package:my_app/pages/articles_pages/widgets/categories_section.dart';
import 'package:my_app/pages/articles_pages/widgets/add_article_dialog.dart';
import 'package:provider/provider.dart';
import '../article_detail_page.dart';
import '../predictions_league_page/predictions_league_page.dart';
import 'models/article.dart';
import 'models/article_category.dart';
import 'widgets/article_card.dart';
import 'widgets/articles_app_bar.dart'; // Добавляем импорт
import 'widgets/filters_section.dart';
import 'widgets/articles_grid.dart';
import 'widgets/quick_preview_sheet.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'services/article_service.dart';
import 'services/layout_service.dart';
import '../../providers/articles_provider.dart';
import '../../providers/channel_provider/channel_state_provider.dart';
import 'test_articles.dart';

class ArticlesPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const ArticlesPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final List<ArticleCategory> _categories = [
    ArticleCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive_rounded,
      color: const Color(0xFF10B981), // Изумрудный
      articleCount: 42,
    ),
    ArticleCategory(
      id: 'youtube',
      title: 'YouTube',
      description: 'Обсуждение видео и блогеров',
      icon: Icons.play_circle_fill_rounded,
      color: const Color(0xFFEF4444),
      articleCount: 15,
    ),
    ArticleCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Стартапы и инвестиции',
      icon: Icons.business_center_rounded,
      color: const Color(0xFFF59E0B),
      articleCount: 8,
    ),
    ArticleCategory(
      id: 'games',
      title: 'Игры',
      description: 'Игровая индустрия',
      icon: Icons.sports_esports_rounded,
      color: const Color(0xFF8B5CF6),
      articleCount: 12,
    ),
    ArticleCategory(
      id: 'programming',
      title: 'Программирование',
      description: 'Разработка и IT',
      icon: Icons.code_rounded,
      color: const Color(0xFF3B82F6),
      articleCount: 25,
    ),
    ArticleCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer_rounded,
      color: const Color(0xFF10B981), // Изумрудный
      articleCount: 7,
    ),
    ArticleCategory(
      id: 'communication',
      title: 'Общение',
      description: 'Психология и отношения',
      icon: Icons.psychology_rounded,
      color: const Color(0xFFEC4899),
      articleCount: 9,
    ),
  ];

  final List<SortOption> _sortOptions = [
    SortOption('Сначала новые', 'Сначала новые', Icons.new_releases_rounded, (a, b) {
      final dateA = DateTime.parse(a['publish_date'] ?? '');
      final dateB = DateTime.parse(b['publish_date'] ?? '');
      return dateB.compareTo(dateA);
    }),
    SortOption('По популярности', 'По популярности', Icons.trending_up_rounded, (a, b) {
      final viewsA = (a['views'] as int?) ?? 0;
      final viewsB = (b['views'] as int?) ?? 0;
      return viewsB.compareTo(viewsA);
    }),
    SortOption('По лайкам', 'По лайкам', Icons.favorite_rounded, (a, b) {
      final likesA = (a['likes'] as int?) ?? 0;
      final likesB = (b['likes'] as int?) ?? 0;
      return likesB.compareTo(likesA);
    }),
  ];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  final Set<String> _favoriteArticleIds = <String>{};
  final Set<String> _selectedArticles = <String>{};

  int _currentTabIndex = 0;
  int _currentSortIndex = 0;
  String _searchQuery = '';

  bool _isLoadingMore = false;
  bool _isSelectionMode = false;
  bool _showSearchBar = false;
  bool _showFilters = false;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 400 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 400 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoadingMore = false);
  }

  void _openArticleDetail(Map<String, dynamic> articleData) {
    final article = ArticleService.articleFromMap(articleData);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(article: article),
      ),
    );
  }

  void _showQuickPreview(Map<String, dynamic> articleData) {
    final article = ArticleService.articleFromMap(articleData);
    QuickPreviewSheet.show(
      context: context,
      article: article,
      onReadFull: () => _openArticleDetail(articleData),
    );
  }

  void _navigateToAddArticlePage() {
    final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
    final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);

    final currentAvatarUrl = channelStateProvider.getCurrentAvatar(
      'user_${widget.userEmail}',
      defaultAvatar: ArticleService.defaultAvatarUrl,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddArticlePage(
          categories: _categories.where((cat) => cat.id != 'all').map((cat) => cat.title).toList(),
          emojis: const ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'],
          onArticleAdded: (newArticle) {
            final articleData = {
              "id": "user_${DateTime.now().millisecondsSinceEpoch}",
              "title": newArticle.title,
              "description": newArticle.description,
              "content": newArticle.content,
              "emoji": newArticle.emoji,
              "category": newArticle.category,
              "views": 0,
              "likes": 0,
              "author": widget.userName,
              "publish_date": DateTime.now().toIso8601String(),
              "image_url": newArticle.imageUrl,
              "author_level": newArticle.authorLevel == AuthorLevel.expert ? 'expert' : 'beginner',
              "author_avatar": currentAvatarUrl,
            };
            articlesProvider.addArticle(articleData);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Статья "${newArticle.title}" успешно создана!'),
                backgroundColor: const Color(0xFF10B981), // Изумрудный
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          userName: widget.userName,
          userAvatarUrl: currentAvatarUrl ?? ArticleService.defaultAvatarUrl,
        ),
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedArticles.clear();
    });
  }

  void _toggleArticleSelection(String articleId) {
    setState(() {
      if (_selectedArticles.contains(articleId)) {
        _selectedArticles.remove(articleId);
      } else {
        _selectedArticles.add(articleId);
      }
    });
  }

  void _toggleFavorite(String articleId) {
    setState(() {
      if (_favoriteArticleIds.contains(articleId)) {
        _favoriteArticleIds.remove(articleId);
      } else {
        _favoriteArticleIds.add(articleId);
      }
    });
  }

  bool _isArticleFavorite(String articleId) => _favoriteArticleIds.contains(articleId);

  void _showFavorites() {
    setState(() {
      _searchQuery = "избранное";
    });
  }

  void _showSortBottomSheet() {
    SortBottomSheet.show(
      context: context,
      sortOptions: _sortOptions,
      currentSortIndex: _currentSortIndex,
      onSortChanged: (index) => setState(() => _currentSortIndex = index),
    );
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _deleteSelectedArticles() {
    if (_selectedArticles.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить статьи?'),
        content: Text('Вы уверены, что хотите удалить ${_selectedArticles.length} статей?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          TextButton(
            onPressed: () {
              final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);

              for (final id in _selectedArticles) {
                articlesProvider.removeArticle(id);
              }

              _toggleSelectionMode();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Удалено ${_selectedArticles.length} статей'),
                  backgroundColor: const Color(0xFF10B981), // Изумрудный
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredArticles(List<Map<String, dynamic>> allArticles) {
    final selectedCategory = _categories[_currentTabIndex];
    var filtered = allArticles.where((article) {
      final matchesSearch = _searchQuery.isEmpty ||
          _searchQuery == "избранное" ||
          (article['title']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (article['description']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = selectedCategory.id == 'all' ||
          _categoryMatches(article['category']?.toString() ?? '', selectedCategory);

      final matchesFavorites = _searchQuery != "избранное" ||
          _favoriteArticleIds.contains(article['id']?.toString());

      return matchesSearch && matchesCategory && matchesFavorites;
    }).toList();

    filtered.sort(_sortOptions[_currentSortIndex].comparator);
    return filtered;
  }

  bool _categoryMatches(String articleCategory, ArticleCategory selectedCategory) {
    final categoryMap = {
      'Спорт': 'sport',
      'Киберспорт': 'games',
      'Здоровье': 'communication',
      'Технологии': 'programming',
      'Образование': 'programming',
      'Психология': 'communication',
      'Карьера': 'business',
      'Бизнес': 'business',
      'Игры': 'games',
      'Программирование': 'programming',
    };

    final articleCategoryId = categoryMap[articleCategory] ?? articleCategory.toLowerCase();
    return articleCategoryId == selectedCategory.id;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = LayoutService.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        constraints: const BoxConstraints(minWidth: LayoutService.minContentWidth),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              isMobile ? _buildMobileContent() : _buildDesktopContent(),
              if (_showScrollToTop) _buildScrollToTopButton(isMobile),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(isMobile),
    );
  }

  Widget _buildMobileContent() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Consumer<ArticlesProvider>(
            builder: (context, articlesProvider, child) {
              return _buildContent(articlesProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return LayoutService.buildDesktopLayout(
      Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Consumer<ArticlesProvider>(
              builder: (context, articlesProvider, child) {
                return _buildContent(articlesProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return ArticlesAppBar(
      isSelectionMode: _isSelectionMode,
      selectedArticlesCount: _selectedArticles.length,
      onDeleteSelected: _deleteSelectedArticles,
      onToggleSelectionMode: _toggleSelectionMode,
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      searchQuery: _searchQuery,
      showSearchBar: _showSearchBar,
      showFilters: _showFilters,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onSearchToggled: () => setState(() => _showSearchBar = true),
      onSearchClosed: () => setState(() {
        _showSearchBar = false;
        _searchController.clear();
        _searchQuery = '';
      }),
      onFiltersToggled: _toggleFilters,
      onSortToggled: _showSortBottomSheet,
    );
  }

  Widget _buildContent(ArticlesProvider articlesProvider) {
    final isMobile = LayoutService.isMobile(context);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Filters
        SliverToBoxAdapter(
          child: FiltersSection(
            showFilters: _showFilters,
            searchQuery: _searchQuery,
            currentSortIndex: _currentSortIndex,
            onSortChanged: (index) => setState(() => _currentSortIndex = index),
            onShowFavorites: _showFavorites,
            isMobile: isMobile,
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: CategoriesSection(
            categories: _categories,
            currentTabIndex: _currentTabIndex,
            onCategoryChanged: (index) => setState(() => _currentTabIndex = index),
            isMobile: isMobile,
          ),
        ),

        // Убрали разделительную линию - этот блок удален

        // Articles Grid
        _buildArticlesGrid(articlesProvider),
      ],
    );
  }

  Widget _buildArticlesGrid(ArticlesProvider articlesProvider) {
    final allArticles = articlesProvider.articles;
    final filteredArticles = _getFilteredArticles(allArticles);

    return ArticlesGrid(
      articles: filteredArticles,
      isLoadingMore: _isLoadingMore,
      isSelectionMode: _isSelectionMode,
      selectedArticles: _selectedArticles,
      favoriteArticleIds: _favoriteArticleIds,
      onArticleTap: _openArticleDetail,
      onArticleLongPress: _toggleArticleSelection,
      onArticleQuickPreview: _showQuickPreview,
      onSelectionModeToggled: _toggleSelectionMode,
      onFavoriteToggled: _toggleFavorite,
    );
  }

  Widget _buildScrollToTopButton(bool isMobile) {
    return Positioned(
      bottom: isMobile ? 80 : 80,
      right: isMobile ? 16 : 20,
      child: FloatingActionButton(
        onPressed: () => _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
        backgroundColor: const Color(0xFF10B981), // Изумрудный
        foregroundColor: Colors.white,
        mini: isMobile,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        ),
        child: Icon(Icons.arrow_upward_rounded, size: isMobile ? 18 : 20),
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom > 0
            ? MediaQuery.of(context).viewPadding.bottom + (isMobile ? 70 : 16)
            : (isMobile ? 70 : 16),
      ),
      child: FloatingActionButton(
        onPressed: _navigateToAddArticlePage,
        backgroundColor: const Color(0xFF10B981), // Изумрудный
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
    );
  }
}