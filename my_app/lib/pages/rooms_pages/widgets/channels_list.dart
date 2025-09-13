import 'package:flutter/material.dart';
import '../models_room/channel.dart';
import 'channel_card.dart';

class ChannelsList extends StatelessWidget {
  final List<Channel> channels;
  final void Function(Channel) onChannelTap;
  final bool showAsGrid;

  const ChannelsList({
    super.key,
    required this.channels,
    required this.onChannelTap,
    this.showAsGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsGrid) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return ChannelCard(
            channel: channel,
            onTap: onChannelTap, // Just pass the function directly
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return ChannelCard(
            channel: channel,
            onTap: onChannelTap, // Just pass the function directly
            compact: true,
          );
        },
      );
    }
  }
}