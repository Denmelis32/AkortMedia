import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearchExpanded;
  final VoidCallback onToggleSearch;
  final VoidCallback onShowFilters;

  const SearchSection({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearchExpanded,
    required this.onToggleSearch,
    required this.onShowFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomProvider = context.read<RoomProvider>();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isSearchExpanded ? 70 : 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSearchExpanded ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSearchExpanded ? 0.15 : 0.1),
                blurRadius: isSearchExpanded ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Поиск по названию, тегам, автору...',
              prefixIcon: IconButton(
                icon: Icon(isSearchExpanded ? Icons.arrow_back_rounded : Icons.search_rounded),
                onPressed: onToggleSearch,
              ),
              suffixIcon: _buildSearchSuffix(theme, roomProvider),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSearchExpanded ? 20 : 16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuffix(ThemeData theme, RoomProvider roomProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              searchController.clear();
              roomProvider.setSearchQuery('');
            },
          ),
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          onPressed: onShowFilters,
          tooltip: 'Расширенные фильтры',
        ),
      ],
    );
  }
}