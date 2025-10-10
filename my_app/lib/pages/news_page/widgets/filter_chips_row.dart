import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/news_state.dart';
import '../theme/news_theme.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  // Адаптивные методы как в CardsPage
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 80;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1200;
    if (width > 1000) return 900;
    if (width > 700) return 700;
    return double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final pageState = Provider.of<NewsPageState>(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);

    const filterOptions = ['Все новости', 'Популярные', 'Избранное', 'Подписки'];
    const filterIcons = [
      Icons.all_inclusive_rounded,
      Icons.trending_up_rounded,
      Icons.bookmark_rounded,
      Icons.subscriptions_rounded
    ];

    final List<Color> colors = [
      NewsTheme.primaryColor,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 12),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: List.generate(filterOptions.length, (index) {
              final isSelected = pageState.currentFilter == index;
              final color = colors[index % colors.length];

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < filterOptions.length - 1 ? 4 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        pageState.setFilter(isSelected ? 0 : index);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              filterIcons[index],
                              size: 16,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              filterOptions[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Альтернативная версия с равномерным распределением
class EqualWidthFilterChipsRow extends StatelessWidget {
  const EqualWidthFilterChipsRow({super.key});

  // Адаптивные методы как в CardsPage
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 80;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1200;
    if (width > 1000) return 900;
    if (width > 700) return 700;
    return double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final pageState = Provider.of<NewsPageState>(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);

    const filterOptions = ['Все', 'Популярные', 'Избранное', 'Подписки'];
    const filterIcons = [
      Icons.all_inclusive_rounded,
      Icons.trending_up_rounded,
      Icons.bookmark_rounded,
      Icons.subscriptions_rounded
    ];

    final List<Color> colors = [
      NewsTheme.primaryColor,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 12),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: List.generate(filterOptions.length, (index) {
              final isSelected = pageState.currentFilter == index;
              final color = colors[index % colors.length];

              return Expanded(
                child: Container(
                  height: 48,
                  margin: EdgeInsets.only(
                    right: index < filterOptions.length - 1 ? 4 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        pageState.setFilter(isSelected ? 0 : index);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              filterIcons[index],
                              size: 14,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              filterOptions[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}