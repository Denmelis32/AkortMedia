import 'package:flutter/material.dart';
import '../models/prediction_league.dart';

class LeagueDescriptionTab extends StatelessWidget {
  final PredictionLeague league;

  const LeagueDescriptionTab({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          league.description,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Детальное описание:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          league.detailedDescription,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Правила участия:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildRuleItem('Минимальная ставка: ${league.minBet.toInt()}₽'),
        _buildRuleItem('Максимальная ставка: ${league.maxBet.toInt()}₽'),
        _buildRuleItem('Комиссия платформы: 5%'),
        _buildRuleItem('Вывод средств: от 100₽'),
        _buildRuleItem('Максимум в экспрессе: 5 ставок'),
        _buildRuleItem('Отмена ставки: до начала события'),
      ],
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(rule),
        ],
      ),
    );
  }
}