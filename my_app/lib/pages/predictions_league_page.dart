import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/prediction.dart';
import '../models/match.dart';
import '../models/user_stats.dart';
import '../models/head_to_head_match.dart';
import '../widgets/prediction_card.dart';
import '../widgets/user_ranking.dart';
import '../widgets/head_to_head_match_card.dart';
import '../widgets/add_prediction_form.dart';

class PredictionsLeaguePage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final VoidCallback? onLogout;

  const PredictionsLeaguePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.onLogout,
  });

  @override
  State<PredictionsLeaguePage> createState() => _PredictionsLeaguePageState();
}

class _PredictionsLeaguePageState extends State<PredictionsLeaguePage>
    with SingleTickerProviderStateMixin {
  final List<Prediction> _predictions = [];
  final List<Match> _matches = [];
  final List<UserStats> _userStats = [];
  final List<HeadToHeadMatch> _headToHeadMatches = [];
  final TextEditingController _predictionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showAddForm = false;
  late TabController _tabController;

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
  String _selectedMatchId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedLeague = _leagues[0]['name'];
    _selectedMatch = _leagues[0]['matches'][0];
    _initializeData();
  }

  @override
  void dispose() {
    _predictionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Инициализация матчей
    final now = DateTime.now();
    _matches.addAll([
      Match(
        id: '1',
        homeTeam: 'Барселона',
        awayTeam: 'Реал Мадрид',
        league: 'Ла Лига',
        date: now.add(const Duration(days: 1)),
        time: '20:00',
        result: '2:1',
        isFinished: true,
      ),
      Match(
        id: '2',
        homeTeam: 'Манчестер Сити',
        awayTeam: 'Манчестер Юнайтед',
        league: 'АПЛ',
        date: now.add(const Duration(days: 2)),
        time: '18:30',
        result: '1:2',
        isFinished: true,
      ),
      Match(
        id: '3',
        homeTeam: 'Интер',
        awayTeam: 'Милан',
        league: 'Серия А',
        date: now.add(const Duration(days: 3)),
        time: '21:45',
        result: '0:0',
        isFinished: true,
      ),
      Match(
        id: '4',
        homeTeam: 'Арсенал',
        awayTeam: 'Форест',
        league: 'АПЛ',
        date: now.add(const Duration(days: 4)),
        time: '16:00',
      ),
      Match(
        id: '5',
        homeTeam: 'Ливерпуль',
        awayTeam: 'Челси',
        league: 'АПЛ',
        date: now.add(const Duration(days: 5)),
        time: '15:00',
      ),
    ]);

    _selectedMatchId = _matches[0].id;

    // Инициализация пользователей
    _userStats.addAll([
      UserStats(
        userId: '1',
        userName: 'Алексей Футболов',
        userAvatar: '⚽',
        points: 15,
        matchesPlayed: 3,
        wins: 2,
        draws: 0,
        losses: 1,
        correctPredictions: 2,
      ),
      UserStats(
        userId: '2',
        userName: 'Мария Скаут',
        userAvatar: '👑',
        points: 8,
        matchesPlayed: 3,
        wins: 1,
        draws: 0,
        losses: 2,
        correctPredictions: 1,
      ),
      UserStats(
        userId: '3',
        userName: 'Иван Голкипер',
        userAvatar: '🧤',
        points: 12,
        matchesPlayed: 3,
        wins: 1,
        draws: 1,
        losses: 1,
        correctPredictions: 2,
      ),
      UserStats(
        userId: widget.userId,
        userName: widget.userName,
        userAvatar: _getRandomAvatar(),
        points: 0,
        matchesPlayed: 0,
        wins: 0,
        draws: 0,
        losses: 0,
        correctPredictions: 0,
      ),
    ]);

    // Инициализация прогнозов
    _addSamplePredictions();

    // Инициализация матчей 1 на 1
    _headToHeadMatches.addAll([
      HeadToHeadMatch(
        id: '1',
        user1Id: '1',
        user1Name: 'Алексей Футболов',
        user2Id: '2',
        user2Name: 'Мария Скаут',
        matchIds: ['1', '2', '3'],
        createdDate: now.subtract(const Duration(days: 2)),
        isCompleted: true,
        user1Points: 15,
        user2Points: 8,
        winnerId: '1',
      ),
      HeadToHeadMatch(
        id: '2',
        user1Id: '1',
        user1Name: 'Алексей Футболов',
        user2Id: '3',
        user2Name: 'Иван Голкипер',
        matchIds: ['4', '5'],
        createdDate: now.subtract(const Duration(days: 1)),
        isCompleted: false,
        user1Points: 0,
        user2Points: 0,
      ),
    ]);
  }

  void _addSamplePredictions() {
    final samplePredictions = [
      Prediction(
        id: '1',
        userId: '1',
        userName: 'Алексей Футболов',
        matchId: '1',
        match: 'Барселона - Реал Мадрид',
        prediction: '2:1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        points: 15,
        isCorrect: true,
        userAvatar: '⚽',
        league: 'Ла Лига',
        matchTime: '20:00',
        matchDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Prediction(
        id: '2',
        userId: '2',
        userName: 'Мария Скаут',
        matchId: '1',
        match: 'Барселона - Реал Мадрид',
        prediction: '1:2',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        points: 0,
        isCorrect: false,
        userAvatar: '👑',
        league: 'Ла Лига',
        matchTime: '20:00',
        matchDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Prediction(
        id: '3',
        userId: '3',
        userName: 'Иван Голкипер',
        matchId: '1',
        match: 'Барселона - Реал Мадрид',
        prediction: '2:2',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        points: 0,
        isCorrect: false,
        userAvatar: '🧤',
        league: 'Ла Лига',
        matchTime: '20:00',
        matchDate: DateTime.now().add(const Duration(days: 1)),
      ),
    ];

    setState(() {
      _predictions.addAll(samplePredictions);
    });
  }

  void _addPrediction() {
    if (_formKey.currentState!.validate()) {
      final selectedMatch = _matches.firstWhere((m) => m.id == _selectedMatchId);

      final newPrediction = Prediction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.userId,
        userName: widget.userName,
        matchId: _selectedMatchId,
        match: selectedMatch.name,
        prediction: _predictionController.text,
        timestamp: DateTime.now(),
        userAvatar: _getRandomAvatar(),
        league: _selectedLeague,
        matchTime: selectedMatch.time,
        matchDate: selectedMatch.date,
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

  void _createHeadToHeadChallenge() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция создания матча скоро будет доступна')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Лига Прогнозов'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Прогнозы'),
            Tab(text: 'Турнир'),
            Tab(text: 'Матчи 1x1'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _createHeadToHeadChallenge,
            tooltip: 'Создать матч 1 на 1',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка прогнозов
          _buildPredictionsTab(),

          // Вкладка турнирной таблицы
          _buildTournamentTab(),

          // Вкладка матчей 1 на 1
          _buildHeadToHeadTab(),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab() {
    return Stack(
      children: [
        _predictions.isEmpty
            ? Center(
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
        )
            : ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: _predictions.length,
          itemBuilder: (context, index) {
            return PredictionCard(
              prediction: _predictions[index],
              match: _matches.firstWhereOrNull((m) => m.id == _predictions[index].matchId),
              onOptionsPressed: () => _showPredictionOptions(context, index),
              formatDate: _formatDate,
            );
          },
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
                    child: AddPredictionForm(
                      formKey: _formKey,
                      leagues: _leagues,
                      matches: _matches,
                      selectedLeague: _selectedLeague,
                      selectedMatchId: _selectedMatchId,
                      predictionController: _predictionController,
                      onLeagueChanged: (newValue) {
                        setState(() {
                          _selectedLeague = newValue!;
                        });
                      },
                      onMatchChanged: (newValue) {
                        setState(() {
                          _selectedMatchId = newValue!;
                          final selectedMatch = _matches.firstWhere((m) => m.id == newValue);
                          _selectedMatch = selectedMatch.name;
                          _selectedLeague = selectedMatch.league;
                        });
                      },
                      onCancel: _toggleAddForm,
                      onSubmit: _addPrediction,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTournamentTab() {
    return ListView(
      children: [
        UserRanking(
          userStats: _userStats,
          currentUserId: widget.userId,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Последние прогнозы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ..._predictions.take(3).map((prediction) => PredictionCard(
          prediction: prediction,
          match: _matches.firstWhereOrNull((m) => m.id == prediction.matchId),
          onOptionsPressed: () => _showPredictionOptions(
              context, _predictions.indexOf(prediction)),
          formatDate: _formatDate,
        )),
      ],
    );
  }

  Widget _buildHeadToHeadTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _headToHeadMatches.length,
      itemBuilder: (context, index) {
        final match = _headToHeadMatches[index];
        return HeadToHeadMatchCard(match: match);
      },
    );
  }
}