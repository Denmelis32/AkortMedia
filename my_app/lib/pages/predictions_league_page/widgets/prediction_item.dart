import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PredictionItem extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const PredictionItem({
    super.key,
    required this.prediction,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = prediction['status'] == 'active';
    final isWin = prediction['result'] == 'win';
    final isLose = prediction['result'] == 'lose';
    final isCancelled = prediction['status'] == 'cancelled';
    final isExpress = prediction['isExpress'] == true;
    final event = prediction['event'];
    final amount = prediction['amount'] ?? 0.0;
    final potentialWin = prediction['potentialWin'] ?? 0.0;
    final odds = prediction['odds'] ?? 1.0;

    final canCancel = isActive && _canCancelPrediction(prediction);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isExpress)
                          Row(
                            children: [
                              const Icon(Icons.bolt, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              const Text(
                                'Экспресс',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              if ((prediction['couponDetails']?.length ?? 0) > 1) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(${prediction['couponDetails']?.length} ставки)',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        if (isExpress) const SizedBox(height: 4),
                        Text(
                          prediction['option'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${event['teamA']} vs ${event['teamB']}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(prediction),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(prediction),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (canCancel) ...[
                        const SizedBox(height: 4),
                        OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: const Size(0, 0),
                          ),
                          child: const Text(
                            'Отменить',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Детали ставки
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Сумма: ${amount.toStringAsFixed(2)}₽',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Коэффициент: $odds',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Потенциально: ${potentialWin.toStringAsFixed(2)}₽',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (isWin) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Выигрыш: +${(potentialWin - amount).toStringAsFixed(2)}₽',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (isLose) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Проигрыш: -${amount.toStringAsFixed(2)}₽',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (isCancelled) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Возврат: +${amount.toStringAsFixed(2)}₽',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Время и тип
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Размещено: ${DateFormat('dd.MM.yyyy HH:mm').format(prediction['date'])}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    'Тип: ${_getBetTypeName(prediction['type'])}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),

              // Результат для завершенных ставок
              if (prediction['resultDate'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Завершена: ${DateFormat('dd.MM.yyyy HH:mm').format(prediction['resultDate'])}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],

              // Детали экспресса
              if (isExpress && prediction['couponDetails'] != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Состав экспресса:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildExpressDetails(prediction['couponDetails']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpressDetails(List<dynamic> couponDetails) {
    return couponDetails.map((detail) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${detail['title']} (×${detail['odds']})',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getStatusColor(Map<String, dynamic> prediction) {
    switch (prediction['status']) {
      case 'active': return Colors.orange;
      case 'won': return Colors.green;
      case 'lost': return Colors.red;
      case 'cancelled': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getStatusText(Map<String, dynamic> prediction) {
    switch (prediction['status']) {
      case 'active': return 'Активна';
      case 'won': return 'Выиграна';
      case 'lost': return 'Проиграна';
      case 'cancelled': return 'Отменена';
      default: return 'Неизвестно';
    }
  }

  String? _getBetTypeName(String type) {
    final betTypes = [
      {'id': 'winner', 'name': 'Победитель'},
      {'id': 'total', 'name': 'Тоталы'},
      {'id': 'handicap', 'name': 'Форы'},
      {'id': 'exact_score', 'name': 'Точный счет'},
      {'id': 'double_chance', 'name': 'Двойной шанс'},
      {'id': 'express', 'name': 'Экспресс'},
    ];

    final betType = betTypes.firstWhere(
          (bt) => bt['id'] == type,
      orElse: () => {'name': 'Неизвестно'},
    );
    return betType['name'];
  }

  bool _canCancelPrediction(Map<String, dynamic> prediction) {
    final eventDate = prediction['event']['date'] as DateTime;
    return DateTime.now().isBefore(eventDate);
  }
}