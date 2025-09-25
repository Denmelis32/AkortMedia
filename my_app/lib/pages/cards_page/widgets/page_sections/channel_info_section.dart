import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_detail_provider.dart';
import '../../models/channel.dart';
import '../../models/channel_detail_state.dart';


class ChannelInfoSection extends StatelessWidget {
  final Channel channel;
  final ChannelDetailProvider provider;
  final ChannelDetailState state;

  const ChannelInfoSection({
    super.key,
    required this.channel,
    required this.provider,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 20),
          _buildDescription(context),
          const SizedBox(height: 24),
          _buildChannelStats(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          'О КАНАЛЕ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: channel.cardColor,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            state.isEditingDescription ? Icons.check : Icons.edit,
            size: 18,
            color: channel.cardColor,
          ),
          onPressed: provider.toggleEditDescription,
          tooltip: state.isEditingDescription ? 'Сохранить' : 'Редактировать',
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return state.isEditingDescription
        ? TextField(
      controller: provider.descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: channel.cardColor),
        ),
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          channel.description,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: state.showFullDescription ? null : 3,
          overflow: state.showFullDescription ? null : TextOverflow.ellipsis,
        ),
        if (channel.description.length > 150 && !state.isEditingDescription)
          TextButton(
            onPressed: provider.toggleDescription,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              state.showFullDescription ? 'Свернуть' : 'Читать далее',
              style: TextStyle(
                color: channel.cardColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChannelStats(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          Icons.people_alt_rounded,
          '${_formatNumber(channel.subscribers)} подписчиков',
          channel.cardColor,
        ),
        _buildInfoRow(
          context,
          Icons.video_library_rounded,
          '${channel.videos} видео',
          channel.cardColor,
        ),
        _buildInfoRow(
          context,
          Icons.calendar_today_rounded,
          'Создан: ${_formatDate(DateTime(2022, 3, 15))}',
          channel.cardColor,
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}