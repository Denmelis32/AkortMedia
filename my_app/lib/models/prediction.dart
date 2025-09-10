class Prediction {
  final String id;
  final String userId;
  final String userName;
  final String matchId;
  final String match;
  final String prediction;
  final DateTime timestamp;
  final int points;
  final bool isCorrect;
  final String userAvatar;
  final String league;
  final String matchTime;
  final DateTime matchDate;

  Prediction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.matchId,
    required this.match,
    required this.prediction,
    required this.timestamp,
    this.points = 0,
    this.isCorrect = false,
    this.userAvatar = '',
    required this.league,
    required this.matchTime,
    required this.matchDate,
  });
}