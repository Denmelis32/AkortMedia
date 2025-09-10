import 'package:flutter/material.dart';
import '../models/article.dart';
import 'home_page.dart';
import 'article_detail_page.dart';

class ArticlesPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ArticlesPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {

  static const Color primaryColor = Color(0xFF1E88E5); // Синий цвет
  static const Color backgroundColor = Color(0xFFF5F5F5);

  final List<Article> _articles = [
    Article(
      id: '1',
      title: 'Тактика чемпионов: анализ игры топ-клубов',
      content: 'Подробный разбор тактических схем ведущих футбольных клубов Европы в текущем сезоне. Узнайте, какие стратегии приносят победы и как команды адаптируются к разным соперникам.',
      author: 'Алексей Футболов',
      publishDate: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Тактика',
      imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&h=400&q=80',
      readTime: 8,
      views: 1245,
      likes: 89,
    ),
    Article(
      id: '2',
      title: 'Молодые таланты 2024: на кого стоит обратить внимание',
      content: 'Обзор самых перспективных молодых игроков, которые могут взорвать трансферный рынок. Откройте для себя будущих звезд мирового футбола.',
      author: 'Мария Скаут',
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Аналитика',
      imageUrl: 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&h=400&q=80',
      readTime: 6,
      views: 987,
      likes: 67,
    ),
    Article(
      id: '3',
      title: 'История легендарных дерби: от Эль-Класико до Олд-Фирм',
      content: 'Погружение в историю самых принципиальных противостояний в мировом футболе. Узнайте о страстях, традициях и самых запоминающихся матчах.',
      author: 'Иван Историк',
      publishDate: DateTime.now().subtract(const Duration(days: 7)),
      category: 'История',
      imageUrl: 'https://images.unsplash.com/photo-1599669454699-248893623464?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&h=400&q=80',
      readTime: 12,
      views: 1567,
      likes: 112,
    ),
    Article(
      id: '4',
      title: 'Питание футболиста: секреты профессионалов',
      content: 'Как питаются лучшие футболисты мира? Раскрываем секреты диет, которые помогают показывать最高ые результаты на поле.',
      author: 'Ольга Диетолог',
      publishDate: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Здоровье',
      imageUrl: 'https://images.unsplash.com/photo-1550461716-dbf266b2a8a5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&h=400&q=80',
      readTime: 7,
      views: 876,
      likes: 54,
    ),
  ];

  // Функция для открытия диалога создания статьи
  void _openAddArticleDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController readTimeController = TextEditingController();

    String? selectedCategory;
    final List<String> categories = [
      'Тактика', 'Аналитика', 'История', 'Здоровье', 'Тренировки', 'Трансферы'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новую статью'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок статьи',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Содержание статьи',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedCategory = newValue;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL изображения (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: readTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Время чтения (в минутах)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty &&
                    selectedCategory != null) {
                  _addNewArticle(
                    titleController.text,
                    contentController.text,
                    selectedCategory!,
                    imageUrlController.text,
                    int.tryParse(readTimeController.text) ?? 5,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Заполните все обязательные поля'),
                    ),
                  );
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // Функция для добавления новой статьи
  void _addNewArticle(String title, String content, String category,
      String imageUrl, int readTime) {
    final newArticle = Article(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      author: widget.userName,
      publishDate: DateTime.now(),
      category: category,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&h=400&q=80',
      readTime: readTime,
      views: 0,
      likes: 0,
    );

    setState(() {
      _articles.insert(0, newArticle);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Статья успешно добавлена!'),
      ),
    );
  }

  void _likeArticle(int index) {
    setState(() {
      final article = _articles[index];
      if (article.likedBy.contains(widget.userEmail)) {
        _articles[index] = article.copyWith(
          likes: article.likes - 1,
          likedBy: List.from(article.likedBy)..remove(widget.userEmail),
        );
      } else {
        _articles[index] = article.copyWith(
          likes: article.likes + 1,
          likedBy: List.from(article.likedBy)..add(widget.userEmail),
        );
      }
    });
  }

  void _viewArticle(int index) {
    setState(() {
      _articles[index] = _articles[index].copyWith(
        views: _articles[index].views + 1,
      );
    });
  }

  // НОВЫЙ МЕТОД: Открытие полной статьи
  void _openArticleDetail(int index) {
    _viewArticle(index); // Увеличиваем счетчик просмотров

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(
          article: _articles[index],
          userEmail: widget.userEmail,
          onLike: () => _likeArticle(index),
          onView: () => _viewArticle(index),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 7) return '${difference.inDays} д назад';

    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  // Метод для создания красивого плейсхолдера вместо ошибки
  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Футбольное фото',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddArticleDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        color: backgroundColor,
        child: _articles.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'Пока нет статей',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Нажмите + чтобы добавить первую статью!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: _articles.length,
          itemBuilder: (context, index) {
            final article = _articles[index];
            final isLiked = article.likedBy.contains(widget.userEmail);

            return GestureDetector(
              onTap: () => _openArticleDetail(index), // ИЗМЕНЕНО: открываем полную статью
              child: Card(
                margin: EdgeInsets.only(bottom: screenWidth * 0.04),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Изображение статьи
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        article.imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Категория и время чтения
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  article.category,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${article.readTime} мин',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Заголовок
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Контент
                          Text(
                            article.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 16),

                          // Футер статьи
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor,
                                radius: 14,
                                child: Text(
                                  article.author[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.author,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatDateTime(article.publishDate),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Статистика
                          Row(
                            children: [
                              // Кнопка лайка
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey,
                                  size: 22,
                                ),
                                onPressed: () => _likeArticle(index),
                              ),
                              Text(
                                _formatNumber(article.likes),
                                style: TextStyle(
                                  color: isLiked ? Colors.red : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Просмотры
                              Icon(
                                Icons.visibility,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatNumber(article.views),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),

                              // Кнопка поделиться
                              IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: Colors.grey[600],
                                  size: 22,
                                ),
                                onPressed: () {
                                  // Функция поделиться
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Метод для форматирования чисел (1K, 1M)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}