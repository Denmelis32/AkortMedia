import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/prediction_model.dart';

class MatchPredictionCard extends StatelessWidget {
  final Match match;
  final Prediction? userPrediction;
  final VoidCallback onPredict;

  const MatchPredictionCard({
    super.key,
    required this.match,
    this.userPrediction,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок матча
            Text(
              match.matchTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Время матча
            Text(
              '${match.formattedDate} ${match.formattedTime}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            // Прогноз пользователя или кнопка
            if (userPrediction != null) _buildPredictionInfo()
            else _buildPredictButton(context),

            // Статус матча
            if (match.status != 'scheduled') _buildMatchStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ваш прогноз: ${userPrediction!.homeScore}:${userPrediction!.awayScore}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),

        if (userPrediction!.points > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Набрано очков: ${userPrediction!.points}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPredictButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPredict,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'СДЕЛАТЬ ПРОГНОЗ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMatchStatus() {
    Color statusColor;
    String statusText;

    switch (match.status) {
      case 'live':
        statusColor = Colors.red;
        statusText = 'LIVE';
        break;
      case 'finished':
        statusColor = Colors.green;
        statusText = 'ЗАВЕРШЕН';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'СКОРО';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}