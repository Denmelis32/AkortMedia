import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../models/room.dart';
import '../category_chip.dart';

class CategorySection extends StatelessWidget {
  final RoomProvider roomProvider;
  final bool isSearchExpanded;

  const CategorySection({
    super.key,
    required this.roomProvider,
    required this.isSearchExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isSearchExpanded ? 0 : null,
        constraints: isSearchExpanded
            ? const BoxConstraints(maxHeight: 0)
            : const BoxConstraints(minHeight: 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: RoomCategory.values.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: CategoryChip(
                  category: category,
                  isSelected: roomProvider.selectedCategory == category,
                  onSelected: () => roomProvider.setCategory(category),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}