import 'package:my_app/pages/rooms_pages/models_room/user_permissions.dart';

import 'channel.dart';

class ChannelDetailArgs {
  final Channel channel;
  final String userId;
  final UserPermissions userPermissions;

  ChannelDetailArgs({
    required this.channel,
    required this.userId,
    required this.userPermissions,
  });
}