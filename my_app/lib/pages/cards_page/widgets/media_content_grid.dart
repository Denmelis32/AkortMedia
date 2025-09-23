// lib/pages/cards_page/widgets/media_content_grid.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/media_item.dart';
import '../models/channel.dart';

class MediaContentGrid extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final Channel channel;
  final ValueChanged<MediaItem>? onMediaTap;
  final bool showTitle;

  const MediaContentGrid({
    super.key,
    required this.mediaItems,
    required this.channel,
    this.onMediaTap,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            _BuildHeader(
              channel: channel,
              mediaCount: mediaItems.length,
            ),
            const SizedBox(height: 20),
          ],

          // Content
          if (mediaItems.isEmpty)
            _EmptyMediaState(channel: channel)
          else
            _MediaGrid(
              mediaItems: mediaItems,
              channel: channel,
              onMediaTap: onMediaTap,
            ),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  final Channel channel;
  final int mediaCount;

  const _BuildHeader({
    required this.channel,
    required this.mediaCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Медиа контент',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: channel.cardColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getMediaCountText(mediaCount),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _getMediaCountText(int count) {
    if (count == 0) return 'Нет медиафайлов';
    if (count % 10 == 1 && count % 100 != 11) return '$count медиафайл';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return '$count медиафайла';
    }
    return '$count медиафайлов';
  }
}

class _MediaGrid extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final Channel channel;
  final ValueChanged<MediaItem>? onMediaTap;

  const _MediaGrid({
    required this.mediaItems,
    required this.channel,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _getAspectRatio(crossAxisCount),
      ),
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final media = mediaItems[index];
        return _MediaCard(
          media: media,
          channel: channel,
          onTap: onMediaTap,
        );
      },
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  double _getAspectRatio(int crossAxisCount) {
    switch (crossAxisCount) {
      case 4: return 0.75;
      case 3: return 0.8;
      case 2: return 0.85;
      default: return 0.8;
    }
  }
}

class _MediaCard extends StatelessWidget {
  final MediaItem media;
  final Channel channel;
  final ValueChanged<MediaItem>? onTap;

  const _MediaCard({
    required this.media,
    required this.channel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap != null ? onTap!(media) : _showMediaDetail(context, media),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail section
              Expanded(
                child: _MediaThumbnail(
                  media: media,
                  channel: channel,
                ),
              ),

              // Info section
              _MediaInfo(
                media: media,
                channel: channel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMediaDetail(BuildContext context, MediaItem media) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      barrierDismissible: true,
      barrierLabel: 'Медиа контент',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _MediaDetailDialog(
          media: media,
          channel: channel,
          animation: animation,
        );
      },
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final MediaItem media;
  final Channel channel;

  const _MediaThumbnail({
    required this.media,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: CachedNetworkImage(
            imageUrl: media.thumbnail,
            fit: BoxFit.cover,
            placeholder: (context, url) => _BuildPlaceholder(
              icon: _getMediaTypeIcon(media.type),
              channel: channel,
            ),
            errorWidget: (context, url, error) => _BuildPlaceholder(
              icon: Icons.error_outline,
              channel: channel,
              isError: true,
            ),
            fadeInDuration: const Duration(milliseconds: 300),
          ),
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
        ),

        // Media type indicator
        Positioned(
          top: 8,
          right: 8,
          child: _MediaTypeBadge(type: media.type),
        ),

        // Duration for videos
        if (media.type == MediaType.video && media.duration != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: _DurationBadge(duration: media.duration!),
          ),

        // Play button for videos
        if (media.type == MediaType.video)
          const Positioned(
            bottom: 8,
            right: 8,
            child: _PlayButton(),
          ),
      ],
    );
  }

  IconData _getMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.video:
        return Icons.play_circle_filled;
      case MediaType.image:
        return Icons.photo_library;
      case MediaType.audio:
        return Icons.audio_file;
    }
  }
}

class _MediaInfo extends StatelessWidget {
  final MediaItem media;
  final Channel channel;

  const _MediaInfo({
    required this.media,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            media.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Stats
          Row(
            children: [
              // Views
              _StatItem(
                icon: Icons.remove_red_eye_outlined,
                value: _formatViews(media.views),
                color: Colors.grey.shade600,
              ),

              const Spacer(),

              // Media type icon
              Icon(
                _getMediaTypeIcon(media.type),
                size: 14,
                color: channel.cardColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.video:
        return Icons.videocam_outlined;
      case MediaType.image:
        return Icons.photo_outlined;
      case MediaType.audio:
        return Icons.audiotrack_outlined;
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }
}

class _MediaTypeBadge extends StatelessWidget {
  final MediaType type;

  const _MediaTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _getTypeInfo(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String, Color) _getTypeInfo(MediaType type) {
    switch (type) {
      case MediaType.video:
        return (Icons.play_arrow, 'Видео', Colors.red);
      case MediaType.image:
        return (Icons.photo, 'Фото', Colors.blue);
      case MediaType.audio:
        return (Icons.audiotrack, 'Аудио', Colors.green);
    }
  }
}

class _DurationBadge extends StatelessWidget {
  final String duration;

  const _DurationBadge({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        duration,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.play_arrow,
        size: 16,
        color: Colors.black,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BuildPlaceholder extends StatelessWidget {
  final IconData icon;
  final Channel channel;
  final bool isError;

  const _BuildPlaceholder({
    required this.icon,
    required this.channel,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isError ? Colors.red.shade50 : Colors.grey.shade100,
      child: Center(
        child: Icon(
          icon,
          size: 32,
          color: isError ? Colors.red.shade300 : channel.cardColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _MediaDetailDialog extends StatelessWidget {
  final MediaItem media;
  final Channel channel;
  final Animation<double> animation;

  const _MediaDetailDialog({
    required this.media,
    required this.channel,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 600,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _DialogHeader(media: media, channel: channel),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: media.thumbnail,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => _BuildPlaceholder(
                        icon: _getMediaTypeIcon(media.type),
                        channel: channel,
                      ),
                    ),
                  ),
                ),
              ),

              // Footer
              _DialogFooter(media: media),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.video:
        return Icons.videocam;
      case MediaType.image:
        return Icons.image;
      case MediaType.audio:
        return Icons.audiotrack;
    }
  }
}

class _DialogHeader extends StatelessWidget {
  final MediaItem media;
  final Channel channel;

  const _DialogHeader({
    required this.media,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            _getMediaTypeIcon(media.type),
            color: channel.cardColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              media.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.video:
        return Icons.videocam;
      case MediaType.image:
        return Icons.photo;
      case MediaType.audio:
        return Icons.audiotrack;
    }
  }
}

class _DialogFooter extends StatelessWidget {
  final MediaItem media;

  const _DialogFooter({required this.media});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _FooterStat(
            icon: Icons.remove_red_eye_outlined,
            label: '${_formatViews(media.views)} просмотров',
          ),

          const Spacer(),

          if (media.type == MediaType.video && media.duration != null)
            _FooterStat(
              icon: Icons.schedule_outlined,
              label: media.duration!,
            ),
        ],
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }
}

class _FooterStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterStat({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _EmptyMediaState extends StatelessWidget {
  final Channel channel;

  const _EmptyMediaState({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет медиафайлов',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Медиа контент появится здесь',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}