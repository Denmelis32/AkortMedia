import 'package:flutter/material.dart';
import 'package:my_app/pages/cards_page/widgets/posts_list.dart';
import '../models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 0.95, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    room.category.color.withOpacity(0.9),
                    room.category.color.withOpacity(0.7),
                    room.category.color.withOpacity(0.9),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  _buildDecorations(),
                  _buildContent(context),
                  _buildNewIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorations() {
    return Positioned(
      top: -10,
      right: -10,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatarSection(),
          const SizedBox(height: 16),
          _buildTitleSection(),
          const SizedBox(height: 8),
          _buildDescriptionSection(),
          const Spacer(),
          _buildStatsSection(),
          const SizedBox(height: 16),
          _buildJoinButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              room.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        _buildParticipantsBadge(),
      ],
    );
  }

  Widget _buildParticipantsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        room.participants.formatCount(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      room.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescriptionSection() {
    return Text(
      room.description,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 12,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        _buildStatItem(
          Icons.chat_bubble_outline_rounded,
          room.messages.formatCount(),
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.access_time_rounded,
          _formatLastActivity(),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onJoin,
      style: ElevatedButton.styleFrom(
        backgroundColor: room.isJoined
            ? Colors.white.withOpacity(0.15)
            : Colors.white,
        foregroundColor: room.isJoined
            ? Colors.white
            : room.category.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(double.infinity, 44),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            room.isJoined ? Icons.check_circle_rounded : Icons.add_rounded,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            room.isJoined ? 'Вы участвуете' : 'Присоединиться',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewIndicator() {
    final isNew = DateTime.now().difference(room.lastActivity).inMinutes < 10;

    return isNew
        ? Positioned(
      top: 15,
      right: 15,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
    )
        : const SizedBox();
  }

  String _formatLastActivity() {
    final difference = DateTime.now().difference(room.lastActivity);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    return '${difference.inDays} д назад';
  }
}