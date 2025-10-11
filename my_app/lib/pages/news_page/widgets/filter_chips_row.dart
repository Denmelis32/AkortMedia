import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/news_state.dart';
import '../theme/news_theme.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  // TWITTER-LIKE АДАПТИВНЫЕ МЕТОДЫ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280; // Twitter-like для больших экранов
    if (width > 700) return 80;   // Для планшетов
    return 16;                    // Для мобильных
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;  // Twitter-like максимальная ширина
    if (width > 1000) return 600;
    if (width > 700) return 600;
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
      margin: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 10), // Более компактные отступы
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          padding: const EdgeInsets.all(8), // Более компактный
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Более скругленные углы
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), // Более легкая тень
                blurRadius: 6,
                offset: const Offset(0, 2),
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
                    right: index < filterOptions.length - 1 ? 3 : 0, // Более компактный spacing
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        pageState.setFilter(isSelected ? 0 : index);
                      },
                      borderRadius: BorderRadius.circular(8), // Более скругленные углы
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5), // Более компактный
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.withOpacity(0.15), // Более прозрачная граница
                            width: 1, // Более тонкая граница
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              filterIcons[index],
                              size: 14, // Более компактная иконка
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(height: 1), // Более компактный spacing
                            Text(
                              filterOptions[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9, // Более мелкий шрифт
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

  // TWITTER-LIKE АДАПТИВНЫЕ МЕТОДЫ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280; // Twitter-like для больших экранов
    if (width > 700) return 80;   // Для планшетов
    return 16;                    // Для мобильных
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;  // Twitter-like максимальная ширина
    if (width > 1000) return 600;
    if (width > 700) return 600;
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
      margin: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 10), // Более компактные отступы
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          padding: const EdgeInsets.all(8), // Более компактный
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Более скругленные углы
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), // Более легкая тень
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(filterOptions.length, (index) {
              final isSelected = pageState.currentFilter == index;
              final color = colors[index % colors.length];

              return Expanded(
                child: Container(
                  height: 40, // Более компактный
                  margin: EdgeInsets.only(
                    right: index < filterOptions.length - 1 ? 3 : 0, // Более компактный spacing
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        pageState.setFilter(isSelected ? 0 : index);
                      },
                      borderRadius: BorderRadius.circular(6), // Более скругленные углы
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.withOpacity(0.12), // Более прозрачная граница
                            width: 1, // Более тонкая граница
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              filterIcons[index],
                              size: 12, // Более компактная иконка
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(height: 1), // Более компактный spacing
                            Text(
                              filterOptions[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8, // Более мелкий шрифт
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