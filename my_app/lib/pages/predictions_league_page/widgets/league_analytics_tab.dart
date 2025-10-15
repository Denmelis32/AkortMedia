import 'package:flutter/material.dart';

class LeagueAnalyticsTab extends StatelessWidget {
  final List<Map<String, dynamic>> predictions;
  final List<Map<String, dynamic>> profitHistory;
  final double userPoints;

  const LeagueAnalyticsTab({
    super.key,
    required this.predictions,
    required this.profitHistory,
    required this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Общая статистика
          _buildStatsGrid(stats),
          const SizedBox(height: 16),

          // Распределение по типам ставок
          _buildBetTypeDistribution(stats),
          const SizedBox(height: 16),

          // Прогресс профита
          _buildProfitProgress(stats),
          const SizedBox(height: 16),

          // Рекомендации
          _buildRecommendations(stats),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    final totalPredictions = predictions.length;
    final completedPredictions = predictions.where((p) => p['result'] != null).length;
    final wins = predictions.where((p) => p['result'] == 'win').length;
    final losses = predictions.where((p) => p['result'] == 'lose').length;
    final active = predictions.where((p) => p['status'] == 'active').length;

    final successRate = completedPredictions > 0 ? (wins / completedPredictions * 100) : 0;

    final totalProfit = predictions
        .where((p) => p['result'] == 'win')
        .fold(0.0, (sum, p) => sum + (p['potentialWin'] - p['amount']));

    final totalInvested = predictions.fold(0.0, (sum, p) => sum + p['amount']);
    final roi = totalInvested > 0 ? (totalProfit / totalInvested * 100) : 0;

    // Распределение по типам ставок
    final betTypeStats = {};
    for (final prediction in predictions) {
      final type = prediction['type'];
      final isWin = prediction['result'] == 'win';

      if (!betTypeStats.containsKey(type)) {
        betTypeStats[type] = {'total': 0, 'wins': 0};
      }

      betTypeStats[type]['total']++;
      if (isWin) {
        betTypeStats[type]['wins']++;
      }
    }

    return {
      'totalPredictions': totalPredictions,
      'completedPredictions': completedPredictions,
      'wins': wins,
      'losses': losses,
      'active': active,
      'successRate': successRate,
      'totalProfit': totalProfit,
      'totalInvested': totalInvested,
      'roi': roi,
      'betTypeStats': betTypeStats,
    };
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      padding: const EdgeInsets.all(8),
      children: [
        _buildStatCard(
          'Успешность',
          '${stats['successRate'].toStringAsFixed(1)}%',
          Colors.blue,
          Icons.trending_up,
        ),
        _buildStatCard(
          'Общий профит',
          '${stats['totalProfit'].toStringAsFixed(2)}₽',
          Colors.green,
          Icons.attach_money,
        ),
        _buildStatCard(
          'ROI',
          '${stats['roi'].toStringAsFixed(1)}%',
          Colors.orange,
          Icons.analytics,
        ),
        _buildStatCard(
          'Ставок',
          '${stats['completedPredictions']}/${stats['totalPredictions']}',
          Colors.purple,
          Icons.list_alt,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBetTypeDistribution(Map<String, dynamic> stats) {
    final betTypeStats = stats['betTypeStats'] as Map;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Эффективность по типам ставок',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...betTypeStats.entries.map((entry) {
              final type = entry.key;
              final data = entry.value;
              final total = data['total'];
              final wins = data['wins'];
              final successRate = total > 0 ? (wins / total * 100) : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getBetTypeDisplayName(type),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '$wins/$total',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: successRate / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: successRate > 50 ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${successRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: successRate > 50 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitProgress(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Финансовый прогресс',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildProgressItem('Инвестировано', '${stats['totalInvested'].toStringAsFixed(2)}₽', Colors.blue),
                _buildProgressItem('Профит', '${stats['totalProfit'].toStringAsFixed(2)}₽',
                    stats['totalProfit'] >= 0 ? Colors.green : Colors.red),
                _buildProgressItem('Баланс', '${userPoints.toStringAsFixed(2)}₽', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.attach_money, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(Map<String, dynamic> stats) {
    final successRate = stats['successRate'];
    String recommendation = '';
    Color color = Colors.grey;

    if (successRate > 70) {
      recommendation = 'Отличные результаты! Продолжайте в том же духе.';
      color = Colors.green;
    } else if (successRate > 50) {
      recommendation = 'Хорошие показатели. Анализируйте ошибки для улучшения.';
      color = Colors.blue;
    } else if (successRate > 30) {
      recommendation = 'Есть над чем работать. Изучайте статистику команд.';
      color = Colors.orange;
    } else {
      recommendation = 'Рекомендуем начать с небольших ставок и обучения.';
      color = Colors.red;
    }

    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recommendation,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBetTypeDisplayName(String type) {
    switch (type) {
      case 'winner': return 'Победитель';
      case 'total': return 'Тоталы';
      case 'handicap': return 'Форы';
      case 'exact_score': return 'Точный счет';
      case 'double_chance': return 'Двойной шанс';
      case 'express': return 'Экспресс';
      default: return type;
    }
  }
}