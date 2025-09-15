// Этот файл можно удалить, так как вся функциональность
// теперь находится в ChannelService

// Или оставить как прокси к ChannelService для обратной совместимости:
import 'package:my_app/services/channel_service.dart';

import '../pages/rooms_pages/models_room/channel.dart';

class SubscriptionService {
  static bool isUserSubscribed(Channel channel, String userId) {
    return ChannelService.isUserSubscribed(channel, userId);
  }

  static void subscribe(Channel channel, String userId) {
    ChannelService.subscribe(channel, userId);
  }

  static void unsubscribe(Channel channel, String userId) {
    ChannelService.unsubscribe(channel, userId);
  }

  static void toggleSubscription(Channel channel, String userId) {
    ChannelService.toggleSubscription(channel, userId);
  }

  static List<Channel> getSubscribedChannels(List<Channel> allChannels, String userId) {
    return ChannelService.getSubscribedChannels(allChannels, userId);
  }
}