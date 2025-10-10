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

  // Адаптивные методы
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1800) return 4;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 700) return 2;
    return 1;
  }

  double _getCoverHeight(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    // УМЕНЬШАЕМ ВЫСОТУ ДЛЯ ДЕСКТОПА
    switch (crossAxisCount) {
      case 1: return 160; // было 200
      case 2: return 140; // было 180
      case 3: return 120; // было 160
      case 4: return 110; // было 150
      default: return 140;
    }
  }

  double _getContentPadding(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    // МЕНЬШЕ ПАДДИНГ ДЛЯ ДЕСКТОПА
    switch (crossAxisCount) {
      case 1: return 16;
      case 2: return 14;
      case 3: return 12;
      case 4: return 10;
      default: return 14;
    }
  }

  double _getTitleFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1: return 18;
      case 2: return 16;
      case 3: return 15;
      case 4: return 14;
      default: return 16;
    }
  }

  double _getDescriptionFontSize(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1: return 14;
      case 2: return 13;
      case 3: return 12;
      case 4: return 11;
      default: return 13;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColors[widget.article.category] ?? const Color(0xFF78909C);
    final readingTime = _getReadingTime();
    final formattedDate = _getFormattedDate();

    // Адаптивные размеры
    final crossAxisCount = _getCrossAxisCount(context);
    final coverHeight = _getCoverHeight(context);
    final contentPadding = _getContentPadding(context);
    final titleFontSize = _getTitleFontSize(context);
    final descriptionFontSize = _getDescriptionFontSize(context);

    return Container(
      margin: EdgeInsets.all(crossAxisCount >= 3 ? 6 : 8), // Меньше маржин для десктопа
      constraints: BoxConstraints(
        maxHeight: crossAxisCount >= 3 ? 380 : 400, // ОГРАНИЧИВАЕМ МАКСИМАЛЬНУЮ ВЫСОТУ
      ),
      child: Card(
        elevation: crossAxisCount >= 3 ? 4 : 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ВАЖНО: предотвращаем растягивание
            children: [
              // ОБЛОЖКА СТАТЬИ
              Stack(
                children: [
                  // Основное изображение
                  Container(
                    height: coverHeight,
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

                  // Градиент поверх изображения
                  Container(
                    height: coverHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Контент поверх изображения
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Категория и дата в одной строке
                        Row(
                          children: [
                            // Категория
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(widget.article.category),
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.article.category.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Дата
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Заголовок
                        Text(
                          widget.article.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w700,
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

              // ОСНОВНОЙ КОНТЕНТ - УПРОЩЕННАЯ ВЕРСИЯ
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Описание - КОРОЧЕ ДЛЯ ДЕСКТОПА
                      Text(
                        widget.article.description,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: Colors.grey[700],
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: crossAxisCount >= 3 ? 2 : 3, // МЕНЬШЕ СТРОК НА ДЕСКТОПЕ
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Информация об авторе и статистика в КОМПАКТНОМ ВИДЕ
                      Row(
                        children: [
                          // Аватар автора
                          Container(
                            width: crossAxisCount >= 3 ? 32 : 36,
                            height: crossAxisCount >= 3 ? 32 : 36,
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: crossAxisCount >= 3 ? 12 : 14,
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
                                  style: TextStyle(
                                    fontSize: crossAxisCount >= 3 ? 12 : 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      _levelIcon,
                                      size: crossAxisCount >= 3 ? 10 : 12,
                                      color: _levelColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      _levelText,
                                      style: TextStyle(
                                        fontSize: crossAxisCount >= 3 ? 9 : 10,
                                        fontWeight: FontWeight.w600,
                                        color: _levelColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Статистика - КОМПАКТНАЯ
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: crossAxisCount >= 3 ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    _formatNumber(widget.article.views),
                                    style: TextStyle(
                                      fontSize: crossAxisCount >= 3 ? 10 : 12,
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
                                  fontSize: crossAxisCount >= 3 ? 9 : 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // КНОПКИ ДЕЙСТВИЙ - КОМПАКТНЫЕ
                      Container(
                        height: crossAxisCount >= 3 ? 36 : 40,
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
                                          size: crossAxisCount >= 3 ? 16 : 18,
                                          color: _isLiked ? Colors.red : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatNumber(_likeCount),
                                          style: TextStyle(
                                            fontSize: crossAxisCount >= 3 ? 11 : 12,
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
                                          size: crossAxisCount >= 3 ? 16 : 18,
                                          color: _isBookmarked ? Colors.blue : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Сохранить',
                                          style: TextStyle(
                                            fontSize: crossAxisCount >= 3 ? 11 : 12,
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
    );
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
}