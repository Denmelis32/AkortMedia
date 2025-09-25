import 'package:flutter/material.dart';
import '../models/room.dart';
import 'room_actions_menu.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onPin;
  final VoidCallback onReport;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onJoin,
    required this.onEdit,
    required this.onShare,
    required this.onPin,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showRoomPreview(context),
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
            elevation: room.isPinned ? 12 : 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: _buildGradient(),
                border: room.isPinned
                    ? Border.all(color: Colors.amber, width: 2)
                    : null,
              ),
              child: Stack(
                children: [
                  _buildDecorations(),
                  _buildContent(context),
                  _buildNewIndicator(),
                  _buildPinnedIndicator(),
                  _buildActionsMenu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _buildGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        room.category.color.withOpacity(room.isPinned ? 0.95 : 0.9),
        room.category.color.withOpacity(room.isPinned ? 0.8 : 0.7),
        room.category.color.withOpacity(room.isPinned ? 0.95 : 0.9),
      ],
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
          _buildHeaderSection(),
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

  Widget _buildHeaderSection() {
    return Row(
      children: [
        _buildAvatarSection(),
        const Spacer(),
        if (room.isPrivate)
          Icon(Icons.lock, color: Colors.white.withOpacity(0.8), size: 16),
      ],
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    room.category.icon,
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
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
        if (room.isOwner) ...[
          const SizedBox(width: 16),
          _buildStatItem(
            Icons.star,
            'Ваша',
          ),
        ],
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

  Widget _buildPinnedIndicator() {
    return room.isPinned
        ? Positioned(
      top: 12,
      left: 12,
      child: Icon(
        Icons.push_pin,
        color: Colors.amber,
        size: 16,
      ),
    )
        : const SizedBox();
  }

  Widget _buildActionsMenu() {
    return Positioned(
      top: 8,
      right: 8,
      child: RoomActionsMenu(
        room: room,
        onEdit: onEdit,
        onShare: onShare,
        onPin: onPin,
        onReport: onReport,
      ),
    );
  }

  void _showRoomPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRoomPreview(context),
    );
  }

  Widget _buildRoomPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _buildGradient(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewHeader(),
            const SizedBox(height: 16),
            Text(
              room.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              room.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildPreviewStats(),
            const SizedBox(height: 20),
            _buildPreviewButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Text(
            room.title[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Категория: ${room.category.title}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                'Создана ${_formatDate(room.createdAt)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStats() {
    return Row(
      children: [
        _buildPreviewStatItem(Icons.people, '${room.participants} участников'),
        const SizedBox(width: 20),
        _buildPreviewStatItem(Icons.chat, '${room.messages} сообщений'),
        const SizedBox(width: 20),
        _buildPreviewStatItem(Icons.access_time, _formatLastActivity()),
      ],
    );
  }

  Widget _buildPreviewStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text('Закрыть'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: room.category.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(room.isJoined ? 'Открыть' : 'Присоединиться'),
          ),
        ),
      ],
    );
  }

  String _formatLastActivity() {
    final difference = DateTime.now().difference(room.lastActivity);
    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    return '${difference.inDays} д назад';
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}