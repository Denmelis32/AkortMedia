import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../chat/chat_page.dart';
import '../../communities/community_detail_page.dart';
import '../../communities/widgets/create_community_bottom_sheet.dart';
import '../widgets/bottom_sheets/advanced_filters_bottom_sheet.dart';
import '../widgets/bottom_sheets/create_room_bottom_sheet.dart';
import '../models/room.dart';
import '../../communities/models/community.dart';
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

  void createNewCommunity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateCommunityBottomSheet(
        onCommunityCreated: (newCommunity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Сообщество "${newCommunity.name}" создано! 🎉'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  void openCommunityDetail({
    required BuildContext context,
    required Community community,
    required int selectedTab,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailPage(
          community: community,
          initialTab: selectedTab,
        ),
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

    // Обновляем список комнат
    _refreshRooms(context);
  }

  void showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersBottomSheet(
        onFiltersApplied: () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Фильтры применены'),
                duration: const Duration(seconds: 2),
              ),
            );
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
          final roomProvider = context.read<RoomProvider>();
          roomProvider.setSortBy(sortBy);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Сортировка: ${sortBy.title}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
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
      builder: (context) => const NotificationsDialog(),
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
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomQuickActionsDialog(
        room: room,
        userId: userProvider.userId,
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

    // Показываем индикатор загрузки
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
    // TODO: Реализовать копирование ссылки в буфер обмена
    // Clipboard.setData(ClipboardData(text: 'room-link-${room.id}'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на "${room.title}" скопирована в буфер обмена'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editRoom(BuildContext context, Room room) {
    final userProvider = context.read<UserProvider>();

    if (room.canEdit(userProvider.userId)) {
      _dialogs.showEditRoomDialog(context, room);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('У вас нет прав для редактирования этой комнаты'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pinRoom(BuildContext context, Room room) {
    final roomProvider = context.read<RoomProvider>();
    final userProvider = context.read<UserProvider>();

    if (room.canPin(userProvider.userId)) {
      roomProvider.togglePinRoom(room.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(room.isPinned
              ? 'Комната "${room.title}" закреплена'
              : 'Комната "${room.title}" откреплена'),
          backgroundColor: room.isPinned ? Colors.green : Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('У вас нет прав для закрепления комнат'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setRoomReminder(BuildContext context, Room room) {
    // TODO: Реализовать установку напоминания
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Напоминание для "${room.title}" установлено'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareRoom(BuildContext context, Room room) {
    // TODO: Реализовать функционал шаринга
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Поделиться "${room.title}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRoomParticipants(BuildContext context, Room room) {
    _dialogs.showRoomParticipantsDialog(context, room);
  }

  void _reportRoom(BuildContext context, Room room) {
    _dialogs.showReportRoomDialog(context, room);
  }

  // Новый метод для проверки доступности комнаты
  bool canAccessRoom(Room room, String userId) {
    return room.isActive &&
        !room.isExpired &&
        !room.isFull &&
        room.hasAccess(userId) &&
        !room.requiresPassword;
  }

  // Новый метод для получения статуса комнаты
  String getRoomStatus(Room room) {
    if (!room.isActive) return 'Неактивна';
    if (room.isExpired) return 'Завершена';
    if (room.isFull) return 'Заполнена';
    if (room.isScheduled) return 'Запланирована';
    return 'Активна';
  }
}