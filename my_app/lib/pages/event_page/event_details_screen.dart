import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'event_model.dart';
import 'add_event_dialog.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final Function(Event)? onEdit;
  final Function()? onDelete;
  final Function()? onFavorite;
  final Function()? onAttend;
  final Function()? onShare;
  final Function(double)? onRate;
  final bool? isFavorite;
  final bool? isAttending;
  final double? currentRating;
  final int? viewCount;

  const EventDetailsScreen({
    Key? key,
    required this.event,
    this.onEdit,
    this.onDelete,
    this.onFavorite,
    this.onAttend,
    this.onShare,
    this.onRate,
    this.isFavorite = false,
    this.isAttending = false,
    this.currentRating,
    this.viewCount = 0,
  }) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with TickerProviderStateMixin {
  late Event _currentEvent;
  bool _isPastEvent = false;
  bool _isOngoing = false;
  bool _isFavorite = false;
  bool _isAttending = false;
  double _currentRating = 0.0;
  int _viewCount = 0;

  // Анимации
  late AnimationController _favoriteController;
  late AnimationController _attendController;
  late Animation<double> _scaleAnimation;

  // Состояния
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  bool get _isMobile => MediaQuery.of(context).size.width <= 600;

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ ОТСТУПОВ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1000;
    if (width > 1000) return 900;
    if (width > 700) return 700;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
    _isPastEvent = _currentEvent.date.isBefore(DateTime.now());
    _isOngoing = _currentEvent.date.isBefore(DateTime.now()) && _currentEvent.endDate.isAfter(DateTime.now());
    _isFavorite = widget.isFavorite ?? false;
    _isAttending = widget.isAttending ?? false;
    _currentRating = widget.currentRating ?? _currentEvent.rating;
    _viewCount = widget.viewCount ?? 0;

    // Инициализация анимаций
    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _attendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _favoriteController, curve: Curves.easeInOut),
    );

    // Увеличиваем счетчик просмотров
    _incrementViewCount();
  }

  void _incrementViewCount() {
    setState(() {
      _viewCount++;
    });
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    _attendController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _editEvent() async {
    final updatedEvent = await showDialog<Event>(
      context: context,
      builder: (BuildContext context) {
        return AddEventDialog(
          onAdd: (event) => event,
          initialEvent: _currentEvent,
          isEditing: true,
        );
      },
    );

    if (updatedEvent != null) {
      setState(() {
        _currentEvent = updatedEvent;
        _isPastEvent = _currentEvent.date.isBefore(DateTime.now());
        _isOngoing = _currentEvent.date.isBefore(DateTime.now()) && _currentEvent.endDate.isAfter(DateTime.now());
      });

      widget.onEdit?.call(updatedEvent);
      _showSnackbar('Событие успешно обновлено!', Colors.green);
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text("Удалить событие?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Вы уверены, что хотите удалить событие?", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                "\"${_currentEvent.title}\"",
                style: TextStyle(fontWeight: FontWeight.bold, color: _currentEvent.color),
              ),
              SizedBox(height: 12),
              Text("Это действие нельзя отменить.", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Отмена", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete?.call();
                Navigator.of(context).pop();
                _showSnackbar('Событие удалено', Colors.red);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Удалить", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });

    widget.onFavorite?.call();
    _showSnackbar(
      _isFavorite ? 'Добавлено в избранное' : 'Удалено из избранного',
      _isFavorite ? Colors.pink : Colors.grey,
    );
  }

  void _toggleAttending() {
    setState(() {
      _isAttending = !_isAttending;
    });

    _attendController.forward().then((_) {
      _attendController.reverse();
    });

    widget.onAttend?.call();
    _showSnackbar(
      _isAttending ? 'Вы участвуете в событии!' : 'Вы больше не участвуете',
      _isAttending ? Colors.green : Colors.grey,
    );
  }

  void _shareEvent() {
    final shareText = '''
🎉 ${_currentEvent.title}

${_currentEvent.description}

📅 ${_formatEventDate(_currentEvent.date)}
⏰ ${DateFormat('HH:mm').format(_currentEvent.date)} - ${DateFormat('HH:mm').format(_currentEvent.endDate)}
📍 ${_currentEvent.location ?? 'Онлайн'}
💰 ${_currentEvent.price == 0 ? 'Бесплатно' : '${_currentEvent.price} ₽'}

Присоединяйтесь к событию! 🚀
''';

    Share.share(shareText, subject: _currentEvent.title);
    widget.onShare?.call();
  }

  void _setReminder() {
    final timeUntilEvent = _currentEvent.date.difference(DateTime.now());

    if (timeUntilEvent.isNegative) {
      _showSnackbar('Это событие уже прошло', Colors.orange);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentEvent.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_active_rounded, size: 32, color: _currentEvent.color),
            ),
            SizedBox(height: 16),
            Text(
              'Напомнить о событии',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '"${_currentEvent.title}"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: _currentEvent.color, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Text(
              'Выберите время напоминания:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildReminderOption('За 15 минут', Duration(minutes: 15)),
                _buildReminderOption('За 1 час', Duration(hours: 1)),
                _buildReminderOption('За 3 часа', Duration(hours: 3)),
                _buildReminderOption('За 1 день', Duration(days: 1)),
                _buildReminderOption('За 1 неделю', Duration(days: 7)),
                _buildReminderOption('В день события', Duration(days: 0)),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Отмена'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showSnackbar('Напоминание установлено', _currentEvent.color);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentEvent.color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Установить'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderOption(String label, Duration duration) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (_) {
        Navigator.of(context).pop();
        _showSnackbar('Напоминание установлено $label', _currentEvent.color);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: _currentEvent.color.withOpacity(0.2),
      labelStyle: TextStyle(color: _currentEvent.color, fontWeight: FontWeight.w500),
    );
  }

  void _rateEvent(double rating) {
    setState(() {
      _currentRating = rating;
    });
    widget.onRate?.call(rating);
    _showSnackbar('Спасибо за вашу оценку!', _currentEvent.color);
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Оцените событие', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('"${_currentEvent.title}"',
              textAlign: TextAlign.center,
              style: TextStyle(color: _currentEvent.color, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            _buildStarRating(_currentRating, true),
            SizedBox(height: 20),
            Text('Ваша оценка: ${_currentRating.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackbar('Спасибо за оценку!', _currentEvent.color);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _currentEvent.color),
            child: Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildEventImage(String? imageUrl, double height) {
    if (imageUrl == null) {
      return _buildErrorEventImage(height);
    }

    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorEventImage(height);
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorEventImage(height);
          },
        );
      }
    } catch (e) {
      return _buildErrorEventImage(height);
    }
  }

  Widget _buildErrorEventImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: _currentEvent.color.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_rounded,
            color: _currentEvent.color.withOpacity(0.5),
            size: 60,
          ),
          SizedBox(height: 12),
          Text(
            'Изображение события',
            style: TextStyle(
              color: _currentEvent.color.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Кастомный AppBar вместо SliverAppBar
          SliverToBoxAdapter(
            child: _buildCustomAppBar(horizontalPadding),
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: _buildMainContent(horizontalPadding),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // КАСТОМНЫЙ APP BAR
  Widget _buildCustomAppBar(double horizontalPadding) {
    final images = _currentEvent.imageUrl != null ? [_currentEvent.imageUrl!] : [];

    return Stack(
      children: [
        // Основной контент заголовка
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _currentEvent.color.withOpacity(0.9),
                _currentEvent.color,
                _currentEvent.color.withOpacity(0.8),
              ],
            ),
          ),
          child: images.isNotEmpty
              ? PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) => _buildEventImage(images[index], 280),
          )
              : Container(),
        ),

        // Градиентный оверлей
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Кнопки управления
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: _isMobile ? 8 : horizontalPadding,
          right: _isMobile ? 8 : horizontalPadding,
          child: Row(
            children: [
              // Кнопка назад - ПРОСТАЯ И РАБОЧАЯ
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              Spacer(),
              // Другие кнопки
              _buildSimpleActionButton(Icons.share_rounded, _shareEvent),
              if (_isMobile)
                _buildSimpleActionButton(Icons.more_vert_rounded, _showOptionsBottomSheet),
            ],
          ),
        ),

        // Контент поверх изображения
        Positioned(
          bottom: 20,
          left: _isMobile ? 16 : horizontalPadding,
          right: _isMobile ? 16 : horizontalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Категория и рейтинг
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(_currentEvent.category),
                          size: 14,
                          color: _currentEvent.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentEvent.category.toUpperCase(),
                          style: TextStyle(
                            color: _currentEvent.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_currentEvent.rating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _currentEvent.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Заголовок
              Text(
                _currentEvent.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Статус и дата
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatEventDate(_currentEvent.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _currentEvent.color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ПРОСТАЯ КНОПКА ДЕЙСТВИЯ
  Widget _buildSimpleActionButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 18),
      ),
    );
  }

  // ОСТАЛЬНЫЕ МЕТОДЫ остаются без изменений
  Widget _buildMainContent(double horizontalPadding) {
    return Column(
      children: [
        // Быстрые действия
        if (!_isPastEvent)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: _isMobile ? 0 : horizontalPadding, vertical: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_isMobile ? 0 : 16)),
              margin: EdgeInsets.zero,
              color: Colors.white,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton.icon(
                          onPressed: _toggleFavorite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFavorite ? Colors.pink.withOpacity(0.1) : Colors.grey[50],
                            foregroundColor: _isFavorite ? Colors.pink : Colors.grey[700],
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: _isFavorite ? Colors.pink : Colors.grey[300]!),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                          label: Text(_isFavorite ? 'В избранном' : 'В избранное'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleAttending,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAttending ? Colors.green.withOpacity(0.1) : Colors.grey[50],
                          foregroundColor: _isAttending ? Colors.green : Colors.grey[700],
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: _isAttending ? Colors.green : Colors.grey[300]!),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(_isAttending ? Icons.check_circle_rounded : Icons.person_add_rounded),
                        label: Text(_isAttending ? 'Участвую' : 'Участвовать'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Основная информация
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: _isMobile ? 0 : horizontalPadding),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_isMobile ? 0 : 16)),
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Информация о событии',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 20),
                  _buildInfoGrid(),
                  SizedBox(height: 20),
                  if (_currentEvent.description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Описание', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        SizedBox(height: 12),
                        Text(
                          _currentEvent.description,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 16),

        // Дополнительные действия
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: _isMobile ? 0 : horizontalPadding),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_isMobile ? 0 : 16)),
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!_isPastEvent) ...[
                    _buildActionButtonRow(),
                    SizedBox(height: 16),
                  ],
                  _buildManagementButtonRow(),
                ],
              ),
            ),
          ),
        ),

        // Статистика
        if (_viewCount > 0 || _currentEvent.reviewCount > 0) ...[
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: _isMobile ? 0 : horizontalPadding),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_isMobile ? 0 : 16)),
              margin: EdgeInsets.zero,
              color: Colors.white,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Статистика', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    _buildStatsGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 32),
      ],
    );
  }

  Widget _buildInfoGrid() {
    final duration = _currentEvent.endDate.difference(_currentEvent.date);
    final durationInHours = duration.inMinutes / 60.0;

    return Column(
      children: [
        _buildInfoItem(
          icon: Icons.calendar_today_rounded,
          title: 'Дата и время',
          value: '${_formatEventDate(_currentEvent.date)}\n${DateFormat('HH:mm').format(_currentEvent.date)} - ${DateFormat('HH:mm').format(_currentEvent.endDate)}',
          color: Colors.blue,
        ),
        SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.access_time_rounded,
          title: 'Длительность',
          value: '${durationInHours.toStringAsFixed(1)} часа',
          color: Colors.orange,
        ),
        SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.people_rounded,
          title: 'Участники',
          value: '${_currentEvent.currentAttendees} / ${_currentEvent.maxAttendees}',
          color: Colors.green,
        ),
        SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.attach_money_rounded,
          title: 'Стоимость',
          value: _currentEvent.price == 0 ? 'Бесплатно' : '${_currentEvent.price} ₽',
          color: Colors.purple,
        ),
        if (_currentEvent.location != null) ...[
          SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.location_on_rounded,
            title: 'Местоположение',
            value: _currentEvent.location!,
            color: Colors.red,
          ),
        ],
        if (_currentEvent.isOnline && _currentEvent.onlineLink != null) ...[
          SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.online_prediction_rounded,
            title: 'Онлайн-ссылка',
            value: _currentEvent.onlineLink!,
            color: Colors.cyan,
            isLink: true,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isLink = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                SizedBox(height: 6),
                isLink
                    ? GestureDetector(
                  onTap: () => _showSnackbar('Ссылка скопирована', color),
                  child: Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                )
                    : Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _setReminder,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentEvent.color.withOpacity(0.1),
              foregroundColor: _currentEvent.color,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(Icons.notifications_active_rounded),
            label: Text('Напомнить'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
              foregroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(Icons.share_rounded),
            label: Text('Поделиться'),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementButtonRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _editEvent,
            style: OutlinedButton.styleFrom(
              foregroundColor: _currentEvent.color,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: _currentEvent.color),
            ),
            icon: Icon(Icons.edit_rounded),
            label: Text('Редактировать'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _deleteEvent,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.red),
            ),
            icon: Icon(Icons.delete_rounded),
            label: Text('Удалить'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(Icons.remove_red_eye_rounded, 'Просмотры', _viewCount.toString()),
        _buildStatItem(Icons.people_rounded, 'Участники', _currentEvent.currentAttendees.toString()),
        _buildStatItem(Icons.star_rounded, 'Рейтинг', _currentEvent.rating.toStringAsFixed(1)),
        _buildStatItem(Icons.reviews_rounded, 'Отзывы', _currentEvent.reviewCount.toString()),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _currentEvent.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: _currentEvent.color),
        ),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStarRating(double rating, bool interactive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive ? () => _rateEvent(index + 1.0) : null,
          child: Icon(
            index < rating.floor() ? Icons.star_rounded :
            (index < rating.ceil() ? Icons.star_half_rounded : Icons.star_border_rounded),
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: _currentEvent.color),
              title: Text('Редактировать', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _editEvent();
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_active_rounded, color: _currentEvent.color),
              title: Text('Напомнить', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _setReminder();
              },
            ),
            ListTile(
              leading: Icon(Icons.share_rounded, color: _currentEvent.color),
              title: Text('Поделиться', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _shareEvent();
              },
            ),
            ListTile(
              leading: Icon(Icons.star_rounded, color: _currentEvent.color),
              title: Text('Оценить', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showRatingDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.report_rounded, color: Colors.orange),
              title: Text('Пожаловаться', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Жалоба отправлена', Colors.orange);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: Colors.red),
              title: Text('Удалить', style: TextStyle(fontSize: 16, color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_isPastEvent) return Colors.grey;
    if (_isOngoing) return Colors.green;
    return Colors.orange;
  }

  String _getStatusText() {
    if (_isPastEvent) return 'ЗАВЕРШЕНО';
    if (_isOngoing) return 'СЕЙЧАС ИДЕТ';
    return 'СКОРО';
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return 'Сегодня';
    } else if (eventDay == today.add(Duration(days: 1))) {
      return 'Завтра';
    } else if (eventDay.isBefore(today.add(Duration(days: 7)))) {
      return _getWeekday(date.weekday);
    } else {
      return DateFormat('dd MMMM yyyy', 'ru_RU').format(date);
    }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Понедельник';
      case 2: return 'Вторник';
      case 3: return 'Среда';
      case 4: return 'Четверг';
      case 5: return 'Пятница';
      case 6: return 'Суббота';
      case 7: return 'Воскресенье';
      default: return '';
    }
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Концерты': Icons.music_note_rounded,
      'Выставки': Icons.palette_rounded,
      'Фестивали': Icons.celebration_rounded,
      'Спорт': Icons.sports_soccer_rounded,
      'Театр': Icons.theater_comedy_rounded,
      'Встречи': Icons.people_alt_rounded,
      'Образование': Icons.school_rounded,
      'Кино': Icons.movie_rounded,
      'Ужин': Icons.restaurant_rounded,
      'Встреча': Icons.people_alt_rounded,
      'День рождения': Icons.cake_rounded,
      'Рабочее': Icons.work_rounded,
    };
    return icons[category] ?? Icons.event_rounded;
  }
}