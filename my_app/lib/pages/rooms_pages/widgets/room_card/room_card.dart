import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../models/room.dart';
import '../../utils/layout_utils.dart';
import '../../utils/room_utils.dart';
import 'mobile_room_card.dart';
import 'desktop_room_card.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final int index;
  final RoomProvider roomProvider;
  final LayoutUtils layoutUtils;
  final RoomUtils roomUtils;
  final VoidCallback onRoomTap;
  final VoidCallback onRoomJoinToggle;

  const RoomCard({
    super.key,
    required this.room,
    required this.index,
    required this.roomProvider,
    required this.layoutUtils,
    required this.roomUtils,
    required this.onRoomTap,
    required this.onRoomJoinToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = layoutUtils.isMobile(context);

    return isMobile
        ? MobileRoomCard(
      room: room,
      index: index,
      roomProvider: roomProvider,
      layoutUtils: layoutUtils,
      roomUtils: roomUtils,
      onRoomTap: onRoomTap,
      onRoomJoinToggle: onRoomJoinToggle,
    )
        : DesktopRoomCard(
      room: room,
      index: index,
      roomProvider: roomProvider,
      layoutUtils: layoutUtils,
      roomUtils: roomUtils,
      onRoomTap: onRoomTap,
      onRoomJoinToggle: onRoomJoinToggle,
    );
  }
}