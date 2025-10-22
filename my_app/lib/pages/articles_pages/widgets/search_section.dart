import 'package:flutter/material.dart';
import 'package:my_app/pages/articles_pages/services/layout_service.dart';

class SearchSection extends StatelessWidget {
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

  const SearchSection({
    super.key,
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
    final theme = Theme.of(context);
    final isMobile = LayoutService.isMobile(context);
    final horizontalPadding = LayoutService.getHorizontalPadding(context);

    if (!showSearchBar) {
      return _buildCompactSearchBar(context, theme, isMobile, horizontalPadding);
    }

    return _buildExpandedSearchBar(context, theme, isMobile, horizontalPadding);
  }

  Widget _buildCompactSearchBar(BuildContext context, ThemeData theme, bool isMobile, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981), // Изумрудный
            const Color(0xFF059669),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          _buildTitle(context, isMobile, horizontalPadding),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildExpandedSearchBar(BuildContext context, ThemeData theme, bool isMobile, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981), // Изумрудный
            const Color(0xFF059669),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildSearchField(theme)),
          const SizedBox(width: 8),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isMobile, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.only(left: _calculateTitleLeftPadding(isMobile, horizontalPadding)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Статьи',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: _buildIconButton(Icons.search_rounded),
          onPressed: onSearchToggled,
        ),
        IconButton(
          icon: _buildIconButton(
            Icons.filter_alt_rounded,
            isActive: showFilters,
          ),
          onPressed: onFiltersToggled,
        ),
        IconButton(
          icon: _buildIconButton(Icons.sort_rounded),
          onPressed: onSortToggled,
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
  Widget _buildSearchField(ThemeData theme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white, // Белый фон поля поиска
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск статей...',
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15), // Серый текст подсказки
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: const Color(0xFF10B981)), // Изумрудная иконка
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, size: 18, color: Colors.grey.shade600),
            onPressed: () {
              searchController.clear();
              onSearchChanged('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 15, color: Colors.black87), // Темный текст ввода
        onChanged: onSearchChanged,
      ),
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
      ),
      onPressed: onSearchClosed,
    );
  }

  double _calculateTitleLeftPadding(bool isMobile, double horizontalPadding) {
    final categoriesCardMargin = isMobile ? 12.0 : horizontalPadding;
    final categoriesContentPadding = isMobile ? 12.0 : 16.0;
    final categoriesTitlePadding = 4.0;
    return categoriesCardMargin + categoriesContentPadding + categoriesTitlePadding -
        (isMobile ? 12 : horizontalPadding);
  }
}