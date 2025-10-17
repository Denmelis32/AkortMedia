import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatCacheManager {
  static const String _messagesPrefix = 'chat_messages_';
  static const String _roomsPrefix = 'chat_rooms_';
  static const String _lastUpdatePrefix = 'last_update_';
  static const String _userPrefsPrefix = 'user_prefs_';
  static const Duration _cacheDuration = Duration(hours: 2);
  static const Duration _roomCacheDuration = Duration(days: 1);
  static const int _maxMessagesPerRoom = 1000;

  // Сигналы для уведомлений об изменениях
  final ValueNotifier<int> _cacheUpdated = ValueNotifier(0);
  ValueNotifier<int> get cacheUpdated => _cacheUpdated;

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // === СООБЩЕНИЯ ===

  // Сохранение сообщений комнаты с ограничением по количеству
  Future<void> saveMessages(String roomId, List<ChatMessage> messages) async {
    try {
      final prefs = await _prefs;
      final key = '$_messagesPrefix$roomId';

      // Ограничиваем количество сохраняемых сообщений
      final messagesToSave = messages.length > _maxMessagesPerRoom
          ? messages.sublist(0, _maxMessagesPerRoom)
          : messages;

      final jsonMessages = messagesToSave.map((msg) => msg.toJson()).toList();

      await prefs.setString(key, jsonEncode({
        'messages': jsonMessages,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'count': messagesToSave.length,
      }));

      _notifyCacheUpdate();

      if (messages.length > _maxMessagesPerRoom) {
        debugPrint('ChatCacheManager: Сохранено $_maxMessagesPerRoom из ${messages.length} сообщений для комнаты $roomId');
      }
    } catch (e) {
      debugPrint('ChatCacheManager.saveMessages error: $e');
    }
  }

  // Получение сообщений комнаты с фильтрацией
  Future<List<ChatMessage>> getMessages(
      String roomId, {
        bool ignoreExpired = false,
        int? limit,
      }) async {
    try {
      final prefs = await _prefs;
      final key = '$_messagesPrefix$roomId';
      final cachedData = prefs.getString(key);

      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final timestamp = DateTime.fromMillisecondsSinceEpoch(jsonData['timestamp']);

        // Проверяем актуальность кэша
        if (ignoreExpired || DateTime.now().difference(timestamp) < _cacheDuration) {
          final messages = (jsonData['messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();

          // Применяем лимит если указан
          return limit != null && messages.length > limit
              ? messages.sublist(0, limit)
              : messages;
        } else {
          // Удаляем просроченный кэш
          await prefs.remove(key);
          debugPrint('ChatCacheManager: Кэш сообщений для комнаты $roomId устарел и удален');
        }
      }
    } catch (e) {
      debugPrint('ChatCacheManager.getMessages error: $e');
    }
    return [];
  }

  // Сохранение отдельного сообщения
  Future<void> saveMessage(String roomId, ChatMessage message) async {
    try {
      final existingMessages = await getMessages(roomId, ignoreExpired: true);

      // Удаляем старое сообщение с таким же ID (если есть)
      existingMessages.removeWhere((m) => m.id == message.id);

      // Добавляем новое сообщение в начало
      existingMessages.insert(0, message);

      // Сохраняем обновленный список
      await saveMessages(roomId, existingMessages);

      debugPrint('ChatCacheManager: Сохранено сообщение ${message.id} для комнаты $roomId');
    } catch (e) {
      debugPrint('ChatCacheManager.saveMessage error: $e');
    }
  }

  // Удаление сообщения
  Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      final existingMessages = await getMessages(roomId, ignoreExpired: true);
      final initialCount = existingMessages.length;

      existingMessages.removeWhere((m) => m.id == messageId);

      if (existingMessages.length != initialCount) {
        await saveMessages(roomId, existingMessages);
        debugPrint('ChatCacheManager: Удалено сообщение $messageId из комнаты $roomId');
      }
    } catch (e) {
      debugPrint('ChatCacheManager.deleteMessage error: $e');
    }
  }

  // Получение последних N сообщений
  Future<List<ChatMessage>> getRecentMessages(String roomId, int count) async {
    final messages = await getMessages(roomId);
    return messages.length > count ? messages.sublist(0, count) : messages;
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

      _notifyCacheUpdate();
      debugPrint('ChatCacheManager: Сохранена комната ${room.id}');
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

        if (DateTime.now().difference(timestamp) < _roomCacheDuration) {
          return ChatRoom.fromJson(jsonData['room']);
        } else {
          await prefs.remove(key);
          debugPrint('ChatCacheManager: Кэш комнаты $roomId устарел и удален');
        }
      }
    } catch (e) {
      debugPrint('ChatCacheManager.getRoom error: $e');
    }
    return null;
  }

  // Получение всех кэшированных комнат
  Future<List<ChatRoom>> getAllRooms() async {
    try {
      final prefs = await _prefs;
      final keys = prefs.getKeys();
      final rooms = <ChatRoom>[];

      for (final key in keys) {
        if (key.startsWith(_roomsPrefix)) {
          final cachedData = prefs.getString(key);
          if (cachedData != null) {
            try {
              final jsonData = jsonDecode(cachedData);
              final timestamp = DateTime.fromMillisecondsSinceEpoch(jsonData['timestamp']);

              if (DateTime.now().difference(timestamp) < _roomCacheDuration) {
                final room = ChatRoom.fromJson(jsonData['room']);
                rooms.add(room);
              }
            } catch (e) {
              debugPrint('ChatCacheManager.getAllRooms: Ошибка парсинга комнаты $key: $e');
            }
          }
        }
      }

      return rooms;
    } catch (e) {
      debugPrint('ChatCacheManager.getAllRooms error: $e');
      return [];
    }
  }

  // Обновление последнего сообщения в комнате
  Future<void> updateRoomLastMessage(String roomId, ChatMessage message) async {
    try {
      final room = await getRoom(roomId);
      if (room != null) {
        final updatedRoom = room.copyWith(lastMessage: message);
        await saveRoom(updatedRoom);
        debugPrint('ChatCacheManager: Обновлено последнее сообщение для комнаты $roomId');
      }
    } catch (e) {
      debugPrint('ChatCacheManager.updateRoomLastMessage error: $e');
    }
  }

  // === ПОЛЬЗОВАТЕЛЬСКИЕ НАСТРОЙКИ ===

  // Сохранение настройки уведомлений для комнаты
  Future<void> saveNotificationPreference(String roomId, bool enabled) async {
    try {
      final prefs = await _prefs;
      await prefs.setBool('$_userPrefsPrefix$roomId', enabled);
    } catch (e) {
      debugPrint('ChatCacheManager.saveNotificationPreference error: $e');
    }
  }

  // Получение настройки уведомлений для комнаты
  Future<bool> getNotificationPreference(String roomId) async {
    try {
      final prefs = await _prefs;
      return prefs.getBool('$_userPrefsPrefix$roomId') ?? true;
    } catch (e) {
      debugPrint('ChatCacheManager.getNotificationPreference error: $e');
      return true;
    }
  }

  // === СТАТИСТИКА И МОНИТОРИНГ ===

  // Получение статистики кэша
  Future<CacheStats> getCacheStats() async {
    try {
      final prefs = await _prefs;
      final keys = prefs.getKeys();

      int totalRooms = 0;
      int totalMessages = 0;
      int totalSize = 0;
      final roomStats = <String, int>{};

      for (final key in keys) {
        if (key.startsWith(_messagesPrefix)) {
          final roomId = key.replaceFirst(_messagesPrefix, '');
          final value = prefs.getString(key);
          if (value != null) {
            try {
              final jsonData = jsonDecode(value);
              final messageCount = (jsonData['messages'] as List).length;
              roomStats[roomId] = messageCount;
              totalMessages += messageCount;
              totalSize += value.length * 2;
            } catch (e) {
              debugPrint('ChatCacheManager.getCacheStats: Ошибка парсинга сообщений для $key');
            }
          }
        } else if (key.startsWith(_roomsPrefix)) {
          totalRooms++;
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length * 2;
          }
        }
      }

      return CacheStats(
        totalRooms: totalRooms,
        totalMessages: totalMessages,
        totalSize: totalSize,
        roomStats: roomStats,
      );
    } catch (e) {
      debugPrint('ChatCacheManager.getCacheStats error: $e');
      return CacheStats.empty();
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
      await prefs.remove('$_userPrefsPrefix$roomId');

      _notifyCacheUpdate();
      debugPrint('ChatCacheManager: Очищен кэш для комнаты $roomId');
    } catch (e) {
      debugPrint('ChatCacheManager.clearRoomCache error: $e');
    }
  }

  // Очистка устаревшего кэша
  Future<void> clearExpiredCache() async {
    try {
      final prefs = await _prefs;
      final keys = prefs.getKeys();
      int clearedCount = 0;

      for (final key in keys) {
        if (key.startsWith(_messagesPrefix) || key.startsWith(_roomsPrefix)) {
          final cachedData = prefs.getString(key);
          if (cachedData != null) {
            try {
              final jsonData = jsonDecode(cachedData);
              final timestamp = DateTime.fromMillisecondsSinceEpoch(jsonData['timestamp']);
              final duration = key.startsWith(_messagesPrefix)
                  ? _cacheDuration
                  : _roomCacheDuration;

              if (DateTime.now().difference(timestamp) > duration) {
                await prefs.remove(key);
                clearedCount++;
              }
            } catch (e) {
              // Если не удалось распарсить, удаляем поврежденный кэш
              await prefs.remove(key);
              clearedCount++;
            }
          }
        }
      }

      if (clearedCount > 0) {
        _notifyCacheUpdate();
        debugPrint('ChatCacheManager: Очищено $clearedCount устаревших записей кэша');
      }
    } catch (e) {
      debugPrint('ChatCacheManager.clearExpiredCache error: $e');
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
            key.startsWith(_lastUpdatePrefix) ||
            key.startsWith(_userPrefsPrefix)) {
          await prefs.remove(key);
        }
      }

      _notifyCacheUpdate();
      debugPrint('ChatCacheManager: Весь кэш очищен');
    } catch (e) {
      debugPrint('ChatCacheManager.clearAllCache error: $e');
    }
  }

  // Уведомление об обновлении кэша
  void _notifyCacheUpdate() {
    _cacheUpdated.value = DateTime.now().millisecondsSinceEpoch;
  }
}

// Модель для статистики кэша
class CacheStats {
  final int totalRooms;
  final int totalMessages;
  final int totalSize;
  final Map<String, int> roomStats;

  const CacheStats({
    required this.totalRooms,
    required this.totalMessages,
    required this.totalSize,
    required this.roomStats,
  });

  factory CacheStats.empty() => const CacheStats(
    totalRooms: 0,
    totalMessages: 0,
    totalSize: 0,
    roomStats: {},
  );

  String get formattedSize {
    if (totalSize < 1024) return '$totalSize Б';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} КБ';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  @override
  String toString() {
    return 'CacheStats(rooms: $totalRooms, messages: $totalMessages, size: $formattedSize)';
  }
}