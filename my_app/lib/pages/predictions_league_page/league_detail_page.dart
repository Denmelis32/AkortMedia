import 'package:flutter/material.dart';
import 'models/league_model.dart';
import 'models/match_model.dart';
import 'package:flutter/foundation.dart';
import 'league_detail_design.dart';
import 'league_detail_management.dart';

class LeagueDetailPage extends StatefulWidget {
  final League league;
  final Function(League) onLeagueUpdated;

  const LeagueDetailPage({
    super.key,
    required this.league,
    required this.onLeagueUpdated,
  });

  @override
  State<LeagueDetailPage> createState() => _LeagueDetailPageState();
}

class _LeagueDetailPageState extends State<LeagueDetailPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Матчи', 'Мои прогнозы', 'Рейтинг', 'Управление'];

  // Используем копию матчей для работы на этой странице
  List<Match> _matches = [];

  bool get _isCreator => widget.league.creatorId == 'user@example.com';

  @override
  void initState() {
    super.initState();

    // Проверяем и исправляем дубликаты ID
    _matches = LeagueDetailManagement.fixDuplicateMatchIds(widget.league.matches);

    if (kDebugMode) {
      _debugPrintMatches('После инициализации');
    }
  }

  void _updateLeagueMatches(List<Match> newMatches) {
    setState(() {
      // Создаем ГЛУБОКУЮ копию каждого матча
      _matches = newMatches.map((match) => match.copyWith()).toList();
    });

    // Также создаем глубокую копию для родительского компонента
    final updatedLeague = widget.league.copyWithMatches(
      newMatches.map((match) => match.copyWith()).toList(),
    );
    widget.onLeagueUpdated(updatedLeague);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LeagueDetailDesign.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.league.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: LeagueDetailDesign.textColor,
          ),
        ),
        backgroundColor: LeagueDetailDesign.cardColor,
        elevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: LeagueDetailDesign.primaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: _showFinalResults,
          ),
          if (_isCreator)
            IconButton(icon: const Icon(Icons.share), onPressed: _shareLeague),
        ],
      ),
      floatingActionButton: _isCreator && _selectedTab == 3
          ? FloatingActionButton(
        onPressed: _showAddMatchDialog,
        backgroundColor: LeagueDetailDesign.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: Column(
        children: [
          LeagueDetailDesign.buildTabSection(_tabs, _selectedTab, _isCreator, _onTabChanged),
          const SizedBox(height: 8),
          LeagueDetailDesign.buildLeagueStats(_matches),
          const SizedBox(height: 8),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildMatchesContent();
      case 1:
        return _buildPredictionsContent();
      case 2:
        return _buildRatingContent();
      case 3:
        return _buildManagementContent();
      default:
        return _buildMatchesContent();
    }
  }

  Widget _buildMatchesContent() {
    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: LeagueDetailDesign.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Матчей пока нет',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: LeagueDetailDesign.textColor,
              ),
            ),
            if (_isCreator) ...[
              const SizedBox(height: 8),
              Text(
                'Добавьте матчи во вкладке "Управление"',
                style: TextStyle(fontSize: 14, color: LeagueDetailDesign.secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _matches.map((match) {
        return LeagueDetailDesign.buildMatchCard(
          match,
          _isCreator,
          _showPredictionDialog,
          _showResultInputDialog,
        );
      }).toList(),
    );
  }

  Widget _buildPredictionsContent() {
    final userPredictions = _matches
        .where((match) => match.userPrediction.isNotEmpty)
        .toList();

    if (userPredictions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: LeagueDetailDesign.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Прогнозов пока нет',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: LeagueDetailDesign.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Сделайте прогноз на предстоящий матч!',
              style: TextStyle(fontSize: 16, color: LeagueDetailDesign.secondaryTextColor),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: userPredictions.map((match) {
        return LeagueDetailDesign.buildPredictionCard(match);
      }).toList(),
    );
  }

  Widget _buildRatingContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: LeagueDetailDesign.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Рейтинг участников',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: LeagueDetailDesign.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Топ-10 игроков лиги',
              style: TextStyle(fontSize: 16, color: LeagueDetailDesign.secondaryTextColor),
            ),
            const SizedBox(height: 20),
            LeagueDetailDesign.buildRatingList(_matches),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementContent() {
    if (!_isCreator) {
      return Center(
        child: Text(
          'Доступно только создателю лиги',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Управление лигой',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: LeagueDetailDesign.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Участников: ${widget.league.participants}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.sports, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Матчей: ${_matches.length}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Рассчитать результаты'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _matches.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 64,
                  color: LeagueDetailDesign.primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Матчей пока нет',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LeagueDetailDesign.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Добавьте первый матч',
                  style: TextStyle(
                    fontSize: 14,
                    color: LeagueDetailDesign.secondaryTextColor,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              final match = _matches[index];
              return _buildManageableMatchCard(match);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManageableMatchCard(Match match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.sports, color: LeagueDetailDesign.primaryColor),
        title: Text('${match.teamHome} - ${match.teamAway}'),
        subtitle: Text(
          '${LeagueDetailDesign.formatMatchDate(match.date)} • ${match.league}',
          style: TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (match.status == MatchStatus.upcoming)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => _showEditMatchDialog(match),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deleteMatch(match.id),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMatch(int matchId) {
    LeagueDetailManagement.showDeleteMatchDialog(
      context: context,
      matchId: matchId,
      onMatchDeleted: (id) {
        final updatedMatches = _matches
            .where((m) => m.id != id)
            .toList();
        _updateLeagueMatches(updatedMatches);
      },
    );
  }

  void _calculateResults() {
    LeagueDetailManagement.showCalculateResultsDialog(
      context: context,
      onCalculate: _performCalculation,
    );
  }

  void _showAddMatchDialog() {
    LeagueDetailManagement.showAddMatchDialog(
      context: context,
      leagueTitle: widget.league.title,
      existingMatches: _matches, // Добавлен недостающий аргумент
      onMatchAdded: (newMatch) {
        final updatedMatches = [..._matches, newMatch];
        _updateLeagueMatches(updatedMatches);
      },
    );
  }

  void _showEditMatchDialog(Match match) {
    LeagueDetailManagement.showEditMatchDialog(
      context: context,
      match: match,
      existingMatches: _matches, // Добавлен недостающий аргумент
      onMatchUpdated: (updatedMatch) {
        final updatedMatches = _matches
            .map((m) => m.id == match.id ? updatedMatch : m.copyWith())
            .toList();
        _updateLeagueMatches(updatedMatches);
      },
    );
  }

  void _showPredictionDialog(Match match) {
    LeagueDetailManagement.showPredictionDialog(
      context: context,
      match: match,
      onPredictionSaved: (prediction) {
        _savePrediction(match, prediction);
      },
    );
  }

  void _savePrediction(Match match, String prediction) {
    final updatedMatches = _matches.map((m) {
      if (m.id == match.id) {
        return m.copyWith(userPrediction: prediction);
      }
      return m.copyWith();
    }).toList();

    _updateLeagueMatches(updatedMatches);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Прогноз сохранен!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showResultInputDialog(Match match) {
    LeagueDetailManagement.showResultInputDialog(
      context: context,
      match: match,
      onResultSaved: (result) {
        _saveMatchResult(match.id, result);
      },
    );
  }

  void _saveMatchResult(int matchId, String result) {
    final updatedMatches = _matches.map((match) {
      if (match.id == matchId) {
        int points = 0;
        if (match.userPrediction.isNotEmpty) {
          points = Match.calculatePoints(match.userPrediction, result);
        }

        return match.copyWith(
          actualScore: result,
          status: MatchStatus.finished,
          points: points,
        );
      }
      return match.copyWith();
    }).toList();

    _updateLeagueMatches(updatedMatches);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Результат матча сохранен!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _performCalculation() {
    final updatedMatches = _matches.map((match) {
      if (match.status == MatchStatus.finished &&
          match.actualScore.isNotEmpty &&
          match.userPrediction.isNotEmpty) {
        final points = Match.calculatePoints(
          match.userPrediction,
          match.actualScore,
        );

        if (match.points != points) {
          return match.copyWith(points: points);
        }
      }
      return match;
    }).toList();

    _updateLeagueMatches(updatedMatches);

    final totalPoints = updatedMatches.fold(
      0,
          (sum, match) => sum + match.points,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Результаты рассчитаны! Общее количество очков: $totalPoints',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFinalResults() {
    LeagueDetailManagement.showFinalResultsDialog(
      context: context,
      matches: _matches,
    );
  }

  void _shareLeague() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ссылка на лигу скопирована')),
    );
  }

  void _debugPrintMatches(String operation) {
    if (kDebugMode) {
      print('=== $operation ===');
      for (var match in _matches) {
        print('ID: ${match.id}, Prediction: "${match.userPrediction}", Hash: ${match.hashCode}');
      }
      print('===================');
    }
  }
}