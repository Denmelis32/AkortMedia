import 'package:flutter/material.dart';
import '../models/room_category.dart';
import '../utils/layout_utils.dart';

class CategoriesSection extends StatelessWidget {
  final String selectedCategoryId;
  final Function(String) onCategorySelected;
  final LayoutUtils layoutUtils;
  final bool isMobile;

  const CategoriesSection({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.layoutUtils,
    required this.isMobile,
  });

  List<RoomCategory> get _categories {
    return [
      RoomCategory(id: 'all', title: 'Все', icon: Icons.explore, color: const Color(0xFF26A69A)),
      RoomCategory(id: 'technology', title: 'Технологии', icon: Icons.memory, color: Colors.orange),
      RoomCategory(id: 'business', title: 'Бизнес', icon: Icons.business_center, color: const Color(0xFF9C27B0)),
      RoomCategory(id: 'education', title: 'Образование', icon: Icons.school, color: Colors.teal),
      RoomCategory(id: 'entertainment', title: 'Развлечения', icon: Icons.movie, color: Colors.pink),
      RoomCategory(id: 'sports', title: 'Спорт', icon: Icons.sports_soccer, color: Colors.red),
      RoomCategory(id: 'music', title: 'Музыка', icon: Icons.music_note, color: Colors.green),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                  'Категории',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: layoutUtils.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
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

  Widget _buildMobileCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildMobileCategoryChip(category);
        },
      ),
    );
  }

  Widget _buildDesktopCategories() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) => _buildDesktopCategoryChip(category)).toList(),
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
                    color: isSelected ? Colors.white : layoutUtils.textColor,
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
                  color: isSelected ? Colors.white : layoutUtils.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}