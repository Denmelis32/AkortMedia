import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../chat/chat_page.dart';
import '../widgets/bottom_sheets/advanced_filters_bottom_sheet.dart';
import '../widgets/bottom_sheets/create_room_bottom_sheet.dart';
import '../models/room.dart';
import '../../../providers/room_provider.dart';
import '../../../providers/user_provider.dart';
import '../widgets/dialogs/notifications_dialog.dart';
import '../widgets/dialogs/quick_actions_dialog.dart' show QuickActionsDialog;
import '../widgets/dialogs/room_quick_actions_dialog.dart';
import '../widgets/dialogs/sort_dialog.dart';
import '../widgets/dialogs/room_stats_dialog.dart';
import 'room_dialogs.dart';

class RoomNavigation {
  final RoomDialogs _dialogs = RoomDialogs();

  void openChatPage({
    required BuildContext context,
    required Room room,
    required String userName,
  }) {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId;

    // Проверки доступа к комнате
    if (room.requiresPassword) {
      _dialogs.showPasswordDialog(context, room, userProvider);
      return;
    }

    if (room.accessLevel == RoomAccessLevel.private && !room.hasAccess(userId)) {
      _dialogs.showAccessDeniedDialog(context, room);
      return;
    }

    if (room.isFull) {
      _dialogs.showRoomFullDialog(context, room);
      return;
    }

    if (room.isScheduled && !room.isExpired) {
      _dialogs.showScheduledRoomDialog(context, room);
      return;
    }

    // Навигация в чат
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          room: room,
          userName: userName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
  void createNewRoom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateRoomBottomSheet(
        onRoomCreated: (newRoom) => _onRoomCreated(context, newRoom),
      ),
    );
  }

  void _onRoomCreated(BuildContext context, Room newRoom) {
    // Показываем уведомление о успешном создании
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Комната "${newRoom.title}" создана! 🎉'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Открыть',
          textColor: Colors.white,
          onPressed: () {
            // Открываем созданную комнату
            final userProvider = context.read<UserProvider>();
            openChatPage(
              context: context,
              room: newRoom,
              userName: userProvider.userName,
            );
          },
        ),
      ),
    );

    // Дополнительное обновление через 2 секунды для синхронизации
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.read<RoomProvider>().loadRooms();
      }
    });
  }

  void showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersBottomSheet(
        onFiltersApplied: () {
          if (context.mounted) {
            // Фильтры применены, можно обновить состояние
          }
        },
      ),
    );
  }

  void showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortDialog(
        currentSortBy: context.read<RoomProvider>().sortBy,
        onSortChanged: (sortBy) {
          context.read<RoomProvider>().setSortBy(sortBy);
        },
      ),
    );
  }

  void showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsDialog(
        onCreateRoom: () => createNewRoom(context),
        onShowFilters: () => showAdvancedFilters(context),
        onShowSort: () => showSortDialog(context),
        onShowStats: () => showStatsDialog(context),
        onShowNotifications: () => showNotificationsDialog(context),
        onRefreshRooms: () => _refreshRooms(context),
      ),
    );
  }

  void showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationsDialog(),
    );
  }

  void showStatsDialog(BuildContext context) {
    final roomProvider = context.read<RoomProvider>();
    final stats = roomProvider.getRoomStats();

    showDialog(
      context: context,
      builder: (context) => RoomStatsDialog(stats: stats),
    );
  }

  void showRoomQuickActions(BuildContext context, Room room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomQuickActionsDialog(
        room: room,
        userId: context.read<UserProvider>().userId,
        onShowInfo: () => _dialogs.showRoomPreview(context, room),
        onCopyLink: () => _copyRoomLink(context, room),
        onEditRoom: () => _editRoom(context, room),
        onPinRoom: () => _pinRoom(context, room),
        onSetReminder: () => _setRoomReminder(context, room),
        onShareRoom: () => _shareRoom(context, room),
        onShowParticipants: () => _showRoomParticipants(context, room),
        onReportRoom: () => _reportRoom(context, room),
      ),
    );
  }

  Future<void> _refreshRooms(BuildContext context) async {
    final roomProvider = context.read<RoomProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Обновление комнат...'),
        duration: Duration(seconds: 2),
      ),
    );

    await roomProvider.loadRooms();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Обновлено ${roomProvider.filteredRooms.length} комнат'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyRoomLink(BuildContext context, Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на "${room.title}" скопирована в буфер обмена'),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _editRoom(BuildContext context, Room room) {
    _dialogs.showEditRoomDialog(context, room);
  }

  void _pinRoom(BuildContext context, Room room) {
    final roomProvider = context.read<RoomProvider>();
    roomProvider.togglePinRoom(room.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(room.isPinned
            ? 'Комната "${room.title}" закреплена'
            : 'Комната "${room.title}" откреплена'),
        backgroundColor: room.isPinned ? Colors.green : Colors.blue,
      ),
    );
  }

  void _setRoomReminder(BuildContext context, Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Напоминание для "${room.title}" установлено'),
      ),
    );
  }

  void _shareRoom(BuildContext context, Room room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на "${room.title}" скопирована в буфер обмена'),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showRoomParticipants(BuildContext context, Room room) {
    _dialogs.showRoomParticipantsDialog(context, room);
  }

  void _reportRoom(BuildContext context, Room room) {
    _dialogs.showReportRoomDialog(context, room);
  }
}