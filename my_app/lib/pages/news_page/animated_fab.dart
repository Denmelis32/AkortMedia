import 'package:flutter/material.dart';
import 'theme/news_theme.dart';

class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;
  final ScrollController scrollController;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.tooltip,
    required this.icon,
    required this.scrollController,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (widget.scrollController.positions.isNotEmpty) {
      final position = widget.scrollController.position;
      if (position.pixels > 100 && _isVisible) {
        setState(() => _isVisible = false);
      } else if (position.pixels <= 100 && !_isVisible) {
        setState(() => _isVisible = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        backgroundColor: NewsTheme.primaryColor,
        foregroundColor: Colors.white,
        child: Icon(widget.icon),
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }
}