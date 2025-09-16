import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/match_model.dart';

class LeagueDetailManagement {
  static List<Match> fixDuplicateMatchIds(List<Match> matches) {
    final uniqueIds = <int>{};
    final fixedMatches = <Match>[];
    int newId = 1000;

    for (var match in matches) {
      if (uniqueIds.contains(match.id)) {
        while (uniqueIds.contains(newId)) {
          newId++;
        }
        fixedMatches.add(match.copyWith(id: newId));
        uniqueIds.add(newId);
        newId++;
      } else {
        fixedMatches.add(match.copyWith());
        uniqueIds.add(match.id);
      }
    }

    return fixedMatches;
  }

  static int generateUniqueMatchId(List<Match> matches) {
    final existingIds = matches.map((m) => m.id).toSet();
    int newId = DateTime.now().millisecondsSinceEpoch;

    while (existingIds.contains(newId)) {
      newId++;
    }

    return newId;
  }

  static void showAddMatchDialog({
    required BuildContext context,
    required String leagueTitle,
    required Function(Match) onMatchAdded,
    required List<Match> existingMatches,
  }) {
    final TextEditingController homeController = TextEditingController();
    final TextEditingController awayController = TextEditingController();
    final TextEditingController leagueController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    String? validationError;

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
                        prefixIcon: Icon(Icons.home),
                      ),
                      onChanged: (_) => setState(() => validationError = null),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: awayController,
                      decoration: const InputDecoration(
                        labelText: 'Гости',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.airline_seat_individual_suite),
                      ),
                      onChanged: (_) => setState(() => validationError = null),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: leagueController,
                      decoration: const InputDecoration(
                        labelText: 'Турнир',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emoji_events),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
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
                              DateFormat('dd.MM.yyyy').format(selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
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
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (validationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          validationError!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
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
                    final validation = _validateMatchInput(
                      homeTeam: homeController.text,
                      awayTeam: awayController.text,
                      existingMatches: existingMatches,
                    );

                    if (!validation.isValid) {
                      setState(() => validationError = validation.message);
                      return;
                    }

                    if (homeController.text.isNotEmpty &&
                        awayController.text.isNotEmpty) {
                      final matchDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final newMatch = Match(
                        id: generateUniqueMatchId(existingMatches),
                        teamHome: homeController.text,
                        teamAway: awayController.text,
                        league: leagueController.text.isNotEmpty
                            ? leagueController.text
                            : leagueTitle,
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

                      onMatchAdded(newMatch);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Матч добавлен!'),
                          backgroundColor: Colors.green[700],
                        ),
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

  static void showEditMatchDialog({
    required BuildContext context,
    required Match match,
    required Function(Match) onMatchUpdated,
    required List<Match> existingMatches,
  }) {
    final homeController = TextEditingController(text: match.teamHome);
    final awayController = TextEditingController(text: match.teamAway);
    final leagueController = TextEditingController(text: match.league);
    DateTime selectedDate = match.date;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(match.date);
    String? validationError;

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
                        prefixIcon: Icon(Icons.home),
                      ),
                      onChanged: (_) => setState(() => validationError = null),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: awayController,
                      decoration: const InputDecoration(
                        labelText: 'Гости',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.airline_seat_individual_suite),
                      ),
                      onChanged: (_) => setState(() => validationError = null),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: leagueController,
                      decoration: const InputDecoration(
                        labelText: 'Турнир',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emoji_events),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
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
                              DateFormat('dd.MM.yyyy').format(selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
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
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (validationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          validationError!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
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
                    final validation = _validateMatchInput(
                      homeTeam: homeController.text,
                      awayTeam: awayController.text,
                      existingMatches: existingMatches,
                      originalMatch: match,
                    );

                    if (!validation.isValid) {
                      setState(() => validationError = validation.message);
                      return;
                    }

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

                      onMatchUpdated(updatedMatch);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Матч обновлен!'),
                          backgroundColor: Colors.green[700],
                        ),
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

  static void showDeleteMatchDialog({
    required BuildContext context,
    required int matchId,
    required Function(int) onMatchDeleted,
  }) {
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
              onMatchDeleted(matchId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Матч удален!'),
                  backgroundColor: Colors.red[700],
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  static void showPredictionDialog({
    required BuildContext context,
    required Match match,
    required Function(String) onPredictionSaved,
  }) {
    final homeController = TextEditingController();
    final awayController = TextEditingController();
    String? validationError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        width: 80,
                        child: TextField(
                          controller: homeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: match.teamHome,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onChanged: (_) => setState(() => validationError = null),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: awayController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: match.teamAway,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onChanged: (_) => setState(() => validationError = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (validationError != null)
                    Text(
                      validationError!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Система начисления очков:\n'
                        '• Точный счет: 4 очка\n'
                        '• Правильный исход: 2 очка\n'
                        '• Угаданная ничья: 1 очко\n'
                        '• Неугаданный исход: 0 очков',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
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
                    final prediction = '${homeController.text}:${awayController.text}';

                    if (!Match.isValidPredictionFormat(prediction)) {
                      setState(() => validationError = 'Введите корректный счет (например: 2:1)');
                      return;
                    }

                    onPredictionSaved(prediction);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Прогноз сохранен!'),
                        backgroundColor: Colors.green[700],
                      ),
                    );
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

  static void showResultInputDialog({
    required BuildContext context,
    required Match match,
    required Function(String) onResultSaved,
  }) {
    final homeController = TextEditingController();
    final awayController = TextEditingController();
    String? validationError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        width: 80,
                        child: TextField(
                          controller: homeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: match.teamHome,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onChanged: (_) => setState(() => validationError = null),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: awayController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: match.teamAway,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onChanged: (_) => setState(() => validationError = null),
                        ),
                      ),
                    ],
                  ),
                  if (validationError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        validationError!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                    final result = '${homeController.text}:${awayController.text}';

                    if (!Match.isValidScoreFormat(result)) {
                      setState(() => validationError = 'Введите корректный счет (например: 2:1)');
                      return;
                    }

                    onResultSaved(result);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Результат сохранен!'),
                        backgroundColor: Colors.green[700],
                      ),
                    );
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

  static void showCalculateResultsDialog({
    required BuildContext context,
    required Function() onCalculate,
  }) {
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
              onCalculate();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Рассчитать'),
          ),
        ],
      ),
    );
  }

  static void showFinalResultsDialog({
    required BuildContext context,
    required List<Match> matches,
  }) {
    final userPredictions = matches
        .where((match) => match.userPrediction.isNotEmpty && match.isCompleted)
        .toList();

    final totalPoints = userPredictions.fold(0, (sum, match) => sum + match.points);

    // Группируем матчи по количеству набранных очков
    final matchesByPoints = {
      4: userPredictions.where((m) => m.points == 4).toList(),
      2: userPredictions.where((m) => m.points == 2).toList(),
      1: userPredictions.where((m) => m.points == 1).toList(),
      0: userPredictions.where((m) => m.points == 0).toList(),
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Итоговые результаты',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Общее количество очков: $totalPoints',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (matchesByPoints[4]!.isNotEmpty)
                          _buildPointsSection('🎯 Точные прогнозы (4 очка)', matchesByPoints[4]!),

                        if (matchesByPoints[2]!.isNotEmpty)
                          _buildPointsSection('✅ Правильный исход (2 очка)', matchesByPoints[2]!),

                        if (matchesByPoints[1]!.isNotEmpty)
                          _buildPointsSection('🤝 Угаданная ничья (1 очко)', matchesByPoints[1]!),

                        if (matchesByPoints[0]!.isNotEmpty)
                          _buildPointsSection('❌ Неудачные прогнозы (0 очков)', matchesByPoints[0]!),

                        const SizedBox(height: 8),
                        Text(
                          'Всего матчей с прогнозами: ${userPredictions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildPointsSection(String title, List<Match> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${matches.length})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _getPointsColor(matches.first.points),
          ),
        ),
        const SizedBox(height: 8),
        ...matches.map(
              (match) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              title: Text(
                '${match.teamHome} - ${match.teamAway}',
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                'Прогноз: ${match.userPrediction} • Результат: ${match.actualScore}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                '+${match.points}',
                style: TextStyle(
                  color: _getPointsColor(match.points),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  static Color _getPointsColor(int points) {
    switch (points) {
      case 4: return Colors.green;
      case 2: return Colors.blue;
      case 1: return Colors.orange;
      case 0: return Colors.red;
      default: return Colors.grey;
    }
  }

  // Валидация ввода матча
  static _ValidationResult _validateMatchInput({
    required String homeTeam,
    required String awayTeam,
    required List<Match> existingMatches,
    Match? originalMatch,
  }) {
    if (homeTeam.isEmpty || awayTeam.isEmpty) {
      return _ValidationResult(
        isValid: false,
        message: 'Названия команд не могут быть пустыми',
      );
    }

    if (homeTeam == awayTeam) {
      return _ValidationResult(
        isValid: false,
        message: 'Команды не могут совпадать',
      );
    }

    // Проверка на дубликат матча (исключая редактируемый матч)
    final potentialDuplicate = existingMatches.any((match) =>
    match.teamHome == homeTeam &&
        match.teamAway == awayTeam &&
        match.id != (originalMatch?.id ?? -1));

    if (potentialDuplicate) {
      return _ValidationResult(
        isValid: false,
        message: 'Такой матч уже существует',
      );
    }

    return _ValidationResult(isValid: true);
  }
}

// Вспомогательный класс для результатов валидации
class _ValidationResult {
  final bool isValid;
  final String? message;

  _ValidationResult({required this.isValid, this.message});
}

// Класс для отображения матчей в виде сетки 2x2
class MatchGridView extends StatelessWidget {
  final List<Match> matches;
  final Function(Match) onMatchTap;
  final Function(Match) onEditMatch;
  final Function(int) onDeleteMatch;
  final Function(Match) onPredictMatch;
  final Function(Match) onEnterResult;
  final bool isAdmin;

  const MatchGridView({
    super.key,
    required this.matches,
    required this.onMatchTap,
    required this.onEditMatch,
    required this.onDeleteMatch,
    required this.onPredictMatch,
    required this.onEnterResult,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _buildMatchCard(match, context);
      },
    );
  }

  Widget _buildMatchCard(Match match, BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Заголовок с лигой
            Text(
              match.league,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Команды
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    match.teamHome,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    match.teamAway,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Дата и время
            Text(
              DateFormat('dd.MM.yyyy HH:mm').format(match.date),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            // Статус
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(match.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(match.status),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return Colors.blue;
      case MatchStatus.completed:
        return Colors.green;
      case MatchStatus.live:
        return Colors.red;
      case MatchStatus.finished:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _getStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return 'Предстоящий';
      case MatchStatus.completed:
        return 'Завершен';
      case MatchStatus.live:
        return 'В прямом эфире';
      case MatchStatus.finished:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}