import 'package:flutter/material.dart';

class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final ScrollController? scrollController; // Добавляем опциональный параметр

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.tooltip,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.scrollController, // Делаем опциональным
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Инициализируем контроллер анимации
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Инициализируем анимацию масштаба
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Опционально: добавляем слушатель скролла для скрытия FAB
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Можно добавить логику скрытия/показа FAB при скролле
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton(
          onPressed: null, // handled by gesture detector
          tooltip: widget.tooltip,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Icon(widget.icon, size: 28),
        ),
      ),
    );
  }
}