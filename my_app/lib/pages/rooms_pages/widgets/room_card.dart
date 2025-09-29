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

class _RoomCardState extends State<RoomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<Offset> _contentOffsetAnimation;

  bool _isHovering = false;
  bool _isTapped = false;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _elevationAnimation = Tween<double>(begin: 4, end: 16).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white.withOpacity(0.6),
    ).animate(_animationController);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _contentOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _contentOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Каскадная анимация появления
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
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

  void _toggleDescription() {
    setState(() {
      _showFullDescription = !_showFullDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              borderRadius: BorderRadius.circular(24),
            ),
            shadowColor: widget.room.category.color.withOpacity(0.4),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: _buildGradient(theme),
                border: Border.all(
                  color: _borderColorAnimation.value ?? Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  if (_glowAnimation.value > 0)
                    BoxShadow(
                      color: widget.room.category.color
                          .withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 25,
                      spreadRadius: 3,
                      offset: const Offset(0, 4),
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Фоновый узор с анимацией
                  _buildAnimatedBackground(),

                  // Градиентный оверлей
                  _buildGradientOverlay(),

                  // Стек контента с анимацией
                  SlideTransition(
                    position: _contentOffsetAnimation,
                    child: FadeTransition(
                      opacity: _contentOpacityAnimation,
                      child: _buildContentStack(theme),
                    ),
                  ),

                  // Эффекты взаимодействия
                  if (_isHovering) _buildHoverEffect(),
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
    final isPinned = widget.room.isPinned;

    if (isPinned) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.95),
          baseColor.withOpacity(0.8),
          baseColor.withOpacity(0.7),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.85),
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.5),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.white.withOpacity(_isHovering ? 0.1 : 0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _AnimatedGeometricPatternPainter(
            color: Colors.white.withOpacity(0.08),
            patternType: _getPatternType(),
            animationValue: _animationController.value,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentStack(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Верхняя секция с аватаром и действиями
          _buildTopSection(),

          const SizedBox(height: 20),

          // Секция заголовка и описания
          _buildTitleDescriptionSection(),

          const SizedBox(height: 16),

          // Секция тегов
          _buildTagsSection(),

          const Spacer(),

          // Секция статистики
          _buildStatsSection(),

          const SizedBox(height: 16),

          // Индикатор заполненности
          _buildCapacitySection(),

          const SizedBox(height: 20),

          // Кнопка присоединения
          _buildJoinButton(theme),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Аватар с эффектом
        _buildEnhancedAvatar(),

        const Spacer(),

        // Правая секция с рейтингом и действиями
        _buildRightSection(),
      ],
    );
  }

  Widget _buildEnhancedAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Основной аватар с градиентной рамкой
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: widget.room.category.color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(),
          ),
        ),

        // Бейдж онлайн-участников
        _buildOnlineBadge(),
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
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        widget.room.category.icon,
        color: Colors.white.withOpacity(0.9),
        size: 28,
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

  Widget _buildOnlineBadge() {
    return Transform.translate(
      offset: const Offset(6, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.room.currentParticipants}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Рейтинг с анимацией
        _buildRatingBadge(),

        const SizedBox(height: 8),

        // Бейджи приватности
        _buildPrivacyBadges(),

        const SizedBox(height: 12),

        // Меню действий
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

  Widget _buildRatingBadge() {
    if (widget.room.rating <= 0) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            widget.room.rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBadges() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        if (widget.room.isPrivate)
          _buildMiniBadge(
            Icons.lock_outline_rounded,
            'Приватная',
            Colors.orange,
          ),
        if (widget.room.requiresPassword)
          _buildMiniBadge(
            Icons.key_rounded,
            'Пароль',
            Colors.amber,
          ),
        if (widget.room.isVerified)
          _buildMiniBadge(
            Icons.verified_rounded,
            'Проверено',
            Colors.blue,
          ),
      ],
    );
  }

  Widget _buildMiniBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
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

  Widget _buildTitleDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Text(
          widget.room.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Описание с возможностью развернуть
        GestureDetector(
          onTap: _toggleDescription,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showFullDescription
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.room.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.room.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),

        if (widget.room.description.length > 100)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _showFullDescription ? 'Свернуть' : 'Развернуть...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    if (widget.room.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: widget.room.popularTags.take(4).map((tag) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isHovering ? 0.25 : 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
            boxShadow: [
              if (_isHovering)
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.chat_bubble_rounded,
            widget.room.messageCount.formatCount(),
            'сообщений',
            Colors.blue,
          ),
          _buildStatItem(
            Icons.access_time_filled_rounded,
            widget.room.formattedLastActivity,
            'активность',
            Colors.green,
          ),
          _buildStatItem(
            Icons.visibility_rounded,
            widget.room.viewCount.formatCount(),
            'просмотров',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Заполненность комнаты:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${widget.room.availableSpots} из ${widget.room.maxParticipants} мест',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Кастомный индикатор заполненности
        _buildCustomCapacityIndicator(),
      ],
    );
  }

  Widget _buildCustomCapacityIndicator() {
    final percentage = widget.room.currentParticipants / widget.room.maxParticipants;
    final isAlmostFull = percentage > 0.8;

    return Stack(
      children: [
        // Фон индикатора
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Заполненная часть
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          height: 8,
          width: MediaQuery.of(context).size.width * percentage * 0.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAlmostFull
                  ? [Colors.red, Colors.orange]
                  : [Colors.green, Colors.lightGreen],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: (isAlmostFull ? Colors.red : Colors.green).withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(ThemeData theme) {
    final isDisabled = !widget.room.canJoin || widget.room.isExpired;
    final isJoined = widget.room.isJoined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isHovering && !isDisabled
            ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: widget.room.category.color.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : widget.onJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(isDisabled, isJoined),
          foregroundColor: _getButtonTextColor(isDisabled, isJoined),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildButtonIcon(isDisabled, isJoined),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _getButtonText(isDisabled, isJoined),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
                key: ValueKey('${isJoined}_$isDisabled'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      return Colors.white.withOpacity(0.15);
    }
    if (isJoined) {
      return Colors.white.withOpacity(0.2);
    }
    return Colors.white;
  }

  Color _getButtonTextColor(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      return Colors.white.withOpacity(0.5);
    }
    if (isJoined) {
      return Colors.white;
    }
    return widget.room.category.color;
  }

  Widget _buildButtonIcon(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      return Icon(Icons.lock_rounded, size: 20, key: const ValueKey('disabled'));
    }

    return Icon(
      isJoined ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
      size: 20,
      key: ValueKey(isJoined ? 'joined' : 'join'),
    );
  }

  String _getButtonText(bool isDisabled, bool isJoined) {
    if (isDisabled) {
      if (widget.room.isExpired) return 'Завершена';
      if (widget.room.isFull) return 'Заполнена';
      if (!widget.room.isActive) return 'Неактивна';
      return 'Недоступна';
    }
    return isJoined ? 'Вы в комнате' : 'Присоединиться сейчас';
  }

  Widget _buildHoverEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.white.withOpacity(0.1),
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
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withOpacity(0.15),
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
          constraints: const BoxConstraints(maxWidth: 500),
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
                color: Colors.black.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced preview content would go here
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      room.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: room.category.color,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Присоединиться',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
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
      case PatternType.lines:
        _paintAnimatedLines(canvas, size, paint);
        break;
      case PatternType.triangles:
        _paintAnimatedTriangles(canvas, size, paint);
        break;
    }
  }

  void _paintAnimatedDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 25.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final offset = (x / spacing + y / spacing) * 0.1;
        final alpha = ((animationValue + offset) % 1.0) * 0.5;
        canvas.drawCircle(
          Offset(x, y),
          dotRadius,
          paint..color = color.withOpacity(alpha),
        );
      }
    }
  }

  void _paintAnimatedLines(Canvas canvas, Size size, Paint paint) {
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      final alpha = 0.1 + (x / size.width) * 0.2;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint
          ..color = color.withOpacity(alpha * animationValue)
          ..strokeWidth = 0.8,
      );
    }
  }

  void _paintAnimatedTriangles(Canvas canvas, Size size, Paint paint) {
    const spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final offset = (x / spacing + y / spacing) * 0.2;
        final alpha = 0.1 + ((animationValue + offset) % 1.0) * 0.3;

        final path = Path()
          ..moveTo(x, y)
          ..lineTo(x + 10, y + 5)
          ..lineTo(x, y + 10)
          ..close();

        canvas.drawPath(
          path,
          paint..color = color.withOpacity(alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}