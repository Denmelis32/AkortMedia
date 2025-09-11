class Standing {
  final String userId;
  final String userName;
  final int points;
  final int correctPredictions;
  final int totalPredictions;
  final int position;

  Standing({
    required this.userId,
    required this.userName,
    required this.points,
    required this.correctPredictions,
    required this.totalPredictions,
    required this.position,
  });

  double get accuracy => totalPredictions > 0
      ? (correctPredictions / totalPredictions) * 100
      : 0;
}