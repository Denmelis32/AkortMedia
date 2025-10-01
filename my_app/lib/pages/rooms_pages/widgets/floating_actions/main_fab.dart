import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/room_provider.dart';

class MainFab extends StatelessWidget {
  final AnimationController controller;
  final RoomProvider roomProvider;
  final VoidCallback onPressed;

  const MainFab({
    super.key,
    required this.controller,
    required this.roomProvider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: Badge(
          isLabelVisible: roomProvider.hasNewInvites,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          label: const Text('!'),
          offset: const Offset(4, -4),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }
}