// lib/pages/predictions_league_page/models/prediction_league.dart
import 'package:flutter/material.dart';

import 'enums.dart';

class PredictionLeague {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int participants;
  final int predictions;
  final DateTime endDate;
  final String category;
  final String author;
  final String imageUrl;
  final AuthorLevel authorLevel;
  final bool isActive;
  final double prizePool;
  final int views;
  final String detailedDescription;
  final double progress; // Добавленное поле

  const PredictionLeague({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.participants,
    required this.predictions,
    required this.endDate,
    required this.category,
    required this.author,
    required this.imageUrl,
    required this.authorLevel,
    required this.isActive,
    required this.prizePool,
    required this.views,
    required this.detailedDescription,
    required this.progress, // Добавленное поле
  });

  // Время до окончания
  String get timeLeft {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м';
    } else {
      return 'Завершена';
    }
  }

  // Прогресс в процентах (вычисляемое свойство, если нужно)
  double get calculatedProgress {
    final totalDuration = endDate.difference(DateTime.now().subtract(const Duration(days: 30)));
    final passedDuration = DateTime.now().difference(endDate.subtract(totalDuration));
    final progress = passedDuration.inSeconds / totalDuration.inSeconds;
    return progress.clamp(0.0, 1.0);
  }

  // Форматирование призового фонда
  String get formattedPrizePool {
    if (prizePool >= 1000000) {
      return '\$${(prizePool / 1000000).toStringAsFixed(1)}M';
    } else if (prizePool >= 1000) {
      return '\$${(prizePool / 1000).toStringAsFixed(1)}K';
    }
    return '\$${prizePool.toInt()}';
  }

  // Метод для копирования с изменением прогресса
  PredictionLeague copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    int? participants,
    int? predictions,
    DateTime? endDate,
    String? category,
    String? author,
    String? imageUrl,
    AuthorLevel? authorLevel,
    bool? isActive,
    double? prizePool,
    int? views,
    String? detailedDescription,
    double? progress,
  }) {
    return PredictionLeague(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      participants: participants ?? this.participants,
      predictions: predictions ?? this.predictions,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      authorLevel: authorLevel ?? this.authorLevel,
      isActive: isActive ?? this.isActive,
      prizePool: prizePool ?? this.prizePool,
      views: views ?? this.views,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      progress: progress ?? this.progress,
    );
  }
}