import '../pages/rooms_pages/models_room/channel.dart';
import '../pages/rooms_pages/models_room/discussion_topic.dart';

class ChannelService {
  // Хранилище подписок: userId -> Set<channelId>
  static final Map<String, Set<String>> _userSubscriptions = {};

  // Основные методы работы с каналами
  static List<Channel> getChannelsByCategory(String categoryId, List<Channel> allChannels) {
    return allChannels.where((channel) => channel.categoryId == categoryId).toList();
  }

  static List<DiscussionTopic> getRecentTopicsForChannel(
      String channelId,
      List<DiscussionTopic> allTopics,
      int limit
      ) {
    final channelTopics = allTopics.where((topic) => topic.channelId == channelId).toList();
    channelTopics.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return channelTopics.take(limit).toList();
  }

  static List<Channel> getPopularChannels(List<Channel> channels, int limit) {
    final sorted = List<Channel>.from(channels);
    sorted.sort((a, b) => b.subscribersCount.compareTo(a.subscribersCount));
    return sorted.take(limit).toList();
  }

  static List<Channel> searchChannels(List<Channel> channels, String query) {
    if (query.isEmpty) return channels;

    return channels.where((channel) =>
    channel.name.toLowerCase().contains(query.toLowerCase()) ||
        channel.description.toLowerCase().contains(query.toLowerCase()) ||
        channel.ownerName.toLowerCase().contains(query.toLowerCase()) ||
        channel.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  static List<Channel> getChannelsByOwner(String ownerId, List<Channel> allChannels) {
    return allChannels.where((channel) => channel.ownerId == ownerId).toList();
  }

  static void addChannel(List<Channel> channels, Channel newChannel) {
    channels.add(newChannel);
  }

  // Методы для работы с подписками
  static bool isUserSubscribed(Channel channel, String userId) {
    return _userSubscriptions[userId]?.contains(channel.id) ?? false;
  }

  static void subscribe(Channel channel, String userId) {
    if (!isUserSubscribed(channel, userId)) {
      _userSubscriptions.putIfAbsent(userId, () => Set<String>()).add(channel.id);
      channel.subscribersCount++;
    }
  }

  static void unsubscribe(Channel channel, String userId) {
    if (isUserSubscribed(channel, userId)) {
      _userSubscriptions[userId]?.remove(channel.id);
      channel.subscribersCount = channel.subscribersCount > 0
          ? channel.subscribersCount - 1
          : 0;
    }
  }

  static void toggleSubscription(Channel channel, String userId) {
    if (isUserSubscribed(channel, userId)) {
      unsubscribe(channel, userId);
    } else {
      subscribe(channel, userId);
    }
  }

  static List<Channel> getSubscribedChannels(List<Channel> allChannels, String userId) {
    final subscribedIds = _userSubscriptions[userId] ?? Set<String>();
    return allChannels.where((channel) => subscribedIds.contains(channel.id)).toList();
  }

  static int getSubscribedChannelsCount(String userId) {
    return _userSubscriptions[userId]?.length ?? 0;
  }

  // Метод для очистки подписок (для тестирования)
  static void clearSubscriptions() {
    _userSubscriptions.clear();
  }
}