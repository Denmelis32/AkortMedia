import 'package:flutter/material.dart';
import '../theme/news_theme.dart';

class EmptyNewsState extends StatelessWidget {
  final VoidCallback onCreateNews;
  final String title;
  final String description;
  final IconData icon;

  const EmptyNewsState({
    super.key,
    required this.onCreateNews,
    this.title = 'Лента пустая',
    this.description = 'Будьте первым, кто поделится интересной новостью!',
    this.icon = Icons.article_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: NewsTheme.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: NewsTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: NewsTheme.secondaryTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onCreateNews,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Создать первую новость'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NewsTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoResultsState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;

  const NoResultsState({
    super.key,
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: NewsTheme.secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ничего не найдено',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: NewsTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isEmpty
                  ? 'Попробуйте изменить фильтр или создать новую новость'
                  : 'По запросу "$searchQuery" ничего не найдено',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: NewsTheme.secondaryTextColor,
              ),
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onClearSearch,
                child: const Text('Очистить поиск'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}