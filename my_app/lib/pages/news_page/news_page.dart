import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers/news_provider.dart';
import '../../../services/api_service.dart';
import 'news_card.dart';
import 'utils.dart';
import 'shimmer_loading.dart';
import 'animated_fab.dart';
import 'search_delegate.dart';

class NewsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const NewsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _secondaryColor = const Color(0xFFFF6B35);
  final Color _backgroundColor = const Color(0xFFF5F9FF);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _secondaryTextColor = const Color(0xFF666666);

  int _currentFilter = 0;
  final List<String> _filterOptions = ['Все новости', 'Мои новости', 'Популярные', 'Избранное'];
  final List<IconData> _filterIcons = [Icons.all_inclusive, Icons.person, Icons.trending_up, Icons.bookmark];

  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNews(showLoading: true);
      Provider.of<NewsProvider>(context, listen: false).loadUserTags();
    });
  }

  Future<void> _loadNews({bool showLoading = false}) async {
    try {
      if (showLoading) {
        Provider.of<NewsProvider>(context, listen: false).setLoading(true);
      }
      await Provider.of<NewsProvider>(context, listen: false).loadNews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (showLoading) {
        Provider.of<NewsProvider>(context, listen: false).setLoading(false);
      }
    }
  }

  Future<void> _onRefresh() async {
    try {
      await Provider.of<NewsProvider>(context, listen: false).loadNews();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onLoading() async {
    _refreshController.loadComplete();
  }

  // ========== ОСНОВНЫЕ МЕТОДЫ ВЗАИМОДЕЙСТВИЯ С НОВОСТЯМИ ==========

  Future<void> _toggleLike(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index] as Map<dynamic, dynamic>);
    final bool isCurrentlyLiked = news['isLiked'] ?? false;
    final int currentLikes = news['likes'] ?? 0;

    try {
      // Оптимистичное обновление UI
      newsProvider.updateNewsLikeStatus(index, !isCurrentlyLiked, isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1);

     // await ApiService.toggleLikeNews(news['id'].toString(), !isCurrentlyLiked);
    } catch (e) {
      // Откатываем изменения при ошибке
      newsProvider.updateNewsLikeStatus(index, isCurrentlyLiked, currentLikes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось поставить лайк'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleBookmark(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index] as Map<dynamic, dynamic>);
    final bool isCurrentlyBookmarked = news['isBookmarked'] ?? false;

    try {
      // Оптимистичное обновление UI
      newsProvider.updateNewsBookmarkStatus(index, !isCurrentlyBookmarked);

   //   await ApiService.toggleBookmarkNews(news['id'].toString(), !isCurrentlyBookmarked);
    } catch (e) {
      // Откатываем изменения при ошибке
      newsProvider.updateNewsBookmarkStatus(index, isCurrentlyBookmarked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось добавить в закладки'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addComment(int index, String commentText) async {
    if (commentText.trim().isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index] as Map<dynamic, dynamic>);

    try {
      final newComment = {
        'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
        'author': widget.userName,
        'text': commentText.trim(),
        'time': 'Только что',
      };

      // Оптимистичное обновление
      newsProvider.addCommentToNews(index, newComment);

  //    await ApiService.addComment(news['id'].toString(), {
    //    'text': commentText.trim(),
      //  'author': widget.userName,
     // });
    } catch (e) {
      // Удаляем комментарий при ошибке
      newsProvider.removeCommentFromNews(index, 'comment-${DateTime.now().millisecondsSinceEpoch}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось добавить комментарий'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addNews(String title, String description, String hashtags) async {
    if (title.isEmpty || description.isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    // Правильно форматируем хештеги
    final hashtagsArray = hashtags.split(' ')
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.startsWith('#') ? tag : '#$tag')
        .toList();

    try {
      final newNews = await ApiService.createNews({
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
      });

      // Используем данные с сервера
      newsProvider.addNews({
        ...newNews,
        'author_name': widget.userName,
        'isLiked': false,
        'isBookmarked': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Новость успешно создана!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Ошибка создания новости: $e');

      // Fallback: создаем новость локально
      newsProvider.addNews({
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
        'author_name': widget.userName,
        'likes': 0,
        'comments': [],
        'user_tags': {'tag1': 'Новый тег'},
        'created_at': DateTime.now().toIso8601String(),
        'isLiked': false,
        'isBookmarked': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Создано локально: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }


  Future<void> _editNews(int index, String title, String description, String hashtags) async {
    if (title.isEmpty || description.isEmpty) return;

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index] as Map<dynamic, dynamic>);
    final hashtagsArray = hashtags.split(' ').where((tag) => tag.isNotEmpty).toList();

    try {
      await ApiService.updateNews(news['id'].toString(), {
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
      });

      newsProvider.updateNews(index, {
        ...news,
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
      });
    } catch (e) {
      // Fallback: обновляем локально
      newsProvider.updateNews(index, {
        ...news,
        'title': title,
        'description': description,
        'hashtags': hashtagsArray,
      });
    }
  }

  Future<void> _deleteNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index] as Map<dynamic, dynamic>);

    try {
      await ApiService.deleteNews(news['id'].toString());
      newsProvider.removeNews(index);
    } catch (e) {
      newsProvider.removeNews(index);
    }
  }

  void _editUserTag(int newsIndex, String tagId, String newTagName, Color color) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    try {
      newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
    } catch (e) {
      newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
    }
  }

  Future<void> _shareNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index] as Map<dynamic, dynamic>);

    final title = news['title'] ?? '';
    final description = news['description'] ?? '';
    final url = 'https://example.com/news/${news['id']}';

    await Share.share('$title\n\n$description\n\n$url');
  }

  // ========== ДИАЛОГИ ==========
  void _showAddNewsDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final hashtagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _cardColor,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Создать новость',
                style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Заголовок * (до 20 символов)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '${titleController.text.length}/20',
                      ),
                      maxLength: 20,
                      onChanged: (value) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Описание * (до 240 символов)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '${descriptionController.text.length}/240',
                      ),
                      maxLength: 240,
                      onChanged: (value) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hashtagsController,
                      decoration: InputDecoration(
                        labelText: 'Хештеги (через пробел)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        hintText: 'спорт новости технологии',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: _secondaryTextColor)),
                ),
                ElevatedButton(
                  onPressed: titleController.text.isNotEmpty && descriptionController.text.isNotEmpty
                      ? () {
                    _addNews(
                      titleController.text,
                      descriptionController.text,
                      hashtagsController.text,
                    );
                    Navigator.pop(context);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Создать'),
                ),
              ],
            );
          }
      ),
    );
  }


  void _showEditNewsDialog(int index) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = Map<String, dynamic>.from(newsProvider.news[index] as Map<dynamic, dynamic>);

    final titleController = TextEditingController(text: news['title'] ?? '');
    final descriptionController = TextEditingController(text: news['description'] ?? '');
    final hashtagsController = TextEditingController(
        text: (news['hashtags'] is List ? (news['hashtags'] as List).join(' ') : '')
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _cardColor,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Редактировать новость',
                style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Заголовок (до 20 символов)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '${titleController.text.length}/20',
                      ),
                      maxLength: 20,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      onChanged: (value) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Описание (до 240 символов)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '${descriptionController.text.length}/240',
                        alignLabelWithHint: true,
                      ),
                      maxLength: 240,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      onChanged: (value) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hashtagsController,
                      decoration: InputDecoration(
                        labelText: 'Хештеги (через пробел, например: #спорт #новости)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: _secondaryTextColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                      _editNews(
                        index,
                        titleController.text,
                        descriptionController.text,
                        hashtagsController.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            );
          }
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Удалить новость?',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Вы уверены, что хотите удалить эту новость? Это действие нельзя отменить.',
          style: TextStyle(color: _secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: _secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteNews(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  // ========== ПРОФИЛЬ И ШАРИНГ ==========

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: _primaryColor,
              child: Text(
                widget.userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.userName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            Text(
              widget.userEmail,
              style: TextStyle(
                fontSize: 14,
                color: _secondaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(Icons.settings, 'Настройки'),
            _buildMenuButton(Icons.help, 'Помощь'),
            _buildMenuButton(Icons.info, 'О приложении'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor),
      title: Text(text, style: TextStyle(color: _textColor)),
      onTap: () => Navigator.pop(context),
    );
  }

  // ========== ПОИСК И ФИЛЬТРАЦИЯ ==========

  void _startSearch() {
    showSearch(
      context: context,
      delegate: NewsSearchDelegate(
        news: Provider.of<NewsProvider>(context, listen: false).news,
        searchHint: 'Поиск по новостям...',
      ),
    ).then((value) {
      setState(() {
        _isSearching = false;
        _searchQuery = value ?? '';
      });
    });
  }

  List<dynamic> _getFilteredNews(List<dynamic> news) {
    List<dynamic> filtered = news;

    // Применяем текстовый поиск
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final newsItem = Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
        final title = newsItem['title']?.toString().toLowerCase() ?? '';
        final description = newsItem['description']?.toString().toLowerCase() ?? '';
        final hashtags = (newsItem['hashtags'] is List
            ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
            : '');

        return title.contains(_searchQuery.toLowerCase()) ||
            description.contains(_searchQuery.toLowerCase()) ||
            hashtags.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Применяем выбранный фильтр
    switch (_currentFilter) {
      case 1: // Мои новости
        return filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
          return newsItem['author_name'] == widget.userName;
        }).toList();
      case 2: // Популярные
        return filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
          return (newsItem['likes'] ?? 0) > 5;
        }).toList();
      case 3: // Избранное
        return filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
          return newsItem['isBookmarked'] == true;
        }).toList();
      default: // Все новости
        return filtered;
    }
  }

  // ========== ВИДЖЕТЫ ИНТЕРФЕЙса ==========

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor, _secondaryColor],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.userName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_filterOptions.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(_filterOptions[index]),
                avatar: Icon(_filterIcons[index], size: 18),
                selected: _currentFilter == index,
                onSelected: (selected) => setState(() => _currentFilter = selected ? index : _currentFilter),
                selectedColor: _primaryColor,
                labelStyle: TextStyle(
                  color: _currentFilter == index ? Colors.white : _textColor,
                ),
                backgroundColor: _cardColor,
                showCheckmark: false,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: _currentFilter == index ? _primaryColor : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => const NewsCardShimmer(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: _primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Лента пустая',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Будьте первым, кто поделится интересной новостью!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddNewsDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Создать первую новость'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: _secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить фильтр или создать новую новость',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryTextColor,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => setState(() => _searchQuery = ''),
                child: const Text('Очистить поиск'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final filteredNews = _getFilteredNews(newsProvider.news);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() => _searchQuery = value),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новости',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: _textColor,
              ),
            ),
            Text(
              widget.userEmail,
              style: TextStyle(
                fontSize: 12,
                color: _secondaryTextColor,
              ),
            ),
          ],
        ),
        backgroundColor: _cardColor,
        elevation: 2,
        centerTitle: false,
        iconTheme: IconThemeData(color: _primaryColor),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, size: 24),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
            color: _primaryColor,
          ),
          if (!_isSearching) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
            const SizedBox(width: 12),
          ]
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const ClassicHeader(
          completeText: 'Обновлено',
          refreshingText: 'Обновление...',
          releaseText: 'Отпустите для обновления',
          idleText: 'Потяните для обновления',
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: Column(
          children: [
            if (newsProvider.news.isNotEmpty && !_isSearching) _buildFilterChips(),
            Expanded(
              child: newsProvider.isLoading && newsProvider.news.isEmpty
                  ? _buildLoadingState()
                  : newsProvider.news.isEmpty
                  ? _buildEmptyState()
                  : filteredNews.isEmpty
                  ? _buildNoResultsState()
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: filteredNews.length,
                itemBuilder: (context, index) {
                  final news = Map<String, dynamic>.from(filteredNews[index] as Map<dynamic, dynamic>);
                  final originalIndex = newsProvider.news.indexOf(filteredNews[index]);

                  return NewsCard(
                    key: ValueKey(news['id'] ?? index),
                    news: news,
                    userName: widget.userName,
                    onLike: () => _toggleLike(originalIndex),
                    onBookmark: () => _toggleBookmark(originalIndex),
                    onComment: (comment) => _addComment(originalIndex, comment),
                    onEdit: () => _showEditNewsDialog(originalIndex),
                    onDelete: () => _showDeleteConfirmationDialog(originalIndex),
                    onShare: () => _shareNews(originalIndex),
                    onTagEdit: (tagId, newTagName, color) =>
                        _editUserTag(originalIndex, tagId, newTagName, color),
                    formatDate: formatDate,
                    getTimeAgo: getTimeAgo,
                    primaryColor: _primaryColor,
                    backgroundColor: _backgroundColor,
                    cardColor: _cardColor,
                    textColor: _textColor,
                    secondaryTextColor: _secondaryTextColor,
                    scrollController: _scrollController,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: _showAddNewsDialog,
        tooltip: 'Создать новость',
        icon: Icons.add,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        scrollController: _scrollController,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}