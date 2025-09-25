import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  final Widget label; // Измените String на Widget
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Widget? avatar;

  const FilterChip({
    super.key,
    required this.label, // Теперь принимает Widget, а не String
    required this.selected,
    required this.onSelected,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: label, // Просто используем переданный widget
      selected: selected,
      onSelected: onSelected,
      avatar: avatar,
      showCheckmark: false,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).primaryColor : Colors.grey[700],
      ),
    );
  }
}