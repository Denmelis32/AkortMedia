import 'package:flutter/material.dart';

class Prediction {
  final String id;
  final String userName;
  final String match;
  final String prediction;
  final DateTime timestamp;
  final int points;
  final bool isCorrect;
  final String userAvatar;
  final String league;
  final String matchTime;

  Prediction({
    required this.id,
    required this.userName,
    required this.match,
    required this.prediction,
    required this.timestamp,
    this.points = 0,
    this.isCorrect = false,
    this.userAvatar = '',
    required this.league,
    required this.matchTime,
  });
}

class PredictionsLeaguePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback? onLogout;

  const PredictionsLeaguePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.onLogout,
  });

  @override
  State<PredictionsLeaguePage> createState() => _PredictionsLeaguePageState();
}

class _PredictionsLeaguePageState extends State<PredictionsLeaguePage> {
  final List<Prediction> _predictions = [];
  final TextEditingController _predictionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showAddForm = false;

  // Список лиг и матчей
  final List<Map<String, dynamic>> _leagues = [
    {
      'name': 'Ла Лига',
      'matches': [
        'Барселона - Реал Мадрид',
        'Атлетико - Севилья',
        'Валенсия - Вильярреал',
      ]
    },
    {
      'name': 'АПЛ',
      'matches': [
        'Манчестер Сити - Манчестер Юнайтед',
        'Арсенал - Форест',
        'Ливерпуль - Челси',
      ]
    },
    {
      'name': 'Серия А',
      'matches': [
        'Интер - Милан',
        'Ювентус - Наполи',
        'Рома - Лацио',
      ]
    },
  ];

  String _selectedLeague = '';
  String _selectedMatch = '';

  @override
  void initState() {
    super.initState();
    _selectedLeague = _leagues[0]['name'];
    _selectedMatch = _leagues[0]['matches'][0];
    _addSamplePredictions();
  }

  @override
  void dispose() {
    _predictionController.dispose();
    super.dispose();
  }

  void _addSamplePredictions() {
    final samplePredictions = [
      Prediction(
        id: '1',
        userName: 'Алексей Футболов',
        match: 'Барселона - Реал Мадрид',
        prediction: '2:1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        points: 15,
        isCorrect: true,
        userAvatar: '⚽',
        league: 'Ла Лига',
        matchTime: '20:00',
      ),
      Prediction(
        id: '2',
        userName: 'Мария Скаут',
        match: 'Манчестер Сити - Манчестер Юнайтед',
        prediction: '1:2',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        points: 8,
        isCorrect: false,
        userAvatar: '👑',
        league: 'АПЛ',
        matchTime: '18:30',
      ),
      Prediction(
        id: '3',
        userName: 'Иван Голкипер',
        match: 'Интер - Милан',
        prediction: '0:0',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        points: 12,
        isCorrect: true,
        userAvatar: '🧤',
        league: 'Серия А',
        matchTime: '21:45',
      ),
    ];

    setState(() {
      _predictions.addAll(samplePredictions);
    });
  }

  void _addPrediction() {
    if (_formKey.currentState!.validate()) {
      final newPrediction = Prediction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: widget.userName,
        match: _selectedMatch,
        prediction: _predictionController.text,
        timestamp: DateTime.now(),
        userAvatar: _getRandomAvatar(),
        league: _selectedLeague,
        matchTime: '20:00',
      );

      setState(() {
        _predictions.insert(0, newPrediction);
        _showAddForm = false;
      });

      _predictionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Прогноз добавлен! 🎯'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getRandomAvatar() {
    final avatars = ['⚽', '⭐', '🔥', '👑', '🎯', '🏆', '👟', '🧤'];
    return avatars[DateTime.now().millisecond % avatars.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 7) return '${difference.inDays} д назад';

    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildUserRanking() {
    // Сортируем пользователей по очкам
    final userStats = _predictions.fold<Map<String, int>>({}, (map, prediction) {
      map[prediction.userName] = (map[prediction.userName] ?? 0) + prediction.points;
      return map;
    });

    final sortedUsers = userStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 ТОП ИГРОКОВ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (sortedUsers.isEmpty)
            const Text(
              'Пока нет результатов',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...sortedUsers.take(5).map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    radius: 16,
                    child: Text(
                      entry.key[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.value} очков',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(Prediction prediction, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и автор
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: prediction.isCorrect ? Colors.green[100] : Colors.red[100],
                    child: Text(
                      prediction.userAvatar,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prediction.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _formatDate(prediction.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (prediction.userName == widget.userName)
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                      onPressed: () => _showPredictionOptions(context, index),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Информация о матче
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sports_soccer, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prediction.match,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      prediction.league,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Прогноз и результат
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prediction.prediction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (prediction.points > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: prediction.isCorrect ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: prediction.isCorrect ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            prediction.isCorrect ? Icons.check : Icons.close,
                            size: 14,
                            color: prediction.isCorrect ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${prediction.points}',
                            style: TextStyle(
                              color: prediction.isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPredictionOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                _editPrediction(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить'),
              onTap: () {
                Navigator.pop(context);
                _deletePrediction(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editPrediction(int index) {
    // TODO: Реализовать редактирование прогноза
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Редактирование скоро будет доступно')),
    );
  }

  void _deletePrediction(int index) {
    setState(() {
      _predictions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Прогноз удален')),
    );
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Список прогнозов
              _predictions.isEmpty
                  ? SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Пока нет прогнозов',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Будьте первым, кто сделает прогноз!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) return _buildUserRanking();
                    return _buildPredictionCard(_predictions[index - 1], index - 1);
                  },
                  childCount: _predictions.length + 1,
                ),
              ),
            ],
          ),

          // Плавающая кнопка
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleAddForm,
              backgroundColor: const Color(0xFF1E88E5),
              child: Icon(
                _showAddForm ? Icons.close : Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Модальное окно для добавления прогноза
          if (_showAddForm)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: _buildAddPredictionForm(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPredictionForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Новый прогноз',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedLeague,
                decoration: InputDecoration(
                  labelText: 'Лига',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _leagues.map((league) {
                  return DropdownMenuItem<String>(
                    value: league['name'],
                    child: Text(league['name']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLeague = newValue!;
                    _selectedMatch = _leagues
                        .firstWhere((l) => l['name'] == newValue)['matches'][0];
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMatch,
                decoration: InputDecoration(
                  labelText: 'Матч',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _leagues
                    .firstWhere((l) => l['name'] == _selectedLeague)['matches']
                    .map<DropdownMenuItem<String>>((match) {
                  return DropdownMenuItem<String>(
                    value: match,
                    child: Text(match),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMatch = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _predictionController,
                decoration: InputDecoration(
                  labelText: 'Прогноз (например: 2:1)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите прогноз';
                  }
                  if (!RegExp(r'^\d+:\d+$').hasMatch(value)) {
                    return 'Формат: число:число (например: 2:1)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _toggleAddForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _addPrediction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Добавить',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}