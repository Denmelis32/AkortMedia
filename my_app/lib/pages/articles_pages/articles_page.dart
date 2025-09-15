import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../article_detail_page.dart';
import 'models/article.dart';
import 'widgets/article_card.dart';
import 'widgets/add_article_dialog.dart';

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
  final List<Article> _articles = [
    Article(
      id: '1',
      title: 'Тактика игры Манчестер Сити',
      description: 'Анализ тактических схем Пеп Гвардиолы в сезоне 2024/2025',
      emoji: '📊',
      content: '''
# Тактика Манчестер Сити под руководством Пеп Гвардиолы

## Введение
Манчестер Сити продолжает доминировать в английском футболе благодаря новаторским тактическим решениям Пеп Гвардиолы. В сезоне 2024/2025 команда представила несколько новых элементов.

## Основная схема
Гвардиола чаще всего использует гибкую схему 4-3-3, которая трансформируется в 3-2-4-1 при атаке. Задние защитники перемещаются в центр, позволяя крайним защитникам подниматься высоко по флангам.

## Ключевые innovations
- **Инвертированные латерали**: Камвин и Уокер часто перемещаются в центр поля
- **Ложная девятка**: Холаннд оттягивается на позицию плеймейкера
- **Высокий прессинг**: Команда начинает давить сразу после потери мяча

## Заключение
Тактическая гибкость остается главным козырем Манчестер Сити в борьбе за титулы.
''',
      views: 1250,
      likes: 345,
      publishDate: DateTime.now().subtract(const Duration(days: 2)),
      category: 'YouTube',
      author: 'Алексей Петров',
      imageUrl: 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop',
    ),
    Article(
      id: '2',
      title: 'Лучшие бомбардиры Лиги Чемпионов',
      description: 'Рейтинг самых результативных игроков сезона 2024/2025',
      emoji: '⚽',
      content: 'Содержание статьи о лучших бомбардирах...',
      views: 890,
      likes: 210,
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Бизнес',
      author: 'Иван Сидоров',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=300&fit=crop',
    ),
    Article(
      id: '3',
      title: 'Новые технологии в футболе',
      description: 'Как технологии меняют современный футбол',
      emoji: '🚀',
      content: 'Содержание статьи о технологиях...',
      views: 1560,
      likes: 420,
      publishDate: DateTime.now().subtract(const Duration(days: 3)),
      category: 'Программирование',
      author: 'Мария Иванова',
      imageUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=500&h=300&fit=crop',
    ),
    Article(
      id: '4',
      title: 'Психология победителей',
      description: 'Ментальная подготовка футболистов',
      emoji: '🧠',
      content: 'Содержание статьи о психологии...',
      views: 980,
      likes: 230,
      publishDate: DateTime.now().subtract(const Duration(days: 7)),
      category: 'Общение',
      author: 'Петр Смирнов',
      imageUrl: 'https://images.unsplash.com/photo-1545239351-ef35f43d514b?w=500&h=300&fit=crop',
    ),
  ];

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

  final List<String> _emojis = ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();
  int _currentTabIndex = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _openArticleDetail(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(article: article),
      ),
    );
  }

  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddArticleDialog(
        categories: _categories.where((cat) => cat.id != 'all').map((cat) => cat.title).toList(),
        emojis: _emojis,
        onArticleAdded: (newArticle) {
          setState(() {
            _articles.insert(0, newArticle);
          });
        },
        userName: widget.userName,
      ),
    );
  }

  List<Article> _getFilteredArticles(int tabIndex) {
    final selectedCategory = _categories[tabIndex];

    return _articles.where((article) {
      final matchesSearch = _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = selectedCategory.id == 'all' ||
          article.category.toLowerCase() == selectedCategory.title.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Фильтр по категориям',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) => _buildCategoryChip(category)).toList(),
            ),
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
        setState(() {
          _currentTabIndex = _categories.indexOf(category);
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          category.title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(ArticleCategory category, int index) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? category.color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? category.color : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              category.title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Заголовок "Статьи" вверху - исправленная версия
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              title: Text(
                'Статьи',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: ColoredBox(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return _buildTabItem(category, index);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.filter_list_rounded,
                      size: 24,
                      color: Colors.grey[700]),
                  onPressed: _showFilterBottomSheet,
                  tooltip: 'Фильтры',
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск статей...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 22),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_currentTabIndex != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Категория: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _categories[_currentTabIndex].title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentTabIndex = 0;
                                });
                              },
                              child: const Icon(Icons.close_rounded, size: 14),
                            ),
                          ],
                        ),
                      ),
                    if (_searchQuery.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Поиск: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '"$_searchQuery"',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(Icons.close_rounded, size: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: IndexedStack(
          index: _currentTabIndex,
          children: _categories.asMap().entries.map((entry) {
            final index = entry.key;
            return _CategoryContentBuilder(
              tabIndex: index,
              currentTabIndex: _currentTabIndex,
              getFilteredArticles: _getFilteredArticles,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryContentBuilder extends StatelessWidget {
  final int tabIndex;
  final int currentTabIndex;
  final List<Article> Function(int) getFilteredArticles;

  const _CategoryContentBuilder({
    required this.tabIndex,
    required this.currentTabIndex,
    required this.getFilteredArticles,
  });

  @override
  Widget build(BuildContext context) {
    // Показываем контент только для активной вкладки
    if (tabIndex != currentTabIndex) {
      return Container(); // Пустой контейнер для неактивных вкладки
    }

    final filteredArticles = getFilteredArticles(tabIndex);

    return filteredArticles.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Статьи не найдены',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить параметры поиска',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    )
        : GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles[index];
        return ArticleCard(
          article: article,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ArticleDetailPage(article: article),
              ),
            );
          },
        );
      },
    );
  }
}

// Модель категории статей с обновленными полями
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