import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5001/api';

  static Future<List<dynamic>> getNews() async {
    final response = await http.get(Uri.parse('$baseUrl/news'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load news');
  }

  static Future<dynamic> createNews(Map<String, dynamic> newsData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/news'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newsData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create news');
  }

  static Future<void> likeNews(String newsId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/news/$newsId/like'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to like news');
    }
  }

  static Future<void> addComment(String newsId, Map<String, dynamic> comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/news/$newsId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(comment),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add comment');
    }
  }
}