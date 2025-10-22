import 'package:flutter/cupertino.dart';

class ArticleCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final int articleCount;

  ArticleCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.articleCount = 0,
  });
}