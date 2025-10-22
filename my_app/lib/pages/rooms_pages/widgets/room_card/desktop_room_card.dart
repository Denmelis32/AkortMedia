import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../models/room.dart';
import '../../utils/layout_utils.dart';
import '../../utils/room_utils.dart';

class DesktopRoomCard extends StatelessWidget {
  final Room room;
  final int index;
  final RoomProvider roomProvider;
  final LayoutUtils layoutUtils;
  final RoomUtils roomUtils;
  final VoidCallback onRoomTap;
  final VoidCallback onRoomJoinToggle;

  const DesktopRoomCard({
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
    final double cardWidth = 360.0;
    final double fixedCardHeight = 460;
    final cardColor = layoutUtils.getCardColor(index);
    final borderColor = layoutUtils.getCardBorderColor(index);
    final categoryColor = room.category.color;

    return Container(
      width: cardWidth,
      height: fixedCardHeight,
      margin: const EdgeInsets.all(2),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(24),
        color: cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: onRoomTap,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                        child: _buildRoomCover(room),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              room.category.icon,
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
                    Positioned(
                      bottom: -30,
                      left: 16,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildRoomAvatar(room),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                        const SizedBox(height: 12),
                        Expanded(
                          child: Text(
                            room.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: layoutUtils.textColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                roomUtils.formatNumber(room.currentParticipants),
                                'участников',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                room.messageCount.toString(),
                                'сообщений',
                                fontSize: 10,
                                color: borderColor,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: borderColor.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                room.ratingCount.toString(),
                                'лайков',
                                fontSize: 10,
                                color: borderColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: room.tags.take(2).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: borderColor.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: borderColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: onRoomJoinToggle,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: room.isJoined
                                      ? Colors.white.withOpacity(0.8)
                                      : layoutUtils.primaryColor,
                                  foregroundColor: room.isJoined
                                      ? borderColor
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: room.isJoined
                                          ? borderColor.withOpacity(0.5)
                                          : layoutUtils.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      room.isJoined ? Icons.check : Icons.add,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      room.isJoined ? 'Присоединен' : 'Присоединиться',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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