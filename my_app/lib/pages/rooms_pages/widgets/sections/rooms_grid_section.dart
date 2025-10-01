import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/room_provider.dart';
import '../../models/room.dart';
import '../cards/animated_room_card.dart';
import '../empty_states/rooms_empty_state.dart';

class RoomsGridSection extends StatelessWidget {
  final RoomProvider roomProvider;
  final bool isSearchExpanded;
  final Function(Room) onRoomTap;
  final Function(Room) onRoomLongPress;

  const RoomsGridSection({
    super.key,
    required this.roomProvider,
    required this.isSearchExpanded,
    required this.onRoomTap,
    required this.onRoomLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (roomProvider.isLoading && roomProvider.filteredRooms.isEmpty) {
      return _buildLoadingState(context);
    }

    final rooms = roomProvider.filteredRooms;

    if (rooms.isEmpty) {
      return SliverFillRemaining(
        child: RoomsEmptyState(
          roomProvider: roomProvider,
          isSearchExpanded: isSearchExpanded,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
        top: 8,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final gridDelegate = _buildGridDelegate(constraints.crossAxisExtent);

          return SliverGrid(
            gridDelegate: gridDelegate,
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final room = rooms[index];
                return AnimatedRoomCard(
                  room: room,
                  index: index,
                  onTap: () => onRoomTap(room),
                  onJoin: () => roomProvider.toggleJoinRoom(room.id),
                  onLongPress: () => onRoomLongPress(room),
                );
              },
              childCount: rooms.length,
            ),
          );
        },
      ),
    );
  }

  SliverGridDelegate _buildGridDelegate(double maxWidth) {
    final crossAxisCount = _calculateCrossAxisCount(maxWidth);
    final childAspectRatio = _calculateChildAspectRatio(maxWidth);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
    );
  }

  int _calculateCrossAxisCount(double maxWidth) {
    if (maxWidth > 1000) return 4;
    if (maxWidth > 800) return 3;
    if (maxWidth > 600) return 2;
    return 1;
  }

  double _calculateChildAspectRatio(double maxWidth) {
    if (maxWidth > 1000) return 0.9;
    if (maxWidth > 800) return 0.85;
    if (maxWidth > 600) return 0.75;
    return 1.1;
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Загрузка комнат...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}