import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_app/pages/news_page/theme/news_theme.dart';
import 'package:my_app/providers/news_provider.dart';
import 'package:provider/provider.dart';

// Импортируем необходимые утилиты из news_page
import 'news_card.dart';
import 'utils.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  final int? newMessagesCount;
  final String? profileImageUrl;
  final File? profileImageFile;
  final Function(String?)? onProfileImageUrlChanged;
  final Function(File?)? onProfileImageFileChanged;
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
  int _selectedSection = 0; // 0 - Мои посты, 1 - Понравилось, 2 - Информация

  // ТАКИЕ ЖЕ ОТСТУПЫ КАК В КАРТОЧКАХ НОВОСТЕЙ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280; // Twitter-like для больших экранов
    if (width > 700) return 80;   // Для планшетов
    return 16;                    // Для мобильных
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;  // Twitter-like максимальная ширина
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
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

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final userStats = _getUserStats(newsProvider.news);
    final myPosts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['author_name'] == widget.userName;
    }).toList();

    final likedPosts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['isLiked'] == true;
    }).toList();

    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // ПРОЗРАЧНЫЙ ФОН
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
              // AppBar БЕЗ карточки - просто белый фон
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Профиль', // ТОЛЬКО ОДНО СЛОВО
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Карточка профиля - ТАКАЯ ЖЕ ШИРИНА КАК У КАРТОЧЕК
                      Container(
                        margin: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: 8, // Компактный отступ как в ленте
                          bottom: 16,
                        ),
                        child: _buildProfileCard(userStats, contentMaxWidth),
                      ),

                      // Кнопки выбора раздела - ТАКАЯ ЖЕ ШИРИНА
                      Container(
                        margin: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          bottom: 16,
                        ),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: _buildSectionButtons(),
                        ),
                      ),

                      // Контент выбранного раздела
                      _buildSelectedSection(myPosts, likedPosts, newsProvider, horizontalPadding, contentMaxWidth),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, int> stats, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ВЫРАВНИВАНИЕ ПО ЦЕНТРУ - аватар и информация по центру
            Column(
              crossAxisAlignment: CrossAxisAlignment.center, // ВЫРАВНИВАНИЕ ПО ЦЕНТРУ
              children: [
                _buildProfileAvatar(),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // ВЫРАВНИВАНИЕ ПО ЦЕНТРУ
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center, // ВЫРАВНИВАНИЕ ПО ЦЕНТРУ
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsRow(stats),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showImagePickerModal(context),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Редактировать профиль'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: BorderSide(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSectionButton('Мои посты', 0),
          _buildSectionButton('Понравилось', 1),
          _buildSectionButton('Информация', 2),
        ],
      ),
    );
  }

  Widget _buildSectionButton(String text, int index) {
    final isSelected = _selectedSection == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSection = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              )
                  : null,
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.blue
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSection(
      List<dynamic> myPosts,
      List<dynamic> likedPosts,
      NewsProvider newsProvider,
      double horizontalPadding,
      double contentMaxWidth,
      ) {
    switch (_selectedSection) {
      case 0:
        return _buildPostsSection(myPosts, newsProvider, horizontalPadding, contentMaxWidth);
      case 1:
        return _buildLikedPostsSection(likedPosts, newsProvider, horizontalPadding, contentMaxWidth);
      case 2:
        return _buildInfoSection(horizontalPadding, contentMaxWidth);
      default:
        return _buildPostsSection(myPosts, newsProvider, horizontalPadding, contentMaxWidth);
    }
  }

  Widget _buildPostsSection(
      List<dynamic> posts,
      NewsProvider newsProvider,
      double horizontalPadding,
      double contentMaxWidth,
      ) {
    if (posts.isEmpty) {
      return _buildEmptyState(
        horizontalPadding: horizontalPadding,
        contentMaxWidth: contentMaxWidth,
        icon: Icons.article_outlined,
        title: 'Пока нет постов',
        subtitle: 'Создайте свой первый пост, чтобы он появился здесь',
      );
    }

    return Column(
      children: [
        for (int index = 0; index < posts.length; index++)
          NewsCard(
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
          ),
      ],
    );
  }

  Widget _buildLikedPostsSection(
      List<dynamic> likedPosts,
      NewsProvider newsProvider,
      double horizontalPadding,
      double contentMaxWidth,
      ) {
    if (likedPosts.isEmpty) {
      return _buildEmptyState(
        horizontalPadding: horizontalPadding,
        contentMaxWidth: contentMaxWidth,
        icon: Icons.favorite_border_rounded,
        title: 'Пока нет лайков',
        subtitle: 'Поставьте лайки понравившимся постам, чтобы они появились здесь',
      );
    }

    return Column(
      children: [
        for (int index = 0; index < likedPosts.length; index++)
          NewsCard(
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
          ),
      ],
    );
  }

  Widget _buildInfoSection(double horizontalPadding, double contentMaxWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(
              children: [
                _buildInfoCard(
                  title: 'Действия',
                  items: [
                    _buildActionItem(
                      'Сообщения',
                      'Новых: ${widget.newMessagesCount ?? 0}',
                      Icons.message_rounded,
                      Colors.blue,
                          () => _handleMessagesTap(context),
                    ),
                    _buildActionItem(
                      'Настройки',
                      'Внешний вид, уведомления',
                      Icons.settings_rounded,
                      Colors.purple,
                          () => _handleSettingsTap(context),
                    ),
                    _buildActionItem(
                      'Помощь',
                      'Частые вопросы и поддержка',
                      Icons.help_rounded,
                      Colors.orange,
                          () => _handleHelpTap(context),
                    ),
                    _buildActionItem(
                      'О приложении',
                      'Версия 1.0.0 Beta',
                      Icons.info_rounded,
                      Colors.teal,
                          () => _handleAboutTap(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Выйти из аккаунта',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.red.withOpacity(0.6),
                    ),
                    onTap: () => _handleLogout(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required double horizontalPadding,
    required double contentMaxWidth,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        constraints: BoxConstraints(maxWidth: contentMaxWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.blue),
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
        ),
      ),
    );
  }

  // Остальные методы остаются без изменений...
  Widget _buildProfileAvatar() {
    final gradientColors = _getAvatarGradient(widget.userName);
    final hasProfileImage = widget.profileImageUrl != null || widget.profileImageFile != null;

    return GestureDetector(
      onTap: () => _showImagePickerModal(context),
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: hasProfileImage ? null : LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: _getProfileImageDecoration(),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3), // УБРАНА ЦВЕТНАЯ ЛИНИЯ - удалите эту строку если нужно убрать границу
              boxShadow: [
                BoxShadow(
                  color: (hasProfileImage ? Colors.black : gradientColors[0]).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: hasProfileImage ? null : Center(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Посты',
            stats['posts']?.toString() ?? '0',
            Icons.article_rounded,
          ),
          _buildStatItem(
            'Лайки',
            stats['likes']?.toString() ?? '0',
            Icons.favorite_rounded,
          ),
          _buildStatItem(
            'Комменты',
            stats['comments']?.toString() ?? '0',
            Icons.chat_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Действия',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          ...items,
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
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
                    const SizedBox(height: 2),
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

  int _getSafeNewsIndex(dynamic newsItem, NewsProvider newsProvider) {
    final newsId = newsItem['id'].toString();
    return newsProvider.findNewsIndexById(newsId);
  }

  void _handleLike(int index, NewsProvider newsProvider) {
    if (index == -1) return;
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyLiked = news['isLiked'] ?? false;
    final int currentLikes = news['likes'] ?? 0;
    newsProvider.updateNewsLikeStatus(
      index,
      !isCurrentlyLiked,
      isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1,
    );
  }

  void _handleBookmark(int index, NewsProvider newsProvider) {
    if (index == -1) return;
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyBookmarked = news['isBookmarked'] ?? false;
    newsProvider.updateNewsBookmarkStatus(index, !isCurrentlyBookmarked);
    _showSuccessSnackBar(!isCurrentlyBookmarked ? 'Добавлено в избранное' : 'Удалено из избранного');
  }

  void _handleFollow(int index, NewsProvider newsProvider) {
    if (index == -1) return;
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final bool isCurrentlyFollowing = news['isFollowing'] ?? false;
    newsProvider.updateNewsFollowStatus(index, !isCurrentlyFollowing);
    final isChannelPost = news['is_channel_post'] == true;
    final targetName = isChannelPost ? news['channel_name'] ?? 'канал' : news['author_name'] ?? 'пользователя';
    if (!isCurrentlyFollowing) {
      _showSuccessSnackBar('✅ Вы подписались на $targetName');
    } else {
      _showSuccessSnackBar('❌ Вы отписались от $targetName');
    }
  }

  void _handleComment(int index, String commentText, String userName, String userAvatar, NewsProvider newsProvider) {
    if (index == -1 || commentText.trim().isEmpty) return;
    final news = Map<String, dynamic>.from(newsProvider.news[index]);
    final newsId = news['id'].toString();
    try {
      final commentId = 'comment-${DateTime.now().millisecondsSinceEpoch}-${newsId}';
      final newComment = {
        'id': commentId,
        'author': userName,
        'text': commentText.trim(),
        'time': 'Только что',
        'author_avatar': userAvatar,
      };
      newsProvider.addCommentToNews(newsId, newComment);
      _showSuccessSnackBar('Комментарий добавлен');
    } catch (e) {
      print('❌ Ошибка добавления комментария в профиле: $e');
      _showErrorSnackBar('Не удалось добавить комментарий');
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

  // Методы для работы с изображениями остаются без изменений
  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null && widget.onProfileImageFileChanged != null) {
        widget.onProfileImageFileChanged!(File(image.path));
        if (widget.onProfileImageUrlChanged != null) {
          widget.onProfileImageUrlChanged!(null);
        }
        if (context.mounted) {
          _showSuccessSnackBar('Фото профиля обновлено');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar('Ошибка: $e');
      }
    }
  }

  void _showImagePickerModal(BuildContext context) {
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
                  fontWeight: FontWeight.w700,
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
                      () {
                    if (widget.onProfileImageFileChanged != null) {
                      widget.onProfileImageFileChanged!(null);
                    }
                    if (widget.onProfileImageUrlChanged != null) {
                      widget.onProfileImageUrlChanged!(null);
                    }
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Введите ссылку на фото',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/photo.jpg',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              if (!isLoading) ...[
                const SizedBox(height: 12),
                Text(
                  'Поддерживаются: JPG, PNG, WebP',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'Отмена',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final url = urlController.text.trim();
                if (url.isNotEmpty && widget.onProfileImageUrlChanged != null) {
                  setState(() => isLoading = true);
                  try {
                    String validatedUrl = url;
                    if (!url.startsWith('http')) {
                      validatedUrl = 'https://$url';
                    }
                    final testResponse = await http.get(Uri.parse(validatedUrl));
                    if (testResponse.statusCode == 200) {
                      widget.onProfileImageUrlChanged!(validatedUrl);
                      if (widget.onProfileImageFileChanged != null) {
                        widget.onProfileImageFileChanged!(null);
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                      if (context.mounted) {
                        _showSuccessSnackBar('Фото загружено по ссылке');
                      }
                    } else {
                      throw Exception('HTTP ${testResponse.statusCode}');
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    if (context.mounted) {
                      _showErrorSnackBar('Ошибка загрузки: $e');
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Загрузить',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage? _getProfileImageDecoration() {
    if (widget.profileImageFile != null) {
      return DecorationImage(
        image: FileImage(widget.profileImageFile!),
        fit: BoxFit.cover,
      );
    } else if (widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(widget.profileImageUrl!),
        fit: BoxFit.cover,
        onError: (exception, stackTrace) {
          print('❌ Error loading profile image from URL: $exception');
        },
      );
    }
    return null;
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