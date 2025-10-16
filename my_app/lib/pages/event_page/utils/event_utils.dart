import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventUtils {
  static String formatEventDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return 'Сегодня, ${DateFormat('HH:mm').format(date)}';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      return 'Завтра, ${DateFormat('HH:mm').format(date)}';
    } else if (eventDay.isBefore(today.add(const Duration(days: 7)))) {
      return '${_getWeekday(date.weekday)}, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd MMM, HH:mm').format(date);
    }
  }

  static String _getWeekday(int weekday) {
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

  static IconData getCategoryIcon(String category) {
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
    };
    return icons[category] ?? Icons.event_rounded;
  }

  static Color getColorForType(String type) {
    switch (type) {
      case 'Встреча': return Colors.blue;
      case 'День рождения': return Colors.pink;
      case 'Рабочее': return Colors.green;
      case 'Спорт': return Colors.orange;
      case 'Кино': return Colors.purple;
      case 'Ужин': return Colors.red;
      default: return Colors.grey;
    }
  }
}