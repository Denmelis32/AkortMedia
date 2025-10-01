import 'package:flutter/material.dart';
import '../../models/chat_message.dart';

class EditPanel extends StatelessWidget {
  final ThemeData theme;
  final ChatMessage editingMessage;
  final VoidCallback onCancel;

  const EditPanel({
    super.key,
    required this.theme,
    required this.editingMessage,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Редактирование сообщения',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  editingMessage.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}