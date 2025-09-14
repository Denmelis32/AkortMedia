import 'package:flutter/material.dart';
import 'package:my_app/services/channel_service.dart';

import '../models_room/channel.dart';
import '../models_room/user_permissions.dart';

class ChannelMembersSection extends StatelessWidget {
  final Channel channel;
  final UserPermissions userPermissions;

  const ChannelMembersSection({
    super.key,
    required this.channel,
    required this.userPermissions,
  });

  void _showMemberDetails(BuildContext context, String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(memberName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $memberId'),
            Text('Участник канала: ${channel.name}'),
            const SizedBox(height: 16),
            if (memberId == channel.ownerId)
              const Text('👑 Владелец канала', style: TextStyle(color: Colors.amber)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = ChannelService.getChannelMembers(channel);
    final currentUserIsOwner = channel.ownerId == userPermissions.userId;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Участники (${members.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isOwner = member['id'] == channel.ownerId;
                final isCurrentUser = member['id'] == userPermissions.userId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(member['avatarUrl'] ??
                          'https://ui-avatars.com/api/?name=${member['name']}&background=007AFF'),
                    ),
                    title: Row(
                      children: [
                        Text(member['name']),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, size: 16, color: Colors.amber),
                        ]
                      ],
                    ),
                    subtitle: Text(isOwner ? 'Владелец канала' : 'Участник'),
                    trailing: isCurrentUser
                        ? const Chip(label: Text('Вы'), backgroundColor: Colors.blue)
                        : null,
                    onTap: () => _showMemberDetails(context, member['id'], member['name']),
                  ),
                );
              },
            ),
          ),
          if (currentUserIsOwner) ...[
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Управление участниками:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Пригласить'),
                  onPressed: () => _showInviteDialog(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Модерация'),
                  onPressed: () => _showModerationTools(context),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пригласить в канал'),
        content: const Text('Отправить приглашение по email или ссылке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Приглашение отправлено')),
              );
            },
            child: const Text('Пригласить'),
          ),
        ],
      ),
    );
  }

  void _showModerationTools(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Инструменты модерации'),
        content: const Text('Управление участниками и разрешениями'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  static List<Map<String, dynamic>> getChannelMembers(Channel channel) {
    final members = <Map<String, dynamic>>[];

    // Владелец
    members.add({
      'id': channel.ownerId,
      'name': channel.ownerName,
      'avatarUrl': channel.ownerAvatarUrl,
      'role': 'owner',
      'joinedAt': channel.createdAt,
    });

    // Подписчики (если есть реальные данные)
    if (channel.subscriberIds.isNotEmpty) {
      for (final subscriberId in channel.subscriberIds) {
        // Здесь должен быть запрос к базе для получения данных пользователя
        // Пока используем демо-данные
        members.add({
          'id': subscriberId,
          'name': 'Пользователь ${subscriberId.substring(0, 4)}',
          'avatarUrl': 'https://ui-avatars.com/api/?name=User&background=007AFF',
          'role': 'subscriber',
          'joinedAt': DateTime.now().subtract(const Duration(days: 10)),
        });
      }
    } else {
      // Демо-данные если нет реальных подписчиков
      for (int i = 0; i < channel.subscribersCount.clamp(0, 5); i++) {
        members.add({
          'id': 'demo_user_$i',
          'name': 'Подписчик ${i + 1}',
          'avatarUrl': 'https://ui-avatars.com/api/?name=User$i&background=random',
          'role': 'subscriber',
          'joinedAt': DateTime.now().subtract(Duration(days: (i + 1) * 5)),
        });
      }
    }

    return members;
  }







}