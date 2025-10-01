import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../../../providers/user_provider.dart';
import '../dialogs/user_profile_dialog.dart';

class RoomsAppBar extends StatelessWidget {
  final RoomProvider roomProvider;
  final UserProvider userProvider;
  final bool isSearchExpanded;
  final VoidCallback onLogout;
  final VoidCallback onStatsPressed;
  final VoidCallback onSortPressed;

  const RoomsAppBar({
    super.key,
    required this.roomProvider,
    required this.userProvider,
    required this.isSearchExpanded,
    required this.onLogout,
    required this.onStatsPressed,
    required this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, top: 16),
        expandedTitleScale: 1.1,
        title: AnimatedOpacity(
          opacity: isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: _buildTitle(theme, roomProvider),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.08),
                theme.colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        AnimatedOpacity(
          opacity: isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: onStatsPressed,
            tooltip: 'Статистика',
          ),
        ),
        AnimatedOpacity(
          opacity: isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: onSortPressed,
            tooltip: 'Сортировка',
          ),
        ),
        AnimatedOpacity(
          opacity: isSearchExpanded ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: _buildUserAvatar(theme, userProvider, context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme, RoomProvider roomProvider) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Обсуждения',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (roomProvider.filteredRooms.isNotEmpty)
                Text(
                  '${roomProvider.filteredRooms.length} активных комнат',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(ThemeData theme, UserProvider userProvider, BuildContext context) {
    return GestureDetector(
      onTap: () => _showUserProfile(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: theme.primaryColor,
          child: Text(
            userProvider.userName.isNotEmpty
                ? userProvider.userName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UserProfileDialog(onLogout: onLogout),
    );
  }
}