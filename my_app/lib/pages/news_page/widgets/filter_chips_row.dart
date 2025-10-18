import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/news_state.dart';
import '../theme/news_theme.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 0;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final pageState = Provider.of<NewsPageState>(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final isMobile = MediaQuery.of(context).size.width <= 700;

    const filterOptions = ['Все новости', 'Мои новости', 'Популярные', 'Избранное', 'Подписки'];
    const filterIcons = [
      Icons.all_inclusive_rounded,
      Icons.person_rounded,
      Icons.trending_up_rounded,
      Icons.bookmark_rounded,
      Icons.subscriptions_rounded
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        horizontalPadding,
        8,
        horizontalPadding,
        8,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(filterOptions.length, (index) {
              final isSelected = pageState.currentFilter == index;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < filterOptions.length - 1 ? 8 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Просто устанавливаем фильтр - не переключаем на "все"
                        pageState.setFilter(index);
                      },
                      borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? NewsTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(8),
                          border: isSelected ? Border.all(
                            color: NewsTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ) : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              filterIcons[index],
                              size: 18,
                              color: isSelected ? NewsTheme.primaryColor : Colors.grey[600],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              filterOptions[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? NewsTheme.primaryColor : Colors.black87,
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