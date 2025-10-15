import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onLongPress,
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

  // Цвета для категорий
  final Map<String, Color> _categoryColors = {
    'YouTube': const Color(0xFFFF6B6B),
    'Бизнес': const Color(0xFFFFA726),
    'Игры': const Color(0xFFAB47BC),
    'Программирование': const Color(0xFF42A5F5),
    'Спорт': const Color(0xFF66BB6A),
    'Общение': const Color(0xFFEC407A),
    'Общее': const Color(0xFF78909C),
  };

  // Цвета для уровней авторов
  Color get _levelColor {
    return widget.article.authorLevel == AuthorLevel.expert
        ? const Color(0xFFFFD700)
        : const Color(0xFFC0C0C0);
  }

  // Иконка уровня автора
  IconData get _levelIcon {
    return widget.article.authorLevel == AuthorLevel.expert
        ? Icons.workspace_premium
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
    final wordCount = widget.article.content.split(' ').length;
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
      'Бизнес': Icons.business,
      'Игры': Icons.sports_esports,
      'Программирование': Icons.code,
      'Спорт': Icons.sports_soccer,
      'Общение': Icons.chat,
      'Общее': Icons.article,
    };
    return icons[category] ?? Icons.article;
  }

  // Определяем размер экрана
  _ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColors[widget.article.category] ?? const Color(0xFF78909C);
    final readingTime = _getReadingTime();
    final formattedDate = _getFormattedDate();
    final screenSize = _getScreenSize(context);

    // Для десктопной версии
    if (screenSize == _ScreenSize.desktop) {
      return _buildDesktopCard(categoryColor, readingTime, formattedDate);
    }

    // Для мобильных устройств
    return _buildMobileCard(context, screenSize, categoryColor, readingTime, formattedDate);
  }

  // ВЕРСИЯ ДЛЯ МОБИЛЬНЫХ УСТРОЙСТВ
  Widget _buildMobileCard(
      BuildContext context,
      _ScreenSize screenSize,
      Color categoryColor,
      String readingTime,
      String formattedDate,
      ) {
    // Определяем размеры в зависимости от размера экрана
    final double imageHeight;
    final double titleFontSize;
    final double descriptionFontSize;
    final double authorFontSize;
    final double paddingValue;
    final double avatarSize;
    final double iconSize;
    final double buttonFontSize;

    switch (screenSize) {
      case _ScreenSize.small: // Маленькие телефоны (до 360px)
        imageHeight = 140;
        titleFontSize = 15;
        descriptionFontSize = 13;
        authorFontSize = 12;
        paddingValue = 10;
        avatarSize = 28;
        iconSize = 14;
        buttonFontSize = 12;
        break;
      case _ScreenSize.medium: // Средние телефоны (360-420px)
        imageHeight = 150;
        titleFontSize = 16;
        descriptionFontSize = 14;
        authorFontSize = 13;
        paddingValue = 12;
        avatarSize = 32;
        iconSize = 16;
        buttonFontSize = 13;
        break;
      case _ScreenSize.large: // Большие телефоны (420-600px)
        imageHeight = 160;
        titleFontSize = 17;
        descriptionFontSize = 14;
        authorFontSize = 14;
        paddingValue = 14;
        avatarSize = 36;
        iconSize = 18;
        buttonFontSize = 14;
        break;
      default:
        imageHeight = 160;
        titleFontSize = 16;
        descriptionFontSize = 14;
        authorFontSize = 13;
        paddingValue = 12;
        avatarSize = 32;
        iconSize = 16;
        buttonFontSize = 13;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ТОНКАЯ СЕРАЯ ЛИНИЯ СВЕРХУ
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: paddingValue),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

              // ОБЛОЖКА СТАТЬИ
              Stack(
                children: [
                  Container(
                    height: imageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.article.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Категория в левом верхнем углу
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
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
                          const SizedBox(width: 3),
                          Text(
                            widget.article.category.toUpperCase(),
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: buttonFontSize * 0.8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Дата в правом верхнем углу
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: buttonFontSize * 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ОСНОВНОЙ КОНТЕНТ
              Container(
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: paddingValue * 0.5),

                    // Описание
                    Text(
                      widget.article.description,
                      style: TextStyle(
                        fontSize: descriptionFontSize,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: screenSize == _ScreenSize.small ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: paddingValue),

                    // Автор и статистика в одной строке
                    Row(
                      children: [
                        // Аватар автора
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: categoryColor,
                          ),
                          child: Center(
                            child: Text(
                              widget.article.author[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: authorFontSize * 0.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: paddingValue * 0.7),

                        // Информация об авторе
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.article.author,
                                style: TextStyle(
                                  fontSize: authorFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _levelText,
                                style: TextStyle(
                                  fontSize: authorFontSize * 0.85,
                                  color: _levelColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Статистика
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: iconSize * 0.8,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatNumber(widget.article.views),
                              style: TextStyle(
                                fontSize: buttonFontSize * 0.9,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              readingTime,
                              style: TextStyle(
                                fontSize: buttonFontSize * 0.9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: paddingValue),

                    // Кнопки действий - адаптивный вариант
                    if (screenSize == _ScreenSize.small) ...[
                      // Для маленьких экранов - компактные кнопки
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Лайк
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                  _isLiked ? _likeCount++ : _likeCount--;
                                });
                              },
                              icon: Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                size: iconSize,
                                color: _isLiked ? Colors.red : Colors.grey,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),

                          // Счетчик лайков
                          Text(
                            _formatNumber(_likeCount),
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              color: _isLiked ? Colors.red : Colors.grey,
                            ),
                          ),

                          const Spacer(),

                          // Закладка
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isBookmarked = !_isBookmarked;
                                });
                              },
                              icon: Icon(
                                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                size: iconSize,
                                color: _isBookmarked ? Colors.blue : Colors.grey,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),

                          // Текст "Сохранить"
                          Text(
                            'Сохранить',
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              color: _isBookmarked ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Для средних и больших экранов - полноценные кнопки
                      Row(
                        children: [
                          // Лайк
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                  _isLiked ? _likeCount++ : _likeCount--;
                                });
                              },
                              icon: Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                size: iconSize,
                                color: _isLiked ? Colors.red : Colors.grey,
                              ),
                              label: Text(
                                _formatNumber(_likeCount),
                                style: TextStyle(
                                  color: _isLiked ? Colors.red : Colors.grey,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                          ),

                          // Закладка
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isBookmarked = !_isBookmarked;
                                });
                              },
                              icon: Icon(
                                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                size: iconSize,
                                color: _isBookmarked ? Colors.blue : Colors.grey,
                              ),
                              label: Text(
                                'Сохранить',
                                style: TextStyle(
                                  color: _isBookmarked ? Colors.blue : Colors.grey,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ВЕРСИЯ ДЛЯ КОМПЬЮТЕРА (оставлена без изменений)
  Widget _buildDesktopCard(
      Color categoryColor,
      String readingTime,
      String formattedDate,
      ) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ОБЛОЖКА СТАТЬИ
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(widget.article.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Категория в левом верхнем углу
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(widget.article.category),
                              size: 12,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.article.category.toUpperCase(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Дата в правом верхнем углу
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ОСНОВНОЙ КОНТЕНТ
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Заголовок
                        Text(
                          widget.article.title,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Описание
                        Text(
                          widget.article.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        // Информация об авторе и статистика
                        Row(
                          children: [
                            // Аватар автора
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: categoryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.article.author[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Информация об авторе
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.article.author,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        _levelIcon,
                                        size: 10,
                                        color: _levelColor,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _levelText,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: _levelColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Статистика
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      _formatNumber(widget.article.views),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  readingTime,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // КНОПКИ ДЕЙСТВИЙ
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[200]!,
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
                                            _isLiked ? Icons.favorite : Icons.favorite_border,
                                            size: 16,
                                            color: _isLiked ? Colors.red : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatNumber(_likeCount),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _isLiked ? Colors.red : Colors.grey[700],
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
                                color: Colors.grey[300],
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
                                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                            size: 16,
                                            color: _isBookmarked ? Colors.blue : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Сохранить',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _isBookmarked ? Colors.blue : Colors.grey[700],
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
  small,    // до 360px
  medium,   // 360-420px
  large,    // 420-600px
  desktop,  // больше 600px
}