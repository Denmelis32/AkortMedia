import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/pages/news_page/profile_menu_page.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'dialogs.dart';
import '../../../providers/news_provider.dart';
import '../../../services/api_service.dart';
import 'news_card.dart';
import 'utils.dart';
import 'shimmer_loading.dart';
import 'animated_fab.dart';
import 'search_delegate.dart';

// Импортируем новые модули
import 'state/news_state.dart';
import 'theme/news_theme.dart';
import 'widgets/empty_states.dart';
import 'widgets/loading_state.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/app_bar.dart'; // Импортируем NewsAppBar

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

class _NewsPageState extends State<NewsPage> with SingleTickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late NewsPageState _pageState;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _pageState = NewsPageState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isMounted) return;
      await _ensureDataPersistence();
      _loadNews(showLoading: true);
      _safeProviderOperation((newsProvider) => newsProvider.loadUserTags());
      _animationController.forward();
    });
  }

  // Безопасная операция с провайдером
  void _safeProviderOperation(Function(NewsProvider) operation) {
    if (!_isMounted) return;

    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (!newsProvider.isDisposed) {
        operation(newsProvider);
      } else {
        print('⚠️ NewsProvider is disposed, skipping operation');
      }
    } catch (e) {
      print('❌ Error in provider operation: $e');
    }
  }

  Future<void> _ensureDataPersistence() async {
    if (!_isMounted) return;

    try {
      _safeProviderOperation((newsProvider) async {
        await newsProvider.ensureDataPersistence();
      });
    } catch (e) {
      print('❌ Error ensuring data persistence: $e');
    }
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 16.0; // Для компьютеров и планшетов
    return 0.0;                   // Для телефонов - БЕЗ ОТСТУПОВ
  }

  EdgeInsets _getNewsCardPadding(BuildContext context, int index, int totalCount) {
    final horizontalPadding = _getHorizontalPadding(context);

    return EdgeInsets.fromLTRB(
      horizontalPadding,
      0, // ВЕРХНИЙ отступ 0
      horizontalPadding,
      0, // НИЖНИЙ отступ 0 - полностью убираем все отступы
    );
  }

  Future<void> _loadNews({bool showLoading = false}) async {
    if (!_isMounted) return;

    try {
      if (showLoading) {
        _safeProviderOperation((newsProvider) => newsProvider.setLoading(true));
      }

      await _safeProviderOperationAsync((newsProvider) => newsProvider.loadNews());
    } catch (e) {
      _showErrorSnackBar('Ошибка загрузки: ${e.toString()}');
    } finally {
      if (showLoading && _isMounted) {
        _safeProviderOperation((newsProvider) => newsProvider.setLoading(false));
      }
    }
  }

  // Безопасная асинхронная операция с провайдером
  Future<void> _safeProviderOperationAsync(Future Function(NewsProvider) operation) async {
    if (!_isMounted) return;

    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (!newsProvider.isDisposed) {
        await operation(newsProvider);
      } else {
        print('⚠️ NewsProvider is disposed, skipping async operation');
      }
    } catch (e) {
      print('❌ Error in async provider operation: $e');
      rethrow;
    }
  }

  Future<void> _onRefresh() async {
    if (!_isMounted) return;

    try {
      await _safeProviderOperationAsync((newsProvider) => newsProvider.loadNews());
      if (_isMounted) {
        _refreshController.refreshCompleted();
        _showSuccessSnackBar('Новости обновлены');
      }
    } catch (e) {
      if (_isMounted) {
        _refreshController.refreshFailed();
        _showErrorSnackBar('Ошибка обновления: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (_isMounted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: NewsTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (_isMounted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: NewsTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ========== УЛУЧШЕННЫЕ МЕТОДЫ ВЗАИМОДЕЙСТВИЯ С НОВОСТЯМИ ==========

  Future<void> _toggleLike(int index) async {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final bool isCurrentlyLiked = news['isLiked'] ?? false;
      final int currentLikes = news['likes'] ?? 0;

      try {
        HapticFeedback.lightImpact();
        newsProvider.updateNewsLikeStatus(
            index,
            !isCurrentlyLiked,
            isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1
        );
      } catch (e) {
        newsProvider.updateNewsLikeStatus(index, isCurrentlyLiked, currentLikes);
        _showErrorSnackBar('Не удалось поставить лайк');
      }
    });
  }

  Future<void> _toggleBookmark(int index) async {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final bool isCurrentlyBookmarked = news['isBookmarked'] ?? false;

      try {
        HapticFeedback.lightImpact();
        newsProvider.updateNewsBookmarkStatus(index, !isCurrentlyBookmarked);
        _showSuccessSnackBar(
            !isCurrentlyBookmarked
                ? 'Добавлено в избранное'
                : 'Удалено из избранное'
        );
      } catch (e) {
        newsProvider.updateNewsBookmarkStatus(index, isCurrentlyBookmarked);
        _showErrorSnackBar('Не удалось добавить в закладки');
      }
    });
  }

  Future<void> _toggleFollow(int index) async {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final bool isCurrentlyFollowing = news['isFollowing'] ?? false;

      try {
        HapticFeedback.mediumImpact();
        newsProvider.updateNewsFollowStatus(index, !isCurrentlyFollowing);
        final isChannelPost = news['is_channel_post'] == true;
        final targetName = isChannelPost
            ? news['channel_name'] ?? 'канал'
            : news['author_name'] ?? 'пользователя';

        if (!isCurrentlyFollowing) {
          _showSuccessSnackBar('✅ Вы подписались на $targetName');
        } else {
          _showSuccessSnackBar('❌ Вы отписались от $targetName');
        }
      } catch (e) {
        newsProvider.updateNewsFollowStatus(index, isCurrentlyFollowing);
        _showErrorSnackBar('Не удалось изменить подписку');
      }
    });
  }

  // ИСПРАВЛЕНИЕ: Обновленный метод добавления комментария
  Future<void> _addComment(int index, String commentText, String userName, String userAvatar) async {
    if (commentText.trim().isEmpty || !_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final newsId = news['id'].toString();

      try {
        final newComment = {
          'id': 'comment-${DateTime.now().millisecondsSinceEpoch}-${news['id']}',
          'author': userName,
          'text': commentText.trim(),
          'time': 'Только что',
          'author_avatar': userAvatar,
          'created_at': DateTime.now().toIso8601String(),
        };

        newsProvider.addCommentToNews(newsId, newComment);
        _showSuccessSnackBar('Комментарий добавлен');

      } catch (e) {
        print('❌ Ошибка добавления комментария: $e');
        _showErrorSnackBar('Не удалось добавить комментарий');
      }
    });
  }

  String _getUserAvatarUrl(String userName) {
    String avatarUrl = '';
    _safeProviderOperation((newsProvider) {
      final currentProfileImage = newsProvider.getCurrentProfileImage();

      if (currentProfileImage is File) {
        avatarUrl = _getFallbackAvatarUrl(userName);
      } else if (currentProfileImage is String && currentProfileImage.isNotEmpty) {
        avatarUrl = currentProfileImage;
      } else {
        avatarUrl = _getFallbackAvatarUrl(userName);
      }
    });
    return avatarUrl;
  }

  // ИСПРАВЛЕНИЕ: Улучшенный метод создания новости
  Future<void> _addNews(String title, String description, String hashtags) async {
    if (description.isEmpty || !_isMounted) return;

    final hashtagsArray = _formatHashtags(hashtags);

    // Показываем индикатор загрузки
    _safeProviderOperation((newsProvider) => newsProvider.setLoading(true));

    try {
      final newNews = await ApiService.createNews({
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
      });

      // УБИРАЕМ дублирование - используем ТОЛЬКО данные от API
      final Map<String, dynamic> newsItem = _convertToStringDynamicMap({
        ...newNews,
        'author_name': widget.userName,
        'author_avatar': _getUserAvatarUrl(widget.userName),
        'isLiked': false,
        'isBookmarked': false,
        'isFollowing': false,
        'likes': 0,
        'comments': [],
        'user_tags': {'tag1': 'Новый тег'},
        'tag_color': _generateColorFromId(newNews['id']?.toString() ?? '').value,
        'is_channel_post': false, // ЯВНО указываем, что это не канальный пост
      });

      // Добавляем новость только один раз
      _safeProviderOperation((newsProvider) => newsProvider.addNews(newsItem));
      _showSuccessSnackBar('🎉 Новость успешно создана!');

    } catch (e) {
      print('❌ Ошибка создания новости: $e');

      // ТОЛЬКО В СЛУЧАЕ ОШИБКИ создаем локальную новость
      final Map<String, dynamic> localNewsItem = _convertToStringDynamicMap({
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'title': title.trim(),
        'description': description.trim(),
        'hashtags': hashtagsArray,
        'author_name': widget.userName,
        'author_avatar': _getUserAvatarUrl(widget.userName),
        'likes': 0,
        'comments': [],
        'user_tags': {'tag1': 'Новый тег'},
        'created_at': DateTime.now().toIso8601String(),
        'isLiked': false,
        'isBookmarked': false,
        'isFollowing': false,
        'tag_color': _generateColorFromId('local-${DateTime.now().millisecondsSinceEpoch}').value,
        'is_channel_post': false, // ЯВНО указываем, что это не канальный пост
      });

      _safeProviderOperation((newsProvider) => newsProvider.addNews(localNewsItem));
      _showSuccessSnackBar('📝 Новость создана локально (ошибка сети)');
    } finally {
      // Всегда убираем индикатор загрузки
      if (_isMounted) {
        _safeProviderOperation((newsProvider) => newsProvider.setLoading(false));
      }
    }
  }

  String _getFallbackAvatarUrl(String userName) {
    // Используем локальный генератор аватаров вместо внешнего сервиса
    final name = userName.isNotEmpty ? userName : 'User';
    final firstLetter = name[0].toUpperCase();

    // Создаем цвет на основе имени
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final colorIndex = name.codeUnits.reduce((a, b) => a + b) % colors.length;
    final color = colors[colorIndex];

    // Возвращаем прозрачный цвет, так как будем использовать Text аватар
    return ''; // Пустая строка, будем использовать Text виджет
  }

  Map<String, dynamic> _convertToStringDynamicMap(Map<dynamic, dynamic> input) {
    final Map<String, dynamic> result = {};

    input.forEach((key, value) {
      final String stringKey = key.toString();

      if (value is Map<dynamic, dynamic>) {
        result[stringKey] = _convertToStringDynamicMap(value);
      } else if (value is List) {
        result[stringKey] = _convertList(value);
      } else {
        result[stringKey] = value;
      }
    });

    return result;
  }

  List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<dynamic, dynamic>) {
        return _convertToStringDynamicMap(item);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
  }

  Color _generateColorFromId(String id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }

  List<String> _formatHashtags(String hashtags) {
    final tags = hashtags
        .split(RegExp(r'[,\s]+'))
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) {
      var cleanTag = tag.replaceAll(RegExp(r'#'), '').trim();
      cleanTag = cleanTag.replaceAll(RegExp(r'\s+'), '');
      return cleanTag;
    })
        .where((tag) => tag.isNotEmpty)
        .toList();

    print('🎯 Formatted hashtags: $tags');
    return tags;
  }

  Future<void> _editNews(int index, String title, String description, String hashtags) async {
    if (description.isEmpty || !_isValidIndex(index) || !_isMounted) return;

    final hashtagsArray = _formatHashtags(hashtags);

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);

      try {
        ApiService.updateNews(news['id'].toString(), {
          'title': title,
          'description': description,
          'hashtags': hashtagsArray,
        }).then((_) {
          newsProvider.updateNews(index, {
            ...news,
            'title': title,
            'description': description,
            'hashtags': hashtagsArray,
          });
          _showSuccessSnackBar('📝 Новость обновлена');
        }).catchError((e) {
          newsProvider.updateNews(index, {
            ...news,
            'title': title,
            'description': description,
            'hashtags': hashtagsArray,
          });
          _showSuccessSnackBar('💾 Изменения сохранены локально');
        });
      } catch (e) {
        newsProvider.updateNews(index, {
          ...news,
          'title': title,
          'description': description,
          'hashtags': hashtagsArray,
        });
        _showSuccessSnackBar('💾 Изменения сохранены локально');
      }
    });
  }

  Future<void> _deleteNews(int index) async {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);

      try {
        ApiService.deleteNews(news['id'].toString()).then((_) {
          newsProvider.removeNews(index);
          _showSuccessSnackBar('🗑️ Новость удалена');
        }).catchError((e) {
          newsProvider.removeNews(index);
          _showSuccessSnackBar('🗑️ Новость удалена локально');
        });
      } catch (e) {
        newsProvider.removeNews(index);
        _showSuccessSnackBar('🗑️ Новость удалена локально');
      }
    });
  }

  void _editUserTag(int newsIndex, String tagId, String newTagName, Color color) {
    if (!_isValidIndex(newsIndex) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      try {
        newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
        _showSuccessSnackBar('🏷️ Тег обновлен');
      } catch (e) {
        newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color: color);
      }
    });
  }

  Future<void> _shareNews(int index) async {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);

      final title = news['title'] ?? '';
      final description = news['description'] ?? '';
      final url = 'https://example.com/news/${news['id']}';

      Share.share('$title\n\n$description\n\n$url').then((_) {
        _showSuccessSnackBar('📤 Новость опубликована');
      });
    });
  }

  // ========== БЕЗОПАСНЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С ИНДЕКСАМИ ==========

  bool _isValidIndex(int index) {
    bool isValid = false;
    _safeProviderOperation((newsProvider) {
      isValid = index >= 0 && index < newsProvider.news.length;
    });
    return isValid;
  }

  void _safeNewsAction(int originalIndex, Function(int) action) {
    if (_isValidIndex(originalIndex) && _isMounted) {
      action(originalIndex);
    } else {
      print('⚠️ Invalid news index: $originalIndex');
      _showErrorSnackBar('Ошибка: новость не найдена');
    }
  }

  // ========== УЛУЧШЕННАЯ ФИЛЬТРАЦИЯ ==========

  List<dynamic> _getFilteredNews(List<dynamic> news) {
    if (!_isMounted) return [];

    List<dynamic> filtered = List.from(news); // Создаем копию для безопасности

    if (_pageState.searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final newsItem = Map<String, dynamic>.from(item);
        final title = newsItem['title']?.toString().toLowerCase() ?? '';
        final description = newsItem['description']?.toString().toLowerCase() ?? '';
        final hashtags = (newsItem['hashtags'] is List
            ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
            : '');
        final author = newsItem['author_name']?.toString().toLowerCase() ?? '';
        final userTags = (newsItem['user_tags'] is Map
            ? (newsItem['user_tags'] as Map).values.join(' ').toLowerCase()
            : '');

        return title.contains(_pageState.searchQuery.toLowerCase()) ||
            description.contains(_pageState.searchQuery.toLowerCase()) ||
            hashtags.contains(_pageState.searchQuery.toLowerCase()) ||
            author.contains(_pageState.searchQuery.toLowerCase()) ||
            userTags.contains(_pageState.searchQuery.toLowerCase());
      }).toList();
    }

    switch (_pageState.currentFilter) {
      case 1: // Мои новости
        filtered = filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return newsItem['author_name'] == widget.userName;
        }).toList();
        break;
      case 2: // Популярные
        filtered = filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return (newsItem['likes'] ?? 0) > 5;
        }).toList();
        break;
      case 3: // Избранное
        filtered = filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return newsItem['isBookmarked'] == true;
        }).toList();
        break;
      case 4: // Подписки
        filtered = filtered.where((item) {
          final newsItem = Map<String, dynamic>.from(item);
          return newsItem['isFollowing'] == true;
        }).toList();
        break;
      default: // Все новости
        break;
    }

    return filtered;
  }

  // ========== УЛУЧШЕННЫЕ ДИАЛОГИ ==========
  void _showAddNewsDialog() {
    if (!_isMounted) return;

    showDialog(
      context: context,
      builder: (context) => AddNewsDialog(
        onAddNews: _addNews,
      ),
    );
  }

  void _showEditNewsDialog(int index) {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);

      showDialog(
        context: context,
        builder: (context) => EditNewsDialog(
          news: news,
          onEditNews: (title, description, hashtags) => _editNews(index, title, description, hashtags),
        ),
      );
    });
  }

  void _showDeleteConfirmationDialog(int index) {
    if (!_isMounted) return;

    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        onDelete: () => _deleteNews(index),
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Открытие страницы профиля вместо модального окна
  void _showProfilePage(BuildContext context) {
    if (!_isMounted) return;

    _safeProviderOperation((newsProvider) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userName: widget.userName,
            userEmail: widget.userEmail,
            onLogout: () {
              // Возвращаемся на предыдущую страницу перед выходом
              if (_isMounted) {
                Navigator.pop(context);
                widget.onLogout();
              }
            },
            newMessagesCount: 3,
            profileImageUrl: newsProvider.profileImageUrl,
            profileImageFile: newsProvider.profileImageFile,
            onProfileImageUrlChanged: (url) {
              _safeProviderOperation((provider) => provider.updateProfileImageUrl(url));
            },
            onProfileImageFileChanged: (file) {
              _safeProviderOperation((provider) => provider.updateProfileImageFile(file));
            },
            onMessagesTap: () {
              if (_isMounted) {
                Navigator.pop(context);
                _showSuccessSnackBar('Переход к сообщениям');
              }
            },
            onSettingsTap: () {
              if (_isMounted) {
                Navigator.pop(context);
                _showSuccessSnackBar('Переход к настройкам');
              }
            },
            onHelpTap: () {
              if (_isMounted) {
                Navigator.pop(context);
                _showSuccessSnackBar('Переход к разделу помощи');
              }
            },
            onAboutTap: () {
              if (_isMounted) {
                Navigator.pop(context);
                _showSuccessSnackBar('Информация о приложении');
              }
            },
          ),
        ),
      );
    });
  }

  // ========== НОВЫЕ ФУНКЦИИ ==========

  void _scrollToTop() {
    if (!_isMounted) return;
    _pageState.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // ИСПРАВЛЕНИЕ: Обновленный метод репоста
  void _toggleRepost(int index) {
    if (!_isValidIndex(index) || !_isMounted) return;

    _safeProviderOperation((newsProvider) {
      final news = Map<String, dynamic>.from(newsProvider.news[index]);
      final bool isCurrentlyReposted = news['isReposted'] ?? false;
      final int currentReposts = news['reposts'] ?? 0;

      try {
        HapticFeedback.lightImpact();
        newsProvider.updateNewsRepostStatus(
            index,
            !isCurrentlyReposted,
            isCurrentlyReposted ? currentReposts - 1 : currentReposts + 1
        );

        _showSuccessSnackBar(
            !isCurrentlyReposted
                ? '🔁 Новость репостнута'
                : '❌ Репост отменен'
        );
      } catch (e) {
        newsProvider.updateNewsRepostStatus(index, isCurrentlyReposted, currentReposts);
        _showErrorSnackBar('Не удалось выполнить репост');
      }
    });
  }

  void _clearAllFilters() {
    if (!_isMounted) return;
    _pageState.setFilter(0);
    _pageState.clearSearch();
    _showSuccessSnackBar('Фильтры сброшены');
  }

  Widget _buildScrollToTopButton() {
    return AnimatedBuilder(
      animation: _pageState.scrollController,
      builder: (context, child) {
        final showButton = _pageState.scrollController.hasClients &&
            _pageState.scrollController.offset > 200;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showButton ? 1.0 : 0.0,
          child: Visibility(
            visible: showButton,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: NewsTheme.primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.arrow_upward_rounded),
              heroTag: 'scroll_to_top',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _pageState,
      child: Consumer2<NewsPageState, NewsProvider>(
        builder: (context, pageState, newsProvider, child) {
          // Проверяем disposed состояние провайдера
          if (newsProvider.isDisposed) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Загрузка новостей...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredNews = _getFilteredNews(newsProvider.news);
          final hasActiveFilters = pageState.currentFilter != 0 || pageState.searchQuery.isNotEmpty;

          return Theme(
            data: NewsTheme.themeData,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: NewsAppBar(
                userName: widget.userName,
                userEmail: widget.userEmail,
                isSearching: pageState.isSearching,
                searchQuery: pageState.searchQuery,
                onSearchChanged: (query) {
                  if (!_isMounted) return;
                  pageState.setSearchQuery(query);
                  if (query.isNotEmpty) {
                    pageState.addToRecentSearches(query);
                  }
                },
                onSearchToggled: () {
                  if (!_isMounted) return;
                  pageState.setSearching(!pageState.isSearching);
                },
                onProfilePressed: () => _showProfilePage(context),
                onClearFilters: _clearAllFilters,
                hasActiveFilters: hasActiveFilters,
                newMessagesCount: 3,
                profileImageUrl: newsProvider.profileImageUrl,
                profileImageFile: newsProvider.profileImageFile,
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF5F5F5),
                      Color(0xFFE8E8E8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    header: const ClassicHeader(
                      completeText: 'Обновлено',
                      refreshingText: 'Обновление...',
                      releaseText: 'Отпустите для обновления',
                      idleText: 'Потяните для обновления',
                      completeIcon: Icon(Icons.check_rounded, color: Colors.green),
                      refreshingIcon: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: () => _refreshController.loadComplete(),
                    child: CustomScrollView(
                      controller: pageState.scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Основной контент - используем SliverToBoxAdapter для не-sliver виджетов
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              // Фильтры
                              if (newsProvider.news.isNotEmpty)
                                const FilterChipsRow(),

                              // Индикатор активных фильтров
                              if (hasActiveFilters && filteredNews.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _getHorizontalPadding(context), // Адаптивный отступ
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.filter_alt_rounded,
                                          size: 16, color: NewsTheme.primaryColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Найдено: ${filteredNews.length}',
                                        style: TextStyle(
                                          color: NewsTheme.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: _clearAllFilters,
                                        child: Text(
                                          'Очистить',
                                          style: TextStyle(
                                            color: NewsTheme.secondaryTextColor,
                                            fontSize: 12,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Состояния загрузки и новости
                        if (newsProvider.isLoading && newsProvider.news.isEmpty)
                          const SliverFillRemaining(
                            child: NewsLoadingState(),
                          )
                        else if (newsProvider.news.isEmpty)
                          SliverFillRemaining(
                            child: EmptyNewsState(onCreateNews: _showAddNewsDialog),
                          )
                        else if (filteredNews.isEmpty)
                            SliverFillRemaining(
                              child: NoResultsState(
                                searchQuery: pageState.searchQuery,
                                onClearSearch: pageState.clearSearch,
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  final news = Map<String, dynamic>.from(filteredNews[index]);
                                  final newsId = news['id'].toString();
                                  final originalIndex = newsProvider.findNewsIndexById(newsId);

                                  if (originalIndex == -1) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: _getNewsCardPadding(context, index, filteredNews.length),
                                    child: NewsCard(
                                      key: ValueKey('news-${news['id']}'),
                                      news: news,
                                      onLike: () => _safeNewsAction(originalIndex, _toggleLike),
                                      onRepost: () => _safeNewsAction(originalIndex, _toggleRepost),
                                      onBookmark: () => _safeNewsAction(originalIndex, _toggleBookmark),
                                      onFollow: () => _safeNewsAction(originalIndex, _toggleFollow),
                                      onComment: (text, userName, userAvatar) => _safeNewsAction(
                                        originalIndex,
                                            (idx) => _addComment(idx, text, userName, userAvatar),
                                      ),
                                      onEdit: () => _safeNewsAction(originalIndex, _showEditNewsDialog),
                                      onDelete: () => _safeNewsAction(originalIndex, _showDeleteConfirmationDialog),
                                      onShare: () => _safeNewsAction(originalIndex, _shareNews),
                                      onTagEdit: (tagId, newTagName, color) =>
                                          _safeNewsAction(originalIndex, (idx) => _editUserTag(idx, tagId, newTagName, color)),
                                      formatDate: formatDate,
                                      getTimeAgo: getTimeAgo,
                                      scrollController: pageState.scrollController,
                                      onLogout: widget.onLogout,
                                    ),
                                  );
                                },
                                childCount: filteredNews.length,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildScrollToTopButton(),
                  const SizedBox(height: 16),
                  AnimatedFAB(
                    onPressed: _showAddNewsDialog,
                    tooltip: 'Создать новость',
                    icon: Icons.add_rounded,
                    scrollController: pageState.scrollController,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _refreshController.dispose();
    _pageState.dispose();
    _animationController.dispose();
    super.dispose();
  }
}