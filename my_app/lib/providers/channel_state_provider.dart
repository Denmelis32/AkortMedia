// providers/channel_state_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelStateProvider with ChangeNotifier {
  final Map<String, String?> _channelAvatars = {};
  final Map<String, String?> _channelCovers = {};
  final Map<String, List<String>> _channelHashtags = {};
  final Map<String, bool> _channelSubscriptions = {};
  final Map<String, int> _channelSubscribersCount = {};

  static const String _avatarsKey = 'channel_avatars';
  static const String _coversKey = 'channel_covers';
  static const String _hashtagsKey = 'channel_hashtags';
  static const String _subscriptionsKey = 'channel_subscriptions';
  static const String _subscribersCountKey = 'channel_subscribers_count';

  ChannelStateProvider() {
    _loadFromStorage();
  }

  // === МЕТОДЫ ДЛЯ ОБРАТНОЙ СОВМЕСТИМОСТИ ===

  /// [УСТАРЕВШИЙ] Получение аватарки канала - используйте getCurrentAvatar вместо этого
  String? getAvatarForChannel(String channelId) => _channelAvatars[channelId];

  /// [УСТАРЕВШИЙ] Получение обложки канала - используйте getCurrentCover вместо этого
  String? getCoverForChannel(String channelId) => _channelCovers[channelId];

  // === НОВЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С АВАТАРКАМИ ===

  /// Получение текущей аватарки канала с приоритетом: кастомная → дефолтная
  String? getCurrentAvatar(String channelId, {String? defaultAvatar}) {
    return _channelAvatars[channelId] ?? defaultAvatar;
  }

  /// Установка аватарки канала
  void setAvatarForChannel(String channelId, String? avatarUrl) {
    if (avatarUrl == null) {
      _channelAvatars.remove(channelId);
    } else {
      _channelAvatars[channelId] = avatarUrl;
    }
    notifyListeners();
    _saveToStorage();
  }

  /// Очистка аватарки канала (возврат к дефолтной)
  void clearAvatarForChannel(String channelId) {
    _channelAvatars.remove(channelId);
    notifyListeners();
    _saveToStorage();
  }

  /// Проверка наличия кастомной аватарки
  bool hasCustomAvatar(String channelId) {
    final avatar = _channelAvatars[channelId];
    return avatar != null && avatar.isNotEmpty;
  }

  /// Получение всех кастомных аватарок
  Map<String, String?> getAllCustomAvatars() {
    return Map.from(_channelAvatars)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }

  // === МЕТОДЫ ДЛЯ ОБЛОЖЕК ===

  /// Получение текущей обложки канала с приоритетом: кастомная → дефолтная
  String? getCurrentCover(String channelId, {String? defaultCover}) {
    return _channelCovers[channelId] ?? defaultCover;
  }

  /// Установка обложки канала
  void setCoverForChannel(String channelId, String? coverUrl) {
    if (coverUrl == null) {
      _channelCovers.remove(channelId);
    } else {
      _channelCovers[channelId] = coverUrl;
    }
    notifyListeners();
    _saveToStorage();
  }

  /// Очистка обложки канала (возврат к дефолтной)
  void clearCoverForChannel(String channelId) {
    _channelCovers.remove(channelId);
    notifyListeners();
    _saveToStorage();
  }

  /// Проверка наличия кастомной обложки
  bool hasCustomCover(String channelId) {
    final cover = _channelCovers[channelId];
    return cover != null && cover.isNotEmpty;
  }

  /// Получение всех кастомных обложек
  Map<String, String?> getAllCustomCovers() {
    return Map.from(_channelCovers)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }

  // === МЕТОДЫ ДЛЯ ХЕШТЕГОВ ===

  /// Получение хештегов канала
  List<String> getHashtagsForChannel(String channelId) => _channelHashtags[channelId] ?? [];

  /// Установка хештегов канала
  void setHashtagsForChannel(String channelId, List<String> hashtags) {
    _channelHashtags[channelId] = List.from(hashtags);
    notifyListeners();
    _saveToStorage();
  }

  /// Добавление хештега к каналу
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

  /// Удаление хештега из канала
  void removeHashtagFromChannel(String channelId, String hashtag) {
    if (_channelHashtags.containsKey(channelId)) {
      _channelHashtags[channelId]!.remove(hashtag);
      notifyListeners();
      _saveToStorage();
    }
  }

  /// Очистка всех хештегов канала
  void clearHashtagsForChannel(String channelId) {
    _channelHashtags.remove(channelId);
    notifyListeners();
    _saveToStorage();
  }

  /// Получение всех кастомных хештегов
  Map<String, List<String>> getAllCustomHashtags() {
    return Map.from(_channelHashtags)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }

  // === МЕТОДЫ ДЛЯ ПОДПИСОК ===

  /// Проверка подписки на канал
  bool isSubscribed(String channelId) {
    return _channelSubscriptions[channelId] ?? false;
  }

  /// Получение количества подписчиков
  int getSubscribers(String channelId) {
    return _channelSubscribersCount[channelId] ?? 0;
  }

  /// Обновление подписки
  void updateChannelSubscription(String channelId, bool isSubscribed, int subscribersCount) {
    _channelSubscriptions[channelId] = isSubscribed;
    _channelSubscribersCount[channelId] = subscribersCount;
    notifyListeners();
    _saveToStorage();
  }

  /// Переключение подписки
  void toggleSubscription(String channelId, int currentSubscribers) {
    final currentIsSubscribed = isSubscribed(channelId);
    final newSubscribedState = !currentIsSubscribed;
    final newSubscribersCount = newSubscribedState
        ? currentSubscribers + 1
        : currentSubscribers - 1;

    updateChannelSubscription(channelId, newSubscribedState, newSubscribersCount);
  }

  /// Получение всех подписок
  List<String> getSubscribedChannels() {
    return _channelSubscriptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Получение количества подписок
  int getSubscriptionsCount() {
    return _channelSubscriptions.values.where((isSubscribed) => isSubscribed).length;
  }

  /// Получение всех подписок
  Map<String, bool> getAllSubscriptions() {
    return Map.from(_channelSubscriptions);
  }

  // === ОБЩИЕ МЕТОДЫ ===

  /// Проверка наличия кастомных данных у канала
  bool hasCustomData(String channelId) {
    return hasCustomAvatar(channelId) || hasCustomCover(channelId) || (_channelHashtags[channelId]?.isNotEmpty ?? false);
  }

  /// Инициализация канала
  void initializeChannelIfNeeded(String channelId, {String? defaultAvatar, String? defaultCover, List<String>? defaultTags, int? defaultSubscribers}) {
    if (!_channelAvatars.containsKey(channelId) && defaultAvatar != null) {
      _channelAvatars[channelId] = defaultAvatar;
    }
    if (!_channelCovers.containsKey(channelId) && defaultCover != null) {
      _channelCovers[channelId] = defaultCover;
    }
    if (!_channelHashtags.containsKey(channelId) && defaultTags != null) {
      _channelHashtags[channelId] = List.from(defaultTags);
    }
    if (!_channelSubscribersCount.containsKey(channelId) && defaultSubscribers != null) {
      _channelSubscribersCount[channelId] = defaultSubscribers;
    }
  }

  /// Получение полной информации о канале
  Map<String, dynamic> getChannelData(String channelId) {
    return {
      'avatar': _channelAvatars[channelId],
      'cover': _channelCovers[channelId],
      'hashtags': _channelHashtags[channelId] ?? [],
      'is_subscribed': isSubscribed(channelId),
      'subscribers_count': getSubscribers(channelId),
      'has_custom_avatar': hasCustomAvatar(channelId),
      'has_custom_cover': hasCustomCover(channelId),
      'has_custom_data': hasCustomData(channelId),
    };
  }

  /// Очистка данных канала
  void clearChannelData(String channelId) {
    _channelAvatars.remove(channelId);
    _channelCovers.remove(channelId);
    _channelHashtags.remove(channelId);
    _channelSubscriptions.remove(channelId);
    _channelSubscribersCount.remove(channelId);
    notifyListeners();
    _saveToStorage();
  }

  /// Очистка всех данных
  void clearAllData() {
    _channelAvatars.clear();
    _channelCovers.clear();
    _channelHashtags.clear();
    _channelSubscriptions.clear();
    _channelSubscribersCount.clear();
    notifyListeners();
    _clearStorage();
  }

  // === РАБОТА С ХРАНИЛИЩЕМ ===

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

      // Сохраняем подписки
      final subscriptionsJson = json.encode(_channelSubscriptions);
      await prefs.setString(_subscriptionsKey, subscriptionsJson);

      // Сохраняем количество подписчиков
      final subscribersCountJson = json.encode(_channelSubscribersCount);
      await prefs.setString(_subscribersCountKey, subscribersCountJson);

      if (kDebugMode) {
        print('✅ Channel state saved to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving channel state: $e');
      }
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

      // Загружаем подписки
      final subscriptionsJson = prefs.getString(_subscriptionsKey);
      if (subscriptionsJson != null) {
        final subscriptionsMap = json.decode(subscriptionsJson) as Map<String, dynamic>;
        _channelSubscriptions.clear();
        subscriptionsMap.forEach((key, value) {
          _channelSubscriptions[key] = value as bool;
        });
      }

      // Загружаем количество подписчиков
      final subscribersCountJson = prefs.getString(_subscribersCountKey);
      if (subscribersCountJson != null) {
        final subscribersCountMap = json.decode(subscribersCountJson) as Map<String, dynamic>;
        _channelSubscribersCount.clear();
        subscribersCountMap.forEach((key, value) {
          _channelSubscribersCount[key] = value as int;
        });
      }

      if (kDebugMode) {
        print('✅ Channel state loaded from storage');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading channel state: $e');
      }
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_avatarsKey);
      await prefs.remove(_coversKey);
      await prefs.remove(_hashtagsKey);
      await prefs.remove(_subscriptionsKey);
      await prefs.remove(_subscribersCountKey);
      if (kDebugMode) {
        print('✅ Channel state cleared from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing channel state: $e');
      }
    }
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  /// Валидация и очистка хештегов
  String _cleanHashtag(String hashtag) {
    return hashtag.replaceAll(RegExp(r'#'), '').trim();
  }

  List<String> cleanHashtags(List<String> hashtags) {
    return hashtags.map(_cleanHashtag).where((tag) => tag.isNotEmpty).toList();
  }

  /// Получение статистики
  Map<String, int> getStats() {
    return {
      'channels_with_avatars': getAllCustomAvatars().length,
      'channels_with_covers': getAllCustomCovers().length,
      'channels_with_hashtags': getAllCustomHashtags().length,
      'total_subscriptions': getSubscriptionsCount(),
      'total_channels': _channelAvatars.length,
    };
  }

  /// Поиск каналов по хештегам
  List<String> findChannelsByHashtag(String hashtag) {
    final cleanHashtag = _cleanHashtag(hashtag);
    return _channelHashtags.entries
        .where((entry) => entry.value.any((tag) => tag.toLowerCase().contains(cleanHashtag.toLowerCase())))
        .map((entry) => entry.key)
        .toList();
  }

  /// Проверка существования канала
  bool channelExists(String channelId) {
    return _channelAvatars.containsKey(channelId) ||
        _channelCovers.containsKey(channelId) ||
        _channelHashtags.containsKey(channelId) ||
        _channelSubscriptions.containsKey(channelId) ||
        _channelSubscribersCount.containsKey(channelId);
  }

  // === ИМПОРТ/ЭКСПОРТ ДАННЫХ ===

  /// Экспорт всех данных
  Map<String, dynamic> exportData() {
    return {
      'avatars': _channelAvatars,
      'covers': _channelCovers,
      'hashtags': _channelHashtags,
      'subscriptions': _channelSubscriptions,
      'subscribers_count': _channelSubscribersCount,
      'version': '1.1.0',
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Импорт данных
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

      if (data['subscriptions'] is Map) {
        _channelSubscriptions.clear();
        (data['subscriptions'] as Map).forEach((key, value) {
          _channelSubscriptions[key.toString()] = value as bool;
        });
      }

      if (data['subscribers_count'] is Map) {
        _channelSubscribersCount.clear();
        (data['subscribers_count'] as Map).forEach((key, value) {
          _channelSubscribersCount[key.toString()] = value as int;
        });
      }

      notifyListeners();
      await _saveToStorage();
      if (kDebugMode) {
        print('✅ Channel state imported successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error importing channel state: $e');
      }
      throw Exception('Failed to import channel state');
    }
  }
}