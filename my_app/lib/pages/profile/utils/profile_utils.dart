import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';
import 'package:my_app/pages/news_cards/news_card.dart';
import 'package:my_app/pages/news_page/utils.dart';

class ProfileUtils {
  String generateUserId(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final userId = 'user_${cleanEmail.hashCode.abs()}';
    print('🆔 Generated User ID: $userId from email: $cleanEmail');
    return userId;
  }

  double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 16;
  }

  double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  Color getUserColor(String userName) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
      Colors.teal.shade700,
    ];
    final index = userName.isEmpty ? 0 : userName.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  Color darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  List<Color> getAvatarGradient(String name) {
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

  Map<String, int> getUserStats(List<dynamic> news, String userName) {
    final myNews = news.where((item) {
      final newsItem = Map<String, dynamic>.from(item);
      return newsItem['author_name'] == userName;
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

  List<dynamic> getUserReposts(List<dynamic> news, String userEmail) {
    final userId = generateUserId(userEmail);

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
    return reposts;
  }

  Widget buildNewsSliver({
    required BuildContext context,
    required List<dynamic> news,
    required double horizontalPadding,
    required double contentMaxWidth,
    required VoidCallback onLogout,
  }) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final newsItem = Map<String, dynamic>.from(news[index]);
          final safeIndex = _getSafeNewsIndex(newsItem, newsProvider);

          return NewsCard(
            key: ValueKey('profile-news-${newsItem['id']}-$index'),
            news: newsItem,
            onLike: () => _handleLike(safeIndex, newsProvider),
            onBookmark: () => _handleBookmark(safeIndex, newsProvider),
            onFollow: () => _handleFollow(safeIndex, newsProvider, context),
            onComment: (text, userName, userAvatar) => _handleComment(safeIndex, text, userName, userAvatar, newsProvider),
            onRepost: _handleRepost,
            onEdit: () => _handleEdit(safeIndex, context),
            onDelete: () => _handleDelete(safeIndex, newsProvider),
            onShare: () => _handleShare(safeIndex, context),
            onTagEdit: (tagId, newTagName, color) => _handleTagEdit(safeIndex, tagId, newTagName, color, newsProvider),
            formatDate: formatDate,
            getTimeAgo: getTimeAgo,
            scrollController: ScrollController(),
            onLogout: onLogout,
          );
        },
        childCount: news.length,
      ),
    );
  }

  int _getSafeNewsIndex(dynamic newsItem, NewsProvider newsProvider) {
    final newsId = newsItem['id'].toString();
    return newsProvider.findNewsIndexById(newsId);
  }

  void _handleLike(int index, NewsProvider newsProvider) {
    if (index == -1) return;
    // Реализация лайка
  }

  void _handleBookmark(int index, NewsProvider newsProvider) {
    if (index == -1) return;
    // Реализация закладки
  }

  void _handleFollow(int index, NewsProvider newsProvider, BuildContext context) {
    if (index == -1) return;
    // Реализация подписки
  }

  void _handleComment(int index, String text, String userName, String userAvatar, NewsProvider newsProvider) {
    if (index == -1) return;
    // Реализация комментария
  }

  void _handleRepost() {
    // Реализация репоста
  }

  void _handleEdit(int index, BuildContext context) {
    if (index == -1) return;
    // Реализация редактирования
  }

  void _handleDelete(int index, NewsProvider newsProvider) {
    if (index == -1) return;
    // Реализация удаления
  }

  void _handleShare(int index, BuildContext context) {
    if (index == -1) return;
    // Реализация шаринга
  }

  void _handleTagEdit(int index, String tagId, String newTagName, Color color, NewsProvider newsProvider) {
    if (index == -1) return;
    // Реализация редактирования тега
  }

  String? getUserCoverUrl(BuildContext context, String userEmail) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = generateUserId(userEmail);
    final userProfile = newsProvider.getUserProfile(userId);

    if (userProfile?.coverImageFile != null) {
      return userProfile!.coverImageFile!.path;
    } else if (userProfile?.coverImageUrl != null && userProfile!.coverImageUrl!.isNotEmpty) {
      return userProfile.coverImageUrl;
    }

    return 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400';
  }

  File? getProfileImage(BuildContext context, String userEmail) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = generateUserId(userEmail);
    final userProfile = newsProvider.getUserProfile(userId);
    return userProfile?.profileImageFile;
  }

  String? getProfileImageUrl(BuildContext context, String userEmail) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userId = generateUserId(userEmail);
    final userProfile = newsProvider.getUserProfile(userId);
    return userProfile?.profileImageUrl;
  }
}