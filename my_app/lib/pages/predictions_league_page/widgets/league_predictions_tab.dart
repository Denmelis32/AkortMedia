import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'prediction_item.dart';

class LeaguePredictionsTab extends StatefulWidget {
  final List<Map<String, dynamic>> predictions;
  final double userPoints;
  final VoidCallback onMakePrediction;
  final Function(String predictionId) onCancelPrediction;

  const LeaguePredictionsTab({
    super.key,
    required this.predictions,
    required this.userPoints,
    required this.onMakePrediction,
    required this.onCancelPrediction,
  });

  @override
  State<LeaguePredictionsTab> createState() => _LeaguePredictionsTabState();
}

class _LeaguePredictionsTabState extends State<LeaguePredictionsTab> {
  String _selectedFilter = 'all';
  String _sortBy = 'date_newest';
  bool _showStats = true;

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'name': 'Все', 'icon': Icons.all_inclusive, 'color': Colors.blue},
    {'id': 'active', 'name': 'Активные', 'icon': Icons.schedule, 'color': Colors.orange},
    {'id': 'won', 'name': 'Выигранные', 'icon': Icons.emoji_events, 'color': Colors.green},
    {'id': 'lost', 'name': 'Проигранные', 'icon': Icons.money_off, 'color': Colors.red},
    {'id': 'cancelled', 'name': 'Отмененные', 'icon': Icons.cancel, 'color': Colors.grey},
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'id': 'date_newest', 'name': 'Сначала новые'},
    {'id': 'date_oldest', 'name': 'Сначала старые'},
    {'id': 'amount_high', 'name': 'По сумме ↓'},
    {'id': 'amount_low', 'name': 'По сумме ↑'},
    {'id': 'odds_high', 'name': 'По коэффициенту ↓'},
    {'id': 'odds_low', 'name': 'По коэффициенту ↑'},
  ];

  List<Map<String, dynamic>> get _filteredPredictions {
    List<Map<String, dynamic>> filtered = widget.predictions.where((p) {
      switch (_selectedFilter) {
        case 'active':
          return p['status'] == 'active';
        case 'won':
          return p['result'] == 'win';
        case 'lost':
          return p['result'] == 'lose';
        case 'cancelled':
          return p['status'] == 'cancelled';
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date_oldest':
          return (a['date'] as DateTime).compareTo(b['date'] as DateTime);
        case 'amount_high':
          return (b['amount'] as num).compareTo(a['amount'] as num);
        case 'amount_low':
          return (a['amount'] as num).compareTo(b['amount'] as num);
        case 'odds_high':
          return (b['odds'] as num).compareTo(a['odds'] as num);
        case 'odds_low':
          return (a['odds'] as num).compareTo(b['odds'] as num);
        default:
          return (b['date'] as DateTime).compareTo(a['date'] as DateTime);
      }
    });

    return filtered;
  }

  Map<String, dynamic> get _stats {
    final total = widget.predictions.length;
    final active = widget.predictions.where((p) => p['status'] == 'active').length;
    final completed = widget.predictions.where((p) => p['result'] != null).length;
    final wins = widget.predictions.where((p) => p['result'] == 'win').length;
    final losses = widget.predictions.where((p) => p['result'] == 'lose').length;
    final cancelled = widget.predictions.where((p) => p['status'] == 'cancelled').length;

    final totalInvested = widget.predictions.fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble());
    final totalWon = widget.predictions.where((p) => p['result'] == 'win').fold(
        0.0, (sum, p) => sum + ((p['potentialWin'] as num).toDouble() - (p['amount'] as num).toDouble())
    );
    final totalLost = widget.predictions.where((p) => p['result'] == 'lose').fold(
        0.0, (sum, p) => sum + (p['amount'] as num).toDouble()
    );

    final successRate = completed > 0 ? (wins / completed * 100) : 0;
    final roi = totalInvested > 0 ? (totalWon / totalInvested * 100) : 0;
    final completedPredictions = widget.predictions.where((p) => p['result'] != null);
    final avgOdds = completedPredictions.isNotEmpty ?
    completedPredictions.fold(0.0, (sum, p) => sum + (p['odds'] as num).toDouble()) / completedPredictions.length : 0;

    return {
      'total': total,
      'active': active,
      'completed': completed,
      'wins': wins,
      'losses': losses,
      'cancelled': cancelled,
      'successRate': successRate,
      'totalProfit': totalWon - totalLost,
      'roi': roi,
      'totalInvested': totalInvested,
      'totalWon': totalWon,
      'totalLost': totalLost,
      'avgOdds': avgOdds,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final filteredPredictions = _filteredPredictions;
    final hasPredictions = widget.predictions.isNotEmpty;

    // Используем SingleChildScrollView вместо Column с Expanded
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200, // Минимальная высота
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок с переключателем статистики
            if (hasPredictions)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Мои ставки',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Статистика',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Switch(
                      value: _showStats,
                      onChanged: (value) => setState(() => _showStats = value),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),

            // Статистика
            if (_showStats && hasPredictions) ...[
              _buildStatsCard(stats),
              const SizedBox(height: 12),
            ],

            // Панель фильтров и сортировки
            if (hasPredictions) _buildControlPanel(),

            // Информация о фильтрации
            if (hasPredictions && filteredPredictions.length != widget.predictions.length)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Показано ${filteredPredictions.length} из ${widget.predictions.length} ставок',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),

            // Список ставок или пустое состояние
            if (hasPredictions && filteredPredictions.isNotEmpty)
              _buildPredictionsList(filteredPredictions)
            else if (hasPredictions && filteredPredictions.isEmpty)
              _buildEmptyFilterState()
            else
              _buildEmptyPredictionsState(),

            // Кнопка отмены для активных ставок
            if (_selectedFilter == 'active' && filteredPredictions.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: _cancelAllActivePredictions,
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Отменить все активные ставки'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),

            // Добавляем отступ снизу для безопасности
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsList(List<Map<String, dynamic>> predictions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...predictions.map((prediction) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: PredictionItem(
            prediction: prediction,
            onTap: () => _showPredictionDetails(prediction),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _buildStatItem('Всего', stats['total'].toString(), Icons.list, Colors.blue),
                  _buildStatItem('Активные', stats['active'].toString(), Icons.schedule, Colors.orange),
                  _buildStatItem('Выиграно', stats['wins'].toString(), Icons.emoji_events, Colors.green),
                  _buildStatItem('Проиграно', stats['losses'].toString(), Icons.money_off, Colors.red),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFinancialStat(
                          'Общий профит',
                          '${stats['totalProfit'] >= 0 ? '+' : ''}${stats['totalProfit'].toStringAsFixed(2)}₽',
                          stats['totalProfit'] >= 0 ? Colors.green : Colors.red,
                          Icons.trending_up,
                        ),
                        _buildFinancialStat(
                          'Успешность',
                          '${stats['successRate'].toStringAsFixed(1)}%',
                          _getSuccessRateColor(stats['successRate']),
                          Icons.bar_chart,
                        ),
                        _buildFinancialStat(
                          'ROI',
                          '${stats['roi'].toStringAsFixed(1)}%',
                          stats['roi'] > 0 ? Colors.green : Colors.red,
                          Icons.percent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFinancialStat(
                          'Инвестировано',
                          '${stats['totalInvested'].toStringAsFixed(2)}₽',
                          Colors.blue,
                          Icons.account_balance_wallet,
                        ),
                        _buildFinancialStat(
                          'Ср. коэффициент',
                          stats['avgOdds'].toStringAsFixed(2),
                          Colors.purple,
                          Icons.show_chart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStat(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Фильтр:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildFilterChip(filter, _selectedFilter == filter['id']),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.sort, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Сортировка:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    onChanged: (value) => setState(() => _sortBy = value!),
                    items: _sortOptions.map<DropdownMenuItem<String>>((option) {
                      return DropdownMenuItem<String>(
                        value: option['id'] as String,
                        child: Text(
                            option['name'] as String,
                            style: const TextStyle(fontSize: 12)
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(Map<String, dynamic> filter, bool isSelected) {
    final color = filter['color'] as Color;
    return ChoiceChip(
      label: Text(filter['name'] as String),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter['id'] as String;
        });
      },
      avatar: Icon(filter['icon'] as IconData, size: 14, color: isSelected ? Colors.white : color),
      backgroundColor: Colors.white,
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEmptyPredictionsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      height: 300, // Фиксированная высота для пустого состояния
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ставок пока нет',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Сделайте первую ставку и начните отслеживать свою статистику',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.onMakePrediction,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Сделать первую ставку'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    final message = _getEmptyStateMessage();

    return Container(
      padding: const EdgeInsets.all(32),
      height: 300, // Фиксированная высота для пустого состояния фильтра
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(_getEmptyStateIcon(), size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            message['title']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message['subtitle']!,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedFilter = 'all'),
            icon: const Icon(Icons.filter_alt_off, size: 18),
            label: const Text('Сбросить фильтр'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'active':
        return {
          'title': 'Нет активных ставок',
          'subtitle': 'Все ваши ставки либо завершены, либо отменены',
        };
      case 'won':
        return {
          'title': 'Пока нет выигрышей',
          'subtitle': 'Успешные ставки появятся здесь после завершения событий',
        };
      case 'lost':
        return {
          'title': 'Пока нет проигрышей',
          'subtitle': 'Отличная работа! Продолжайте в том же духе',
        };
      case 'cancelled':
        return {
          'title': 'Нет отмененных ставок',
          'subtitle': 'Вы пока не отменяли свои ставки',
        };
      default:
        return {
          'title': 'Ставок пока нет',
          'subtitle': 'Сделайте первую ставку и начните отслеживать свою статистику',
        };
    }
  }

  IconData _getEmptyStateIcon() {
    switch (_selectedFilter) {
      case 'active': return Icons.schedule;
      case 'won': return Icons.emoji_events;
      case 'lost': return Icons.money_off;
      case 'cancelled': return Icons.cancel;
      default: return Icons.analytics;
    }
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 70) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }

  void _showPredictionDetails(Map<String, dynamic> prediction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildPredictionDetailsSheet(prediction),
    );
  }

  Widget _buildPredictionDetailsSheet(Map<String, dynamic> prediction) {
    final canCancel = prediction['status'] == 'active' && _canCancelPrediction(prediction);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Детали ставки',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              _buildStatusBadge(prediction),
            ],
          ),
          const SizedBox(height: 16),

          _buildDetailItem('Событие',
              '${prediction['event']['teamA']} vs ${prediction['event']['teamB']}'),
          _buildDetailItem('Ставка', prediction['option'] as String),
          _buildDetailItem('Коэффициент', prediction['odds'].toString()),
          _buildDetailItem('Сумма', '${prediction['amount']}₽'),
          _buildDetailItem('Потенциальный выигрыш', '${prediction['potentialWin']}₽'),
          _buildDetailItem('Размещена',
              DateFormat('dd.MM.yyyy HH:mm').format(prediction['date'] as DateTime)),

          if (prediction['resultDate'] != null)
            _buildDetailItem('Завершена',
                DateFormat('dd.MM.yyyy HH:mm').format(prediction['resultDate'] as DateTime)),

          if (canCancel) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Вы можете отменить эту ставку до начала события',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ),
              const SizedBox(width: 12),
              if (canCancel)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _cancelPrediction(prediction['id'] as String);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Отменить'),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> prediction) {
    final statusInfo = _getStatusInfo(prediction);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo['color']!.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo['icon'] as IconData, size: 14, color: statusInfo['color'] as Color),
          const SizedBox(width: 4),
          Text(
            statusInfo['text']! as String,
            style: TextStyle(
              color: statusInfo['color'] as Color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(Map<String, dynamic> prediction) {
    switch (prediction['status']) {
      case 'active':
        return {
          'text': 'Активна',
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'won':
        return {
          'text': 'Выиграна',
          'color': Colors.green,
          'icon': Icons.emoji_events,
        };
      case 'lost':
        return {
          'text': 'Проиграна',
          'color': Colors.red,
          'icon': Icons.money_off,
        };
      case 'cancelled':
        return {
          'text': 'Отменена',
          'color': Colors.grey,
          'icon': Icons.cancel,
        };
      default:
        return {
          'text': 'Неизвестно',
          'color': Colors.grey,
          'icon': Icons.help,
        };
    }
  }

  bool _canCancelPrediction(Map<String, dynamic> prediction) {
    final eventDate = prediction['event']['date'] as DateTime;
    return DateTime.now().isBefore(eventDate);
  }

  void _cancelPrediction(String predictionId) {
    widget.onCancelPrediction(predictionId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ставка успешно отменена')),
    );
  }

  void _cancelAllActivePredictions() {
    final activePredictions = widget.predictions.where((p) =>
    p['status'] == 'active' && _canCancelPrediction(p)
    ).toList();

    if (activePredictions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет активных ставок для отмены')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить все ставки?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Будет отменено ${activePredictions.length} ставок:'),
            const SizedBox(height: 8),
            ...activePredictions.take(3).map((p) => Text(
              '• ${p['event']['teamA']} vs ${p['event']['teamB']} - ${p['amount']}₽',
              style: const TextStyle(fontSize: 12),
            )),
            if (activePredictions.length > 3)
              Text('... и ещё ${activePredictions.length - 3} ставок',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Text(
              'Общая сумма: ${activePredictions.fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble()).toStringAsFixed(2)}₽',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              for (final prediction in activePredictions) {
                widget.onCancelPrediction(prediction['id'] as String);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Отменено ${activePredictions.length} ставок')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Отменить все'),
          ),
        ],
      ),
    );
  }
}