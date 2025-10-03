// models/community.dart
import 'package:flutter/material.dart';

import '../../rooms_pages/models/room.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final int memberCount;
  final int onlineCount;
  final List<String> tags;
  final bool isUserMember;
  final bool isPrivate;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final List<Room> rooms;
  final String? rules;
  final String? welcomeMessage;
  final List<String> moderators;
  final int roomCount;
  final CommunityStats stats;
  final CommunitySettings settings;
  final List<CommunityEvent> events;
  final String? bannerImageUrl;
  final CommunityLevel level;
  final bool isVerified;
  final List<String> featuredTags;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.memberCount,
    required this.onlineCount,
    required this.tags,
    required this.isUserMember,
    required this.isPrivate,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.rooms,
    this.rules,
    this.welcomeMessage,
    this.moderators = const [],
    this.roomCount = 0,
    required this.stats,
    required this.settings,
    this.events = const [],
    this.bannerImageUrl,
    this.level = CommunityLevel.beginner,
    this.isVerified = false,
    this.featuredTags = const [],
  });

  // Геттеры
  bool get isOwner => creatorId == 'current_user_id';
  bool get isModerator => moderators.contains('current_user_id');
  bool get canManage => isOwner || isModerator;
  bool get hasBanner => bannerImageUrl != null && bannerImageUrl!.isNotEmpty;
  bool get hasEvents => events.isNotEmpty;
  bool get isPopular => memberCount > 1000;
  bool get isActive => stats.dailyActiveUsers > 50;
  bool get isGrowing => stats.weeklyGrowth > 0.1;

  String get formattedMemberCount {
    if (memberCount >= 1000000) {
      return '${(memberCount / 1000000).toStringAsFixed(1)}M';
    } else if (memberCount >= 1000) {
      return '${(memberCount / 1000).toStringAsFixed(1)}K';
    }
    return memberCount.toString();
  }

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 1) return 'Сегодня';
    if (difference.inDays < 7) return '${difference.inDays}д назад';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}н назад';
    return '${(difference.inDays / 30).floor()}мес назад';
  }

  Color get levelColor {
    switch (level) {
      case CommunityLevel.beginner:
        return Colors.blue;
      case CommunityLevel.intermediate:
        return Colors.green;
      case CommunityLevel.advanced:
        return Colors.orange;
      case CommunityLevel.expert:
        return Colors.purple;
      case CommunityLevel.legendary:
        return Colors.red;
    }
  }

  String get levelName {
    switch (level) {
      case CommunityLevel.beginner:
        return 'Начинающий';
      case CommunityLevel.intermediate:
        return 'Развивающийся';
      case CommunityLevel.advanced:
        return 'Популярный';
      case CommunityLevel.expert:
        return 'Эксперт';
      case CommunityLevel.legendary:
        return 'Легендарный';
    }
  }

  Widget buildCommunityHeader({required BuildContext context, bool showStats = true}) {
    return Column(
      children: [
        if (hasBanner)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(bannerImageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              getCommunityIcon(size: 80),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified)
                          const Icon(Icons.verified_rounded, color: Colors.blue, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showStats) ...[
                      const SizedBox(height: 8),
                      _buildCommunityStats(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityStats(BuildContext context) {
    return Row(
      children: [
        _buildStatChip(
          icon: Icons.people_rounded,
          value: formattedMemberCount,
          context: context,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.online_prediction_rounded,
          value: onlineCount.toString(),
          context: context,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.trending_up_rounded,
          value: '${(stats.weeklyGrowth * 100).toStringAsFixed(1)}%',
          context: context,
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget getCommunityIcon({double size = 50}) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor().withOpacity(0.8),
            _getCategoryColor().withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getCategoryIcon(),
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'технологии':
        return Colors.blue;
      case 'игры':
        return Colors.purple;
      case 'социальное':
        return Colors.green;
      case 'путешествия':
        return Colors.orange;
      case 'образование':
        return Colors.teal;
      case 'бизнес':
        return Colors.indigo;
      case 'искусство':
        return Colors.pink;
      case 'музыка':
        return Colors.deepPurple;
      case 'наука':
        return Colors.blueGrey;
      case 'спорт':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'технологии':
        return Icons.smartphone_rounded;
      case 'игры':
        return Icons.sports_esports_rounded;
      case 'социальное':
        return Icons.people_alt_rounded;
      case 'путешествия':
        return Icons.travel_explore_rounded;
      case 'образование':
        return Icons.school_rounded;
      case 'бизнес':
        return Icons.business_center_rounded;
      case 'искусство':
        return Icons.palette_rounded;
      case 'музыка':
        return Icons.music_note_rounded;
      case 'наука':
        return Icons.science_rounded;
      case 'спорт':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.room_rounded;
    }
  }

  List<Widget> buildBadges({bool compact = false}) {
    final badges = <Widget>[];

    if (isVerified) {
      badges.add(_buildBadge('Проверено', Icons.verified_rounded, Colors.blue, compact));
    }
    if (isPopular) {
      badges.add(_buildBadge('Популярное', Icons.trending_up_rounded, Colors.orange, compact));
    }
    if (isActive) {
      badges.add(_buildBadge('Активное', Icons.flash_on_rounded, Colors.green, compact));
    }
    if (isGrowing) {
      badges.add(_buildBadge('Растущее', Icons.arrow_upward_rounded, Colors.purple, compact));
    }
    if (level != CommunityLevel.beginner) {
      badges.add(_buildBadge(levelName, Icons.star_rounded, levelColor, compact));
    }

    return badges;
  }

  Widget _buildBadge(String text, IconData icon, Color color, bool compact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          if (!compact) ...[
            const SizedBox(width: 2),
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Новые классы для расширенной функциональности
class CommunityStats {
  final int totalMessages;
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final double weeklyGrowth;
  final int newMembersThisWeek;
  final int roomsCreated;
  final int eventsHosted;

  const CommunityStats({
    this.totalMessages = 0,
    this.dailyActiveUsers = 0,
    this.weeklyActiveUsers = 0,
    this.weeklyGrowth = 0.0,
    this.newMembersThisWeek = 0,
    this.roomsCreated = 0,
    this.eventsHosted = 0,
  });
}

class CommunitySettings {
  final bool allowUserRooms;
  final bool requireApproval;
  final bool enableModeration;
  final bool enableEvents;
  final bool showOnlineMembers;
  final bool allowFileSharing;
  final int maxRoomSize;
  final List<String> bannedWords;

  const CommunitySettings({
    this.allowUserRooms = true,
    this.requireApproval = false,
    this.enableModeration = true,
    this.enableEvents = true,
    this.showOnlineMembers = true,
    this.allowFileSharing = true,
    this.maxRoomSize = 100,
    this.bannedWords = const [],
  });
}

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final List<String> hosts;
  final int participants;
  final bool isOnline;
  final String? location;
  final String? imageUrl;

  const CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.hosts = const [],
    this.participants = 0,
    this.isOnline = true,
    this.location,
    this.imageUrl,
  });

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isActive => startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());
  bool get isFinished => endTime.isBefore(DateTime.now());
}

enum CommunityLevel {
  beginner,
  intermediate,
  advanced,
  expert,
  legendary,
}