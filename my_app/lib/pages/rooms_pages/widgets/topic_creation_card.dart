import 'package:flutter/material.dart';
import '../models_room/access_level.dart';

class TopicCreationCard extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> selectedTags;
  final List<String> availableTags;
  final AccessLevel selectedAccessLevel;
  final VoidCallback onCreate;
  final VoidCallback onCancel;
  final ValueChanged<String> onToggleTag;
  final ValueChanged<AccessLevel> onAccessLevelChanged;
  final String categoryTitle;

  const TopicCreationCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedTags,
    required this.availableTags,
    required this.selectedAccessLevel,
    required this.onCreate,
    required this.onCancel,
    required this.onToggleTag,
    required this.onAccessLevelChanged,
    required this.categoryTitle,
  });

  @override
  State<TopicCreationCard> createState() => _TopicCreationCardState();
}

class _TopicCreationCardState extends State<TopicCreationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Создать новую комнату в ${widget.categoryTitle}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: widget.titleController,
              decoration: InputDecoration(
                labelText: 'Название комнаты*',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Теги:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableTags.map((tag) => FilterChip(
                label: Text(tag),
                selected: widget.selectedTags.contains(tag),
                onSelected: (_) => widget.onToggleTag(tag),
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.blue[100],
                labelStyle: TextStyle(
                  color: widget.selectedTags.contains(tag)
                      ? Colors.blue
                      : Colors.black87,
                  fontWeight: widget.selectedTags.contains(tag)
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Уровень доступа:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AccessLevel.values.map((level) => FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(level.icon, size: 16, color: level.color),
                    const SizedBox(width: 6),
                    Text(level.label),
                  ],
                ),
                selected: widget.selectedAccessLevel == level,
                onSelected: (_) => widget.onAccessLevelChanged(level),
                backgroundColor: Colors.grey[100],
                selectedColor: level.color.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: widget.selectedAccessLevel == level
                      ? level.color
                      : Colors.black87,
                  fontWeight: widget.selectedAccessLevel == level
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: widget.onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Создать комнату'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}