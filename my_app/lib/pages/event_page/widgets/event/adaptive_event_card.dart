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

  // 🖼️ УНИВЕРСАЛЬНЫЙ МЕТОД ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ
  Widget _buildEventImage(double height, {double? width}) {
    final imageUrl = widget.event.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildGradientBackground(height, width);
    }

    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildImageLoadingPlaceholder(height, width);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildGradientBackground(height, width);
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildGradientBackground(height, width);
          },
        );
      }
    } catch (e) {
      return _buildGradientBackground(height, width);
    }
  }

  Widget _buildImageLoadingPlaceholder([double? height, double? width]) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(widget.event.color),
        ),
      ),
    );
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
      child: Icon(
        EventUtils.getCategoryIcon(widget.event.category),
        size: 32,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isMobile(context)
        ? _buildMobileCard()  // 📱 Мобильная версия
        : _buildDesktopCard(context); // 💻 Десктоп версия с контекстом
  }

  // 📱 МОБИЛЬНАЯ ВЕРСИЯ - ФИКСИРОВАННАЯ КАРТОЧКА
  Widget _buildMobileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: 140, // 🎯 ФИКСИРОВАННАЯ ВЫСОТА
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🖼️ ЛЕВАЯ ЧАСТЬ - ФОТОГРАФИЯ (ФИКСИРОВАННАЯ ШИРИНА)
              Container(
                width: 120, // 🎯 УМЕНЬШЕНА ШИРИНА ДЛЯ БОЛЬШЕГО МЕСТА
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      _buildEventImage(140, width: 120),
                      // 🏷️ Категория поверх изображения
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                EventUtils.getCategoryIcon(widget.event.category),
                                size: 10.0, // 🛠️ FIX: double вместо int
                                color: widget.event.color,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _getCategoryShort(widget.event.category),
                                style: TextStyle(
                                  color: widget.event.color,
                                  fontSize: 8.0, // 🛠️ FIX: double вместо int
                                  fontWeight: FontWeight.w700,
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

              // 📝 ПРАВАЯ ЧАСТЬ - ИНФОРМАЦИЯ
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Container(
                        constraints: const BoxConstraints(maxHeight: 36),
                        child: Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 14.0, // 🛠️ FIX: double вместо int
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Организатор
                      Text(
                        widget.event.organizer,
                        style: TextStyle(
                          fontSize: 11.0, // 🛠️ FIX: double вместо int
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Описание
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 28),
                          child: Text(
                            _getShortDescription(widget.event.description ?? 'Описание отсутствует'),
                            style: TextStyle(
                              fontSize: 10.0, // 🛠️ FIX: double вместо int
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Информация и кнопки
                      Row(
                        children: [
                          // Информация о времени и месте
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  Icons.access_time_outlined,
                                  _formatTime(widget.event.date),
                                  isMobile: true,
                                ),
                                const SizedBox(height: 2),
                                _buildInfoRow(
                                  Icons.location_on_outlined,
                                  _getShortLocation(widget.event.location ?? 'Место не указано'),
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
                              const SizedBox(width: 8),
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
    );
  }

  // 💻 ДЕСКТОП ВЕРСИЯ - АДАПТИВНАЯ КАРТОЧКА
  Widget _buildDesktopCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🎯 АДАПТИВНЫЕ РАЗМЕРЫ В ЗАВИСИМОСТИ ОТ ШИРИНЫ ЭКРАНА
    final cardWidth = _getAdaptiveCardWidth(screenWidth);
    final imageWidth = _getAdaptiveImageWidth(screenWidth);
    final cardHeight = _getAdaptiveCardHeight(screenWidth);

    return Container(
      width: cardWidth, // 🎯 АДАПТИВНАЯ ШИРИНА
      height: cardHeight, // 🎯 АДАПТИВНАЯ ВЫСОТА
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🖼️ ЛЕВАЯ ЧАСТЬ - ФОТОГРАФИЯ (АДАПТИВНАЯ ШИРИНА)
                Container(
                  width: imageWidth,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        _buildEventImage(cardHeight, width: imageWidth),
                        // 🏷️ Категория поверх изображения
                        Positioned(
                          top: 12,
                          left: 12,
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  EventUtils.getCategoryIcon(widget.event.category),
                                  size: 12.0, // 🛠️ FIX: double вместо int
                                  color: widget.event.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getCategoryShort(widget.event.category),
                                  style: TextStyle(
                                    color: widget.event.color,
                                    fontSize: 10.0, // 🛠️ FIX: double вместо int
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 💰 Цена в левом нижнем углу
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.event.price == 0 ? 'БЕСПЛАТНО' : '${widget.event.price}₽',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0, // 🛠️ FIX: double вместо int
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 📝 ПРАВАЯ ЧАСТЬ - ИНФОРМАЦИЯ
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(_getContentPadding(screenWidth)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок и организатор
                        Container(
                          constraints: BoxConstraints(maxHeight: _getTitleMaxHeight(screenWidth)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.title,
                                style: TextStyle(
                                  fontSize: _getTitleFontSize(screenWidth),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.event.organizer,
                                style: TextStyle(
                                  fontSize: _getSubtitleFontSize(screenWidth),
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _getSpacing(screenWidth)),

                        // Описание
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(maxHeight: _getDescriptionMaxHeight(screenWidth)),
                            child: Text(
                              widget.event.description ?? 'Описание отсутствует',
                              style: TextStyle(
                                fontSize: _getDescriptionFontSize(screenWidth),
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: _getSpacing(screenWidth)),

                        // Детали и кнопки
                        Row(
                          children: [
                            // Детали события
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    Icons.access_time_outlined,
                                    '${_formatDateShort(widget.event.date)} • ${_formatTime(widget.event.date)}',
                                    isMobile: false,
                                    screenWidth: screenWidth,
                                  ),
                                  SizedBox(height: _getSmallSpacing(screenWidth)),
                                  _buildInfoRow(
                                    Icons.location_on_outlined,
                                    _getShortLocation(widget.event.location ?? 'Место не указано'),
                                    isMobile: false,
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                            ),

                            // Кнопки действий
                            Column(
                              children: [
                                _buildIconButton(
                                  onPressed: widget.onFavorite,
                                  icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  isActive: widget.isFavorite,
                                  activeColor: Colors.red,
                                  tooltip: 'В избранное',
                                  isMobile: false,
                                ),
                                SizedBox(height: _getSmallSpacing(screenWidth)),
                                _buildDesktopAttendButton(),
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

  // 🎯 АДАПТИВНЫЕ РАЗМЕРЫ ДЛЯ ДЕСКТОПА

  double _getAdaptiveCardWidth(double screenWidth) {
    if (screenWidth < 700) return 320; // 🚨 МИНИМАЛЬНАЯ ШИРИНА ДЛЯ 2 КОЛОНОК
    if (screenWidth < 800) return 340;
    if (screenWidth < 900) return 360;
    if (screenWidth < 1000) return 380;
    return 400; // 🚨 МАКСИМАЛЬНАЯ ШИРИНА
  }

  double _getAdaptiveImageWidth(double screenWidth) {
    if (screenWidth < 700) return 120;
    if (screenWidth < 800) return 130;
    if (screenWidth < 900) return 140;
    if (screenWidth < 1000) return 150;
    return 160;
  }

  double _getAdaptiveCardHeight(double screenWidth) {
    if (screenWidth < 700) return 160;
    if (screenWidth < 800) return 170;
    return 180;
  }

  double _getContentPadding(double screenWidth) {
    if (screenWidth < 700) return 12;
    if (screenWidth < 800) return 14;
    return 16;
  }

  double _getTitleMaxHeight(double screenWidth) {
    if (screenWidth < 700) return 45;
    if (screenWidth < 800) return 48;
    return 50;
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 700) return 14.0;
    if (screenWidth < 800) return 15.0;
    return 16.0;
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (screenWidth < 700) return 11.0;
    return 12.0;
  }

  double _getDescriptionMaxHeight(double screenWidth) {
    if (screenWidth < 700) return 32;
    if (screenWidth < 800) return 34;
    return 36;
  }

  double _getDescriptionFontSize(double screenWidth) {
    if (screenWidth < 700) return 11.0;
    return 12.0;
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth < 700) return 6;
    if (screenWidth < 800) return 7;
    return 8;
  }

  double _getSmallSpacing(double screenWidth) {
    if (screenWidth < 700) return 4;
    return 6;
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
      width: isMobile ? 32 : 36,
      height: isMobile ? 32 : 36,
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.3) : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            icon,
            size: isMobile ? 16.0 : 18.0, // 🛠️ FIX: double вместо int
            color: isActive ? activeColor : Colors.grey[600],
          ),
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
            size: 16.0, // 🛠️ FIX: double вместо int
            color: isAttending ? Colors.green : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopAttendButton() {
    final isAttending = widget.isAttending;
    return Container(
      width: 36,
      height: 36,
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
          child: Icon(
            isAttending ? Icons.check_circle_outlined : Icons.event_available_outlined,
            size: 18.0, // 🛠️ FIX: double вместо int
            color: isAttending ? Colors.green : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {required bool isMobile, double? screenWidth}) {
    // 🛠️ FIX: Все размеры должны быть double
    final fontSize = isMobile ? 10.0 : (screenWidth != null && screenWidth < 700 ? 11.0 : 12.0);
    final iconSize = isMobile ? 12.0 : (screenWidth != null && screenWidth < 700 ? 13.0 : 14.0);

    return Row(
      children: [
        Icon(icon, size: iconSize, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
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

  // Вспомогательные методы
  String _getShortDescription(String description) {
    const maxLength = 60;
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }

  String _getShortLocation(String location) {
    const maxLength = 25;
    if (location.length <= maxLength) return location;
    return '${location.substring(0, maxLength)}...';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateShort(DateTime date) {
    const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final monthName = months[date.month - 1];
    return '${date.day} $monthName';
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
      'Вечеринка': 'ВЕЧЕРИнКА',
      'Лекция': 'ЛЕКЦИЯ',
      'Мастер-класс': 'МАСТЕР-КЛАСС',
      'Семинар': 'СЕМИНАР',
      'Митап': 'МИТАП',
      'Выпускной': 'ВЫПУСКНОЙ',
    };
    return categories[category] ?? category.toUpperCase();
  }
}