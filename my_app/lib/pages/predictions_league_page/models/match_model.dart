enum MatchStatus { upcoming, live, completed, finished }

class Match {
  final int id;
  final String teamHome;
  final String teamAway;
  final String league;
  final DateTime date;
  final String imageHome;
  final String imageAway;
  final String userPrediction;
  final String actualScore;
  final MatchStatus status;
  final int points;

  Match({
    required this.id,
    required this.teamHome,
    required this.teamAway,
    required this.league,
    required this.date,
    required this.imageHome,
    required this.imageAway,
    required this.userPrediction,
    required this.actualScore,
    required this.status,
    this.points = 0,
  });

  Match copyWith({
    int? id,
    String? teamHome,
    String? teamAway,
    String? league,
    DateTime? date,
    String? imageHome,
    String? imageAway,
    String? userPrediction,
    String? actualScore,
    MatchStatus? status,
    int? points,
  }) {
    return Match(
      id: id ?? this.id,
      teamHome: teamHome ?? this.teamHome,
      teamAway: teamAway ?? this.teamAway,
      league: league ?? this.league,
      date: date ?? this.date,
      imageHome: imageHome ?? this.imageHome,
      imageAway: imageAway ?? this.imageAway,
      userPrediction: userPrediction ?? this.userPrediction,
      actualScore: actualScore ?? this.actualScore,
      status: status ?? this.status,
      points: points ?? this.points,
    );
  }

  // Новая система подсчета очков
  static int calculatePoints(String prediction, String actualScore) {
    if (prediction.isEmpty || actualScore.isEmpty) return 0;

    // Проверяем формат прогноза и результата
    if (!prediction.contains(':') || !actualScore.contains(':')) return 0;

    try {
      final predParts = prediction.split(':');
      final actualParts = actualScore.split(':');

      if (predParts.length != 2 || actualParts.length != 2) return 0;

      final predHome = int.parse(predParts[0].trim());
      final predAway = int.parse(predParts[1].trim());
      final actualHome = int.parse(actualParts[0].trim());
      final actualAway = int.parse(actualParts[1].trim());

      // 1. Точное попадание счета и победителя - 4 очка
      if (predHome == actualHome && predAway == actualAway) {
        return 4;
      }

      // 2. Угадан победитель, но не счет - 2 очка
      final predOutcome = _getMatchOutcome(predHome, predAway);
      final actualOutcome = _getMatchOutcome(actualHome, actualAway);

      if (predOutcome == actualOutcome) {
        return 2;
      }

      // 3. Угадана только ничья (но не точный счет) - 1 очко
      if (predOutcome == 'draw' && actualOutcome == 'draw') {
        return 1;
      }

      // 4. Не угадал победителя и счет - 0 очков
      return 0;

    } catch (e) {
      print('Ошибка расчета очков: $e');
      return 0;
    }
  }

  // Вспомогательный метод для определения исхода матча
  static String _getMatchOutcome(int home, int away) {
    if (home > away) return 'home_win';
    if (home < away) return 'away_win';
    return 'draw';
  }

  static bool isValidPredictionFormat(String prediction) {
    if (prediction.isEmpty || !prediction.contains(':')) return false;

    final parts = prediction.split(':');
    if (parts.length != 2) return false;

    try {
      final home = int.parse(parts[0].trim());
      final away = int.parse(parts[1].trim());
      return home >= 0 && away >= 0;
    } catch (e) {
      return false;
    }
  }

  static bool isValidScoreFormat(String score) {
    return isValidPredictionFormat(score);
  }

  // Дополнительный метод для получения текстового описания исхода
  String get matchOutcome {
    if (actualScore.isEmpty) return 'Матч не завершен';

    try {
      final parts = actualScore.split(':');
      final home = int.parse(parts[0].trim());
      final away = int.parse(parts[1].trim());

      if (home > away) return 'Победа $teamHome';
      if (away > home) return 'Победа $teamAway';
      return 'Ничья';
    } catch (e) {
      return 'Неверный формат счета';
    }
  }

  // Метод для проверки, завершен ли матч
  bool get isCompleted => actualScore.isNotEmpty &&
      (status == MatchStatus.completed || status == MatchStatus.finished);

  // Метод для получения разницы голов
  String get goalDifference {
    if (actualScore.isEmpty) return '-';

    try {
      final parts = actualScore.split(':');
      final home = int.parse(parts[0].trim());
      final away = int.parse(parts[1].trim());
      return '${home - away}';
    } catch (e) {
      return '-';
    }
  }
}