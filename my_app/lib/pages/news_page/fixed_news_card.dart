import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/news_providers/news_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class FixedNewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onRepost;
  final Function(String)? onComment;
  final VoidCallback? onFollow;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final Function(String, String, Color)? onTagEdit;
  final String Function(String) formatDate;
  final String Function(String) getTimeAgo;
  final ScrollController scrollController;
  final VoidCallback? onLogout;

  const FixedNewsCard({
    super.key,
    required this.news,
    this.onLike,
    this.onBookmark,
    this.onRepost,
    this.onComment,
    this.onFollow,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onTagEdit,
    required this.formatDate,
    required this.getTimeAgo,
    required this.scrollController,
    this.onLogout,
  });

  @override
  State<FixedNewsCard> createState() => _FixedNewsCardState();
}

class _FixedNewsCardState extends State<FixedNewsCard> with SingleTickerProviderStateMixin {
  // 🎯 КЭШ КОММЕНТАРИЕВ ДЛЯ ИЗБЕЖАНИЯ ПОВТОРНЫХ ЗАПРОСОВ
  static final Map<String, List<Map<String, dynamic>>> _commentsCache = {};
  static final Map<String, bool> _loadingStates = {};

  // 🎯 СОСТОЯНИЕ ДЛЯ ОТОБРАЖЕНИЯ КОММЕНТАРИЕВ ПОД КАРТОЧКОЙ
  bool _showComments = false;
  String? _currentNewsId;

  // 🎯 АНИМАЦИЯ ДЛЯ ВЫЕЗЖАНИЯ КОММЕНТАРИЕВ
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Инициализация анимации
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 🎯 БЕЗОПАСНОЕ ПРЕОБРАЗОВАНИЕ ТИПОВ
  Map<String, dynamic> _ensureStringMap(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map<dynamic, dynamic>) {
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        result[key.toString()] = _ensureSafeTypes(value);
      });
      return result;
    }
    return <String, dynamic>{};
  }

  dynamic _ensureSafeTypes(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      return _ensureStringMap(value);
    } else if (value is List<dynamic>) {
      return value.map((item) => _ensureSafeTypes(item)).toList();
    }
    return value;
  }

  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }

  int _getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }

  // 🎯 ПОЛУЧЕНИЕ ХЕШТЕГОВ
  List<String> _getHashtags() {
    try {
      final safeNews = _ensureStringMap(widget.news);
      final hashtags = safeNews['hashtags'];

      if (hashtags is List) {
        return hashtags.whereType<String>().where((tag) => tag.isNotEmpty).toList();
      }

      if (hashtags is String && hashtags.isNotEmpty) {
        try {
          if (hashtags.startsWith('[')) {
            final parsed = List<String>.from(json.decode(hashtags));
            return parsed.where((tag) => tag.isNotEmpty).toList();
          } else {
            return hashtags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
          }
        } catch (e) {
          print('❌ Error parsing hashtags: $e');
          return [];
        }
      }

      return [];
    } catch (e) {
      print('❌ Error getting hashtags: $e');
      return [];
    }
  }

  // 🎯 КРАСИВЫЙ ДИАЛОГ ДОБАВЛЕНИЯ КОММЕНТАРИЯ
  void _showAddCommentDialog(BuildContext context, String newsId) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF7E57C2),
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
                      child: const Icon(Icons.chat_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Добавить комментарий',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Контент
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Что вы думаете об этом посте?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Напишите ваш комментарий...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        maxLines: 4,
                        maxLength: 500,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Кнопки
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
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
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty) {
                            Navigator.pop(context);
                            if (widget.onComment != null) {
                              widget.onComment!(text);
                            } else {
                              await _addCommentDirectly(context, newsId, text);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          'Отправить',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // 🎯 ПРЯМОЕ ДОБАВЛЕНИЕ КОММЕНТАРИЯ ЧЕРЕЗ API
  Future<void> _addCommentDirectly(BuildContext context, String newsId, String text) async {
    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userName = userProvider.userName.isNotEmpty ? userProvider.userName : 'Пользователь';

      // Показываем индикатор загрузки
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 12),
              Text('Отправка комментария...'),
            ],
          ),
          backgroundColor: Color(0xFF7E57C2),
          duration: Duration(seconds: 10),
        ),
      );

      // Вызываем API для добавления комментария
      final result = await ApiService.addComment(newsId, text, userName);

      // Скрываем индикатор
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result.containsKey('id')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Комментарий добавлен!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 🎯 ВАЖНО: ОЧИЩАЕМ КЭШ КОММЕНТАРИЕВ ДЛЯ ЭТОГО ПОСТА
        _commentsCache.remove(newsId);
        _loadingStates.remove(newsId);

        // 🎯 ОБНОВЛЯЕМ СЧЕТЧИК КОММЕНТАРИЕВ В ПРОВАЙДЕРЕ
        newsProvider.updatePostCommentsCount(newsId);

        // 🎯 ПРИНУДИТЕЛЬНО ЗАГРУЖАЕМ ОБНОВЛЕННЫЕ КОММЕНТАРИИ
        await _getCommentsFromAPI(newsId, forceRefresh: true);

        // 🎯 ОБНОВЛЯЕМ ОТОБРАЖЕНИЕ КОММЕНТАРИЕВ ЕСЛИ ОНИ ОТКРЫТЫ
        if (_showComments && _currentNewsId == newsId) {
          setState(() {});
        }

      } else {
        throw Exception('Не удалось добавить комментарий');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // 🎯 ПОЛУЧЕНИЕ КОММЕНТАРИЕВ ИЗ API
  Future<List<Map<String, dynamic>>> _getCommentsFromAPI(String newsId, {bool forceRefresh = false}) async {
    try {
      // Проверяем кэш (если не принудительное обновление)
      if (!forceRefresh && _commentsCache.containsKey(newsId)) {
        return _commentsCache[newsId]!;
      }

      print('💬 Loading comments from API for post: $newsId');

      // Устанавливаем состояние загрузки
      _loadingStates[newsId] = true;
      if (mounted) {
        setState(() {});
      }

      final comments = await ApiService.getComments(newsId);

      // 🎯 ПРАВИЛЬНЫЙ ПАРСИНГ КОММЕНТАРИЕВ
      final parsedComments = comments.map((comment) {
        final safeComment = _ensureStringMap(comment);

        return {
          'id': _getStringValue(safeComment['id']),
          'text': _getStringValue(safeComment['text']),
          'author_name': _getStringValue(safeComment['author_name']),
          'timestamp': _getStringValue(safeComment['timestamp'] ?? safeComment['created_at']),
          'created_at': _getStringValue(safeComment['created_at']),
        };
      }).toList();

      // Сохраняем в кэш
      _commentsCache[newsId] = parsedComments;

      // Сбрасываем состояние загрузки
      _loadingStates[newsId] = false;
      if (mounted) {
        setState(() {});
      }

      return parsedComments;
    } catch (e) {
      print('❌ Error loading comments from API: $e');

      // Сбрасываем состояние загрузки
      _loadingStates[newsId] = false;
      if (mounted) {
        setState(() {});
      }

      return [];
    }
  }

  // 🎯 ПЕРЕКЛЮЧЕНИЕ ОТОБРАЖЕНИЯ КОММЕНТАРИЕВ ПОД КАРТОЧКОЙ
  void _toggleComments(String newsId) async {
    if (_showComments && _currentNewsId == newsId) {
      // Закрываем комментарии с анимацией
      await _animationController.reverse();
      setState(() {
        _showComments = false;
        _currentNewsId = null;
      });
    } else {
      // Открываем комментарии
      setState(() {
        _showComments = true;
        _currentNewsId = newsId;
      });

      // Запускаем анимацию
      _animationController.forward();

      // 🎯 ВСЕГДА ЗАГРУЖАЕМ СВЕЖИЕ КОММЕНТАРИИ ПРИ ОТКРЫТИИ
      await _getCommentsFromAPI(newsId, forceRefresh: true);
    }
  }

  // 🎯 КРАСИВЫЙ ВИДЖЕТ ДЛЯ ОТОБРАЖЕНИЯ КОММЕНТАРИЕВ ПОД КАРТОЧКОЙ
  Widget _buildCommentsSection(String newsId, String title) {
    final comments = _commentsCache[newsId] ?? [];
    final isLoading = _loadingStates[newsId] == true;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _heightAnimation.value) * -20),
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E57C2).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF7E57C2).withOpacity(0.1),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Заголовок секции комментариев
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF7E57C2),
                            const Color(0xFF667eea),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Комментарии',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                              onPressed: () => _toggleComments(newsId),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Контент комментариев
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: isLoading
                          ? _buildLoadingIndicator()
                          : comments.isEmpty
                          ? _buildEmptyComments(newsId)
                          : _buildCommentsList(comments, newsId),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF7E57C2)),
          ),
          const SizedBox(height: 12),
          Text(
            'Загрузка комментариев...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments(String newsId) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Пока нет комментариев',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Будьте первым, кто оставит комментарий!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showAddCommentDialog(context, newsId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E57C2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_comment_rounded, size: 18),
                SizedBox(width: 8),
                Text('Добавить комментарий'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<Map<String, dynamic>> comments, String newsId) {
    return Column(
      children: [
        // Список комментариев
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final commentAuthor = _getStringValue(comment['author_name']);
              final commentText = _getStringValue(comment['text']);
              final commentDate = _getStringValue(comment['timestamp'] ?? comment['created_at']);
              final authorAvatar = commentAuthor.isNotEmpty ? commentAuthor[0].toUpperCase() : '?';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Аватар автора
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF667eea), Color(0xFF7E57C2)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7E57C2).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          authorAvatar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Текст комментария
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    commentAuthor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF2D3748),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  widget.getTimeAgo(commentDate),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              commentText.isNotEmpty ? commentText : '[Текст комментария отсутствует]',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Кнопка добавления комментария
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: ElevatedButton(
            onPressed: () => _showAddCommentDialog(context, newsId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E57C2),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_comment_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Добавить комментарий',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🎯 ВИДЖЕТ КНОПКИ ДЕЙСТВИЙ
  Widget _buildActionButton(IconData icon, String count, Color color, VoidCallback onPressed, {bool isComment = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 ПОЛУЧАЕМ АКТУАЛЬНЫЕ ДАННЫЕ ИЗ PROVIDER
    final newsProvider = Provider.of<NewsProvider>(context, listen: true);

    // Находим актуальный пост в провайдере
    final currentPost = newsProvider.news.firstWhere(
          (post) {
        final safePost = _ensureStringMap(post);
        final safeNews = _ensureStringMap(widget.news);
        return safePost['id'] == safeNews['id'];
      },
      orElse: () => widget.news,
    );

    // Безопасное преобразование данных для отображения
    final safeNews = _ensureStringMap(currentPost);
    final newsId = _getStringValue(safeNews['id']);
    final authorName = _getStringValue(safeNews['author_name']);
    final title = _getStringValue(safeNews['title']);
    final content = _getStringValue(safeNews['content']); // 🎯 ИСПРАВЛЕНО: используем content вместо description
    final isRepost = _getBoolValue(safeNews['is_repost']) ?? false;
    final hashtags = _getHashtags();
    final createdAt = _getStringValue(safeNews['created_at']);

    // 🎯 АКТУАЛЬНЫЕ ДАННЫЕ ИЗ PROVIDER
    final isLiked = _getBoolValue(safeNews['isLiked']) ?? false;
    final isBookmarked = _getBoolValue(safeNews['isBookmarked']) ?? false;
    final isReposted = _getBoolValue(safeNews['isReposted']) ?? false;
    final likesCount = _getIntValue(safeNews['likes_count']) ?? _getIntValue(safeNews['likes']) ?? 0;
    final repostsCount = _getIntValue(safeNews['reposts_count']) ?? _getIntValue(safeNews['reposts']) ?? 0;
    final commentsCount = _getIntValue(safeNews['comments_count']) ?? 0;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Шапка с автором
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF667eea), Color(0xFF7E57C2)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7E57C2).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              widget.getTimeAgo(createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRepost)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade100,
                                Colors.green.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.repeat_rounded, size: 14, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Репост',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Заголовок
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Color(0xFF1A202C),
                      ),
                    ),

                  // 🎯 КОНТЕНТ (основной текст поста)
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Хештеги
                  if (hashtags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: hashtags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF7E57C2).withOpacity(0.1),
                                const Color(0xFF667eea).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF7E57C2).withOpacity(0.3)),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: Color(0xFF7E57C2),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Действия
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        likesCount.toString(),
                        isLiked ? Colors.red : Colors.grey[700]!,
                        widget.onLike ?? () {},
                      ),
                      _buildActionButton(
                        Icons.chat_bubble_outline_rounded,
                        commentsCount.toString(),
                        _showComments && _currentNewsId == newsId ? const Color(0xFF7E57C2) : Colors.grey[700]!,
                            () => _toggleComments(newsId),
                        isComment: true,
                      ),
                      _buildActionButton(
                        Icons.repeat_rounded,
                        repostsCount.toString(),
                        isReposted ? Colors.green : Colors.grey[700]!,
                        widget.onRepost ?? () {},
                      ),
                      _buildActionButton(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        '',
                        isBookmarked ? Colors.amber : Colors.grey[700]!,
                        widget.onBookmark ?? () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 🎯 АНИМИРОВАННОЕ ОТОБРАЖЕНИЕ КОММЕНТАРИЕВ ПОД КАРТОЧКОЙ
        if (_showComments && _currentNewsId == newsId)
          _buildCommentsSection(newsId, title),
      ],
    );
  }
}