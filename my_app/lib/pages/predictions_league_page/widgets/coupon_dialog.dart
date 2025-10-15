import 'package:flutter/material.dart';

class CouponDialog extends StatefulWidget {
  final List<Map<String, dynamic>> couponPredictions;
  final double userPoints;
  final Function(double totalAmount, double totalOdds, List<Map<String, dynamic>> predictions) onPlaceCoupon;
  final Function(int index) onRemovePrediction;
  final Function(int index, double newAmount) onUpdatePredictionAmount;

  const CouponDialog({
    super.key,
    required this.couponPredictions,
    required this.userPoints,
    required this.onPlaceCoupon,
    required this.onRemovePrediction,
    required this.onUpdatePredictionAmount,
  });

  @override
  State<CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<CouponDialog> {
  final Map<int, TextEditingController> _amountControllers = {};
  String _selectedSystem = 'single'; // single, express, system_2_3, system_3_5

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры для каждой ставки
    for (int i = 0; i < widget.couponPredictions.length; i++) {
      _amountControllers[i] = TextEditingController(
        text: widget.couponPredictions[i]['amount'].toStringAsFixed(2),
      );
    }
  }

  double get totalAmount {
    return widget.couponPredictions.fold(
        0.0,
            (sum, prediction) => sum + (prediction['amount'] ?? 0.0)
    );
  }

  double get totalOdds {
    return widget.couponPredictions.fold(
        1.0,
            (product, prediction) => product * (prediction['odds'] ?? 1.0)
    );
  }

  double get potentialWin {
    if (_selectedSystem == 'single') {
      return totalAmount * totalOdds;
    } else if (_selectedSystem == 'express') {
      return totalAmount * totalOdds;
    } else {
      return _calculateSystemWin();
    }
  }

  double _calculateSystemWin() {
    // Базовая реализация для системных ставок
    // В реальном приложении здесь будет сложная логика комбинаций
    switch (_selectedSystem) {
      case 'system_2_3':
        return totalAmount * totalOdds * 0.6; // Упрощенный расчет
      case 'system_3_5':
        return totalAmount * totalOdds * 0.4; // Упрощенный расчет
      default:
        return totalAmount * totalOdds;
    }
  }

  List<Map<String, dynamic>> get _systemOptions {
    return [
      {'id': 'single', 'name': 'Одинарные', 'description': 'Каждая ставка отдельно'},
      {'id': 'express', 'name': 'Экспресс', 'description': 'Все ставки вместе'},
      if (widget.couponPredictions.length >= 3)
        {'id': 'system_2_3', 'name': 'Система 2/3', 'description': 'Выигрыш при 2+ угаданных'},
      if (widget.couponPredictions.length >= 5)
        {'id': 'system_3_5', 'name': 'Система 3/5', 'description': 'Выигрыш при 3+ угаданных'},
    ];
  }

  String _getSystemDescription(String systemId) {
    switch (systemId) {
      case 'single':
        return 'Каждая ставка рассчитывается отдельно';
      case 'express':
        return 'Все ставки должны выиграть для получения выигрыша';
      case 'system_2_3':
        return 'Выигрыш при угадывании 2 или 3 событий из 3';
      case 'system_3_5':
        return 'Выигрыш при угадывании 3, 4 или 5 событий из 5';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Купон ставок',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (widget.couponPredictions.isEmpty)
                _buildEmptyCoupon()
              else
                ..._buildCouponContent(),

              if (widget.couponPredictions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSystemSelector(),
                const SizedBox(height: 16),
                _buildCouponSummary(),
                const SizedBox(height: 8),

                // Предупреждение о балансе
                if (totalAmount > widget.userPoints)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'Недостаточно средств',
                          style: TextStyle(color: Colors.red),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // Навигация к пополнению баланса
                          },
                          child: const Text('Пополнить'),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCoupon() {
    return Column(
      children: [
        const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Купон пуст',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Добавьте ставки в купон для создания экспресса',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Добавить ставки'),
        ),
      ],
    );
  }

  List<Widget> _buildCouponContent() {
    return [
      // Список ставок в купоне
      ...widget.couponPredictions.asMap().entries.map((entry) {
        final index = entry.key;
        final prediction = entry.value;
        final event = prediction['event'];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
                      onPressed: () => widget.onRemovePrediction(index),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prediction['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (event != null)
                            Text(
                              '${event['teamA']} vs ${event['teamB']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          Text(
                            'Тип: ${_getTypeDisplayName(prediction['type'])}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '×${prediction['odds']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _amountControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Сумма',
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                            ),
                            onChanged: (value) {
                              final newAmount = double.tryParse(value) ?? 0;
                              widget.onUpdatePredictionAmount(index, newAmount);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Потенциально: ${(prediction['amount'] * prediction['odds']).toStringAsFixed(2)}₽',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeColor(prediction['type']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeShortName(prediction['type']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),

      // Максимальное количество ставок
      if (widget.couponPredictions.length >= 10)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Достигнуто максимальное количество ставок в купоне (10)',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _buildSystemSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тип ставки:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _systemOptions.map((system) {
            final isSelected = _selectedSystem == system['id'];
            return ChoiceChip(
              label: Text(system['name']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSystem = system['id'];
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getSystemDescription(_selectedSystem),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCouponSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Количество ставок:'),
              Text('${widget.couponPredictions.length}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Общий коэффициент:'),
              Text(totalOdds.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Сумма ставки:'),
              Text('${totalAmount.toStringAsFixed(2)}₽'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Потенциальный выигрыш:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${potentialWin.toStringAsFixed(2)}₽',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (_selectedSystem != 'single' && _selectedSystem != 'express')
            Text(
              'Расчет для системы ${_selectedSystem.split('_').skip(1).join('/')}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'winner': return Colors.blue;
      case 'total': return Colors.green;
      case 'handicap': return Colors.orange;
      case 'exact_score': return Colors.purple;
      case 'double_chance': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getTypeShortName(String type) {
    switch (type) {
      case 'winner': return 'П1Х2';
      case 'total': return 'ТОТ';
      case 'handicap': return 'ФОРА';
      case 'exact_score': return 'СЧЕТ';
      case 'double_chance': return 'ДВШ';
      default: return type;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'winner': return 'Победитель';
      case 'total': return 'Тоталы';
      case 'handicap': return 'Форы';
      case 'exact_score': return 'Точный счет';
      case 'double_chance': return 'Двойной шанс';
      default: return type;
    }
  }

  void _placeCoupon() {
    if (totalAmount <= widget.userPoints) {
      widget.onPlaceCoupon(totalAmount, totalOdds, widget.couponPredictions);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedSystem == 'express' ? 'Экспресс' : 'Системная'} ставка на ${totalAmount.toStringAsFixed(2)}₽ успешно размещена!'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Очищаем все контроллеры
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}