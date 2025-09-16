import 'package:flutter/material.dart';
import 'models/league_model.dart';
import 'models/match_model.dart';
import 'package:flutter/foundation.dart';

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
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _backgroundColor = const Color(0xFFF5F9FF);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _secondaryTextColor = const Color(0xFF666666);

  int _selectedTab = 0;
  final List<String> _tabs = ['Матчи', 'Мои прогнозы', 'Рейтинг', 'Управление'];

  // Используем копию матчей для работы на этой странице
  List<Match> _matches = [];

  bool get _isCreator => widget.league.creatorId == 'user@example.com';

  @override
  void initState() {
    super.initState();

    // Проверяем и исправляем дубликаты ID
    _matches = _fixDuplicateMatchIds(widget.league.matches);

    if (kDebugMode) {
      _debugPrintMatches('После инициализации');
    }
  }

  List<Match> _fixDuplicateMatchIds(List<Match> matches) {
    final uniqueIds = <int>{};
    final fixedMatches = <Match>[];
    int newId = 1000; // Начинаем с большого числа чтобы избежать конфликтов

    for (var match in matches) {
      if (uniqueIds.contains(match.id)) {
        // Найден дубликат ID - создаем новый уникальный ID
        while (uniqueIds.contains(newId)) {
          newId++;
        }
        fixedMatches.add(match.copyWith(id: newId));
        uniqueIds.add(newId);
        newId++;
      } else {
        // ID уникален - оставляем как есть
        fixedMatches.add(match.copyWith());
        uniqueIds.add(match.id);
      }
    }

    return fixedMatches;
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.league.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: _textColor,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: _primaryColor),
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
              backgroundColor: _primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          _buildTabSection(),
          const SizedBox(height: 8),
          _buildLeagueStats(),
          const SizedBox(height: 8),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    final tabs = _isCreator ? _tabs : _tabs.sublist(0, 3);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final index = tabs.indexOf(tab);
          final isActive = index == _selectedTab;
          return Expanded(
            child: _buildTabButton(tab, isActive, () {
              setState(() {
                _selectedTab = index;
              });
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? _primaryColor : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? _primaryColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueStats() {
    final totalPoints = _matches.fold(0, (sum, match) => sum + match.points);
    final finishedMatches = _matches
        .where((m) => m.status == MatchStatus.finished)
        .length;
    final accuracy = finishedMatches > 0
        ? ((_matches.where((m) => m.points > 0).length / finishedMatches) * 100)
              .round()
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withOpacity(0.1),
            _primaryColor.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${_matches.length}', 'Матчей'),
          _buildStatItem('$finishedMatches', 'Завершено'),
          _buildStatItem('$accuracy%', 'Точность'),
          _buildStatItem('$totalPoints', 'Очков'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
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
              color: _primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Матчей пока нет',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            if (_isCreator) ...[
              const SizedBox(height: 8),
              Text(
                'Добавьте матчи во вкладке "Управление"',
                style: TextStyle(fontSize: 14, color: _secondaryTextColor),
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
        return _buildMatchCard(match);
      }).toList(),
    );
  }

  Widget _buildMatchCard(Match match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  match.league,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    fontSize: 14,
                  ),
                ),
                // ОТЛАДОЧНАЯ ИНФОРМАЦИЯ - покажем ID и хэш
                if (kDebugMode)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ID:${match.id}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                      Text(
                        'Hash:${match.hashCode}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 8),
                      ),
                    ],
                  ),
                Text(
                  _formatMatchDate(match.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.network(
                            match.imageHome,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.sports),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.teamHome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        if (match.status == MatchStatus.finished)
                          Text(
                            match.actualScore,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          )
                        else if (match.status == MatchStatus.live)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          Text(
                            _formatMatchTime(match.date),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _getMatchStatusText(match.status),
                          style: TextStyle(
                            color: _getStatusColor(match.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.network(
                            match.imageAway,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.sports),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.teamAway,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Прогноз пользователя
                if (match.userPrediction.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Ваш прогноз: ${match.userPrediction}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (match.status == MatchStatus.upcoming)
                  ElevatedButton(
                    onPressed: () => _showPredictionDialog(match),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Сделать прогноз'),
                  ),

                // Результат матча
                if (match.status == MatchStatus.finished &&
                    match.userPrediction.isNotEmpty)
                  const SizedBox(height: 12),
                if (match.status == MatchStatus.finished &&
                    match.userPrediction.isNotEmpty)
                  Text(
                    match.userPrediction == match.actualScore
                        ? '✅ Вы угадали результат! +${match.points} очков'
                        : '❌ Прогноз не совпал',
                    style: TextStyle(
                      color: match.userPrediction == match.actualScore
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                // Отображение очков
                if (match.points > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      '+${match.points} очков',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Кнопка ввода результата для создателя
                if (_isCreator && match.status == MatchStatus.upcoming)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: ElevatedButton(
                      onPressed: () => _showResultInputDialog(match),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ввести результат'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
              color: _primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Прогнозов пока нет',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Сделайте прогноз на предстоящий матч!',
              style: TextStyle(fontSize: 16, color: _secondaryTextColor),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: userPredictions.map((match) {
        return _buildPredictionCard(match);
      }).toList(),
    );
  }

  Widget _buildPredictionCard(Match match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${match.teamHome} - ${match.teamAway}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                match.status == MatchStatus.finished
                    ? (match.points > 0 ? Icons.check_circle : Icons.cancel)
                    : Icons.access_time,
                color: match.status == MatchStatus.finished
                    ? (match.points > 0 ? Colors.green : Colors.red)
                    : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Прогноз: ${match.userPrediction}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: match.status == MatchStatus.finished
                      ? (match.points > 0 ? Colors.green : Colors.red)
                      : Colors.blue,
                ),
              ),
            ],
          ),
          if (match.status == MatchStatus.finished) ...[
            const SizedBox(height: 4),
            Text(
              'Результат: ${match.actualScore}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (match.points > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Очки: +${match.points}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Дата: ${_formatMatchDate(match.date)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    ); // Убрали лишнюю точку с запятой здесь
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
              color: _primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Рейтинг участников',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Топ-10 игроков лиги',
              style: TextStyle(fontSize: 16, color: _secondaryTextColor),
            ),
            const SizedBox(height: 20),
            _buildRatingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingList() {
    final List<Map<String, dynamic>> leaders = [
      {'name': 'Алексей Иванов', 'points': 245, 'accuracy': '85%'},
      {'name': 'Мария Петрова', 'points': 228, 'accuracy': '82%'},
      {'name': 'Иван Сидоров', 'points': 215, 'accuracy': '80%'},
      {
        'name': 'Вы',
        'points': _matches.fold(0, (sum, match) => sum + match.points),
        'accuracy': '78%',
      },
      {'name': 'Дмитрий Козлов', 'points': 185, 'accuracy': '75%'},
    ];

    // Сортируем по очкам
    leaders.sort((a, b) => b['points'].compareTo(a['points']));

    return Column(
      children: leaders.asMap().entries.map((entry) {
        final index = entry.key;
        final leader = entry.value;
        final isCurrentUser = leader['name'] == 'Вы';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? _primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isCurrentUser
                ? Border.all(color: _primaryColor.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? _primaryColor : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  leader['name'] ?? 'Неизвестный',
                  style: TextStyle(
                    fontWeight: isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCurrentUser ? _primaryColor : Colors.black,
                  ),
                ),
              ),
              Text(
                '${leader['points']} очков',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
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
                      color: _primaryColor,
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
                        color: _primaryColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Матчей пока нет',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Добавьте первый матч',
                        style: TextStyle(
                          fontSize: 14,
                          color: _secondaryTextColor,
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
        leading: Icon(Icons.sports, color: _primaryColor),
        title: Text('${match.teamHome} - ${match.teamAway}'),
        subtitle: Text(
          '${_formatMatchDate(match.date)} • ${match.league}',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить матч?'),
        content: const Text('Вы уверены, что хотите удалить этот матч?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedMatches = _matches
                  .where((m) => m.id != matchId)
                  .toList();
              _updateLeagueMatches(updatedMatches);
              Navigator.pop(context);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Матч удален!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _calculateResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Рассчитать результаты'),
        content: const Text(
          'Вы уверены, что хотите рассчитать результаты для всех завершенных матчей?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              _performCalculation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Рассчитать'),
          ),
        ],
      ),
    );
  }

  void _showAddMatchDialog() {
    final TextEditingController homeController = TextEditingController();
    final TextEditingController awayController = TextEditingController();
    final TextEditingController leagueController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Добавить матч'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: homeController,
                      decoration: const InputDecoration(
                        labelText: 'Хозяева',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: awayController,
                      decoration: const InputDecoration(
                        labelText: 'Гости',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: leagueController,
                      decoration: const InputDecoration(
                        labelText: 'Турнир',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                              if (pickedTime != null) {
                                setState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                            child: Text(
                              '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
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
                  onPressed: () {
                    if (homeController.text.isNotEmpty &&
                        awayController.text.isNotEmpty) {
                      final matchDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      // Генерируем уникальный ID
                      final newId = _generateUniqueMatchId();

                      final newMatch = Match(
                        id: newId,
                        teamHome: homeController.text,
                        teamAway: awayController.text,
                        league: leagueController.text.isNotEmpty
                            ? leagueController.text
                            : widget.league.title,
                        date: matchDateTime,
                        imageHome:
                            'https://via.placeholder.com/60?text=${homeController.text.substring(0, 1)}',
                        imageAway:
                            'https://via.placeholder.com/60?text=${awayController.text.substring(0, 1)}',
                        userPrediction: '',
                        actualScore: '',
                        status: MatchStatus.upcoming,
                        points: 0,
                      );

                      // СОЗДАЕМ НОВЫЙ СПИСОК, а не изменяем существующий
                      final updatedMatches = [..._matches, newMatch];
                      _updateLeagueMatches(updatedMatches);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Матч добавлен!')),
                      );
                    }
                  },
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Генерация уникального ID для матча
  int _generateUniqueMatchId() {
    final existingIds = _matches.map((m) => m.id).toSet();
    int newId = DateTime.now().millisecondsSinceEpoch;

    // Убедимся, что ID уникален
    while (existingIds.contains(newId)) {
      newId++;
    }

    return newId;
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





  void _showEditMatchDialog(Match match) {
    final homeController = TextEditingController(text: match.teamHome);
    final awayController = TextEditingController(text: match.teamAway);
    final leagueController = TextEditingController(text: match.league);
    DateTime selectedDate = match.date;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(match.date);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Редактировать матч'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: homeController,
                      decoration: const InputDecoration(
                        labelText: 'Хозяева',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: awayController,
                      decoration: const InputDecoration(
                        labelText: 'Гости',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: leagueController,
                      decoration: const InputDecoration(
                        labelText: 'Турнир',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                              if (pickedTime != null) {
                                setState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                            child: Text(
                              '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
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
                  onPressed: () {
                    if (homeController.text.isNotEmpty &&
                        awayController.text.isNotEmpty) {
                      final matchDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final updatedMatch = match.copyWith(
                        teamHome: homeController.text,
                        teamAway: awayController.text,
                        league: leagueController.text,
                        date: matchDateTime,
                        imageHome:
                            'https://via.placeholder.com/60?text=${homeController.text.substring(0, 1)}',
                        imageAway:
                            'https://via.placeholder.com/60?text=${awayController.text.substring(0, 1)}',
                      );

                      final updatedMatches = _matches
                          .map(
                            (m) =>
                                m.id == match.id ? updatedMatch : m.copyWith(),
                          )
                          .toList();
                      _updateLeagueMatches(updatedMatches);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Матч обновлен!')),
                      );
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPredictionDialog(Match match) {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Прогноз на матч ${match.teamHome} - ${match.teamAway}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Введите предполагаемый счет:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: homeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: match.teamHome,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: awayController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: match.teamAway,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: homeController,
                builder: (context, homeValue, child) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: awayController,
                    builder: (context, awayValue, child) {
                      final prediction = '${homeValue.text}:${awayValue.text}';
                      final isValid = Match.isValidPredictionFormat(prediction);

                      if (!isValid && prediction != ':') {
                        return const Text(
                          'Введите корректный счет (например: 2:1)',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        );
                      }
                      return const SizedBox();
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: homeController,
              builder: (context, homeValue, child) {
                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: awayController,
                  builder: (context, awayValue, child) {
                    final prediction = '${homeValue.text}:${awayValue.text}';
                    final isValid = Match.isValidPredictionFormat(prediction);

                    return ElevatedButton(
                      onPressed: isValid
                          ? () {
                              _savePrediction(match, prediction);
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text('Сохранить'),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _savePrediction(Match match, String prediction) {
    final updatedMatches = _matches.map((m) {
      if (m.id == match.id) {
        return m.copyWith(userPrediction: prediction);
      }
      return m.copyWith(); // Важно: создаем копию каждого матча
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
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Результат матча ${match.teamHome} - ${match.teamAway}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Введите фактический счет:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: homeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: match.teamHome,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: awayController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: match.teamAway,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
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
                if (homeController.text.isNotEmpty &&
                    awayController.text.isNotEmpty) {
                  _saveMatchResult(
                    match.id,
                    '${homeController.text}:${awayController.text}',
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
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
          // Создаем новую копию
          actualScore: result,
          status: MatchStatus.finished,
          points: points,
        );
      }
      return match.copyWith(); // Создаем копию даже для неизмененных матчей
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

        // Обновляем только если очки изменились
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
    final userPredictions = _matches
        .where((match) => match.userPrediction.isNotEmpty)
        .toList();
    final totalPoints = userPredictions.fold(
      0,
      (sum, match) => sum + match.points,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Итоговые результаты'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Общее количество очков: $totalPoints',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...userPredictions
                  .map(
                    (match) => ListTile(
                      title: Text('${match.teamHome} - ${match.teamAway}'),
                      subtitle: Text(
                        'Прогноз: ${match.userPrediction} • Результат: ${match.actualScore}',
                      ),
                      trailing: Text(
                        '+${match.points}',
                        style: TextStyle(
                          color: match.points > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
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

  void _shareLeague() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ссылка на лигу скопирована')));
  }

  String _formatMatchDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatMatchTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMatchStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return 'Предстоящий';
      case MatchStatus.live:
        return 'В прямом эфире';
      case MatchStatus.finished:
        return 'Завершен';
    }
  }

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return Colors.blue;
      case MatchStatus.live:
        return Colors.red;
      case MatchStatus.finished:
        return Colors.green;
    }
  }
}
