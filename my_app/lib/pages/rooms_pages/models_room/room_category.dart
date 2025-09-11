import 'package:flutter/material.dart';
import 'discussion_topic.dart';

class RoomCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<DiscussionTopic> topics;

  RoomCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.topics = const [],
  });
}