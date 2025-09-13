import '../pages/rooms_pages/models_room/channel.dart';
import '../pages/rooms_pages/models_room/discussion_topic.dart';


class ChannelService {
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
}
