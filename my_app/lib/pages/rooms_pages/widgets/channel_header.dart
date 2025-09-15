import 'package:flutter/material.dart';
import '../models_room/channel.dart';

class ChannelHeader extends StatelessWidget {
  final Channel channel;
  final bool isSubscribed;
  final VoidCallback onSubscribe;

  const ChannelHeader({
    super.key,
    required this.channel,
    required this.isSubscribed,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Баннер и аватар
          Stack(
            children: [
              // Баннер
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[100],
                  image: channel.bannerImageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(channel.bannerImageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: channel.bannerImageUrl == null
                    ? const Icon(Icons.people, size: 40, color: Colors.grey)
                    : null,
              ),

              // Аватар владельца
              Positioned(
                bottom: -20,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(channel.ownerAvatarUrl),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Информация о канале
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Создатель: ${channel.ownerName}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Кнопка подписки
              OutlinedButton(
                onPressed: onSubscribe,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSubscribed ? Colors.grey[100] : Colors.blue,
                  foregroundColor: isSubscribed ? Colors.grey[700] : Colors.white,
                ),
                child: Text(isSubscribed ? 'Вы подписаны' : 'Подписаться'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Статистика
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('${channel.subscribersCount}', 'Подписчики'),
              _buildStatItem('${channel.recentTopicIds.length}', 'Темы'),
              _buildStatItem('125', 'Сообщения'), // Заглушка
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}