import 'package:flutter/material.dart';

class ReactionsPanel extends StatelessWidget {
  final ThemeData theme;
  final List<String> availableReactions;
  final Function(String) onEmojiSelected;

  const ReactionsPanel({
    super.key,
    required this.theme,
    required this.availableReactions,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(availableReactions.length, (index) {
          return GestureDetector(
            onTap: () => onEmojiSelected(availableReactions[index]),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                availableReactions[index],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        }),
      ),
    );
  }
}