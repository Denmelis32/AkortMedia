import 'package:flutter/material.dart';

class QuickActionsDialog extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final VoidCallback onShowFilters;
  final VoidCallback onShowSort;
  final VoidCallback onShowStats;
  final VoidCallback onShowNotifications;
  final VoidCallback onRefreshRooms;

  const QuickActionsDialog({
    super.key,
    required this.onCreateRoom,
    required this.onShowFilters,
    required this.onShowSort,
    required this.onShowStats,
    required this.onShowNotifications,
    required this.onRefreshRooms,
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
                    Icon(Icons.flash_on_rounded, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      'Быстрые действия',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickActionItem(
                      context: context, // Передаем context
                      icon: Icons.add_rounded,
                      label: 'Создать',
                      color: theme.primaryColor,
                      onTap: onCreateRoom,
                    ),
                    _buildQuickActionItem(
                      context: context, // Передаем context
                      icon: Icons.tune_rounded,
                      label: 'Фильтры',
                      color: Colors.blue,
                      onTap: onShowFilters,
                    ),
                    _buildQuickActionItem(
                      context: context, // Передаем context
                      icon: Icons.sort_rounded,
                      label: 'Сортировка',
                      color: Colors.green,
                      onTap: onShowSort,
                    ),
                    _buildQuickActionItem(
                      context: context, // Передаем context
                      icon: Icons.analytics_rounded,
                      label: 'Статистика',
                      color: Colors.orange,
                      onTap: onShowStats,
                    ),
                    _buildQuickActionItem(
                      context: context, // Передаем context
                      icon: Icons.notifications_rounded,
                      label: 'Уведомления',
                      color: Colors.purple,
                      onTap: onShowNotifications,
                    ),
                    _buildQuickActionItem(
                      context: context, // Передаем context
                      icon: Icons.refresh_rounded,
                      label: 'Обновить',
                      color: Colors.teal,
                      onTap: onRefreshRooms,
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

  Widget _buildQuickActionItem({
    required BuildContext context, // Добавляем параметр context
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context); // Теперь context доступен

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      surfaceTintColor: color.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(context); // Теперь можно использовать context
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
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