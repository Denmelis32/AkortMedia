// providers/channel_state_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelStateProvider with ChangeNotifier {
  final Map<String, String?> _channelAvatars = {};
  final Map<String, String?> _channelCovers = {};
  final Map<String, List<String>> _channelHashtags = {};

  static const String _avatarsKey = 'channel_avatars';
  static const String _coversKey = 'channel_covers';
  static const String _hashtagsKey = 'channel_hashtags';

  ChannelStateProvider() {
    _loadFromStorage();
  }

  // Геттеры
  String? getAvatarForChannel(String channelId) => _channelAvatars[channelId];
  String? getCoverForChannel(String channelId) => _channelCovers[channelId];
  List<String> getHashtagsForChannel(String channelId) => _channelHashtags[channelId] ?? [];

  // Сеттеры
  void setAvatarForChannel(String channelId, String? avatarUrl) {
    _channelAvatars[channelId] = avatarUrl;
    notifyListeners();
    _saveToStorage();
  }

  void setCoverForChannel(String channelId, String? coverUrl) {
    _channelCovers[channelId] = coverUrl;
    notifyListeners();
    _saveToStorage();
  }

  void setHashtagsForChannel(String channelId, List<String> hashtags) {
    _channelHashtags[channelId] = List.from(hashtags);
    notifyListeners();
    _saveToStorage();
  }

  void addHashtagToChannel(String channelId, String hashtag) {
    if (!_channelHashtags.containsKey(channelId)) {
      _channelHashtags[channelId] = [];
    }
    final cleanHashtag = _cleanHashtag(hashtag);
    if (!_channelHashtags[channelId]!.contains(cleanHashtag)) {
      _channelHashtags[channelId]!.add(cleanHashtag);
      notifyListeners();
      _saveToStorage();
    }
  }

  void removeHashtagFromChannel(String channelId, String hashtag) {
    if (_channelHashtags.containsKey(channelId)) {
      _channelHashtags[channelId]!.remove(hashtag);
      notifyListeners();
      _saveToStorage();
    }
  }

  // Очистка
  void clearAllData() {
    _channelAvatars.clear();
    _channelCovers.clear();
    _channelHashtags.clear();
    notifyListeners();
    _clearStorage();
  }

  // Инициализация канала
  void initializeChannelIfNeeded(String channelId, {String? defaultAvatar, String? defaultCover, List<String>? defaultTags}) {
    if (!_channelAvatars.containsKey(channelId) && defaultAvatar != null) {
      _channelAvatars[channelId] = defaultAvatar;
    }
    if (!_channelCovers.containsKey(channelId) && defaultCover != null) {
      _channelCovers[channelId] = defaultCover;
    }
    if (!_channelHashtags.containsKey(channelId) && defaultTags != null) {
      _channelHashtags[channelId] = List.from(defaultTags);
    }
  }

  void clearChannelData(String channelId) {
    _channelAvatars.remove(channelId);
    _channelCovers.remove(channelId);
    _channelHashtags.remove(channelId);
    notifyListeners();
    _saveToStorage();
  }

  // Вспомогательные методы
  bool hasCustomAvatar(String channelId) {
    final avatar = _channelAvatars[channelId];
    return avatar != null && avatar.isNotEmpty;
  }

  bool hasCustomCover(String channelId) {
    final cover = _channelCovers[channelId];
    return cover != null && cover.isNotEmpty;
  }

  bool hasCustomData(String channelId) {
    return hasCustomAvatar(channelId) || hasCustomCover(channelId) || (_channelHashtags[channelId]?.isNotEmpty ?? false);
  }

  // Получение всех данных
  Map<String, String?> getAllCustomAvatars() {
    return Map.from(_channelAvatars)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }

  Map<String, String?> getAllCustomCovers() {
    return Map.from(_channelCovers)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }

  Map<String, List<String>> getAllCustomHashtags() {
    return Map.from(_channelHashtags)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }

  // Получение полной информации о канале
  Map<String, dynamic> getChannelData(String channelId) {
    return {
      'avatar': _channelAvatars[channelId],
      'cover': _channelCovers[channelId],
      'hashtags': _channelHashtags[channelId] ?? [],
      'has_custom_avatar': hasCustomAvatar(channelId),
      'has_custom_cover': hasCustomCover(channelId),
      'has_custom_data': hasCustomData(channelId),
    };
  }

  // Работа с хранилищем
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Сохраняем аватарки
      final avatarsJson = json.encode(_channelAvatars);
      await prefs.setString(_avatarsKey, avatarsJson);

      // Сохраняем обложки
      final coversJson = json.encode(_channelCovers);
      await prefs.setString(_coversKey, coversJson);

      // Сохраняем хештеги
      final hashtagsJson = json.encode(_channelHashtags.map(
              (key, value) => MapEntry(key, value)
      ));
      await prefs.setString(_hashtagsKey, hashtagsJson);

      print('✅ Channel state saved to storage');
    } catch (e) {
      print('❌ Error saving channel state: $e');
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Загружаем аватарки
      final avatarsJson = prefs.getString(_avatarsKey);
      if (avatarsJson != null) {
        final avatarsMap = json.decode(avatarsJson) as Map<String, dynamic>;
        _channelAvatars.clear();
        avatarsMap.forEach((key, value) {
          _channelAvatars[key] = value?.toString();
        });
      }

      // Загружаем обложки
      final coversJson = prefs.getString(_coversKey);
      if (coversJson != null) {
        final coversMap = json.decode(coversJson) as Map<String, dynamic>;
        _channelCovers.clear();
        coversMap.forEach((key, value) {
          _channelCovers[key] = value?.toString();
        });
      }

      // Загружаем хештеги
      final hashtagsJson = prefs.getString(_hashtagsKey);
      if (hashtagsJson != null) {
        final hashtagsMap = json.decode(hashtagsJson) as Map<String, dynamic>;
        _channelHashtags.clear();
        hashtagsMap.forEach((key, value) {
          if (value is List) {
            _channelHashtags[key] = List<String>.from(value.map((e) => e.toString()));
          }
        });
      }

      print('✅ Channel state loaded from storage');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading channel state: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_avatarsKey);
      await prefs.remove(_coversKey);
      await prefs.remove(_hashtagsKey);
      print('✅ Channel state cleared from storage');
    } catch (e) {
      print('❌ Error clearing channel state: $e');
    }
  }

  // Валидация и очистка хештегов
  String _cleanHashtag(String hashtag) {
    return hashtag.replaceAll(RegExp(r'#'), '').trim();
  }

  List<String> cleanHashtags(List<String> hashtags) {
    return hashtags.map(_cleanHashtag).where((tag) => tag.isNotEmpty).toList();
  }

  // Получение статистики
  Map<String, int> getStats() {
    return {
      'channels_with_avatars': getAllCustomAvatars().length,
      'channels_with_covers': getAllCustomCovers().length,
      'channels_with_hashtags': getAllCustomHashtags().length,
      'total_channels': _channelAvatars.length,
    };
  }

  // Поиск каналов по хештегам
  List<String> findChannelsByHashtag(String hashtag) {
    final cleanHashtag = _cleanHashtag(hashtag);
    return _channelHashtags.entries
        .where((entry) => entry.value.any((tag) => tag.toLowerCase().contains(cleanHashtag.toLowerCase())))
        .map((entry) => entry.key)
        .toList();
  }

  // Проверка существования канала
  bool channelExists(String channelId) {
    return _channelAvatars.containsKey(channelId) ||
        _channelCovers.containsKey(channelId) ||
        _channelHashtags.containsKey(channelId);
  }

  // Импорт/экспорт данных
  Map<String, dynamic> exportData() {
    return {
      'avatars': _channelAvatars,
      'covers': _channelCovers,
      'hashtags': _channelHashtags,
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data['avatars'] is Map) {
        _channelAvatars.clear();
        (data['avatars'] as Map).forEach((key, value) {
          _channelAvatars[key.toString()] = value?.toString();
        });
      }

      if (data['covers'] is Map) {
        _channelCovers.clear();
        (data['covers'] as Map).forEach((key, value) {
          _channelCovers[key.toString()] = value?.toString();
        });
      }

      if (data['hashtags'] is Map) {
        _channelHashtags.clear();
        (data['hashtags'] as Map).forEach((key, value) {
          if (value is List) {
            _channelHashtags[key.toString()] = List<String>.from(value.map((e) => e.toString()));
          }
        });
      }

      notifyListeners();
      await _saveToStorage();
      print('✅ Channel state imported successfully');
    } catch (e) {
      print('❌ Error importing channel state: $e');
      throw Exception('Failed to import channel state');
    }
  }
}