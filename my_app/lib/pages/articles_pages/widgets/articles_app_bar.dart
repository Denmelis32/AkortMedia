import 'package:flutter/material.dart';
import 'package:my_app/pages/articles_pages/services/layout_service.dart';
import 'package:my_app/pages/articles_pages/widgets/search_section.dart';

class ArticlesAppBar extends StatelessWidget {
  final bool isSelectionMode;
  final int selectedArticlesCount;
  final VoidCallback onDeleteSelected;
  final VoidCallback onToggleSelectionMode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchQuery;
  final bool showSearchBar;
  final bool showFilters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggled;
  final VoidCallback onSearchClosed;
  final VoidCallback onFiltersToggled;
  final VoidCallback onSortToggled;

  const ArticlesAppBar({
    super.key,
    required this.isSelectionMode,
    required this.selectedArticlesCount,
    required this.onDeleteSelected,
    required this.onToggleSelectionMode,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchQuery,
    required this.showSearchBar,
    required this.showFilters,
    required this.onSearchChanged,
    required this.onSearchToggled,
    required this.onSearchClosed,
    required this.onFiltersToggled,
    required this.onSortToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = LayoutService.isMobile(context);
    final horizontalPadding = LayoutService.getHorizontalPadding(context);
    final theme = Theme.of(context);

    // Изумрудный цвет
    final emeraldColor = const Color(0xFF10B981);
    final emeraldDarkColor = const Color(0xFF059669);

    if (isSelectionMode) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              emeraldColor,
              emeraldDarkColor,
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Выбрано: $selectedArticlesCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: _buildIconButton(Icons.delete_rounded),
                  onPressed: onDeleteSelected,
                ),
                IconButton(
                  icon: _buildIconButton(Icons.close_rounded),
                  onPressed: onToggleSelectionMode,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SearchSection(
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      searchQuery: searchQuery,
      showSearchBar: showSearchBar,
      showFilters: showFilters,
      onSearchChanged: onSearchChanged,
      onSearchToggled: onSearchToggled,
      onSearchClosed: onSearchClosed,
      onFiltersToggled: onFiltersToggled,
      onSortToggled: onSortToggled,
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}