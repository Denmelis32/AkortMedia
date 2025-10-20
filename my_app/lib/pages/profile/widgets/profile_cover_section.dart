import 'package:flutter/material.dart';
import '../utils/profile_utils.dart';

class ProfileCoverSection extends StatelessWidget {
  final String userName;
  final String userEmail;
  final double horizontalPadding;
  final VoidCallback onImageTap;
  final VoidCallback onCoverTap;
  final VoidCallback onEditProfile;
  final String bio;
  final String location;
  final String website;
  final DateTime joinDate;

  const ProfileCoverSection({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.horizontalPadding,
    required this.onImageTap,
    required this.onCoverTap,
    required this.onEditProfile,
    required this.bio,
    required this.location,
    required this.website,
    required this.joinDate,
  });

  @override
  Widget build(BuildContext context) {
    final utils = ProfileUtils();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            _buildCoverSection(utils),
            _buildAvatarAndInfoSection(utils),
            _buildEditProfileButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverSection(ProfileUtils utils) {
    return GestureDetector(
      onTap: onCoverTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _getCoverGradient(utils),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Gradient _getCoverGradient(ProfileUtils utils) {
    final userColor = utils.getUserColor(userName);
    return LinearGradient(
      colors: [userColor, utils.darkenColor(userColor, 0.3)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Widget _buildAvatarAndInfoSection(ProfileUtils utils) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(child: _buildDefaultAvatar(utils)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '@${userName.toLowerCase().replaceAll(' ', '')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (bio.isNotEmpty && bio != 'Расскажите о себе...')
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Positioned(
      top: 100,
      right: 16,
      child: FloatingActionButton.small(
        onPressed: onEditProfile,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        child: const Icon(Icons.edit_rounded, size: 18),
      ),
    );
  }

  Widget _buildDefaultAvatar(ProfileUtils utils) {
    final gradientColors = utils.getAvatarGradient(userName);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}