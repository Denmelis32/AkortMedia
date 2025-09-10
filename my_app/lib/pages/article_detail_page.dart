// lib/pages/article_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'articles_page.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Аппбар с изображением
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.7),
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withOpacity(0.8),
                      colorScheme.primaryContainer.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    article.emoji,
                    style: TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareArticle(context), // Передаем context
              ),
              IconButton(
                icon: Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () => _bookmarkArticle(context), // Передаем context
              ),
            ],
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и метаданные
                  _buildArticleHeader(),

                  const SizedBox(height: 24),

                  // Контент статьи
                  _buildArticleContent(),

                  const SizedBox(height: 32),

                  // Статистика и действия
                  _buildArticleStats(),

                  const SizedBox(height: 24),

                  // Кнопки действий
                  _buildActionButtons(context), // Передаем context

                  const SizedBox(height: 40),

                  // Информация об авторе
                  _buildAuthorInfo(),
                ],
              ),
            ),
          ),
        ],
      ),

      // Нижняя панель с быстрыми действиями
      bottomNavigationBar: _buildBottomAppBar(context), // Передаем context
    );
  }

  Widget _buildArticleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Категория
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Text(
            article.category,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Заголовок
        Text(
          article.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Colors.grey[900],
          ),
        ),

        const SizedBox(height: 12),

        // Описание
        Text(
          article.description,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 20),

        // Метаданные
        Row(
          children: [
            // Автор
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      article.author[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.author,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Автор статьи',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Дата публикации
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  article.formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Опубликовано',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticleContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: MarkdownBody(
        data: article.content,
        styleSheet: MarkdownStyleSheet(
          h1: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
            height: 1.5,
          ),
          h2: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
            height: 1.4,
          ),
          p: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[800],
          ),
          strong: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
          blockquote: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[700],
            backgroundColor: Colors.blue[50],
          ),
          blockquoteDecoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: Colors.blue[300]!, width: 4)),
          ),
          listBullet: TextStyle(color: Colors.blue[600]),
        ),
      ),
    );
  }

  Widget _buildArticleStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.visibility, '${article.views}', 'Просмотров'),
          _buildStatItem(Icons.favorite, '${article.likes}', 'Лайков'),
          _buildStatItem(Icons.comment, '24', 'Комментариев'),
          _buildStatItem(Icons.access_time, '5', 'мин чтения'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) { // Принимаем context
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _likeArticle(),
            icon: Icon(Icons.favorite_border, size: 20),
            label: Text('Нравится'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[50],
              foregroundColor: Colors.pink[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _commentArticle(),
            icon: Icon(Icons.comment, size: 20),
            label: Text('Комментировать'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                article.author[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.author,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Автор футбольных аналитических материалов',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Эксперт в области футбольной тактики и анализа матчей',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) { // Принимаем context
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
              onPressed: () => Navigator.pop(context), // Теперь context доступен
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.bookmark_border, color: Colors.blue[700]),
              onPressed: () => _bookmarkArticle(context), // Передаем context
            ),
            IconButton(
              icon: Icon(Icons.share, color: Colors.blue[700]),
              onPressed: () => _shareArticle(context), // Передаем context
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _subscribeToAuthor(),
              child: Text('Подписаться'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Методы действий
  void _likeArticle() {
    // Логика лайка
  }

  void _commentArticle() {
    // Логика комментария
  }

  void _shareArticle(BuildContext context) { // Принимаем context
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Поделиться статьей'),
        content: Text('Выберите способ поделиться статьей "${article.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ссылка скопирована в буфер обмена!'),
                ),
              );
            },
            child: Text('Копировать ссылку'),
          ),
        ],
      ),
    );
  }

  void _bookmarkArticle(BuildContext context) { // Принимаем context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Статья добавлена в закладки!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _subscribeToAuthor() {
    // Логика подписки на автора
  }
}