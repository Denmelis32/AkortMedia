import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../models/room.dart';
import '../chips/search_filter_chip.dart';

class FiltersSection extends StatelessWidget {
  final RoomProvider roomProvider;
  final TextEditingController searchController;
  final bool isSearchExpanded;

  const FiltersSection({
    super.key,
    required this.roomProvider,
    required this.searchController,
    required this.isSearchExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilters = _getActiveFilters(context, roomProvider);

    if (activeFilters.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isSearchExpanded ? 0 : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Активные фильтры:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: roomProvider.resetAllFilters,
                    child: const Text('Сбросить все'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activeFilters,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getActiveFilters(BuildContext context, RoomProvider roomProvider) {
    final theme = Theme.of(context);
    final filters = <Widget>[];

    if (roomProvider.selectedCategory != RoomCategory.all) {
      filters.add(SearchFilterChip(
        label: 'Категория: ${roomProvider.selectedCategory.title}',
        color: theme.primaryColor,
        onRemove: () => roomProvider.setCategory(RoomCategory.all),
      ));
    }

    if (roomProvider.searchQuery.isNotEmpty) {
      filters.add(SearchFilterChip(
        label: 'Поиск: "${roomProvider.searchQuery}"',
        color: Colors.green,
        onRemove: () {
          searchController.clear();
          roomProvider.setSearchQuery('');
        },
      ));
    }

    if (roomProvider.showJoinedOnly) {
      filters.add(SearchFilterChip(
        label: 'Только мои обсуждения',
        color: Colors.orange,
        onRemove: () => roomProvider.toggleShowJoinedOnly(),
      ));
    }

    return filters;
  }
}