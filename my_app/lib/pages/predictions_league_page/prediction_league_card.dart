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

  // Форматирование призового фонда
  String get _formattedPrizePool {
    if (widget.league.prizePool >= 1000000) {
      return '\$${(widget.league.prizePool / 1000000).toStringAsFixed(1)}M';
    } else if (widget.league.prizePool >= 1000) {
      return '\$${(widget.league.prizePool / 1000).toStringAsFixed(1)}K';
    }
    return '\$${widget.league.prizePool.toStringAsFixed(0)}';
  }

  // Адаптивные методы
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getCoverHeight(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    switch (crossAxisCount) {
      case 1: return 160;
      case 2: return 140;
      case 3: return 120;
      case 4: return 110;
      default: return 140;
    }
  }

  double _getContentPadding(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
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
    final categoryColor = _categoryColors[widget.league.category] ?? const Color(0xFF607D8B);
    final timeLeft = widget.league.timeLeft;
    final formattedPrizePool = widget.league.formattedPrizePool;

    // Адаптивные размеры
    final crossAxisCount = _getCrossAxisCount(context);
    final coverHeight = _getCoverHeight(context);
    final contentPadding = _getContentPadding(context);
    final titleFontSize = _getTitleFontSize(context);
    final descriptionFontSize = _getDescriptionFontSize(context);

    return Container(
      margin: EdgeInsets.all(crossAxisCount >= 3 ? 6 : 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ОБЛОЖКА ЛИГИ
              Stack(
                children: [
                  // Основное изображение с градиентом
                  Container(
                    height: coverHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(widget.league.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
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
                        color: Colors.green.withOpacity(0.9),
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
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        // Эмодзи
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
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
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
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
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок
                      Text(
                        widget.league.title,
                        style: TextStyle(
                          fontSize: titleFontSize,
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
                          fontSize: descriptionFontSize,
                          color: Colors.grey[700],
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: crossAxisCount >= 3 ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Прогресс-бар
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: widget.league.progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.league.isActive ? Colors.blue : Colors.green,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(widget.league.progress * 100).clamp(0.0, 100.0).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                widget.league.isActive ? 'До завершения' : 'Завершена',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
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
                                widget.league.author[0].toUpperCase(),
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
                                  widget.league.author,
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

                          // Статистика участников и прогнозов
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: crossAxisCount >= 3 ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    _formatNumber(widget.league.participants),
                                    style: TextStyle(
                                      fontSize: crossAxisCount >= 3 ? 10 : 12,
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
                                    size: crossAxisCount >= 3 ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    _formatNumber(widget.league.predictions),
                                    style: TextStyle(
                                      fontSize: crossAxisCount >= 3 ? 10 : 12,
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
                            // Участие
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Обработка участия в лиге
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
                                          Icons.emoji_events_outlined,
                                          size: crossAxisCount >= 3 ? 16 : 18,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Участвовать',
                                          style: TextStyle(
                                            fontSize: crossAxisCount >= 3 ? 11 : 12,
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