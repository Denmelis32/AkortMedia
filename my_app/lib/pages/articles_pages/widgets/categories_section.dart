import 'package:flutter/material.dart';
import 'package:my_app/pages/articles_pages/models/article_category.dart';
import 'package:my_app/pages/articles_pages/services/layout_service.dart';

class CategoriesSection extends StatelessWidget {
  final List<ArticleCategory> categories;
  final int currentTabIndex;
  final ValueChanged<int> onCategoryChanged;
  final bool isMobile;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.currentTabIndex,
    required this.onCategoryChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : LayoutService.getHorizontalPadding(context),
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
                  'Категории',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87, // Темный текст для контраста
                  ),
                ),
              ),
              const SizedBox(height: 8),
              isMobile ? _buildMobileCategories(context) : _buildDesktopCategories(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCategories(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) => _buildMobileCategoryChip(context, categories[index], index),
      ),
    );
  }

  Widget _buildDesktopCategories(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        categories.length,
            (index) => _buildDesktopCategoryChip(context, categories[index], index),
      ),
    );
  }

  Widget _buildMobileCategoryChip(BuildContext context, ArticleCategory category, int index) {
    final isSelected = currentTabIndex == index;

    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onCategoryChanged(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey.shade300, // Светло-серая граница
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 14, color: isSelected ? Colors.white : category.color),
                const SizedBox(width: 4),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87, // Темный текст
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade100, // Светло-серый фон
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.articleCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700, // Темно-серый текст
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCategoryChip(BuildContext context, ArticleCategory category, int index) {
    final isSelected = currentTabIndex == index;

    return Material(
      color: isSelected ? category.color : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onCategoryChanged(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? category.color : Colors.grey.shade300, // Светло-серая граница
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, size: 16, color: isSelected ? Colors.white : category.color),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87, // Темный текст
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade100, // Светло-серый фон
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.articleCount.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700, // Темно-серый текст
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}