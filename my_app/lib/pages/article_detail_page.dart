import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'articles_pages/models/article.dart';
import 'articles_pages/widgets/add_article_dialog.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  // ИСПРАВЛЕННЫЙ МЕТОД: На телефоне отступы 0, на остальных как было
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0; // Убраны отступы на телефоне
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1000;
    if (width > 1000) return 900;
    if (width > 700) return 700;
    return double.infinity;
  }

  // Адаптивные размеры как в articles_page
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

  double _getHeadingFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 22;
    if (width > 800) return 20;
    if (width > 600) return 18;
    return 16;
  }

  double _getSubheadingFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 18;
    if (width > 800) return 16;
    if (width > 600) return 14;
    return 13;
  }

  double _getQuoteFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 16;
    if (width > 800) return 15;
    if (width > 600) return 14;
    return 13;
  }

  double _getCodeFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 13;
    if (width > 800) return 12;
    if (width > 600) return 11;
    return 10;
  }

  double _getCoverHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 280;
    if (width > 800) return 280;
    if (width > 600) return 280;
    return 280; // Всегда 280px как в LeagueDetailPage
  }

  // ИСПРАВЛЕННЫЙ МЕТОД: Парсинг всех типов блоков содержания
  // ОБНОВЛЕННЫЙ МЕТОД: Парсинг всех типов блоков содержания
  List<ContentBlock> _parseContentBlocks(String content) {
    final blocks = <ContentBlock>[];
    final lines = content.split('\n\n');

    for (final line in lines) {
      if (line.startsWith('[IMAGE:')) {
        final url = line.substring(7, line.length - 1);
        blocks.add(ContentBlock(type: ContentBlockType.image, content: url));
      } else if (line.startsWith('[HEADING:')) {
        final headingText = line.substring(9, line.length - 1);
        blocks.add(ContentBlock(type: ContentBlockType.heading, content: headingText));
      } else if (line.startsWith('[SUBHEADING:')) {
        final subheadingText = line.substring(12, line.length - 1);
        blocks.add(ContentBlock(type: ContentBlockType.subheading, content: subheadingText));
      } else if (line.startsWith('[QUOTE:')) {
        final quoteText = line.substring(7, line.length - 1);
        blocks.add(ContentBlock(type: ContentBlockType.quote, content: quoteText));
      } else if (line.startsWith('[LINK:')) {
        final parts = line.substring(6, line.length - 1).split(':');
        final url = parts[0];
        final text = parts.length > 1 ? parts[1] : '';
        blocks.add(ContentBlock(type: ContentBlockType.link, content: url, extra: text));
      } else if (line.startsWith('[CODE:')) {
        final parts = line.substring(6, line.length - 1).split(':');
        final language = parts[0];
        final code = parts.length > 1 ? parts.sublist(1).join(':') : '';
        // ВОССТАНАВЛИВАЕМ ПЕРЕНОСЫ СТРОК
        final unescapedCode = code.replaceAll('\\n', '\n');
        blocks.add(ContentBlock(type: ContentBlockType.code, content: unescapedCode, extra: language));
      } else if (line.startsWith('[DIVIDER]')) {
        blocks.add(ContentBlock(type: ContentBlockType.divider, content: ''));
      } else if (line.trim().isNotEmpty) {
        blocks.add(ContentBlock(type: ContentBlockType.text, content: line));
      }
    }

    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final coverHeight = _getCoverHeight(context);
    final contentBlocks = _parseContentBlocks(article.content);
    final isMobile = MediaQuery.of(context).size.width <= 600;

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
              // AppBar как в ArticlesPage
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : horizontalPadding,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Статья',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share, color: Colors.black, size: 18),
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
                        child: const Icon(Icons.bookmark_border, color: Colors.black, size: 18),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
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
                                // ОСНОВНАЯ КАРТОЧКА СТАТЬИ БЕЗ БЕЛОГО ФОНА
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ОБЛОЖКА С ЗАКРУГЛЕНИЕМ СНИЗУ
                                    Stack(
                                      children: [
                                        // Основное изображение с отступами и закруглением
                                        Container(
                                          margin: EdgeInsets.only(
                                            bottom: 20,
                                            left: isMobile ? 0 : 16,
                                            right: isMobile ? 0 : 16,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                                            child: _buildCoverImage(article.imageUrl, coverHeight),
                                          ),
                                        ),

                                        // Контент поверх изображения
                                        Positioned(
                                          bottom: 40,
                                          left: isMobile ? 16 : 32,
                                          right: isMobile ? 16 : 32,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Эмодзи и категория
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.9),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      article.emoji,
                                                      style: const TextStyle(fontSize: 20),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.9),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      article.category.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 16),

                                              // Заголовок
                                              Text(
                                                article.title,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isMobile ? 20 : 24,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              const SizedBox(height: 12),

                                              // Автор и дата
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${article.author} • ${article.formattedDate}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // ИНФОРМАЦИЯ О СТАТЬЕ
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
                                        ),
                                        color: Colors.white,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blue.withOpacity(0.03),
                                                Colors.blue.withOpacity(0.01),
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // ЗАГОЛОВОК СЕКЦИИ
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.info_rounded,
                                                      color: Colors.blue,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Информация о статье',
                                                    style: TextStyle(
                                                      fontSize: _getTitleFontSize(context) - 4,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),

                                              // АВТОР И ВРЕМЯ
                                              _buildAuthorAndTime(context),
                                              const SizedBox(height: 20),

                                              // ПОДЗАГОЛОВОК
                                              _buildInfoItem(
                                                Icons.subtitles_rounded,
                                                'Подзаголовок',
                                                article.description,
                                                Colors.orange,
                                                context,
                                              ),
                                              const SizedBox(height: 16),

                                              // ОПИСАНИЕ
                                              _buildInfoItem(
                                                Icons.description_rounded,
                                                'Описание статьи',
                                                _getArticleDescription(article),
                                                Colors.blue,
                                                context,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // ОСНОВНОЕ СОДЕРЖАНИЕ СТАТЬИ С РАЗДЕЛАМИ
                                    _buildArticleContentWithSections(context, contentBlocks),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // СТАТИСТИКА И КНОПКИ ДЕЙСТВИЙ
                                Column(
                                  children: [
                                    // СТАТИСТИКА
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
                                        ),
                                        color: Colors.white,
                                        child: _buildStatsSection(context),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // КНОПКИ ДЕЙСТВИЙ
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                                        ),
                                        color: Colors.white,
                                        child: _buildActionButtons(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  // НОВЫЙ МЕТОД: Загрузка обложки (сетевой или локальной)
  Widget _buildCoverImage(String imageUrl, double height) {
    print('🖼️ Loading cover image: $imageUrl');

    try {
      if (imageUrl.startsWith('http')) {
        // Для сетевых изображений
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      } else {
        // Для локальных assets
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Exception loading cover image: $e');
      return _buildErrorCoverImage(height);
    }
  }

  // НОВЫЙ МЕТОД: Запасная обложка при ошибке
  Widget _buildErrorCoverImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            color: Colors.grey[500],
            size: 50,
          ),
          SizedBox(height: 12),
          Text(
            'Обложка не загружена',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Построение содержания с разделами
  Widget _buildArticleContentWithSections(BuildContext context, List<ContentBlock> contentBlocks) {
    final sections = <Widget>[];
    List<Widget> currentSectionContent = [];
    String? currentSectionTitle;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    for (final block in contentBlocks) {
      if (block.type == ContentBlockType.heading) {
        // Если есть предыдущая секция, добавляем ее
        if (currentSectionTitle != null && currentSectionContent.isNotEmpty) {
          sections.add(_buildSectionCard(currentSectionTitle, currentSectionContent, context));
          sections.add(const SizedBox(height: 16));
        }
        // Начинаем новую секцию
        currentSectionTitle = block.content;
        currentSectionContent = [];
      } else {
        // Добавляем контент в текущую секцию
        currentSectionContent.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildContentBlock(block, context),
          ),
        );
      }
    }

    // Добавляем последнюю секцию
    if (currentSectionTitle != null && currentSectionContent.isNotEmpty) {
      sections.add(_buildSectionCard(currentSectionTitle, currentSectionContent, context));
    } else if (currentSectionContent.isNotEmpty) {
      // Если нет заголовков, но есть контент
      sections.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
            ),
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withOpacity(0.03),
                    Colors.green.withOpacity(0.01),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Colors.green,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: currentSectionContent,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(children: sections);
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Создание карточки секции
  Widget _buildSectionCard(String title, List<Widget> content, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
        ),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.withOpacity(0.03),
                Colors.purple.withOpacity(0.01),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ЗАГОЛОВОК СЕКЦИИ
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.article_rounded,
                      color: Colors.purple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: _getTitleFontSize(context) - 2,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // КОНТЕНТ СЕКЦИИ - БЕЗ ДОПОЛНИТЕЛЬНЫХ ОТСТУПОВ
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: content,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // НОВЫЙ МЕТОД: Автор и время публикации
  Widget _buildAuthorAndTime(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.lightBlue],
              ),
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
                  'Опубликовано ${article.formattedDate}',
                  style: TextStyle(
                    fontSize: _getContentFontSize(context) - 2,
                    color: Colors.black87.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: Colors.white),
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

  // МЕТОД: Элемент информации
  Widget _buildInfoItem(IconData icon, String title, String content, Color color, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: _getContentFontSize(context) - 1,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: _getDescriptionFontSize(context),
              color: Colors.black87.withOpacity(0.8),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _getArticleDescription(Article article) {
    final contentBlocks = _parseContentBlocks(article.content);
    final firstTextBlock = contentBlocks.firstWhere(
          (block) => block.type == ContentBlockType.text && block.content.trim().isNotEmpty,
      orElse: () => ContentBlock(type: ContentBlockType.text, content: ''),
    );

    final description = firstTextBlock.content;
    if (description.length > 200) {
      return '${description.substring(0, 200)}...';
    }
    return description.isNotEmpty ? description : 'Статья не содержит описания.';
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Создание виджета для ВСЕХ типов блоков
  Widget _buildContentBlock(ContentBlock block, BuildContext context) {
    switch (block.type) {
      case ContentBlockType.heading:
        return _buildHeadingBlock(block.content, context);
      case ContentBlockType.subheading:
        return _buildSubheadingBlock(block.content, context);
      case ContentBlockType.text:
        return _buildTextBlock(block.content, context);
      case ContentBlockType.image:
        return _buildImageBlock(block.content, context);
      case ContentBlockType.quote:
        return _buildQuoteBlock(block.content, context);
      case ContentBlockType.link:
        return _buildLinkBlock(block.content, block.extra ?? '', context);
      case ContentBlockType.code:
        return _buildCodeBlock(block.content, block.extra ?? 'text', context);
      case ContentBlockType.divider:
        return _buildDividerBlock(context);
      default:
        return const SizedBox.shrink();
    }
  }

  // ОБНОВЛЕННЫЕ МЕТОДЫ ДЛЯ КОНТЕНТНЫХ БЛОКОВ
  Widget _buildHeadingBlock(String text, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 0 : 0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _getHeadingFontSize(context),
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          height: 1.4,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildSubheadingBlock(String text, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: isMobile ? 0 : 0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _getSubheadingFontSize(context),
          fontWeight: FontWeight.w600,
          color: Colors.black87.withOpacity(0.8),
          height: 1.4,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildTextBlock(String text, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.grey[50],
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Text(
            text,
            style: TextStyle(
              fontSize: _getContentFontSize(context),
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }

  // НОВЫЙ МЕТОД: Блок цитаты
  Widget _buildQuoteBlock(String text, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.amber.shade50,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: Colors.amber.shade400, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.format_quote, color: Colors.amber.shade600, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Цитата',
                    style: TextStyle(
                      fontSize: _getContentFontSize(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: _getQuoteFontSize(context),
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // НОВЫЙ МЕТОД: Блок ссылки
  Widget _buildLinkBlock(String url, String text, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final displayText = text.isNotEmpty ? text : url;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.indigo.shade50,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: Colors.indigo.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ссылка',
                    style: TextStyle(
                      fontSize: _getContentFontSize(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                displayText,
                style: TextStyle(
                  fontSize: _getContentFontSize(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // TODO: Открыть ссылку
                },
                child: Text(
                  url,
                  style: TextStyle(
                    fontSize: _getContentFontSize(context) - 1,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // УЛУЧШЕННЫЙ МЕТОД: Блок кода с подсветкой синтаксиса
  Widget _buildCodeBlock(String code, String language, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF1E1E1E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с языком программирования
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getLanguageColor(language),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.code,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      language.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18, color: Colors.grey),
                      onPressed: () {
                        // TODO: Копирование кода
                      },
                    ),
                  ],
                ),
              ),
              // Блок с кодом
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - (isMobile ? 32 : 64),
                    ),
                    child: SelectableText(
                      code,
                      style: TextStyle(
                        fontSize: _getCodeFontSize(context),
                        color: Colors.white,
                        fontFamily: 'RobotoMono',
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              // Подвал с информацией
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(
                      '${code.split('\n').length} строк',
                      style: TextStyle(
                        fontSize: _getCodeFontSize(context) - 1,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Нажмите для копирования',
                      style: TextStyle(
                        fontSize: _getCodeFontSize(context) - 1,
                        color: Colors.grey.shade400,
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

  // НОВЫЙ МЕТОД: Цвет для разных языков программирования
  Color _getLanguageColor(String language) {
    final lang = language.toLowerCase();
    switch (lang) {
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'javascript':
        return const Color(0xFFF7DF1E);
      case 'typescript':
        return const Color(0xFF3178C6);
      case 'python':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFFED8B00);
      case 'cpp':
      case 'c++':
        return const Color(0xFF00599C);
      case 'c':
        return const Color(0xFFA8B9CC);
      case 'c#':
        return const Color(0xFF239120);
      case 'php':
        return const Color(0xFF777BB4);
      case 'ruby':
        return const Color(0xFFCC342D);
      case 'go':
        return const Color(0xFF00ADD8);
      case 'rust':
        return const Color(0xFF000000);
      case 'swift':
        return const Color(0xFFFA7343);
      case 'kotlin':
        return const Color(0xFF7F52FF);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  // НОВЫЙ МЕТОД: Разделитель
  Widget _buildDividerBlock(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
      child: Column(
        children: [
          Divider(
            height: 1,
            thickness: 2,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Разделитель',
                style: TextStyle(
                  fontSize: _getContentFontSize(context) - 2,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ИСПРАВЛЕННЫЙ МЕТОД: Изображения внутри статьи в полный размер
  Widget _buildImageBlock(String imageUrl, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Изображение занимает всю доступную ширину
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : horizontalPadding,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
              child: _buildContentImage(imageUrl),
            ),
          ),
          const SizedBox(height: 8),
          // Подпись к изображению
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  'Изображение в статье',
                  style: TextStyle(
                    fontSize: _getContentFontSize(context) - 2,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Загрузка изображения контента в полный размер
  Widget _buildContentImage(String imageUrl) {
    print('🖼️ Loading content image: $imageUrl');

    try {
      if (imageUrl.startsWith('http')) {
        // Для сетевых изображений
        return Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Network image error: $error');
            return _buildErrorContentImage(250);
          },
        );
      } else {
        // Для локальных assets
        return Image.asset(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Asset image error: $error for path: $imageUrl');
            return _buildErrorContentImage(250);
          },
        );
      }
    } catch (e) {
      print('❌ Exception loading image: $e');
      return _buildErrorContentImage(250);
    }
  }

  // НОВЫЙ МЕТОД: Запасное изображение контента при ошибке
  Widget _buildErrorContentImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            color: Colors.grey[500],
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Изображение\nне загружено',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.remove_red_eye_rounded, 'Просмотры', article.views.toString(), Colors.blue, context),
          _buildStatItem(Icons.favorite_rounded, 'Лайки', article.likes.toString(), Colors.red, context),
          _buildStatItem(Icons.chat_bubble_rounded, 'Комментарии', '24', Colors.green, context),
          _buildStatItem(Icons.share_rounded, 'Репосты', '8', Colors.purple, context),
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
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(icon, size: 20, color: color),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}

// ОБНОВЛЕННЫЙ КЛАСС ContentBlockType с новыми типами
enum ContentBlockType {
  heading,
  subheading,
  text,
  image,
  quote,
  link,
  code,
  divider,
}

class ContentBlock {
  final ContentBlockType type;
  final String content;
  final String? extra;

  ContentBlock({
    required this.type,
    required this.content,
    this.extra,
  });
}