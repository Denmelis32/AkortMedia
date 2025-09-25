import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_detail_provider.dart';
import '../../models/channel.dart';
import '../../models/channel_detail_state.dart';
import '../shared/channel_members.dart';

class MembersSection extends StatelessWidget {
  final Channel channel;
  final ChannelDetailProvider provider;
  final ChannelDetailState state;

  const MembersSection({
    super.key,
    required this.channel,
    required this.provider,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCollapsibleSection(
      context,
      id: 0,
      title: 'УЧАСТНИКИ',
      count: 125,
      icon: Icons.people_rounded,
      isExpanded: state.expandedSections[0] ?? false,
      onToggle: () => provider.toggleSection(0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ChannelMembers(channel: channel),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => _inviteMembers(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: channel.cardColor,
                  side: BorderSide(color: channel.cardColor),
                ),
                child: const Text('Пригласить'),
              ),
              TextButton(
                onPressed: () => _showAllMembers(context),
                style: TextButton.styleFrom(foregroundColor: channel.cardColor),
                child: const Text('Показать всех'),
              ),
            ],
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
                  _formatNumber(count),
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

  void _inviteMembers(BuildContext context) {
    // Логика приглашения участников
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Функция приглашения участников')),
    );
  }

  void _showAllMembers(BuildContext context) {
    // Логика показа всех участников
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Показать всех участников')),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}