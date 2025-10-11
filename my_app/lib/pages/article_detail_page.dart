import 'package:flutter/material.dart';
import 'articles_pages/models/article.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  // АДАПТИВНЫЕ МЕТОДЫ КАК В ПЕРВОМ ФАЙЛЕ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200; // Большие экраны
    if (width > 800) return 100;  // Средние экраны
    if (width > 600) return 60;   // Планшеты
    return 16;                    // Мобильные
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 800;
    if (width > 1000) return 700;
    if (width > 700) return 600;
    return double.infinity;
  }

  // Адаптивные размеры как в первом файле
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 28;
    if (width > 800) return 26;
    if (width > 600) return 24;
    return 22;
  }

  double _getDescriptionFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 16;
    if (width > 800) return 15;
    if (width > 600) return 14;
    return 13;
  }

  double _getContentFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 15;
    if (width > 800) return 14;
    if (width > 600) return 13;
    return 12;
  }

  double _getCoverHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 280;
    if (width > 800) return 240;
    if (width > 600) return 200;
    return 180;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final coverHeight = _getCoverHeight(context);

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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar КАК В ПЕРВОМ ФАЙЛЕ - БЕЗ КАРТОЧКИ
            SliverAppBar(
              expandedHeight: 60.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 2,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                'Статья',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
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
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // Основной контент С АДАПТИВНЫМИ ОТСТУПАМИ КАК В ПЕРВОМ ФАЙЛЕ
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      children: [
                        // Карточка статьи - ДИЗАЙН КАК В ПЕРВОМ ФАЙЛЕ
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ОБЛОЖКА СТАТЬИ С ГРАДИЕНТОМ
                              Stack(
                                children: [
                                  Container(
                                    height: coverHeight,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(article.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
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
                                    ),
                                  ),

                                  // МЕТА-ИНФОРМАЦИЯ НА ОБЛОЖКЕ
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // КАТЕГОРИЯ
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                article.emoji,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                article.category,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // ЗАГОЛОВОК НА ОБЛОЖКЕ
                                        Text(
                                          article.title,
                                          style: TextStyle(
                                            fontSize: _getTitleFontSize(context) + 2,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // КОНТЕНТ СТАТЬИ
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // МЕТА-ИНФОРМАЦИЯ ПОД ОБЛОЖКОЙ
                                    _buildMetaInfo(context),
                                    const SizedBox(height: 20),

                                    // ОПИСАНИЕ СТАТЬИ
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        article.description,
                                        style: TextStyle(
                                          fontSize: _getDescriptionFontSize(context),
                                          color: Colors.black87.withOpacity(0.8),
                                          height: 1.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // РАЗДЕЛИТЕЛЬ
                                    Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.grey.withOpacity(0.2),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // СОДЕРЖАНИЕ СТАТЬИ
                                    _buildArticleContent(context),
                                    const SizedBox(height: 24),

                                    // ИНФОРМАЦИЯ ОБ АВТОРЕ - СТИЛЬ КАК В КАРТОЧКАХ КАНАЛОВ
                                    _buildAuthorSection(context),
                                    const SizedBox(height: 20),

                                    // СТАТИСТИКА - КОМПАКТНЫЙ ДИЗАЙН КАК В КАРТОЧКАХ
                                    _buildStatsSection(context),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ДОПОЛНИТЕЛЬНЫЕ ДЕЙСТВИЯ (если нужно)
                        const SizedBox(height: 16),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context) {
    return Row(
      children: [
        // АВАТАР АВТОРА КАК В КАРТОЧКАХ КАНАЛОВ
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue,
                Colors.lightBlue,
              ],
            ),
          ),
          child: Center(
            child: Text(
              article.author.isNotEmpty ? article.author[0] : 'A',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ИНФОРМАЦИЯ ОБ АВТОРЕ И ДАТЕ
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.author,
                style: TextStyle(
                  fontSize: _getContentFontSize(context),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Опубликовано ${article.formattedDate}',
                style: TextStyle(
                  fontSize: _getContentFontSize(context) - 2,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // ВРЕМЯ ЧТЕНИЯ
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${_calculateReadingTime(article.content)} мин',
                style: TextStyle(
                  fontSize: _getContentFontSize(context) - 2,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ЗАГОЛОВОК СОДЕРЖАНИЯ
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: Colors.blue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Содержание статьи',
              style: TextStyle(
                fontSize: _getTitleFontSize(context) - 4,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ТЕКСТ СТАТЬИ
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Text(
            article.content,
            style: TextStyle(
              fontSize: _getContentFontSize(context),
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // АВАТАР АВТОРА КАК В КАРТОЧКАХ КАНАЛОВ
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue,
                  Colors.lightBlue,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                article.author.isNotEmpty ? article.author[0] : 'A',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ИНФОРМАЦИЯ ОБ АВТОРЕ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'АВТОР СТАТЬИ',
                  style: TextStyle(
                    fontSize: _getContentFontSize(context) - 3,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.author,
                  style: TextStyle(
                    fontSize: _getContentFontSize(context) + 2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Эксперт в области ${article.category}',
                  style: TextStyle(
                    fontSize: _getContentFontSize(context) - 2,
                    color: Colors.black87.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // КНОПКА ПОДПИСКИ КАК В КАРТОЧКАХ КАНАЛОВ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Подписаться',
                  style: TextStyle(
                    fontSize: _getContentFontSize(context) - 2,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.remove_red_eye_rounded,
            'Просмотры',
            article.views.toString(),
            Colors.blue,
            context,
          ),
          _buildStatItem(
            Icons.favorite_rounded,
            'Лайки',
            article.likes.toString(),
            Colors.red,
            context,
          ),
          _buildStatItem(
            Icons.chat_bubble_rounded,
            'Комментарии',
            '24',
            Colors.green,
            context,
          ),
          _buildStatItem(
            Icons.share_rounded,
            'Репосты',
            '8',
            Colors.purple,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color, BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatNumber(int.tryParse(value) ?? 0),
          style: TextStyle(
            fontSize: _getContentFontSize(context),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: _getContentFontSize(context) - 3,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Нравится',
                      style: TextStyle(
                        fontSize: _getContentFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Комментировать',
                      style: TextStyle(
                        fontSize: _getContentFontSize(context),
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
    );
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ИЗ ПЕРВОГО ФАЙЛА
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  int _calculateReadingTime(String content) {
    final words = content.split(' ').length;
    final readingTime = (words / 200).ceil(); // 200 слов в минуту
    return readingTime < 1 ? 1 : readingTime;
  }
}