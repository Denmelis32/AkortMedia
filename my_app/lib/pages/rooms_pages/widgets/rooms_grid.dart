import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/room_provider.dart';
import '../models/room.dart';
import '../utils/layout_utils.dart';
import '../utils/room_utils.dart';
import 'room_card/room_card.dart';

class RoomsGrid extends StatelessWidget {
  final List<Room> rooms;
  final RoomProvider roomProvider;
  final double horizontalPadding;
  final bool isMobile;
  final Function(Room) onRoomTap;
  final Function(Room, RoomProvider) onRoomJoinToggle;
  final LayoutUtils layoutUtils;
  final RoomUtils roomUtils;

  const RoomsGrid({
    super.key,
    required this.rooms,
    required this.roomProvider,
    required this.horizontalPadding,
    required this.isMobile,
    required this.onRoomTap,
    required this.onRoomJoinToggle,
    required this.layoutUtils,
    required this.roomUtils,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chat_rounded, size: 48, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Комнаты не найдены',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: layoutUtils.textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить параметры поиска\nили выбрать другую категорию',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= rooms.length) return const SizedBox.shrink();
            final room = rooms[index];
            return RoomCard(
              room: room,
              index: index,
              roomProvider: roomProvider,
              layoutUtils: layoutUtils,
              roomUtils: roomUtils,
              onRoomTap: () => onRoomTap(room),
              onRoomJoinToggle: () => onRoomJoinToggle(room, roomProvider),
            );
          },
          childCount: rooms.length,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: layoutUtils.getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 360 / 460,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= rooms.length) return const SizedBox.shrink();
            final room = rooms[index];
            return Padding(
              padding: const EdgeInsets.all(2),
              child: RoomCard(
                room: room,
                index: index,
                roomProvider: roomProvider,
                layoutUtils: layoutUtils,
                roomUtils: roomUtils,
                onRoomTap: () => onRoomTap(room),
                onRoomJoinToggle: () => onRoomJoinToggle(room, roomProvider),
              ),
            );
          },
          childCount: rooms.length,
        ),
      ),
    );
  }
}