import 'package:flutter/material.dart';

class ContentTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final Color channelColor;

  // 3 ВКЛАДКИ: Стена, Акорта, Статьи
  final List<String> tabs;

  const ContentTabs({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.channelColor,
    this.tabs = const ['Стена', 'Акорта', 'Статьи'], // 3 вкладки
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;
            return Expanded(
              child: _buildTabButton(text, currentIndex == index, index),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTabChanged(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? channelColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}