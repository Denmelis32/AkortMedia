// pages/league_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/predictions_league_page/prediction_league_card.dart';
import 'models/enums.dart';
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
  double _userPoints = 0.0;

  // Демо данные для прогнозов
  final List<Map<String, dynamic>> _predictionOptions = [
    {
      'id': '1',
      'title': 'Победа команды A',
      'probability': 0.35,
      'odds': 2.85,
      'votes': 450,
    },
    {
      'id': '2',
      'title': 'Победа команды B',
      'probability': 0.45,
      'odds': 2.22,
      'votes': 580,
    },
    {
      'id': '3',
      'title': 'Ничья',
      'probability': 0.20,
      'odds': 5.00,
      'votes': 220,
    },
  ];

  // Демо комментарии
  final List<Map<String, dynamic>> _demoComments = [
    {
      'id': '1',
      'author': 'Алексей Петров',
      'avatar': 'АП',
      'text': 'Отличная лига! Уже сделал несколько прогнозов. Призовой фонд впечатляет!',
      'time': '2 часа назад',
      'likes': 12,
      'isLiked': false,
    },
    {
      'id': '2',
      'author': 'Мария Иванова',
      'avatar': 'МИ',
      'text': 'Интересные условия участия. Жду начала основных событий!',
      'time': '5 часов назад',
      'likes': 8,
      'isLiked': true,
    },
    {
      'id': '3',
      'author': 'Дмитрий Сидоров',
      'avatar': 'ДС',
      'text': 'Участвую не первый раз. Организаторы на высоте!',
      'time': '1 день назад',
      'likes': 25,
      'isLiked': false,
    },
  ];

  // Демо статистика
  final Map<String, dynamic> _leagueStats = {
    'totalPredictions': 1250,
    'activeUsers': 890,
    'successRate': 0.68,
    'averageOdds': 3.2,
  };

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

  @override
  void initState() {
    super.initState();
    _likeCount = widget.league.participants ~/ 10;
    _loadComments();
    _checkSubscription();
    _loadUserStats();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _imagePageController.dispose();
    _commentController.dispose();
    _predictionController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _comments = _demoComments.map((comment) => comment['text'] as String).toList();
      _isLoading = false;
    });
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
        },
        {
          'id': '2',
          'option': 'Ничья',
          'amount': 50.0,
          'potentialWin': 250.0,
          'status': 'active',
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'Сообщение', Colors.blue),
                _buildShareOption(Icons.link, 'Ссылка', Colors.green),
                _buildShareOption(Icons.email, 'Email', Colors.orange),
                _buildShareOption(Icons.file_copy, 'Копировать', Colors.purple),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(0, _commentController.text);
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Комментарий добавлен'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPredictionDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Сделать прогноз'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Выберите вариант прогноза:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ..._predictionOptions.map((option) => _buildPredictionOption(option, setDialogState)).toList(),
                  const SizedBox(height: 16),
                  const Text(
                    'Сумма ставки:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _predictionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Введите сумму',
                      suffixText: '₽',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_predictionController.text.isNotEmpty)
                    Text(
                      'Потенциальный выигрыш: ${(double.tryParse(_predictionController.text) ?? 0) * 2.5}₽',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: _predictionController.text.isNotEmpty
                    ? () {
                  _placePrediction();
                  Navigator.pop(context);
                }
                    : null,
                child: const Text('Подтвердить ставку'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _placePrediction() {
    final amount = double.tryParse(_predictionController.text) ?? 0;
    if (amount > 0) {
      setState(() {
        _predictions.insert(0, {
          'id': '${DateTime.now().millisecondsSinceEpoch}',
          'option': 'Победа команды B',
          'amount': amount,
          'potentialWin': amount * 2.22,
          'status': 'active',
          'date': DateTime.now(),
        });
        _userPoints -= amount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ставка на ${amount}₽ успешно размещена!'),
          duration: const Duration(seconds: 3),
        ),
      );
      _predictionController.clear();
    }
  }

  Widget _buildPredictionOption(Map<String, dynamic> option, StateSetter setDialogState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option['title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Коэффициент: ${option['odds']}',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
                Text(
                  '${option['votes']} ставок',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(option['probability'] * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Статистика лиги',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatCard('Общее количество прогнозов', _leagueStats['totalPredictions'].toString(), Icons.analytics),
            _buildStatCard('Активных пользователей', _leagueStats['activeUsers'].toString(), Icons.people),
            _buildStatCard('Успешность прогнозов', '${(_leagueStats['successRate'] * 100).toInt()}%', Icons.trending_up),
            _buildStatCard('Средний коэффициент', _leagueStats['averageOdds'].toStringAsFixed(2), Icons.show_chart),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
    );
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
              Color(0xFFF5F5F5), // Светло-серый верх
              Color(0xFFE8E8E8), // Светло-серый низ
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
                    // ОБЛОЖКА С ТАКИМИ ЖЕ ОТСТУПАМИ КАК У AppBar
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Stack(
                          children: [
                            // Основное изображение с такими же отступами как у AppBar
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

                            // Контент поверх изображения - ТАКИЕ ЖЕ ОТСТУПЫ
                            Positioned(
                              bottom: 40,
                              left: 16, // Отступ внутри обложки
                              right: 16, // Отступ внутри обложки
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Эмодзи и категория
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

                                  // Заголовок
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

                                  // Призовой фонд и участники
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

                          // КНОПКА УЧАСТИЯ - БЕЛАЯ КАРТОЧКА
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white, // БЕЛЫЙ ЦВЕТ
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
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: _showStatistics,
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.analytics, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // БАЛАНС ПОЛЬЗОВАТЕЛЯ - БЕЛАЯ КАРТОЧКА
                          if (_isSubscribed)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white, // БЕЛЫЙ ЦВЕТ
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
                                        ],
                                      ),
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
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          if (_isSubscribed) const SizedBox(height: 16),

                          // СТАТИСТИКА ЛИГИ - БЕЛАЯ КАРТОЧКА
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white, // БЕЛЫЙ ЦВЕТ
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Заголовок раздела
                                    const Text(
                                      'Статистика лиги',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Показатели
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem('Участники', widget.league.participants, Icons.people),
                                        _buildStatItem('Прогнозы', widget.league.predictions, Icons.analytics),
                                        _buildStatItem('Просмотры', widget.league.views, Icons.remove_red_eye),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Прогресс до окончания
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'До завершения лиги',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              widget.league.timeLeft,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: widget.league.progress,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            widget.league.isActive ? Colors.blue : Colors.green,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ТАБЫ - БЕЛАЯ КАРТОЧКА
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white, // БЕЛЫЙ ЦВЕТ
                              child: Column(
                                children: [
                                  // Заголовки табов
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
                                        _buildTabItem(1, 'Мои прогнозы'),
                                        _buildTabItem(2, 'Обсуждение'),
                                        _buildTabItem(3, 'Статистика'),
                                      ],
                                    ),
                                  ),

                                  // Контент табов
                                  Container(
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
  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          _formatNumber(value),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
      case 0: // Описание
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.league.description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Детальное описание:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.league.detailedDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Правила участия:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildRuleItem('Минимальная ставка: 10₽'),
            _buildRuleItem('Максимальная ставка: 1000₽'),
            _buildRuleItem('Комиссия платформы: 5%'),
            _buildRuleItem('Вывод средств: от 100₽'),
          ],
        );

      case 1: // Мои прогнозы
        return _predictions.isEmpty
            ? const Column(
          children: [
            Icon(Icons.analytics, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'У вас пока нет активных прогнозов',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Сделайте первую ставку!',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        )
            : Column(
          children: [
            ..._predictions.map((prediction) => _buildPredictionHistoryItem(prediction)).toList(),
          ],
        );

      case 2: // Обсуждение
        return Column(
          children: [
            // Поле ввода комментария
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Написать комментарий...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Список комментариев
            ..._demoComments.map((comment) => _buildCommentItem(comment)).toList(),
          ],
        );

      case 3: // Статистика
        return Column(
          children: [
            _buildStatCard('Общее количество прогнозов', _leagueStats['totalPredictions'].toString(), Icons.analytics),
            _buildStatCard('Активных пользователей', _leagueStats['activeUsers'].toString(), Icons.people),
            _buildStatCard('Успешность прогнозов', '${(_leagueStats['successRate'] * 100).toInt()}%', Icons.trending_up),
            _buildStatCard('Средний коэффициент', _leagueStats['averageOdds'].toStringAsFixed(2), Icons.show_chart),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(rule),
        ],
      ),
    );
  }

  Widget _buildPredictionHistoryItem(Map<String, dynamic> prediction) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  prediction['option'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: prediction['status'] == 'active' ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prediction['status'] == 'active' ? 'Активна' : 'Завершена',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Сумма: ${prediction['amount']}₽',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Потенциальный выигрыш: ${prediction['potentialWin']}₽',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Размещено: ${DateFormat('dd.MM.yyyy HH:mm').format(prediction['date'])}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватар
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  comment['avatar'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Контент комментария
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment['author'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        comment['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment['text'],
                    style: const TextStyle(
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          comment['isLiked'] ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: comment['isLiked'] ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        '${comment['likes']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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