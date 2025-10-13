import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_model.dart';
import 'add_event_dialog.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final Function(Event)? onEdit;
  final Function()? onDelete;

  const EventDetailsScreen({
    Key? key,
    required this.event,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Event _currentEvent;
  bool _isPastEvent = false;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
    _isPastEvent = _currentEvent.date.isBefore(DateTime.now());
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
      });

      if (widget.onEdit != null) {
        widget.onEdit!(updatedEvent);
      }

      _showSnackbar('Событие успешно обновлено!', Colors.green);
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text("Удалить событие?", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Вы уверены, что хотите удалить событие \"${_currentEvent.title}\"? Это действие нельзя отменить."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Отмена", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
                Navigator.of(context).pop();
                _showSnackbar('Событие удалено', Colors.red);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Удалить", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _setReminder() {
    final timeUntilEvent = _currentEvent.date.difference(DateTime.now());

    if (timeUntilEvent.isNegative) {
      _showSnackbar('Это событие уже прошло', Colors.orange);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentEvent.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active, size: 32, color: _currentEvent.color),
                ),
                SizedBox(height: 16),
                Text(
                  'Установить напоминание',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Напомнить о событии \"${_currentEvent.title}\" за:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildReminderOption('15 минут', Duration(minutes: 15)),
                    _buildReminderOption('1 час', Duration(hours: 1)),
                    _buildReminderOption('3 часа', Duration(hours: 3)),
                    _buildReminderOption('1 день', Duration(days: 1)),
                    _buildReminderOption('1 неделя', Duration(days: 7)),
                  ],
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Отмена', style: TextStyle(color: Colors.grey[600])),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderOption(String label, Duration duration) {
    return FilterChip(
      label: Text(label),
      onSelected: (_) {
        Navigator.of(context).pop();
        _showSnackbar('Напоминание установлено за $label', _currentEvent.color);
      },
      backgroundColor: _currentEvent.color.withOpacity(0.1),
      selectedColor: _currentEvent.color.withOpacity(0.3),
      checkmarkColor: _currentEvent.color,
      labelStyle: TextStyle(color: _currentEvent.color),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // АДАПТИВНЫЕ МЕТОДЫ КАК В PREDICTIONS PAGE
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
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar как в ArticlesPage
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : horizontalPadding,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Событие',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share, color: Colors.black, size: 18),
                      ),
                      onPressed: () {
                        _showSnackbar('Функция "Поделиться" в разработке', Colors.blue);
                      },
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert, color: Colors.black, size: 18),
                      ),
                      onPressed: () {
                        _showOptionsBottomSheet();
                      },
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ОБЛОЖКА С ТАКИМИ ЖЕ ОТСТУПАМИ КАК У AppBar И ОТСТУПОМ СВЕРХУ
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Stack(
                          children: [
                            // Основной фон с градиентом - С ОТСТУПОМ СВЕРХУ
                            Container(
                              margin: const EdgeInsets.only(top: 16, bottom: 20), // ОТСТУП СВЕРХУ 16px
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 280,
                                  width: double.infinity,
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
                                  child: Container(
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
                                ),
                              ),
                            ),

                            // Контент поверх изображения
                            Positioned(
                              bottom: 40,
                              left: 16, // Отступ внутри обложки
                              right: 16, // Отступ внутри обложки
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Категория
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
                                          _getCategoryIcon(_currentEvent.category ?? 'Общее'),
                                          size: 14,
                                          color: _currentEvent.color,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          _currentEvent.category?.toUpperCase() ?? 'ОБЩЕЕ',
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

                                  SizedBox(height: 16),

                                  // Заголовок
                                  Text(
                                    _currentEvent.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: 8),

                                  // Описание
                                  if (_currentEvent.description.isNotEmpty)
                                    Text(
                                      _currentEvent.description,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                  SizedBox(height: 16),

                                  // Статус и дата
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _isPastEvent ? Colors.grey : Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _isPastEvent ? 'ЗАВЕРШЕНО' : 'АКТИВНО',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          DateFormat('dd MMM yyyy').format(_currentEvent.date),
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
                        ),
                      ),
                    ),

                    // ОСНОВНОЙ КОНТЕНТ - КАРТОЧКИ ТАКОЙ ЖЕ ШИРИНЫ КАК ОБЛОЖКА
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding, // ТАКИЕ ЖЕ ОТСТУПЫ КАК У ОБЛОЖКИ
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            // КНОПКА ДЕЙСТВИЯ - БЕЛАЯ КАРТОЧКА ТАКОЙ ЖЕ ШИРИНЫ
                            if (!_isPastEvent)
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Container(
                                  width: double.infinity, // ЗАНИМАЕТ ВСЮ ШИРИНУ КОНТЕЙНЕРА
                                  padding: const EdgeInsets.all(16),
                                  child: ElevatedButton(
                                    onPressed: _setReminder,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _currentEvent.color,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.notifications_active, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Установить напоминание',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            if (!_isPastEvent) const SizedBox(height: 16),

                            // ИНФОРМАЦИЯ О СОБЫТИИ - БЕЛАЯ КАРТОЧКА ТАКОЙ ЖЕ ШИРИНЫ
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Container(
                                width: double.infinity, // ЗАНИМАЕТ ВСЮ ШИРИНУ КОНТЕЙНЕРА
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Заголовок раздела
                                    Text(
                                      'Информация о событии',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    // Детальная информация
                                    _buildInfoItem(
                                      icon: Icons.calendar_today,
                                      title: 'Дата и время',
                                      value: DateFormat('dd MMMM yyyy, HH:mm').format(_currentEvent.date),
                                      color: Colors.blue,
                                    ),
                                    SizedBox(height: 16),

                                    if (_currentEvent.category != null && _currentEvent.category!.isNotEmpty)
                                      _buildInfoItem(
                                        icon: Icons.category,
                                        title: 'Категория',
                                        value: _currentEvent.category!,
                                        color: _currentEvent.color,
                                      ),

                                    SizedBox(height: 16),

                                    // Время до события
                                    _buildTimeUntilEvent(),

                                    SizedBox(height: 20),

                                    // Полное описание
                                    if (_currentEvent.description.isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Описание',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _currentEvent.description,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[700],
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // КНОПКИ ДЕЙСТВИЙ - БЕЛАЯ КАРТОЧКА ТАКОЙ ЖЕ ШИРИНЫ
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Container(
                                width: double.infinity, // ЗАНИМАЕТ ВСЮ ШИРИНУ КОНТЕЙНЕРА
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _editEvent,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: _currentEvent.color,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: _currentEvent.color,
                                              width: 2,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Редактировать',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _deleteEvent,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Удалить',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
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

                            SizedBox(height: 32),
                          ],
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
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUntilEvent() {
    final now = DateTime.now();
    final difference = _currentEvent.date.difference(now);

    String timeText;
    Color color;

    if (difference.isNegative) {
      timeText = 'Событие завершено';
      color = Colors.grey;
    } else if (difference.inDays > 0) {
      timeText = 'Через ${difference.inDays} ${_getDayText(difference.inDays)}';
      color = Colors.green;
    } else if (difference.inHours > 0) {
      timeText = 'Через ${difference.inHours} ${_getHourText(difference.inHours)}';
      color = Colors.orange;
    } else {
      timeText = 'Через ${difference.inMinutes} минут';
      color = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'До события',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit, color: _currentEvent.color),
              title: Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                _editEvent();
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_active, color: _currentEvent.color),
              title: Text('Напомнить'),
              onTap: () {
                Navigator.pop(context);
                _setReminder();
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: _currentEvent.color),
              title: Text('Поделиться'),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Функция "Поделиться" в разработке', Colors.blue);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Удалить', style: TextStyle(color: Colors.red)),
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

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Работа': Icons.work,
      'Личное': Icons.person,
      'Здоровье': Icons.favorite,
      'Образование': Icons.school,
      'Развлечения': Icons.movie,
      'Спорт': Icons.sports_soccer,
      'Общее': Icons.event,
    };
    return icons[category] ?? Icons.event;
  }

  String _getDayText(int days) {
    if (days % 10 == 1 && days % 100 != 11) return 'день';
    if (days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20)) return 'дня';
    return 'дней';
  }

  String _getHourText(int hours) {
    if (hours % 10 == 1 && hours % 100 != 11) return 'час';
    if (hours % 10 >= 2 && hours % 10 <= 4 && (hours % 100 < 10 || hours % 100 >= 20)) return 'часа';
    return 'часов';
  }
}