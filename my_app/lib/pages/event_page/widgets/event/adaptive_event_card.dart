import 'package:flutter/material.dart';
import '../../event_model.dart';
import '../../utils/event_utils.dart';

class AdaptiveEventCard extends StatefulWidget {
  final Event event;
  final bool isFavorite;
  final bool isAttending;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onAttend;
  final int viewCount;

  const AdaptiveEventCard({
    Key? key,
    required this.event,
    required this.isFavorite,
    required this.isAttending,
    required this.onTap,
    required this.onFavorite,
    required this.onAttend,
    required this.viewCount,
  }) : super(key: key);

  @override
  State<AdaptiveEventCard> createState() => _AdaptiveEventCardState();
}

class _AdaptiveEventCardState extends State<AdaptiveEventCard> {
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ
  Widget _buildEventImage(double height, {double? width}) {
    final imageUrl = widget.event.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildGradientBackground(height, width);
    }

    print('🖼️ Loading event image: $imageUrl');

    try {
      if (imageUrl.startsWith('http')) {
        // Для сетевых изображений
        return Image.network(
          imageUrl,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Event network image error: $error');
            return _buildGradientBackground(height, width);
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
            print('❌ Event asset image error: $error for path: $imageUrl');
            return _buildGradientBackground(height, width);
          },
        );
      }
    } catch (e) {
      print('❌ Exception loading event image: $e');
      return _buildGradientBackground(height, width);
    }
  }

  Widget _buildGradientBackground([double? height, double? width]) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.event.color.withOpacity(0.9),
            widget.event.color.withOpacity(0.7),
            widget.event.color.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isMobile(context)
        ? _buildMobileCard()
        : _buildDesktopCard();
  }

  // 📱 МОБИЛЬНАЯ ВЕРСИЯ
  Widget _buildMobileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ЛЕВАЯ ЧАСТЬ - ИЗОБРАЖЕНИЕ
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: _buildEventImage(140, width: 100),
                  ),
                ),

                // ПРАВАЯ ЧАСТЬ - КОНТЕНТ
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок и категория
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.event.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.event.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    EventUtils.getCategoryIcon(widget.event.category),
                                    size: 10,
                                    color: widget.event.color,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    _getCategoryShort(widget.event.category),
                                    style: TextStyle(
                                      color: widget.event.color,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Организатор
                        Text(
                          widget.event.organizer,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Описание
                        Expanded(
                          child: Text(
                            _getShortDescription(widget.event.description ?? 'Без описания'),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Информация и кнопки
                        Row(
                          children: [
                            // Место и время
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    Icons.location_on_outlined,
                                    widget.event.location ?? 'Место не указано',
                                    isMobile: true,
                                  ),
                                  const SizedBox(height: 2),
                                  _buildInfoRow(
                                    Icons.access_time_outlined,
                                    _formatTime(widget.event.date),
                                    isMobile: true,
                                  ),
                                ],
                              ),
                            ),

                            // Кнопки действий
                            Row(
                              children: [
                                _buildIconButton(
                                  onPressed: widget.onFavorite,
                                  icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  isActive: widget.isFavorite,
                                  activeColor: Colors.red,
                                  tooltip: 'В избранное',
                                  isMobile: true,
                                ),
                                const SizedBox(width: 6),
                                _buildMobileAttendButton(),
                              ],
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
      ),
    );
  }

  // 💻 ДЕСКТОП ВЕРСИЯ
  Widget _buildDesktopCard() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ВЕРХНЯЯ ЧАСТЬ С ИЗОБРАЖЕНИЕМ
                  Stack(
                    children: [
                      // ОСНОВНОЕ ИЗОБРАЖЕНИЕ - универсальное для локальных и сетевых
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: _buildEventImage(140),
                        ),
                      ),

                      // Затемнение снизу для лучшей читаемости текста
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
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

                      // Контент поверх изображения
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Организатор
                            Text(
                              widget.event.organizer,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Категория в левом верхнем углу
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                EventUtils.getCategoryIcon(widget.event.category),
                                size: 12,
                                color: widget.event.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getCategoryShort(widget.event.category),
                                style: TextStyle(
                                  color: widget.event.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Цена в правом верхнем углу
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.event.price == 0 ? 'БЕСПЛАТНО' : '${widget.event.price}₽',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ОСНОВНОЙ КОНТЕНТ
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Описание
                        Text(
                          widget.event.description ?? 'Без описания',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // ДЕТАЛИ
                        _buildDetailSection(),
                        const SizedBox(height: 12),

                        // ХЕШТЕГИ
                        if (widget.event.tags.isNotEmpty) ...[
                          _buildHashtags(),
                          const SizedBox(height: 12),
                        ],

                        // ФУТЕР С КНОПКАМИ И СТАТИСТИКОЙ
                        _buildFooter(),
                      ],
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

  Widget _buildDetailSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_today_outlined,
            _formatDateFull(widget.event.date),
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            Icons.access_time_outlined,
            _formatTime(widget.event.date),
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            Icons.location_on_outlined,
            widget.event.location ?? 'Место не указано',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHashtags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.event.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50]!,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue[700]!,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Статистика
        Row(
          children: [
            _buildStatItem(
              Icons.people_outline,
              '${widget.event.currentAttendees}/${widget.event.maxAttendees}',
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              Icons.visibility_outlined,
              '${_formatNumber(widget.viewCount)}',
            ),
            const Spacer(),
            if (widget.event.isOnline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50]!,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_outlined, size: 12, color: Colors.green[700]!),
                    const SizedBox(width: 4),
                    Text(
                      'ОНЛАЙН',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green[700]!,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Кнопки действий
        Row(
          children: [
            _buildIconButton(
              onPressed: widget.onFavorite,
              icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              isActive: widget.isFavorite,
              activeColor: Colors.red,
              tooltip: 'В избранное',
              isMobile: false,
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildAttendButton(isMobile: false)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required String tooltip,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? 32 : 40,
      height: isMobile ? 32 : 40,
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon,
          size: isMobile ? 16 : 18,
          color: isActive ? activeColor : Colors.grey[600],
        ),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildMobileAttendButton() {
    final isAttending = widget.isAttending;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isAttending ? Colors.green[50]! : Colors.blue[50]!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAttending ? Colors.green[100]! : Colors.blue[100]!,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAttend,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            isAttending ? Icons.check_circle_outlined : Icons.event_available_outlined,
            size: 16,
            color: isAttending ? Colors.green : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendButton({required bool isMobile}) {
    final isAttending = widget.isAttending;
    return Container(
      height: isMobile ? 32 : 40,
      decoration: BoxDecoration(
        color: isAttending ? Colors.green[50]! : Colors.blue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAttending ? Colors.green[100]! : Colors.blue,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAttend,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAttending ? Icons.check_circle_outlined : Icons.event_available_outlined,
                size: isMobile ? 14 : 16,
                color: isAttending ? Colors.green : Colors.white,
              ),
              if (!isMobile) const SizedBox(width: 6),
              if (!isMobile) Text(
                isAttending ? 'Вы участвуете' : 'Участвовать',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: isAttending ? Colors.green : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {required bool isMobile}) {
    return Row(
      children: [
        Icon(icon, size: isMobile ? 10 : 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 9 : 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // МЕТОДЫ ДЛЯ ФОРМАТИРОВАНИЯ ДАТЫ
  String _formatDay(DateTime date) {
    return date.day.toString().padLeft(2, '0');
  }

  String _formatMonthShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateFull(DateTime date) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    const months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  String _getShortDescription(String description) {
    const maxLength = 60;
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }

  String _getCategoryShort(String category) {
    final Map<String, String> categories = {
      'Концерты': 'КОНЦЕРТ',
      'Выставки': 'ВЫСТАВКА',
      'Фестивали': 'ФЕСТИВАЛЬ',
      'Образование': 'ОБУЧЕНИЕ',
      'Спорт': 'СПОРТ',
      'Театр': 'ТЕАТР',
      'Встречи': 'ВСТРЕЧА',
      'Концерт': 'КОНЦЕРТ',
      'Выставка': 'ВЫСТАВКА',
      'Вечеринка': 'ВЕЧЕРИНКА',
      'Лекция': 'ЛЕКЦИЯ',
      'Мастер-класс': 'МАСТЕР-КЛАСС',
      'Семинар': 'СЕМИНАР',
      'Митап': 'МИТАП',
      'Выпускной': 'ВЫПУСКНОЙ',
    };
    return categories[category] ?? category.toUpperCase();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}