import 'package:flutter/material.dart';
import '../models/reaction.dart';

class MessageReactions extends StatelessWidget {
  final List<Reaction> reactions;
  final VoidCallback? onReactionTap; // Делаем nullable

  const MessageReactions({
    super.key,
    required this.reactions,
    this.onReactionTap, // Делаем optional
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    // Группируем реакции по эмодзи
    final reactionGroups = <String, List<Reaction>>{};
    for (final reaction in reactions) {
      reactionGroups[reaction.emoji] = [
        ...reactionGroups[reaction.emoji] ?? [],
        reaction
      ];
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: reactionGroups.entries.map((entry) {
          final emoji = entry.key;
          final groupReactions = entry.value;
          final count = groupReactions.length;

          return GestureDetector(
            onTap: onReactionTap, // Просто передаем callback (может быть null)
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _hasCurrentUserReaction(groupReactions)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasCurrentUserReaction(groupReactions)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (count > 1) ...[
                    const SizedBox(width: 4),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _hasCurrentUserReaction(groupReactions)
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _hasCurrentUserReaction(List<Reaction> reactions) {
    // TODO: Заменить на реальную проверку текущего пользователя
    return reactions.any((reaction) => reaction.user.id == 'current-user');
  }
}