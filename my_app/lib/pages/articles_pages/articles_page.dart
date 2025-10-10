import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../article_detail_page.dart';
import 'models/article.dart';
import 'widgets/article_card.dart';
import 'widgets/add_article_dialog.dart';
import '../../providers/articles_provider.dart';
import '../../providers/channel_state_provider.dart';

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

class SortOption {
  final String label;
  final String title;
  final IconData icon;
  final int Function(Map<String, dynamic>, Map<String, dynamic>) comparator;

  SortOption(this.label, this.title, this.icon, this.comparator);
}

class ArticleCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  ArticleCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });
}

class _ArticlesPageState extends State<ArticlesPage> {
  // Константы
  static const defaultImageUrl = 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop';
  static const defaultAvatarUrl = 'https://via.placeholder.com/150/007bff/ffffff?text=U'; // ЗАГЛУШКА ДЛЯ АВАТАРКИ

  final List<ArticleCategory> _categories = [
    ArticleCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive,
      color: Colors.blue,
    ),
    ArticleCategory(
      id: 'youtube',
      title: 'YouTube',
      description: 'Обсуждение видео и блогеров',
      icon: Icons.video_library,
      color: Colors.red,
    ),
    ArticleCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Стартапы и инвестиции',
      icon: Icons.business,
      color: Colors.orange,
    ),
    ArticleCategory(
      id: 'games',
      title: 'Игры',
      description: 'Игровая индустрия',
      icon: Icons.sports_esports,
      color: Colors.purple,
    ),
    ArticleCategory(
      id: 'programming',
      title: 'Программирование',
      description: 'Разработка и IT',
      icon: Icons.code,
      color: Colors.blue,
    ),
    ArticleCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer,
      color: Colors.green,
    ),
    ArticleCategory(
      id: 'communication',
      title: 'Общение',
      description: 'Психология и отношения',
      icon: Icons.chat,
      color: Colors.pink,
    ),
  ];

  final List<SortOption> _sortOptions = [
    SortOption('Сначала новые', 'Сначала новые', Icons.new_releases, (a, b) {
      final dateA = DateTime.parse(a['publish_date'] ?? '');
      final dateB = DateTime.parse(b['publish_date'] ?? '');
      return dateB.compareTo(dateA);
    }),
    SortOption('По популярности', 'По популярности', Icons.trending_up, (a, b) {
      final viewsA = (a['views'] as int?) ?? 0;
      final viewsB = (b['views'] as int?) ?? 0;
      return viewsB.compareTo(viewsA);
    }),
    SortOption('По лайкам', 'По лайкам', Icons.favorite, (a, b) {
      final likesA = (a['likes'] as int?) ?? 0;
      final likesB = (b['likes'] as int?) ?? 0;
      return likesB.compareTo(likesA);
    }),
  ];

  final List<String> _emojis = ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'];
  final List<String> _popularSearches = ['Flutter', 'Dart', 'Программирование', 'Бизнес'];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Set<String> _favoriteArticleIds = <String>{};
  final Set<String> _selectedArticles = <String>{};
  final List<String> _searchHistory = [];

  int _currentTabIndex = 0;
  int _currentSortIndex = 0;
  String _searchQuery = '';

  bool _isLoadingMore = false;
  bool _isOffline = false;
  bool _isSelectionMode = false;
  bool _showSearchBar = false;
  bool _showFilters = false;

  // ОБНОВЛЕННЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ
  String _getUserAvatarUrl(BuildContext context) {
    try {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);

      // Пытаемся получить аватарку из ChannelStateProvider
      final customAvatar = channelStateProvider.getCurrentAvatar(
        'user_${widget.userEmail}', // Используем email как идентификатор
        defaultAvatar: defaultAvatarUrl, // ИСПОЛЬЗУЕМ ЗАГЛУШКУ
      );

      return customAvatar ?? defaultAvatarUrl; // ВОЗВРАЩАЕМ ЗАГЛУШКУ
    } catch (e) {
      // Если произошла ошибка, возвращаем заглушку
      return defaultAvatarUrl;
    }
  }

  // Адаптивные методы
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1800) return 4;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 700) return 2;
    return 1;
  }

  double _getCardAspectRatio(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1: return 0.85;
      case 2: return 0.9;
      case 3: return 0.95;
      case 4: return 1.0;
      default: return 0.9;
    }
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 80;
    return 16;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
    _loadCachedArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkConnectivity() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isOffline = false;
    });
  }

  void _loadCachedArticles() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoadingMore = false;
    });
  }

  AuthorLevel _parseAuthorLevel(dynamic authorLevelData) {
    if (authorLevelData == null) return AuthorLevel.beginner;
    if (authorLevelData is String) {
      return authorLevelData.toLowerCase() == 'expert' ? AuthorLevel.expert : AuthorLevel.beginner;
    }
    return AuthorLevel.beginner;
  }

  DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    try {
      if (dateData is String) return DateTime.parse(dateData);
      if (dateData is DateTime) return dateData;
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  void _openArticleDetail(Map<String, dynamic> articleData) {
    final article = Article(
      id: articleData['id']?.toString() ?? '',
      title: articleData['title'] ?? '',
      description: articleData['description'] ?? '',
      emoji: articleData['emoji'] ?? '📝',
      content: articleData['content'] ?? '',
      views: (articleData['views'] as int?) ?? 0,
      likes: (articleData['likes'] as int?) ?? 0,
      publishDate: _parseDate(articleData['publish_date']),
      category: articleData['category'] ?? 'Общее',
      author: articleData['author'] ?? 'Неизвестный автор',
      imageUrl: articleData['image_url'] ?? defaultImageUrl,
      authorLevel: _parseAuthorLevel(articleData['author_level']),
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article)));
  }

  void _navigateToAddArticlePage() {
    final currentAvatarUrl = _getUserAvatarUrl(context);
    final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddArticlePage(
          categories: _categories.where((cat) => cat.id != 'all').map((cat) => cat.title).toList(),
          emojis: _emojis,
          onArticleAdded: (newArticle) {
            final articleData = {
              "id": "article-${DateTime.now().millisecondsSinceEpoch}",
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
                duration: const Duration(seconds: 2),
              ),
            );
          },
          userName: widget.userName,
          userAvatarUrl: currentAvatarUrl,
        ),
      ),
    );
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

  void _deleteSelectedArticles() {
    if (_selectedArticles.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить статьи?'),
        content: Text('Вы уверены, что хотите удалить ${_selectedArticles.length} статей?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
              for (final id in _selectedArticles) {
                articlesProvider.removeArticle(id);
              }
              _toggleSelectionMode();
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareSelectedArticles() {
    if (_selectedArticles.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Поделиться ${_selectedArticles.length} статьями')));
  }

  void _addToSearchHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5) _searchHistory.removeLast();
      });
    }
  }

  void _showFavorites() {
    setState(() {
      _currentTabIndex = 0;
      _searchQuery = "избранное";
    });
  }

  // ВИДЖЕТЫ ДЛЯ ФИЛЬТРОВ И КАТЕГОРИЙ
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _buildFilterChip('verified', 'Только проверенные', Icons.verified),
                    _buildFilterChip('favorites', 'Избранное', Icons.favorite),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String id, String title, IconData icon) {
    final isActive = id == 'favorites' && _searchQuery == "избранное";

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (id == 'favorites') {
              _showFavorites();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isActive ? Colors.white : Colors.blue),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Категории',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: _categories.asMap().entries.map((entry) {
                    final category = entry.value;
                    return _buildCategoryChip(category);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ArticleCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            setState(() {
              _currentTabIndex = _categories.indexOf(category);
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16, color: isSelected ? Colors.white : category.color),
                const SizedBox(width: 6),
                Text(category.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Виджет поля поиска
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
          hintText: 'Поиск статей...',
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
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  void _showSortBottomSheet() {
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
            const SizedBox(height: 12),
            const Text('Сортировка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._sortOptions.map((option) => ListTile(
              leading: Icon(option.icon, size: 18),
              title: Text(option.title, style: const TextStyle(fontSize: 13)),
              trailing: _sortOptions.indexOf(option) == _currentSortIndex
                  ? const Icon(Icons.check, color: Colors.blue, size: 18)
                  : null,
              onTap: () {
                setState(() => _currentSortIndex = _sortOptions.indexOf(option));
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    // ПОЛУЧАЕМ АКТУАЛЬНУЮ АВАТАРКУ
    final currentAvatarUrl = _getUserAvatarUrl(context);

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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    if (!_showSearchBar) ...[
                      const Text(
                        'Статьи',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],

                    if (_showSearchBar)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildSearchField()),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.black, size: 18),
                              ),
                              onPressed: () => setState(() {
                                _showSearchBar = false;
                                _searchController.clear();
                                _searchQuery = '';
                              }),
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
                              child: const Icon(Icons.search, color: Colors.black, size: 18),
                            ),
                            onPressed: () => setState(() => _showSearchBar = true),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                            onPressed: () => setState(() => _showFilters = !_showFilters),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.sort, color: Colors.black, size: 18),
                            ),
                            onPressed: _showSortBottomSheet,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Consumer2<ArticlesProvider, ChannelStateProvider>(
                    builder: (context, articlesProvider, channelStateProvider, child) {
                      return _buildContent(articlesProvider, horizontalPadding);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Кнопка добавления статьи
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddArticlePage,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }


  Widget _buildContent(ArticlesProvider articlesProvider, double horizontalPadding) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Фильтры
        SliverToBoxAdapter(child: _buildFiltersCard(horizontalPadding)),

        // Категории
        SliverToBoxAdapter(child: _buildCategoriesCard(horizontalPadding)),

        // Карточки статей
        _buildArticlesGrid(articlesProvider, horizontalPadding),
      ],
    );
  }

  Widget _buildArticlesGrid(ArticlesProvider articlesProvider, double horizontalPadding) {
    final filteredArticles = _getFilteredArticles(articlesProvider.articles);

    if (filteredArticles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 8),
              const Text('Статьи не найдены', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Попробуйте изменить параметры поиска', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: _getCardAspectRatio(context),
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == filteredArticles.length && _isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            }
            if (index >= filteredArticles.length) return const SizedBox.shrink();

            final articleData = filteredArticles[index];
            final article = Article(
              id: articleData['id']?.toString() ?? '',
              title: articleData['title'] ?? '',
              description: articleData['description'] ?? '',
              emoji: articleData['emoji'] ?? '📝',
              content: articleData['content'] ?? '',
              views: (articleData['views'] as int?) ?? 0,
              likes: (articleData['likes'] as int?) ?? 0,
              publishDate: _parseDate(articleData['publish_date']),
              category: articleData['category'] ?? 'Общее',
              author: articleData['author'] ?? 'Неизвестный автор',
              imageUrl: articleData['image_url'] ?? defaultImageUrl,
              authorLevel: _parseAuthorLevel(articleData['author_level']),
            );

            return Stack(
              children: [
                ArticleCard(
                  key: ValueKey(article.id),
                  article: article,
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleArticleSelection(article.id);
                    } else {
                      _openArticleDetail(articleData);
                    }
                  },
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      _toggleSelectionMode();
                      _toggleArticleSelection(article.id);
                    }
                  },
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Checkbox(
                      value: _selectedArticles.contains(article.id),
                      onChanged: (_) => _toggleArticleSelection(article.id),
                    ),
                  ),
                if (_isArticleFavorite(article.id))
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.favorite, size: 16, color: Colors.red),
                  ),
              ],
            );
          },
          childCount: filteredArticles.length + (_isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredArticles(List<Map<String, dynamic>> allArticles) {
    final selectedCategory = _categories[_currentTabIndex];
    var filtered = allArticles.where((article) {
      final matchesSearch = _searchQuery.isEmpty ||
          (article['title']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (article['description']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = selectedCategory.id == 'all' ||
          (article['category']?.toString() ?? '').toLowerCase() == selectedCategory.id.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    filtered.sort(_sortOptions[_currentSortIndex].comparator);
    return filtered;
  }
}