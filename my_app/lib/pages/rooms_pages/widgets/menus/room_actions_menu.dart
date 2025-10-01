import 'package:flutter/material.dart';
import '../../models/room.dart';

class RoomActionsMenu extends StatelessWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onPin;
  final VoidCallback onReport;

  const RoomActionsMenu({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onShare,
    required this.onPin,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        if (room.isOwner)
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text('Редактировать'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.share, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Поделиться'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.push_pin, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(room.isPinned ? 'Открепить' : 'Закрепить'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(Icons.report, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Пожаловаться'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 1:
            onEdit();
            break;
          case 2:
            onShare();
            break;
          case 3:
            onPin();
            break;
          case 4:
            onReport();
            break;
        }
      },
    );
  }
}