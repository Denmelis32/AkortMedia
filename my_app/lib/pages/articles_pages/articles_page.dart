import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../article_detail_page.dart';
import 'models/article.dart';
import 'widgets/article_card.dart';
import 'widgets/add_article_dialog.dart';
import '../../providers/articles_provider.dart';

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
  final IconData icon;
  final int Function(Map<String, dynamic>, Map<String, dynamic>) comparator;

  SortOption(this.label, this.icon, this.comparator);
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
  static const gridPadding = EdgeInsets.all(16);
  static const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.7,
  );

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
    SortOption('Сначала новые', Icons.access_time, (a, b) {
      final dateA = DateTime.parse(a['publish_date'] ?? '');
      final dateB = DateTime.parse(b['publish_date'] ?? '');
      return dateB.compareTo(dateA);
    }),
    SortOption('Сначала старые', Icons.access_time, (a, b) {
      final dateA = DateTime.parse(a['publish_date'] ?? '');
      final dateB = DateTime.parse(b['publish_date'] ?? '');
      return dateA.compareTo(dateB);
    }),
    SortOption('По популярности', Icons.trending_up, (a, b) {
      final viewsA = (a['views'] as int?) ?? 0;
      final viewsB = (b['views'] as int?) ?? 0;
      return viewsB.compareTo(viewsA);
    }),
    SortOption('По лайкам', Icons.favorite, (a, b) {
      final likesA = (a['likes'] as int?) ?? 0;
      final likesB = (b['likes'] as int?) ?? 0;
      return likesB.compareTo(likesA);
    }),
  ];

  final List<String> _emojis = ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'];
  final List<String> _popularSearches = ['Flutter', 'Dart', 'Программирование', 'Бизнес'];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();

  final Set<String> _favoriteArticleIds = <String>{};
  final Set<String> _selectedArticles = <String>{};
  final List<String> _searchHistory = [];

  int _currentTabIndex = 0;
  int _currentSortIndex = 0;
  int _currentPage = 1;
  String _searchQuery = '';

  bool _isLoadingMore = false;
  bool _isOffline = false;
  bool _isSelectionMode = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
    _loadCachedArticles();
    _checkForNewContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabScrollController.dispose();
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

  void _checkForNewContent() {
    final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
    if (articlesProvider.articles.length > 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Доступны новые статьи!'),
            action: SnackBarAction(
              label: 'Обновить',
              onPressed: () {
                setState(() {});
              },
            ),
          ),
        );
      });
    }
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
      _currentPage++;
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

  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddArticleDialog(
        categories: _categories.where((cat) => cat.id != 'all').map((cat) => cat.title).toList(),
        emojis: _emojis,
        onArticleAdded: (newArticle) {
          final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
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
          };
          articlesProvider.addArticle(articleData);
        },
        userName: widget.userName,
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
        title: Text('Удалить статьи?'),
        content: Text('Вы уверены, что хотите удалить ${_selectedArticles.length} статей?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена')),
          TextButton(
            onPressed: () {
              final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
              for (final id in _selectedArticles) {
                articlesProvider.removeArticle(id); // Теперь метод существует
              }
              _toggleSelectionMode();
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
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

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300]!, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Сортировка', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ..._sortOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _currentSortIndex == index;
              return ListTile(
                leading: Icon(option.icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
                title: Text(option.label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface)),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  setState(() => _currentSortIndex = index);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300]!, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Фильтр по категориям', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 12, children: _categories.map((category) => _buildCategoryChip(category)).toList()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ArticleCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);
    return GestureDetector(
      onTap: () {
        setState(() => _currentTabIndex = _categories.indexOf(category));
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!, width: 1),
        ),
        child: Text(category.title, style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showSearchSuggestions() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => _buildSearchSuggestionsSheet());
  }

  Widget _buildSearchSuggestionsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Text('История поиска', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _searchHistory.map((query) => ActionChip(label: Text(query), onPressed: () {
              setState(() {
                _searchController.text = query;
                _searchQuery = query;
              });
              Navigator.pop(context);
            })).toList()),
            const SizedBox(height: 16),
          ],
          Text('Популярные запросы', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _popularSearches.map((query) => ActionChip(label: Text(query), onPressed: () {
            setState(() {
              _searchController.text = query;
              _searchQuery = query;
            });
            Navigator.pop(context);
          })).toList()),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300]!, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildQuickAction(icon: Icons.trending_up, label: 'Популярные', onTap: () {
                  setState(() => _currentSortIndex = 2);
                  Navigator.pop(context);
                }),
                _buildQuickAction(icon: Icons.favorite, label: 'Избранное', onTap: () {
                  _showFavorites();
                  Navigator.pop(context);
                }),
                _buildQuickAction(icon: Icons.history, label: 'История', onTap: () {
                  _showSearchSuggestions();
                  Navigator.pop(context);
                }),
                _buildQuickAction(icon: Icons.download, label: 'Офлайн', onTap: () {
                  _downloadForOffline();
                  Navigator.pop(context);
                }),
                _buildQuickAction(icon: Icons.share, label: 'Поделиться', onTap: () {
                  _shareApp();
                  Navigator.pop(context);
                }),
                _buildQuickAction(icon: Icons.settings, label: 'Настройки', onTap: () {
                  _openSettings();
                  Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _downloadForOffline() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Статьи загружены для офлайн-чтения'), backgroundColor: Colors.green));
  }

  void _shareApp() {}
  void _openSettings() {}

  void _showPersonalizedRecommendations() {
    final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
    final recommendedArticles = articlesProvider.articles.take(3).toList();
    if (recommendedArticles.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Рекомендуем к прочтению'),
        content: Column(mainAxisSize: MainAxisSize.min, children: recommendedArticles.map((article) => ListTile(
          leading: Text(article['emoji'] ?? '📝'),
          title: Text(article['title'] ?? ''),
          onTap: () {
            Navigator.pop(context);
            _openArticleDetail(article);
          },
        )).toList()),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Закрыть'))],
      ),
    );
  }

  void _showReadingStats() {
    final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
    final totalArticles = articlesProvider.articles.length;
    final readArticles = articlesProvider.articles.where((a) => (a['views'] as int) > 0).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ваша статистика'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _buildStatItem('Прочитано статей', '$readArticles/$totalArticles'),
          _buildStatItem('В избранном', '${_favoriteArticleIds.length}'),
          _buildStatItem('Активность', '${DateTime.now().day}.${DateTime.now().month}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Закрыть'))],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ]),
    );
  }

  Widget _buildTabItem(ArticleCategory category, int index) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
          border: Border(bottom: BorderSide(color: isSelected ? category.color : Colors.transparent, width: 3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(category.icon, size: 18, color: isSelected ? category.color : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(category.title, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        child: const Icon(Icons.add, size: 24),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        tooltip: 'Добавить статью',
      ),
      body: Consumer<ArticlesProvider>(
        builder: (context, articlesProvider, child) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Text('Статьи', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20.0, fontWeight: FontWeight.w600)),
                  centerTitle: false,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: ColoredBox(
                      color: Theme.of(context).colorScheme.surface,
                      child: SingleChildScrollView(
                        controller: _tabScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _categories.asMap().entries.map((entry) => _buildTabItem(entry.value, entry.key)).toList()),
                      ),
                    ),
                  ),
                  actions: [
                    if (_isSelectionMode) ...[
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: _selectedArticles.isNotEmpty ? _deleteSelectedArticles : null, tooltip: 'Удалить выбранное'),
                      IconButton(icon: Icon(Icons.share), onPressed: _selectedArticles.isNotEmpty ? _shareSelectedArticles : null, tooltip: 'Поделиться'),
                      IconButton(icon: Icon(Icons.close), onPressed: _toggleSelectionMode, tooltip: 'Отменить выбор'),
                    ] else ...[
                      IconButton(icon: Icon(Icons.select_all), onPressed: _toggleSelectionMode, tooltip: 'Выбрать статьи'),
                      IconButton(icon: Icon(Icons.favorite, color: _favoriteArticleIds.isNotEmpty ? Colors.red : null), onPressed: _showFavorites, tooltip: 'Избранное'),
                      IconButton(icon: Icon(Icons.bolt), onPressed: _showQuickActions, tooltip: 'Быстрые действия'),
                      IconButton(icon: Icon(Icons.sort), onPressed: _showSortBottomSheet, tooltip: 'Сортировка'),
                      IconButton(icon: Icon(Icons.filter_alt), onPressed: _showFilterBottomSheet, tooltip: 'Фильтры'),
                    ],
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Поиск статей...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 22),
                          suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (_searchQuery.isNotEmpty) IconButton(icon: const Icon(Icons.clear_rounded, size: 22), onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            }),
                            IconButton(icon: const Icon(Icons.history, size: 22), onPressed: _showSearchSuggestions, tooltip: 'История поиска'),
                          ]),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                        onSubmitted: _addToSearchHistory,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      if (_currentTabIndex != 0) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Категория: ', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text(_categories[_currentTabIndex].title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                          const SizedBox(width: 4),
                          GestureDetector(onTap: () => setState(() => _currentTabIndex = 0), child: const Icon(Icons.close_rounded, size: 14)),
                        ]),
                      ),
                      if (_searchQuery.isNotEmpty) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.3), width: 1)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Поиск: ', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text('"$_searchQuery"', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green[700])),
                          const SizedBox(width: 4),
                          GestureDetector(onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          }, child: const Icon(Icons.close_rounded, size: 14)),
                        ]),
                      ),
                      if (_isOffline) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.wifi_off, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('Офлайн режим', style: TextStyle(fontSize: 12, color: Colors.orange[700])),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ];
            },
            body: _CategoryContentBuilder(
              allArticles: articlesProvider.articles,
              tabIndex: _currentTabIndex,
              searchQuery: _searchQuery,
              categories: _categories,
              sortComparator: _sortOptions[_currentSortIndex].comparator,
              onArticleTap: _openArticleDetail,
              parseAuthorLevel: _parseAuthorLevel,
              isLoadingMore: _isLoadingMore,
              scrollController: _scrollController,
              isSelectionMode: _isSelectionMode,
              selectedArticles: _selectedArticles,
              isArticleFavorite: _isArticleFavorite,
              onToggleArticleSelection: _toggleArticleSelection,
              onArticleLongPress: (articleId) { // Добавлен именованный параметр
                if (!_isSelectionMode) {
                  _toggleSelectionMode();
                  _toggleArticleSelection(articleId);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryContentBuilder extends StatelessWidget {
  final List<Map<String, dynamic>> allArticles;
  final int tabIndex;
  final String searchQuery;
  final List<ArticleCategory> categories;
  final int Function(Map<String, dynamic>, Map<String, dynamic>) sortComparator;
  final Function(Map<String, dynamic>) onArticleTap;
  final AuthorLevel Function(dynamic) parseAuthorLevel;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final bool isSelectionMode;
  final Set<String> selectedArticles;
  final bool Function(String) isArticleFavorite;
  final Function(String) onToggleArticleSelection;
  final Function(String) onArticleLongPress; // Добавлен именованный параметр

  const _CategoryContentBuilder({
    required this.allArticles,
    required this.tabIndex,
    required this.searchQuery,
    required this.categories,
    required this.sortComparator,
    required this.onArticleTap,
    required this.parseAuthorLevel,
    required this.isLoadingMore,
    required this.scrollController,
    required this.isSelectionMode,
    required this.selectedArticles,
    required this.isArticleFavorite,
    required this.onToggleArticleSelection,
    required this.onArticleLongPress, // Добавлен именованный параметр
  });

  List<Map<String, dynamic>> _getFilteredArticles() {
    final selectedCategory = categories[tabIndex];
    var filtered = allArticles.where((article) {
      final matchesSearch = searchQuery.isEmpty || (article['title']?.toString() ?? '').toLowerCase().contains(searchQuery.toLowerCase()) || (article['description']?.toString() ?? '').toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory.id == 'all' || (article['category']?.toString() ?? '').toLowerCase() == selectedCategory.id.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    filtered.sort(sortComparator);
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _getFilteredArticles();

    if (filteredArticles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredArticles.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredArticles.length && isLoadingMore) {
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
                  imageUrl: articleData['image_url'] ?? 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop',
                  authorLevel: parseAuthorLevel(articleData['author_level']),
                );

                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300 + (index % 5) * 100),
                  child: Stack(
                    children: [
                      ArticleCard(
                        key: ValueKey(article.id),
                        article: article,
                        onTap: () {
                          if (isSelectionMode) {
                            onToggleArticleSelection(article.id);
                          } else {
                            onArticleTap(articleData);
                          }
                        },
                        onLongPress: () => onArticleLongPress(article.id), // Исправлено: именованный параметр
                      ),
                      if (isSelectionMode)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Checkbox(
                            value: selectedArticles.contains(article.id),
                            onChanged: (_) => onToggleArticleSelection(article.id),
                          ),
                        ),
                      if (isArticleFavorite(article.id))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(Icons.favorite, size: 16, color: Colors.red),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('Статьи не найдены', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Попробуйте изменить параметры поиска', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
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
}