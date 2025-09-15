import 'package:flutter/material.dart';
import '../models_room/channel.dart';
import '../models_room/discussion_topic.dart';
import '../models_room/user_permissions.dart';
import 'topic_card.dart';

class ChannelTopicsList extends StatelessWidget {
  final List<DiscussionTopic> topics;
  final String searchQuery;
  final VoidCallback onCreateTopic;
  final Channel channel;
  final UserPermissions userPermissions;

  const ChannelTopicsList({
    super.key,
    required this.topics,
    required this.searchQuery,
    required this.onCreateTopic,
    required this.channel,
    required this.userPermissions,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTopics = searchQuery.isEmpty
        ? topics
        : topics.where((topic) =>
    topic.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        topic.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        topic.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))).toList();

    return filteredTopics.isEmpty && searchQuery.isNotEmpty
        ? _buildEmptySearch()
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTopics.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }
        final topic = filteredTopics[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TopicCard(
            topic: topic,
            onTap: () {
              // Навигация к обсуждению
            },
            textColor: Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Обсуждения в канале',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Ничего не найдено',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить поисковый запрос',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}