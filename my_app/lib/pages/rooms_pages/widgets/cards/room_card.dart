import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../models/room.dart';


class RoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onPin;
  final VoidCallback onReport;
  final VoidCallback onQuickJoin;
  final int index;
  final bool isFeatured;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onJoin,
    required this.onEdit,
    required this.onShare,
    required this.onPin,
    required this.onReport,
    required this.onQuickJoin,
    required this.index,
    this.isFeatured = false,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _isBookmarked = false;
  bool _isQuickJoining = false;
  bool _showFullDescription = false;
  late ConfettiController _confettiController;

  // Определяем, мобильное ли устройство
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ ОТСТУПОВ - ТАКИЕ ЖЕ КАК В ARTICLES_PAGE
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0; // Для мобильных - БЕЗ БОКОВЫХ ОТСТУПОВ
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleQuickJoin() async {
    if (!_canJoin()) return;

    setState(() => _isQuickJoining = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isQuickJoining = false);
      _confettiController.play();
      widget.onQuickJoin();
    }
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
  }

  void _toggleDescription() {
    setState(() => _showFullDescription = !_showFullDescription);
  }

  bool _canJoin() {
    return widget.room.isActive &&
        widget.room.currentParticipants < widget.room.maxParticipants &&
        !widget.room.isExpired;
  }

  bool _isExpired() => widget.room.lastActivity.isBefore(
      DateTime.now().subtract(const Duration(hours: 24))
  );

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  String _getFormattedLastActivity() {
    final now = DateTime.now();
    final difference = now.difference(widget.room.lastActivity);

    if (difference.inMinutes < 1) return 'Только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин';
    if (difference.inHours < 24) return '${difference.inHours} ч';
    return '${difference.inDays} дн';
  }

  int _getViewCount() => widget.room.viewCount ?? 0;

  // ОСНОВНОЙ ВИДЖЕТ КАРТОЧКИ - БЕЗ ВНЕШНИХ ОТСТУПОВ
  Widget _buildCardContent() {
    final categoryColor = widget.room.category.color;
    final isMobile = _isMobile(context);

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 1), // ТОЛЬКО НИЖНИЙ ОТСТУП 1px МЕЖДУ КАРТОЧКАМИ
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
            onLongPress: _toggleBookmark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ЦВЕТНАЯ ЛИНИЯ СВЕРХУ - только на мобильных
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                // ОБЛОЖКА КОМНАТЫ
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: widget.room.imageUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(widget.room.imageUrl),
                          fit: BoxFit.cover,
                        )
                            : null,
                        color: categoryColor.withOpacity(0.9),
                      ),
                      child: widget.room.imageUrl.isEmpty
                          ? Center(
                        child: Icon(
                          widget.room.category.icon,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                          : null,
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
                              widget.room.category.icon,
                              size: 10,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 3),
                          ],
                        ),
                      ),
                    ),

                    // Онлайн в правом верхнем углу
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.room.currentParticipants}',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                        widget.room.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Описание
                      GestureDetector(
                        onTap: _toggleDescription,
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 400),
                          crossFadeState: _showFullDescription
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Text(
                            widget.room.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            widget.room.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Информация о комнате
                      Row(
                        children: [
                          // Иконка комнаты
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: categoryColor,
                            ),
                            child: Center(
                              child: Icon(
                                widget.room.isPrivate ? Icons.lock : Icons.public,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Информация
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.room.currentParticipants}/${widget.room.maxParticipants} участников',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.room.isPrivate ? 'Приватная' : 'Публичная',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: categoryColor,
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
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatCount(widget.room.messageCount),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getFormattedLastActivity(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Кнопки действий
                      Row(
                        children: [
                          // Присоединиться
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _canJoin() ? widget.onJoin : null,
                              icon: Icon(
                                _isQuickJoining ? Icons.hourglass_top : Icons.login,
                                size: 16,
                                color: _canJoin() ? Colors.green : Colors.grey,
                              ),
                              label: Text(
                                _isQuickJoining ? 'Вход...' : 'Присоединиться',
                                style: TextStyle(
                                  color: _canJoin() ? Colors.green : Colors.grey,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                          ),

                          // Действия
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                // Открыть меню действий
                              },
                              icon: Icon(
                                Icons.more_vert,
                                size: 16,
                                color: Colors.grey,
                              ),
                              label: Text(
                                'Еще',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
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
    } else {
      // ВЕРСИЯ ДЛЯ КОМПЬЮТЕРА
      return Container(
        margin: const EdgeInsets.all(8), // ОТСТУПЫ ДЛЯ КОМПЬЮТЕРА
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: _toggleBookmark,
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
                  // ОБЛОЖКА КОМНАТЫ
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
                          image: widget.room.imageUrl.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(widget.room.imageUrl),
                            fit: BoxFit.cover,
                          )
                              : null,
                          color: categoryColor.withOpacity(0.9),
                        ),
                        child: widget.room.imageUrl.isEmpty
                            ? Center(
                          child: Icon(
                            widget.room.category.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                            : null,
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
                                widget.room.category.icon,
                                size: 12,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),

                      // Онлайн в правом верхнем углу
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.room.currentParticipants} онлайн',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                            widget.room.title,
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
                            widget.room.description,
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

                          // Информация о комнате
                          Row(
                            children: [
                              // Иконка комнаты
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
                                  child: Icon(
                                    widget.room.isPrivate ? Icons.lock : Icons.public,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Информация
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.room.currentParticipants}/${widget.room.maxParticipants} участников',
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
                                          widget.room.isPrivate ? Icons.lock : Icons.public,
                                          size: 10,
                                          color: categoryColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          widget.room.isPrivate ? 'Приватная' : 'Публичная',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: categoryColor,
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
                                        Icons.chat_bubble_outline,
                                        size: 12,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _formatCount(widget.room.messageCount),
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
                                    _getFormattedLastActivity(),
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

                          // КНОПКА ПРИСОЕДИНЕНИЯ
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: _canJoin() ? Colors.green.withOpacity(0.1) : Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _canJoin() ? Colors.green.withOpacity(0.3) : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Присоединиться
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _canJoin() ? widget.onJoin : null,
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
                                              _isQuickJoining ? Icons.hourglass_top : Icons.login,
                                              size: 16,
                                              color: _canJoin() ? Colors.green : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _isQuickJoining ? 'Вход...' : 'Присоединиться',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _canJoin() ? Colors.green : Colors.grey[700],
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

                                // Действия
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // Открыть меню действий
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
                                              Icons.more_vert,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Еще',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
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

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);

    // ДЛЯ МОБИЛЬНЫХ - БЕЗ ОТСТУПОВ, КАК В ARTICLES_PAGE
    if (isMobile) {
      return _buildCardContent();
    }

    // ДЛЯ КОМПЬЮТЕРА - С ЦЕНТРИРОВАНИЕМ И ОГРАНИЧЕНИЕМ ШИРИНЫ
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: _buildCardContent(),
        ),
      ),
    );
  }
}