// widgets/prediction_league_card.dart
import 'package:flutter/material.dart';
import 'models/enums.dart';
import 'models/prediction_league.dart';

class PredictionLeagueCard extends StatefulWidget {
  final PredictionLeague league;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const PredictionLeagueCard({
    super.key,
    required this.league,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<PredictionLeagueCard> createState() => _PredictionLeagueCardState();
}

class _PredictionLeagueCardState extends State<PredictionLeagueCard> {
  bool _isBookmarked = false;
  bool _isLiked = false;
  int _likeCount = 24;
  bool _imageError = false;

  // Цвета для категорий
  final Map<String, Color> _categoryColors = {
    'Спорт': const Color(0xFF4CAF50),
    'Киберспорт': const Color(0xFF9C27B0),
    'Политика': const Color(0xFFF44336),
    'Финансы': const Color(0xFFFF9800),
    'Развлечения': const Color(0xFFE91E63),
    'Общее': const Color(0xFF607D8B),
  };

  // Цвета для уровней авторов
  Color get _levelColor {
    return widget.league.authorLevel == AuthorLevel.expert
        ? const Color(0xFFFFD700)
        : const Color(0xFF78909C);
  }

  // Иконка уровня автора
  IconData get _levelIcon {
    return widget.league.authorLevel == AuthorLevel.expert
        ? Icons.workspace_premium
        : Icons.verified;
  }

  // Текст уровня автора
  String get _levelText {
    return widget.league.authorLevel == AuthorLevel.expert
        ? 'ЭКСПЕРТ'
        : 'АВТОР';
  }

  // Получить иконку для категории
  IconData _getCategoryIcon(String category) {
    final icons = {
      'Спорт': Icons.sports_soccer,
      'Киберспорт': Icons.sports_esports,
      'Политика': Icons.policy,
      'Финансы': Icons.trending_up,
      'Развлечения': Icons.movie,
      'Общее': Icons.emoji_events,
    };
    return icons[category] ?? Icons.emoji_events;
  }

  // Форматирование времени
  String get _formattedTimeLeft {
    final now = DateTime.now();
    final difference = widget.league.endDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else {
      return '${difference.inMinutes}м';
    }
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

  // Определяем размер экрана как во втором файле
  _ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 360) return _ScreenSize.small;
    if (width <= 420) return _ScreenSize.medium;
    if (width <= 600) return _ScreenSize.large;
    return _ScreenSize.desktop;
  }

  // УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ
  Widget _buildLeagueImage(double height, {double? width}) {
    final imageUrl = widget.league.imageUrl;

    // Для отладки
    print('🖼️ Loading league image: $imageUrl');

    try {
      if (imageUrl.startsWith('http')) {
        // Для сетевых изображений
        return Image.network(
          imageUrl,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Network image error: $error');
            return _buildErrorImage(height, width);
          },
        );
      } else {
        // Для локальных assets
        return Image.asset(
          imageUrl,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Asset image error: $error for path: $imageUrl');
            return _buildErrorImage(height, width);
          },
        );
      }
    } catch (e) {
      print('❌ Exception loading image: $e');
      return _buildErrorImage(height, width);
    }
  }

  Widget _buildErrorImage(double height, [double? width]) {
    return Container(
      height: height,
      width: width ?? double.infinity,
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

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColors[widget.league.category] ?? const Color(0xFF607D8B);
    final timeLeft = widget.league.timeLeft;
    final formattedPrizePool = widget.league.formattedPrizePool;
    final screenSize = _getScreenSize(context);

    // Для десктопной версии
    if (screenSize == _ScreenSize.desktop) {
      return _buildDesktopCard(categoryColor, timeLeft, formattedPrizePool);
    }

    // Для мобильных устройств
    return _buildMobileCard(context, screenSize, categoryColor, timeLeft, formattedPrizePool);
  }

  // ВЕРСИЯ ДЛЯ МОБИЛЬНЫХ УСТРОЙСТВ
  Widget _buildMobileCard(
      BuildContext context,
      _ScreenSize screenSize,
      Color categoryColor,
      String timeLeft,
      String formattedPrizePool,
      ) {
    // Определяем размеры в зависимости от размера экрана как во втором файле
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
      margin: const EdgeInsets.only(bottom: 1), // 🆕 Тонкая линия снизу как во втором файле
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white, // 🆕 Белый фон как во втором файле
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ТОНКАЯ СЕРАЯ ЛИНИЯ СВЕРХУ как во втором файле
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: paddingValue),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

              // ОБЛОЖКА ЛИГИ
              Stack(
                children: [
                  // Используем универсальный метод для загрузки изображения
                  _buildLeagueImage(imageHeight),

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
                            _getCategoryIcon(widget.league.category),
                            size: iconSize * 0.7,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.league.category.toUpperCase(),
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

                  // Призовой фонд в правом верхнем углу
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
                        formattedPrizePool,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: buttonFontSize * 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Эмодзи и статус в нижней части обложки
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        // Эмодзи
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.league.emoji,
                            style: TextStyle(fontSize: iconSize * 0.8),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Статус лиги
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              children: [
                                Icon(
                                  widget.league.isActive ? Icons.timer : Icons.check_circle,
                                  size: iconSize * 0.7,
                                  color: widget.league.isActive ? Colors.orange : Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.league.isActive ? 'Осталось $timeLeft' : 'Завершена',
                                    style: TextStyle(
                                      fontSize: buttonFontSize * 0.8,
                                      fontWeight: FontWeight.w600,
                                      color: widget.league.isActive ? Colors.orange : Colors.green,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                      widget.league.title,
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
                      widget.league.description,
                      style: TextStyle(
                        fontSize: descriptionFontSize,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: screenSize == _ScreenSize.small ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: paddingValue),

                    // Прогресс-бар
                    Column(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Stack(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    width: constraints.maxWidth * widget.league.progress.clamp(0.0, 1.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: widget.league.isActive
                                            ? [Colors.blue.shade500, Colors.blue.shade400]
                                            : [Colors.green.shade500, Colors.green.shade400],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(widget.league.progress * 100).clamp(0.0, 100.0).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: buttonFontSize * 0.9,
                                fontWeight: FontWeight.w700,
                                color: widget.league.isActive ? Colors.blue.shade600 : Colors.green.shade600,
                              ),
                            ),
                            Text(
                              widget.league.isActive ? 'До завершения' : 'Завершена',
                              style: TextStyle(
                                fontSize: buttonFontSize * 0.9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: paddingValue),

                    // Информация об авторе и статистика в одной строке как во втором файле
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
                              widget.league.author[0].toUpperCase(),
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
                                widget.league.author,
                                style: TextStyle(
                                  fontSize: authorFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    _levelIcon,
                                    size: iconSize * 0.8,
                                    color: _levelColor,
                                  ),
                                  const SizedBox(width: 2),
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
                            ],
                          ),
                        ),

                        // Статистика как во втором файле
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: iconSize * 0.8,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatNumber(widget.league.participants),
                                  style: TextStyle(
                                    fontSize: buttonFontSize * 0.9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: iconSize * 0.8,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatNumber(widget.league.predictions),
                                  style: TextStyle(
                                    fontSize: buttonFontSize * 0.9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: paddingValue),

                    // Кнопки действий - адаптивный вариант как во втором файле
                    if (screenSize == _ScreenSize.small) ...[
                      // Для маленьких экранов - компактные кнопки
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Участие
                          Expanded(
                            child: IconButton(
                              onPressed: widget.onTap,
                              icon: Icon(
                                Icons.emoji_events_outlined,
                                size: iconSize,
                                color: Colors.orange,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),

                          const Text(
                            'Участвовать',
                            style: TextStyle(
                              color: Colors.orange,
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
                          // Участие
                          Expanded(
                            child: TextButton.icon(
                              onPressed: widget.onTap,
                              icon: Icon(
                                Icons.emoji_events_outlined,
                                size: iconSize,
                                color: Colors.orange,
                              ),
                              label: Text(
                                'Участвовать',
                                style: TextStyle(
                                  color: Colors.orange,
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

  // ВЕРСИЯ ДЛЯ КОМПЬЮТЕРА
  Widget _buildDesktopCard(
      Color categoryColor,
      String timeLeft,
      String formattedPrizePool,
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
                // ОБЛОЖКА ЛИГИ
                Stack(
                  children: [
                    // Используем универсальный метод для загрузки изображения
                    _buildLeagueImage(120),

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
                              _getCategoryIcon(widget.league.category),
                              size: 12,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.league.category.toUpperCase(),
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

                    // Призовой фонд в правом верхнем углу
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          formattedPrizePool,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Эмодзи и статус в нижней части обложки
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          // Эмодзи
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.league.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Статус лиги
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
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
                                children: [
                                  Icon(
                                    widget.league.isActive ? Icons.timer : Icons.check_circle,
                                    size: 12,
                                    color: widget.league.isActive ? Colors.orange : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.league.isActive ? 'Осталось $timeLeft' : 'Завершена',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: widget.league.isActive ? Colors.orange : Colors.green,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ОСНОВНОЙ КОНТЕНТ
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок
                      Text(
                        widget.league.title,
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
                        widget.league.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Прогресс-бар
                      Column(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOut,
                                      width: constraints.maxWidth * widget.league.progress.clamp(0.0, 1.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: widget.league.isActive
                                              ? [Colors.blue.shade500, Colors.blue.shade400]
                                              : [Colors.green.shade500, Colors.green.shade400],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(widget.league.progress * 100).clamp(0.0, 100.0).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: widget.league.isActive ? Colors.blue.shade600 : Colors.green.shade600,
                                ),
                              ),
                              Text(
                                widget.league.isActive ? 'До завершения' : 'Завершена',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Информация об авторе и статистика
                      Row(
                        children: [
                          // Аватар автора
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [categoryColor, categoryColor.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.league.author[0].toUpperCase(),
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
                                  widget.league.author,
                                  style: const TextStyle(
                                    fontSize: 12,
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
                                      size: 10,
                                      color: _levelColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      _levelText,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: _levelColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Статистика участников и прогнозов
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatNumber(widget.league.participants),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatNumber(widget.league.predictions),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
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
                            // Участие
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onTap,
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
                                          Icons.emoji_events_outlined,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Участвовать',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
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
                                        const SizedBox(width: 6),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Перечисление для размеров экрана как во втором файле
enum _ScreenSize {
  small,    // до 360px
  medium,   // 360-420px
  large,    // 420-600px
  desktop,  // больше 600px
}