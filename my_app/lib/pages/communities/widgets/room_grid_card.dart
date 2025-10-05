import 'package:flutter/material.dart';
import '../../rooms_pages/models/room.dart';


class RoomGridCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomGridCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар и статус
              Row(
                children: [
                  room.getRoomIcon(size: 32),
                  const Spacer(),
                  _buildStatusIndicator(),
                ],
              ),
              const SizedBox(height: 8),
              // Заголовок
              Text(
                room.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Участники
              Text(
                '${room.currentParticipants} участников',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              // Прогресс бар
              if (room.maxParticipants > 0)
                LinearProgressIndicator(
                  value: room.participationRate,
                  backgroundColor: Colors.grey[300],
                  color: room.statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: room.statusColor,
        shape: BoxShape.circle,
      ),
    );
  }
}