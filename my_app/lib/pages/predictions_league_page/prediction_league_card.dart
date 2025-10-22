// widgets/prediction_league_card.dart
import 'package:flutter/material.dart';
import 'models/enums.dart';
import 'models/prediction_league.dart';

class PredictionLeagueCard extends StatefulWidget {
  final PredictionLeague league;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isMobile;

  const PredictionLeagueCard({
    super.key,
    required this.league,
    required this.onTap,
    this.onLongPress,
    required this.isMobile,
  });

  @override
  State<PredictionLeagueCard> createState() => _PredictionLeagueCardState();
}

class _PredictionLeagueCardState extends State<PredictionLeagueCard> {
  bool _isBookmarked = false;

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

  // Форматирование чисел для статистики
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ
  Widget _buildLeagueImage(double height, {double? width}) {
    final imageUrl = widget.league.imageUrl;

    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorImage(height, width);
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorImage(height, width);
          },
        );
      }
    } catch (e) {
      return _buildErrorImage(height, width);
    }
  }

  Widget _buildErrorImage(double height, [double? width]) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: Colors.grey[400],
            size: 40.0,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Лига прогнозов',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColors[widget.league.category] ?? const Color(0xFF607D8B);
    final formattedPrizePool = widget.league.formattedPrizePool;

    if (widget.isMobile) {
      return _buildMobileCard(categoryColor, formattedPrizePool);
    } else {
      return _buildDesktopCard(categoryColor, formattedPrizePool);
    }
  }

  // 📱 ВЕРСИЯ ДЛЯ МОБИЛЬНЫХ УСТРОЙСТВ
  Widget _buildMobileCard(
      Color categoryColor,
      String formattedPrizePool,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🖼️ ОБЛОЖКА ЛИГИ
              Stack(
                children: [
                  // Изображение лиги
                  Container(
                    height: 140.0, // Уменьшил высоту изображения
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      child: _buildLeagueImage(140.0),
                    ),
                  ),

                  // Градиентный оверлей
                  Container(
                    height: 140.0,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
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

                  // Категория в левом верхнем углу
                  Positioned(
                    top: 12.0,
                    left: 12.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(widget.league.category),
                            size: 14.0,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            widget.league.category.toUpperCase(),
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Призовой фонд в правом верхнем углу
                  Positioned(
                    top: 12.0,
                    right: 12.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.green.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        formattedPrizePool,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Эмодзи в левом нижнем углу
                  Positioned(
                    bottom: 12.0,
                    left: 12.0,
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.league.emoji,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                ],
              ),

              // 📝 ОСНОВНОЙ КОНТЕНТ
              Container(
                padding: const EdgeInsets.all(16.0), // Уменьшил отступы
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Заголовок
                    Text(
                      widget.league.title,
                      style: const TextStyle(
                        fontSize: 16.0, // Уменьшил размер шрифта
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6.0), // Уменьшил отступ

                    // Описание
                    Text(
                      widget.league.description,
                      style: TextStyle(
                        fontSize: 13.0, // Уменьшил размер шрифта
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12.0),

                    // 👤 ИНФОРМАЦИЯ ОБ АВТОРЕ И СТАТИСТИКА
                    Row(
                      children: [
                        // Аватар автора
                        Container(
                          width: 36.0, // Уменьшил размер аватара
                          height: 36.0,
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
                                blurRadius: 6.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.league.author[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0, // Уменьшил размер шрифта
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10.0), // Уменьшил отступ

                        // Информация об авторе
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.league.author,
                                style: const TextStyle(
                                  fontSize: 13.0, // Уменьшил размер шрифта
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3.0), // Уменьшил отступ
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                                decoration: BoxDecoration(
                                  color: _levelColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(
                                    color: _levelColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _levelIcon,
                                      size: 10.0, // Уменьшил размер иконки
                                      color: _levelColor,
                                    ),
                                    const SizedBox(width: 3.0),
                                    Text(
                                      _levelText,
                                      style: TextStyle(
                                        fontSize: 9.0, // Уменьшил размер шрифта
                                        fontWeight: FontWeight.w700,
                                        color: _levelColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Статистика
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStatItem(
                              Icons.people_outline,
                              _formatNumber(widget.league.participants),
                              'участников',
                              isMobile: true,
                            ),
                            const SizedBox(height: 3.0), // Уменьшил отступ
                            _buildStatItem(
                              Icons.analytics_outlined,
                              _formatNumber(widget.league.predictions),
                              'прогнозов',
                              isMobile: true,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12.0),

                    // 🎯 КНОПКИ ДЕЙСТВИЙ
                    Row(
                      children: [
                        // Участие
                        Expanded(
                          child: Container(
                            height: 40.0, // Уменьшил высоту кнопки
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange, Colors.orange.shade600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10.0), // Уменьшил радиус
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 6.0, // Уменьшил размытие
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onTap,
                                borderRadius: BorderRadius.circular(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.emoji_events_outlined,
                                      size: 16.0, // Уменьшил размер иконки
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6.0), // Уменьшил отступ
                                    Text(
                                      'Участвовать',
                                      style: const TextStyle(
                                        fontSize: 13.0, // Уменьшил размер шрифта
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10.0), // Уменьшил отступ

                        // Закладка
                        Container(
                          width: 40.0, // Уменьшил размер кнопки
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: _isBookmarked ? Colors.blue.shade50 : Colors.grey[50],
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: _isBookmarked ? Colors.blue.shade100! : Colors.grey[300]!,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isBookmarked = !_isBookmarked;
                                });
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: Icon(
                                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                size: 18.0, // Уменьшил размер иконки
                                color: _isBookmarked ? Colors.blue : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // 💻 ВЕРСИЯ ДЛЯ КОМПЬЮТЕРА
  Widget _buildDesktopCard(
      Color categoryColor,
      String formattedPrizePool,
      ) {
    return Container(
      width: 340.0, // Уменьшил ширину карточки
      margin: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 6.0, // Уменьшил тень
        borderRadius: BorderRadius.circular(20.0), // Уменьшил радиус
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), // Уменьшил прозрачность
                blurRadius: 12.0, // Уменьшил размытие
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            borderRadius: BorderRadius.circular(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🖼️ ОБЛОЖКА ЛИГИ
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Обложка
                    Container(
                      height: 160.0, // Уменьшил высоту изображения
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        child: _buildLeagueImage(160.0),
                      ),
                    ),

                    // Градиентный оверлей
                    Container(
                      height: 160.0,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.4), // Уменьшил прозрачность
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Категория
                    Positioned(
                      top: 12.0,
                      left: 12.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(widget.league.category),
                              size: 12.0, // Уменьшил размер иконки
                              color: categoryColor,
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              widget.league.category.toUpperCase(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 10.0, // Уменьшил размер шрифта
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Призовой фонд
                    Positioned(
                      top: 12.0,
                      right: 12.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          formattedPrizePool,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.0, // Уменьшил размер шрифта
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Эмодзи
                    Positioned(
                      bottom: -15.0, // Поднял выше
                      left: 15.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0), // Уменьшил отступы
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.league.emoji,
                          style: const TextStyle(fontSize: 16.0), // Уменьшил размер
                        ),
                      ),
                    ),
                  ],
                ),

                // 📝 ОСНОВНОЙ КОНТЕНТ
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 16.0), // Уменьшил отступы
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок
                      Text(
                        widget.league.title,
                        style: const TextStyle(
                          fontSize: 16.0, // Уменьшил размер шрифта
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6.0), // Уменьшил отступ

                      // Описание
                      Text(
                        widget.league.description,
                        style: TextStyle(
                          fontSize: 12.0, // Уменьшил размер шрифта
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2, // Уменьшил количество строк
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12.0),

                      // 👤 ИНФОРМАЦИЯ ОБ АВТОРЕ
                      Row(
                        children: [
                          Container(
                            width: 36.0, // Уменьшил размер аватара
                            height: 36.0,
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
                                  blurRadius: 5.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.league.author[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0, // Уменьшил размер шрифта
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0), // Уменьшил отступ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.league.author,
                                  style: const TextStyle(
                                    fontSize: 13.0, // Уменьшил размер шрифта
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3.0), // Уменьшил отступ
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                                  decoration: BoxDecoration(
                                    color: _levelColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: _levelColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _levelIcon,
                                        size: 10.0, // Уменьшил размер иконки
                                        color: _levelColor,
                                      ),
                                      const SizedBox(width: 3.0),
                                      Text(
                                        _levelText,
                                        style: TextStyle(
                                          fontSize: 9.0, // Уменьшил размер шрифта
                                          fontWeight: FontWeight.w700,
                                          color: _levelColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildStatItem(
                                Icons.people_outline,
                                _formatNumber(widget.league.participants),
                                'участников',
                                isMobile: false,
                              ),
                              const SizedBox(height: 3.0), // Уменьшил отступ
                              _buildStatItem(
                                Icons.analytics_outlined,
                                _formatNumber(widget.league.predictions),
                                'прогнозов',
                                isMobile: false,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16.0),

                      // 🎯 КНОПКИ ДЕЙСТВИЙ
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 38.0, // Уменьшил высоту кнопки
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.orange.shade600],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 5.0,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onTap,
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.emoji_events_outlined,
                                        size: 15.0, // Уменьшил размер иконки
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6.0),
                                      Text(
                                        'Участвовать',
                                        style: const TextStyle(
                                          fontSize: 12.0, // Уменьшил размер шрифта
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0), // Уменьшил отступ
                          Container(
                            width: 38.0, // Уменьшил размер кнопки
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: _isBookmarked ? Colors.blue.shade50 : Colors.grey[50],
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: _isBookmarked ? Colors.blue.shade100! : Colors.grey[300]!,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isBookmarked = !_isBookmarked;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10.0),
                                child: Icon(
                                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  size: 17.0, // Уменьшил размер иконки
                                  color: _isBookmarked ? Colors.blue : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  // 📊 ВСПОМОГАТЕЛЬНЫЙ МЕТОД ДЛЯ СТАТИСТИКИ
  Widget _buildStatItem(IconData icon, String value, String label, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile ? 12.0 : 11.0, // Уменьшил размер иконки
              color: Colors.grey[600],
            ),
            const SizedBox(width: 3.0),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 11.0 : 10.0, // Уменьшил размер шрифта
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1.0), // Уменьшил отступ
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 9.0 : 8.0, // Уменьшил размер шрифта
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}