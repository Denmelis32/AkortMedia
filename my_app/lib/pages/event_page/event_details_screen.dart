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

      // Показываем уведомление об успешном обновлении
      _showSnackbar('Событие успешно обновлено!', Colors.green);
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text("Удалить событие?"),
            ],
          ),
          content: Text("Вы уверены, что хотите удалить событие \"${_currentEvent.title}\"? Это действие нельзя отменить."),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_active, size: 50, color: _currentEvent.color),
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

  Widget _buildEventHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentEvent.color.withOpacity(0.9),
            _currentEvent.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _currentEvent.color.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.event_rounded, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Событие',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                _currentEvent.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8),
              if (_currentEvent.description.isNotEmpty)
                Text(
                  _currentEvent.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          if (_isPastEvent)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ПРОШЕДШЕЕ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time_filled, color: _currentEvent.color, size: 24),
              SizedBox(width: 12),
              Text(
                'Дата и время',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildDateTimeItem(
                icon: Icons.calendar_today,
                title: 'Дата',
                value: dateFormat.format(_currentEvent.date),
                color: Colors.blue,
              ),
              SizedBox(width: 16),
              _buildDateTimeItem(
                icon: Icons.schedule,
                title: 'Время',
                value: timeFormat.format(_currentEvent.date),
                color: Colors.green,
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildTimeUntilEvent(),
        ],
      ),
    );
  }

  Widget _buildDateTimeItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUntilEvent() {
    final now = DateTime.now();
    final difference = _currentEvent.date.difference(now);

    String timeText;
    Color color;

    if (difference.isNegative) {
      timeText = 'Событие прошло';
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: color, size: 16),
          SizedBox(width: 8),
          Text(
            timeText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildCategoryInfo() {
    if (_currentEvent.category == null || _currentEvent.category!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _currentEvent.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.category, color: _currentEvent.color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Категория',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _currentEvent.category!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _currentEvent.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: _currentEvent.color,
        elevation: 0,
        title: Text(
          'Детали события',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: Colors.white),
            onPressed: _editEvent,
            tooltip: 'Редактировать',
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              // TODO: Реализовать функцию поделиться
              _showSnackbar('Функция "Поделиться" в разработке', Colors.blue);
            },
            tooltip: 'Поделиться',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEventHeader(),
            SizedBox(height: 24),
            _buildDateTimeInfo(),
            SizedBox(height: 16),
            _buildCategoryInfo(),
            SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_isPastEvent)
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _setReminder,
              icon: Icon(Icons.notifications_active, size: 24),
              label: Text('Установить напоминание'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentEvent.color,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
              ),
            ),
          ),
        if (!_isPastEvent) SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _editEvent,
                icon: Icon(Icons.edit_rounded),
                label: Text('Редактировать'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: _currentEvent.color),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _deleteEvent,
                icon: Icon(Icons.delete_rounded, color: Colors.red),
                label: Text('Удалить', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}