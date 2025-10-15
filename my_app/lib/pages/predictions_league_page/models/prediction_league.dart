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
  final double progress;
  final double minBet; // Добавлено
  final double maxBet; // Добавлено

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
    required this.progress,
    this.minBet = 10.0, // Значение по умолчанию
    this.maxBet = 1000.0, // Значение по умолчанию
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
    double? minBet, // Добавлено
    double? maxBet, // Добавлено
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
      minBet: minBet ?? this.minBet, // Добавлено
      maxBet: maxBet ?? this.maxBet, // Добавлено
    );
  }

  // Фабричный метод для создания из JSON
  factory PredictionLeague.fromJson(Map<String, dynamic> json) {
    return PredictionLeague(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🏆',
      participants: json['participants'] ?? 0,
      predictions: json['predictions'] ?? 0,
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toString()),
      category: json['category'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      authorLevel: AuthorLevel.values[json['authorLevel'] ?? 0],
      isActive: json['isActive'] ?? true,
      prizePool: (json['prizePool'] ?? 0).toDouble(),
      views: json['views'] ?? 0,
      detailedDescription: json['detailedDescription'] ?? '',
      progress: (json['progress'] ?? 0.5).toDouble(),
      minBet: (json['minBet'] ?? 10.0).toDouble(), // Добавлено
      maxBet: (json['maxBet'] ?? 1000.0).toDouble(), // Добавлено
    );
  }

  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'participants': participants,
      'predictions': predictions,
      'endDate': endDate.toIso8601String(),
      'category': category,
      'author': author,
      'imageUrl': imageUrl,
      'authorLevel': authorLevel.index,
      'isActive': isActive,
      'prizePool': prizePool,
      'views': views,
      'detailedDescription': detailedDescription,
      'progress': progress,
      'minBet': minBet, // Добавлено
      'maxBet': maxBet, // Добавлено
    };
  }
}