import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/chat_member.dart';
import '../../models/enums.dart';

class MembersPanel extends StatelessWidget {
  final ThemeData theme;
  final List<ChatMember> onlineMembers;
  final VoidCallback onClose;

  const MembersPanel({
    super.key,
    required this.theme,
    required this.onlineMembers,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Участники онлайн',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: onlineMembers.length,
              itemBuilder: (context, index) {
                final member = onlineMembers[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: CachedNetworkImageProvider(member.avatar),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.surface, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        member.name.split(' ')[0],
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRoleText(member.role),
                          style: TextStyle(
                            color: _getRoleColor(member.role),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return Colors.red;
      case MemberRole.moderator:
        return Colors.blue;
      case MemberRole.member:
        return Colors.green;
    }
  }

  String _getRoleText(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return 'Админ';
      case MemberRole.moderator:
        return 'Модератор';
      case MemberRole.member:
        return 'Участник';
    }
  }
}