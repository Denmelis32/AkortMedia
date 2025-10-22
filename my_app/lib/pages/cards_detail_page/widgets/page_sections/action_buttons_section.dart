import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_detail_provider.dart';
import '../../../../providers/channel_state_provider.dart';
import '../../models/channel.dart';
import '../../dialogs/chat_dialog.dart';
import '../../models/channel_detail_state.dart';

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
    return Consumer<ChannelStateProvider>(
      builder: (context, channelStateProvider, child) {
        final channelId = channel.id.toString();
        final isSubscribed = channelStateProvider.isSubscribed(channelId);
        final subscribersCount = channelStateProvider.getSubscribers(channelId) ?? channel.subscribers;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Статистика канала с обновленными данными
              _buildChannelStats(subscribersCount, channelStateProvider),
              const SizedBox(height: 20),

              // Основные кнопки действий
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSubscribeButton(isSubscribed, channelStateProvider, context),
                  _buildNotificationsButton(),
                  _buildChatButton(context),
                  _buildShareButton(context),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelStats(int subscribersCount, ChannelStateProvider stateProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: _formatNumber(subscribersCount),
            label: 'Подписчиков',
            icon: Icons.people_rounded,
            color: Colors.blue,
          ),
          _buildStatItem(
            value: channel.videos.toString(),
            label: 'Публикаций',
            icon: Icons.video_library_rounded,
            color: Colors.green,
          ),
          _buildStatItem(
            value: _formatNumber(channel.views),
            label: 'Просмотров',
            icon: Icons.visibility_rounded,
            color: Colors.orange,
          ),
          _buildStatItem(
            value: channel.rating.toStringAsFixed(1),
            label: 'Рейтинг',
            icon: Icons.star_rounded,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(bool isSubscribed, ChannelStateProvider stateProvider, BuildContext context) {
    return SizedBox(
      width: 180,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSubscribed
              ? LinearGradient(
            colors: [Colors.grey[300]!, Colors.grey[200]!],
          )
              : LinearGradient(
            colors: [
              channel.cardColor,
              channel.cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isSubscribed ? Colors.grey : channel.cardColor)
                  .withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _toggleSubscription(stateProvider, context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: isSubscribed ? Colors.grey[700] : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isSubscribed ? Icons.check_circle_rounded : Icons.person_add_alt_1,
                  size: 20,
                  key: ValueKey(isSubscribed),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isSubscribed ? 'ПОДПИСАН' : 'ПОДПИСАТЬСЯ',
                  key: ValueKey(isSubscribed),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
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
      tooltip: state.notificationsEnabled ? 'Уведомления включены' : 'Уведомления выключены',
      color: state.notificationsEnabled ? channel.cardColor : Colors.grey[600],
      isActive: state.notificationsEnabled,
      badge: state.notificationsEnabled ? null : '!',
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return _buildIconButton(
      icon: Icons.chat_bubble_outline_rounded,
      onPressed: () => _showChatDialog(context),
      tooltip: 'Открыть чат',
      color: Colors.blue,
      badge: state.chatMessages.isNotEmpty ? state.chatMessages.length.toString() : null,
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return _buildIconButton(
      icon: Icons.share_rounded,
      onPressed: () => _shareChannel(context),
      tooltip: 'Поделиться каналом',
      color: Colors.green,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
    bool isActive = false,
    String? badge,
  }) {
    return Stack(
      children: [
        AnimatedContainer(
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
        ),

        // Бейдж для уведомлений
        if (badge != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _toggleSubscription(ChannelStateProvider stateProvider, BuildContext context) {
    final channelId = channel.id.toString();

    // Переключаем подписку через ChannelStateProvider
    stateProvider.toggleSubscription(channelId, channel.subscribers);

    // Также обновляем локальное состояние в ChannelDetailProvider
    provider.toggleSubscription();

    // Показываем уведомление
    final isSubscribed = stateProvider.isSubscribed(channelId);
    final message = isSubscribed
        ? '✅ Подписались на канал "${channel.title}"'
        : '❌ Отписались от канала "${channel.title}"';

    // Показываем уведомление через ScaffoldMessenger
    _showSubscriptionNotification(message, context);
  }

  void _showSubscriptionNotification(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChatDialog(
        channel: channel,
        messages: state.chatMessages,
        onSendMessage: (message) {
          // Добавляем сообщение в чат
          provider.addChatMessage(message);

          // Показываем уведомление об отправке
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Сообщение отправлено в чат ${channel.title}'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _shareChannel(BuildContext context) async {
    try {
      final shareText = '''
🎉 ${channel.title}

${channel.description}

📊 ${_formatNumber(channel.subscribers)} подписчиков
⭐ Рейтинг: ${channel.rating}/5
🎥 ${channel.videos} публикаций

Присоединяйтесь к каналу! 🚀
''';

      // Имитация шаринга
      await Future.delayed(const Duration(milliseconds: 300));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Поделиться каналом: ${channel.title}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Скопировать',
            onPressed: () {
              // Копирование текста в буфер обмена
              _copyToClipboard(shareText, context);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ошибка при попытке поделиться'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyToClipboard(String text, BuildContext context) {
    // Имитация копирования в буфер обмена
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Текст скопирован в буфер обмена'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}