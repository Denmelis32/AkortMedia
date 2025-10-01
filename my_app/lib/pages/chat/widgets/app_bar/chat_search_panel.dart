import 'package:flutter/material.dart';

class ChatSearchPanel extends StatelessWidget {
  final ThemeData theme;
  final Function(String) onSearch;
  final VoidCallback onClose;

  const ChatSearchPanel({
    super.key,
    required this.theme,
    required this.onSearch,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск по сообщениям...',
                prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
              onChanged: onSearch,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, color: theme.primaryColor),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}