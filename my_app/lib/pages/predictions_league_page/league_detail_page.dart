import 'package:flutter/material.dart';
import 'package:my_app/pages/predictions_league_page/widgets/league_description_tab.dart';
import 'package:my_app/pages/predictions_league_page/widgets/league_events_tab.dart';
import 'package:my_app/pages/predictions_league_page/widgets/league_leaderboard_tab.dart';
import 'package:my_app/pages/predictions_league_page/widgets/league_predictions_tab.dart';
import 'package:my_app/pages/predictions_league_page/widgets/prediction_dialog.dart';
import 'package:my_app/pages/predictions_league_page/widgets/coupon_dialog.dart';

import 'models/prediction_league.dart';

class LeagueDetailPage extends StatefulWidget {
  final PredictionLeague league;

  const LeagueDetailPage({
    super.key,
    required this.league,
  });

  @override
  State<LeagueDetailPage> createState() => _LeagueDetailPageState();
}

class _LeagueDetailPageState extends State<LeagueDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _imagePageController = PageController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _predictionController = TextEditingController();

  int _currentImageIndex = 0;
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _isSubscribed = false;
  bool _isLiked = false;
  int _likeCount = 0;
  List<String> _comments = [];
  List<Map<String, dynamic>> _predictions = [];
  List<Map<String, dynamic>> _couponPredictions = [];
  double _userPoints = 0.0;
  String _selectedBetType = 'winner';
  Map<String, dynamic> _selectedEvent = {};
  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _betTypes = [];

  // АДАПТИВНЫЕ МЕТОДЫ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1000;
    if (width > 1000) return 900;
    if (width > 700) return 700;
    return double.infinity;
  }

  double _getTextContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 800;
    if (width > 1000) return 700;
    if (width > 700) return 600;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _likeCount = widget.league.participants ~/ 10;
    _checkSubscription();
    _loadUserStats();
    _loadLeaderboard();
    _loadEvents();
    _loadBetTypes();
    if (_events.isNotEmpty) {
      _selectedEvent = _events.first;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _imagePageController.dispose();
    _commentController.dispose();
    _predictionController.dispose();
    super.dispose();
  }

  Future<void> _checkSubscription() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isSubscribed = false;
    });
  }

  Future<void> _loadUserStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _userPoints = 1250.0;
      _predictions = [
        {
          'id': '1',
          'option': 'Победа команды A',
          'amount': 100.0,
          'potentialWin': 285.0,
          'status': 'active',
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'type': 'winner',
          'event': _events.isNotEmpty ? _events[0] : {},
          'odds': 2.85,
          'result_key': 'teamA',
        },
        {
          'id': '2',
          'option': 'Тотал больше 2.5',
          'amount': 50.0,
          'potentialWin': 97.5,
          'status': 'won',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'type': 'total',
          'event': _events.isNotEmpty ? _events[0] : {},
          'odds': 1.95,
          'result': 'win',
          'result_key': 'total_over',
          'resultDate': DateTime.now().subtract(const Duration(hours: 5)),
        },
        {
          'id': '3',
          'option': 'Победа команды C',
          'amount': 200.0,
          'potentialWin': 390.0,
          'status': 'lost',
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'type': 'winner',
          'event': _events.isNotEmpty ? _events[0] : {},
          'odds': 1.95,
          'result': 'lose',
          'result_key': 'teamA',
          'resultDate': DateTime.now().subtract(const Duration(days: 2)),
        },
      ];
    });
  }

  Future<void> _loadLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _leaderboard = [
        {
          'rank': 1,
          'username': 'ProGamer',
          'points': 12500,
          'profit': 8500,
          'accuracy': 78,
          'avatar': '👑',
          'isCurrentUser': false,
          'trend': 'up',
        },
        {
          'rank': 15,
          'username': 'Вы',
          'points': 4500,
          'profit': 1250,
          'accuracy': 62,
          'avatar': '😊',
          'isCurrentUser': true,
          'trend': 'up',
        },
      ];
    });
  }

  Future<void> _loadEvents() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _events = [
        {
          'id': '1',
          'teamA': 'Команда A',
          'teamB': 'Команда B',
          'date': DateTime.now().add(const Duration(days: 1)),
          'sport': 'Футбол',
          'league': 'Чемпионат мира',
          'odds': {'teamA': 2.85, 'draw': 3.20, 'teamB': 2.40},
          'isLive': false,
          'timeToStart': '1 день',
        },
        {
          'id': '2',
          'teamA': 'Команда C',
          'teamB': 'Команда D',
          'date': DateTime.now().add(const Duration(hours: 3)),
          'sport': 'Баскетбол',
          'league': 'НБА',
          'odds': {'teamA': 1.95, 'teamB': 1.85},
          'isLive': true,
          'timeToStart': '3 часа',
        },
      ];
    });
  }

  Future<void> _loadBetTypes() async {
    setState(() {
      _betTypes = [
        {'id': 'winner', 'name': 'Победитель', 'icon': Icons.emoji_events},
        {'id': 'total', 'name': 'Тоталы', 'icon': Icons.line_weight},
        {'id': 'handicap', 'name': 'Форы', 'icon': Icons.trending_up},
        {'id': 'exact_score', 'name': 'Точный счет', 'icon': Icons.score},
        {'id': 'double_chance', 'name': 'Двойной шанс', 'icon': Icons.autorenew},
      ];
    });
  }

  void _toggleSubscription() {
    setState(() {
      _isSubscribed = !_isSubscribed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSubscribed ? 'Вы присоединились к лиге!' : 'Вы покинули лигу'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
  }

  void _shareLeague() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Поделиться лигой',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showPredictionDialog() {
    print('🎯 Opening prediction dialog for: ${_selectedEvent['teamA']} vs ${_selectedEvent['teamB']}');

    showDialog(
      context: context,
      builder: (context) => PredictionDialog(
        event: _selectedEvent,
        betTypes: _betTypes,
        userPoints: _userPoints,
        minBet: widget.league.minBet,
        maxBet: widget.league.maxBet,
        onPlacePrediction: _placePrediction,
        onAddToCoupon: _addToCoupon,
      ),
    );
  }

  void _showCouponDialog() {
    if (_couponPredictions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Купон пуст. Добавьте ставки в купон')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CouponDialog(
        couponPredictions: _couponPredictions,
        userPoints: _userPoints,
        onPlaceCoupon: _placeCouponPrediction,
        onRemovePrediction: _removeFromCoupon,
        onUpdatePredictionAmount: _updateCouponPredictionAmount,
      ),
    );
  }

  // ОСНОВНЫЕ МЕТОДЫ ДЛЯ СТАВОК

  void _placePrediction(String optionId, double amount, String betType, Map<String, dynamic> option) {
    setState(() {
      _predictions.insert(0, {
        'id': '${DateTime.now().millisecondsSinceEpoch}',
        'option': option['title'],
        'amount': amount,
        'potentialWin': amount * (option['odds'] ?? 1.0),
        'status': 'active',
        'date': DateTime.now(),
        'type': betType,
        'event': _selectedEvent,
        'odds': option['odds'],
        'result_key': option['result_key'],
        'bet_details': option,
      });
      _userPoints -= amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ставка на ${amount.toStringAsFixed(2)}₽ успешно размещена!'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _placeCouponPrediction(double totalAmount, double totalOdds, List<Map<String, dynamic>> predictions) {
    setState(() {
      _predictions.insert(0, {
        'id': '${DateTime.now().millisecondsSinceEpoch}',
        'option': 'Экспресс из ${predictions.length} ставок',
        'amount': totalAmount,
        'potentialWin': totalAmount * totalOdds,
        'status': 'active',
        'date': DateTime.now(),
        'type': 'express',
        'isExpress': true,
        'events': predictions.map((p) => p['event']).toList(),
        'couponDetails': predictions.map((p) => ({
          'title': p['title'],
          'odds': p['odds'],
          'event': p['event'],
          'type': p['type'],
          'result_key': p['result_key'],
          'amount': p['amount'],
        })).toList(),
        'odds': totalOdds,
      });
      _userPoints -= totalAmount;
      _couponPredictions.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Экспресс ставка на ${totalAmount.toStringAsFixed(2)}₽ успешно размещена!'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addToCoupon(Map<String, dynamic> prediction) {
    setState(() {
      _couponPredictions.add(prediction);
    });
  }

  void _removeFromCoupon(int index) {
    setState(() {
      _couponPredictions.removeAt(index);
    });
  }

  void _updateCouponPredictionAmount(int index, double newAmount) {
    setState(() {
      _couponPredictions[index]['amount'] = newAmount;
      _couponPredictions[index]['potentialWin'] = newAmount * (_couponPredictions[index]['odds'] ?? 1.0);
    });
  }

  void _cancelPrediction(String predictionId) {
    setState(() {
      final prediction = _predictions.firstWhere((p) => p['id'] == predictionId);
      prediction['status'] = 'cancelled';
      _userPoints += prediction['amount'];

      _updateUserStats();
    });
  }

  // РЕАЛЬНЫЕ РАСЧЕТЫ РЕЗУЛЬТАТОВ

  void _calculatePredictionResults(String eventId, Map<String, dynamic> eventResult) {
    setState(() {
      final predictionsToUpdate = _predictions.where((prediction) {
        return prediction['status'] == 'active' &&
            prediction['event']['id'] == eventId;
      }).toList();

      for (final prediction in predictionsToUpdate) {
        final isWin = _isPredictionWin(prediction, eventResult);
        prediction['status'] = isWin ? 'won' : 'lost';
        prediction['resultDate'] = DateTime.now();

        if (isWin) {
          _userPoints += prediction['potentialWin'];
        }
      }

      _updateUserStats();
    });
  }

  bool _isPredictionWin(Map<String, dynamic> prediction, Map<String, dynamic> eventResult) {
    final resultKey = prediction['result_key'];
    final betType = prediction['type'];

    // Демо-логика расчета результатов
    // В реальном приложении здесь будет интеграция с API результатов
    switch (betType) {
      case 'winner':
        return eventResult['winner'] == resultKey;

      case 'total':
        final totalGoals = eventResult['score_teamA'] + eventResult['score_teamB'];
        if (resultKey == 'total_over') {
          return totalGoals > prediction['bet_details']['value'];
        } else {
          return totalGoals < prediction['bet_details']['value'];
        }

      case 'handicap':
        final scoreDiff = eventResult['score_teamA'] - eventResult['score_teamB'];
        final handicap = prediction['bet_details']['value'];
        if (resultKey == 'handicap_teamA') {
          return scoreDiff + handicap > 0;
        } else {
          return scoreDiff - handicap < 0;
        }

      case 'exact_score':
        return '${eventResult['score_teamA']}:${eventResult['score_teamB']}' == resultKey;

      case 'double_chance':
        final winner = eventResult['winner'];
        switch (resultKey) {
          case '1X': return winner == 'teamA' || winner == 'draw';
          case 'X2': return winner == 'teamB' || winner == 'draw';
          case '12': return winner == 'teamA' || winner == 'teamB';
          default: return false;
        }

      default:
        return false;
    }
  }

  void _updateUserStats() {
    final totalPredictions = _predictions.length;
    final completedPredictions = _predictions.where((p) => p['status'] != 'active' && p['status'] != 'cancelled').length;
    final wins = _predictions.where((p) => p['status'] == 'won').length;
    final totalProfit = _predictions.where((p) => p['status'] == 'won').fold(
        0.0, (sum, p) => sum + (p['potentialWin'] - p['amount'])
    ) - _predictions.where((p) => p['status'] == 'lost').fold(
        0.0, (sum, p) => sum + p['amount']
    );

    print('📊 Статистика обновлена: $wins/$completedPredictions выиграно, профит: $totalProfit');
  }

  // ДЕМО-МЕТОД ДЛЯ ТЕСТИРОВАНИЯ РАСЧЕТОВ
  void _testCalculationResults() {
    // Демо-результат матча
    final eventResult = {
      'winner': 'teamA',
      'score_teamA': 2,
      'score_teamB': 1,
    };

    _calculatePredictionResults('1', eventResult);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Результаты матча применены к активным ставкам')),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return LeagueDescriptionTab(league: widget.league);
      case 1:
        return LeagueEventsTab(
          events: _events,
          onEventSelected: (event) {
            setState(() {
              _selectedEvent = event;
            });
            _showPredictionDialog();
          },
        );
      case 2:
        return LeaguePredictionsTab(
          predictions: _predictions,
          userPoints: _userPoints,
          onMakePrediction: _showPredictionDialog,
          onCancelPrediction: _cancelPrediction,
        );
      case 3:
        return LeagueLeaderboardTab(
          leaderboard: _leaderboard,
          prizePool: widget.league.formattedPrizePool,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final contentMaxWidth = _getContentMaxWidth(context);
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : horizontalPadding,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Лига прогнозов',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Кнопка тестирования расчетов (только для разработки)
                    if (!isMobile)
                      IconButton(
                        icon: const Icon(Icons.calculate, color: Colors.orange),
                        onPressed: _testCalculationResults,
                        tooltip: 'Тест расчетов результатов',
                      ),
                    if (_couponPredictions.isNotEmpty)
                      Badge(
                        label: Text(_couponPredictions.length.toString()),
                        child: IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                          onPressed: _showCouponDialog,
                        ),
                      ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.share, color: Colors.black, size: 18),
                      ),
                      onPressed: _shareLeague,
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.black,
                          size: 18,
                        ),
                      ),
                      onPressed: _toggleLike,
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ОБЛОЖКА
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 280,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(widget.league.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 40,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          widget.league.emoji,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          widget.league.category.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    widget.league.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          widget.league.formattedPrizePool,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${_formatNumber(widget.league.participants)} участников',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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

                    // ОСНОВНОЙ КОНТЕНТ
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // КНОПКА УЧАСТИЯ
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _isSubscribed ? _showPredictionDialog : _toggleSubscription,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isSubscribed ? Colors.blue : Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _isSubscribed ? Icons.emoji_events : Icons.person_add,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _isSubscribed ? 'Сделать прогноз' : 'Присоединиться к лиге',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // БАЛАНС ПОЛЬЗОВАТЕЛЯ
                          if (_isSubscribed)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ваш баланс',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '${_userPoints.toStringAsFixed(2)}₽',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Активных ставок: ${_predictions.where((p) => p['status'] == 'active').length}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              // Пополнение баланса
                                            },
                                            icon: const Icon(Icons.add, size: 18),
                                            label: const Text('Пополнить'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          OutlinedButton(
                                            onPressed: _testCalculationResults,
                                            child: const Text(
                                              'Тест расчетов',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          if (_isSubscribed) const SizedBox(height: 16),

                          // ТАБЫ
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey[300]!),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildTabItem(0, 'Описание'),
                                        _buildTabItem(1, 'События'),
                                        _buildTabItem(2, 'Мои прогнозы'),
                                        _buildTabItem(3, 'Рейтинг'),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: contentMaxWidth,
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: _buildTabContent(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}