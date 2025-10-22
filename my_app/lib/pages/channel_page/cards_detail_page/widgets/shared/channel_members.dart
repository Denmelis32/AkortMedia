// lib/pages/cards_detail_page/widgets/channel_members.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/channel.dart';

class ChannelMembers extends StatelessWidget {
  final Channel channel;

  const ChannelMembers({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    // Заглушка данных участников
    final members = [
      _Member(name: 'Алексей Петров', role: 'Создатель', imageUrl: 'https://picsum.photos/200?1'),
      _Member(name: 'Мария Иванова', role: 'Модератор', imageUrl: 'https://picsum.photos/200?2'),
      _Member(name: 'Иван Сидоров', role: 'Модератор', imageUrl: 'https://picsum.photos/200?3'),
      _Member(name: 'Екатерина Волкова', role: 'Участник', imageUrl: 'https://picsum.photos/200?4'),
      _Member(name: 'Дмитрий Козлов', role: 'Участник', imageUrl: 'https://picsum.photos/200?5'),
    ];

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: channel.cardColor,
                      width: member.role == 'Создатель' ? 2 : 0,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: member.imageUrl,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role == 'Создатель' ? 'Создатель' : '',
                  style: TextStyle(
                    fontSize: 10,
                    color: channel.cardColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Member {
  final String name;
  final String role;
  final String imageUrl;

  _Member({required this.name, required this.role, required this.imageUrl});
}