import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/pagination_response.dart';

class ChatApiService {
  final String baseUrl;
  final String authToken;
  final Duration timeout = const Duration(seconds: 30);

  ChatApiService({
    required this.baseUrl,
    required this.authToken,
  });

  // === HEADERS ===
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  // === ОСНОВНЫЕ МЕТОДЫ ===

  // Получение комнаты
  Future<ChatRoom> getRoom(String roomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: _headers,
    ).timeout(timeout);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ChatRoom.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load room: ${response.statusCode}');
    }
  }

  // Получение сообщений с пагинацией
  Future<PaginationResponse<ChatMessage>> getMessages({
    required String roomId,
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId/messages')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      }),
      headers: _headers,
    ).timeout(timeout);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final messages = (jsonData['data']['messages'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList();

      return PaginationResponse(
        messages: messages,
        currentPage: jsonData['data']['currentPage'],
        totalPages: jsonData['data']['totalPages'],
        totalCount: jsonData['data']['totalCount'],
        hasMore: jsonData['data']['hasMore'],
      );
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  // Отправка сообщения
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String text,
    String? replyToId,
  }) async {
    final payload = {
      'text': text,
      if (replyToId != null) 'replyToId': replyToId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/rooms/$roomId/messages'),
      headers: _headers,
      body: jsonEncode(payload),
    ).timeout(timeout);

    if (response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return ChatMessage.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  // Реакции на сообщения
  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/$messageId/reactions'),
      headers: _headers,
      body: jsonEncode({'emoji': emoji}),
    ).timeout(timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to toggle reaction: ${response.statusCode}');
    }
  }

  // Закрепление сообщения
  Future<void> pinMessage({
    required String messageId,
    required bool pinned,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/messages/$messageId/pin'),
      headers: _headers,
      body: jsonEncode({'pinned': pinned}),
    ).timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to pin message: ${response.statusCode}');
    }
  }

  // Поиск сообщений
  Future<List<ChatMessage>> searchMessages({
    required String roomId,
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId/search')
          .replace(queryParameters: {'q': query}),
      headers: _headers,
    ).timeout(timeout);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return (jsonData['data'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList();
    } else {
      throw Exception('Failed to search messages: ${response.statusCode}');
    }
  }

  // Индикатор набора текста
  Future<void> sendTypingIndicator({
    required String roomId,
    required bool isTyping,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rooms/$roomId/typing'),
      headers: _headers,
      body: jsonEncode({'isTyping': isTyping}),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Failed to send typing indicator: ${response.statusCode}');
    }
  }

  // Удаление сообщения
  Future<void> deleteMessage(String messageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/messages/$messageId'),
      headers: _headers,
    ).timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message: ${response.statusCode}');
    }
  }

  // Редактирование сообщения
  Future<ChatMessage> editMessage({
    required String messageId,
    required String newText,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/messages/$messageId'),
      headers: _headers,
      body: jsonEncode({'text': newText}),
    ).timeout(timeout);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ChatMessage.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to edit message: ${response.statusCode}');
    }
  }
}