// providers/channel_state_provider.dart
import 'package:flutter/foundation.dart';

class ChannelStateProvider with ChangeNotifier {
  final Map<int, String?> _channelAvatars = {};
  final Map<int, String?> _channelCovers = {};
  final Map<int, List<String>> _channelHashtags = {};

  String? getAvatarForChannel(int channelId) => _channelAvatars[channelId];
  String? getCoverForChannel(int channelId) => _channelCovers[channelId];
  List<String> getHashtagsForChannel(int channelId) => _channelHashtags[channelId] ?? [];

  void setAvatarForChannel(int channelId, String? avatarUrl) {
    _channelAvatars[channelId] = avatarUrl;
    notifyListeners();
  }

  void setCoverForChannel(int channelId, String? coverUrl) {
    _channelCovers[channelId] = coverUrl;
    notifyListeners();
  }



  void clearAllData() {
    _channelAvatars.clear();
    _channelCovers.clear();
    _channelHashtags.clear();
    notifyListeners();
  }

  // Метод для инициализации канала, если его еще нет
  void initializeChannelIfNeeded(int channelId, String defaultAvatar, String? defaultCover, List<String> defaultTags) {
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


  void setHashtagsForChannel(int channelId, List<String> hashtags) {
    _channelHashtags[channelId] = hashtags;
    notifyListeners();
  }

  void clearChannelData(int channelId) {
    _channelAvatars.remove(channelId);
    _channelCovers.remove(channelId);
    _channelHashtags.remove(channelId);
    notifyListeners();
  }
}