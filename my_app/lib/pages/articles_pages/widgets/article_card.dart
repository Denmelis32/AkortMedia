import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double cardPadding;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onLongPress,
    this.cardPadding = 20,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

enum AuthorLevel {
  beginner,
  expert,
}

class _ArticleCardState extends State<ArticleCard> {
  bool _isBookmarked = false;
  bool _isLiked = false;
  bool _imageError = false;
  int _likeCount = 24;

  // Современная палитра цветов
  final Map<String, Color> _categoryColors = {
    'YouTube': const Color(0xFFFF6B6B),
    'Бизнес': const Color(0xFF4ECDC4),
    'Игры': const Color(0xFF9B59B6),
    'Программирование': const Color(0xFF3498DB),
    'Спорт': const Color(0xFF1ABC9C),
    'Общение': const Color(0xFFFF9FF3),
    'Общее': const Color(0xFF95A5A6),
  };

  // Градиенты для карточек
  final List<LinearGradient> _cardGradients = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        const Color(0xFFFAFBFF),
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        const Color(0xFFF8F9FF),
      ],
    ),
  ];

  // Цвета для уровней авторов
  Color get _levelColor {
    return widget.article.authorLevel == AuthorLevel.expert
        ? const Color(0xFFFFD700)
        : const Color(0xFF3498DB);
  }

  // Иконка уровня автора
  IconData get _levelIcon {
    return widget.article.authorLevel == AuthorLevel.expert
        ? Icons.verified
        : Icons.person;
  }

  // Текст уровня автора
  String get _levelText {
    return widget.article.authorLevel == AuthorLevel.expert
        ? 'ЭКСПЕРТ'
        : 'АВТОР';
  }

  // Время чтения
  String _getReadingTime() {
    final wordCount = widget.article.content
        .split(' ')
        .length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes мин';
  }

  // Форматирование даты
  String _getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(widget.article.publishDate);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} мес.';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} дн.';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч.';
    } else {
      return 'Сейчас';
    }
  }

  // Получить иконку для категории
  IconData _getCategoryIcon(String category) {
    final icons = {
      'YouTube': Icons.play_circle_filled,
      'Бизнес': Icons.business_center,
      'Игры': Icons.sports_esports,
      'Программирование': Icons.code,
      'Спорт': Icons.fitness_center,
      'Общение': Icons.chat,
      'Общее': Icons.article,
    };
    return icons[category] ?? Icons.article;
  }

  // Определяем размер экрана
  _ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    if (width <= 360) return _ScreenSize.small;
    if (width <= 420) return _ScreenSize.medium;
    if (width <= 600) return _ScreenSize.large;
    return _ScreenSize.desktop;
  }

  // Форматирование чисел для статистики
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Метод для загрузки изображения
  Widget _buildArticleImage(double height) {
    final imageUrl = widget.article.imageUrl;

    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingImage(height);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorImage(height);
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorImage(height);
          },
        );
      }
    } catch (e) {
      return _buildErrorImage(height);
    }
  }

  Widget _buildLoadingImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5F5F5),
            const Color(0xFFEEEEEE),
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F9FA),
            const Color(0xFFE9ECEF),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            color: Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Нет изображения',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColors[widget.article.category] ??
        const Color(0xFF3498DB);
    final readingTime = _getReadingTime();
    final formattedDate = _getFormattedDate();
    final screenSize = _getScreenSize(context);

    final gradientIndex = widget.article.category.hashCode %
        _cardGradients.length;
    final cardGradient = _cardGradients[gradientIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (availableWidth > 600) {
          return _buildDesktopCard(
            categoryColor,
            readingTime,
            formattedDate,
            cardGradient,
            availableWidth,
          );
        }

        return _buildMobileCard(
          context,
          screenSize,
          categoryColor,
          readingTime,
          formattedDate,
          cardGradient,
          availableWidth,
        );
      },
    );
  }

  // ВЕРСИЯ ДЛЯ МОБИЛЬНЫХ УСТРОЙСТВ
  Widget _buildMobileCard(BuildContext context,
      _ScreenSize screenSize,
      Color categoryColor,
      String readingTime,
      String formattedDate,
      LinearGradient cardGradient,
      double availableWidth,) {
    // Адаптивные размеры на основе доступной ширины
    final double imageHeight;
    final double titleFontSize;
    final double descriptionFontSize;
    final double authorFontSize;
    final double paddingValue;
    final double avatarSize;
    final double iconSize;

    if (availableWidth <= 360) {
      imageHeight = 140;
      titleFontSize = 16;
      descriptionFontSize = 13;
      authorFontSize = 12;
      paddingValue = 12;
      avatarSize = 32;
      iconSize = 16;
    } else if (availableWidth <= 420) {
      imageHeight = 160;
      titleFontSize = 17;
      descriptionFontSize = 14;
      authorFontSize = 13;
      paddingValue = 16;
      avatarSize = 36;
      iconSize = 18;
    } else {
      imageHeight = 180;
      titleFontSize = 18;
      descriptionFontSize = 15;
      authorFontSize = 14;
      paddingValue = 20;
      avatarSize = 40;
      iconSize = 20;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: availableWidth <= 360 ? 8 : 12,
        vertical: 6,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(20),
          splashColor: categoryColor.withOpacity(0.1),
          highlightColor: categoryColor.withOpacity(0.05),
          child: Container(
            width: double.infinity, // Занимает всю доступную ширину
            constraints: BoxConstraints(
              minHeight: 100,
              maxWidth: availableWidth,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: cardGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ОБЛОЖКА СТАТЬИ
                Stack(
                  children: [
                    // Изображение
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: _buildArticleImage(imageHeight),
                    ),

                    // Градиент поверх изображения
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),

                    // Категория
                    Positioned(
                      top: 12,
                      left: 12,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: availableWidth * 0.5,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(widget.article.category),
                                size: iconSize * 0.7,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.article.category.toUpperCase(),
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Дата
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                // ОСНОВНОЙ КОНТЕНТ
                Padding(
                  padding: EdgeInsets.all(paddingValue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Описание
                      Text(
                        widget.article.description,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: const Color(0xFF666666),
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16),

                      // Автор и статистика
                      SizedBox(
                        height: avatarSize + 8,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Аватар автора
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    categoryColor,
                                    Color.alphaBlend(
                                      categoryColor.withOpacity(0.7),
                                      const Color(0xFF1A1A1A),
                                    ),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  widget.article.author[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: avatarSize * 0.4,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Информация об авторе
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.article.author,
                                    style: TextStyle(
                                      fontSize: authorFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _levelColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _levelIcon,
                                          size: authorFontSize * 0.7,
                                          color: _levelColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _levelText,
                                          style: TextStyle(
                                            fontSize: authorFontSize * 0.7,
                                            color: _levelColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Статистика
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE9ECEF),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: iconSize * 0.6,
                                        color: const Color(0xFF6C757D),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatNumber(widget.article.views),
                                        style: TextStyle(
                                          fontSize: authorFontSize * 0.8,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    readingTime,
                                    style: TextStyle(
                                      fontSize: authorFontSize * 0.7,
                                      color: const Color(0xFF6C757D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Кнопки действий
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Лайк
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isLiked = !_isLiked;
                                      _isLiked ? _likeCount++ : _likeCount--;
                                    });
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Icon(
                                          _isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          size: iconSize * 0.8,
                                          color: _isLiked
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(0xFF6C757D),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatNumber(_likeCount),
                                          style: TextStyle(
                                            fontSize: authorFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: _isLiked
                                                ? const Color(0xFFFF6B6B)
                                                : const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Разделитель
                            Container(
                              width: 1,
                              height: 24,
                              color: const Color(0xFFE9ECEF),
                            ),

                            // Закладка
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isBookmarked = !_isBookmarked;
                                    });
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Icon(
                                          _isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_outline,
                                          size: iconSize * 0.8,
                                          color: _isBookmarked
                                              ? const Color(0xFF3498DB)
                                              : const Color(0xFF6C757D),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Сохранить',
                                          style: TextStyle(
                                            fontSize: authorFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: _isBookmarked
                                                ? const Color(0xFF3498DB)
                                                : const Color(0xFF1A1A1A),
                                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

// ПОЛНОСТЬЮ ИСПРАВЛЕННАЯ ВЕРСИЯ ДЛЯ КОМПЬЮТЕРА
  Widget _buildDesktopCard(
      Color categoryColor,
      String readingTime,
      String formattedDate,
      LinearGradient cardGradient,
      double availableWidth,
      ) {
    // АДАПТИВНАЯ ШИРИНА КАРТОЧКИ
    final double cardWidth;
    if (availableWidth > 1200) {
      cardWidth = 360.0;
    } else if (availableWidth > 800) {
      cardWidth = availableWidth * 0.28;
    } else if (availableWidth > 600) {
      cardWidth = availableWidth * 0.42;
    } else {
      cardWidth = availableWidth * 0.9;
    }

    // ФИКСИРОВАННАЯ ВЫСОТА для одинакового размера всех карточек
    final double fixedCardHeight = 460;

    return SizedBox(
      width: cardWidth,
      height: fixedCardHeight, // ФИКСИРОВАННАЯ ВЫСОТА
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(20),
          splashColor: categoryColor.withOpacity(0.1),
          hoverColor: categoryColor.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: cardGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ОБЛОЖКА СТАТЬИ - ФИКСИРОВАННАЯ ВЫСОТА
                Stack(
                  children: [
                    // Изображение
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: SizedBox(
                        height: 160, // ФИКСИРОВАННАЯ ВЫСОТА
                        width: double.infinity,
                        child: _buildArticleImage(160),
                      ),
                    ),

                    // Градиент поверх изображения
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),

                    // Категория
                    Positioned(
                      top: 12,
                      left: 12,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: cardWidth * 0.5,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(widget.article.category),
                                size: 14,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.article.category.toUpperCase(),
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Дата
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                // ОСНОВНОЙ КОНТЕНТ - ФИКСИРОВАННАЯ ВЫСОТА БЕЗ Expanded
                Container(
                  height: 300, // 460 - 160 = 300 для контента
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок - ФИКСИРОВАННАЯ ВЫСОТА
                      SizedBox(
                        height: 44, // ФИКСИРОВАННАЯ ВЫСОТА для 2 строк
                        child: Text(
                          widget.article.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Описание - ФИКСИРОВАННАЯ ВЫСОТА
                      SizedBox(
                        height: 60, // ФИКСИРОВАННАЯ ВЫСОТА для 3 строк
                        child: Text(
                          widget.article.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF666666),
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Spacer для выравнивания контента сверху
                      const Spacer(),

                      // Автор и статистика - ФИКСИРОВАННАЯ ВЫСОТА
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Аватар автора
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    categoryColor,
                                    Color.alphaBlend(
                                      categoryColor.withOpacity(0.7),
                                      const Color(0xFF1A1A1A),
                                    ),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  widget.article.author[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Информация об авторе
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.article.author,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _levelColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _levelIcon,
                                          size: 10,
                                          color: _levelColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _levelText,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _levelColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Статистика
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE9ECEF),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 12,
                                        color: const Color(0xFF6C757D),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatNumber(widget.article.views),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    readingTime,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6C757D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Кнопки действий - ФИКСИРОВАННАЯ ВЫСОТА
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Лайк
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isLiked = !_isLiked;
                                      _isLiked ? _likeCount++ : _likeCount--;
                                    });
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isLiked ? Icons.favorite : Icons.favorite_outline,
                                          size: 16,
                                          color: _isLiked ? const Color(0xFFFF6B6B) : const Color(0xFF6C757D),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatNumber(_likeCount),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _isLiked ? const Color(0xFFFF6B6B) : const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Разделитель
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE9ECEF),
                            ),

                            // Закладка
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isBookmarked = !_isBookmarked;
                                    });
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                          size: 16,
                                          color: _isBookmarked ? const Color(0xFF3498DB) : const Color(0xFF6C757D),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Сохранить',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _isBookmarked ? const Color(0xFF3498DB) : const Color(0xFF1A1A1A),
                                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Перечисление для размеров экрана
enum _ScreenSize {
  small,
  medium,
  large,
  desktop,
}