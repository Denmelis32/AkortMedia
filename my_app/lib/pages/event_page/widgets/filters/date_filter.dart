import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilter extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;

  const DateFilter({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Дата', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('Сегодня', selectedDate?.day == DateTime.now().day),
            _buildFilterChip('Завтра', selectedDate?.day == DateTime.now().add(const Duration(days: 1)).day),
            _buildFilterChip('На неделе', false),
            _buildFilterChip('В выходные', false),
            _buildFilterChip('Выбрать дату', false, onTap: () => _showDatePicker(context)),
          ],
        ),
        if (selectedDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Выбрана дата: ${DateFormat('dd.MM.yyyy').format(selectedDate!)}',
            style: const TextStyle(color: Colors.blue, fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, {VoidCallback? onTap}) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        if (onTap != null) {
          onTap();
        }
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(color: selected ? Colors.blue : Colors.black87),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      onDateChanged(date);
    }
  }
}