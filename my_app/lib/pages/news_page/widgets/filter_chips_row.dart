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
            color: const Color(0xFFF1F5F9), // Светлый серо-голубой фон
            borderRadius: BorderRadius.circular(16), // Всегда закругленные углы
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: List.generate(filterOptions.length, (index) {
              final isSelected = pageState.currentFilter == index;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < filterOptions.length - 1 ? 6 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        pageState.setFilter(index);
                      },
                      borderRadius: BorderRadius.circular(12), // Всегда закругленные углы
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.15),
                              const Color(0xFF8B5CF6).withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ) : null,
                          color: isSelected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(12), // Всегда закругленные углы
                          border: isSelected ? Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.25),
                            width: 1.5,
                          ) : Border.all(
                            color: Colors.grey.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6366F1).withOpacity(0.1)
                                    : Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                filterIcons[index],
                                size: 16,
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              filterOptions[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey[800],
                                letterSpacing: -0.1,
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