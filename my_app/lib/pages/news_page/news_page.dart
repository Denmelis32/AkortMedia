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

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCreatingPost = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
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

    // Загружаем новости
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

  // 🆕 УЛУЧШЕННЫЙ МЕТОД ДЛЯ ОБРАБОТКИ ХЕШТЕГОВ
  List<String> _parseHashtags(String hashtagsText) {
    if (hashtagsText.trim().isEmpty) return [];

    return hashtagsText
        .split(',')
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
    if (_titleController.text.isEmpty) return;

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

    setState(() => _isCreatingPost = true);

    try {
      // 🆕 ПАРСИМ ХЕШТЕГИ
      final hashtags = _parseHashtags(_hashtagsController.text);

      // Используем данные из UserProvider
      final newsData = {
        'title': _titleController.text.trim(),
        'content': _descriptionController.text.trim(), // ✅ используем content
        'hashtags': hashtags,
      };

      print('🎯 Creating post as: ${userProvider.userName} (ID: ${userProvider.userId})');
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
    final newsProvider = context.read<NewsProvider>();
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
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.create_rounded, color: Color(0xFF7E57C2)),
            SizedBox(width: 8),
            Text('Создать пост'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🆕 ИНФОРМАЦИЯ О ПОЛЬЗОВАТЕЛЕ
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF7E57C2),
                      child: Text(
                        userProvider.userName.isNotEmpty
                            ? userProvider.userName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'ID: ${userProvider.userId}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Создать пост',
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
              SizedBox(height: 12),

              // 🆕 ИНДИКАТОР СТАТУСА СЕРВЕРА
              if (!newsProvider.serverAvailable)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Автономный режим. Посты сохранятся локально.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 12),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Заголовок*',
                  hintText: 'Введите заголовок поста',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title_rounded),
                  counterText: '${_titleController.text.length}/200',
                ),
                maxLines: 2,
                maxLength: 200,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  hintText: 'Введите описание поста',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_rounded),
                  counterText: '${_descriptionController.text.length}/2000',
                ),
                maxLines: 4,
                maxLength: 2000,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _hashtagsController,
                decoration: InputDecoration(
                  labelText: 'Хештеги',
                  hintText: 'через запятую: новости, спорт, технологии',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                maxLines: 1,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Вводите хештеги через запятую. Пример: "футбол, спорт, лига"',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: _isCreatingPost ? null : () {
              final title = _titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Заголовок не может быть пустым'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (title.length < 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Заголовок должен содержать минимум 5 символов'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              _createNews();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7E57C2),
              foregroundColor: Colors.white,
            ),
            child: _isCreatingPost
                ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text('Опубликовать'),
          ),
        ],
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

  // 🎯 ИСПРАВЛЕННЫЙ МЕТОД ДЛЯ КОММЕНТАРИЕВ
  void _handleComment(String postId, String text) {
    print('🎯 HANDLE COMMENT: $postId - "$text"');
    final newsProvider = context.read<NewsProvider>();
    newsProvider.addComment(postId, text);
  }

  void _handleFollow(String authorId) {
    print('📢 Подписка на автора: $authorId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Подписка оформлена!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleShare(String postId) {
    print('📤 Шаринг поста: $postId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на пост скопирована!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_rounded, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'Пока нет новостей',
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
              'Будьте первым, кто поделится новостью с сообществом!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return ElevatedButton(
                onPressed: userProvider.isLoggedIn ? _showCreatePostDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7E57C2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  userProvider.isLoggedIn
                      ? 'Создать первый пост'
                      : 'Войдите для создания поста',
                  style: TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
    );
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

  // 🎯 ОСНОВНОЙ МЕТОД ДЛЯ ОТОБРАЖЕНИЯ КАРТОЧЕК
  Widget _buildNewsList(NewsProvider newsProvider) {
    return Column(
      children: [
        // 🆕 ИНДИКАТОР СТАТУСА СЕРВЕРА
        if (!newsProvider.serverAvailable)
          Container(
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
                  ),
                ),
              ],
            ),
          ),

        // 🆕 ИНДИКАТОР ОШИБКИ
        if (newsProvider.errorMessage != null)
          Container(
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

        Expanded(
          child: RefreshIndicator(
            onRefresh: () => newsProvider.refreshNews(),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 80),
              itemCount: newsProvider.news.length,
              itemBuilder: (context, index) {
                final post = newsProvider.news[index];
                // Безопасное преобразование данных
                final safePost = _ensureStringMap(post);
                final postId = safePost['id']?.toString() ?? '';

                return FixedNewsCard(
                  key: ValueKey('news-$postId-$index'),
                  news: safePost,
                  onLike: () => _handleLike(postId),
                  onBookmark: () => _handleBookmark(postId),
                  onRepost: () => _handleRepost(postId),
                  onComment: (text) => _handleComment(postId, text), // ✅ ИСПРАВЛЕННЫЙ ВЫЗОВ
                  onFollow: () => _handleFollow(safePost['author_id']?.toString() ?? ''),
                  onShare: () => _handleShare(postId),
                  formatDate: _formatDate,
                  getTimeAgo: _getTimeAgo,
                  scrollController: _scrollController,
                  onLogout: widget.onLogout,
                );
              },
            ),
          ),
        ),
      ],
    );
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
          'Лента новостей',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              return Row(
                children: [
                  // 🆕 ИНДИКАТОР СТАТУСА СЕРВЕРА В APP BAR
                  Icon(
                    newsProvider.serverAvailable
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                    color: newsProvider.serverAvailable ? Colors.green : Colors.orange,
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
          if (newsProvider.isLoading) {
            return _buildLoadingIndicator();
          } else if (newsProvider.errorMessage != null && newsProvider.news.isEmpty) {
            return _buildErrorState(newsProvider.errorMessage!);
          } else if (newsProvider.news.isEmpty) {
            return _buildEmptyState();
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
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }
}