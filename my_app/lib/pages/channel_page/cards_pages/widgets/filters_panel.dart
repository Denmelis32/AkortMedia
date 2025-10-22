// lib/pages/cards_pages/widgets/filters_panel.dart
import 'package:flutter/material.dart';
import '../../../rooms_pages/models/filter_option.dart';
import '../../../rooms_pages/models/room_category.dart';
import '../models/channel_data.dart';
import '../models/ui_config.dart';

class FiltersPanel extends StatelessWidget {
  final bool showFilters;
  final Set<String> activeFilters;
  final String selectedCategoryId;
  final Function(String) onFilterToggle;
  final Function(String) onCategorySelected;
  final ChannelDataManager dataManager;
  final UIConfig uiConfig;
  final bool isMobile;
  final double horizontalPadding;

  const FiltersPanel({
    super.key,
    required this.showFilters,
    required this.activeFilters,
    required this.selectedCategoryId,
    required this.onFilterToggle,
    required this.onCategorySelected,
    required this.dataManager,
    required this.uiConfig,
    required this.isMobile,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showFilters) _buildFiltersCard(),
        _buildCategoriesCard(),
      ],
    );
  }

  Widget _buildFiltersCard() {
    if (!showFilters) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: uiConfig.surfaceColor,
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
                    color: uiConfig.textColor,
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
                  children: dataManager.filterOptions.map((filter) => _buildFilterChip(filter)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: uiConfig.surfaceColor,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Категории',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: uiConfig.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // АДАПТИВНЫЙ СПИСОК КАТЕГОРИЙ
              if (isMobile)
                _buildMobileCategories()
              else
                _buildDesktopCategories(),
            ],
          ),
        ),
      ),
    );
  }

  // ГОРИЗОНТАЛЬНЫЙ СКРОЛЛ КАТЕГОРИЙ ДЛЯ ТЕЛЕФОНА
  Widget _buildMobileCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: dataManager.categories.length,
        itemBuilder: (context, index) {
          final category = dataManager.categories[index];
          return _buildMobileCategoryChip(category);
        },
      ),
    );
  }

  // КАТЕГОРИИ ДЛЯ ДЕСКТОПА
  Widget _buildDesktopCategories() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dataManager.categories.map((category) => _buildDesktopCategoryChip(category)).toList(),
    );
  }

  Widget _buildMobileCategoryChip(RoomCategory category) {
    final isSelected = selectedCategoryId == category.id;

    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onCategorySelected(category.id),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 14,
                  color: isSelected ? Colors.white : category.color,
                ),
                const SizedBox(width: 4),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : uiConfig.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCategoryChip(RoomCategory category) {
    final isSelected = selectedCategoryId == category.id;

    return Material(
      color: isSelected ? category.color : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onCategorySelected(category.id),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? category.color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 16,
                color: isSelected ? Colors.white : category.color,
              ),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : uiConfig.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(FilterOption filter) {
    final isActive = activeFilters.contains(filter.id);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isActive ? uiConfig.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onFilterToggle(filter.id),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? uiConfig.primaryColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter.icon,
                  size: 16,
                  color: isActive ? Colors.white : uiConfig.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  filter.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : uiConfig.textColor,
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