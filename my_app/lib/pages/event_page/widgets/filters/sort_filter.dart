import 'package:flutter/material.dart';

class SortFilter extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  const SortFilter({
    Key? key,
    required this.sortBy,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Сортировка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSortChip('По дате', 'date'),
            _buildSortChip('По популярности', 'popularity'),
            _buildSortChip('Сначала дешевые', 'price_low'),
            _buildSortChip('Сначала дорогие', 'price_high'),
            _buildSortChip('По рейтингу', 'rating'),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSortChanged(value),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}