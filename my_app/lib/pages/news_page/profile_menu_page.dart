import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_app/pages/news_page/theme/news_theme.dart';
import 'package:my_app/providers/news_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// Импортируем необходимые утилиты из news_page
import 'news_card.dart';
import 'utils.dart';
import '../../services/interaction_manager.dart'; // ДОБАВИТЬ
import '../../providers/channel_state_provider.dart'; // ДОБАВИТЬ

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  final int? newMessagesCount;
  final String? profileImageUrl;
  final File? profileImageFile;
  final Function(String?)? onProfileImageUrlChanged;
  final Function(File?)? onProfileImageFileChanged;
  final Function(String?)? onCoverImageUrlChanged;
  final Function(File?)? onCoverImageFileChanged;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onAboutTap;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
    this.newMessagesCount = 0,
    this.profileImageUrl,
    this.profileImageFile,
    this.onProfileImageUrlChanged,
    this.onProfileImageFileChanged,
    this.onCoverImageUrlChanged,
    this.onCoverImageFileChanged,
    this.onMessagesTap,
    this.onSettingsTap,
    this.onHelpTap,
    this.onAboutTap,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  String _searchQuery = '';
  int _selectedSection = 0; // 0 - Мои посты, 1 - Понравилось, 2 - Информация



  // ТАКИЕ ЖЕ ОТСТУПЫ КАК В КАРТОЧКАХ НОВОСТЕЙ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _setCurrentUser();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });

    // УСТАНАВЛИВАЕМ АВАТАРКУ И ОБЛОЖКУ ПО УМОЛЧАНИЮ ПРИ ЗАГРУЗКЕ
    _setDefaultImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugReposts(); // Добавьте этот вызов для отладки
    });
  }



  void _debugReposts() {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = _generateUserId(widget.userEmail);

    print('=== DEBUG REPOSTS ===');
    print('User ID: $userId');
    print('Total news: ${newsProvider.news.length}');

    final allReposts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['is_repost'] == true;
    }).toList();

    print('Total reposts in system: ${allReposts.length}');

    for (final repost in allReposts) {
      final repostItem = Map<String, dynamic>.from(repost);
      print('Repost: ${repostItem['id']} by ${repostItem['reposted_by']}');
    }

    final userReposts = _getUserReposts(newsProvider.news);
    print('User reposts count: ${userReposts.length}');
    print('=== END DEBUG ===');
  }



  void _setCurrentUser() {
    // Создаем уникальный ID пользователя на основе email
    final userId = _generateUserId(widget.userEmail);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.setCurrentUser(userId, widget.userName, widget.userEmail);
    });
  }

  // Метод для генерации ID пользователя
  String _generateUserId(String email) {
    // Простой способ генерации ID пользователя
    return 'user_${email.hashCode.abs()}';
  }


  List<dynamic> _getUserReposts(List<dynamic> news) {
    final userId = _generateUserId(widget.userEmail);

    print('🔍 Searching reposts for user: $userId');
    print('📊 Total news items: ${news.length}');

    final reposts = news.where((item) {
      try {
        final newsItem = Map<String, dynamic>.from(item);
        final isRepost = newsItem['is_repost'] == true;
        final repostedBy = newsItem['reposted_by']?.toString();

        final isUserRepost = isRepost && repostedBy == userId;

        if (isUserRepost) {
          print('✅ Found user repost: ${newsItem['id']} - ${newsItem['title']}');
        }

        return isUserRepost;
      } catch (e) {
        print('❌ Error checking repost: $e');
        return false;
      }
    }).toList();

    print('📊 Total reposts found for user $userId: ${reposts.length}');

    // Дополнительная проверка - логируем все найденные репосты
    for (final repost in reposts) {
      final repostItem = Map<String, dynamic>.from(repost);
      print('📋 Repost details:');
      print('   ID: ${repostItem['id']}');
      print('   Title: ${repostItem['title']}');
      print('   Reposted by: ${repostItem['reposted_by']}');
      print('   Original post: ${repostItem['original_post_id']}');
    }

    return reposts;
  }

  void _showCoverPickerModal(BuildContext context) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = _generateUserId(widget.userEmail);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Выберите обложку профиля',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildCoverSourceButton(
                context,
                Icons.link_rounded,
                'Загрузить по ссылке',
                Colors.purple,
                    () => _showCoverUrlInputDialog(context),
              ),
              const SizedBox(height: 12),
              _buildCoverSourceButton(
                context,
                Icons.photo_library_rounded,
                'Выбрать из галереи',
                Colors.blue,
                    () => _pickCoverImage(ImageSource.gallery, context),
              ),
              const SizedBox(height: 12),
              _buildCoverSourceButton(
                context,
                Icons.photo_camera_rounded,
                'Сделать фото',
                Colors.green,
                    () => _pickCoverImage(ImageSource.camera, context),
              ),
              const SizedBox(height: 12),
              if (_getUserCoverUrl() != null) // ИСПРАВЬТЕ ЭТУ ПРОВЕРКУ
                _buildCoverSourceButton(
                  context,
                  Icons.delete_rounded,
                  'Удалить обложку',
                  Colors.red,
                      () async {
                    await newsProvider.updateCoverImageUrl(null);
                    await newsProvider.updateCoverImageFile(null);
                    Navigator.pop(context);
                    if (context.mounted) {
                      _showSuccessSnackBar('Обложка профиля удалена');
                    }
                  },
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showImagePickerModal(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = _generateUserId(widget.userEmail);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Выберите фото профиля',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildImageSourceButton(
                context,
                Icons.link_rounded,
                'Загрузить по ссылке',
                Colors.purple,
                    () => _showUrlInputDialog(context),
              ),
              const SizedBox(height: 12),
              _buildImageSourceButton(
                context,
                Icons.photo_library_rounded,
                'Выбрать из галереи',
                Colors.blue,
                    () => _pickImage(ImageSource.gallery, context),
              ),
              const SizedBox(height: 12),
              _buildImageSourceButton(
                context,
                Icons.photo_camera_rounded,
                'Сделать фото',
                Colors.green,
                    () => _pickImage(ImageSource.camera, context),
              ),
              const SizedBox(height: 12),
              if (widget.profileImageUrl != null || widget.profileImageFile != null)
                _buildImageSourceButton(
                  context,
                  Icons.delete_rounded,
                  'Удалить фото',
                  Colors.red,
                      () async {
                    await newsProvider.updateProfileImageUrl(null);
                    await newsProvider.updateProfileImageFile(null);
                    Navigator.pop(context);
                    if (context.mounted) {
                      _showSuccessSnackBar('Фото профиля удалено');
                    }
                  },
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }




  // МЕТОД ДЛЯ УСТАНОВКИ ИЗОБРАЖЕНИЙ ПО УМОЛЧАНИЮ
  void _setDefaultImages() {

  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Статистика пользователя
  Map<String, int> _getUserStats(List<dynamic> news) {
    final myNews = news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['author_name'] == widget.userName;
    }).toList();

    final totalLikes = myNews.fold<int>(0, (sum, item) {
      final newsItem = Map<String, dynamic>.from(item);
      final likes = newsItem['likes'] ?? 0;
      return sum + (likes is int ? likes : int.tryParse(likes.toString()) ?? 0);
    });

    final totalComments = myNews.fold<int>(0, (sum, item) {
      final newsItem = Map<String, dynamic>.from(item);
      final comments = newsItem['comments'] ?? [];
      return sum + (comments is List ? comments.length : 0);
    });

    return {
      'posts': myNews.length,
      'likes': totalLikes,
      'comments': totalComments,
    };
  }

  // Виджет поля поиска для AppBar
  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск в профиле...',
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final userStats = _getUserStats(newsProvider.news);
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          child: Column(
            children: [
              // AppBar КАК В CHANNEL DETAIL PAGE
              _buildAppBar(horizontalPadding),

              // Основной контент
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ОБЛОЖКА С АВАТАРКОЙ
                    SliverToBoxAdapter(
                      child: _buildCoverWithAvatar(context, userStats, horizontalPadding),
                    ),

                    // КОНТЕНТ ПРОФИЛЯ
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: 0,
                          bottom: 16,
                        ),
                        child: Column(
                          children: [
                            // КАРТОЧКА С ОПИСАНИЕМ
                            Container(
                              constraints: BoxConstraints(maxWidth: contentMaxWidth),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _buildDescriptionCard(),
                            ),

                            const SizedBox(height: 16),

                            // СТАТИСТИКА
                            Container(
                              constraints: BoxConstraints(maxWidth: contentMaxWidth),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _buildEnhancedStatsSection(userStats),
                            ),

                            const SizedBox(height: 16),

                            // ВКЛАДКИ КОНТЕНТА
                            Container(
                              constraints: BoxConstraints(maxWidth: contentMaxWidth),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _buildContentTabs(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // КОНТЕНТ ВЫБРАННОГО РАЗДЕЛА (ПОСТЫ ИЛИ ИНФОРМАЦИЯ)
                    _buildSelectedSectionSliver(newsProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSectionSliver(NewsProvider newsProvider) {
    final myPosts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['author_name'] == widget.userName &&
          newsItem['is_repost'] != true; // Исключаем репосты из "Мои посты"
    }).toList();

    final likedPosts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['isLiked'] == true;
    }).toList();

    final repostedPosts = _getUserReposts(newsProvider.news); // Репосты пользователя

    switch (_selectedSection) {
      case 0:
        return _buildPostsSectionSliver(myPosts, newsProvider);
      case 1:
        return _buildLikedPostsSectionSliver(likedPosts, newsProvider);
      case 2: // Новая секция репостов
        return _buildRepostsSectionSliver(repostedPosts, newsProvider);
      case 3:
        return _buildInfoSectionSliver();
      default:
        return _buildPostsSectionSliver(myPosts, newsProvider);
    }
  }


  Widget _buildRepostsSectionSliver(List<dynamic> reposts, NewsProvider newsProvider) {
    if (reposts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(
            left: _getHorizontalPadding(context),
            right: _getHorizontalPadding(context),
            bottom: 16,
          ),
          constraints: BoxConstraints(maxWidth: _getContentMaxWidth(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildEmptyState(
            icon: Icons.repeat_rounded,
            title: 'Пока нет репостов',
            subtitle: 'Репостните интересные посты, чтобы они появились здесь',
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final newsItem = Map<String, dynamic>.from(reposts[index]);

          return NewsCard(
            key: ValueKey('repost-${newsItem['id']}-$index'),
            news: newsItem,
            onLike: () => _handleLike(_getSafeNewsIndex(newsItem, newsProvider), newsProvider),
            onBookmark: () => _handleBookmark(_getSafeNewsIndex(newsItem, newsProvider), newsProvider),
            onFollow: () => _handleFollow(_getSafeNewsIndex(newsItem, newsProvider), newsProvider),
            onComment: (text, userName, userAvatar) => _handleComment(
              _getSafeNewsIndex(newsItem, newsProvider),
              text,
              userName,
              userAvatar,
              newsProvider,
            ),
            onRepost: () => _handleRepost(_getSafeNewsIndex(newsItem, newsProvider), newsProvider),
            onEdit: () => _handleEdit(_getSafeNewsIndex(newsItem, newsProvider), context),
            onDelete: () => _handleDelete(_getSafeNewsIndex(newsItem, newsProvider), newsProvider),
            onShare: () => _handleShare(_getSafeNewsIndex(newsItem, newsProvider), context),
            onTagEdit: (tagId, newTagName, color) => _handleTagEdit(
              _getSafeNewsIndex(newsItem, newsProvider),
              tagId,
              newTagName,
              color,
              newsProvider,
            ),
            formatDate: formatDate,
            getTimeAgo: getTimeAgo,
            scrollController: _scrollController,
            onLogout: widget.onLogout,
          );
        },
        childCount: reposts.length,
      ),
    );
  }


  Widget _buildPostsSectionSliver(List<dynamic> posts, NewsProvider newsProvider) {
    if (posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(
            left: _getHorizontalPadding(context),
            right: _getHorizontalPadding(context),
            bottom: 16,
          ),
          constraints: BoxConstraints(maxWidth: _getContentMaxWidth(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildEmptyState(
            icon: Icons.article_outlined,
            title: 'Пока нет постов',
            subtitle: 'Создайте свой первый пост, чтобы он появился здесь',
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return NewsCard(
            key: ValueKey('profile-post-${posts[index]['id']}-$index'),
            news: Map<String, dynamic>.from(posts[index]),
            onLike: () => _handleLike(_getSafeNewsIndex(posts[index], newsProvider), newsProvider),
            onBookmark: () => _handleBookmark(_getSafeNewsIndex(posts[index], newsProvider), newsProvider),
            onFollow: () => _handleFollow(_getSafeNewsIndex(posts[index], newsProvider), newsProvider),
            onComment: (text, userName, userAvatar) => _handleComment(
              _getSafeNewsIndex(posts[index], newsProvider),
              text,
              userName,
              userAvatar,
              newsProvider,
            ),
            onRepost: () => _handleRepost(_getSafeNewsIndex(posts[index], newsProvider), newsProvider),
            onEdit: () => _handleEdit(_getSafeNewsIndex(posts[index], newsProvider), context),
            onDelete: () => _handleDelete(_getSafeNewsIndex(posts[index], newsProvider), newsProvider),
            onShare: () => _handleShare(_getSafeNewsIndex(posts[index], newsProvider), context),
            onTagEdit: (tagId, newTagName, color) => _handleTagEdit(
              _getSafeNewsIndex(posts[index], newsProvider),
              tagId,
              newTagName,
              color,
              newsProvider,
            ),
            formatDate: formatDate,
            getTimeAgo: getTimeAgo,
            scrollController: _scrollController,
            onLogout: widget.onLogout,
          );
        },
        childCount: posts.length,
      ),
    );
  }

  Widget _buildLikedPostsSectionSliver(List<dynamic> likedPosts, NewsProvider newsProvider) {
    if (likedPosts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(
            left: _getHorizontalPadding(context),
            right: _getHorizontalPadding(context),
            bottom: 16,
          ),
          constraints: BoxConstraints(maxWidth: _getContentMaxWidth(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Пока нет лайков',
            subtitle: 'Поставьте лайки понравившимся постам, чтобы они появились здесь',
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return NewsCard(
            key: ValueKey('liked-post-${likedPosts[index]['id']}-$index'),
            news: Map<String, dynamic>.from(likedPosts[index]),
            onLike: () => _handleLike(_getSafeNewsIndex(likedPosts[index], newsProvider), newsProvider),
            onBookmark: () => _handleBookmark(_getSafeNewsIndex(likedPosts[index], newsProvider), newsProvider),
            onFollow: () => _handleFollow(_getSafeNewsIndex(likedPosts[index], newsProvider), newsProvider),
            onComment: (text, userName, userAvatar) => _handleComment(
              _getSafeNewsIndex(likedPosts[index], newsProvider),
              text,
              userName,
              userAvatar,
              newsProvider,
            ),
            onRepost: () => _handleRepost(_getSafeNewsIndex(likedPosts[index], newsProvider), newsProvider),
            onEdit: () => _handleEdit(_getSafeNewsIndex(likedPosts[index], newsProvider), context),
            onDelete: () => _handleDelete(_getSafeNewsIndex(likedPosts[index], newsProvider), newsProvider),
            onShare: () => _handleShare(_getSafeNewsIndex(likedPosts[index], newsProvider), context),
            onTagEdit: (tagId, newTagName, color) => _handleTagEdit(
              _getSafeNewsIndex(likedPosts[index], newsProvider),
              tagId,
              newTagName,
              color,
              newsProvider,
            ),
            formatDate: formatDate,
            getTimeAgo: getTimeAgo,
            scrollController: _scrollController,
            onLogout: widget.onLogout,
          );
        },
        childCount: likedPosts.length,
      ),
    );
  }

  Widget _buildInfoSectionSliver() {
    final contentMaxWidth = _getContentMaxWidth(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 16,
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildInfoSection(),
          ),
        ),
      ),
    );
  }

  // APP BAR КАК В CHANNEL DETAIL PAGE
  Widget _buildAppBar(double horizontalPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          // КНОПКА BACK СЛЕВА
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),

          // Заголовок
          if (!_showSearchBar) ...[
            const Text(
              'Профиль',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],

          // Поле поиска или кнопки
          if (_showSearchBar)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchField(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => _showSearchBar = false),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  onPressed: () => setState(() => _showSearchBar = true),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  onPressed: () => _showProfileMenu(context),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ОБЛОЖКА С АВАТАРКОЙ ВЫРОВНЕННОЙ ПО НАЗВАНИЮ
  Widget _buildCoverWithAvatar(BuildContext context, Map<String, int> stats, double horizontalPadding) {
    final coverUrl = _getUserCoverUrl();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ОБЛОЖКА С ВОЗМОЖНОСТЬЮ ИЗМЕНЕНИЯ
            GestureDetector(
              onTap: () => _showCoverPickerModal(context),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: coverUrl != null && coverUrl.isNotEmpty
                      ? DecorationImage(
                    image: coverUrl.startsWith('http')
                        ? NetworkImage(coverUrl)
                        : FileImage(File(coverUrl)) as ImageProvider,
                    fit: BoxFit.cover,
                  )
                      : null,
                  gradient: coverUrl == null || coverUrl.isEmpty
                      ? LinearGradient(
                    colors: [
                      _getUserColor(),
                      _darkenColor(_getUserColor(), 0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  // ИКОНКА РЕДАКТИРОВАНИЯ ОБЛОЖКИ
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // АВАТАРКА И ИНФОРМАЦИЯ - ВЫРОВНЕНЫ ПО ЦЕНТРУ
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // АВАТАРКА
                  GestureDetector(
                    onTap: () => _showImagePickerModal(context),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _getProfileImageWidget(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ИНФОРМАЦИЯ О ПОЛЬЗОВАТЕЛЕ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${widget.userName.toLowerCase().replaceAll(' ', '')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
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
    );
  }

  // КАРТОЧКА С ОПИСАНИЕМ
  Widget _buildDescriptionCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: _getUserColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'О пользователе',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Текст описания
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Зарегистрирован с 2024 года',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // СЕКЦИЯ СТАТИСТИКИ
  Widget _buildEnhancedStatsSection(Map<String, int> stats) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: _getUserColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Статистика профиля',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${stats['posts'] ?? 0}',
                  'Постов',
                  Icons.article_rounded,
                  _getUserColor(),
                ),
                _buildStatItem(
                  '${stats['likes'] ?? 0}',
                  'Лайков',
                  Icons.favorite_rounded,
                  _getUserColor(),
                ),
                _buildStatItem(
                  '${stats['comments'] ?? 0}',
                  'Комментариев',
                  Icons.chat_rounded,
                  _getUserColor(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ВКЛАДКИ КОНТЕНТА
  Widget _buildContentTabs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.dynamic_feed_rounded,
                color: _getUserColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Контент профиля',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Вкладки - добавьте новую вкладку "Репосты"
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildTab('Мои посты', 0),
                _buildTab('Понравилось', 1),
                _buildTab('Репосты', 2),
                _buildTab('Информация', 3),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTab(String text, int index) {
    final isActive = _selectedSection == index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? _getUserColor() : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: _getUserColor().withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _selectedSection = index);
              // При переходе на вкладку репостов обновляем данные
              if (index == 2) {
                _debugReposts();
                // Принудительно обновляем состояние
                if (mounted) setState(() {});
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }






  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildActionItem(
            'Сообщения',
            'Новых: ${widget.newMessagesCount ?? 0}',
            Icons.message_rounded,
            Colors.blue,
                () => _handleMessagesTap(context),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Настройки',
            'Внешний вид, уведомления',
            Icons.settings_rounded,
            Colors.purple,
                () => _handleSettingsTap(context),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Помощь',
            'Частые вопросы и поддержка',
            Icons.help_rounded,
            Colors.orange,
                () => _handleHelpTap(context),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'О приложении',
            'Версия 1.0.0 Beta',
            Icons.info_rounded,
            Colors.teal,
                () => _handleAboutTap(context),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.red),
              title: Text(
                'Выйти из аккаунта',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.red),
              onTap: () => _handleLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _getUserColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: _getUserColor()),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback? onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ИЗОБРАЖЕНИЙ
  String? _getUserCoverUrl() {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = _generateUserId(widget.userEmail);
    final userProfile = newsProvider.getUserProfile(userId);

    if (userProfile?.coverImageFile != null) {
      return userProfile!.coverImageFile!.path;
    } else if (userProfile?.coverImageUrl != null &&
        userProfile!.coverImageUrl!.isNotEmpty) {
      return userProfile.coverImageUrl;
    }

    // Обложка по умолчанию для этого пользователя
    return 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400';
  }

  Widget _getProfileImageWidget() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        final userId = _generateUserId(widget.userEmail);
        final userProfile = newsProvider.getUserProfile(userId);

        if (userProfile?.profileImageFile != null) {
          return Image.file(userProfile!.profileImageFile!, fit: BoxFit.cover);
        } else if (userProfile?.profileImageUrl != null &&
            userProfile!.profileImageUrl!.isNotEmpty) {
          return Image.network(
            userProfile.profileImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
          );
        } else {
          return _buildDefaultAvatar();
        }
      },
    );
  }

  Widget _buildDefaultAvatar() {
    final gradientColors = _getAvatarGradient(widget.userName);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getUserColor() {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
      Colors.teal.shade700,
    ];
    final index = widget.userName.isEmpty ? 0 : widget.userName.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  Color _darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  List<Color> _getAvatarGradient(String name) {
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];
    final index = name.isEmpty ? 0 : name.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  // МЕТОДЫ ДЛЯ РАБОТЫ С ОБЛОЖКОЙ
  Future<void> _pickCoverImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 400,
        imageQuality: 85,
      );
      if (image != null) {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        final userId = _generateUserId(widget.userEmail);

        await newsProvider.updateCoverImageFile(File(image.path));

        if (context.mounted) {
          _showSuccessSnackBar('Обложка профиля обновлена');
          Navigator.pop(context); // Закрываем модальное окно
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar('Ошибка: $e');
      }
    }
  }

  Widget _buildCoverSourceButton(BuildContext context, IconData icon, String text, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoverUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Введите ссылку на обложку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Проверка ссылки...'),
                  ],
                ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/cover.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final url = urlController.text.trim();
                if (url.isEmpty) {
                  _showErrorSnackBar('Введите ссылку');
                  return;
                }

                setState(() => isLoading = true);
                try {
                  String finalUrl = url;
                  if (!url.startsWith('http')) {
                    finalUrl = 'https://$url';
                  }

                  final newsProvider = Provider.of<NewsProvider>(context, listen: false);
                  final userId = _generateUserId(widget.userEmail);

                  await newsProvider.updateCoverImageUrl(finalUrl);

                  Navigator.pop(context); // Закрываем диалог
                  Navigator.pop(context); // Закрываем модальное окно

                  _showSuccessSnackBar('Обложка установлена!');

                } catch (e) {
                  setState(() => isLoading = false);
                  _showErrorSnackBar('Ошибка: $e');
                }
              },
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Установить'),
            ),
          ],
        ),
      ),
    );
  }

  // ОБНОВЛЕННЫЕ МЕТОДЫ ДЛЯ ВЗАИМОДЕЙСТВИЙ С ПОСТАМИ
  int _getSafeNewsIndex(dynamic newsItem, NewsProvider newsProvider) {
    final newsId = newsItem['id'].toString();
    return newsProvider.findNewsIndexById(newsId);
  }
  void _handleLike(int index, NewsProvider newsProvider) {
    if (index == -1) return;

    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final newsId = news['id'].toString();

    // Используем InteractionManager вместо прямого вызова NewsProvider
    final interactionManager = InteractionManager();
    interactionManager.toggleLike(newsId);

    _showSuccessSnackBar('Лайк обновлен');
  }







  void _handleBookmark(int index, NewsProvider newsProvider) {
    if (index == -1) return;

    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final newsId = news['id'].toString();

    // Используем InteractionManager
    final interactionManager = InteractionManager();
    interactionManager.toggleBookmark(newsId);

    final isCurrentlyBookmarked = news['isBookmarked'] ?? false;
    _showSuccessSnackBar(!isCurrentlyBookmarked ? 'Добавлено в избранное' : 'Удалено из избранного');
  }

  void _handleRepost(int index, NewsProvider newsProvider) {
    if (index == -1) return;

    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final newsId = news['id'].toString();
    final userId = _generateUserId(widget.userEmail);

    print('🔄 ProfilePage: Handling repost for post: $newsId');
    print('   User: $userId (${widget.userName})');
    print('   Current repost state: ${news['isReposted'] ?? false}');

    // Используем InteractionManager с передачей параметров пользователя
    final interactionManager = InteractionManager();
    interactionManager.toggleRepost(
      newsId,
      currentUserId: userId,
      currentUserName: widget.userName,
    );

    // Принудительно обновляем состояние
    setState(() {});

    print('✅ Repost action completed for post $newsId');
  }


  // Добавьте этот метод в _ProfilePageState для проверки
  void _checkReposts() {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = _generateUserId(widget.userEmail);

    print('🔍 Checking reposts for user: $userId');

    final allReposts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['is_repost'] == true;
    }).toList();

    print('📊 Total reposts in system: ${allReposts.length}');

    final userReposts = allReposts.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['reposted_by'] == userId;
    }).toList();

    print('👤 Reposts by current user: ${userReposts.length}');

    for (final repost in userReposts) {
      final repostItem = Map<String, dynamic>.from(repost);
      print('   - ${repostItem['id']}: ${repostItem['title']}');
    }

    // Вызываем при смене вкладки
    if (_selectedSection == 2) { // Вкладка репостов
      _checkReposts();
    }
  }


  // Добавьте этот метод в _ProfilePageState для отладки
  void _debugUserData() {
    final userId = _generateUserId(widget.userEmail);
    print('👤 Debug user data:');
    print('   Name: ${widget.userName}');
    print('   Email: ${widget.userEmail}');
    print('   Generated ID: $userId');

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final allReposts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['is_repost'] == true;
    }).toList();

    print('📊 Total reposts in system: ${allReposts.length}');
    for (final repost in allReposts) {
      final repostItem = Map<String, dynamic>.from(repost);
      print('   - ${repostItem['id']} by ${repostItem['reposted_by']} (${repostItem['reposted_by_name']})');
    }
  }
  void _handleComment(int index, String commentText, String userName, String userAvatar, NewsProvider newsProvider) {
    if (index == -1 || commentText.trim().isEmpty) return;

    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final newsId = news['id'].toString();

    // Используем InteractionManager
    final interactionManager = InteractionManager();
    interactionManager.addComment(
      postId: newsId,
      text: commentText.trim(),
      author: userName,
      authorAvatar: userAvatar,
    );

    _showSuccessSnackBar('Комментарий добавлен');
  }

  void _handleFollow(int index, NewsProvider newsProvider) {
    if (index == -1) return;

    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyFollowing = news['isFollowing'] ?? false;

    // Для канальных постов используем ChannelStateProvider
    final isChannelPost = news['is_channel_post'] == true;
    final channelId = news['channel_id']?.toString();

    if (isChannelPost && channelId != null && channelId.isNotEmpty) {
      final channelStateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
      final currentSubscribers = channelStateProvider.getSubscribers(channelId) ?? 0;
      channelStateProvider.toggleSubscription(channelId, currentSubscribers);

      final targetName = news['channel_name'] ?? 'канал';
      if (!isCurrentlyFollowing) {
        _showSuccessSnackBar('✅ Вы подписались на $targetName');
      } else {
        _showSuccessSnackBar('❌ Вы отписались от $targetName');
      }
    } else {
      // Для обычных постов используем NewsProvider
      newsProvider.updateNewsFollowStatus(index, !isCurrentlyFollowing);

      final targetName = news['author_name'] ?? 'пользователя';
      if (!isCurrentlyFollowing) {
        _showSuccessSnackBar('✅ Вы подписались на $targetName');
      } else {
        _showSuccessSnackBar('❌ Вы отписались от $targetName');
      }
    }
  }

  void _handleEdit(int index, BuildContext context) {
    if (index == -1) return;
    _showSuccessSnackBar('Редактирование поста');
  }

  void _handleDelete(int index, NewsProvider newsProvider) {
    if (index == -1) return;
    newsProvider.removeNews(index);
    _showSuccessSnackBar('Пост удален');
  }

  void _handleShare(int index, BuildContext context) {
    if (index == -1) return;
    _showSuccessSnackBar('Поделиться постом');
  }

  void _handleTagEdit(int index, String tagId, String newTagName, Color color, NewsProvider newsProvider) {
    if (index == -1) return;
    newsProvider.updateNewsUserTag(index, tagId, newTagName, color: color);
    _showSuccessSnackBar('Тег обновлен');
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                Icons.share_rounded,
                'Поделиться профилем',
                Colors.blue,
                    () {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Ссылка на профиль скопирована');
                },
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                Icons.qr_code_rounded,
                'QR-код профиля',
                Colors.green,
                    () {
                  Navigator.pop(context);
                  _showSuccessSnackBar('QR-код профиля');
                },
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                Icons.report_rounded,
                'Пожаловаться',
                Colors.orange,
                    () {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Жалоба отправлена');
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String text, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Методы для работы с изображениями профиля
  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        final userId = _generateUserId(widget.userEmail);

        await newsProvider.updateProfileImageFile(File(image.path));

        if (context.mounted) {
          _showSuccessSnackBar('Фото профиля обновлено');
          Navigator.pop(context); // Закрываем модальное окно
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar('Ошибка: $e');
      }
    }
  }



  Widget _buildImageSourceButton(BuildContext context, IconData icon, String text, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Введите ссылку на фото'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Проверка ссылки...'),
                  ],
                ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/photo.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final url = urlController.text.trim();
                if (url.isEmpty) {
                  _showErrorSnackBar('Введите ссылку');
                  return;
                }

                setState(() => isLoading = true);
                try {
                  String finalUrl = url;
                  if (!url.startsWith('http')) {
                    finalUrl = 'https://$url';
                  }

                  final newsProvider = Provider.of<NewsProvider>(context, listen: false);
                  final userId = _generateUserId(widget.userEmail);

                  await newsProvider.updateProfileImageUrl(finalUrl);

                  Navigator.pop(context); // Закрываем диалог
                  Navigator.pop(context); // Закрываем модальное окно

                  _showSuccessSnackBar('Фото установлено!');

                } catch (e) {
                  setState(() => isLoading = false);
                  _showErrorSnackBar('Ошибка: $e');
                }
              },
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Установить'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMessagesTap(BuildContext context) {
    widget.onMessagesTap?.call();
    _showSuccessSnackBar('Переход к сообщениям');
  }

  void _handleSettingsTap(BuildContext context) {
    widget.onSettingsTap?.call();
    _showSuccessSnackBar('Переход к настройкам');
  }

  void _handleHelpTap(BuildContext context) {
    widget.onHelpTap?.call();
    _showSuccessSnackBar('Переход к разделу помощи');
  }

  void _handleAboutTap(BuildContext context) {
    widget.onAboutTap?.call();
    _showSuccessSnackBar('Информация о приложении');
  }

  void _handleLogout(BuildContext context) {
    widget.onLogout();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}