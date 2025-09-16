// models/league_model.dart
import 'package:flutter/material.dart';
import 'match_model.dart';

class League {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final int participants;
  final List<Match> matches;
  final bool isJoined;
  final int colorValue;
  final String categoryId;
  final String creatorId;
  final bool isPublic;

  League({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.matches,
    required this.isJoined,
    required this.colorValue,
    required this.categoryId,
    required this.creatorId,
    this.isPublic = true,
  });

  Color get cardColor => Color(colorValue);

  League copyWithMatches(List<Match> newMatches) {
    return League(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      participants: participants,
      matches: newMatches.map((match) => match.copyWith()).toList(), // Глубокая копия каждого матча
      isJoined: isJoined,
      colorValue: colorValue,
      categoryId: categoryId,
      creatorId: creatorId,
      isPublic: isPublic,
    );
  }
}