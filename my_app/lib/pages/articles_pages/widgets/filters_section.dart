import 'package:flutter/material.dart';
import 'package:my_app/pages/articles_pages/services/layout_service.dart';

class FiltersSection extends StatelessWidget {
  final bool showFilters;
  final String searchQuery;
  final int currentSortIndex;
  final ValueChanged<int> onSortChanged;
  final VoidCallback onShowFavorites;
  final bool isMobile;

  const FiltersSection({
    super.key,
    required this.showFilters,
    required this.searchQuery,
    required this.currentSortIndex,
    required this.onSortChanged,
    required this.onShowFavorites,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (!showFilters) return const SizedBox.shrink();

    final horizontalPadding = LayoutService.getHorizontalPadding(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white, // Явно задаем белый цвет
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87, // Темный текст
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 36 : 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _buildFilterChip(
                      context,
                      'verified',
                      'Только проверенные',
                      Icons.verified_rounded,
                      isActive: false,
                      onTap: () {},
                    ),
                    _buildFilterChip(
                      context,
                      'favorites',
                      'Избранное',
                      Icons.favorite_rounded,
                      isActive: searchQuery == "избранное",
                      onTap: onShowFavorites,
                    ),
                    _buildFilterChip(
                      context,
                      'popular',
                      'Популярные',
                      Icons.trending_up_rounded,
                      isActive: currentSortIndex == 1,
                      onTap: () => onSortChanged(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context,
      String id,
      String title,
      IconData icon, {
        required bool isActive,
        required VoidCallback onTap,
      }) {
    final emeraldColor = const Color(0xFF10B981);

    return Container(
      margin: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: Material(
        color: isActive ? emeraldColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? emeraldColor : Colors.grey.shade300, // Светло-серая граница
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isMobile ? 14 : 16,
                  color: isActive ? Colors.white : emeraldColor, // Изумрудный для неактивных
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.black87, // Темный текст
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