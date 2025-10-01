import 'package:flutter/material.dart';
import '../../models/room.dart';

class RoomQuickActionsDialog extends StatelessWidget {
  final Room room;
  final String userId;
  final VoidCallback onShowInfo;
  final VoidCallback onCopyLink;
  final VoidCallback onEditRoom;
  final VoidCallback onPinRoom;
  final VoidCallback onSetReminder;
  final VoidCallback onShareRoom;
  final VoidCallback onShowParticipants;
  final VoidCallback onReportRoom;

  const RoomQuickActionsDialog({
    super.key,
    required this.room,
    required this.userId,
    required this.onShowInfo,
    required this.onCopyLink,
    required this.onEditRoom,
    required this.onPinRoom,
    required this.onSetReminder,
    required this.onShareRoom,
    required this.onShowParticipants,
    required this.onReportRoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: SafeArea(
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.quickreply_rounded, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Быстрые действия',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    _buildQuickRoomActionItem(
                      context: context,
                      icon: Icons.info_outline_rounded,
                      label: 'Инфо',
                      color: Colors.blue,
                      onTap: onShowInfo,
                    ),
                    _buildQuickRoomActionItem(
                      context: context,
                      icon: Icons.link_rounded,
                      label: 'Ссылка',
                      color: Colors.green,
                      onTap: onCopyLink,
                    ),
                    if (room.canEdit(userId))
                      _buildQuickRoomActionItem(
                        context: context,
                        icon: Icons.edit_rounded,
                        label: 'Редакт.',
                        color: Colors.orange,
                        onTap: onEditRoom,
                      ),
                    if (room.canPin(userId))
                      _buildQuickRoomActionItem(
                        context: context,
                        icon: Icons.push_pin_rounded,
                        label: room.isPinned ? 'Открепить' : 'Закрепить',
                        color: Colors.purple,
                        onTap: onPinRoom,
                      ),
                    _buildQuickRoomActionItem(
                      context: context,
                      icon: Icons.notifications_rounded,
                      label: 'Напомнить',
                      color: Colors.teal,
                      onTap: onSetReminder,
                    ),
                    _buildQuickRoomActionItem(
                      context: context,
                      icon: Icons.share_rounded,
                      label: 'Поделиться',
                      color: Colors.indigo,
                      onTap: onShareRoom,
                    ),
                    _buildQuickRoomActionItem(
                      context: context,
                      icon: Icons.people_rounded,
                      label: 'Участники',
                      color: Colors.cyan,
                      onTap: onShowParticipants,
                    ),
                    _buildQuickRoomActionItem(
                      context: context,
                      icon: Icons.report_rounded,
                      label: 'Пожаловаться',
                      color: Colors.red,
                      onTap: onReportRoom,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoomActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      surfaceTintColor: color.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}