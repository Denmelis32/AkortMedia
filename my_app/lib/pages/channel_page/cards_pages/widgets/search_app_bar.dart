// lib/pages/cards_pages/widgets/search_app_bar.dart
import 'package:flutter/material.dart';
import '../models/ui_config.dart';

class SearchAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool showSearchBar;
  final Function(bool) onSearchBarToggle;
  final VoidCallback onFiltersToggle;
  final VoidCallback onSortPressed;
  final UIConfig uiConfig;
  final bool isMobile;
  final double horizontalPadding;

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.showSearchBar,
    required this.onSearchBarToggle,
    required this.onFiltersToggle,
    required this.onSortPressed,
    required this.uiConfig,
    required this.isMobile,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Вычисляем отступ для выравнивания с категориями
    final categoriesCardMargin = isMobile ? 12.0 : horizontalPadding;
    final categoriesContentPadding = isMobile ? 12.0 : 16.0;
    final categoriesTitlePadding = 4.0;

    // Общий отступ от левого края до текста "Категории"
    final totalCategoriesLeftPadding = categoriesCardMargin +
        categoriesContentPadding + categoriesTitlePadding;

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
            uiConfig.primaryColor,
            uiConfig.secondaryColor,
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
            // Заголовок "Каналы" с фоном и выравниванием по категориям
            Padding(
              padding: EdgeInsets.only(left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
              child: Container(
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
                      Icons.play_circle_filled_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Каналы',
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
            ),
            const Spacer(),
            // Правый контент выровненный по правому краю категорий
            Container(
              margin: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
              child: Row(
                children: [
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
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: onFiltersToggle,
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
              ),
            ),
          ],

          if (showSearchBar)
            Expanded(
              child: Row(
                children: [
                  // Поле поиска с выравниванием
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding),
                        right: 8,
                      ),
                      child: _buildSearchField(),
                    ),
                  ),
                  // Кнопка закрытия с выравниванием
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
              ),
            ),
        ],
      ),
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
          hintText: 'Поиск каналов...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: uiConfig.primaryColor),
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