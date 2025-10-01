import 'package:flutter/material.dart';

class QuickActionsFab extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onPressed;

  const QuickActionsFab({
    super.key,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: controller,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          mini: true,
          child: const Icon(Icons.flash_on_rounded, size: 20),
        ),
      ),
    );
  }
}