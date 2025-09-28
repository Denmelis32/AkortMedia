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

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onJoin,
    required this.onEdit,
    required this.onShare,
    required this.onPin,
    required this.onReport,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 8, end: 16).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() => _isHovering = hovering);
    if (hovering) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => _showRoomPreview(context),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Card(
            elevation: widget.room.isPinned ? 20 : _elevationAnimation.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: _buildGradient(),
                border: widget.room.isPinned
                    ? Border.all(color: Colors.amber, width: 2.5)
                    : _isHovering
                    ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)
                    : null,
                boxShadow: [
                  if (_isHovering)
                    BoxShadow(
                      color: widget.room.category.color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  _buildBackgroundPattern(),
                  _buildContent(context),
                  _buildStatusIndicators(),
                  _buildActionsMenu(),
                  _buildHoverOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _buildGradient() {
    final colors = [
      widget.room.category.color.withOpacity(0.95),
      widget.room.category.color.withOpacity(0.85),
      widget.room.category.color.withOpacity(0.75),
    ];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: widget.room.isPinned
          ? colors.map((c) => c.withOpacity(0.9)).toList()
          : colors,
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: CustomPaint(
          painter: _DotsPatternPainter(
            color: Colors.white,
            dotRadius: 1.0,
            spacing: 20.0,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 16),
          _buildTitleSection(),
          const SizedBox(height: 8),
          _buildDescriptionSection(),
          const Spacer(),
          _buildStatsSection(),
          const SizedBox(height: 16),
          _buildJoinButton(context),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        _buildAvatarSection(),
        const Spacer(),
        _buildPrivacyBadge(),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Main avatar with shimmer effect
        Container(
          width: 60,
          height: 60,
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
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              widget.room.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildShimmerEffect();
              },
              errorBuilder: (context, error, stackTrace) {
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
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
        _buildParticipantsBadge(),
      ],
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
      child: Container(
        color: Colors.white,
      ),
    );
  }

  Widget _buildParticipantsBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 10, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 4),
          Text(
            widget.room.participants.formatCount(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.room.isPrivate)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, size: 12, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 4),
                Text(
                  'Приватная',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (widget.room.requiresPassword)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.key, size: 10, color: Colors.black),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Text(
      widget.room.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescriptionSection() {
    return Text(
      widget.room.description,
      style: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 13,
        height: 1.4,
        letterSpacing: -0.1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
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
            widget.room.messages.formatCount(),
            'сообщений',
          ),
          _buildStatItem(
            Icons.access_time_rounded,
            _formatLastActivity(),
            'активность',
          ),
          if (widget.room.isOwner)
            _buildStatItem(
              Icons.star_rounded,
              '',
              'Ваша',
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
            if (value.isNotEmpty) ...[
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

  Widget _buildJoinButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isHovering
            ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: widget.onJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.room.isJoined
              ? Colors.white.withOpacity(0.15)
              : Colors.white,
          foregroundColor: widget.room.isJoined
              ? Colors.white
              : widget.room.category.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                widget.room.isJoined
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                size: 18,
                key: ValueKey(widget.room.isJoined),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.room.isJoined ? 'Вы участвуете' : 'Присоединиться',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                key: ValueKey(widget.room.isJoined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicators() {
    return Positioned(
      top: 12,
      left: 12,
      child: Row(
        children: [
          if (widget.room.isPinned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.push_pin, size: 10, color: Colors.black),
                  const SizedBox(width: 2),
                  Text(
                    'Закреплено',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (_isNewRoom)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.new_releases, size: 8, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Новая',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
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

  Widget _buildHoverOverlay() {
    return AnimatedOpacity(
      opacity: _isHovering ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  bool get _isNewRoom {
    return DateTime.now().difference(widget.room.lastActivity).inMinutes < 30;
  }

  void _showRoomPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RoomPreviewDialog(room: widget.room, onJoin: widget.onTap),
    );
  }

  String _formatLastActivity() {
    final difference = DateTime.now().difference(widget.room.lastActivity);
    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes}м';
    if (difference.inHours < 24) return '${difference.inHours}ч';
    return '${difference.inDays}д';
  }
}

class _RoomPreviewDialog extends StatelessWidget {
  final Room room;
  final VoidCallback onJoin;

  const _RoomPreviewDialog({required this.room, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              room.category.color.withOpacity(0.95),
              room.category.color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
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
            // Preview content would go here
            // Similar to your existing preview but enhanced
          ],
        ),
      ),
    );
  }
}

class _DotsPatternPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  _DotsPatternPainter({
    required this.color,
    required this.dotRadius,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}