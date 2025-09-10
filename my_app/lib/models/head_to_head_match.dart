class HeadToHeadMatch {
  final String id;
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final List<String> matchIds;
  final DateTime createdDate;
  bool isCompleted;
  int user1Points;
  int user2Points;
  String? winnerId;

  HeadToHeadMatch({
    required this.id,
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
    required this.matchIds,
    required this.createdDate,
    this.isCompleted = false,
    this.user1Points = 0,
    this.user2Points = 0,
    this.winnerId,
  });
}