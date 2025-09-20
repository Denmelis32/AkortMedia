// lib/pages/rooms_pages/advanced_filters_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import 'models/room.dart';

class AdvancedFiltersBottomSheet extends StatelessWidget {
  const AdvancedFiltersBottomSheet({super.key});

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
          SwitchListTile(
            title: const Text('Только мои обсуждения'),
            value: roomProvider.showJoinedOnly,
            onChanged: (value) => roomProvider.toggleShowJoinedOnly(),
          ),
          const SizedBox(height: 20),
          const Text('Категории:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...RoomCategory.values.map((category) {
            return RadioListTile<RoomCategory>(
              title: Text(category.title),
              value: category,
              groupValue: roomProvider.selectedCategory,
              onChanged: (value) {
                if (value != null) {
                  roomProvider.setCategory(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }
}