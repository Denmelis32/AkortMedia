import 'package:flutter/material.dart';

class NewsSearchDelegate extends SearchDelegate {
  final List<dynamic> news;
  final String searchHint;

  NewsSearchDelegate({required this.news, required this.searchHint});

  @override
  String get searchFieldLabel => searchHint;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = news.where((item) {
      final newsItem = item as Map<String, dynamic>;
      final title = newsItem['title']?.toString().toLowerCase() ?? '';
      final description = newsItem['description']?.toString().toLowerCase() ?? '';
      final hashtags = (newsItem['hashtags'] is List
          ? (newsItem['hashtags'] as List).join(' ').toLowerCase()
          : '');

      return title.contains(query.toLowerCase()) ||
          description.contains(query.toLowerCase()) ||
          hashtags.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final newsItem = results[index] as Map<String, dynamic>;
        return ListTile(
          title: Text(newsItem['title'] ?? ''),
          subtitle: Text(newsItem['description'] ?? ''),
          onTap: () {
            close(context, newsItem['title']);
          },
        );
      },
    );
  }
}