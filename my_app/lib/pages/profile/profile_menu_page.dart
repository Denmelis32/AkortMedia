import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';
import 'package:my_app/pages/news_page/utils.dart';

// Widgets
import 'widgets/profile_app_bar.dart';
import 'widgets/profile_cover_section.dart';
import 'widgets/profile_stats_section.dart';
import 'widgets/profile_content_tabs.dart';
import 'widgets/profile_info_section.dart';
import 'widgets/profile_empty_state.dart';

// Components
import 'components/image_picker_modal.dart';
import 'components/cover_picker_modal.dart';
import 'components/profile_menu_modal.dart';

// Utils
import 'utils/profile_utils.dart';
import 'utils/profile_constants.dart';

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
  int _selectedSection = 0;

  final ProfileUtils _utils = ProfileUtils();
  final ProfileConstants _constants = ProfileConstants();

  @override
  void initState() {
    super.initState();
    _setCurrentUser();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });

    _setDefaultImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugReposts();
    });
  }

  void _debugReposts() {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = _utils.generateUserId(widget.userEmail);

    print('=== DEBUG REPOSTS ===');
    print('User ID: $userId');
    print('Total news: ${newsProvider.news.length}');

    final allReposts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['is_repost'] == true;
    }).toList();

    print('Total reposts in system: ${allReposts.length}');
    print('=== END DEBUG ===');
  }

  void _setCurrentUser() {
    final userId = _utils.generateUserId(widget.userEmail);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.setCurrentUser(userId, widget.userName, widget.userEmail);
    });
  }

  void _setDefaultImages() {
    // Логика установки изображений по умолчанию
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, int> _getUserStats(List<dynamic> news) {
    return _utils.getUserStats(news, widget.userName);
  }

  List<dynamic> _getUserReposts(List<dynamic> news) {
    return _utils.getUserReposts(news, widget.userEmail);
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ImagePickerModal(
        userEmail: widget.userEmail,
        profileImageUrl: widget.profileImageUrl,
        profileImageFile: widget.profileImageFile,
        onSuccess: (message) => _showSuccessSnackBar(message),
        onError: (error) => _showErrorSnackBar(error),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showCoverPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CoverPickerModal(
        userEmail: widget.userEmail,
        onSuccess: (message) => _showSuccessSnackBar(message),
        onError: (error) => _showErrorSnackBar(error),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileMenuModal(
        onShareProfile: () {
          Navigator.pop(context);
          _showSuccessSnackBar('Ссылка на профиль скопирована');
        },
        onShowQrCode: () {
          Navigator.pop(context);
          _showSuccessSnackBar('QR-код профиля');
        },
        onReport: () {
          Navigator.pop(context);
          _showSuccessSnackBar('Жалоба отправлена');
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final userStats = _getUserStats(newsProvider.news);
    final horizontalPadding = _utils.getHorizontalPadding(context);
    final contentMaxWidth = _utils.getContentMaxWidth(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: _constants.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              ProfileAppBar(
                showSearchBar: _showSearchBar,
                searchController: _searchController,
                onBackPressed: () => Navigator.pop(context),
                onSearchToggled: () => setState(() => _showSearchBar = !_showSearchBar),
                onProfileMenuPressed: _showProfileMenu,
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProfileCoverSection(
                        userName: widget.userName,
                        userEmail: widget.userEmail,
                        horizontalPadding: horizontalPadding,
                        onImageTap: _showImagePickerModal,
                        onCoverTap: _showCoverPickerModal,
                      ),
                    ),
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
                            _buildDescriptionCard(contentMaxWidth),
                            const SizedBox(height: 16),
                            ProfileStatsSection(
                              stats: userStats,
                              contentMaxWidth: contentMaxWidth,
                              userColor: _utils.getUserColor(widget.userName),
                            ),
                            const SizedBox(height: 16),
                            ProfileContentTabs(
                              selectedSection: _selectedSection,
                              contentMaxWidth: contentMaxWidth,
                              userColor: _utils.getUserColor(widget.userName),
                              userEmail: widget.userEmail,
                              onSectionChanged: (section) {
                                setState(() => _selectedSection = section);
                                if (section == 2) _debugReposts();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildDescriptionCard(double contentMaxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: contentMaxWidth),
      decoration: _constants.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: _utils.getUserColor(widget.userName),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
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
      ),
    );
  }

  Widget _buildSelectedSectionSliver(NewsProvider newsProvider) {
    switch (_selectedSection) {
      case 0:
        return _buildPostsSectionSliver(newsProvider);
      case 1:
        return _buildLikedPostsSectionSliver(newsProvider);
      case 2:
        return _buildRepostsSectionSliver(newsProvider);
      case 3:
        return _buildInfoSectionSliver();
      default:
        return _buildPostsSectionSliver(newsProvider);
    }
  }

  Widget _buildPostsSectionSliver(NewsProvider newsProvider) {
    final myPosts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['author_name'] == widget.userName &&
          newsItem['is_repost'] != true;
    }).toList();

    if (myPosts.isEmpty) {
      return _buildEmptyStateSliver(
        icon: Icons.article_outlined,
        title: 'Пока нет постов',
        subtitle: 'Создайте свой первый пост, чтобы он появился здесь',
      );
    }

    return _utils.buildNewsSliver(
      context: context,
      news: myPosts,
      horizontalPadding: _utils.getHorizontalPadding(context),
      contentMaxWidth: _utils.getContentMaxWidth(context),
      onLogout: widget.onLogout,
    );
  }

  Widget _buildLikedPostsSectionSliver(NewsProvider newsProvider) {
    final likedPosts = newsProvider.news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['isLiked'] == true;
    }).toList();

    if (likedPosts.isEmpty) {
      return _buildEmptyStateSliver(
        icon: Icons.favorite_border_rounded,
        title: 'Пока нет лайков',
        subtitle: 'Поставьте лайки понравившимся постам, чтобы они появились здесь',
      );
    }

    return _utils.buildNewsSliver(
      context: context,
      news: likedPosts,
      horizontalPadding: _utils.getHorizontalPadding(context),
      contentMaxWidth: _utils.getContentMaxWidth(context),
      onLogout: widget.onLogout,
    );
  }

  Widget _buildRepostsSectionSliver(NewsProvider newsProvider) {
    final repostedPosts = _getUserReposts(newsProvider.news);

    if (repostedPosts.isEmpty) {
      return _buildEmptyStateSliver(
        icon: Icons.repeat_rounded,
        title: 'Пока нет репостов',
        subtitle: 'Репостните интересные посты, чтобы они появились здесь',
      );
    }

    return _utils.buildNewsSliver(
      context: context,
      news: repostedPosts,
      horizontalPadding: _utils.getHorizontalPadding(context),
      contentMaxWidth: _utils.getContentMaxWidth(context),
      onLogout: widget.onLogout,
    );
  }

  Widget _buildInfoSectionSliver() {
    final horizontalPadding = _utils.getHorizontalPadding(context);
    final contentMaxWidth = _utils.getContentMaxWidth(context);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 16,
        ),
        child: ProfileInfoSection(
          contentMaxWidth: contentMaxWidth,
          userName: widget.userName,
          userEmail: widget.userEmail,
          newMessagesCount: widget.newMessagesCount ?? 0,
          onMessagesTap: widget.onMessagesTap,
          onSettingsTap: widget.onSettingsTap,
          onHelpTap: widget.onHelpTap,
          onAboutTap: widget.onAboutTap,
          onLogout: () => _handleLogout(context),
        ),
      ),
    );
  }

  Widget _buildEmptyStateSliver({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final horizontalPadding = _utils.getHorizontalPadding(context);
    final contentMaxWidth = _utils.getContentMaxWidth(context);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 16,
        ),
        constraints: BoxConstraints(maxWidth: contentMaxWidth),
        decoration: _constants.cardDecoration,
        child: ProfileEmptyState(
          icon: icon,
          title: title,
          subtitle: subtitle,
          userColor: _utils.getUserColor(widget.userName),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    widget.onLogout();
  }
}