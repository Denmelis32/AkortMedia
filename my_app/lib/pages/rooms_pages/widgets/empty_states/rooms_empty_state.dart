import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../models/room.dart';

class RoomsEmptyState extends StatelessWidget {
  final RoomProvider roomProvider;
  final bool isSearchExpanded;
  final VoidCallback? onCreateRoom;

  const RoomsEmptyState({
    super.key,
    required this.roomProvider,
    required this.isSearchExpanded,
    this.onCreateRoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _hasActiveFilters(roomProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyStateIcon(theme, hasActiveFilters),
            const SizedBox(height: 32),
            _buildEmptyStateTitle(theme, hasActiveFilters),
            const SizedBox(height: 12),
            _buildEmptyStateMessage(theme, hasActiveFilters),
            const SizedBox(height: 32),
            _buildActionButtons(context, hasActiveFilters),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateIcon(ThemeData theme, bool hasActiveFilters) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(
        hasActiveFilters ? Icons.search_off_rounded : Icons.forum_outlined,
        size: 60,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }

  Widget _buildEmptyStateTitle(ThemeData theme, bool hasActiveFilters) {
    return Text(
      _getEmptyStateTitle(hasActiveFilters),
      style: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.8),
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmptyStateMessage(ThemeData theme, bool hasActiveFilters) {
    return Text(
      _getEmptyStateMessage(hasActiveFilters),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool hasActiveFilters) {
    if (!hasActiveFilters) {
      return FilledButton.icon(
        onPressed: onCreateRoom,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Создать обсуждение'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Column(
      children: [
        FilledButton(
          onPressed: () => roomProvider.resetAllFilters(),
          child: const Text('Сбросить фильтры'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onCreateRoom,
          child: const Text('Создать комнату для этой темы'),
        ),
      ],
    );
  }

  bool _hasActiveFilters(RoomProvider roomProvider) {
    return roomProvider.searchQuery.isNotEmpty ||
        roomProvider.selectedCategory != RoomCategory.all ||
        roomProvider.hasActiveAdvancedFilters;
  }

  String _getEmptyStateTitle(bool hasActiveFilters) {
    if (hasActiveFilters) return 'Ничего не найдено';
    if (roomProvider.selectedCategory != RoomCategory.all) return 'Категория пуста';
    return 'Обсуждения не найдены';
  }

  String _getEmptyStateMessage(bool hasActiveFilters) {
    if (hasActiveFilters) {
      return 'Попробуйте изменить параметры поиска или сбросить фильтры для просмотра всех доступных комнат';
    }
    if (roomProvider.selectedCategory != RoomCategory.all) {
      return 'В этой категории пока нет обсуждений. Будьте первым, кто создаст комнату!';
    }
    return 'Пока нет активных обсуждений. Создайте первую комнату и начните общение!';
  }
}