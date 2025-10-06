import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/news_state.dart';
import '../theme/news_theme.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final pageState = Provider.of<NewsPageState>(context);

    const filterOptions = ['Все новости', 'Мои новости', 'Популярные', 'Избранное'];
    const filterIcons = [Icons.all_inclusive, Icons.person, Icons.trending_up, Icons.bookmark];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: NewsTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(filterOptions.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(filterOptions[index]),
                avatar: Icon(filterIcons[index], size: 18),
                selected: pageState.currentFilter == index,
                onSelected: (selected) => pageState.setFilter(selected ? index : pageState.currentFilter),
                selectedColor: NewsTheme.primaryColor,
                labelStyle: TextStyle(
                  color: pageState.currentFilter == index ? Colors.white : NewsTheme.textColor,
                ),
                backgroundColor: NewsTheme.cardColor,
                showCheckmark: false,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: pageState.currentFilter == index ? NewsTheme.primaryColor : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}