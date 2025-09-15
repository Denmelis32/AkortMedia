// lib/pages/cards_page/cards_page.dart
import 'package:flutter/material.dart';
import 'models/channel.dart';
import 'channel_detail_page.dart';

class CardsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const CardsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final List<Channel> _channels = [
    Channel(
      id: '1',
      title: 'Технологии будущего',
      description: 'Обсуждаем новейшие технологии и инновации',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
      subscribers: 12450,
      videos: 89,
      isSubscribed: true,
      cardColor: Colors.blue.shade800,
    ),
    Channel(
      id: '2',
      title: 'Искусственный интеллект',
      description: 'Все о машинном обучении и нейросетях',
      imageUrl: 'https://images.unsplash.com/photo-1677442135135-416f8aa26a5b?w=400',
      subscribers: 8920,
      videos: 67,
      cardColor: Colors.purple.shade700,
    ),
    Channel(
      id: '3',
      title: 'Киберспорт',
      description: 'Турниры, стратегии и новости киберспорта',
      imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400',
      subscribers: 15680,
      videos: 112,
      isSubscribed: true,
      cardColor: Colors.red.shade800,
    ),
    Channel(
      id: '4',
      title: 'Дизайн интерфейсов',
      description: 'UI/UX дизайн и лучшие практики',
      imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400',
      subscribers: 7430,
      videos: 54,
      cardColor: Colors.teal.shade700,
    ),
    Channel(
      id: '5',
      title: 'Мобильная разработка',
      description: 'Flutter, React Native и нативные технологии',
      imageUrl: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
      subscribers: 10320,
      videos: 78,
      cardColor: Colors.orange.shade800,
    ),
    Channel(
      id: '6',
      title: 'Игровая индустрия',
      description: 'Новости игр и разработка геймдева',
      imageUrl: 'https://images.unsplash.com/photo-1542751110-97427bbecf20?w=400',
      subscribers: 18900,
      videos: 95,
      cardColor: Colors.green.shade800,
    ),
  ];

  void _createNewChannel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать новый канал'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название канала',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Канал создан!')),
              );
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _toggleSubscription(int index) {
    setState(() {
      _channels[index] = _channels[index].copyWith(
        isSubscribed: !_channels[index].isSubscribed,
        subscribers: _channels[index].isSubscribed
            ? _channels[index].subscribers - 1
            : _channels[index].subscribers + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каналы'),
        backgroundColor: const Color(0xFF396AA3),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewChannel,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _channels.length,
          itemBuilder: (context, index) {
            final channel = _channels[index];
            return _buildChannelCard(channel, index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChannel,
        backgroundColor: const Color(0xFF396AA3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildChannelCard(Channel channel, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChannelDetailPage(channel: channel),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                channel.cardColor,
                channel.cardColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    '${channel.subscribers} подписчиков',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(channel.imageUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      channel.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      channel.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.video_library,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${channel.videos} видео',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _toggleSubscription(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: channel.isSubscribed
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white,
                        foregroundColor: channel.isSubscribed
                            ? Colors.white
                            : const Color(0xFF396AA3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 36),
                      ),
                      child: Text(
                        channel.isSubscribed ? 'Отписаться' : 'Подписаться',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}