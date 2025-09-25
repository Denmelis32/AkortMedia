import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_detail_provider.dart';
import '../../models/channel.dart';
import '../../models/channel_detail_state.dart';
import 'playlist_section.dart';

class PlaylistsSection extends StatelessWidget {
  final Channel channel;
  final ChannelDetailProvider provider;
  final ChannelDetailState state;

  const PlaylistsSection({
    super.key,
    required this.channel,
    required this.provider,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCollapsibleSection(
      context,
      id: 1,
      title: 'ПЛЕЙЛИСТЫ',
      count: 8,
      icon: Icons.playlist_play_rounded,
      isExpanded: state.expandedSections[1] ?? false,
      onToggle: () => provider.toggleSection(1),
      child: Column(
        children: [
          const SizedBox(height: 16),
          PlaylistSection(channel: channel),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showAllPlaylists(context),
              style: TextButton.styleFrom(foregroundColor: channel.cardColor),
              child: const Text('Все плейлисты'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection(
      BuildContext context, {
        required int id,
        required String title,
        required Widget child,
        required bool isExpanded,
        required VoidCallback onToggle,
        int? count,
        IconData? icon,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        key: ValueKey(id),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) => onToggle(),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.grey[600],
        ),
        title: Row(
          children: [
            if (icon != null) Icon(icon, size: 18, color: channel.cardColor),
            if (icon != null) const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: channel.cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: channel.cardColor,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  void _showAllPlaylists(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Показать все плейлисты')),
    );
  }
}