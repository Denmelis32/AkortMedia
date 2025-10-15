import 'package:flutter/material.dart';

class PredictionDialog extends StatefulWidget {
  final Map<String, dynamic> event;
  final List<Map<String, dynamic>> betTypes;
  final double userPoints;
  final double minBet;
  final double maxBet;
  final Function(String optionId, double amount, String betType, Map<String, dynamic> option) onPlacePrediction;
  final Function(Map<String, dynamic> prediction) onAddToCoupon;

  const PredictionDialog({
    super.key,
    required this.event,
    required this.betTypes,
    required this.userPoints,
    required this.minBet,
    required this.maxBet,
    required this.onPlacePrediction,
    required this.onAddToCoupon,
  });

  @override
  State<PredictionDialog> createState() => _PredictionDialogState();
}

class _PredictionDialogState extends State<PredictionDialog> {
  String _selectedBetType = 'winner';
  double? _selectedAmount;
  String? _selectedOptionId;
  final TextEditingController _amountController = TextEditingController();
  bool _showQuickAmounts = false;

  // Быстрые суммы для ставок
  final List<double> _quickAmounts = [100, 250, 500, 1000, 2500];

  // История предыдущих ставок пользователя
  final List<double> _betHistory = [100, 200, 500];

  String _getTeamName(String teamKey) {
    return widget.event[teamKey] ?? teamKey;
  }

  Map<String, List<Map<String, dynamic>>> get _predictionOptions {
    final teamA = _getTeamName('teamA');
    final teamB = _getTeamName('teamB');
    final isLive = widget.event['isLive'] == true;

    return {
      'winner': [
        {
          'id': 'teamA_win',
          'title': 'Победа $teamA',
          'probability': 0.35,
          'odds': 2.85,
          'votes': 450,
          'result_key': 'teamA',
          'trend': 'up', // тренд коэффициента
        },
        {
          'id': 'teamB_win',
          'title': 'Победа $teamB',
          'probability': 0.45,
          'odds': 2.22,
          'votes': 580,
          'result_key': 'teamB',
          'trend': 'down',
        },
        {
          'id': 'draw',
          'title': 'Ничья',
          'probability': 0.20,
          'odds': 5.00,
          'votes': 220,
          'result_key': 'draw',
          'trend': 'stable',
        },
      ],
      'total': [
        {
          'id': 'total_over_2.5',
          'title': 'Тотал больше 2.5',
          'probability': 0.40,
          'odds': 1.95,
          'votes': 320,
          'value': 2.5,
          'result_key': 'total_over',
          'trend': 'up',
        },
        {
          'id': 'total_under_2.5',
          'title': 'Тотал меньше 2.5',
          'probability': 0.60,
          'odds': 1.85,
          'votes': 480,
          'value': 2.5,
          'result_key': 'total_under',
          'trend': 'stable',
        },
      ],
      'handicap': [
        {
          'id': 'handicap_teamA_-1',
          'title': '$teamA (-1)',
          'probability': 0.30,
          'odds': 3.20,
          'votes': 200,
          'value': -1,
          'result_key': 'handicap_teamA',
          'trend': 'up',
        },
        {
          'id': 'handicap_teamB_+1',
          'title': '$teamB (+1)',
          'probability': 0.45,
          'odds': 2.10,
          'votes': 350,
          'value': 1,
          'result_key': 'handicap_teamB',
          'trend': 'down',
        },
      ],
    };
  }

  double get _potentialWin {
    if (_selectedAmount == null || _selectedOptionId == null) return 0;

    final options = _predictionOptions[_selectedBetType];
    if (options == null) return 0;

    final option = options.firstWhere(
          (opt) => opt['id'] == _selectedOptionId,
      orElse: () => {'odds': 1.0},
    );

    final odds = option['odds'] ?? 1.0;
    return _selectedAmount! * odds;
  }

  double get _potentialProfit {
    return _potentialWin - (_selectedAmount ?? 0);
  }

  String? _getBetErrorText() {
    if (_selectedAmount == null) return null;
    if (_selectedAmount! < widget.minBet) return 'Мин: ${widget.minBet}₽';
    if (_selectedAmount! > widget.maxBet) return 'Макс: ${widget.maxBet}₽';
    if (_selectedAmount! > widget.userPoints) return 'Недостаточно средств';
    return null;
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up': return Colors.green;
      case 'down': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up': return Icons.trending_up;
      case 'down': return Icons.trending_down;
      default: return Icons.trending_flat;
    }
  }

  void _setAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  void _setHalfBalance() {
    _setAmount(widget.userPoints / 2);
  }

  void _setMaxBalance() {
    _setAmount(widget.userPoints);
  }

  @override
  Widget build(BuildContext context) {
    final options = _predictionOptions[_selectedBetType] ?? [];
    final isLive = widget.event['isLive'] == true;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ШАПКА ДИАЛОГА
            _buildHeader(isLive),

            // ОСНОВНОЙ КОНТЕНТ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ИНФОРМАЦИЯ О СОБЫТИИ
                    _buildEventInfo(),
                    const SizedBox(height: 20),

                    // ТИПЫ СТАВОК
                    _buildBetTypesSelector(),
                    const SizedBox(height: 20),

                    // ВАРИАНТЫ СТАВОК
                    if (options.isNotEmpty) ...[
                      _buildOptionsHeader(),
                      const SizedBox(height: 12),
                      ...options.map((option) => _buildPredictionOption(option)),
                      const SizedBox(height: 20),
                    ],

                    // ВВОД СУММЫ
                    if (_selectedOptionId != null) ...[
                      _buildAmountSection(),
                      const SizedBox(height: 20),
                    ],

                    // БЫСТРЫЕ СУММЫ
                    if (_selectedOptionId != null && _showQuickAmounts) ...[
                      _buildQuickAmounts(),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // ФУТЕР С КНОПКАМИ
            if (_selectedOptionId != null) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сделать ставку',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  isLive ? 'LIVE • Коэффициенты обновляются' : 'Прематч • Ставки открыты',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Закрыть',
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sports_soccer, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.event['teamA']} vs ${widget.event['teamB']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.event['league']} • ${widget.event['sport']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(widget.event['date']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetTypesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тип ставки',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: widget.betTypes.map((type) {
              final isSelected = _selectedBetType == type['id'];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedBetType = type['id'];
                      _selectedOptionId = null;
                      _selectedAmount = null;
                      _amountController.clear();
                      _showQuickAmounts = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : Colors.grey[100],
                    foregroundColor: isSelected ? Colors.white : Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type['icon'], size: 16),
                      const SizedBox(width: 6),
                      Text(type['name']),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsHeader() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Варианты',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          'Кэф',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 40),
      ],
    );
  }

  Widget _buildPredictionOption(Map<String, dynamic> option) {
    final isSelected = _selectedOptionId == option['id'];
    final trend = option['trend'] ?? 'stable';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedOptionId = option['id'];
              _showQuickAmounts = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Чекбокс выбора
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? Colors.blue : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),

                // Информация о ставке
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Вероятность
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${((option['probability'] ?? 0.5) * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Количество ставок
                          Row(
                            children: [
                              Icon(Icons.people_outline, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                '${option['votes']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),

                          // Тренд коэффициента
                          if (trend != 'stable') ...[
                            const SizedBox(width: 8),
                            Icon(
                              _getTrendIcon(trend),
                              size: 12,
                              color: _getTrendColor(trend),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Коэффициент
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option['odds'].toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Сумма ставки',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        // Поле ввода суммы
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Введите сумму от ${widget.minBet} до ${widget.maxBet} ₽',
            suffixIcon: IconButton(
              icon: Icon(_showQuickAmounts ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onPressed: () {
                setState(() {
                  _showQuickAmounts = !_showQuickAmounts;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            errorText: _getBetErrorText(),
          ),
          onChanged: (value) {
            setState(() {
              _selectedAmount = double.tryParse(value);
            });
          },
        ),
        const SizedBox(height: 8),

        // Быстрые кнопки баланса
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _setHalfBalance,
                icon: const Icon(Icons.attach_money, size: 16),
                label: const Text('50% баланса'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _setMaxBalance,
                icon: const Icon(Icons.all_inclusive, size: 16),
                label: const Text('Весь баланс'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Расчет выигрыша
        if (_selectedAmount != null && _selectedAmount! > 0) ...[
          const SizedBox(height: 16),
          _buildProfitCalculation(),
        ],
      ],
    );
  }

  Widget _buildQuickAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Быстрые суммы',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // История ставок
            ..._betHistory.map((amount) => ActionChip(
              label: Text('${amount.toInt()}₽'),
              onPressed: () => _setAmount(amount),
              backgroundColor: Colors.orange[50],
              labelStyle: const TextStyle(color: Colors.orange),
            )),

            // Быстрые суммы
            ..._quickAmounts.map((amount) => ActionChip(
              label: Text('${amount.toInt()}₽'),
              onPressed: () => _setAmount(amount),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitCalculation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _potentialProfit >= 0 ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _potentialProfit >= 0 ? Colors.green[100]! : Colors.red[100]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Потенциальный выигрыш',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                '${_potentialWin.toStringAsFixed(2)}₽',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Чистая прибыль',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                '${_potentialProfit >= 0 ? '+' : ''}${_potentialProfit.toStringAsFixed(2)}₽',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _potentialProfit >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Кнопка "В купон"
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectedOptionId != null ? _addToCoupon : null,
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: const Text('В купон'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Кнопка "Подтвердить"
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _canPlaceBet() ? _placePrediction : null,
              icon: const Icon(Icons.check, size: 18),
              label: Text(
                '${_selectedAmount != null ? _selectedAmount!.toStringAsFixed(0) + '₽' : 'Подтвердить'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canPlaceBet() {
    return _selectedOptionId != null &&
        _selectedAmount != null &&
        _selectedAmount! >= widget.minBet &&
        _selectedAmount! <= widget.maxBet &&
        _selectedAmount! <= widget.userPoints;
  }

  void _placePrediction() {
    if (_canPlaceBet()) {
      final options = _predictionOptions[_selectedBetType];
      if (options != null) {
        final option = options.firstWhere(
              (opt) => opt['id'] == _selectedOptionId,
        );

        widget.onPlacePrediction(_selectedOptionId!, _selectedAmount!, _selectedBetType, option);
        Navigator.pop(context);
      }
    }
  }

  void _addToCoupon() {
    if (_selectedOptionId != null) {
      final options = _predictionOptions[_selectedBetType];
      if (options != null) {
        final option = options.firstWhere(
              (opt) => opt['id'] == _selectedOptionId,
        );

        final prediction = {
          ...option,
          'amount': _selectedAmount ?? widget.minBet,
          'event': widget.event,
          'type': _selectedBetType,
          'eventTitle': '${widget.event['teamA']} vs ${widget.event['teamB']}',
          'potentialWin': _potentialWin,
        };

        widget.onAddToCoupon(prediction);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ставка добавлена в купон'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}