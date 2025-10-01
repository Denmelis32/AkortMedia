import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../../../providers/user_provider.dart';
import '../widgets/room_preview_dialog.dart';

class RoomDialogs {
  void showPasswordDialog(BuildContext context, Room room, UserProvider userProvider) {
    final passwordController = TextEditingController();
    final userId = userProvider.userId;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Text('Защищённая комната'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Эта комната защищена паролем. Введите пароль для входа:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.password_rounded),
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility_rounded),
                  onPressed: () {
                    // TODO: Toggle password visibility
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (room.hasAccess(userId, inputPassword: passwordController.text)) {
                Navigator.pop(context);
                // Навигация будет обработана в RoomNavigation
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Неверный пароль'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }

  void showAccessDeniedDialog(BuildContext context, Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.private_connectivity_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Text('Приватная комната'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Эта комната является приватной. Для получения доступа необходимо:'),
            const SizedBox(height: 12),
            _buildAccessItem('Быть приглашённым создателем комнаты'),
            _buildAccessItem('Иметь специальную ссылку-приглашение'),
            _buildAccessItem('Получить разрешение от модератора'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              showRoomPreview(context, room);
            },
            child: const Text('Посмотреть информацию'),
          ),
        ],
      ),
    );
  }

  void showRoomFullDialog(BuildContext context, Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people_alt_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text('Комната заполнена'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text('В комнате достигнут лимит участников (${room.maxParticipants}).'),
            const SizedBox(height: 8),
            const Text('Попробуйте зайти позже или найдите другую комнату.'),
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

  void showScheduledRoomDialog(BuildContext context, Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Text('Комната запланирована'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text('Комната начнётся ${room.formattedStartTime}.'),
            const SizedBox(height: 8),
            const Text('Вы можете установить напоминание или подождать начала.'),
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

  void showEditRoomDialog(BuildContext context, Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Редактировать комнату',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${room.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Функция редактирования находится в разработке.'),
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

  void showRoomPreview(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => RoomPreviewDialog(
        room: room,
        onJoin: () {
          // Навигация будет обработана в RoomNavigation
        },
      ),
    );
  }

  void showRoomParticipantsDialog(BuildContext context, Room room) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people_rounded, color: theme.primaryColor),
            const SizedBox(width: 12),
            Text('Участники комнаты'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"${room.title}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: theme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${room.currentParticipants} из ${room.maxParticipants} участников',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  void showReportRoomDialog(BuildContext context, Room room) {
    // Реализация диалога жалобы
    // (можно вынести в отдельный файл если сложный)
  }

  Widget _buildAccessItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}