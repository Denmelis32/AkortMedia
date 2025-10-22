import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/room_provider.dart';
import '../../../providers/user_provider.dart';
import '../../chat/chat_page.dart';

import '../models/room.dart';
import 'custom_image_cache.dart';

class RoomUtils {
  final CustomImageCache _imageCache = CustomImageCache();

  bool checkRoomAccess(BuildContext context, Room room) {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.userId ?? 'current_user';

    if (!room.hasAccess(currentUserId)) {
      _showAccessDialog(context, room);
      return false;
    }

    return true;
  }

  bool checkRoomAccessForJoin(BuildContext context, Room room) {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.userId ?? 'current_user';

    if (room.isPrivateRoom && !room.hasAccess(currentUserId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нельзя присоединиться к закрытой комнате без приглашения'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (room.isPasswordProtected && !room.hasAccess(currentUserId)) {
      _showPasswordDialogForJoin(context, room);
      return false;
    }

    return true;
  }

  void sortRooms(List<Room> rooms, String sortType) {
    switch (sortType) {
      case 'newest':
        rooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popular':
        rooms.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
      case 'participants':
        rooms.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
        break;
    }
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  ImageProvider getCachedImage(String url) {
    return _imageCache.getImage(url);
  }

  void _showAccessDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(room.accessTypeIcon, color: room.accessTypeColor),
            const SizedBox(width: 8),
            const Text('Доступ ограничен'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Комната "${room.title}" ${room.accessRequirements.toLowerCase()}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (room.isPasswordProtected)
              _buildPasswordInput(context, room),
            if (room.isPrivateRoom)
              Text(
                'Для доступа к этой комнате нужно получить приглашение от создателя.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          if (room.isPasswordProtected)
            ElevatedButton(
              onPressed: () => _joinWithPassword(context, room),
              child: const Text('Войти'),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(BuildContext context, Room room) {
    final passwordController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Введите пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (passwordController.text.isNotEmpty)
              ElevatedButton(
                onPressed: () => _joinWithPassword(context, room, passwordController.text),
                child: const Text('Проверить пароль'),
              ),
          ],
        );
      },
    );
  }

  void _showPasswordDialogForJoin(BuildContext context, Room room) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.password, color: Colors.blue),
            SizedBox(width: 8),
            Text('Введите пароль'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Для присоединения к комнате "${room.title}" требуется пароль'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
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
              final userProvider = context.read<UserProvider>();
              final currentUserId = userProvider.userId ?? 'current_user';

              if (room.hasAccess(currentUserId, inputPassword: passwordController.text)) {
                Navigator.pop(context);
                context.read<RoomProvider>().toggleJoinRoom(room.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Присоединились к комнате ${room.title}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Неверный пароль'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Присоединиться'),
          ),
        ],
      ),
    );
  }

  void _joinWithPassword(BuildContext context, Room room, [String? password]) {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.userId ?? 'current_user';

    if (room.hasAccess(currentUserId, inputPassword: password)) {
      Navigator.pop(context);
      _openChatPageDirectly(context, room);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверный пароль'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openChatPageDirectly(BuildContext context, Room room) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          roomId: room.id,
          roomName: room.title,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void dispose() {
    _imageCache.clear();
  }
}