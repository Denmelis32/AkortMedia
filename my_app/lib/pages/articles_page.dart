// lib/pages/articles_page.dart
import 'package:flutter/material.dart';

class ArticlesPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const ArticlesPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок


          // Контент статей
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Заглушка - здесь будет ваш контент статей
                    _buildArticleCard(
                      'Тактика игры Манчестер Сити',
                      'Анализ тактических схем Пеп Гвардиолы в сезоне 2024/2025',
                      '📊',
                    ),
                    const SizedBox(height: 16),
                    _buildArticleCard(
                      'Лучшие молодые таланты',
                      'Обзор самых перспективных молодых футболистов Европы',
                      '⭐',
                    ),
                    const SizedBox(height: 16),
                    _buildArticleCard(
                      'История Лиги Чемпионов',
                      'От истоков до современных дней великого турнира',
                      '🏆',
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String description, String emoji) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '1.2K',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '345',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '2 дня назад',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}