import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class ChatAnimations {
  final TickerProvider vsync;

  late AnimationController pinnedMessagesController;
  late Animation<double> pinnedMessagesAnimation;
  late AnimationController typingAnimationController;
  late TabController tabController;

  ChatAnimations({required this.vsync});

  void initializeAnimations() {
    pinnedMessagesController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    pinnedMessagesAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: pinnedMessagesController, curve: Curves.easeInOut),
    );

    typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    )..repeat(reverse: true);

    tabController = TabController(length: 4, vsync: vsync);
  }

  void dispose() {
    pinnedMessagesController.dispose();
    typingAnimationController.dispose();
    tabController.dispose();
  }
}