import 'package:flutter/material.dart';

class LeagueLeaderboardTab extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;
  final String prizePool;

  const LeagueLeaderboardTab({
    super.key,
    required this.leaderboard,
    required this.prizePool,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.leaderboard, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Турнирная таблица',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Призовой фонд: $prizePool',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...leaderboard.map((player) => _buildLeaderboardItem(player)),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> player) {
    final isCurrentUser = player['isCurrentUser'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.withOpacity(0.1) : Colors.white,
        border: isCurrentUser ? Border.all(color: Colors.blue) : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ранг
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getRankColor(player['rank']),
              shape: BoxShape.circle,
            ),
            child: Text(
              player['rank'].toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Аватар и имя
          Text(
            player['avatar'],
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['username'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser ? Colors.blue : Colors.black,
                  ),
                ),
                Text(
                  'Точность: ${player['accuracy']}%',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Статистика
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player['points']} очков',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '+${player['profit']}₽',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Тренд
          const SizedBox(width: 8),
          Icon(
            player['trend'] == 'up' ? Icons.trending_up : Icons.trending_down,
            color: player['trend'] == 'up' ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // Gold
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFCD7F32); // Bronze
      default: return Colors.blue;
    }
  }
}