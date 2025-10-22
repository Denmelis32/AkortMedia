import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/articles_pages/test_articles.dart';
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
  final int articleCount;

  ArticleCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.articleCount = 0,
  });
}

class _ArticlesPageState extends State<ArticlesPage> {
  // Константы
  static const defaultImageUrl = 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop';
  static const defaultAvatarUrl = 'https://via.placeholder.com/150/007bff/ffffff?text=U';

  // Цветовая палитра
  final Color _primaryColor = const Color(0xFF10B981);
  final Color _secondaryColor = const Color(0xFF059669);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF1E293B);
  final Color _lightTextColor = const Color(0xFF64748B);

  final List<ArticleCategory> _categories = [
    ArticleCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive_rounded,
      color: Color(0xFF10B981),
      articleCount: 42,
    ),
    ArticleCategory(
      id: 'youtube',
      title: 'YouTube',
      description: 'Обсуждение видео и блогеров',
      icon: Icons.play_circle_fill_rounded,
      color: Color(0xFFEF4444),
      articleCount: 15,
    ),
    ArticleCategory(
      id: 'business',
      title: 'Бизнес',
      description: 'Стартапы и инвестиции',
      icon: Icons.business_center_rounded,
      color: Color(0xFFF59E0B),
      articleCount: 8,
    ),
    ArticleCategory(
      id: 'games',
      title: 'Игры',
      description: 'Игровая индустрия',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF8B5CF6),
      articleCount: 12,
    ),
    ArticleCategory(
      id: 'programming',
      title: 'Программирование',
      description: 'Разработка и IT',
      icon: Icons.code_rounded,
      color: Color(0xFF3B82F6),
      articleCount: 25,
    ),
    ArticleCategory(
      id: 'sport',
      title: 'Спорт',
      description: 'Спортивные события',
      icon: Icons.sports_soccer_rounded,
      color: Color(0xFF10B981),
      articleCount: 7,
    ),
    ArticleCategory(
      id: 'communication',
      title: 'Общение',
      description: 'Психология и отношения',
      icon: Icons.psychology_rounded,
      color: Color(0xFFEC4899),
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

  final List<String> _emojis = ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'];
  final List<String> _popularSearches = ['Flutter', 'Dart', 'Программирование', 'Бизнес'];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

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
  bool _showScrollToTop = false;

  // ФИКСИРОВАННАЯ МАКСИМАЛЬНАЯ ШИРИНА ДЛЯ ДЕСКТОПА
  double get _maxContentWidth => 1200;

  // МИНИМАЛЬНАЯ ШИРИНА ДЛЯ ЗАЩИТЫ ОТ OVERFLOW
  double get _minContentWidth => 320;

  // АДАПТИВНЫЕ МЕТОДЫ
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final contentWidth = _getContentWidth(context);

    if (contentWidth > 1000) return 3;
    if (contentWidth > 700) return 2;
    return 1;
  }

  // Определяем, мобильное ли устройство
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // ШИРИНА КОНТЕНТА С УЧЕТОМ ОГРАНИЧЕНИЙ
  double _getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > _maxContentWidth) return _maxContentWidth;
    return screenWidth;
  }

  // ОПТИМАЛЬНЫЕ ПРОПОРЦИИ С ЗАЩИТОЙ ОТ OVERFLOW
  double _getCardAspectRatio(BuildContext context) {
    final contentWidth = _getContentWidth(context);

    if (contentWidth > 1000) return 0.75;  // Десктоп - широкие
    if (contentWidth > 800) return 0.85;   // Ноутбуки
    if (contentWidth > 600) return 1.0;    // Планшеты
    return 1.3;                            // Мобильные - высокие
  }

  // АДАПТИВНЫЕ ОТСТУПЫ
  double _getHorizontalPadding(BuildContext context) {
    final contentWidth = _getContentWidth(context);
    if (contentWidth > 1000) return 24;
    if (contentWidth > 800) return 20;
    if (contentWidth > 600) return 16;
    return 12;
  }

  // ОТСТУПЫ МЕЖДУ КАРТОЧКАМИ
  double _getGridSpacing(BuildContext context) {
    if (_isMobile(context)) return 8;
    return 6;
  }

  // АДАПТИВНЫЕ ОТСТУПЫ В КАРТОЧКАХ
  double _getCardPadding(BuildContext context) {
    final contentWidth = _getContentWidth(context);
    if (contentWidth > 1000) return 16;
    if (contentWidth > 600) return 12;
    return 8;
  }

  // ОБНОВЛЕННЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ
  String _getUserAvatarUrl(BuildContext context) {
    try {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);

      final customAvatar = channelStateProvider.getCurrentAvatar(
        'user_${widget.userEmail}',
        defaultAvatar: defaultAvatarUrl,
      );

      return customAvatar ?? defaultAvatarUrl;
    } catch (e) {
      return defaultAvatarUrl;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
    _loadCachedArticles();

    // Слушаем изменения контрастности
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHighContrast();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
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
    // Проверяем, нужно ли показать кнопку "Наверх"
    if (_scrollController.offset > 400 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 400 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }

    // Бесконечный скролл
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

  // ПРОВЕРКА ВЫСОКОЙ КОНТРАСТНОСТИ
  void _checkHighContrast() {
    final mediaQuery = MediaQuery.of(context);
    final isHighContrast = mediaQuery.highContrast;

    // Можно адаптировать цвета для высококонтрастного режима
    if (isHighContrast) {
      // Логика для высококонтрастного режима
    }
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(article: article),
      ),
    );
  }

  // БЫСТРЫЙ ПРЕДПРОСМОТР СТАТЬИ
  void _showQuickPreview(Map<String, dynamic> articleData) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Хедер предпросмотра
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.visibility_rounded, size: 20, color: _primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Быстрый просмотр',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: _lightTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article.content.length > 200
                          ? '${article.content.substring(0, 200)}...'
                          : article.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Закрыть',
                        style: TextStyle(color: _lightTextColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openArticleDetail(articleData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Читать полностью'),
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
                backgroundColor: _primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: _lightTextColor)),
          ),
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Поделиться ${_selectedArticles.length} статьями'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
        )
    );
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

  // ПРОКРУТКА К НАЧАЛУ
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // ВИДЖЕТЫ ДЛЯ ФИЛЬТРОВ И КАТЕГОРИЙ
  Widget _buildFiltersCard(double horizontalPadding) {
    if (!_showFilters) return const SizedBox.shrink();

    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _surfaceColor,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _buildFilterChip('verified', 'Только проверенные', Icons.verified_rounded),
                    _buildFilterChip('favorites', 'Избранное', Icons.favorite_rounded),
                    _buildFilterChip('popular', 'Популярные', Icons.trending_up_rounded),
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
    final isActive = (id == 'favorites' && _searchQuery == "избранное") ||
        (id == 'popular' && _currentSortIndex == 1);
    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: Material(
        color: isActive ? _primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (id == 'favorites') {
              _showFavorites();
            } else if (id == 'popular') {
              setState(() => _currentSortIndex = 1);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? _primaryColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isMobile ? 14 : 16,
                  color: isActive ? Colors.white : _primaryColor,
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ОБНОВЛЕННЫЙ ВИДЖЕТ КАТЕГОРИЙ С АДАПТАЦИЕЙ ДЛЯ ТЕЛЕФОНА
  Widget _buildCategoriesCard(double horizontalPadding) {
    final isMobile = _isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _surfaceColor,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Категории',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // АДАПТИВНЫЙ СПИСОК КАТЕГОРИЙ
              if (isMobile)
                _buildMobileCategories()
              else
                _buildDesktopCategories(),
            ],
          ),
        ),
      ),
    );
  }

  // ГОРИЗОНТАЛЬНЫЙ СКРОЛЛ КАТЕГОРИЙ ДЛЯ ТЕЛЕФОНА
  Widget _buildMobileCategories() {
    return SizedBox(
      height: 42, // ЕЩЕ БОЛЕЕ КОМПАКТНАЯ ВЫСОТА
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildMobileCategoryChip(category);
        },
      ),
    );
  }

  // КАТЕГОРИИ ДЛЯ ДЕСКТОПА
  Widget _buildDesktopCategories() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) => _buildDesktopCategoryChip(category)).toList(),
    );
  }

  Widget _buildMobileCategoryChip(ArticleCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return Container(
      margin: const EdgeInsets.only(right: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 14,
                  color: isSelected ? Colors.white : category.color,
                ),
                const SizedBox(width: 4),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : _textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.articleCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCategoryChip(ArticleCategory category) {
    final isSelected = _currentTabIndex == _categories.indexOf(category);

    return Material(
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
              color: isSelected ? category.color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 16,
                color: isSelected ? Colors.white : category.color,
              ),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : _textColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.articleCount.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск статей...',
          hintStyle: TextStyle(color: _lightTextColor, fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: _primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, size: 18, color: _lightTextColor),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 15),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Сортировка',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map((option) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, size: 20, color: _primaryColor),
              ),
              title: Text(
                option.title,
                style: TextStyle(
                  fontSize: 15,
                  color: _textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: _sortOptions.indexOf(option) == _currentSortIndex
                  ? Icon(Icons.check_rounded, color: _primaryColor, size: 20)
                  : null,
              onTap: () {
                setState(() => _currentSortIndex = _sortOptions.indexOf(option));
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  // ОСНОВНОЙ LAYOUT С ФИКСИРОВАННОЙ ШИРИНОЙ
  Widget _buildDesktopLayout(Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _maxContentWidth,
          minWidth: _minContentWidth,
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final isMobile = _isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        constraints: BoxConstraints(
          minWidth: _minContentWidth,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _backgroundColor,
              _backgroundColor.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              isMobile
                  ? _buildMobileContent(horizontalPadding)
                  : _buildDesktopContent(horizontalPadding),

              // ПЛАВАЮЩАЯ КНОПКА "НАВЕРХ" С АДАПТАЦИЕЙ ДЛЯ ТЕЛЕФОНА
              if (_showScrollToTop)
                Positioned(
                  bottom: isMobile ? 80 : 80, // Поднимаем выше на телефоне
                  right: isMobile ? 16 : 20,
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    mini: isMobile, // Мини-версия на телефоне
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                    ),
                    child: Icon(
                        Icons.arrow_upward_rounded,
                        size: isMobile ? 18 : 20
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? _buildMobileFloatingActionButton()
          : _buildDesktopFloatingActionButton(),
    );
  }


  Widget _buildDesktopFloatingActionButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom > 0
            ? MediaQuery.of(context).viewPadding.bottom + 16
            : 16,
      ),
      child: FloatingActionButton(
        onPressed: _navigateToAddArticlePage,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
    );
  }


  Widget _buildMobileFloatingActionButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom > 0
            ? MediaQuery.of(context).viewPadding.bottom + 70 // Поднимаем выше чтобы не конфликтовала
            : 70,
      ),
      child: FloatingActionButton(
        onPressed: _navigateToAddArticlePage,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
    );
  }



  Widget _buildMobileContent(double horizontalPadding) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        _buildCompactAppBar(horizontalPadding, true),
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
    );
  }


  Widget _buildDesktopContent(double horizontalPadding) {
    return _buildDesktopLayout(
      Column(
        children: [
          // КОМПАКТНЫЙ APP BAR
          _buildCompactAppBar(horizontalPadding, false),
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
    );
  }

  // APP BAR С ФОНОМ И ВЫРАВНИВАНИЕМ ПРАВОГО КОНТЕНТА
  Widget _buildCompactAppBar(double horizontalPadding, bool isMobile) {
    // Вычисляем отступ для выравнивания с категориями
    final categoriesCardMargin = isMobile ? 12.0 : horizontalPadding;
    final categoriesContentPadding = isMobile ? 12.0 : 16.0;
    final categoriesTitlePadding = 4.0;

    // Общий отступ от левого края до текста "Категории"
    final totalCategoriesLeftPadding = categoriesCardMargin + categoriesContentPadding + categoriesTitlePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!_showSearchBar) ...[
            // Заголовок "Статьи" с фоном и выравниванием по категориям
            Padding(
              padding: EdgeInsets.only(left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Статьи',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Правый контент выровненный по правому краю категорий
            Container(
              margin: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => setState(() => _showSearchBar = true),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _showFilters ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.sort_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: _showSortBottomSheet,
                  ),
                ],
              ),
            ),
          ],

          if (_showSearchBar)
            Expanded(
              child: Row(
                children: [
                  // Поле поиска с выравниванием
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding),
                        right: 8,
                      ),
                      child: _buildSearchField(),
                    ),
                  ),
                  // Кнопка закрытия с выравниванием
                  Padding(
                    padding: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: () => setState(() {
                        _showSearchBar = false;
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

        // Разделитель
        SliverToBoxAdapter(
          child: Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            color: Colors.grey.shade100,
          ),
        ),

        // Карточки статей
        _buildArticlesGrid(articlesProvider, horizontalPadding),
      ],
    );
  }

  Widget _buildArticlesGrid(ArticlesProvider articlesProvider, double horizontalPadding) {
    // Используем тестовые статьи если нет данных из провайдера
    final articlesToShow = articlesProvider.articles.isNotEmpty
        ? articlesProvider.articles
        : TestArticles.testArticles;

    final filteredArticles = _getFilteredArticles(articlesToShow);
    final isMobile = _isMobile(context);
    final gridSpacing = _getGridSpacing(context);

    if (filteredArticles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.article_rounded, size: 48, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Статьи не найдены',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить параметры поиска\nили выбрать другую категорию',
                  style: TextStyle(color: _lightTextColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ДЛЯ МОБИЛЬНЫХ - ИСПОЛЬЗУЕМ SliverList вместо SliverGrid
    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
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

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: GestureDetector(
                onLongPress: () => _showQuickPreview(articleData),
                child: Stack(
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
                      cardPadding: _getCardPadding(context),
                    ),
                    if (_isSelectionMode)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Checkbox(
                            value: _selectedArticles.contains(article.id),
                            onChanged: (_) => _toggleArticleSelection(article.id),
                            fillColor: MaterialStateProperty.all(_primaryColor),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    if (_isArticleFavorite(article.id))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.favorite_rounded, size: 16, color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          childCount: filteredArticles.length,
        ),
      );
    }

    // ДЛЯ ПЛАНШЕТОВ И КОМПЬЮТЕРОВ - ИСПОЛЬЗУЕМ SliverGrid С ФИКСИРОВАННОЙ ВЫСОТОЙ
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          // ЗАМЕНА childAspectRatio на фиксированную высоту
          childAspectRatio: _calculateFixedAspectRatio(context),
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

            return GestureDetector(
              onLongPress: () => _showQuickPreview(articleData),
              child: Container(
                margin: const EdgeInsets.all(2),
                child: Stack(
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
                      cardPadding: _getCardPadding(context),
                    ),
                    if (_isSelectionMode)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Checkbox(
                            value: _selectedArticles.contains(article.id),
                            onChanged: (_) => _toggleArticleSelection(article.id),
                            fillColor: MaterialStateProperty.all(_primaryColor),
                          ),
                        ),
                      ),
                    if (_isArticleFavorite(article.id))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.favorite_rounded, size: 16, color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          childCount: filteredArticles.length + (_isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

// ДОБАВЬТЕ ЭТОТ МЕТОД В КЛАСС _ArticlesPageState
  double _calculateFixedAspectRatio(BuildContext context) {
    final contentWidth = _getContentWidth(context);
    final crossAxisCount = _getCrossAxisCount(context);

    // Ширина одной карточки
    final horizontalPadding = _getHorizontalPadding(context);
    final gridSpacing = _getGridSpacing(context);

    final cardWidth = (contentWidth - (horizontalPadding * 2) -
        (gridSpacing * (crossAxisCount - 1))) / crossAxisCount;

    // Фиксированная высота карточки (должна совпадать с fixedCardHeight в ArticleCard)
    final fixedCardHeight = 460.0;

    // Рассчитываем aspect ratio: ширина / высота
    return cardWidth / fixedCardHeight;
  }







  List<Map<String, dynamic>> _getFilteredArticles(List<Map<String, dynamic>> allArticles) {
    final selectedCategory = _categories[_currentTabIndex];
    var filtered = allArticles.where((article) {
      final matchesSearch = _searchQuery.isEmpty ||
          _searchQuery == "избранное" ||
          (article['title']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (article['description']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = selectedCategory.id == 'all' ||
          (article['category']?.toString() ?? '').toLowerCase() == selectedCategory.id.toLowerCase();

      final matchesFavorites = _searchQuery != "избранное" ||
          _favoriteArticleIds.contains(article['id']?.toString());

      return matchesSearch && matchesCategory && matchesFavorites;
    }).toList();

    filtered.sort(_sortOptions[_currentSortIndex].comparator);
    return filtered;
  }
}