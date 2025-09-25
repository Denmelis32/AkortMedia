// lib/pages/rooms_pages/advanced_filters_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import 'models/room.dart';

class AdvancedFiltersBottomSheet extends StatelessWidget {
  final VoidCallback onFiltersApplied;

  const AdvancedFiltersBottomSheet({
    super.key,
    required this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.read<RoomProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расширенные фильтры',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Переключение "Только мои обсуждения"
          SwitchListTile(
            title: const Text('Только мои обсуждения'),
            value: roomProvider.showJoinedOnly,
            onChanged: (value) {
              roomProvider.toggleShowJoinedOnly();
              onFiltersApplied();
            },
          ),

          // Переключение "Только активные комнаты"
          SwitchListTile(
            title: const Text('Только активные комнаты'),
            value: roomProvider.showActiveOnly,
            onChanged: (value) {
              roomProvider.toggleShowActiveOnly();
              onFiltersApplied();
            },
          ),

          // Переключение "Показывать закрепленные первыми"
          SwitchListTile(
            title: const Text('Закрепленные вначале'),
            value: roomProvider.showPinnedFirst,
            onChanged: (value) {
              roomProvider.toggleShowPinnedFirst();
              onFiltersApplied();
            },
          ),

          const SizedBox(height: 20),
          const Text(
            'Сортировка:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...RoomSortBy.values.map((sortBy) {
            return RadioListTile<RoomSortBy>(
              title: Row(
                children: [
                  Icon(sortBy.icon, size: 20),
                  const SizedBox(width: 8),
                  Text(sortBy.title),
                ],
              ),
              value: sortBy,
              groupValue: roomProvider.sortBy,
              onChanged: (value) {
                if (value != null) {
                  roomProvider.setSortBy(value);
                  onFiltersApplied();
                }
              },
            );
          }).toList(),

          const SizedBox(height: 20),
          const Text(
            'Категории:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...RoomCategory.values.map((category) {
            if (category == RoomCategory.all) return const SizedBox.shrink();

            return RadioListTile<RoomCategory>(
              title: Row(
                children: [
                  Icon(category.icon, color: category.color, size: 20),
                  const SizedBox(width: 8),
                  Text(category.title),
                ],
              ),
              value: category,
              groupValue: roomProvider.selectedCategory,
              onChanged: (value) {
                if (value != null) {
                  roomProvider.setCategory(value);
                  onFiltersApplied();
                }
              },
            );
          }).toList(),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    roomProvider.resetFilters();
                    onFiltersApplied();
                    Navigator.pop(context);
                  },
                  child: const Text('Сбросить все'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onFiltersApplied();
                    Navigator.pop(context);
                  },
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}