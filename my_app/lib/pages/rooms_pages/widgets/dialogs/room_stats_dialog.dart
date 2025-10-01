// 1. Сначала исправляем RoomStatsDialog - основную ошибку
import 'package:flutter/material.dart';

class RoomStatsDialog extends StatelessWidget {
  final Map<String, dynamic> stats;

  const RoomStatsDialog({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.25),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? 520 : 380,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.analytics, color: theme.colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Статистика сообщества',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Актуальная статистика по всем обсуждениям',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Основная статистика в адаптивной сетке
            _buildStatsGrid(theme),

            const SizedBox(height: 24),

            // Дополнительная статистика
            _buildAdditionalStats(theme),

            const SizedBox(height: 24),

            // Кнопка закрытия
            Center(
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Понятно'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          'Всего комнат',
          _getSafeValue(stats['totalRooms']),
          Icons.forum_outlined,
          Colors.blue.shade600,
          theme,
        ),
        _buildStatCard(
          'Активных',
          _getSafeValue(stats['activeRooms']),
          Icons.people_outlined,
          Colors.green.shade600,
          theme,
        ),
        _buildStatCard(
          'Участников',
          _formatNumber(_getSafeValue(stats['totalParticipants'])),
          Icons.person_outlined,
          Colors.purple.shade600,
          theme,
        ),
        _buildStatCard(
          'Рейтинг',
          _formatRating(stats['averageRating']),
          Icons.star_rate_rounded,
          Colors.amber.shade600,
          theme,
        ),
        _buildStatCard(
          'Закрепленных',
          _getSafeValue(stats['pinnedRooms']),
          Icons.push_pin,
          Colors.orange.shade600,
          theme,
        ),
        _buildStatCard(
          'Запланированных',
          _getSafeValue(stats['scheduledRooms']),
          Icons.schedule,
          Colors.teal.shade600,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка и значение в одной строке
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats(ThemeData theme) {
    final filteredRooms = _getSafeInt(stats['filteredRooms']);
    final joinedRooms = _getSafeInt(stats['joinedRooms']);
    final totalRooms = _getSafeInt(stats['totalRooms'], defaultValue: 1);
    final activeRooms = _getSafeInt(stats['activeRooms']);

    // Безопасное преобразование в double
    final filteredPercentage = totalRooms > 0 ? (filteredRooms / totalRooms * 100) : 0.0;
    final joinedPercentage = totalRooms > 0 ? (joinedRooms / totalRooms * 100) : 0.0;
    final activityLevel = totalRooms > 0 ? (activeRooms / totalRooms * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Детальная статистика',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildProgressItem(
            'Отфильтровано комнат',
            filteredRooms.toString(),
            filteredPercentage,
            theme,
          ),
          const SizedBox(height: 12),

          _buildProgressItem(
            'Ваших комнат',
            joinedRooms.toString(),
            joinedPercentage,
            theme,
          ),
          const SizedBox(height: 12),

          _buildActivityLevel(activityLevel, theme),
        ],
      ),
    );
  }


  Widget _buildProgressItem(String label, String value, double percentage, ThemeData theme) {
    // Гарантируем что значение от 0.0 до 1.0
    final progressValue = (percentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildActivityLevel(double activityLevel, ThemeData theme) {
    String activityText;
    Color activityColor;

    if (activityLevel >= 70) {
      activityText = 'Высокая активность';
      activityColor = Colors.green.shade600;
    } else if (activityLevel >= 40) {
      activityText = 'Средняя активность';
      activityColor = Colors.orange.shade600;
    } else {
      activityText = 'Низкая активность';
      activityColor = Colors.red.shade600;
    }

    // Гарантируем что значение от 0.0 до 1.0
    final progressValue = (activityLevel / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Уровень активности',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activityColor.withOpacity(0.3)),
              ),
              child: Text(
                activityText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: activityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          color: activityColor,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${activityLevel.toStringAsFixed(1)}% активных комнат',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  // Безопасные методы для обработки данных
  String _getSafeValue(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }

  int _getSafeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _formatRating(dynamic rating) {
    if (rating == null) return '0.0';

    if (rating is double) return rating.toStringAsFixed(1);
    if (rating is int) return rating.toDouble().toStringAsFixed(1);
    if (rating is String) {
      final parsed = double.tryParse(rating);
      return parsed?.toStringAsFixed(1) ?? '0.0';
    }

    return '0.0';
  }

  String _formatNumber(String value) {
    final number = int.tryParse(value) ?? 0;

    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return number.toString();
  }
}