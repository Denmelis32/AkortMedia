import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../rooms_pages/models/room.dart';
import '../../models/chat_member.dart';

class ChatAppBar extends StatelessWidget {
  final Room room;
  final ThemeData theme;
  final List<ChatMember> onlineMembers;
  final List<String> pinnedMessages;
  final bool isSearchMode;
  final bool isDarkMode;
  final bool isIncognitoMode;
  final VoidCallback onBack;
  final VoidCallback onToggleSearch;
  final VoidCallback onTogglePinnedMessages;
  final VoidCallback onToggleMembers;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleIncognito;
  final VoidCallback onShowRoomInfo;
  final VoidCallback onShowRoomSettings;
  final VoidCallback onInviteUsers;

  const ChatAppBar({
    super.key,
    required this.room,
    required this.theme,
    required this.onlineMembers,
    required this.pinnedMessages,
    required this.isSearchMode,
    required this.isDarkMode,
    required this.isIncognitoMode,
    required this.onBack,
    required this.onToggleSearch,
    required this.onTogglePinnedMessages,
    required this.onToggleMembers,
    required this.onToggleTheme,
    required this.onToggleIncognito,
    required this.onShowRoomInfo,
    required this.onShowRoomSettings,
    required this.onInviteUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Back button
            _buildBackButton(),
            const SizedBox(width: 12),

            // Room info
            Expanded(
              child: GestureDetector(
                onTap: onShowRoomInfo,
                child: _buildRoomInfo(),
              ),
            ),

            const SizedBox(width: 12),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.primaryColor),
        onPressed: onBack,
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Row(
      children: [
        // Room avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                room.category.color,
                room.category.color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: room.category.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            room.category.icon,
            color: Colors.white,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (room.isVerified) _buildVerifiedBadge(),
                ],
              ),
              const SizedBox(height: 2),
              _buildOnlineIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'Проверено',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: room.isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: room.isActive ? Colors.green.withOpacity(0.5) : Colors.transparent,
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${room.isActive ? '${onlineMembers.length} онлайн' : 'Неактивна'} • ${_formatParticipantCount(room.currentParticipants)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Search button
        _buildActionButton(
          icon: Icons.search,
          onPressed: onToggleSearch,
          tooltip: 'Поиск',
        ),

        const SizedBox(width: 8),

        // Pinned messages button
        if (pinnedMessages.isNotEmpty)
          _buildActionButton(
            icon: Icons.push_pin,
            onPressed: onTogglePinnedMessages,
            tooltip: 'Закрепленные сообщения',
            badge: pinnedMessages.length.toString(),
            badgeColor: Colors.orange,
          ),

        const SizedBox(width: 8),

        // Members button
        _buildActionButton(
          icon: Icons.people_alt_outlined,
          onPressed: onToggleMembers,
          tooltip: 'Участники',
          badge: onlineMembers.length.toString(),
          badgeColor: Colors.green,
        ),

        const SizedBox(width: 8),

        // More options menu
        _buildMoreMenu(),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: badge != null
            ? Badge(
          label: Text(badge),
          smallSize: 16,
          backgroundColor: badgeColor ?? theme.primaryColor,
          child: Icon(icon, color: theme.primaryColor),
        )
            : Icon(icon, color: theme.primaryColor),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildMoreMenu() {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: theme.primaryColor),
        onSelected: (value) => _handleAppBarAction(value),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'info',
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.primaryColor),
                const SizedBox(width: 8),
                const Text('Информация о комнате'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'members',
            child: Row(
              children: [
                Icon(Icons.people, color: theme.primaryColor),
                const SizedBox(width: 8),
                const Text('Участники'),
              ],
            ),
          ),
          if (pinnedMessages.isNotEmpty)
            PopupMenuItem(
              value: 'pinned',
              child: Row(
                children: [
                  Icon(Icons.push_pin, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Закрепленные сообщения'),
                ],
              ),
            ),
          PopupMenuItem(
            value: 'search',
            child: Row(
              children: [
                Icon(Icons.search, color: theme.primaryColor),
                const SizedBox(width: 8),
                const Text('Поиск по сообщениям'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'theme',
            child: Row(
              children: [
                Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(isDarkMode ? 'Светлая тема' : 'Темная тема'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'incognito',
            child: Row(
              children: [
                Icon(isIncognitoMode ? Icons.visibility_off : Icons.visibility, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(isIncognitoMode ? 'Выключить инкогнито' : 'Режим инкогнито'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, color: theme.primaryColor),
                const SizedBox(width: 8),
                const Text('Поделиться'),
              ],
            ),
          ),
          if (room.canEdit('current_user_id'))
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Настройки комнаты'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleAppBarAction(String value) {
    switch (value) {
      case 'info':
        onShowRoomInfo();
        break;
      case 'members':
        onToggleMembers();
        break;
      case 'share':
        onInviteUsers();
        break;
      case 'settings':
        onShowRoomSettings();
        break;
      case 'search':
        onToggleSearch();
        break;
      case 'pinned':
        onTogglePinnedMessages();
        break;
      case 'theme':
        onToggleTheme();
        break;
      case 'incognito':
        onToggleIncognito();
        break;
    }
  }

  String _formatParticipantCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}