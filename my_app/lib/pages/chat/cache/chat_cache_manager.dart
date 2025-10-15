import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatCacheManager {
  static const String _messagesPrefix = 'chat_messages_';
  static const String _roomsPrefix = 'chat_rooms_';
  static const String _lastUpdatePrefix = 'last_update_';
  static const Duration _cacheDuration = Duration(hours: 1);

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // === СООБЩЕНИЯ ===

  // Сохранение сообщений комнаты
  Future<void> saveMessages(String roomId, List<ChatMessage> messages) async {
    try {
      final prefs = await _prefs;
      final key = '$_messagesPrefix$roomId';
      final jsonMessages = messages.map((msg) => msg.toJson()).toList();
      await prefs.setString(key, jsonEncode({
        'messages': jsonMessages,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
    } catch (e) {
      debugPrint('ChatCacheManager.saveMessages error: $e');
    }
  }

  // Получение сообщений комнаты
  Future<List<ChatMessage>?> getMessages(String roomId) async {
    try {
      final prefs = await _prefs;
      final key = '$_messagesPrefix$roomId';
      final cachedData = prefs.getString(key);

      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final timestamp = DateTime.fromMillisecondsSinceEpoch(jsonData['timestamp']);

        // Проверяем актуальность кэша
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          final messages = (jsonData['messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();
          return messages;
        } else {
          // Удаляем просроченный кэш
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('ChatCacheManager.getMessages error: $e');
    }
    return null;
  }

  // Сохранение отдельного сообщения
  Future<void> saveMessage(String roomId, ChatMessage message) async {
    try {
      final existingMessages = await getMessages(roomId) ?? [];

      // Удаляем старое сообщение с таким же ID (если есть)
      existingMessages.removeWhere((m) => m.id == message.id);

      // Добавляем новое сообщение
      existingMessages.add(message);

      // Сохраняем обновленный список
      await saveMessages(roomId, existingMessages);
    } catch (e) {
      debugPrint('ChatCacheManager.saveMessage error: $e');
    }
  }

  // === КОМНАТЫ ===

  // Сохранение комнаты
  Future<void> saveRoom(ChatRoom room) async {
    try {
      final prefs = await _prefs;
      final key = '$_roomsPrefix${room.id}';
      await prefs.setString(key, jsonEncode({
        'room': room.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
    } catch (e) {
      debugPrint('ChatCacheManager.saveRoom error: $e');
    }
  }

  // Получение комнаты
  Future<ChatRoom?> getRoom(String roomId) async {
    try {
      final prefs = await _prefs;
      final key = '$_roomsPrefix$roomId';
      final cachedData = prefs.getString(key);

      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final timestamp = DateTime.fromMillisecondsSinceEpoch(jsonData['timestamp']);

        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          return ChatRoom.fromJson(jsonData['room']);
        } else {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('ChatCacheManager.getRoom error: $e');
    }
    return null;
  }

  // Обновление последнего сообщения в комнате
  Future<void> updateRoomLastMessage(String roomId, ChatMessage message) async {
    try {
      final room = await getRoom(roomId);
      if (room != null) {
        final updatedRoom = room.copyWith(lastMessage: message);
        await saveRoom(updatedRoom);
      }
    } catch (e) {
      debugPrint('ChatCacheManager.updateRoomLastMessage error: $e');
    }
  }

  // === ОЧИСТКА КЭША ===

  // Очистка кэша комнаты
  Future<void> clearRoomCache(String roomId) async {
    try {
      final prefs = await _prefs;
      await prefs.remove('$_messagesPrefix$roomId');
      await prefs.remove('$_roomsPrefix$roomId');
      await prefs.remove('$_lastUpdatePrefix$roomId');
    } catch (e) {
      debugPrint('ChatCacheManager.clearRoomCache error: $e');
    }
  }

  // Очистка всего кэша
  Future<void> clearAllCache() async {
    try {
      final prefs = await _prefs;
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_messagesPrefix) ||
            key.startsWith(_roomsPrefix) ||
            key.startsWith(_lastUpdatePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('ChatCacheManager.clearAllCache error: $e');
    }
  }

  // Получение размера кэша
  Future<int> getCacheSize() async {
    try {
      final prefs = await _prefs;
      final keys = prefs.getKeys();
      int totalSize = 0;

      for (final key in keys) {
        if (key.startsWith(_messagesPrefix) || key.startsWith(_roomsPrefix)) {
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length * 2; // Примерный расчет в байтах
          }
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('ChatCacheManager.getCacheSize error: $e');
      return 0;
    }
  }
}