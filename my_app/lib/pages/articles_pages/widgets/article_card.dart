import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onLongPress; // Добавляем параметр onLongPress

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onLongPress, // Добавляем в конструктор
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

enum AuthorLevel {
  beginner, // Новичок - серебрянный
  expert,   // Эксперт - бриллиантовый
}

class _ArticleCardState extends State<ArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<Color?> _overlayAnimation;
  bool _isHovered = false;
  bool _isBookmarked = false;
  bool _isLiked = false;
  bool _imageError = false;
  bool _isExpanded = false;
  int _likeCount = 24;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _overlayAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white.withOpacity(0.15),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Цвета для категорий
  final Map<String, Color> _categoryColors = {
    'YouTube': const Color(0xFFFF4D4D),
    'Бизнес': const Color(0xFFFF9E40),
    'Игры': const Color(0xFFBA68C8),
    'Программирование': const Color(0xFF42A5F5),
    'Спорт': const Color(0xFF66BB6A),
    'Общение': const Color(0xFFEC407A),
    'Общее': const Color(0xFF7986CB),
  };

  // Цвета для уровней авторов
  Color get _levelColor {
    return widget.article.authorLevel == AuthorLevel.expert
        ? const Color(0xFF4FC3F7) // Бриллиантовый синий
        : const Color(0xFFB0BEC5); // Серебрянный
  }

  // Градиент для обводки в зависимости от уровня
  Gradient get _borderGradient {
    if (widget.article.authorLevel == AuthorLevel.expert) {
      // Бриллиантовый градиент - более выраженный
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4FC3F7).withOpacity(0.9),
          const Color(0xFF29B6F6).withOpacity(0.9),
          const Color(0xFF03A9F4).withOpacity(0.9),
          const Color(0xFFFFFFFF).withOpacity(0.9), // Бриллиантовый блеск
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    } else {
      // Серебрянный градиент - более выраженный
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFCFD8DC).withOpacity(0.9),
          const Color(0xFFB0BEC5).withOpacity(0.9),
          const Color(0xFF90A4AE).withOpacity(0.9),
          const Color(0xFFFFFFFF).withOpacity(0.9), // Серебрянный блеск
        ],
        stops: const [0.0, 0.4, 0.6, 1.0],
      );
    }
  }

  // Градиент для фона карточки - разноцветный
  Gradient get _cardBackgroundGradient {
    // Создаем разноцветный градиент на основе хэша названия статьи
    final hash = widget.article.title.hashCode;
    final hue1 = (hash % 360).toDouble();
    final hue2 = ((hash + 120) % 360).toDouble();
    final hue3 = ((hash + 240) % 360).toDouble();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        HSLColor.fromAHSL(1, hue1, 0.8, 0.95).toColor(),
        HSLColor.fromAHSL(1, hue2, 0.7, 0.9).toColor(),
        HSLColor.fromAHSL(1, hue3, 0.6, 0.85).toColor(),
      ],
    );
  }

  // Иконка уровня автора
  IconData get _levelIcon {
    return widget.article.authorLevel == AuthorLevel.expert
        ? Icons.diamond_rounded
        : Icons.auto_awesome_rounded;
  }

  // Текст уровня автора
  String get _levelText {
    return widget.article.authorLevel == AuthorLevel.expert
        ? 'ЭКСПЕРТ'
        : 'НОВИЧОК';
  }

  // Время чтения
  String _getReadingTime() {
    final wordCount = widget.article.content.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes мин';
  }

  // Получить иконку для категории
  IconData _getCategoryIcon(String category) {
    final icons = {
      'YouTube': Icons.play_circle_fill_rounded,
      'Бизнес': Icons.business_center_rounded,
      'Игры': Icons.sports_esports_rounded,
      'Программирование': Icons.code_rounded,
      'Спорт': Icons.sports_soccer_rounded,
      'Общение': Icons.forum_rounded,
      'Общее': Icons.article_rounded,
    };
    return icons[category] ?? Icons.article_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColors[widget.article.category] ?? const Color(0xFF7986CB);
    final readingTime = _getReadingTime();
    final levelColor = _levelColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 150), widget.onTap);
          },
          onLongPress: widget.onLongPress, // Добавляем обработчик long press
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: _borderGradient,
              boxShadow: [
                BoxShadow(
                  color: levelColor.withOpacity(_shadowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: levelColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 4,
                    offset: const Offset(0, 15),
                  ),
                // Специальные тени для экспертов
                if (widget.article.authorLevel == AuthorLevel.expert && _isHovered)
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 6,
                    offset: const Offset(0, 20),
                  ),
              ],
            ),
            child: Padding(
              // Увеличиваем толщину обводки
              padding: const EdgeInsets.all(6.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: _cardBackgroundGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Анимированная подложка при наведении
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 1.5,
                            colors: [
                              _overlayAnimation.value ?? Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Бриллиантовый эффект для экспертов
                      if (widget.article.authorLevel == AuthorLevel.expert)
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFFFFF).withOpacity(0.8),
                                  const Color(0xFF4FC3F7).withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Основной контент
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Верхняя часть с закругленной картинкой
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                            ),
                            child: ClipRRect(
                              child: Stack(
                                children: [
                                  // Изображение
                                  _imageError
                                      ? Center(
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 30,
                                      color: Colors.grey[400],
                                    ),
                                  )
                                      : Image.network(
                                    widget.article.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 180,
                                    errorBuilder: (context, error, stackTrace) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (!_imageError) {
                                          setState(() => _imageError = true);
                                        }
                                      });
                                      return Container(
                                        color: categoryColor.withOpacity(0.1),
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image_rounded,
                                            size: 24,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: categoryColor.withOpacity(0.1),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: categoryColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Градиент поверх изображения
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                          Colors.black.withOpacity(0.7),
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),

                                  // Уровень автора (левый верхний угол)
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: levelColor,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: levelColor.withOpacity(0.6),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _levelIcon,
                                            size: 14,
                                            color: levelColor,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _levelText,
                                            style: TextStyle(
                                              color: levelColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Категория (правый верхний угол)
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
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: categoryColor,
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: categoryColor.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
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
                                          const SizedBox(width: 5),
                                          Text(
                                            widget.article.category.toUpperCase(),
                                            style: TextStyle(
                                              color: categoryColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Эмодзи (правый нижний угол)
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: categoryColor,
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: categoryColor.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        widget.article.emoji,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Заголовок
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 12,
                                    child: Text(
                                      widget.article.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.2,
                                        shadows: [
                                          const Shadow(
                                            blurRadius: 8,
                                            color: Colors.black,
                                            offset: Offset(0, 1),
                                          ),
                                          Shadow(
                                            blurRadius: 15,
                                            color: categoryColor,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Основной контент с ограничением по высоте
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Кнопка "Прочитать описание"
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isExpanded = !_isExpanded;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: _isExpanded
                                              ? categoryColor.withOpacity(0.1)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: categoryColor.withOpacity(0.6),
                                            width: 1.2,
                                          ),
                                          boxShadow: _isExpanded
                                              ? [
                                            BoxShadow(
                                              color: categoryColor.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _isExpanded ? 'Скрыть описание' : 'Прочитать описание',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: categoryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            AnimatedRotation(
                                              turns: _isExpanded ? 0.5 : 0,
                                              duration: const Duration(milliseconds: 300),
                                              child: Icon(
                                                Icons.expand_more_rounded,
                                                size: 20,
                                                color: categoryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Описание (только если раскрыто)
                                    if (_isExpanded)
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: categoryColor.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.article.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[800],
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                    // Мета-информация (скрывается при раскрытом описании)
                                    if (!_isExpanded) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          // Время чтения
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: categoryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: categoryColor.withOpacity(0.4),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule_rounded,
                                                  size: 14,
                                                  color: categoryColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  readingTime,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: categoryColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Дата публикации
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: categoryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: categoryColor.withOpacity(0.4),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 12,
                                                  color: categoryColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '2 дня назад',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: categoryColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    // Информация об авторе с указанием уровня (скрывается при раскрытом описании)
                                    if (!_isExpanded) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: levelColor.withOpacity(0.4),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: levelColor.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Аватар автора с индикатором уровня
                                            Stack(
                                              children: [
                                                Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: categoryColor,
                                                    border: Border.all(
                                                      color: levelColor.withOpacity(0.8),
                                                      width: 2,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: levelColor.withOpacity(0.3),
                                                        blurRadius: 6,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      widget.article.author[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Индикатор уровня (маленький значок в углу)
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color: levelColor,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      _levelIcon,
                                                      size: 8,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 12),

                                            // Информация об авторе
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.article.author,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w800,
                                                      color: levelColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Акорт Медиа',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: levelColor.withOpacity(0.8),
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        Icons.verified_rounded,
                                                        size: 12,
                                                        color: levelColor,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    // Действия и статистика (скрывается при раскрытом описании)
                                    if (!_isExpanded) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: levelColor.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            // Лайки
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _isLiked = !_isLiked;
                                                      _isLiked ? _likeCount++ : _likeCount--;
                                                    });
                                                  },
                                                  icon: AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    child: Icon(
                                                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                      key: ValueKey<bool>(_isLiked),
                                                      color: _isLiked ? Colors.red : levelColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  iconSize: 20,
                                                ),
                                                Text(
                                                  '$_likeCount',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: levelColor,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Комментарии
                                            Column(
                                              children: [
                                                Icon(
                                                  Icons.comment_rounded,
                                                  size: 20,
                                                  color: levelColor,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '18',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: levelColor,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Закладка
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _isBookmarked = !_isBookmarked;
                                                    });
                                                  },
                                                  icon: AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    child: Icon(
                                                      _isBookmarked
                                                          ? Icons.bookmark_rounded
                                                          : Icons.bookmark_border_rounded,
                                                      key: ValueKey<bool>(_isBookmarked),
                                                      color: levelColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  iconSize: 20,
                                                ),
                                                Text(
                                                  'Сохранить',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: levelColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
        ),
      ),
    );
  }
}