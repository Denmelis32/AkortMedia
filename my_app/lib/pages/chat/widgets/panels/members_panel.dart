import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../services/chat_service.dart';
import '../../models/chat_member.dart';
import '../../models/enums.dart';

class MembersPanel extends StatelessWidget {
  final ThemeData theme;
  final List<ChatMember> onlineMembers;
  final List<ChatMember> allMembers;
  final List<ChatBot> activeBots; // Добавлено: активные боты
  final VoidCallback onClose;

  const MembersPanel({
    super.key,
    required this.theme,
    required this.onlineMembers,
    required this.allMembers,
    required this.onClose,
    this.activeBots = const [], // Добавлено по умолчанию
  });

  @override
  Widget build(BuildContext context) {
    final totalOnline = onlineMembers.length + activeBots.length;

    return Container(
      height: 280, // Увеличили высоту для ботов
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Заголовок
          Row(
            children: [
              Text(
                'Активные участники',
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

          // Пользователи онлайн
          if (onlineMembers.isNotEmpty) ...[
            _buildSectionHeader('Пользователи онлайн (${onlineMembers.length})'),
            const SizedBox(height: 8),
            _buildMembersList(onlineMembers),
            const SizedBox(height: 16),
          ],

          // Активные боты
          if (activeBots.isNotEmpty) ...[
            _buildSectionHeader('Активные боты (${activeBots.length})'),
            const SizedBox(height: 8),
            _buildBotsList(activeBots),
            const SizedBox(height: 16),
          ],

          // Общая статистика
          _buildStatisticsFooter(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(List<ChatMember> members) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _buildMemberCard(member);
        },
      ),
    );
  }

  Widget _buildMemberCard(ChatMember member) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              // Аватар пользователя
              CircleAvatar(
                radius: 24,
                backgroundImage: member.avatar != null && member.avatar!.startsWith('http')
                    ? CachedNetworkImageProvider(member.avatar!)
                    : null,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: member.avatar == null || !member.avatar!.startsWith('http')
                    ? Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),

              // Индикатор онлайн
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Имя пользователя
          Text(
            member.name.split(' ')[0],
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Роль пользователя
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
  }

  Widget _buildBotsList(List<ChatBot> bots) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: bots.length,
        itemBuilder: (context, index) {
          final bot = bots[index];
          return _buildBotCard(bot);
        },
      ),
    );
  }

  Widget _buildBotCard(ChatBot bot) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              // Аватар бота
              CircleAvatar(
                radius: 24,
                backgroundColor: bot.color.withOpacity(0.1),
                child: Text(
                  bot.avatar,
                  style: const TextStyle(fontSize: 20),
                ),
              ),

              // Индикатор активности бота
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Имя бота
          Text(
            bot.name.split(' ')[0],
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: bot.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Тип бота
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: bot.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getBotType(bot.personality),
              style: TextStyle(
                color: bot.color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsFooter() {
    final totalMembers = allMembers.length;
    final totalOnlineMembers = onlineMembers.length;
    final totalBots = activeBots.length;
    final totalActive = totalOnlineMembers + totalBots;

    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Общая статистика
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Всего', '$totalMembers', Icons.people),
              _buildStatItem('Онлайн', '$totalOnlineMembers', Icons.circle, color: Colors.green),
              _buildStatItem('Боты', '$totalBots', Icons.smart_toy, color: Colors.purple),
            ],
          ),

          const SizedBox(height: 8),

          // Прогресс-бар активности
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Активность комнаты',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$totalActive/$totalMembers',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: totalMembers > 0 ? totalActive / totalMembers : 0,
                  backgroundColor: theme.colorScheme.background,
                  color: _getActivityColor(totalActive / totalMembers),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(double ratio) {
    if (ratio > 0.7) return Colors.green;
    if (ratio > 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getBotType(String personality) {
    switch (personality) {
      case 'analytical':
        return 'Аналитик';
      case 'funny':
        return 'Юморист';
      case 'professional':
        return 'Эксперт';
      case 'knowledgeable':
        return 'Историк';
      default:
        return 'Бот';
    }
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return Colors.red;
      case MemberRole.moderator:
        return Colors.blue;
      case MemberRole.member:
        return Colors.green;
      case MemberRole.guest:
        return Colors.grey;
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
      case MemberRole.guest:
        return 'Гость';
    }
  }
}