import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;
  final Color? checkmarkColor;
  final TextStyle? labelStyle;
  final Color? backgroundColor;
  final OutlinedBorder? shape;

  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor,
    this.checkmarkColor,
    this.labelStyle,
    this.backgroundColor,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: selected ? selectedColor : backgroundColor,
          shape: shape ?? const StadiumBorder(),
        ),
        child: DefaultTextStyle(
          style: labelStyle ?? const TextStyle(),
          child: label,
        ),
      ),
    );
  }
}