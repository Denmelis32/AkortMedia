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

class PredictionLeaguePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const PredictionLeaguePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<PredictionLeaguePage> createState() => _PredictionLeaguePageState();
}

class _PredictionLeaguePageState extends State<PredictionLeaguePage> {
  final List<Prediction> _predictions = [];
  final TextEditingController _predictionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Список лиг и матчей
  final List<Map<String, dynamic>> _leagues = [
    {
      'name': 'Ла Лига',
      'matches': [
        'Барселона - Реал Мадрид',
        'Атлетико - Севилья',
      ]
    },
    {
      'name': 'АПЛ',
      'matches': [
        'Манчестер Сити - Манчестер Юнайтед',
        'Арсенал - Форест',
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
    _scrollController.dispose();
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
      });

      _predictionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Прогноз добавлен!')),
      );
    }
  }

  String _getRandomAvatar() {
    final avatars = ['⚽', '⭐', '🔥', '👑'];
    return avatars[DateTime.now().millisecond % avatars.length];
  }

  Widget _buildUserRanking() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            'ТОП ИГРОКОВ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Рейтинг обновляется...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Упрощенный заголовок
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: const Color(0xFFA31525),
              child: const Text(
                'ЛИГА ПРОГНОЗОВ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Основной контент с прокруткой
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUserRanking(),

                    // Форма для добавления прогноза
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedLeague,
                              decoration: InputDecoration(
                                labelText: 'Лига',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _leagues.map((league) {
                                return DropdownMenuItem<String>(
                                  value: league['name'],
                                  child: Text(
                                    league['name'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
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

                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              value: _selectedMatch,
                              decoration: InputDecoration(
                                labelText: 'Матч',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _leagues
                                  .firstWhere((l) => l['name'] == _selectedLeague)['matches']
                                  .map<DropdownMenuItem<String>>((match) {
                                return DropdownMenuItem<String>(
                                  value: match,
                                  child: Text(
                                    match,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedMatch = newValue!;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _predictionController,
                              decoration: InputDecoration(
                                labelText: 'Прогноз (2:1)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите прогноз';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _addPrediction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA31525),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('ДОБАВИТЬ ПРОГНОЗ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Заголовок списка
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          const Text(
                            'ПРОГНОЗЫ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text('${_predictions.length}'),
                            backgroundColor: const Color(0xFFA31525),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Список прогнозов
                    ..._predictions.map((prediction) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: prediction.isCorrect ? Colors.green[100] : Colors.red[100],
                            child: Text(prediction.userAvatar),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prediction.match,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  prediction.userName,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA31525),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              prediction.prediction,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension PredictionExtension on Prediction {
  Prediction copyWith({
    String? id,
    String? userName,
    String? match,
    String? prediction,
    DateTime? timestamp,
    int? points,
    bool? isCorrect,
    String? userAvatar,
    String? league,
    String? matchTime,
  }) {
    return Prediction(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      match: match ?? this.match,
      prediction: prediction ?? this.prediction,
      timestamp: timestamp ?? this.timestamp,
      points: points ?? this.points,
      isCorrect: isCorrect ?? this.isCorrect,
      userAvatar: userAvatar ?? this.userAvatar,
      league: league ?? this.league,
      matchTime: matchTime ?? this.matchTime,
    );
  }
}