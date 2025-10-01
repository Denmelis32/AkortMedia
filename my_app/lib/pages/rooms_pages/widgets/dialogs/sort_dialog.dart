import 'package:flutter/material.dart';
import '../../models/room.dart';

class SortDialog extends StatelessWidget {
  final RoomSortBy currentSortBy;
  final Function(RoomSortBy) onSortChanged;

  const SortDialog({
    super.key,
    required this.currentSortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: SafeArea(
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sort_rounded, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      'Сортировка комнат',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...RoomSortBy.values.map((sortBy) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: currentSortBy == sortBy
                            ? theme.primaryColor.withOpacity(0.3)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: currentSortBy == sortBy
                              ? theme.primaryColor.withOpacity(0.1)
                              : theme.colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          sortBy.icon,
                          color: currentSortBy == sortBy
                              ? theme.primaryColor
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        sortBy.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: currentSortBy == sortBy
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        sortBy.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      trailing: currentSortBy == sortBy
                          ? Icon(
                        Icons.check_circle_rounded,
                        color: theme.primaryColor,
                      )
                          : null,
                      onTap: () {
                        onSortChanged(sortBy);
                        Navigator.pop(context);
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}