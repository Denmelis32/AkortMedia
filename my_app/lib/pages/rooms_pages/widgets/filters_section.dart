import 'package:flutter/material.dart';
import '../models/filter_option.dart';
import '../utils/layout_utils.dart';

class FiltersSection extends StatelessWidget {
  final bool showFilters;
  final Set<String> activeFilters;
  final Function(String) onFilterToggle;
  final LayoutUtils layoutUtils;
  final bool isMobile;

  const FiltersSection({
    super.key,
    required this.showFilters,
    required this.activeFilters,
    required this.onFilterToggle,
    required this.layoutUtils,
    required this.isMobile,
  });

  List<FilterOption> get _filterOptions {
    return [
      const FilterOption(id: 'active', title: 'Только активные', icon: Icons.online_prediction),
      const FilterOption(id: 'joined', title: 'Мои комнаты', icon: Icons.subscriptions),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!showFilters) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : layoutUtils.getHorizontalPadding(context),
        vertical: 4,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: layoutUtils.surfaceColor,
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
                    color: layoutUtils.textColor,
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
                  children: _filterOptions.map((filter) => _buildFilterChip(filter)).toList(),
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
        color: isActive ? layoutUtils.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onFilterToggle(filter.id),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? layoutUtils.primaryColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter.icon,
                  size: 16,
                  color: isActive ? Colors.white : layoutUtils.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  filter.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : layoutUtils.textColor,
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