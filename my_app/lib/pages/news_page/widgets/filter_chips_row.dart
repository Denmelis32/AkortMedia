import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/news_state.dart';
import '../theme/news_theme.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final pageState = Provider.of<NewsPageState>(context);

    const filterOptions = ['Все новости', 'Мои новости', 'Популярные', 'Избранное', 'Подписки'];
    const filterIcons = [
      Icons.all_inclusive_rounded,
      Icons.person_rounded,
      Icons.trending_up_rounded,
      Icons.bookmark_rounded,
      Icons.subscriptions_rounded
    ];

    final List<Color> gradientColors = [
      NewsTheme.primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NewsTheme.cardColor.withOpacity(0.95),
            NewsTheme.cardColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: NewsTheme.primaryColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: NewsTheme.cardColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(filterOptions.length, (index) {
            final isSelected = pageState.currentFilter == index;
            final color = gradientColors[index % gradientColors.length];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : NewsTheme.textColor,
                  ),
                  child: Text(filterOptions[index]),
                ),
                avatar: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                    )
                        : null,
                    color: isSelected ? null : NewsTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : Border.all(color: NewsTheme.secondaryTextColor.withOpacity(0.2)),
                  ),
                  child: Icon(
                    filterIcons[index],
                    size: 16,
                    color: isSelected ? Colors.white : NewsTheme.secondaryTextColor,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  pageState.setFilter(selected ? index : 0);
                  // Анимация при выборе
                  if (selected) {
                    _playSelectionAnimation(context);
                  }
                },
                selectedColor: color,
                backgroundColor: Colors.transparent,
                checkmarkColor: Colors.white,
                showCheckmark: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: isSelected
                        ? color.withOpacity(0.3)
                        : NewsTheme.secondaryTextColor.withOpacity(0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                elevation: isSelected ? 3 : 0,
                shadowColor: isSelected ? color.withOpacity(0.3) : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          }),
        ),
      ),
    );
  }

  void _playSelectionAnimation(BuildContext context) {
    // Можно добавить haptic feedback или небольшую анимацию
    // HapticFeedback.lightImpact();
  }
}

// ДОПОЛНИТЕЛЬНО: Альтернативная версия с улучшенной анимацией
class AdvancedFilterChipsRow extends StatefulWidget {
  const AdvancedFilterChipsRow({super.key});

  @override
  State<AdvancedFilterChipsRow> createState() => _AdvancedFilterChipsRowState();
}

class _AdvancedFilterChipsRowState extends State<AdvancedFilterChipsRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageState = Provider.of<NewsPageState>(context);

    const filterOptions = ['Все новости', 'Мои новости', 'Популярные', 'Избранное', 'Подписки'];
    const filterIcons = [
      Icons.all_inclusive_rounded,
      Icons.person_rounded,
      Icons.trending_up_rounded,
      Icons.bookmark_rounded,
      Icons.subscriptions_rounded
    ];

    final List<LinearGradient> gradients = [
      LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
      LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]),
      LinearGradient(colors: [Colors.orange.shade600, Colors.orange.shade400]),
      LinearGradient(colors: [Colors.purple.shade600, Colors.purple.shade400]),
      LinearGradient(colors: [Colors.red.shade600, Colors.red.shade400]),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: NewsTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: NewsTheme.cardColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(filterOptions.length, (index) {
            final isSelected = pageState.currentFilter == index;
            final gradient = gradients[index % gradients.length];

            return GestureDetector(
              onTap: () {
                _animationController.forward(from: 0);
                pageState.setFilter(isSelected ? 0 : index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? gradient : null,
                  color: isSelected ? null : NewsTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : NewsTheme.secondaryTextColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filterIcons[index],
                      size: 18,
                      color: isSelected ? Colors.white : NewsTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filterOptions[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : NewsTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

