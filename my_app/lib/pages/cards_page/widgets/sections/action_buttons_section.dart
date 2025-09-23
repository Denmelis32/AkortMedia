import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_detail_provider.dart';
import '../../models/channel.dart';
import '../chat_dialog.dart';

class ActionButtonsSection extends StatelessWidget {
  final Channel channel;
  final ChannelDetailProvider provider;
  final ChannelDetailState state;

  const ActionButtonsSection({
    super.key,
    required this.channel,
    required this.provider,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildSubscribeButton(),
          _buildNotificationsButton(),
          _buildChatButton(context),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: 180,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: state.isSubscribed
              ? LinearGradient(colors: [Colors.grey[300]!, Colors.grey[200]!])
              : LinearGradient(colors: [
            channel.cardColor,
            channel.cardColor.withOpacity(0.8)
          ]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (state.isSubscribed ? Colors.grey : channel.cardColor)
                  .withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: provider.toggleSubscription,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: state.isSubscribed ? Colors.grey[700] : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(state.isSubscribed ? Icons.check : Icons.person_add_alt_1, size: 20),
              const SizedBox(width: 8),
              Text(
                state.isSubscribed ? 'ПОДПИСАН' : 'ПОДПИСАТЬСЯ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsButton() {
    return _buildIconButton(
      icon: state.notificationsEnabled
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
      onPressed: provider.toggleNotifications,
      tooltip: 'Уведомления',
      color: state.notificationsEnabled ? channel.cardColor : Colors.grey[600],
      isActive: state.notificationsEnabled,
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return _buildIconButton(
      icon: Icons.chat_bubble_outline_rounded,
      onPressed: () => _showChatDialog(context),
      tooltip: 'Чат',
      color: Colors.blue,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isActive
            ? Border.all(color: color ?? Colors.grey[700]!, width: 2)
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: color ?? Colors.grey[700],
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        tooltip: tooltip,
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChatDialog(
        channel: channel,
        messages: state.chatMessages,
        onSendMessage: provider.addChatMessage,
      ),
    );
  }
}