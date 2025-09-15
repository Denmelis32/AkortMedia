import 'package:flutter/material.dart';
import '../models_room/channel.dart';

class ChannelAboutSection extends StatelessWidget {
  final Channel channel;
  final VoidCallback onSubscribe;
  final bool isSubscribed;

  const ChannelAboutSection({
    super.key,
    required this.channel,
    required this.onSubscribe,
    required this.isSubscribed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Описание канала
          _buildSectionTitle('Описание канала'),
          const SizedBox(height: 8),
          Text(
            channel.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),

          // Теги
          _buildSectionTitle('Теги'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: channel.tags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.blue[50],
            )).toList(),
          ),
          const SizedBox(height: 24),

          // Статистика
          _buildSectionTitle('Статистика'),
          const SizedBox(height: 8),
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Информация о создателе
          _buildSectionTitle('Создатель канала'),
          const SizedBox(height: 8),
          _buildOwnerInfo(),
          const SizedBox(height: 24),

          // Действия
          _buildSectionTitle('Действия'),
          const SizedBox(height: 8),
          _buildActionButtons(context),
          const SizedBox(height: 24),

          // Дополнительная информация
          _buildSectionTitle('Информация'),
          const SizedBox(height: 8),
          _buildInfoList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      children: [
        _buildStatItem('${channel.subscribersCount}', 'Подписчики', Icons.people),
        _buildStatItem('${channel.recentTopicIds.length}', 'Темы', Icons.forum),
        _buildStatItem('125', 'Сообщения', Icons.message),
        _buildStatItem('2', 'Модераторы', Icons.shield),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfo() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(channel.ownerAvatarUrl),
      ),
      title: Text(channel.ownerName),
      subtitle: const Text('Владелец канала'),
      trailing: IconButton(
        icon: const Icon(Icons.message),
        onPressed: () {}, // Убрали вызов _messageOwner
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: onSubscribe,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSubscribed ? Colors.grey[300] : Colors.blue,
            foregroundColor: isSubscribed ? Colors.grey[700] : Colors.white,
          ),
          child: Text(isSubscribed ? 'Отписаться' : 'Подписаться'),
        ),
        OutlinedButton(
          onPressed: () => _shareChannel(context),
          child: const Text('Поделиться'),
        ),
        OutlinedButton(
          onPressed: () => _reportChannel(context),
          child: const Text('Пожаловаться'),
        ),
      ],
    );
  }

  Widget _buildInfoList() {
    return Column(
      children: [
        _buildInfoItem('Дата создания', _formatDate(channel.createdAt)),
        _buildInfoItem('Категория', _getCategoryName(channel.categoryId)),
        _buildInfoItem('Язык', 'Русский'),
        _buildInfoItem('Рейтинг', '4.8 ⭐'),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _getCategoryName(String categoryId) {
    final categories = {
      'youtube': 'YouTube',
      'sport': 'Спорт',
      'games': 'Игры',
      'programming': 'Программирование',
      'business': 'Бизнес',
      'communication': 'Общение',
      'self_development': 'Саморазвитие',
    };
    return categories[categoryId] ?? categoryId;
  }

  void _shareChannel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция分享 будет реализована позже')),
    );
  }

  void _reportChannel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на канал'),
        content: const Text('Выберите причину жалобы:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Жалоба отправлена')),
              );
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}