class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchTime;
  final String? homeScore;
  final String? awayScore;
  final String status; // scheduled, live, finished

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchTime,
    this.homeScore,
    this.awayScore,
    this.status = 'scheduled',
  });

  String get matchTitle => '$homeTeam - $awayTeam';
  String get formattedTime => '${matchTime.hour}:${matchTime.minute.toString().padLeft(2, '0')}';
  String get formattedDate => '${matchTime.day}.${matchTime.month}.${matchTime.year}';
}