import 'package:flutter/material.dart';

import '../../predictions_league_page/predictions_league_page.dart';

class SortBottomSheet extends StatelessWidget {
  final List<SortOption> sortOptions;
  final int currentSortIndex;
  final ValueChanged<int> onSortChanged;

  const SortBottomSheet({
    super.key,
    required this.sortOptions,
    required this.currentSortIndex,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Сортировка',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          ...sortOptions.map((option) => ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, size: 20, color: theme.primaryColor),
            ),
            title: Text(
              option.title,
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: sortOptions.indexOf(option) == currentSortIndex
                ? Icon(Icons.check_rounded, color: theme.primaryColor, size: 20)
                : null,
            onTap: () {
              onSortChanged(sortOptions.indexOf(option));
              Navigator.pop(context);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          )).toList(),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required List<SortOption> sortOptions,
    required int currentSortIndex,
    required ValueChanged<int> onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SortBottomSheet(
        sortOptions: sortOptions,
        currentSortIndex: currentSortIndex,
        onSortChanged: onSortChanged,
      ),
    );
  }
}