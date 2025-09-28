import 'package:flutter/material.dart';
import '../models/room.dart';
import 'room_actions_menu.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onPin;
  final VoidCallback onReport;
  final int index;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onJoin,
    required this.onEdit,
    required this.onShare,
    required this.onPin,
    required this.onReport,
    required this.index,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovering = false;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _elevationAnimation = Tween<double>(begin: 2, end: 12).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white.withOpacity(0.4),
    ).animate(_animationController);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Задержка анимации появления для создания каскадного эффекта
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (!_isTapped) {
      setState(() => _isHovering = hovering);
      if (hovering) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isTapped = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isTapped = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isTapped = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onLongPress: _showEnhancedPreview,
          child: Card(
            elevation: _elevationAnimation.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: widget.room.category.color.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: _buildGradient(theme),
                border: Border.all(
                  color: _borderColorAnimation.value ?? Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  if (_glowAnimation.value > 0)
                    BoxShadow(
                      color: widget.room.category.color.withOpacity(0.2 * _glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Фоновый узор
                  _buildBackgroundPattern(),

                  // Градиентный оверлей
                  _buildGradientOverlay(),

                  // Основной контент
                  _buildContent(theme),

                  // Индикаторы статуса
                  _buildStatusIndicators(),

                  // Бейджи
                  _buildBadges(),

                  // Меню действий
                  _buildActionsMenu(),

                  // Эффект ховера
                  if (_isHovering) _buildHoverEffect(),

                  // Эффект нажатия
                  if (_isTapped) _buildTapEffect(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _buildGradient(ThemeData theme) {
    final baseColor = widget.room.category.color;

    if (widget.room.isPinned) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.9),
          baseColor.withOpacity(0.7),
          baseColor.withOpacity(0.6),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.8),
        baseColor.withOpacity(0.6),
        baseColor.withOpacity(0.4),
      ],
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: CustomPaint(
          painter: _GeometricPatternPainter(
            color: Colors.white,
            patternType: _getPatternType(),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.black.withOpacity(0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 16),
          _buildTitleSection(),
          const SizedBox(height: 12),
          _buildDescriptionSection(),
          const SizedBox(height: 12),
          _buildTagsSection(),
          const Spacer(),
          _buildStatsSection(),
          const SizedBox(height: 12),
          _buildCapacityIndicator(),
          const SizedBox(height: 16),
          _buildJoinButton(theme),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatarSection(),
        const Spacer(),
        _buildPrivacySection(),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Основной аватар
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(),
          ),
        ),

        // Бейдж участников
        _buildParticipantsBadge(),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (widget.room.imageUrl.isNotEmpty) {
      return Image.network(
        widget.room.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerEffect();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar();
        },
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        widget.room.category.icon,
        color: Colors.white.withOpacity(0.8),
        size: 24,
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Container(color: Colors.white),
    );
  }

  Widget _buildParticipantsBadge() {
    return Transform.translate(
      offset: const Offset(4, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, size: 10, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 2),
            Text(
              '${widget.room.currentParticipants}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Рейтинг
        if (widget.room.rating > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  widget.room.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 6),

        // Приватность и статусы
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          children: [
            if (widget.room.isPrivate)
              _buildMiniBadge(
                Icons.lock,
                'Приватная',
                Colors.orange,
              ),
            if (widget.room.requiresPassword)
              _buildMiniBadge(
                Icons.key,
                'Пароль',
                Colors.amber,
              ),
            if (widget.room.isVerified)
              _buildMiniBadge(
                Icons.verified,
                'Проверено',
                Colors.blue,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      widget.room.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescriptionSection() {
    return Text(
      widget.room.description,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 13,
        height: 1.4,
        letterSpacing: -0.1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTagsSection() {
    if (widget.room.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: widget.room.popularTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.chat_bubble_outline_rounded,
            widget.room.messageCount.formatCount(),
            'сообщений',
          ),
          _buildStatItem(
            Icons.access_time_rounded,
            widget.room.formattedLastActivity,
            'активность',
          ),
          _buildStatItem(
            Icons.visibility_outlined,
            widget.room.viewCount.formatCount(),
            'просмотров',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 12),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Заполненность:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              '${widget.room.availableSpots} мест свободно',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        widget.room.buildCapacityIndicator(height: 6),
      ],
    );
  }

  Widget _buildJoinButton(ThemeData theme) {
    final isDisabled = !widget.room.canJoin || widget.room.isExpired;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isHovering && !isDisabled
            ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : widget.onJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(theme),
          foregroundColor: _getButtonTextColor(theme),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildButtonIcon(),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _getButtonText(isDisabled),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                key: ValueKey('${widget.room.isJoined}_$isDisabled'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(ThemeData theme) {
    if (!widget.room.canJoin || widget.room.isExpired) {
      return Colors.white.withOpacity(0.1);
    }
    return widget.room.isJoined
        ? Colors.white.withOpacity(0.15)
        : Colors.white;
  }

  Color _getButtonTextColor(ThemeData theme) {
    if (!widget.room.canJoin || widget.room.isExpired) {
      return Colors.white.withOpacity(0.5);
    }
    return widget.room.isJoined
        ? Colors.white
        : widget.room.category.color;
  }

  Widget _buildButtonIcon() {
    final isDisabled = !widget.room.canJoin || widget.room.isExpired;

    if (isDisabled) {
      return Icon(Icons.lock, size: 18, key: const ValueKey('disabled'));
    }

    return Icon(
      widget.room.isJoined ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
      size: 18,
      key: ValueKey(widget.room.isJoined),
    );
  }

  String _getButtonText(bool isDisabled) {
    if (isDisabled) {
      if (widget.room.isExpired) return 'Завершена';
      if (widget.room.isFull) return 'Заполнена';
      if (!widget.room.isActive) return 'Неактивна';
      return 'Недоступна';
    }
    return widget.room.isJoined ? 'Вы участвуете' : 'Присоединиться';
  }

  Widget _buildStatusIndicators() {
    return Positioned(
      top: 12,
      left: 12,
      child: Wrap(
        spacing: 6,
        children: [
          if (widget.room.isPinned)
            _buildStatusBadge(
              'Закреплено',
              Icons.push_pin,
              Colors.amber,
            ),
          if (widget.room.isNew)
            _buildStatusBadge(
              'Новая',
              Icons.new_releases,
              Colors.green,
            ),
          if (widget.room.isTrending)
            _buildStatusBadge(
              'В тренде',
              Icons.trending_up,
              Colors.red,
            ),
          if (widget.room.hasMedia)
            _buildStatusBadge(
              'Медиа',
              Icons.photo_library,
              Colors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Positioned(
      top: 12,
      right: 50,
      child: Wrap(
        spacing: 6,
        children: widget.room.buildBadges(),
      ),
    );
  }

  Widget _buildActionsMenu() {
    return Positioned(
      top: 8,
      right: 8,
      child: RoomActionsMenu(
        room: widget.room,
        onEdit: widget.onEdit,
        onShare: widget.onShare,
        onPin: widget.onPin,
        onReport: widget.onReport,
      ),
    );
  }

  Widget _buildHoverEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildTapEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  void _showEnhancedPreview() {
    showDialog(
      context: context,
      builder: (context) => _EnhancedRoomPreviewDialog(
        room: widget.room,
        onJoin: widget.onJoin,
      ),
    );
  }

  PatternType _getPatternType() {
    final index = widget.index % 3;
    return PatternType.values[index];
  }
}

class _EnhancedRoomPreviewDialog extends StatelessWidget {
  final Room room;
  final VoidCallback onJoin;

  const _EnhancedRoomPreviewDialog({required this.room, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                room.category.color.withOpacity(0.95),
                room.category.color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced preview content would go here
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      room.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onJoin,
                      child: const Text('Присоединиться'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum PatternType { dots, lines, triangles }

class _GeometricPatternPainter extends CustomPainter {
  final Color color;
  final PatternType patternType;

  _GeometricPatternPainter({
    required this.color,
    required this.patternType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    switch (patternType) {
      case PatternType.dots:
        _paintDots(canvas, size, paint);
        break;
      case PatternType.lines:
        _paintLines(canvas, size, paint);
        break;
      case PatternType.triangles:
        _paintTriangles(canvas, size, paint);
        break;
    }
  }

  void _paintDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 20.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  void _paintLines(Canvas canvas, Size size, Paint paint) {
    const spacing = 15.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..strokeWidth = 0.5,
      );
    }
  }

  void _paintTriangles(Canvas canvas, Size size, Paint paint) {
    const spacing = 25.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final path = Path()
          ..moveTo(x, y)
          ..lineTo(x + 8, y + 4)
          ..lineTo(x, y + 8)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}