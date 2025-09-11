class Prediction {
  final String id;
  final String matchId;
  final String userId;
  final int homeScore;
  final int awayScore;
  final DateTime predictedAt;
  final int points;

  Prediction({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.homeScore,
    required this.awayScore,
    required this.predictedAt,
    this.points = 0,
  });
}