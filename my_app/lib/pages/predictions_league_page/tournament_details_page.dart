import 'package:flutter/material.dart';
import './models/tournament_model.dart';
import './models/match_model.dart';
import './models/prediction_model.dart';
import './models/standing_model.dart';
import './widgets/match_prediction_card.dart';
import './widgets/prediction_dialog.dart';
import './widgets/standings_widget.dart';

class TournamentDetailsPage extends StatefulWidget {
  final Tournament tournament;
  final String userName;
  final String userId;

  const TournamentDetailsPage({
    super.key,
    required this.tournament,
    required this.userName,
    this.userId = 'current_user',
  });

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  final List<Match> _matches = [
    Match(
      id: '1',
      homeTeam: 'Манчестер Юнайтед',
      awayTeam: 'Челси',
      matchTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      status: 'scheduled',
    ),
    Match(
      id: '2',
      homeTeam: 'Арсенал',
      awayTeam: 'Ливерпуль',
      matchTime: DateTime.now().add(const Duration(days: 3, hours: 5)),
      status: 'scheduled',
    ),
    Match(
      id: '3',
      homeTeam: 'Манчестер Сити',
      awayTeam: 'Тоттенхэм',
      matchTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      status: 'scheduled',
    ),
    Match(
      id: '4',
      homeTeam: 'Барселона',
      awayTeam: 'Реал Мадрид',
      matchTime: DateTime.now().subtract(const Duration(days: 1)),
      homeScore: '2',
      awayScore: '1',
      status: 'finished',
    ),
    Match(
      id: '5',
      homeTeam: 'Бавария',
      awayTeam: 'Боруссия Д',
      matchTime: DateTime.now().add(const Duration(hours: 1)),
      status: 'scheduled',
    ),
    Match(
      id: '6',
      homeTeam: 'ПСЖ',
      awayTeam: 'Олимпик Марсель',
      matchTime: DateTime.now(),
      homeScore: '1',
      awayScore: '0',
      status: 'live',
    ),
  ];

  final List<Prediction> _predictions = [
    Prediction(
      id: '1',
      matchId: '4',
      userId: 'current_user',
      homeScore: 2,
      awayScore: 1,
      predictedAt: DateTime.now().subtract(const Duration(days: 2)),
      points: 3, // Правильный прогноз
    ),
    Prediction(
      id: '2',
      matchId: '6',
      userId: 'current_user',
      homeScore: 2,
      awayScore: 0,
      predictedAt: DateTime.now().subtract(const Duration(days: 1)),
      points: 1, // Угадана победа хозяев
    ),
  ];

  final List<Standing> _standings = [
    Standing(
      userId: 'user1',
      userName: 'Алексей Петров',
      points: 25,
      correctPredictions: 8,
      totalPredictions: 12,
      position: 1,
    ),
    Standing(
      userId: 'user2',
      userName: 'Мария Иванова',
      points: 22,
      correctPredictions: 7,
      totalPredictions: 10,
      position: 2,
    ),
    Standing(
      userId: 'current_user',
      userName: 'Вы',
      points: 18,
      correctPredictions: 6,
      totalPredictions: 9,
      position: 3,
    ),
    Standing(
      userId: 'user3',
      userName: 'Дмитрий Смирнов',
      points: 15,
      correctPredictions: 5,
      totalPredictions: 11,
      position: 4,
    ),
    Standing(
      userId: 'user4',
      userName: 'Екатерина Волкова',
      points: 12,
      correctPredictions: 4,
      totalPredictions: 8,
      position: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tournament.name),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sports_soccer), text: 'Матчи'),
              Tab(icon: Icon(Icons.leaderboard), text: 'Таблица'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMatchesTab(),
            _buildStandingsTab(),
          ],
        ),
        floatingActionButton: _buildStatsFAB(),
      ),
    );
  }

  Widget _buildMatchesTab() {
    // Сортируем матчи: сначала завершенные, потом live, потом будущие
    final sortedMatches = List.of(_matches)
      ..sort((a, b) {
        if (a.status == 'finished' && b.status != 'finished') return -1;
        if (a.status != 'finished' && b.status == 'finished') return 1;
        if (a.status == 'live' && b.status != 'live') return -1;
        if (a.status != 'live' && b.status == 'live') return 1;
        return a.matchTime.compareTo(b.matchTime);
      });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статистика пользователя
          _buildUserStats(),
          const SizedBox(height: 20),

          // Заголовок
          const Text(
            'Матчи турнира:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_matches.where((m) => m.status == 'finished').length} завершено • '
                '${_matches.where((m) => m.status == 'live').length} в прямом эфире • '
                '${_matches.where((m) => m.status == 'scheduled').length} предстоит',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Список матчей
          Expanded(
            child: ListView.builder(
              itemCount: sortedMatches.length,
              itemBuilder: (context, index) {
                final match = sortedMatches[index];
                final prediction = _getUserPrediction(match.id);

                return MatchPredictionCard(
                  match: match,
                  userPrediction: prediction,
                  onPredict: () => _showPredictionDialog(match),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    final userStanding = _standings.firstWhere(
          (s) => s.userId == widget.userId,
      orElse: () => Standing(
        userId: widget.userId,
        userName: widget.userName,
        points: 0,
        correctPredictions: 0,
        totalPredictions: 0,
        position: _standings.length + 1,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Позиция', '#${userStanding.position}'),
          _buildStatItem('Очки', '${userStanding.points}'),
          _buildStatItem('Точность', '${userStanding.accuracy.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStandingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о турнире
          _buildTournamentInfo(),
          const SizedBox(height: 20),

          // Таблица лидеров
          Expanded(
            child: StandingsWidget(standings: _standings),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTournamentStat('Призовой фонд', '${widget.tournament.prizePool} ₽'),
          _buildTournamentStat('Участники', '${widget.tournament.participants}'),
          _buildTournamentStat('Ваша позиция', '#${_getUserPosition()}'),
        ],
      ),
    );
  }

  Widget _buildTournamentStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsFAB() {
    return FloatingActionButton(
      onPressed: _showUserStats,
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      child: const Icon(Icons.analytics),
      tooltip: 'Моя статистика',
    );
  }

  Prediction? _getUserPrediction(String matchId) {
    try {
      return _predictions.firstWhere(
            (prediction) =>
        prediction.matchId == matchId &&
            prediction.userId == widget.userId,
      );
    } catch (e) {
      return null;
    }
  }

  int _getUserPosition() {
    try {
      return _standings.firstWhere(
            (s) => s.userId == widget.userId,
      ).position;
    } catch (e) {
      return _standings.length + 1;
    }
  }

  void _showPredictionDialog(Match match) {
    // Проверяем, можно ли еще делать прогноз (матч еще не начался)
    if (match.status != 'scheduled') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Прогнозы на этот матч больше не принимаются'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PredictionDialog(
        match: match,
        onSavePrediction: (homeScore, awayScore) {
          _savePrediction(match.id, homeScore, awayScore);
        },
      ),
    );
  }

  void _savePrediction(String matchId, int homeScore, int awayScore) {
    setState(() {
      // Удаляем старый прогноз если есть
      _predictions.removeWhere(
            (p) => p.matchId == matchId && p.userId == widget.userId,
      );

      // Добавляем новый прогноз
      _predictions.add(Prediction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        matchId: matchId,
        userId: widget.userId,
        homeScore: homeScore,
        awayScore: awayScore,
        predictedAt: DateTime.now(),
        points: 0, // Очки будут начислены после матча
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Прогноз успешно сохранен!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showUserStats() {
    final userStanding = _standings.firstWhere(
          (s) => s.userId == widget.userId,
      orElse: () => Standing(
        userId: widget.userId,
        userName: widget.userName,
        points: 0,
        correctPredictions: 0,
        totalPredictions: 0,
        position: _standings.length + 1,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Моя статистика'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Общее место', '#${userStanding.position} из ${_standings.length}'),
            _buildStatRow('Всего очков', '${userStanding.points}'),
            _buildStatRow('Правильных прогнозов', '${userStanding.correctPredictions} из ${userStanding.totalPredictions}'),
            _buildStatRow('Точность', '${userStanding.accuracy.toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text(
              'Система начисления очков:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildStatRow('Угадан точный счет', '3 очка'),
            _buildStatRow('Угадан исход матча', '1 очко'),
            _buildStatRow('Неправильный прогноз', '0 очков'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}