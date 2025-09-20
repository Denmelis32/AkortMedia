// lib/widgets/news/smart_refresher.dart
import 'package:flutter/material.dart';

class SmartRefresher extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const SmartRefresher({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.blue,
      backgroundColor: Colors.white,
      child: child,
    );
  }
}

class WaterDropHeader extends StatelessWidget {
  final Color waterDropColor;
  final Widget complete;

  const WaterDropHeader({
    super.key,
    required this.waterDropColor,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Просто возвращаем пустой виджет
  }
}