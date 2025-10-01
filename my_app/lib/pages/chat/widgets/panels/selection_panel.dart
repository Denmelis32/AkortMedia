import 'package:flutter/material.dart';

class SelectionPanel extends StatelessWidget {
  final ThemeData theme;
  final int selectedCount;
  final VoidCallback onForward;
  final VoidCallback onDelete;
  final VoidCallback onClearSelection;

  const SelectionPanel({
    super.key,
    required this.theme,
    required this.selectedCount,
    required this.onForward,
    required this.onDelete,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Выбрано: $selectedCount',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.forward, color: theme.primaryColor),
            onPressed: onForward,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            onPressed: onClearSelection,
          ),
        ],
      ),
    );
  }
}