import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/news_provider.dart';
import '../../../services/api_service.dart';
import 'news_card.dart';
import 'dialogs.dart';
import 'utils.dart';

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
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _backgroundColor = const Color(0xFFF5F9FF);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _secondaryTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).loadNews();
    });
  }

  Future<void> _likeNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.likeNews(news['id'].toString());
      newsProvider.updateNewsLikes(index, news['likes'] + 1);
    } catch (e) {
      print('Error liking news: $e');
      newsProvider.updateNewsLikes(index, (news['likes'] ?? 0) + 1);
    }
  }

  Future<void> _addComment(int index, String commentText) async {
    if (commentText.trim().isEmpty) return;
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.addComment(news['id'].toString(), {
        'text': commentText.trim(),
        'author': widget.userName,
      });
      newsProvider.addCommentToNews(
        index,
        {
          'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
          'author': widget.userName,
          'text': commentText.trim(),
          'time': 'Только что',
        },
      );
    } catch (e) {
      print('Error adding comment: $e');
      newsProvider.addCommentToNews(
        index,
        {
          'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
          'author': widget.userName,
          'text': commentText.trim(),
          'time': 'Только что',
        },
      );
    }
  }

  Future<void> _addNews(String title, String description, String hashtags) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    try {
      final newNews = await ApiService.createNews({
        'title': title,
        'description': description,
        'hashtags': hashtags,
      });
      newsProvider.addNews({
        ...newNews,
        'comments': [],
      });
    } catch (e) {
      print('Error creating news: $e');
      newsProvider.addNews({
        "id": "local-${DateTime.now().millisecondsSinceEpoch}",
        "title": title,
        "description": description,
        "hashtags": hashtags,
        "likes": 0,
        "author_name": widget.userName,
        "created_at": DateTime.now().toIso8601String(),
        "comments": []
      });
    }
  }

  Future<void> _editNews(int index, String title, String description, String hashtags) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.updateNews(news['id'].toString(), {
        'title': title,
        'description': description,
        'hashtags': hashtags,
      });
      newsProvider.updateNews(
        index,
        {
          ...news,
          'title': title,
          'description': description,
          'hashtags': hashtags,
        },
      );
    } catch (e) {
      print('Error updating news: $e');
      newsProvider.updateNews(
        index,
        {
          ...news,
          'title': title,
          'description': description,
          'hashtags': hashtags,
        },
      );
    }
  }

  // ОБНОВЛЕННЫЙ МЕТОД ДЛЯ РЕДАКТИРОВАНИЯ ТЕГА
  void _editUserTag(int newsIndex, String tagId, String newTagName, Color color) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    try {
      newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color);
    } catch (e) {
      print('Error editing user tag: $e');
      newsProvider.updateNewsUserTag(newsIndex, tagId, newTagName, color);
    }
  }

  Future<void> _deleteNews(int index) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final news = newsProvider.news[index];
    try {
      await ApiService.deleteNews(news['id'].toString());
      newsProvider.removeNews(index);
    } catch (e) {
      print('Error deleting news: $e');
      newsProvider.removeNews(index);
    }
  }

  void _showEditNewsDialog(int index) {
    final news = Provider.of<NewsProvider>(context, listen: false).news[index];
    showEditNewsDialog(
      context: context,
      news: news,
      onEdit: (title, description, hashtags) => _editNews(index, title, description, hashtags),
      primaryColor: _primaryColor,
      cardColor: _cardColor,
      textColor: _textColor,
      secondaryTextColor: _secondaryTextColor,
      backgroundColor: _backgroundColor,
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDeleteConfirmationDialog(
      context: context,
      onDelete: () => _deleteNews(index),
      primaryColor: _primaryColor,
    );
  }

  void _showAddNewsDialog() {
    showAddNewsDialog(
      context: context,
      onAdd: _addNews,
      primaryColor: _primaryColor,
      cardColor: _cardColor,
      textColor: _textColor,
      secondaryTextColor: _secondaryTextColor,
      backgroundColor: _backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Новости',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: _textColor,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: _primaryColor),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundColor: _primaryColor.withOpacity(0.1),
              child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.logout, color: _primaryColor),
            onPressed: widget.onLogout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: newsProvider.isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(_primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Загрузка новостей...',
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => newsProvider.loadNews(),
        color: _primaryColor,
        backgroundColor: _cardColor,
        child: newsProvider.news.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article,
                size: 64,
                color: _primaryColor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Новостей пока нет',
                style: TextStyle(
                  fontSize: 18,
                  color: _secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Будьте первым, кто поделится новостью!',
                style: TextStyle(
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: newsProvider.news.length,
          itemBuilder: (context, index) {
            final news = newsProvider.news[index];
            return NewsCard(
              news: news,
              userName: widget.userName,
              onLike: () => _likeNews(index),
              onComment: (comment) => _addComment(index, comment),
              onEdit: () => _showEditNewsDialog(index),
              onDelete: () => _showDeleteConfirmationDialog(index),
              onTagEdit: (tagId, newTagName, color) => _editUserTag(index, tagId, newTagName, color),
              formatDate: formatDate,
              getTimeAgo: getTimeAgo,
              primaryColor: _primaryColor,
              backgroundColor: _backgroundColor,
              cardColor: _cardColor,
              textColor: _textColor,
              secondaryTextColor: _secondaryTextColor,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNewsDialog,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
        elevation: 4,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}