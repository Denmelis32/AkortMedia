import 'package:flutter/material.dart';
import '../event_model.dart';
import '../utils/screen_utils.dart';

class CategoriesSection extends StatelessWidget {
  final List<EventCategory> categories;
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;
  final Animation<double> fadeAnimation;

  const CategoriesSection({
    Key? key,
    required this.categories,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.fadeAnimation,
  }) : super(key: key);

  // 🆕 Метод для определения горизонтальных отступов как во втором файле
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  // 🆕 Метод для определения максимальной ширины контента как во втором файле
  double _getMaxContentWidth() => 1200;
  double _getMinContentWidth() => 320;

  // 🆕 Основной layout с фиксированной шириной как во втором файле
  Widget _buildDesktopLayout(Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getMaxContentWidth(),
          minWidth: _getMinContentWidth(),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final horizontalPadding = _getHorizontalPadding(context);

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        // 🆕 Убрали margin, так как контейнер уже имеет отступы
        child: isMobile
            ? _buildMobileCard()
            : _buildDesktopLayout(_buildDesktopCard(horizontalPadding)),
      ),
    );
  }

  // 🆕 Мобильная версия карточки
  Widget _buildMobileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Категории',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: categories
                      .map((category) => _buildCategoryChip(category, true))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🆕 Десктопная версия карточки
  Widget _buildDesktopCard(double horizontalPadding) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Категории',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(right: horizontalPadding),
                  children: categories
                      .map((category) => _buildCategoryChip(category, false))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(EventCategory category, bool isMobile) {
    final index = categories.indexOf(category);
    final isSelected = currentTabIndex == index;

    return Container(
      margin: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: Material(
        color: isSelected ? category.color : Colors.transparent,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: InkWell(
          onTap: () => onTabChanged(index),
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              border: Border.all(
                color: isSelected ? category.color : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: isMobile ? 14 : 16,
                  color: isSelected ? Colors.white : category.color,
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  _getCategoryTitle(category.title, isMobile),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🆕 Метод для сокращения длинных названий на мобильных
  String _getCategoryTitle(String title, bool isMobile) {
    if (!isMobile) return title;

    // Сокращаем длинные названия на мобильных
    final Map<String, String> shortTitles = {
      'Образование': 'Обучение',
      'Мастер-классы': 'МК',
      'Конференции': 'Конф.',
      'Выставки': 'Выставки',
      'Концерты': 'Концерты',
      'Фестивали': 'Фестивали',
      'Спорт': 'Спорт',
      'Театр': 'Театр',
      'Встречи': 'Встречи',
    };

    return shortTitles[title] ?? (title.length > 10 ? '${title.substring(0, 9)}...' : title);
  }
}