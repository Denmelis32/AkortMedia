import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/news_providers/news_provider.dart';
import '../components/cover_picker_modal.dart';
import '../utils/profile_utils.dart';

class ProfileCoverSection extends StatefulWidget {
  final String userName;
  final String userEmail;
  final double horizontalPadding;
  final VoidCallback onImageTap;
  final VoidCallback onCoverTap;
  final String bio;
  final String location;
  final String website;
  final DateTime joinDate;
  final int followersCount;
  final bool isVerified;

  const ProfileCoverSection({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.horizontalPadding,
    required this.onImageTap,
    required this.onCoverTap,
    required this.bio,
    required this.location,
    required this.website,
    required this.joinDate,
    this.followersCount = 0,
    this.isVerified = false,
  });

  @override
  State<ProfileCoverSection> createState() => _ProfileCoverSectionState();
}

class _ProfileCoverSectionState extends State<ProfileCoverSection> {
  bool _isCoverHovered = false;

  void _handleHover(bool isHovered) {
    setState(() => _isCoverHovered = isHovered);
  }

  void _showCoverPickerModal() {
    final utils = ProfileUtils();
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final userColor = utils.getUserColor(widget.userName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CoverPickerModal(
        userEmail: widget.userEmail,
        coverImageUrl: newsProvider.coverImageUrl,
        coverImageFile: newsProvider.coverImageFile,
        onSuccess: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
        userColor: userColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final utils = ProfileUtils();
    final newsProvider = Provider.of<NewsProvider>(context);
    final isMobile = ProfileUtils.isMobile(context);
    final isTablet = ProfileUtils.isTablet(context);

    // Получаем текущие изображения из провайдера
    final profileImageUrl = newsProvider.profileImageUrl;
    final profileImageFile = newsProvider.profileImageFile;
    final coverImageUrl = newsProvider.coverImageUrl;
    final coverImageFile = newsProvider.coverImageFile;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.horizontalPadding,
        vertical: utils.getAdaptiveValue(context, mobile: 12, tablet: 16, desktop: 20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
          borderRadius: utils.getAdaptiveBorderRadius(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            _buildCoverSection(utils, context, isMobile, coverImageUrl, coverImageFile),
            _buildAvatarAndInfoSection(utils, context, isMobile, isTablet, profileImageUrl, profileImageFile),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverSection(ProfileUtils utils, BuildContext context, bool isMobile, String? coverImageUrl, File? coverImageFile) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _showCoverPickerModal,
        child: Container(
          height: utils.getAdaptiveValue(context, mobile: 120, tablet: 140, desktop: 160),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: coverImageUrl == null && coverImageFile == null
                ? _getEnhancedCoverGradient()
                : null,
            image: coverImageUrl != null || coverImageFile != null
                ? DecorationImage(
              image: _getCoverImageProvider(coverImageUrl, coverImageFile),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: Stack(
            children: [
              // Узор поверх градиента (только для больших экранов и когда нет обложки)
              if (!isMobile && coverImageUrl == null && coverImageFile == null)
                _buildCoverPattern(utils, context),

              // Затемнение
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(_isCoverHovered ? 0.6 : 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Индикатор редактирования
              if (!isMobile)
                Positioned(
                  top: utils.getAdaptiveValue(context, mobile: 8, tablet: 12, desktop: 16),
                  right: utils.getAdaptiveValue(context, mobile: 8, tablet: 12, desktop: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                      vertical: utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 16, tablet: 18, desktop: 20)),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: utils.getAdaptiveIconSize(context),
                        ),
                        if (!isMobile) SizedBox(width: utils.getAdaptiveValue(context, mobile: 2, tablet: 4, desktop: 4)),
                        if (!isMobile) Text(
                          coverImageUrl != null || coverImageFile != null ? 'Изменить обложку' : 'Добавить обложку',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: utils.getAdaptiveFontSize(context, mobile: 10, tablet: 11, desktop: 12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getCoverImageProvider(String? coverImageUrl, File? coverImageFile) {
    if (coverImageFile != null) {
      return FileImage(coverImageFile);
    } else if (coverImageUrl != null) {
      return NetworkImage(coverImageUrl);
    }
    return const AssetImage(''); // Fallback
  }

  Widget _buildCoverPattern(ProfileUtils utils, BuildContext context) {
    return CustomPaint(
      size: Size(
          double.infinity,
          utils.getAdaptiveValue(context, mobile: 120, tablet: 140, desktop: 160)
      ),
      painter: _CoverPatternPainter(),
    );
  }

  Widget _buildAvatarAndInfoSection(ProfileUtils utils, BuildContext context, bool isMobile, bool isTablet, String? profileImageUrl, File? profileImageFile) {
    final avatarSize = utils.getAdaptiveValue(context, mobile: 70, tablet: 80, desktop: 90);
    final bottomPosition = utils.getAdaptiveValue(context, mobile: 12, tablet: 16, desktop: 20);
    final horizontalPosition = utils.getAdaptiveValue(context, mobile: 12, tablet: 16, desktop: 20);
    final spacing = utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16);

    return Positioned(
      bottom: bottomPosition,
      left: horizontalPosition,
      right: horizontalPosition,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(utils, context, avatarSize, profileImageUrl, profileImageFile),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUserNameWithVerification(utils, context, isMobile),
                SizedBox(height: utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6)),
                _buildUserStats(utils, context, isMobile),
                SizedBox(height: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
                if (widget.bio.isNotEmpty && widget.bio != 'Расскажите о себе...' && !isMobile)
                  _buildEnhancedBio(utils, context, isMobile),
                if ((widget.location.isNotEmpty || widget.website.isNotEmpty) && !isMobile)
                  _buildAdditionalInfo(utils, context, isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ProfileUtils utils, BuildContext context, double avatarSize, String? profileImageUrl, File? profileImageFile) {
    return GestureDetector(
      onTap: widget.onImageTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white,
                width: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarImage(utils, context, profileImageUrl, profileImageFile),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(ProfileUtils utils, BuildContext context, String? profileImageUrl, File? profileImageFile) {
    if (profileImageFile != null) {
      return Image.file(profileImageFile, fit: BoxFit.cover);
    } else if (profileImageUrl != null) {
      return Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading profile image: $error');
          return _buildDefaultAvatar(utils, context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildDefaultAvatar(utils, context);
        },
      );
    } else {
      return _buildDefaultAvatar(utils, context);
    }
  }

  Widget _buildUserNameWithVerification(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Row(
      children: [
        Container(
          width: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
          height: utils.getAdaptiveValue(context, mobile: 20, tablet: 22, desktop: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 1.5, tablet: 1.8, desktop: 2)),
          ),
        ),
        SizedBox(width: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.userName,
                      style: TextStyle(
                        fontSize: utils.getAdaptiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isVerified) ...[
                    SizedBox(width: utils.getAdaptiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
                    Container(
                      padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF6366F1),
                        size: utils.getAdaptiveIconSize(context),
                      ),
                    ),
                  ],
                ],
              ),
              if (!isMobile) SizedBox(height: utils.getAdaptiveValue(context, mobile: 1, tablet: 1.5, desktop: 2)),
              if (!isMobile) Text(
                '@${widget.userName.toLowerCase().replaceAll(' ', '_')}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 12),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserStats(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.followersCount > 0) ...[
          Text(
            '${widget.followersCount} подписчиков',
            style: TextStyle(
              fontSize: utils.getAdaptiveFontSize(context, mobile: 10, tablet: 11, desktop: 12),
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnhancedBio(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12),
        vertical: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.white.withOpacity(0.8),
            size: utils.getAdaptiveIconSize(context),
          ),
          SizedBox(width: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
          Expanded(
            child: Text(
              widget.bio,
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              maxLines: isMobile ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(ProfileUtils utils, BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(top: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
      child: Wrap(
        spacing: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12),
        runSpacing: utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6),
        children: [
          if (widget.location.isNotEmpty)
            _buildInfoChip(Icons.location_on_rounded, widget.location, utils, context),
          if (widget.website.isNotEmpty)
            _buildInfoChip(Icons.link_rounded, widget.website, utils, context),
          _buildInfoChip(Icons.calendar_today_rounded, 'С ${widget.joinDate.year}', utils, context),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ProfileUtils utils, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8),
        vertical: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: utils.getAdaptiveIconSize(context),
          ),
          SizedBox(width: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
          Text(
            text,
            style: TextStyle(
              fontSize: utils.getAdaptiveFontSize(context, mobile: 9, tablet: 10, desktop: 11),
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ProfileUtils utils, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: utils.getAdaptiveFontSize(context, mobile: 24, tablet: 28, desktop: 32),
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [
              Shadow(
                blurRadius: 4,
                color: Colors.black26,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Gradient _getEnhancedCoverGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class _CoverPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final step = size.width > 600 ? 20.0 : 15.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}