import 'package:flutter/material.dart';
import '../models/standing_model.dart';

class StandingsWidget extends StatelessWidget {
  final List<Standing> standings;

  const StandingsWidget({
    super.key,
    required this.standings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Турнирная таблица',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: standings.length,
          itemBuilder: (context, index) {
            final standing = standings[index];
            return _buildStandingItem(standing, index);
          },
        ),
      ],
    );
  }

  Widget _buildStandingItem(Standing standing, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Позиция
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getPositionColor(standing.position),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${standing.position}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Имя пользователя
          Expanded(
            child: Text(
              standing.userName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // Очки
          Text(
            '${standing.points} очков',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(width: 12),

          // Точность
          Text(
            '${standing.accuracy.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position <= 3) return Colors.green;
    if (position <= 10) return Colors.blue;
    return Colors.grey;
  }
}