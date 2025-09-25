import 'package:flutter/material.dart';
import '../models/channel.dart';

class ChannelOptionsDialog extends StatelessWidget {
  final Channel channel;
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback onCopyLink;
  final VoidCallback onShowQR;
  final VoidCallback onNotificationSettings;

  const ChannelOptionsDialog({
    super.key,
    required this.channel,
    required this.onReport,
    required this.onBlock,
    required this.onCopyLink,
    required this.onShowQR,
    required this.onNotificationSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 24),
          _buildTitle(context),
          const SizedBox(height: 24),
          _buildOptionTile(
            context,
            icon: Icons.report,
            title: 'Пожаловаться',
            color: Colors.orange,
            onTap: onReport,
          ),
          _buildOptionTile(
            context,
            icon: Icons.block,
            title: 'Заблокировать канал',
            color: Colors.red,
            onTap: onBlock,
          ),
          _buildOptionTile(
            context,
            icon: Icons.copy,
            title: 'Скопировать ссылку',
            color: Colors.blue,
            onTap: onCopyLink,
          ),
          _buildOptionTile(
            context,
            icon: Icons.qr_code,
            title: 'Показать QR-код',
            color: Colors.green,
            onTap: onShowQR,
          ),
          _buildOptionTile(
            context,
            icon: Icons.settings,
            title: 'Настройки уведомлений',
            color: Colors.blueGrey,
            onTap: onNotificationSettings,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 48,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Опции канала',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}