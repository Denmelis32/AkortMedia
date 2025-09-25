import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final DateTime date;
  final Color color;
  final String? category; // Добавлено поле категории

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.color,
    this.category,
  });
}