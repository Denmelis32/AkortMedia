import 'package:flutter/material.dart';
import '../pages/communities/models/community.dart';


class CommunitiesProvider with ChangeNotifier {
  List<Community> _communities = Community.testCommunities;

  List<Community> get communities => _communities;

  void addCommunity(Community community) {
    _communities.insert(0, community);
    notifyListeners();
  }

  void removeCommunity(String id) {
    _communities.removeWhere((community) => community.id.toString() == id);
    notifyListeners();
  }

  Community? getCommunityById(String id) {
    try {
      return _communities.firstWhere((community) => community.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  List<Community> getCommunitiesByCategory(String category) {
    return _communities.where((community) {
      return community.tags.any((tag) => tag.toLowerCase() == category.toLowerCase());
    }).toList();
  }
}