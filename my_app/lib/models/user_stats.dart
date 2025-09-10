class UserStats {
  final String userId;
  final String userName;
  final String userAvatar;
  int points;
  int matchesPlayed;
  int wins;
  int draws;
  int losses;
  int correctPredictions;

  UserStats({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.points = 0,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.correctPredictions = 0,
  });
}