// lib/pages/articles_page.dart
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
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Фильтр по категориям', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('Все'),
                ..._categories.map((category) => _buildCategoryChip(category)),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return ChoiceChip(
      label: Text(category),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : 'Все';
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        child: Icon(Icons.add),
        tooltip: 'Добавить статью',
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Статьи о футболе',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[800]!, Colors.blue[600]!],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Привет, ${widget.userName}!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Фильтры',
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: widget.onLogout,
                tooltip: 'Выйти',
              ),
            ],
          ),

          // Поисковая строка
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск статей...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Индикатор фильтров
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Фильтр: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(_selectedCategory),
                    backgroundColor: Colors.blue[50],
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    SizedBox(width: 8),
                    Chip(
                      label: Text('Поиск: "$_searchQuery"'),
                      backgroundColor: Colors.green[50],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Контент статей
          _filteredArticles.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Статьи не найдены',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Попробуйте изменить параметры поиска',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final article = _filteredArticles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildArticleCard(article),
                );
              },
              childCount: _filteredArticles.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openArticleDetail(article),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article.category,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    article.emoji,
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                article.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                article.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Автор и дата
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      article.author[0],
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    article.author,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Spacer(),
                  Text(
                    article.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Статистика
              Row(
                children: [
                  _buildStatIconText(Icons.visibility_outlined, '${article.views}'),
                  SizedBox(width: 16),
                  _buildStatIconText(Icons.favorite_border, '${article.likes}'),
                  Spacer(),
                  Icon(Icons.comment, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('12', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

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

  String _selectedCategory = 'Тактика';
  String _selectedEmoji = '📊';
  int _charCount = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Добавить новую статью',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Эмодзи и категория
                Row(
                  children: [
                    DropdownButton<String>(
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
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: widget.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Заголовок
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Заголовок статьи',
                    border: OutlineInputBorder(),
                  ),
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
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Содержание статьи',
                    border: OutlineInputBorder(),
                    counterText: '$_charCount/560 символов',
                  ),
                  maxLines: 6,
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
                LinearProgressIndicator(
                  value: _charCount / 560,
                  backgroundColor: Colors.grey[300],
                  color: _charCount >= 560 ? Colors.green : Colors.blue,
                ),
                SizedBox(height: 16),

                // Кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Отмена'),
                    ),
                    SizedBox(width: 8),
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
                          );

                          widget.onArticleAdded(newArticle);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Статья успешно добавлена!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Text('Опубликовать'),
                    ),
                  ],
                ),
              ],
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
    super.dispose();
  }
}