import 'package:flutter/foundation.dart';

class ChannelPostsProvider with ChangeNotifier {
  // Храним посты по ID канала: {channelId: [posts]}
  final Map<int, List<Map<String, dynamic>>> _channelPostsMap = {};

  // Получить посты для конкретного канала
  List<Map<String, dynamic>> getPostsForChannel(int channelId) {
    return _channelPostsMap[channelId] ?? [];
  }

  // Добавить пост в конкретный канал
  void addPostToChannel(int channelId, Map<String, dynamic> post) {
    if (!_channelPostsMap.containsKey(channelId)) {
      _channelPostsMap[channelId] = [];
    }
    _channelPostsMap[channelId]!.insert(0, post);
    notifyListeners();
  }

  // Загрузить посты для конкретного канала
  void loadPostsForChannel(int channelId, List<Map<String, dynamic>> posts) {
    _channelPostsMap[channelId] = posts;
    notifyListeners();
  }

  // Очистить посты конкретного канала
  void clearPostsForChannel(int channelId) {
    if (_channelPostsMap.containsKey(channelId)) {
      _channelPostsMap[channelId]!.clear();
      notifyListeners();
    }
  }

  // Очистить все (например, при logout)
  void clearAll() {
    _channelPostsMap.clear();
    notifyListeners();
  }
}