import 'package:flutter/material.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      'Уведомления',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildNotificationItem(
                  context: context, // Передаем context
                  icon: Icons.people_rounded,
                  title: 'Приглашения в комнаты',
                  subtitle: 'Уведомления о новых приглашениях',
                  enabled: true,
                ),
                _buildNotificationItem(
                  context: context, // Передаем context
                  icon: Icons.schedule_rounded,
                  title: 'Напоминания о начале',
                  subtitle: 'За 15 минут до начала обсуждения',
                  enabled: false,
                ),
                _buildNotificationItem(
                  context: context, // Передаем context
                  icon: Icons.message_rounded,
                  title: 'Новые сообщения',
                  subtitle: 'В избранных комнатах',
                  enabled: true,
                ),
                _buildNotificationItem(
                  context: context, // Передаем context
                  icon: Icons.trending_up_rounded,
                  title: 'Популярные обсуждения',
                  subtitle: 'Рекомендации по активности',
                  enabled: false,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // TODO: Сохранить настройки
                          Navigator.pop(context);
                        },
                        child: const Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Добавляем параметр context в метод
  Widget _buildNotificationItem({
    required BuildContext context, // Добавляем этот параметр
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    final theme = Theme.of(context); // Теперь context доступен

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (value) {
            // TODO: Обновить состояние уведомления
          },
          activeColor: theme.primaryColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}