// widgets/animated_room_card.dart
import 'package:flutter/material.dart';
import '../models/room.dart';

class AnimatedRoomCard extends StatefulWidget {
  final Room room;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onLongPress;

  const AnimatedRoomCard({
    super.key,
    required this.room,
    required this.index,
    required this.onTap,
    required this.onJoin,
    required this.onLongPress,
  });

  @override
  State<AnimatedRoomCard> createState() => _AnimatedRoomCardState();
}

class _AnimatedRoomCardState extends State<AnimatedRoomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 150)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(1),
                child: Card(
                  elevation: _isHovered ? 12 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.black.withOpacity(0.15),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _getCardGradient(theme),
                    ),
                    child: Stack(
                      children: [
                        // Основной контент
                        _buildCardContent(theme),

                        // Бейджи статуса
                        _buildStatusBadges(theme),

                        // Эффект ховера
                        if (_isHovered) _buildHoverOverlay(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getCardGradient(ThemeData theme) {
    if (widget.room.isPinned) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.amber.shade50,
          theme.colorScheme.surface,
        ],
      );
    } else if (widget.room.isJoined) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primaryContainer.withOpacity(0.3),
          theme.colorScheme.surface,
        ],
      );
    } else if (_isHovered) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surfaceVariant,
          theme.colorScheme.surface,
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.surface,
        theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ],
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и категория
          _buildHeader(theme),

          const SizedBox(height: 12),

          // Описание
          _buildDescription(theme),

          const SizedBox(height: 16),

          // Теги
          _buildTags(theme),

          const Spacer(),

          // Статистика и кнопка
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Иконка категории
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.room.category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.room.category.icon,
            size: 18,
            color: widget.room.category.color,
          ),
        ),

        const SizedBox(width: 12),

        // Заголовок
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                widget.room.category.title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      widget.room.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(ThemeData theme) {
    if (widget.room.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.room.popularTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            '#$tag',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        // Статистика в одну строку
        _buildStatsRow(theme),

        const SizedBox(height: 12),

        // Прогресс бар и кнопка
        Row(
          children: [
            Expanded(
              child: _buildCapacityIndicator(theme),
            ),

            const SizedBox(width: 12),

            // Кнопка присоединения
            _buildJoinButton(theme),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        // Участники
        _buildStatItem(
          Icons.people_rounded,
          '${widget.room.currentParticipants}/${widget.room.maxParticipants}',
          theme,
        ),

        const Spacer(),

        // Сообщения
        _buildStatItem(
          Icons.chat_bubble_outline_rounded,
          widget.room.messageCount.formatCount(),
          theme,
        ),

        const Spacer(),

        // Активность
        _buildStatItem(
          Icons.access_time_rounded,
          widget.room.formattedLastActivity,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityIndicator(ThemeData theme) {
    final percentage = widget.room.participationRate;

    Color color;
    if (percentage < 0.5) {
      color = Colors.green.shade600;
    } else if (percentage < 0.8) {
      color = Colors.orange.shade600;
    } else {
      color = Colors.red.shade600;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Заполненность',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Container(
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(ThemeData theme) {
    final isJoined = widget.room.isJoined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isJoined
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isJoined
              ? theme.colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isJoined ? Icons.check_rounded : Icons.add_rounded,
            size: 16,
            color: isJoined
                ? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            isJoined ? 'Вход' : 'Войти',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isJoined
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadges(ThemeData theme) {
    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.room.isPinned) _buildBadge('Закреплено', Icons.push_pin, Colors.amber.shade600, theme),
          if (widget.room.isJoined)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildBadge('Вы в комнате', Icons.check, theme.colorScheme.primary, theme),
            ),
          if (!widget.room.isActive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildBadge('Неактивно', Icons.pause, Colors.grey.shade600, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.primary.withOpacity(0.02),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 2,
          ),
        ),
      ),
    );
  }
}