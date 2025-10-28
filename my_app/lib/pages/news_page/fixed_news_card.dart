import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/news_providers/news_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';

class FixedNewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onRepost;
  final Function(String)? onComment;
  final VoidCallback? onFollow;

  // 🆕 ОБНОВЛЕННЫЕ ТИПЫ
  final Future<void> Function(Map<String, dynamic>)? onEdit;
  final Future<void> Function()? onDelete;
  final VoidCallback? onShare;
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
    required this.formatDate,
    required this.getTimeAgo,
    required this.scrollController,
    this.onLogout,
  });

  @override
  State<FixedNewsCard> createState() => _FixedNewsCardState();
}

class _FixedNewsCardState extends State<FixedNewsCard>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  // 🎯 КОНСТАНТЫ ДЛЯ ОПТИМИЗАЦИИ
  static const int _MAX_CACHE_SIZE = 50;
  static const int _COMMENT_PREVIEW_LENGTH = 150;
  static const int _CONTENT_PREVIEW_LENGTH = 250;

  // 🎯 ОПТИМИЗИРОВАННЫЙ КЭШ КОММЕНТАРИЕВ (LRU)
  static final Map<String, List<Map<String, dynamic>>> _commentsCache = {};
  static final List<String> _cacheAccessOrder = [];
  static final Map<String, bool> _loadingStates = {};

  // 🎯 СОСТОЯНИЕ КОММЕНТАРИЕВ
  bool _showComments = false;
  String? _currentNewsId;
  bool _isFollowing = false;
  bool _isWritingComment = false;
  bool _isExpanded = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  // 🎯 ОПТИМИЗИРОВАННАЯ АНИМАЦИЯ
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _commentFocusNode.addListener(_onCommentFocusChange);
    _commentController.addListener(_onCommentTextChange);

    _isFollowing = _getBoolValue(widget.news['isFollowing']) ?? false;
  }

  void _onCommentFocusChange() {
    if (!_commentFocusNode.hasFocus && _commentController.text.isEmpty) {
      setState(() {
        _isWritingComment = false;
      });
    }
  }

  void _onCommentTextChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    _commentFocusNode.removeListener(_onCommentFocusChange);
    _commentFocusNode.dispose();
    super.dispose();
  }

  // 🎯 ОПТИМИЗИРОВАННЫЕ ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  bool _isCurrentUserAuthor() {
    final userProvider = context.read<UserProvider>();
    final safeNews = _ensureStringMap(widget.news);
    final postAuthorId = safeNews['author_id']?.toString() ?? '';
    return postAuthorId == userProvider.userId;
  }

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

  // 🎯 ОПТИМИЗИРОВАННЫЕ СТРОКОВЫЕ ОПЕРАЦИИ
  String _truncateText(String text, {int maxLength = _CONTENT_PREVIEW_LENGTH}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _truncateAuthorName(String name, {int maxLength = 20}) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  // 🎯 ОПТИМИЗИРОВАННОЕ ПОЛУЧЕНИЕ ХЕШТЕГОВ
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
          return [hashtags];
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // 🎯 ОПТИМИЗИРОВАННОЕ УПРАВЛЕНИЕ КЭШЕМ КОММЕНТАРИЕВ
  void _updateCacheAccess(String newsId) {
    _cacheAccessOrder.remove(newsId);
    _cacheAccessOrder.add(newsId);

    // 🎯 LRU EVICTION
    if (_cacheAccessOrder.length > _MAX_CACHE_SIZE) {
      final removedId = _cacheAccessOrder.removeAt(0);
      _commentsCache.remove(removedId);
      _loadingStates.remove(removedId);
    }
  }

  // 🎯 ОПТИМИЗИРОВАННАЯ ОБРАБОТКА ПОДПИСКИ
  void _handleFollow() async {
    final newsProvider = context.read<NewsProvider>();
    final safeNews = _ensureStringMap(widget.news);
    final authorId = safeNews['author_id']?.toString() ?? '';

    if (authorId.isEmpty) return;

    try {
      setState(() {
        _isFollowing = !_isFollowing;
      });

      await newsProvider.toggleFollow(authorId);
    } catch (e) {
      setState(() {
        _isFollowing = !_isFollowing;
      });
    }
  }

  // 🎯 ОПТИМИЗИРОВАННАЯ ОБРАБОТКА ШАРИНГА
  void _handleShare() async {
    final safeNews = _ensureStringMap(widget.news);
    final postId = safeNews['id']?.toString() ?? '';

    if (postId.isEmpty) return;

    try {
      final newsProvider = context.read<NewsProvider>();
      await newsProvider.shareNews(postId);
    } catch (e) {
      // Ошибка уже обработана в провайдере
    }
  }

  // 🎯 ОПТИМИЗИРОВАННАЯ ОБРАБОТКА УДАЛЕНИЯ
  void _handleDelete() async {
    final safeNews = _ensureStringMap(widget.news);
    final postId = safeNews['id']?.toString() ?? '';

    if (postId.isEmpty) return;

    // 🎯 СОХРАНЯЕМ КОНТЕКСТ ДО АСИНХРОННЫХ ОПЕРАЦИЙ
    final currentContext = context;
    if (!mounted) return;

    showDialog(
      context: currentContext,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пост?'),
        content: const Text('Вы уверены, что хотите удалить этот пост? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // 🎯 ПОКАЗЫВАЕМ ИНДИКАТОР УДАЛЕНИЯ С ПРОВЕРКОЙ mounted
              if (!mounted) return;
              final scaffoldMessenger = ScaffoldMessenger.of(currentContext);
              final snackBar = scaffoldMessenger.showSnackBar(
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

              try {
                // 🎯 ВЫЗЫВАЕМ КОЛБЭК БЕЗ AWAIT ЕСЛИ ОН NULL
                if (widget.onDelete != null) {
                  await widget.onDelete!();
                } else {
                  // 🎯 ЕСЛИ КОЛБЭК НЕ ПЕРЕДАН, ИСПОЛЬЗУЕМ ПРЯМОЙ ВЫЗОВ
                  final newsProvider = currentContext.read<NewsProvider>();
                  await newsProvider.deleteNews(postId);
                }

                // 🎯 СКРЫВАЕМ ИНДИКАТОР И ПОКАЗЫВАЕМ УСПЕХ С ПРОВЕРКОЙ
                if (mounted) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Пост успешно удален!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при удалении: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  // 🎯 ОПТИМИЗИРОВАННАЯ ОБРАБОТКА РЕДАКТИРОВАНИЯ
  void _handleEdit() async {
    final safeNews = _ensureStringMap(widget.news);
    final postId = safeNews['id']?.toString() ?? '';

    if (postId.isEmpty) return;

    final currentContext = context;
    if (!mounted) return;

    try {
      final result = await showDialog<Map<String, dynamic>>(
        context: currentContext,
        builder: (context) => _EditPostDialog(
          currentTitle: safeNews['title']?.toString() ?? '',
          currentContent: safeNews['content']?.toString() ?? '',
          currentHashtags: _getHashtags(),
        ),
      );

      if (result != null && result.isNotEmpty && mounted) {
        // 🎯 ПРАВИЛЬНАЯ ПЕРЕДАЧА ДАННЫХ ДЛЯ ОБНОВЛЕНИЯ
        final updateData = {
          'title': result['title']?.toString() ?? '',
          'content': result['content']?.toString() ?? '',
          'hashtags': result['hashtags'] is List ? result['hashtags'] : [],
        };

        print('✏️ Sending update data: $updateData');

        if (widget.onEdit != null) {
          await widget.onEdit!(updateData);
        } else {
          final newsProvider = currentContext.read<NewsProvider>();
          await newsProvider.updateNews(postId, updateData);
        }
      }
    } catch (e) {
      print('❌ Edit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Ошибка при редактировании: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🎯 ОПТИМИЗИРОВАННАЯ ОТПРАВКА КОММЕНТАРИЯ
  Future<void> _sendComment(String newsId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final newsProvider = context.read<NewsProvider>();

      // 🎯 ОПТИМИСТИЧЕСКОЕ ОБНОВЛЕНИЕ
      final newComment = {
        'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'text': text,
        'author_name': newsProvider.userProvider.userName.isNotEmpty
            ? newsProvider.userProvider.userName
            : 'Пользователь',
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (!_commentsCache.containsKey(newsId)) {
        _commentsCache[newsId] = [];
      }
      _commentsCache[newsId]!.insert(0, newComment);
      _updateCacheAccess(newsId);

      setState(() {});

      // 🎯 ОЧИСТКА И ОТПРАВКА
      _commentController.clear();
      _commentFocusNode.unfocus();
      setState(() {
        _isWritingComment = false;
      });

      // 🎯 ФОНОВАЯ СИНХРОНИЗАЦИЯ
      await newsProvider.addComment(newsId, text);
      await _getCommentsFromAPI(newsId, forceRefresh: true);

    } catch (e) {
      // Ошибка уже обработана в провайдере
    }
  }

  // 🎯 ОПТИМИЗИРОВАННОЕ ПОЛУЧЕНИЕ КОММЕНТАРИЕВ
  Future<List<Map<String, dynamic>>> _getCommentsFromAPI(String newsId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _commentsCache.containsKey(newsId)) {
        _updateCacheAccess(newsId);
        return _commentsCache[newsId]!;
      }

      _loadingStates[newsId] = true;
      if (mounted) setState(() {});

      final comments = await ApiService.getComments(newsId);
      final parsedComments = comments.map((comment) {
        final safeComment = _ensureStringMap(comment);
        return {
          'id': _getStringValue(safeComment['id']),
          'text': _getStringValue(safeComment['text']),
          'author_name': _getStringValue(safeComment['author_name']),
          'timestamp': _getStringValue(safeComment['timestamp'] ?? safeComment['created_at']),
        };
      }).toList();

      _commentsCache[newsId] = parsedComments;
      _updateCacheAccess(newsId);
      _loadingStates[newsId] = false;

      if (mounted) setState(() {});
      return parsedComments;
    } catch (e) {
      _loadingStates[newsId] = false;
      if (mounted) setState(() {});
      return [];
    }
  }

  // 🎯 ОПТИМИЗИРОВАННОЕ ПЕРЕКЛЮЧЕНИЕ КОММЕНТАРИЕВ
  void _toggleComments(String newsId) async {
    if (_showComments && _currentNewsId == newsId) {
      await _animationController.reverse();
      setState(() {
        _showComments = false;
        _currentNewsId = null;
        _isWritingComment = false;
        _commentController.clear();
        _commentFocusNode.unfocus();
      });
    } else {
      setState(() {
        _showComments = true;
        _currentNewsId = newsId;
      });
      _animationController.forward();
      await _getCommentsFromAPI(newsId, forceRefresh: true);
    }
  }

  // 🎯 ОПТИМИЗИРОВАННЫЕ ВИДЖЕТЫ КОММЕНТАРИЕВ
  Widget _buildCommentsSection(String newsId) {
    final comments = _commentsCache[newsId] ?? [];
    final isLoading = _loadingStates[newsId] == true;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommentsHeader(newsId, comments.length),
                const SizedBox(height: 12),
                if (isLoading)
                  _buildLoadingIndicator()
                else if (comments.isEmpty)
                  _buildEmptyComments()
                else
                  _buildCommentsList(comments),
                const SizedBox(height: 12),
                _buildCommentInput(newsId),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsHeader(String newsId, int commentCount) {
    return Row(
      children: [
        const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF7E57C2)),
        const SizedBox(width: 8),
        const Text('Комментарии', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Text('$commentCount', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _toggleComments(newsId),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(String newsId) {
    if (!_isWritingComment) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isWritingComment = true;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _commentFocusNode.requestFocus();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_comment_rounded, size: 16, color: Color(0xFF7E57C2)),
              SizedBox(width: 8),
              Text('Добавить комментарий...', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final hasText = _commentController.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7E57C2).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Напишите комментарий...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (text) => _sendComment(newsId),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: hasText ? () => _sendComment(newsId) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasText ? const Color(0xFF7E57C2) : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF7E57C2)),
        ),
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Column(
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 32, color: Colors.grey),
          SizedBox(height: 8),
          Text('Пока нет комментариев', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<Map<String, dynamic>> comments) {
    return Column(
      children: comments.map((comment) {
        final author = _getStringValue(comment['author_name']);
        final text = _getStringValue(comment['text']);
        final date = _getStringValue(comment['timestamp']);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF7E57C2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    author.isNotEmpty ? author[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _truncateAuthorName(author),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.getTimeAgo(date),
                          style: TextStyle(color: Colors.grey[500], fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _truncateText(text, maxLength: _COMMENT_PREVIEW_LENGTH),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🎯 ОПТИМИЗИРОВАННЫЕ КНОПКИ ДЕЙСТВИЙ
  Widget _buildActionButton(IconData icon, String count, Color color, VoidCallback onPressed) {
    final displayCount = count.isNotEmpty && count != '0' ? _formatCount(int.parse(count)) : '';

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (displayCount.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                displayCount,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🎯 ОПТИМИЗИРОВАННЫЙ ВИДЖЕТ КНОПКИ ПОДПИСКИ
  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: _handleFollow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: _isFollowing
              ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[600]!])
              : const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF7E57C2)]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _isFollowing ? Colors.grey.withOpacity(0.2) : const Color(0xFF7E57C2).withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          _isFollowing ? Icons.check : Icons.add,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  // 🎯 ОПТИМИЗИРОВАННЫЙ ВИДЖЕТ КНОПКИ МЕНЮ
  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 18,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // 🎯 ОПТИМИЗИРОВАННОЕ МЕНЮ
  void _showMenu(BuildContext context) {
    final isCurrentUserAuthor = _isCurrentUserAuthor();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.blue),
              title: const Text('Поделиться'),
              onTap: () {
                Navigator.pop(context);
                _handleShare();
              },
            ),
            if (isCurrentUserAuthor) ...[
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF7E57C2)),
                title: const Text('Редактировать'),
                onTap: () {
                  Navigator.pop(context);
                  _handleEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Удалить'),
                onTap: () {
                  Navigator.pop(context);
                  _handleDelete();
                },
              ),
            ],
            Container(
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[700],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Отмена'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 ОПТИМИЗИРОВАННЫЙ ВИДЖЕТ КОНТЕНТА
  Widget _buildContentWithExpand(String content) {
    final isLongText = content.length > _CONTENT_PREVIEW_LENGTH;
    final displayText = _isExpanded ? content : _truncateText(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.left,
        ),
        if (isLongText) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _isExpanded ? 'Свернуть' : 'Читать далее',
                  style: const TextStyle(
                    color: Color(0xFF7E57C2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transformAlignment: Alignment.center,
                  transform: Matrix4.rotationZ(_isExpanded ? 3.14159 : 0),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF7E57C2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        final currentPost = newsProvider.news.firstWhere(
              (post) => _ensureStringMap(post)['id'] == _ensureStringMap(widget.news)['id'],
          orElse: () => widget.news,
        );

        final safeNews = _ensureStringMap(currentPost);
        final newsId = _getStringValue(safeNews['id']);
        final authorName = _getStringValue(safeNews['author_name']);
        final title = _getStringValue(safeNews['title']);
        final content = _getStringValue(safeNews['content']);
        final hashtags = _getHashtags();
        final createdAt = _getStringValue(safeNews['created_at']);

        final isLiked = _getBoolValue(safeNews['isLiked']) ?? false;
        final isBookmarked = _getBoolValue(safeNews['isBookmarked']) ?? false;
        final isReposted = _getBoolValue(safeNews['isReposted']) ?? false;
        final likesCount = _getIntValue(safeNews['likes_count']) ?? 0;
        final repostsCount = _getIntValue(safeNews['reposts_count']) ?? 0;
        final commentsCount = _getIntValue(safeNews['comments_count']) ?? 0;

        final isCurrentUserAuthor = _isCurrentUserAuthor();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ШАПКА КАРТОЧКИ
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF7E57C2)]),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0xFF7E57C2), blurRadius: 4)],
                        ),
                        child: Center(
                          child: Text(
                            authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _truncateAuthorName(authorName),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(widget.getTimeAgo(createdAt),
                                style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ],
                        ),
                      ),
                      _buildMenuButton(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // КОНТЕНТ
                  if (title.isNotEmpty) Text(
                    _truncateText(title, maxLength: 120),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildContentWithExpand(content),
                  ],

                  // ХЕШТЕГИ
                  if (hashtags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: hashtags.map((tag) {
                        final cleanTag = tag.replaceAll('#', '').trim();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF7E57C2).withOpacity(0.1),
                                const Color(0xFF667eea).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF7E57C2).withOpacity(0.3)),
                          ),
                          child: Text(
                            '#$cleanTag',
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

                  const SizedBox(height: 16),

                  // КНОПКИ ДЕЙСТВИЙ
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        if (!isCurrentUserAuthor)
                          _buildFollowButton(),
                      ],
                    ),
                  ),

                  // КОММЕНТАРИИ
                  if (_showComments && _currentNewsId == newsId)
                    _buildCommentsSection(newsId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🎯 ВЫНЕСЕННЫЙ ДИАЛОГ РЕДАКТИРОВАНИЯ
class _EditPostDialog extends StatefulWidget {
  final String currentTitle;
  final String currentContent;
  final List<String> currentHashtags;

  const _EditPostDialog({
    required this.currentTitle,
    required this.currentContent,
    required this.currentHashtags,
  });

  @override
  State<_EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<_EditPostDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _hashtagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _contentController = TextEditingController(text: widget.currentContent);
    _hashtagsController =
        TextEditingController(text: widget.currentHashtags.join(' '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final isSmallScreen = screenHeight < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: 500,
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
                    child: const Icon(
                        Icons.edit_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Редактировать пост',
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

                    // 🎯 ПОЛЕ ЗАГОЛОВКА (75 символов)
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Заголовок*',
                        hintText: 'Введите заголовок поста...',
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
                          borderSide: const BorderSide(color: Color(0xFF7E57C2),
                              width: 2),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.title_rounded,
                              color: Color(0xFF7E57C2), size: 20),
                        ),
                        suffixIcon: _buildCharCounter(_titleController, 75),
                        counterText: '',
                      ),
                      maxLines: 2,
                      maxLength: 75,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // 🎯 ПОЛЕ ОПИСАНИЯ (435 символов)
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Описание*',
                        hintText: 'Введите описание поста...',
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
                          borderSide: const BorderSide(color: Color(0xFF7E57C2),
                              width: 2),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.description_rounded,
                              color: Color(0xFF7E57C2), size: 20),
                        ),
                        suffixIcon: _buildCharCounter(_contentController, 435),
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
                      controller: _hashtagsController,
                      decoration: InputDecoration(
                        labelText: 'Хештеги',
                        hintText: 'введите хештеги через пробел...',
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
                          borderSide: const BorderSide(color: Color(0xFF7E57C2),
                              width: 2),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tag_rounded,
                              color: Color(0xFF7E57C2), size: 20),
                        ),
                        suffixIcon: _buildCharCounter(_hashtagsController, 60),
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
                          Icon(Icons.info_outline_rounded, size: 16,
                              color: Colors.blue.shade600),
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
                                  'Максимум 60 символов',
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

            // 🎯 КНОПКИ ДЕЙСТВИЙ
            Container(
              padding: const EdgeInsets.all(20),
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
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSave() ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF7E57C2).withOpacity(0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Сохранить',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
    final titleLength = _titleController.text.length;
    final contentLength = _contentController.text.length;
    final hashtagsLength = _hashtagsController.text.length;

    final hasTitleError = titleLength == 0 || titleLength > 75;
    final hasContentError = contentLength == 0 || contentLength > 435;
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
            Icon(Icons.check_circle_rounded, size: 16,
                color: Colors.green.shade600),
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
              Icon(Icons.info_outline_rounded, size: 16,
                  color: Colors.orange.shade600),
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
          if (titleLength == 0)
            Text(
              '• Заголовок обязателен для заполнения',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (titleLength > 75)
            Text(
              '• Заголовок слишком длинный (${titleLength}/75)',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (contentLength == 0)
            Text(
              '• Описание обязательно для заполнения',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
            ),
          if (contentLength > 435)
            Text(
              '• Описание слишком длинное (${contentLength}/435)',
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
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final hashtags = _hashtagsController.text;

    return title.isNotEmpty &&
        content.isNotEmpty &&
        title.length <= 75 &&
        content.length <= 435 &&
        hashtags.length <= 60;
  }

  void _saveChanges() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final hashtagsText = _hashtagsController.text.trim();

    final hashtags = hashtagsText.isEmpty
        ? []
        : hashtagsText.split(' ')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.startsWith('#') ? tag.substring(1) : tag)
        .toList();

    Navigator.pop(context, {
      'title': title,
      'content': content,
      'hashtags': hashtags,
    });
  }
}