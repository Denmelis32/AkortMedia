// widgets/category_chip.dart
import 'package:flutter/material.dart';
import '../models/room.dart';

class CategoryChip extends StatefulWidget {
  final RoomCategory category;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onSelected,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(theme),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getBorderColor(theme),
                    width: _isHovered ? 1.5 : 1.0,
                  ),
                  boxShadow: _getBoxShadow(theme),
                  gradient: _getGradient(theme),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Иконка категории
                    Icon(
                      widget.category.icon,
                      size: 18,
                      color: _getIconColor(theme),
                    ),
                    const SizedBox(width: 8),

                    // Название категории
                    Text(
                      widget.category.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getTextColor(theme),
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),

                    // Индикатор выбора
                    if (widget.isSelected) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getIconColor(theme),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.isSelected) {
      return Color.lerp(
        theme.colorScheme.surface,
        widget.category.color.withOpacity(0.15),
        _colorAnimation.value,
      )!;
    } else if (_isHovered) {
      return theme.colorScheme.surfaceVariant.withOpacity(0.5);
    }
    return theme.colorScheme.surface.withOpacity(0.7);
  }

  Color _getBorderColor(ThemeData theme) {
    if (widget.isSelected) {
      return Color.lerp(
        theme.colorScheme.outline.withOpacity(0.2),
        widget.category.color.withOpacity(0.4),
        _colorAnimation.value,
      )!;
    } else if (_isHovered) {
      return theme.colorScheme.primary.withOpacity(0.3);
    }
    return theme.colorScheme.outline.withOpacity(0.2);
  }

  Color _getIconColor(ThemeData theme) {
    if (widget.isSelected) {
      return Color.lerp(
        theme.colorScheme.onSurface.withOpacity(0.6),
        widget.category.color,
        _colorAnimation.value,
      )!;
    }
    return theme.colorScheme.onSurface.withOpacity(0.6);
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.isSelected) {
      return Color.lerp(
        theme.colorScheme.onSurface,
        theme.colorScheme.onSurface,
        _colorAnimation.value,
      )!;
    }
    return theme.colorScheme.onSurface.withOpacity(0.8);
  }

  List<BoxShadow> _getBoxShadow(ThemeData theme) {
    if (widget.isSelected) {
      return [
        BoxShadow(
          color: widget.category.color.withOpacity(0.2 * _colorAnimation.value),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (_isHovered) {
      return [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];
    }
    return [
      BoxShadow(
        color: theme.colorScheme.shadow.withOpacity(0.05),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  Gradient? _getGradient(ThemeData theme) {
    if (widget.isSelected) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.category.color.withOpacity(0.1 * _colorAnimation.value),
          widget.category.color.withOpacity(0.05 * _colorAnimation.value),
        ],
      );
    }
    return null;
  }
}

// Дополнительный компонент для отображения всех категорий в виде красивого списка
class CategoryFilterBar extends StatelessWidget {
  final RoomCategory selectedCategory;
  final ValueChanged<RoomCategory> onCategorySelected;
  final bool showAllCategory;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showAllCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    final categories = RoomCategory.values.where(
            (category) => showAllCategory || category != RoomCategory.all
    ).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((category) {
          return CategoryChip(
            category: category,
            isSelected: selectedCategory == category,
            onSelected: () => onCategorySelected(category),
          );
        }).toList(),
      ),
    );
  }
}

// Компактная версия для мобильных устройств
class CompactCategoryChip extends StatelessWidget {
  final RoomCategory category;
  final bool isSelected;
  final VoidCallback onSelected;

  const CompactCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withOpacity(0.15)
              : theme.colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? category.color.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 20,
              color: isSelected
                  ? category.color
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              category.title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? category.color
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Вертикальный список категорий для боковой панели
class CategorySidebar extends StatelessWidget {
  final RoomCategory selectedCategory;
  final ValueChanged<RoomCategory> onCategorySelected;

  const CategorySidebar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1, // Добавляем ширину
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: RoomCategory.values.map((category) {
          final isSelected = selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCategorySelected(category),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}