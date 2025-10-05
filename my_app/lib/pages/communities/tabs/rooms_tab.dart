import 'package:flutter/material.dart';
import '../models/community.dart';
import '../widgets/room_card.dart';

class RoomsTab extends StatelessWidget {
  final Community community;

  const RoomsTab({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    if (community.rooms.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: community.rooms.length,
      itemBuilder: (context, index) => RoomCard(room: community.rooms[index]),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Пока нет комнат',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}