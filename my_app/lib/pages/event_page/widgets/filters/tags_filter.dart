import 'package:flutter/material.dart';

class TagsFilter extends StatelessWidget {
  final List<String> selectedTags;
  final List<String> popularTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagsFilter({
    Key? key,
    required this.selectedTags,
    required this.popularTags,
    required this.onTagsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Теги и категории', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularTags.map((tag) => _buildFilterChip(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String tag) {
    final isSelected = selectedTags.contains(tag);
    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (value) {
        final newTags = List<String>.from(selectedTags);
        if (value) {
          newTags.add(tag);
        } else {
          newTags.remove(tag);
        }
        onTagsChanged(newTags);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(color: isSelected ? Colors.blue : Colors.black87),
    );
  }
}