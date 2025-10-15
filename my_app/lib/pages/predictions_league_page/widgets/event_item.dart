import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;
  final bool isSelected;

  const EventItem({
    super.key,
    required this.event,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = event['isLive'] == true;
    final odds = event['odds'] as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Заголовок события
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isLive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isLive) const SizedBox(width: 8),
                          Text(
                            '${event['teamA']} vs ${event['teamB']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['league'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event['sport'],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Время и статус
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  isLive ? 'Идет сейчас' : 'Через ${event['timeToStart']}',
                  style: TextStyle(
                    color: isLive ? Colors.red : Colors.grey,
                    fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(event['date']),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Коэффициенты
            _buildEventOdds(odds),
            const SizedBox(height: 12),

            // Кнопка ставки - ВАЖНО: убедись, что onPressed правильно связан
            ElevatedButton(
              onPressed: onTap, // ← Должен вызывать переданный колбэк
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.attach_money, size: 18),
                  const SizedBox(width: 8),
                  Text(isSelected ? 'Выбрано' : 'Сделать ставку'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventOdds(Map<String, dynamic> odds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: odds.entries.map((entry) {
        return Column(
          children: [
            Text(
              _getOddsLabel(entry.key),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.value.toString(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getOddsLabel(String key) {
    switch (key) {
      case 'teamA': return 'П1';
      case 'draw': return 'X';
      case 'teamB': return 'П2';
      default: return key;
    }
  }
}