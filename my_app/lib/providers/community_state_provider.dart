import 'package:flutter/material.dart';
import '../pages/communities/models/community.dart';

class CommunityStateProvider with ChangeNotifier {
  List<Community> _communities = [];
  final Map<String, String?> _communityAvatars = {};
  final Map<String, String?> _communityCovers = {};
  final Map<String, List<String>> _communityHashtags = {};

  // Инициализация тестовыми данными
  void initializeWithTestData() {
    _communities = Community.testCommunities;
    notifyListeners();
  }

  // Геттер для списка сообществ
  List<Community> get communities => _communities;

  // Добавить новое сообщество
  void addCommunity(Community community) {
    _communities.insert(0, community);
    notifyListeners();
  }

  // Удалить сообщество
  void removeCommunity(String id) {
    _communities.removeWhere((community) => community.id.toString() == id);
    _communityAvatars.remove(id);
    _communityCovers.remove(id);
    _communityHashtags.remove(id);
    notifyListeners();
  }

  // Обновить сообщество
  void updateCommunity(String id, Community updatedCommunity) {
    final index = _communities.indexWhere((community) => community.id.toString() == id);
    if (index != -1) {
      _communities[index] = updatedCommunity;
      notifyListeners();
    }
  }

  // Получить сообщество по ID
  Community? getCommunityById(String id) {
    try {
      return _communities.firstWhere((community) => community.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  // Получить сообщества по категории/тегу
  List<Community> getCommunitiesByCategory(String category) {
    return _communities.where((community) {
      return community.tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()));
    }).toList();
  }

  // Поиск сообществ
  List<Community> searchCommunities(String query) {
    if (query.isEmpty) return _communities;

    final lowercaseQuery = query.toLowerCase();
    return _communities.where((community) {
      return community.title.toLowerCase().contains(lowercaseQuery) ||
          community.description.toLowerCase().contains(lowercaseQuery) ||
          community.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Аватарки
  String? getAvatarForCommunity(String communityId) {
    return _communityAvatars[communityId];
  }

  void setAvatarForCommunity(String communityId, String? avatarUrl) {
    _communityAvatars[communityId] = avatarUrl;

    // Обновляем соответствующее сообщество
    final community = getCommunityById(communityId);
    if (community != null) {
      final updatedCommunity = community.copyWith(
        imageUrl: avatarUrl ?? community.imageUrl,
      );
      updateCommunity(communityId, updatedCommunity);
    }

    notifyListeners();
  }

  // Обложки
  String? getCoverForCommunity(String communityId) {
    return _communityCovers[communityId];
  }

  void setCoverForCommunity(String communityId, String? coverUrl) {
    _communityCovers[communityId] = coverUrl;

    // Обновляем соответствующее сообщество
    final community = getCommunityById(communityId);
    if (community != null) {
      final updatedCommunity = community.copyWith(
        coverImageUrl: coverUrl ?? community.coverImageUrl,
      );
      updateCommunity(communityId, updatedCommunity);
    }

    notifyListeners();
  }

  // Хештеги
  List<String> getHashtagsForCommunity(String communityId) {
    return _communityHashtags[communityId] ?? [];
  }

  void setHashtagsForCommunity(String communityId, List<String> hashtags) {
    _communityHashtags[communityId] = hashtags;

    // Обновляем соответствующее сообщество
    final community = getCommunityById(communityId);
    if (community != null) {
      final updatedCommunity = community.copyWith(
        tags: hashtags,
      );
      updateCommunity(communityId, updatedCommunity);
    }

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

  // Получить избранные сообщества (пример реализации)
  List<Community> get favoriteCommunities {
    // Здесь можно добавить логику для избранных сообществ
    return _communities.where((community) => community.membersCount > 1000).toList();
  }

  // Получить популярные сообщества
  List<Community> get popularCommunities {
    return _communities.where((community) => community.membersCount > 500).toList();
  }

  // Обновить количество участников
  void updateMembersCount(String communityId, int newCount) {
    final community = getCommunityById(communityId);
    if (community != null) {
      final updatedCommunity = community.copyWith(
        membersCount: newCount,
      );
      updateCommunity(communityId, updatedCommunity);
    }
  }

  // Обновить количество постов
  void updatePostsCount(String communityId, int newCount) {
    final community = getCommunityById(communityId);
    if (community != null) {
      final updatedCommunity = community.copyWith(
        postsCount: newCount,
      );
      updateCommunity(communityId, updatedCommunity);
    }
  }

  // Переключить статус приватности
  void togglePrivacy(String communityId) {
    final community = getCommunityById(communityId);
    if (community != null) {
      final updatedCommunity = community.copyWith(
        isPrivate: !community.isPrivate,
      );
      updateCommunity(communityId, updatedCommunity);
    }
  }

  // Очистить все данные (для тестирования)
  void clearAllData() {
    _communities.clear();
    _communityAvatars.clear();
    _communityCovers.clear();
    _communityHashtags.clear();
    notifyListeners();
  }
}