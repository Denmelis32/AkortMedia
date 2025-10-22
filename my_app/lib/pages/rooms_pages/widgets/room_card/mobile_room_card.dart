import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../models/room.dart';
import '../../utils/layout_utils.dart';
import '../../utils/room_utils.dart';

class MobileRoomCard extends StatelessWidget {
  final Room room;
  final int index;
  final RoomProvider roomProvider;
  final LayoutUtils layoutUtils;
  final RoomUtils roomUtils;
  final VoidCallback onRoomTap;
  final VoidCallback onRoomJoinToggle;

  const MobileRoomCard({
    super.key,
    required this.room,
    required this.index,
    required this.roomProvider,
    required this.layoutUtils,
    required this.roomUtils,
    required this.onRoomTap,
    required this.onRoomJoinToggle,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = room.category.color;
    final categoryIcon = room.category.icon;
    final cardColor = layoutUtils.getCardColor(index);
    final borderColor = layoutUtils.getCardBorderColor(index);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onRoomTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCoverSection(room, categoryColor, categoryIcon, borderColor),
                _buildContentSection(room, roomProvider, borderColor, categoryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(Room room, Color categoryColor, IconData categoryIcon, Color borderColor) {
    return Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: _buildRoomCover(room),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  categoryIcon,
                  size: 14,
                  color: categoryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  room.category.title.toUpperCase(),
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (room.currentParticipants > 0)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.currentParticipants} онлайн',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        _buildAccessBadges(room),
      ],
    );
  }

  Widget _buildContentSection(Room room, RoomProvider roomProvider, Color borderColor, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildRoomAvatar(room),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: layoutUtils.textColor,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.creatorName.isNotEmpty ? room.creatorName : 'Создатель комнаты',
                      style: TextStyle(
                        fontSize: 13,
                        color: layoutUtils.textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            room.description,
            style: TextStyle(
              fontSize: 14,
              color: layoutUtils.textColor.withOpacity(0.8),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (room.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: room.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: borderColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      color: borderColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      roomUtils.formatNumber(room.currentParticipants),
                      'участников',
                      icon: Icons.people_outline,
                      color: borderColor,
                    ),
                    _buildStatItem(
                      room.messageCount.toString(),
                      'сообщений',
                      icon: Icons.chat_bubble_outline,
                      color: borderColor,
                    ),
                    _buildStatItem(
                      room.ratingCount.toString(),
                      'лайков',
                      icon: Icons.thumb_up,
                      color: borderColor,
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: room.isJoined
                      ? Colors.white.withOpacity(0.8)
                      : layoutUtils.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: room.isJoined
                        ? borderColor.withOpacity(0.5)
                        : layoutUtils.primaryColor,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  onPressed: onRoomJoinToggle,
                  icon: Icon(
                    room.isJoined ? Icons.check : Icons.add,
                    size: 18,
                    color: room.isJoined
                        ? borderColor
                        : Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {double fontSize = 12, Color? color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: color,
            ),
            const SizedBox(height: 2),
          ],
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color ?? layoutUtils.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (color ?? layoutUtils.textColor).withOpacity(0.7),
              fontSize: fontSize - 1,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessBadges(Room room) {
    final badges = <Widget>[];

    if (room.isPasswordProtected) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.password, size: 10, color: Colors.blue),
              const SizedBox(width: 2),
              Text(
                'Пароль',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (room.isPrivateRoom) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 10, color: Colors.orange),
              const SizedBox(width: 2),
              Text(
                'Приглашение',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (room.isVerified) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 10, color: Colors.green),
              const SizedBox(width: 2),
              Text(
                'Проверено',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 8,
      left: 12,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: badges,
      ),
    );
  }

  Widget _buildRoomAvatar(Room room) {
    final avatarUrl = room.creatorAvatarUrl ?? 'https://avatars.mds.yandex.net/i?id=afbd7642e852a1eb5203048042bb5fe0_l-10702804-images-thumbs&n=13';

    return Image(
      image: roomUtils.getCachedImage(avatarUrl),
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomCover(Room room) {
    final coverUrl = room.imageUrl.isNotEmpty ? room.imageUrl : 'https://via.placeholder.com/400x200/26A69A/ffffff?text=Room';

    return Image(
      image: roomUtils.getCachedImage(coverUrl),
      width: double.infinity,
      height: 140,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Icon(Icons.photo_library, color: Colors.grey[600], size: 40),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}