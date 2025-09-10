// lib/pages/articles_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'article_detail_page.dart';

// Модель данных для статьи
class Article {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String content;
  final int views;
  final int likes;
  final DateTime publishDate;
  final String category;
  final String author;
  final String imageUrl; // Добавим поле для URL изображения

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.content,
    required this.views,
    required this.likes,
    required this.publishDate,
    required this.category,
    required this.author,
    required this.imageUrl, // Добавим изображение в конструктор
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(publishDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}г назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}мес назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else {
      return 'только что';
    }
  }
}

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
      category: 'Тактика',
      author: 'Алексей Петров',
      imageUrl: 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=500&h=300&fit=crop',
    ),
    Article(
      id: '2',
      title: 'Лучшие молодые таланты',
      description: 'Обзор самых перспективных молодых футболистов Европы',
      emoji: '⭐',
      content: '''
# Лучшие молодые таланты Европы 2024

## 1. Джуд Беллингем (Реал Мадрид)
В возрасте 20 лет продолжает поражать своей зрелостью и влиянием на игру.

## 2. Джереми Доку (Манчестер Сити)
Голландский вингер демонстрирует невероятную скорость и дриблинг.

## 3. Гави (Барселона)
Испанский вундеркинд уже стал ключевым игроком в Барселоне и сборной Испании.

## Выводы
Европейский футбол продолжает рождать таланты, которые скоро станут новыми суперзвездами.
''',
      views: 980,
      likes: 267,
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Аналитика',
      author: 'Мария Иванова',
      imageUrl: 'https://images.unsplash.com/photo-1575446913068-df1c1c22786a?w=500&h=300&fit=crop',
    ),
    Article(
      id: '3',
      title: 'История Лиги Чемпионов',
      description: 'От истоков до современных дней великого турнира',
      emoji: '🏆',
      content: '''
# История Лиги Чемпионов УЕФА

## Ранние годы
Турнир был основан в 1955 году как Кубок Европейских Чемпионов. Первым победителем стал мадридский Реал.

## Эра доминирования
- **1950-1960**: Доминирование Реал Мадрида (5 подряд титулов)
- **1970-е**: Успехи аяксов и Баварии
- **1980-е**: Расцвет английских клубов

## Современная эра
С 1992 года турнир был реорганизован в Лигу Чемпионов, что привело к увеличению количества участников и коммерциализации.

## Легендарные моменты
Забытый гол Зидана в финале 2002 года, камбэк Ливерпуля в 2005 и многие другие.
''',
      views: 1560,
      likes: 423,
      publishDate: DateTime.now().subtract(const Duration(days: 1)),
      category: 'История',
      author: 'Иван Сидоров',
      imageUrl: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=500&h=300&fit=crop',
    ),
    Article(
      id: '4',
      title: 'Трансферные новости',
      description: 'Самые громкие трансферы летнего окна 2024',
      emoji: '🔥',
      content: 'Содержание статьи о трансферах...',
      views: 890,
      likes: 210,
      publishDate: DateTime.now().subtract(const Duration(days: 3)),
      category: 'Трансферы',
      author: 'Петр Николаев',
      imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500&h=300&fit=crop',
    ),
  ];

  final List<String> _categories = [
    'Тактика',
    'Аналитика',
    'История',
    'Трансферы',
    'Обзоры матчей',
    'Интервью'
  ];

  final List<String> _emojis = ['📊', '⭐', '🏆', '⚽', '👑', '🔥', '🎯', '💫'];

  // Поиск и фильтрация
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Все';

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
        categories: _categories,
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

  // Фильтрация статей
  List<Article> get _filteredArticles {
    return _articles.where((article) {
      final matchesSearch = _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'Все' ||
          article.category == _selectedCategory;

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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.all(24),
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
            SizedBox(height: 16),
            Text('Фильтр по категориям',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildCategoryChip('Все'),
                ..._categories.map((category) => _buildCategoryChip(category)),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          category,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        child: Icon(Icons.add, size: 24),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        tooltip: 'Добавить статью',
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Футбольные статьи',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF007AFF),
                      Color(0xFF5856D6),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Привет, ${widget.userName}!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list_rounded, size: 24),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Фильтры',
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app_rounded, size: 24),
                onPressed: widget.onLogout,
                tooltip: 'Выйти',
              ),
            ],
          ),

          // Поисковая строка
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск статей...',
                    prefixIcon: Icon(Icons.search_rounded, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 22),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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

          // Индикатор фильтров
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedCategory != 'Все')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            _selectedCategory,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = 'Все';
                              });
                            },
                            child: Icon(Icons.close_rounded, size: 14),
                          ),
                        ],
                      ),
                    ),
                  if (_searchQuery.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            child: Icon(Icons.close_rounded, size: 14),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Контент статей в виде сетки 2x2
          _filteredArticles.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_rounded, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 20),
                  Text(
                    'Статьи не найдены',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Попробуйте изменить параметры поиска',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
              : SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final article = _filteredArticles[index];
                  return _buildArticleCard(article);
                },
                childCount: _filteredArticles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildArticleCard(Article article) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openArticleDetail(article),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column( // Изменено с Stack на Column
              children: [
                // Верхняя часть с изображением
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(article.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Градиент поверх изображения
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),

                      // Категория в левом верхнем углу
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            article.category,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Эмодзи в правом верхнем углу
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            article.emoji,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Нижняя часть с контентом
                Expanded( // Добавлен Expanded
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),

                        // Описание
                        Text(
                          article.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),

                        // Рейтинг звездами
                        Row(
                          children: List.generate(5, (index) => Icon(
                            Icons.star,
                            size: 16,
                            color: index < 4 ? Colors.amber : Colors.grey[300],
                          )),
                        ),
                        Spacer(),
                        // Автор и дата
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                article.author[0],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.author,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    article.formattedDate,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Статистика
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(Icons.remove_red_eye_outlined, article.views.toString()),
                            _buildStatItem(Icons.favorite_outline_rounded, article.likes.toString()),
                            _buildStatItem(Icons.chat_bubble_outline_rounded, '12'),
                          ],
                        ),
                      ],
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

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// Остальной код (AddArticleDialog) остается без изменений
// ...
// Продолжение файла lib/pages/articles_page.dart

// Диалог добавления новой статьи
class AddArticleDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> emojis;
  final Function(Article) onArticleAdded;
  final String userName;

  const AddArticleDialog({
    super.key,
    required this.categories,
    required this.emojis,
    required this.onArticleAdded,
    required this.userName,
  });

  @override
  State<AddArticleDialog> createState() => _AddArticleDialogState();
}

class _AddArticleDialogState extends State<AddArticleDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory = 'Тактика';
  String _selectedEmoji = '📊';
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    // Установим случайное изображение по умолчанию
    _imageUrlController.text = 'https://images.unsplash.com/photo-1552667466-07770ae110d0?w=500&h=300&fit=crop';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                  SizedBox(height: 16),
                  Text(
                    'Новая статья',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Эмодзи и категория
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedEmoji,
                          items: widget.emojis.map((emoji) {
                            return DropdownMenuItem(
                              value: emoji,
                              child: Text(emoji, style: TextStyle(fontSize: 24)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEmoji = value!;
                            });
                          },
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down_rounded),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              items: widget.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Категория',
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // URL изображения
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL изображения',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите URL изображения';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Заголовок
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Заголовок статьи',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите заголовок статьи';
                      }
                      if (value.length < 10) {
                        return 'Заголовок должен содержать минимум 10 символов';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Описание
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Краткое описание',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 2,
                    style: TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите описание статьи';
                      }
                      if (value.length < 20) {
                        return 'Описание должно содержать минимум 20 символов';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Контент
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Содержание статьи',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                        maxLines: 6,
                        style: TextStyle(fontSize: 16),
                        onChanged: (value) {
                          setState(() {
                            _charCount = value.length;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите содержание статьи';
                          }
                          if (value.length < 560) {
                            return 'Статья должна содержать минимум 560 символов';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _charCount / 560,
                              backgroundColor: Colors.grey[300],
                              color: _charCount >= 560 ? Colors.green : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '$_charCount/560',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Кнопки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Отмена'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newArticle = Article(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: _titleController.text,
                              description: _descriptionController.text,
                              emoji: _selectedEmoji,
                              content: _contentController.text,
                              views: 0,
                              likes: 0,
                              publishDate: DateTime.now(),
                              category: _selectedCategory,
                              author: widget.userName,
                              imageUrl: _imageUrlController.text,
                            );

                            widget.onArticleAdded(newArticle);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Статья успешно добавлена!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Опубликовать'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}