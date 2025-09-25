import 'package:flutter/material.dart';

class RoomStatsDialog extends StatelessWidget {
  final Map<String, dynamic> stats;

  const RoomStatsDialog({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика сообщества',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildStatItem('Всего комнат', stats['totalRooms'].toString(), Icons.forum),
            _buildStatItem('Активных комнат', stats['activeRooms'].toString(), Icons.people),
            _buildStatItem('Всего участников', stats['totalParticipants'].toString(), Icons.person),
            _buildStatItem('Средний рейтинг', stats['averageRating'], Icons.star),
            _buildStatItem('Закрепленных', stats['pinnedRooms'].toString(), Icons.push_pin),
            _buildStatItem('Запланированных', stats['scheduledRooms'].toString(), Icons.schedule),
            const SizedBox(height: 20),
            Align(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}