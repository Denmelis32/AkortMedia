enum MatchStatus { upcoming, live, finished }

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
  final int points; // Добавляем поле для очков

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
    this.points = 0, // По умолчанию 0 очков
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

  // Метод для расчета очков за прогноз
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

      // Точное попадание - 3 очка
      if (predHome == actualHome && predAway == actualAway) {
        return 3;
      }

      // Правильный исход (победа/ничья/поражение) - 1 очко
      final predOutcome = _getMatchOutcome(predHome, predAway);
      final actualOutcome = _getMatchOutcome(actualHome, actualAway);

      if (predOutcome == actualOutcome) {
        return 1;
      }

      return 0;
    } catch (e) {
      print('Ошибка расчета очков: $e');
      return 0;
    }
  }

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

  // Проверка валидности формата результата
  static bool isValidScoreFormat(String score) {
    return isValidPredictionFormat(score);
  }


}
