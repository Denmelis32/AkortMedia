import 'package:flutter/material.dart';
import '../../models/room.dart';

class RoomPreviewDialog extends StatelessWidget {
  final Room room;
  final VoidCallback? onJoin;

  const RoomPreviewDialog({
    super.key,
    required this.room,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme),
            const SizedBox(height: 20),
            _buildRoomInfo(theme),
            const SizedBox(height: 20),
            _buildRoomStats(theme),
            const SizedBox(height: 20),
            _buildRoomTags(theme),
            const SizedBox(height: 24),
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Аватар комнаты с бейджами
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: room.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: room.category.color.withOpacity(0.3)),
              ),
              child: Icon(
                room.category.icon,
                color: room.category.color,
                size: 32,
              ),
            ),
            // Бейджи статуса
            if (room.isPinned)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.push_pin, size: 12, color: Colors.white),
                ),
              ),
            if (room.isVerified)
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.verified, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    room.category.icon,
                    size: 14,
                    color: room.category.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.category.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: room.category.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Закрыть',
        ),
      ],
    );
  }

  Widget _buildRoomInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            room.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.people,
            'Участники',
            '${room.currentParticipants}/${room.maxParticipants}',
            theme,
          ),
          _buildStatItem(
            Icons.chat,
            'Сообщения',
            room.messageCount.formatCount(),
            theme,
          ),
          _buildStatItem(
            Icons.star,
            'Рейтинг',
            room.rating.toStringAsFixed(1),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: theme.primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTags(ThemeData theme) {
    if (room.tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Теги',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: room.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Text(
                '#$tag',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    final canJoin = room.canJoin && !room.isExpired;
    final isFull = room.isFull;
    final isExpired = room.isExpired;
    final isInactive = !room.isActive;

    String joinButtonText;
    Color joinButtonColor;
    bool joinButtonEnabled = true;

    if (isExpired) {
      joinButtonText = 'Завершена';
      joinButtonColor = Colors.grey;
      joinButtonEnabled = false;
    } else if (isFull) {
      joinButtonText = 'Заполнена';
      joinButtonColor = Colors.orange;
      joinButtonEnabled = false;
    } else if (isInactive) {
      joinButtonText = 'Неактивна';
      joinButtonColor = Colors.red;
      joinButtonEnabled = false;
    } else if (room.requiresPassword) {
      joinButtonText = 'Войти с паролем';
      joinButtonColor = theme.primaryColor;
    } else if (room.isScheduled) {
      joinButtonText = 'Запланирована';
      joinButtonColor = Colors.blue;
    } else {
      joinButtonText = 'Присоединиться';
      joinButtonColor = theme.primaryColor;
    }

    return Column(
      children: [
        // Информация о статусе
        if (!canJoin) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: joinButtonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: joinButtonColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: joinButtonColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusMessage(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: joinButtonColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Кнопки действий
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Поделиться'), // Добавлен label
                onPressed: () => _shareRoom(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: joinButtonEnabled ? () {
                  Navigator.of(context).pop(); // Исправлено на Navigator.of(context)
                  onJoin?.call();
                } : null,
                style: FilledButton.styleFrom(
                  backgroundColor: joinButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(joinButtonText),
              ),
            ),
          ],
        ),

        // Дополнительная информация
        if (room.isScheduled && !room.isExpired) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  'Начнется ${room.formattedStartTime}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  IconData _getStatusIcon() {
    if (room.isExpired) return Icons.event_busy;
    if (room.isFull) return Icons.person_off;
    if (!room.isActive) return Icons.pause_circle;
    return Icons.info;
  }

  String _getStatusMessage() {
    if (room.isExpired) return 'Эта комната завершена и больше не активна';
    if (room.isFull) return 'Комната заполнена. Достигнут лимит участников';
    if (!room.isActive) return 'Комната временно неактивна';
    if (room.requiresPassword) return 'Для входа требуется пароль';
    if (room.isScheduled) return 'Комната начнется в указанное время';
    return 'Доступна для присоединения';
  }

  void _shareRoom(BuildContext context) {
    // Имитация шаринга
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на "${room.title}" скопирована'),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {},
        ),
      ),
    );
  }
}