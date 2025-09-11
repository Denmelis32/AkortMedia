import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Градиенты для разных категорий
  Map<String, List<Color>> _categoryGradients = {
    'Тактика': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    'Аналитика': [Color(0xFF059669), Color(0xFF10B981)],
    'История': [Color(0xFFF59E0B), Color(0xFFEF4444)],
    'Трансферы': [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    'Обзоры матчей': [Color(0xFFEC4899), Color(0xFFF43F5E)],
    'Интервью': [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  };

  List<Color> _getGradientColors(String category) {
    return _categoryGradients[category] ?? [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors(widget.article.category); // Исправлено: widget.article

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
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                  blurRadius: _isHovered ? 30 : 20,
                  offset: Offset(0, _isHovered ? 12 : 8),
                  spreadRadius: _isHovered ? -5 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Фон с градиентом
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradientColors[0].withOpacity(0.95),
                          gradientColors[1].withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        backgroundBlendMode: BlendMode.overlay,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Верхняя часть с изображением
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.article.imageUrl), // Исправлено: widget.article
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Градиент поверх изображения
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),

                                // Категория и эмодзи
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Категория
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          widget.article.category.toUpperCase(), // Исправлено: widget.article
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      // Эмодзи
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          widget.article.emoji, // Исправлено: widget.article
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Нижняя часть с контентом
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Заголовок
                                  Text(
                                    widget.article.title, // Исправлено: widget.article
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 12),

                                  // Описание
                                  Text(
                                    widget.article.description, // Исправлено: widget.article
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Spacer(),

                                  // Рейтинг и статистика
                                  Row(
                                    children: [
                                      // Рейтинг звездами
                                      Row(
                                        children: List.generate(5, (index) => Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: index < 4 ? Colors.amber : Colors.white.withOpacity(0.3),
                                        )),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '4.8',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Spacer(),

                                      // Статистика
                                      Row(
                                        children: [
                                          _buildStatItem(
                                            Icons.remove_red_eye_rounded,
                                            widget.article.views.toString(), // Исправлено: widget.article
                                            Colors.white.withOpacity(0.8),
                                          ),
                                          SizedBox(width: 16),
                                          _buildStatItem(
                                            Icons.favorite_rounded,
                                            widget.article.likes.toString(), // Исправлено: widget.article
                                            Colors.white.withOpacity(0.8),
                                          ),
                                          SizedBox(width: 16),
                                          _buildStatItem(
                                            Icons.chat_bubble_rounded,
                                            '24',
                                            Colors.white.withOpacity(0.8),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Автор и дата
                                  Row(
                                    children: [
                                      // Аватар автора
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.1),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            widget.article.author[0].toUpperCase(), // Исправлено: widget.article
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.article.author, // Исправлено: widget.article
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              widget.article.formattedDate, // Исправлено: widget.article
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white.withOpacity(0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Эффект при наведении
                  if (_isHovered)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),

                  // Блестящий эффект в углу
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
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}