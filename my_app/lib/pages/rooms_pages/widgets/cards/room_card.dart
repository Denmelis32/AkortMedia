import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../models/room.dart';
import '../menus/room_actions_menu.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onPin;
  final VoidCallback onReport;
  final VoidCallback onQuickJoin;
  final int index;
  final bool isFeatured;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onJoin,
    required this.onEdit,
    required this.onShare,
    required this.onPin,
    required this.onReport,
    required this.onQuickJoin,
    required this.index,
    this.isFeatured = false,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late ConfettiController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<Offset> _contentOffsetAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shineAnimation;

  bool _isHovering = false;
  bool _isTapped = false;
  bool _showFullDescription = false;
  bool _isBookmarked = false;
  bool _isQuickJoining = false;
  double _dragOffset = 0.0;
  int _reactionCount = 0;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _startEntranceAnimation();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _shineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  void _initializeAnimations() {
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _elevationAnimation = Tween<double>(begin: 6, end: 20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white.withOpacity(0.8),
    ).animate(_animationController);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _contentOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _contentOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 30),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
  }

  void _startEntranceAnimation() {
    Future.delayed(Duration(milliseconds: widget.index * 120), () {
      if (mounted) {
        _animationController.forward();
      }
    });
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

    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < const Duration(milliseconds: 300)) {
      _handleQuickJoin();
    } else {
      widget.onTap();
    }
    _lastTap = now;
  }

  void _onTapCancel() {
    setState(() => _isTapped = false);
    _animationController.reverse();
  }

  void _handleQuickJoin() async {
    if (!widget.room.canJoin || widget.room.isExpired) return;

    setState(() => _isQuickJoining = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isQuickJoining = false;
        _reactionCount++;
      });
      _confettiController.play();
      widget.onQuickJoin();
    }
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
  }

  void _toggleDescription() {
    setState(() => _showFullDescription = !_showFullDescription);
  }

  void _addReaction() {
    setState(() => _reactionCount++);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    _confettiController.dispose();
    super.dispose();
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
          onLongPress: _toggleBookmark,
          onDoubleTap: _handleQuickJoin,
          child: Stack(
            children: [
              if (_confettiController.state == ConfettiControllerState.playing)
                Positioned.fill(
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: -pi / 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.3,
                    shouldLoop: false,
                    colors: const [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                    ],
                  ),
                ),

              Card(
                elevation: _elevationAnimation.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                shadowColor: widget.room.category.color.withOpacity(0.5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: _buildEnhancedGradient(theme),
                    border: Border.all(
                      color: _borderColorAnimation.value ?? Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      if (_glowAnimation.value > 0)
                        BoxShadow(
                          color: widget.room.category.color
                              .withOpacity(0.4 * _glowAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 6),
                        ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      _buildAnimatedBackground(),
                      if (widget.isFeatured) _buildFeaturedShineEffect(),
                      _buildEnhancedGradientOverlay(),
                      SlideTransition(
                        position: _contentOffsetAnimation,
                        child: FadeTransition(
                          opacity: _contentOpacityAnimation,
                          child: _buildEnhancedContent(theme),
                        ),
                      ),
                      if (_isHovering) _buildHoverEffect(),
                      if (_isTapped) _buildTapEffect(),
                      if (_isQuickJoining) _buildQuickJoinOverlay(),
                    ],
                  ),
                ),
              ),

              if (widget.isFeatured) _buildFeaturedBadge(),
              if (_isBookmarked) _buildBookmarkBadge(),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _buildEnhancedGradient(ThemeData theme) {
    final baseColor = widget.room.category.color;
    final isPinned = widget.room.isPinned;

    if (isPinned) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.98),
          baseColor.withOpacity(0.85),
          baseColor.withOpacity(0.75),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.9),
        baseColor.withOpacity(0.75),
        baseColor.withOpacity(0.6),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.8,
            colors: [
              Colors.white.withOpacity(_isHovering ? 0.15 : 0.08),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _AnimatedGeometricPatternPainter(
            color: Colors.white.withOpacity(0.12),
            patternType: _getPatternType(),
            animationValue: _pulseController.value,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedShineEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shineAnimation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Transform.translate(
              offset: Offset(_shineAnimation.value * 400 - 200, 0),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.transparent,
              Colors.black.withOpacity(0.4),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedTopSection(),
          const SizedBox(height: 22),
          _buildEnhancedTitleDescription(),
          const SizedBox(height: 18),
          _buildEnhancedTagsSection(),
          const Spacer(),
          _buildEnhancedStatsSection(),
          const SizedBox(height: 18),
          _buildEnhancedCapacitySection(),
          const SizedBox(height: 22),
          _buildEnhancedJoinButton(theme),
        ],
      ),
    );
  }

  Widget _buildEnhancedTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _addReaction,
          child: _buildEnhancedAvatar(),
        ),
        const Spacer(),
        _buildEnhancedRightSection(),
      ],
    );
  }

  Widget _buildEnhancedAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.2),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: widget.room.category.color.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildEnhancedAvatarContent(),
            ),
          ),
          _buildEnhancedOnlineBadge(),
          if (_reactionCount > 0) _buildReactionBadge(),
        ],
      ),
    );
  }

  Widget _buildEnhancedAvatarContent() {
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
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.2),
          ],
        ),
      ),
      child: Icon(
        widget.room.category.icon,
        color: Colors.white.withOpacity(0.95),
        size: 32,
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Container(color: Colors.white),
    );
  }

  Widget _buildEnhancedOnlineBadge() {
    return Transform.translate(
      offset: const Offset(8, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.8),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.room.currentParticipants}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionBadge() {
    return Positioned(
      top: -5,
      left: -5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$_reactionCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildEnhancedRatingBadge(),
        const SizedBox(height: 10),
        _buildEnhancedPrivacyBadges(),
        const SizedBox(height: 14),
        RoomActionsMenu(
          room: widget.room,
          onEdit: widget.onEdit,
          onShare: widget.onShare,
          onPin: widget.onPin,
          onReport: widget.onReport,
        ),
      ],
    );
  }

  Widget _buildEnhancedRatingBadge() {
    if (widget.room.rating <= 0) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.amber.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            widget.room.rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '(${widget.room.ratingCount})',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPrivacyBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      children: [
        if (widget.room.isPrivate)
          _buildEnhancedMiniBadge(
            Icons.lock_outline_rounded,
            'Приватная',
            Colors.orange,
          ),
        if (widget.room.requiresPassword)
          _buildEnhancedMiniBadge(
            Icons.key_rounded,
            'Пароль',
            Colors.amber,
          ),
        if (widget.room.isVerified)
          _buildEnhancedMiniBadge(
            Icons.verified_rounded,
            'Проверено',
            Colors.blue,
          ),
        if (widget.room.isPinned)
          _buildEnhancedMiniBadge(
            Icons.push_pin_rounded,
            'Закреплено',
            Colors.red,
          ),
      ],
    );
  }

  Widget _buildEnhancedMiniBadge(IconData icon, String text, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTitleDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.room.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.8,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _toggleDescription,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 400),
            crossFadeState: _showFullDescription
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.room.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.room.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (widget.room.description.length > 100)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  _showFullDescription
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _showFullDescription ? 'Свернуть' : 'Развернуть',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedTagsSection() {
    if (widget.room.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: widget.room.popularTags.take(5).map((tag) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isHovering ? 0.3 : 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              if (_isHovering)
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedStatsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEnhancedStatItem(
            Icons.chat_bubble_rounded,
            _formatCount(widget.room.messageCount),
            'сообщений',
            Colors.blue,
          ),
          _buildEnhancedStatItem(
            Icons.access_time_filled_rounded,
            _getFormattedLastActivity(),
            'активность',
            Colors.green,
          ),
          _buildEnhancedStatItem(
            Icons.visibility_rounded,
            _formatCount(_getViewCount()),
            'просмотров',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  // Вспомогательные методы для совместимости
  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  int _getViewCount() => widget.room.viewCount ?? 0;

  String _getFormattedLastActivity() {
    final now = DateTime.now();
    final difference = now.difference(widget.room.lastActivity);

    if (difference.inMinutes < 1) return 'Только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин';
    if (difference.inHours < 24) return '${difference.inHours} ч';
    return '${difference.inDays} дн';
  }

  Widget _buildEnhancedStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Заполненность:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${_getAvailableSpots()} из ${widget.room.maxParticipants} мест',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildEnhancedCapacityIndicator(),
      ],
    );
  }

  int _getAvailableSpots() => widget.room.maxParticipants - widget.room.currentParticipants;

  Widget _buildEnhancedCapacityIndicator() {
    final percentage = widget.room.currentParticipants / widget.room.maxParticipants;
    final isAlmostFull = percentage > 0.8;
    final isHalfFull = percentage > 0.5;

    return Stack(
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          height: 10,
          width: MediaQuery.of(context).size.width * percentage * 0.35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAlmostFull
                  ? [Colors.red, Colors.orangeAccent]
                  : isHalfFull
                  ? [Colors.orange, Colors.yellow]
                  : [Colors.green, Colors.lightGreenAccent],
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: (isAlmostFull ? Colors.red : isHalfFull ? Colors.orange : Colors.green)
                    .withOpacity(0.6),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        if (_isHovering) _buildCapacityDots(percentage),
      ],
    );
  }

  Widget _buildCapacityDots(double percentage) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dotCount = (constraints.maxWidth / 15).floor();
          return Row(
            children: List.generate(dotCount, (index) {
              final dotPosition = index / dotCount;
              final isActive = dotPosition <= percentage;

              return Expanded(
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300 + index * 100),
                    width: isActive ? 4 : 2,
                    height: isActive ? 4 : 2,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedJoinButton(ThemeData theme) {
    final isDisabled = !_canJoin();
    final isJoined = widget.room.isJoined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _isHovering && !isDisabled
            ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: widget.room.category.color.withOpacity(0.8),
            blurRadius: 25,
            spreadRadius: 4,
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : widget.onJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getEnhancedButtonColor(isDisabled, isJoined),
          foregroundColor: _getEnhancedButtonTextColor(isDisabled, isJoined),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildEnhancedButtonIcon(isDisabled, isJoined),
            ),
            const SizedBox(width: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _getEnhancedButtonText(isDisabled, isJoined),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.5,
                ),
                key: ValueKey('${isJoined}_$isDisabled'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canJoin() {
    return widget.room.isActive &&
        !_isFull() &&
        !_isExpired();
  }

  bool _isFull() => widget.room.currentParticipants >= widget.room.maxParticipants;

  bool _isExpired() => widget.room.lastActivity.isBefore(
      DateTime.now().subtract(const Duration(hours: 24))
  );

  Color _getEnhancedButtonColor(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      return Colors.white.withOpacity(0.2);
    }
    if (isJoined) {
      return Colors.white.withOpacity(0.25);
    }
    return Colors.white;
  }

  Color _getEnhancedButtonTextColor(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      return Colors.white.withOpacity(0.6);
    }
    if (isJoined) {
      return Colors.white;
    }
    return widget.room.category.color;
  }

  Widget _buildEnhancedButtonIcon(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      return const Icon(Icons.lock_rounded, size: 22, key: ValueKey('disabled'));
    }
    if (_isQuickJoining) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(widget.room.category.color),
        ),
      );
    }

    return Icon(
      isJoined ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
      size: 22,
      key: ValueKey(isJoined ? 'joined' : 'join'),
    );
  }

  String _getEnhancedButtonText(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      if (_isExpired()) return 'Завершена';
      if (_isFull()) return 'Заполнена';
      if (!widget.room.isActive) return 'Неактивна';
      return 'Недоступна';
    }
    return isJoined ? 'Вы в комнате' : 'Присоединиться сейчас';
  }

  Widget _buildHoverEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTapEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.black.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildQuickJoinOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.black.withOpacity(0.4),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'Featured',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.bookmark_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  PatternType _getPatternType() {
    final index = widget.index % 3;
    return PatternType.values[index];
  }
}

enum PatternType { dots, waves, hexagons }

class _AnimatedGeometricPatternPainter extends CustomPainter {
  final Color color;
  final PatternType patternType;
  final double animationValue;

  _AnimatedGeometricPatternPainter({
    required this.color,
    required this.patternType,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    switch (patternType) {
      case PatternType.dots:
        _paintAnimatedDots(canvas, size, paint);
        break;
      case PatternType.waves:
        _paintAnimatedWaves(canvas, size, paint);
        break;
      case PatternType.hexagons:
        _paintAnimatedHexagons(canvas, size, paint);
        break;
    }
  }

  void _paintAnimatedDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 30.0;
    const dotRadius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final offset = (x / spacing + y / spacing) * 0.15;
        final alpha = 0.05 + ((animationValue + offset) % 1.0) * 0.2;
        canvas.drawCircle(
          Offset(x, y),
          dotRadius,
          paint..color = color.withOpacity(alpha),
        );
      }
    }
  }

  void _paintAnimatedWaves(Canvas canvas, Size size, Paint paint) {
    const waveCount = 8;
    final waveHeight = size.height / waveCount;

    for (int i = 0; i < waveCount; i++) {
      final path = Path();
      final baseY = i * waveHeight;
      final amplitude = waveHeight * 0.3;
      const frequency = 0.02;

      path.moveTo(0, baseY);

      for (double x = 0; x < size.width; x += 1) {
        final y = baseY + sin(x * frequency + animationValue * 2 * pi) * amplitude;
        path.lineTo(x, y);
      }

      final alpha = 0.03 + (i / waveCount) * 0.1;
      canvas.drawPath(
        path,
        paint
          ..color = color.withOpacity(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  void _paintAnimatedHexagons(Canvas canvas, Size size, Paint paint) {
    const radius = 20.0;
    const horizontalSpacing = radius * 1.5;
    const verticalSpacing = radius * 1.732;

    for (double x = -radius; x < size.width + radius; x += horizontalSpacing) {
      for (double y = -radius; y < size.height + radius; y += verticalSpacing) {
        // ИСПРАВЛЕННАЯ СТРОКА:
        final offsetX = ((y / verticalSpacing).floor() % 2 == 0) ? 0 : horizontalSpacing / 2;
        final hexX = x + offsetX;

        final offset = (hexX / horizontalSpacing + y / verticalSpacing) * 0.1;
        final alpha = 0.03 + ((animationValue + offset) % 1.0) * 0.15;

        _drawHexagon(canvas, Offset(hexX, y), radius, paint..color = color.withOpacity(alpha));
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = 2.0 * pi * i / 6;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}