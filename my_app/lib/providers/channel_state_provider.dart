// providers/channel_state_provider.dart
import 'package:flutter/foundation.dart';

class ChannelStateProvider with ChangeNotifier {
  final Map<String, String?> _channelAvatars = {};
  final Map<String, String?> _channelCovers = {};
  final Map<String, List<String>> _channelHashtags = {};

  String? getAvatarForChannel(String channelId) => _channelAvatars[channelId];
  String? getCoverForChannel(String channelId) => _channelCovers[channelId];
  List<String> getHashtagsForChannel(String channelId) => _channelHashtags[channelId] ?? [];

  void setAvatarForChannel(String channelId, String? avatarUrl) {
    _channelAvatars[channelId] = avatarUrl;
    notifyListeners();
  }

  void setCoverForChannel(String channelId, String? coverUrl) {
    _channelCovers[channelId] = coverUrl;
    notifyListeners();
  }

  void setHashtagsForChannel(String channelId, List<String> hashtags) {
    _channelHashtags[channelId] = hashtags;
    notifyListeners();
  }

  void clearAllData() {
    _channelAvatars.clear();
    _channelCovers.clear();
    _channelHashtags.clear();
    notifyListeners();
  }

  // Метод для инициализации канала, если его еще нет
  void initializeChannelIfNeeded(String channelId, String defaultAvatar, String? defaultCover, List<String> defaultTags) {
    if (!_channelAvatars.containsKey(channelId)) {
      _channelAvatars[channelId] = defaultAvatar;
    }
    if (!_channelCovers.containsKey(channelId)) {
      _channelCovers[channelId] = defaultCover;
    }
    if (!_channelHashtags.containsKey(channelId)) {
      _channelHashtags[channelId] = List.from(defaultTags);
    }
  }

  void clearChannelData(String channelId) {
    _channelAvatars.remove(channelId);
    _channelCovers.remove(channelId);
    _channelHashtags.remove(channelId);
    notifyListeners();
  }

  // Дополнительные методы для удобства
  bool hasCustomAvatar(String channelId) {
    final defaultAvatar = _channelAvatars[channelId];
    return defaultAvatar != null && defaultAvatar.isNotEmpty;
  }

  bool hasCustomCover(String channelId) {
    final defaultCover = _channelCovers[channelId];
    return defaultCover != null && defaultCover.isNotEmpty;
  }

  // Получение всех каналов с пользовательскими аватарками
  Map<String, String?> getAllCustomAvatars() {
    return Map.from(_channelAvatars)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }

  // Получение всех каналов с пользовательскими обложками
  Map<String, String?> getAllCustomCovers() {
    return Map.from(_channelCovers)
      ..removeWhere((key, value) => value == null || value.isEmpty);
  }
}