class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final DateTime date;
  final String time;
  String? result;
  bool isFinished;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.date,
    required this.time,
    this.result,
    this.isFinished = false,
  });

  String get name => '$homeTeam - $awayTeam';
}