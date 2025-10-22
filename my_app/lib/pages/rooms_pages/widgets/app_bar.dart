import 'package:flutter/material.dart';
import '../utils/layout_utils.dart';

class RoomsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final bool showSearchBar;
  final Function(bool) onSearchBarToggle;
  final LayoutUtils layoutUtils;
  final VoidCallback onSortPressed;
  final VoidCallback? onFilterToggle;
  final bool showFilters;
  final String title;
  final List<Widget>? actions;

  const RoomsAppBar({
    super.key,
    required this.searchController,
    required this.showSearchBar,
    required this.onSearchBarToggle,
    required this.layoutUtils,
    required this.onSortPressed,
    this.onFilterToggle,
    this.showFilters = false,
    this.title = 'Комнаты',
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context) {
    final isMobile = layoutUtils.isMobile(context);
    final horizontalPadding = layoutUtils.getHorizontalPadding(context);

    final categoriesCardMargin = isMobile ? 12.0 : horizontalPadding;
    final categoriesContentPadding = isMobile ? 12.0 : 16.0;
    final categoriesTitlePadding = 4.0;
    final totalCategoriesLeftPadding = categoriesCardMargin + categoriesContentPadding + categoriesTitlePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            layoutUtils.primaryColor,
            layoutUtils.secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!showSearchBar) ...[
            Padding(
              padding: EdgeInsets.only(left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
              child: _buildTitleSection(),
            ),
            const Spacer(),
            Container(
              margin: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
              child: _buildActionButtons(),
            ),
          ],

          if (showSearchBar)
            Expanded(
              child: _buildSearchSection(isMobile, horizontalPadding, totalCategoriesLeftPadding),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (actions != null) ...actions!,
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => onSearchBarToggle(true),
        ),
        if (onFilterToggle != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: showFilters
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            onPressed: onFilterToggle,
          ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sort_rounded, color: Colors.white, size: 18),
          ),
          onPressed: onSortPressed,
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isMobile, double horizontalPadding, double totalCategoriesLeftPadding) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding),
              right: 8,
            ),
            child: _buildSearchField(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
            onPressed: () {
              onSearchBarToggle(false);
              searchController.clear();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск комнат...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: layoutUtils.primaryColor),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
            onPressed: () => searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}