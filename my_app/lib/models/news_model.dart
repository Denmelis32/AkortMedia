// models/models.dart
class News {
  final String id;
  final String title;
  final String description;
  final String image;
  final String time;
  int likes;
  final List<Comment> comments;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.time,
    required this.likes,
    required this.comments,
  });
}

class Comment {
  final String id;
  final String author;
  final String text;
  final String time;

  Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.time,
  });
}

class Match {
  final String id;
  final String teamHome;
  final String teamAway;
  final String league;
  final DateTime matchTime;
  final String? score;
  final String? userPrediction;

  Match({
    required this.id,
    required this.teamHome,
    required this.teamAway,
    required this.league,
    required this.matchTime,
    this.score,
    this.userPrediction,
  });
}
