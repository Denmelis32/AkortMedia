import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/news_providers/news_provider.dart';
import '../../providers/user_provider.dart';
import 'fixed_news_card.dart';

class NewsPage extends StatefulWidget {
  final VoidCallback onLogout;

  const NewsPage({
    super.key,
    required this.onLogout,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCreatingPost = false;

  // 🎯 КАТЕГОРИИ ЛЕНТЫ - ОБНОВЛЕННЫЙ ПОРЯДОК
  int _currentCategoryIndex = 0;
  final List<String> _categories = ['Лента', 'Репосты', 'Подписки', 'Избранное'];
  final List<IconData> _categoryIcons = [
    Icons.article_rounded,
    Icons.repeat_rounded,
    Icons.people_alt_rounded,
    Icons.bookmark_rounded,
  ];

  // 🎯 ЦВЕТА ДЛЯ КАТЕГОРИЙ
  final List<Color> _categoryColors = [
    Color(0xFF7E57C2), // Лента - фиолетовый
    Color(0xFF4CAF50), // Репосты - зеленый
    Color(0xFF2196F3), // Подписки - синий
    Color(0xFFFF9800), // Избранное - оранжевый
  ];

  @override
  void initState() {
    super.initState();

    // 🆕 СЛУШАТЕЛЬ ДЛЯ БЕСКОНЕЧНОГО СКРОЛЛА
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  // 🆕 СЛУШАТЕЛЬ СКРОЛЛА ДЛЯ ПАГИНАЦИИ
  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      _loadMoreNews();
    }
  }

  void _loadMoreNews() {
    final newsProvider = context.read<NewsProvider>();
    if (newsProvider.hasMoreNews && !newsProvider.isLoadingMore && !newsProvider.isLoading) {
      print('🔄 Auto-loading more news...');
      newsProvider.loadMoreNews();
    }
  }

  void _initializeApp() async {
    print('🚀 Initializing app...');

    final newsProvider = context.read<NewsProvider>();
    final userProvider = context.read<UserProvider>();

    // Проверяем авторизацию и синхронизируем данные с сервером
    if (userProvider.isLoggedIn) {
      print('✅ User is logged in: ${userProvider.userName} (ID: ${userProvider.userId})');

      // Синхронизируем с сервером перед загрузкой новостей
      await userProvider.syncWithServer();
      print('🔄 User data synced with server');
    } else {
      print('⚠️ User not logged in, checking auth status...');
      final isAuthenticated = await userProvider.checkAuthStatus();
      if (isAuthenticated) {
        await userProvider.syncWithServer();
        print('🔄 User data synced after auth check');
      }
    }

    // Загружаем новости с пагинацией
    await newsProvider.loadNews();
  }

  // 🎯 БЕЗОПАСНОЕ ПРЕОБРАЗОВАНИЕ ТИПОВ
  Map<String, dynamic> _ensureStringMap(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map<dynamic, dynamic>) {
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        result[key.toString()] = value;
      });
      return result;
    }
    return <String, dynamic>{};
  }

  // 🆕 УЛУЧШЕННЫЙ МЕТОД ДЛЯ ОБРАБОТКИ ХЕШТЕГОВ (через пробел)
  List<String> _parseHashtags(String hashtagsText) {
    if (hashtagsText.trim().isEmpty) return [];

    return hashtagsText
        .split(' ') // 🎯 РАЗДЕЛЕНИЕ ЧЕРЕЗ ПРОБЕЛ
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.startsWith('#') ? tag.substring(1) : tag)
        .map((tag) => tag.toLowerCase())
        .where((tag) => tag.length <= 20)
        .toList();
  }

  // 🆕 МЕТОД ДЛЯ ОЧИСТКИ ФОРМЫ
  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _hashtagsController.clear();
  }

  Future<void> _createNews() async {
    final newsProvider = context.read<NewsProvider>();
    final userProvider = context.read<UserProvider>();

    // 🆕 ПРОВЕРКА АВТОРИЗАЦИИ И ДАННЫХ
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Для создания поста необходимо войти в систему'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 🆕 ПРОВЕРКА ЧТО ИМЯ ПОЛЬЗОВАТЕЛЯ ЗАГРУЖЕНО
    if (userProvider.userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Данные пользователя не загружены. Попробуйте снова.'),
          backgroundColor: Colors.orange,
        ),
      );
      await userProvider.syncWithServer(); // Попробуем синхронизировать
      return;
    }

    // 🎯 ПРОВЕРКА ОГРАНИЧЕНИЙ
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // 🆕 ТЕПЕРЬ ТОЛЬКО ОПИСАНИЕ ОБЯЗАТЕЛЬНОЕ (минимум 4 символа)
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Описание поста обязательно для заполнения'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (description.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Описание должно содержать минимум 4 символа'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (description.length > 435) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Описание не должно превышать 435 символов'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🆕 ПРОВЕРКИ ДЛЯ НЕОБЯЗАТЕЛЬНОГО ЗАГОЛОВКА
    if (title.isNotEmpty) {
      if (title.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Заголовок должен содержать минимум 5 символов'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (title.length > 75) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Заголовок не должен превышать 75 символов'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isCreatingPost = true);

    try {
      // 🆕 ПАРСИМ ХЕШТЕГИ (через пробел)
      final hashtags = _parseHashtags(_hashtagsController.text);

      // Используем данные из UserProvider
      final newsData = {
        'title': title,
        'content': description,
        'hashtags': hashtags,
        'author_id': userProvider.userId,
        'author_name': userProvider.userName,
      };

      print('🎯 Creating post as: ${userProvider.userName} (ID: ${userProvider.userId})');
      print('📝 Title: $title (${title.length}/75 символов)');
      print('📋 Content: ${description.length}/435 символов)');
      print('🏷️ Hashtags: $hashtags');

      // Создаем пост через NewsProvider
      await newsProvider.addNews(newsData);

      // Очищаем поля
      _clearForm();

      // Показываем успешное сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пост успешно создан!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isCreatingPost = false);
    }
  }

  void _showCreatePostDialog() {
    final userProvider = context.read<UserProvider>();

    // 🆕 ПРОВЕРКА АВТОРИЗАЦИИ
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Для создания поста необходимо войти в систему'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _CreatePostDialog(
        titleController: _titleController,
        descriptionController: _descriptionController,
        hashtagsController: _hashtagsController,
        isCreatingPost: _isCreatingPost,
        onCreatePost: _createNews,
        onClearForm: _clearForm,
        userProvider: userProvider,
      ),
    );
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ КАРТОЧЕК
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return 'Недавно';
    }
  }

  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Только что';
      if (difference.inMinutes < 60) return '${difference.inMinutes} мин';
      if (difference.inHours < 24) return '${difference.inHours} ч';
      if (difference.inDays < 7) return '${difference.inDays} д';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} нед';
      if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} мес';
      return '${(difference.inDays / 365).floor()} г';
    } catch (e) {
      return 'Недавно';
    }
  }

  // 🎯 ОБРАБОТЧИКИ ВЗАИМОДЕЙСТВИЙ
  void _handleLike(String postId) {
    print('🎯 HANDLE LIKE: $postId');
    final newsProvider = context.read<NewsProvider>();
    newsProvider.toggleLike(postId);
  }

  void _handleBookmark(String postId) {
    print('🎯 HANDLE BOOKMARK: $postId');
    final newsProvider = context.read<NewsProvider>();
    newsProvider.toggleBookmark(postId);
  }

  void _handleRepost(String postId) {
    print('🎯 HANDLE REPOST: $postId');
    final newsProvider = context.read<NewsProvider>();
    newsProvider.toggleRepost(postId);
  }

  void _handleFollow(String authorId) {
    print('👥 HANDLE FOLLOW: $authorId');
    final newsProvider = context.read<NewsProvider>();
    newsProvider.toggleFollow(authorId);
  }

  void _handleShare(String postId) {
    print('📤 HANDLE SHARE: $postId');
    final newsProvider = context.read<NewsProvider>();
    newsProvider.shareNews(postId);
  }

  // 🎯 ИСПРАВЛЕННЫЙ МЕТОД ДЛЯ КОММЕНТАРИЕВ
  void _handleComment(String postId, String text) {
    print('🎯 HANDLE COMMENT: $postId - "$text"');
    final newsProvider = context.read<NewsProvider>();
    newsProvider.addComment(postId, text);
  }

  // 🎯 ПРОВЕРКА ЯВЛЯЕТСЯ ЛИ ПОЛЬЗОВАТЕЛЬ АВТОРОМ ПОСТА
  bool _isCurrentUserAuthor(Map<String, dynamic> post) {
    final userProvider = context.read<UserProvider>();
    final postAuthorId = post['author_id']?.toString() ?? '';
    return postAuthorId == userProvider.userId;
  }

  // 🎯 ФИЛЬТРАЦИЯ ПО КАТЕГОРИЯМ - ОБНОВЛЕННАЯ
  List<dynamic> _getFilteredNews(List<dynamic> allNews) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId;

    switch (_currentCategoryIndex) {
      case 0: // Лента - все посты
        return allNews;

      case 1: // Репосты - посты, которые пользователь репостнул
        return allNews.where((post) {
          final safePost = _ensureStringMap(post);
          return safePost['isReposted'] == true;
        }).toList();

      case 2: // Подписки - посты от авторов, на которых подписан пользователь
        return allNews.where((post) {
          final safePost = _ensureStringMap(post);
          return safePost['isFollowing'] == true;
        }).toList();

      case 3: // Избранное - посты, добавленные в закладки
        return allNews.where((post) {
          final safePost = _ensureStringMap(post);
          return safePost['isBookmarked'] == true;
        }).toList();

      default:
        return allNews;
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E57C2)),
          ),
          SizedBox(height: 16),
          Text(
            'Загрузка новостей...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 ИНДИКАТОР ЗАГРУЗКИ ДОПОЛНИТЕЛЬНЫХ НОВОСТЕЙ
  Widget _buildLoadMoreIndicator(NewsProvider newsProvider) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            if (newsProvider.isLoadingMore)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E57C2)),
              ),
            SizedBox(height: 8),
            Text(
              newsProvider.isLoadingMore ? 'Загружаем еще новости...' : 'Больше новостей нет',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final categoryName = _categories[_currentCategoryIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getCategoryIcon(categoryName), size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            _getEmptyStateTitle(categoryName),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 🆕 УБИРАЕМ КНОПКУ ИЗ ПУСТОГО СОСТОЯНИЯ, Т.К. ЕСТЬ FAB
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Лента':
        return Icons.article_rounded;
      case 'Репосты':
        return Icons.repeat_rounded;
      case 'Подписки':
        return Icons.people_alt_rounded;
      case 'Избранное':
        return Icons.bookmark_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  String _getEmptyStateTitle(String category) {
    switch (category) {
      case 'Лента':
        return 'Пока нет новостей';
      case 'Репосты':
        return 'Нет репостов';
      case 'Подписки':
        return 'Нет постов от подписок';
      case 'Избранное':
        return 'Нет избранных постов';
      default:
        return 'Нет данных';
    }
  }

  String _getEmptyStateMessage(String category) {
    switch (category) {
      case 'Лента':
        return 'Будьте первым, кто поделится новостью с сообществом!';
      case 'Репосты':
        return 'Репостите интересные посты, чтобы они появились здесь';
      case 'Подписки':
        return 'Подпишитесь на интересных авторов, чтобы видеть их посты здесь';
      case 'Избранное':
        return 'Добавляйте посты в избранное, чтобы вернуться к ним позже';
      default:
        return 'Нет данных для отображения';
    }
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: Colors.orange),
          SizedBox(height: 20),
          Text(
            'Ошибка загрузки',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<NewsProvider>().loadNews(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7E57C2),
              foregroundColor: Colors.white,
            ),
            child: Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  // 🎯 ОТДЕЛЬНЫЙ ВИДЖЕТ ДЛЯ КАТЕГОРИЙ - ТЕПЕРЬ В СКРОЛЛЕ
  // 🎯 АЛЬТЕРНАТИВНЫЙ ВАРИАНТ - СУПЕР КОМПАКТНЫЙ
  Widget _buildCategoriesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_categories.length, (index) {
          final isSelected = _currentCategoryIndex == index;
          final categoryColor = _categoryColors[index];

          return Expanded(
            child: Container(
              margin: EdgeInsets.all(4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentCategoryIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? categoryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? categoryColor : Colors.grey[300]!,
                      width: isSelected ? 0 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcons[index],
                        size: 16,
                        color: isSelected ? Colors.white : categoryColor,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _categories[index],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNewsList(NewsProvider newsProvider) {
    final userProvider = context.read<UserProvider>();
    final filteredNews = _getFilteredNews(newsProvider.news);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        // 🆕 БЕСКОНЕЧНЫЙ СКРОЛЛ
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent &&
            newsProvider.hasMoreNews &&
            !newsProvider.isLoadingMore) {
          print('🔄 Reached bottom, loading more news...');
          newsProvider.loadMoreNews();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => newsProvider.refreshNews(),
        backgroundColor: Colors.white,
        color: Color(0xFF7E57C2),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 🆕 ИНДИКАТОР СТАТУСА СЕРВЕРА
            if (!newsProvider.serverAvailable)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border(bottom: BorderSide(color: Colors.orange)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Автономный режим. Данные могут быть неактуальны.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 🆕 ИНДИКАТОР ОШИБКИ
            if (newsProvider.errorMessage != null)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border(bottom: BorderSide(color: Colors.orange)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          newsProvider.errorMessage!,
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => newsProvider.clearError(),
                        icon: Icon(Icons.close_rounded, size: 16),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

            // 🎯 КАТЕГОРИИ ТЕПЕРЬ В СКРОЛЛЕ
            SliverToBoxAdapter(
              child: _buildCategoriesSection(),
            ),

            // 🎯 СПИСОК НОВОСТЕЙ
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // 🆕 ИНДИКАТОР ЗАГРУЗКИ В КОНЦЕ СПИСКА
                  if (index == filteredNews.length) {
                    return _buildLoadMoreIndicator(newsProvider);
                  }

                  final post = filteredNews[index];
                  // Безопасное преобразование данных
                  final safePost = _ensureStringMap(post);
                  final postId = safePost['id']?.toString() ?? '';
                  final isCurrentUserAuthor = _isCurrentUserAuthor(safePost);

                  return FixedNewsCard(
                    key: ValueKey('news-$postId-$index-$_currentCategoryIndex'),
                    news: safePost,
                    onLike: () => _handleLike(postId),
                    onBookmark: () => _handleBookmark(postId),
                    onRepost: () => _handleRepost(postId),
                    onComment: (text) => _handleComment(postId, text),
                    // 🎯 КНОПКА ПОДПИСКИ ТОЛЬКО ДЛЯ ЧУЖИХ ПОСТОВ
                    onFollow: isCurrentUserAuthor ? null : () => _handleFollow(safePost['author_id']?.toString() ?? ''),
                    // 🎯 РЕДАКТИРОВАНИЕ И УДАЛЕНИЕ ТОЛЬКО ДЛЯ СВОИХ ПОСТОВ
                    onEdit: isCurrentUserAuthor ? (updateData) => _handleEdit(postId, updateData) : null,
                    onDelete: isCurrentUserAuthor ? () => _handleDelete(postId) : null,
                    onShare: () => _handleShare(postId),
                    formatDate: _formatDate,
                    getTimeAgo: _getTimeAgo,
                    scrollController: _scrollController,
                    onLogout: widget.onLogout,
                  );
                },
                childCount: filteredNews.length + (newsProvider.hasMoreNews ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 ОБРАБОТЧИКИ РЕДАКТИРОВАНИЯ И УДАЛЕНИЯ
  Future<void> _handleEdit(String postId, Map<String, dynamic> updateData) async {
    print('✏️ Редактирование поста: $postId с данными: $updateData');

    try {
      final snackBar = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 10),
              Text('Обновляем пост...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 5),
        ),
      );

      final newsProvider = context.read<NewsProvider>();
      await newsProvider.updateNews(postId, updateData);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пост успешно обновлен!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при редактировании: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(String postId) async {
    print('🗑️ Удаление поста: $postId');

    try {
      final snackBar = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 10),
              Text('Удаляем пост...'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );

      final newsProvider = context.read<NewsProvider>();
      await newsProvider.deleteNews(postId);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пост успешно удален!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildScrollToTopButton() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final showButton = _scrollController.hasClients &&
            _scrollController.offset > 200;

        return AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: showButton ? 1.0 : 0.0,
          child: Visibility(
            visible: showButton,
            child: FloatingActionButton.small(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: Color(0xFF7E57C2),
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward_rounded),
              heroTag: 'scroll_to_top',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Новости',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        actions: [
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              return Row(
                children: [
                  // 🆕 ИНДИКАТОР СТАТУСА СЕРВЕРА В APP BAR
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: newsProvider.serverAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          newsProvider.serverAvailable
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_off_rounded,
                          size: 16,
                          color: newsProvider.serverAvailable ? Colors.green : Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text(
                          newsProvider.serverAvailable ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: newsProvider.serverAvailable ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: newsProvider.refreshNews,
                    icon: Icon(Icons.refresh_rounded),
                    tooltip: 'Обновить',
                    color: Color(0xFF7E57C2),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          final filteredNews = _getFilteredNews(newsProvider.news);

          if (newsProvider.isLoading && filteredNews.isEmpty) {
            return _buildLoadingIndicator();
          } else if (newsProvider.errorMessage != null && filteredNews.isEmpty) {
            return _buildErrorState(newsProvider.errorMessage!);
          } else if (filteredNews.isEmpty) {
            return Column(
              children: [
                // 🎯 КАТЕГОРИИ ДАЖЕ ПРИ ПУСТОМ СОСТОЯНИИ
                _buildCategoriesSection(),
                Expanded(
                  child: _buildEmptyState(_getEmptyStateMessage(_categories[_currentCategoryIndex])),
                ),
              ],
            );
          } else {
            return _buildNewsList(newsProvider);
          }
        },
      ),
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildScrollToTopButton(),
              SizedBox(height: 16),
              FloatingActionButton(
                onPressed: userProvider.isLoggedIn ? _showCreatePostDialog : null,
                backgroundColor: userProvider.isLoggedIn ? Color(0xFF7E57C2) : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 4,
                tooltip: userProvider.isLoggedIn ? 'Создать пост' : 'Войдите для создания поста',
                child: Icon(Icons.add_rounded),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }
}

// 🎯 НОВЫЙ КЛАСС ДЛЯ ДИАЛОГА СОЗДАНИЯ ПОСТА
class _CreatePostDialog extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController hashtagsController;
  final bool isCreatingPost;
  final VoidCallback onCreatePost;
  final VoidCallback onClearForm;
  final UserProvider userProvider;

  const _CreatePostDialog({
    required this.titleController,
    required this.descriptionController,
    required this.hashtagsController,
    required this.isCreatingPost,
    required this.onCreatePost,
    required this.onClearForm,
    required this.userProvider,
  });

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth * 0.95,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎯 ЗАГОЛОВОК С ГРАДИЕНТОМ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF667eea)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.create_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Создать пост',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🎯 ИНФОРМАЦИЯ О ПОЛЬЗОВАТЕЛЕ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF7E57C2),
                    child: Text(
                      widget.userProvider.userName.isNotEmpty
                          ? widget.userProvider.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userProvider.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Создать новый пост',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🎯 СОДЕРЖИМОЕ С ВОЗМОЖНОСТЬЮ ПРОКРУТКИ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎯 СТАТУС ВАЛИДАЦИИ
                    _buildValidationStatus(),
                    const SizedBox(height: 16),

                    // 🎯 ПОЛЕ ЗАГОЛОВКА (75 символов) - ТЕПЕРЬ НЕОБЯЗАТЕЛЬНОЕ
                    TextField(
                      controller: widget.titleController,
                      decoration: InputDecoration(
                        labelText: 'Заголовок', // 🆕 БЕЗ ЗВЕЗДОЧКИ
                        hintText: 'Введите заголовок поста (необязательно)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.title_rounded, color: Color(0xFF7E57C2), size: 20),
                        ),
                        suffixIcon: _buildCharCounter(widget.titleController, 75),
                        counterText: '',
                      ),
                      maxLines: 2,
                      maxLength: 75,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // 🎯 ПОЛЕ ОПИСАНИЯ (435 символов) - ТЕПЕРЬ ЕДИНСТВЕННОЕ ОБЯЗАТЕЛЬНОЕ
                    TextField(
                      controller: widget.descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Описание*', // 🆕 СО ЗВЕЗДОЧКОЙ
                        hintText: 'Расскажите о вашем посте...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.description_rounded, color: Color(0xFF7E57C2), size: 20),
                        ),
                        suffixIcon: _buildCharCounter(widget.descriptionController, 435),
                        counterText: '',
                      ),
                      maxLines: isSmallScreen ? 3 : 4,
                      maxLength: 435,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // 🎯 ПОЛЕ ХЕШТЕГОВ (60 символов)
                    TextField(
                      controller: widget.hashtagsController,
                      decoration: InputDecoration(
                        labelText: 'Хештеги',
                        hintText: 'технологии flutter программирование...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tag_rounded, color: Color(0xFF7E57C2), size: 20),
                        ),
                        suffixIcon: _buildCharCounter(widget.hashtagsController, 60),
                        counterText: '',
                      ),
                      maxLines: 1,
                      maxLength: 60,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // 🎯 ПОДСКАЗКА ДЛЯ ХЕШТЕГОВ
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Вводите хештеги через пробел',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Пример: технологии flutter программирование',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🎯 КНОПКИ ДЕЙСТВИЙ - ЗАЩИЩЕННЫЕ ОТ ПЕРЕПОЛНЕНИЯ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onClearForm();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSave() && !widget.isCreatingPost ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF7E57C2).withOpacity(0.3),
                      ),
                      child: widget.isCreatingPost
                          ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Опубликовать',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ

  Widget _buildCharCounter(TextEditingController controller, int maxLength) {
    final currentLength = controller.text.length;
    final isOverLimit = currentLength > maxLength;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        '$currentLength/$maxLength',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isOverLimit ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildValidationStatus() {
    final titleLength = widget.titleController.text.length;
    final contentLength = widget.descriptionController.text.length;
    final hashtagsLength = widget.hashtagsController.text.length;

    final hasTitleError = titleLength > 0 && (titleLength < 5 || titleLength > 75);
    final hasContentError = contentLength == 0 || contentLength < 4 || contentLength > 435;
    final hasHashtagsError = hashtagsLength > 60;

    if (!hasTitleError && !hasContentError && !hasHashtagsError) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Все поля заполнены корректно',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'Проверьте заполнение полей:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (widget.descriptionController.text.isEmpty)
            Text(
              '• Описание обязательно для заполнения',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (widget.descriptionController.text.isNotEmpty && widget.descriptionController.text.length < 4)
            Text(
              '• Описание должно содержать минимум 4 символа',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (contentLength > 435)
            Text(
              '• Описание слишком длинное (${contentLength}/435)',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (titleLength > 0 && titleLength < 5)
            Text(
              '• Заголовок должен содержать минимум 5 символов',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (titleLength > 75)
            Text(
              '• Заголовок слишком длинный (${titleLength}/75)',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (hashtagsLength > 60)
            Text(
              '• Хештеги слишком длинные (${hashtagsLength}/60)',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
        ],
      ),
    );
  }

  bool _canSave() {
    final title = widget.titleController.text.trim();
    final content = widget.descriptionController.text.trim();
    final hashtags = widget.hashtagsController.text;

    // 🆕 ТЕПЕРЬ ТОЛЬКО ОПИСАНИЕ ОБЯЗАТЕЛЬНОЕ (минимум 4 символа)
    final isContentValid = content.isNotEmpty && content.length >= 4 && content.length <= 435;

    // 🆕 ЗАГОЛОВОК НЕОБЯЗАТЕЛЬНЫЙ, НО ЕСЛИ ЗАПОЛНЕН - ПРОВЕРЯЕМ
    final isTitleValid = title.isEmpty || (title.length >= 5 && title.length <= 75);

    final isHashtagsValid = hashtags.length <= 60;

    return isContentValid && isTitleValid && isHashtagsValid;
  }

  void _saveChanges() {
    Navigator.pop(context);
    widget.onCreatePost();
  }
}