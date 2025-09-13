import 'package:flutter/material.dart';
import 'discussion_topic.dart';
import 'channel.dart';

class RoomCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<DiscussionTopic> topics;
  final List<Channel> channels;

  const RoomCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.topics,
    this.channels = const [],
  });

  RoomCategory copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    List<DiscussionTopic>? topics,
    List<Channel>? channels,
  }) {
    return RoomCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      topics: topics ?? this.topics,
      channels: channels ?? this.channels,
    );
  }
}