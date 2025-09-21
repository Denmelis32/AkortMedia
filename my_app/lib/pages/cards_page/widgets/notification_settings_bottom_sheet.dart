// lib/pages/cards_page/channel_detail_page/widgets/notification_settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/channel.dart';

class NotificationSettingsBottomSheet extends StatefulWidget {
  final Channel channel;
  final bool isNotificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;

  const NotificationSettingsBottomSheet({
    super.key,
    required this.channel,
    required this.isNotificationsEnabled,
    required this.onNotificationsChanged,
  });

  @override
  State<NotificationSettingsBottomSheet> createState() => _NotificationSettingsBottomSheetState();
}

class _NotificationSettingsBottomSheetState extends State<NotificationSettingsBottomSheet> {
  bool _notificationsEnabled = true;
  bool _vibrate = true;
  bool _sound = true;
  String _frequency = 'Все уведомления';

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.isNotificationsEnabled;
  }

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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Настройки уведомлений',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Канал: ${widget.channel.title}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Переключатель уведомлений
          _buildSettingSwitch(
            title: 'Уведомления',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              widget.onNotificationsChanged(value);
            },
            icon: Icons.notifications,
            color: widget.channel.cardColor,
          ),

          if (_notificationsEnabled) ...[
            const SizedBox(height: 16),
            _buildSettingSwitch(
              title: 'Вибрация',
              value: _vibrate,
              onChanged: (value) => setState(() => _vibrate = value),
              icon: Icons.vibration,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildSettingSwitch(
              title: 'Звук',
              value: _sound,
              onChanged: (value) => setState(() => _sound = value),
              icon: Icons.volume_up,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildFrequencySelector(),
          ],

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.channel.cardColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Row(
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
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Частота уведомлений',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _frequency,
          items: const [
            DropdownMenuItem(value: 'Все уведомления', child: Text('Все уведомления')),
            DropdownMenuItem(value: 'Только важные', child: Text('Только важные')),
            DropdownMenuItem(value: 'Никакие', child: Text('Никакие')),
          ],
          onChanged: (value) => setState(() => _frequency = value!),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.channel.cardColor),
            ),
          ),
        ),
      ],
    );
  }
}