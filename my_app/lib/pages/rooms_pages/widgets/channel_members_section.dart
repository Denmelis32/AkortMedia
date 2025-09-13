import 'package:flutter/material.dart';
import '../models_room/channel.dart';
import '../models_room/user_permissions.dart';

class ChannelMembersSection extends StatelessWidget {
  final Channel channel;
  final UserPermissions userPermissions;
  final BuildContext parentContext; // Добавляем контекст как параметр

  const ChannelMembersSection({
    super.key,
    required this.channel,
    required this.userPermissions,
    required this.parentContext, // Получаем контекст извне
  });

  // Заглушка для демонстрации - в реальном приложении брать из базы
  final List<Map<String, dynamic>> _demoMembers = const [
    {
      'id': 'user1',
      'name': 'Иван Иванов',
      'avatar': 'https://ui-avatars.com/api/?name=II&background=007AFF',
      'role': 'Владелец',
      'isOnline': true,
    },
    {
      'id': 'user2',
      'name': 'Мария Петрова',
      'avatar': 'https://ui-avatars.com/api/?name=MP&background=FF2D55',
      'role': 'Модератор',
      'isOnline': true,
    },
    {
      'id': 'user3',
      'name': 'Алексей Смирнов',
      'avatar': 'https://ui-avatars.com/api/?name=AS&background=34C759',
      'role': 'Участник',
      'isOnline': false,
    },
    {
      'id': 'user4',
      'name': 'Елена Козлова',
      'avatar': 'https://ui-avatars.com/api/?name=EK&background=FF9500',
      'role': 'Участник',
      'isOnline': true,
    },
    {
      'id': 'user5',
      'name': 'Дмитрий Волков',
      'avatar': 'https://ui-avatars.com/api/?name=DV&background=AF52DE',
      'role': 'Участник',
      'isOnline': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Участники канала (${_demoMembers.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Поиск участников
          TextField(
            decoration: InputDecoration(
              hintText: 'Поиск участников...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Список участников
          Expanded(
            child: ListView.builder(
              itemCount: _demoMembers.length,
              itemBuilder: (context, index) {
                final member = _demoMembers[index];
                return _buildMemberCard(context, member);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(member['avatar']),
              radius: 20,
            ),
            if (member['isOnline'])
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(member['name']),
        subtitle: Text(member['role']),
        trailing: member['role'] == 'Участник' && channel.ownerId == userPermissions.userId
            ? IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMemberActions(context, member),
        )
            : null,
        onTap: () => _showMemberProfile(context, member),
      ),
    );
  }

  void _showMemberActions(BuildContext context, Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Назначить модератором'),
            onTap: () {
              Navigator.pop(context);
              _promoteToModerator(context, member);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Заблокировать'),
            onTap: () {
              Navigator.pop(context);
              _blockMember(context, member);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Отмена'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showMemberProfile(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(member['avatar']),
                radius: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text('Роль: ${member['role']}'),
            Text('Статус: ${member['isOnline'] ? 'Online' : 'Offline'}'),
            const SizedBox(height: 8),
            const Text('Последняя активность: 2 часа назад'),
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

  void _promoteToModerator(BuildContext context, Map<String, dynamic> member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${member['name']} повышен до модератора')),
    );
  }

  void _blockMember(BuildContext context, Map<String, dynamic> member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${member['name']} заблокирован')),
    );
  }
}