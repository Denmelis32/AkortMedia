import 'package:flutter/material.dart';

class CommunityStateProvider with ChangeNotifier {
  final Map<String, String?> _communityAvatars = {};
  final Map<String, String?> _communityCovers = {};
  final Map<String, List<String>> _communityHashtags = {};

  // Аватарки
  String? getAvatarForCommunity(String communityId) {
    return _communityAvatars[communityId];
  }

  void setAvatarForCommunity(String communityId, String? avatarUrl) {
    _communityAvatars[communityId] = avatarUrl;
    notifyListeners();
  }

  // Обложки
  String? getCoverForCommunity(String communityId) {
    return _communityCovers[communityId];
  }

  void setCoverForCommunity(String communityId, String? coverUrl) {
    _communityCovers[communityId] = coverUrl;
    notifyListeners();
  }

  // Хештеги
  List<String> getHashtagsForCommunity(String communityId) {
    return _communityHashtags[communityId] ?? [];
  }

  void setHashtagsForCommunity(String communityId, List<String> hashtags) {
    _communityHashtags[communityId] = hashtags;
    notifyListeners();
  }

  // Инициализация
  void initializeCommunityIfNeeded(
      String communityId, {
        String? defaultAvatar,
        String? defaultCover,
        List<String>? defaultTags,
      }) {
    if (!_communityAvatars.containsKey(communityId) && defaultAvatar != null) {
      _communityAvatars[communityId] = defaultAvatar;
    }
    if (!_communityCovers.containsKey(communityId) && defaultCover != null) {
      _communityCovers[communityId] = defaultCover;
    }
    if (!_communityHashtags.containsKey(communityId) && defaultTags != null) {
      _communityHashtags[communityId] = defaultTags;
    }
  }

  // Для пользовательских аватарок (если нужно)
  String getCurrentAvatar(String userId, {String defaultAvatar = ''}) {
    return _communityAvatars[userId] ?? defaultAvatar;
  }
}