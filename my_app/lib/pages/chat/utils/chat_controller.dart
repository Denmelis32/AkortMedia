// chat_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/chat_service.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/enums.dart';

class ChatController {
  final ChatService _chatService = ChatService();
  final ValueNotifier<ChatSession> _sessionNotifier;
  final Map<String, Color> _userColors = {};

  ChatController({required ChatSession initialSession})
      : _sessionNotifier = ValueNotifier(initialSession);

  ValueListenable<ChatSession> get sessionNotifier => _sessionNotifier;
  ChatSession get currentSession => _sessionNotifier.value;

  // Отправка текстового сообщения
  Future<void> sendTextMessage({
    required String text,
    required String userName,
    required String userAvatar,
    ChatMessage? replyTo,
    String? tempId,
  }) async {
    final message = ChatMessage(
      id: tempId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: currentSession.roomId,
      text: text.trim(),
      sender: userName,
      time: DateTime.now(),
      isMe: true,
      replyTo: replyTo,
      userColor: _getUserColor(userName),
      userAvatar: userAvatar,
      status: MessageStatus.sending,
    );

    // Оптимистичное обновление
    _addMessageOptimistically(message);

    try {
      final sentMessage = await _chatService.sendMessage(message);
      _updateMessageStatus(tempId ?? message.id, MessageStatus.sent, sentMessage);

      // Запуск AI ответа
      _triggerAIResponse(text, currentSession.roomId);
    } catch (e) {
      _updateMessageStatus(tempId ?? message.id, MessageStatus.error);
    }
  }

  void _addMessageOptimistically(ChatMessage message) {
    final newMessages = List<ChatMessage>.from(currentSession.messages)..add(message);
    _updateSession(newMessages);
  }

  void _updateMessageStatus(String messageId, MessageStatus status, [ChatMessage? updatedMessage]) {
    final newMessages = currentSession.messages.map((msg) {
      if (msg.id == messageId) {
        return updatedMessage ?? msg.copyWith(status: status);
      }
      return msg;
    }).toList();

    _updateSession(newMessages);
  }

  void _updateSession(List<ChatMessage> newMessages) {
    _sessionNotifier.value = currentSession.copyWith(
      messages: newMessages,
      lastUpdate: DateTime.now(),
    );
  }

  Future<void> _triggerAIResponse(String userMessage, String roomId) async {
    try {
      final response = await _chatService.getAIResponse(userMessage, roomId);

      final aiMessage = ChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        text: response,
        sender: 'AI Assistant',
        time: DateTime.now(),
        isMe: false,
        userColor: _getUserColor('AI Assistant'),
        userAvatar: 'https://i.pravatar.cc/150?img=45',
        messageType: MessageType.system,
        status: MessageStatus.sent,
      );

      _addMessageOptimistically(aiMessage);
    } catch (e) {
      print('AI response error: $e');
    }
  }

  Color _getUserColor(String userName) {
    return _userColors.putIfAbsent(
      userName,
          () => Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
    );
  }

  // Загрузка сообщений
  Future<void> loadInitialMessages() async {
    try {
      final messages = await _chatService.loadMessages(
        currentSession.roomId,
        limit: 50,
        offset: 0,
      );

      _updateSession(messages);
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> loadMoreMessages() async {
    if (!canLoadMore) return;

    try {
      final newMessages = await _chatService.loadMessages(
        currentSession.roomId,
        limit: 20,
        offset: currentSession.messages.length,
      );

      final allMessages = [...newMessages, ...currentSession.messages];
      _updateSession(allMessages);
    } catch (e) {
      print('Error loading more messages: $e');
    }
  }

  bool get canLoadMore => currentSession.messages.length >= 20;

  // Реакции
  Future<void> toggleReaction(String messageId, String reaction, String userName) async {
    try {
      final updatedReactions = await _chatService.addReaction(
        messageId,
        currentSession.roomId,
        reaction,
        userName,
      );

      if (updatedReactions != null) {
        final newMessages = currentSession.messages.map((msg) {
          if (msg.id == messageId) {
            return msg.copyWith(reactions: updatedReactions);
          }
          return msg;
        }).toList();

        _updateSession(newMessages);
      }
    } catch (e) {
      print('Error toggling reaction: $e');
    }
  }

  // Перевод
  Future<String?> translateMessage(String text) async {
    try {
      return await _chatService.translateMessage(text, 'en');
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }

  void dispose() {
    _sessionNotifier.dispose();
  }
}