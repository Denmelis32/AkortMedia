// lib/pages/cards_page/widgets/playlist_section.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';
import '../models/playlist.dart';

class PlaylistSection extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onPlaylistTap;
  final VoidCallback? onSeeAllTap;

  const PlaylistSection({
    super.key,
    required this.channel,
    this.onPlaylistTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Получаем плейлисты из канала или используем заглушку
    final playlists = channel.playlists?.isNotEmpty == true
        ? channel.playlists!
        : _getDefaultPlaylists();

    if (playlists.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        _buildSectionHeader(theme, playlists.length),
        const SizedBox(height: 16),
        // Список плейлистов
        _buildPlaylistsList(context, theme, playlists),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, int playlistCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Плейлисты',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (playlistCount > 3)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                'Все ($playlistCount)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsList(BuildContext context, ThemeData theme, List<Playlist> playlists) {
    return SizedBox(
      height: 180, // Увеличил высоту для лучшего отображения
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return _PlaylistCard(
            playlist: playlist,
            onTap: onPlaylistTap,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Плейлисты отсутствуют',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Playlist> _getDefaultPlaylists() {
    return [
      Playlist(
        id: '1',
        title: 'Лучшие видео',
        videoCount: 24,
        thumbnailUrl: 'https://picsum.photos/300/200?1',
        description: 'Самые популярные видео канала',
      ),
      Playlist(
        id: '2',
        title: 'Обучение и туториалы',
        videoCount: 15,
        thumbnailUrl: 'https://picsum.photos/300/200?2',
        description: 'Обучающие материалы и руководства',
      ),
      Playlist(
        id: '3',
        title: 'Интервью и беседы',
        videoCount: 8,
        thumbnailUrl: 'https://picsum.photos/300/200?3',
        description: 'Интересные интервью и дискуссии',
      ),
      Playlist(
        id: '4',
        title: 'Последние выпуски',
        videoCount: 12,
        thumbnailUrl: 'https://picsum.photos/300/200?4',
        description: 'Свежие видео и новинки',
      ),
    ];
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;

  const _PlaylistCard({
    required this.playlist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Изображение плейлиста
            _buildPlaylistThumbnail(theme),
            // Информация о плейлисте
            _buildPlaylistInfo(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistThumbnail(ThemeData theme) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: playlist.thumbnailUrl,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: theme.colorScheme.surfaceVariant,
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: theme.colorScheme.surfaceVariant,
              height: 100,
              child: Icon(
                Icons.video_library,
                color: theme.colorScheme.onSurfaceVariant,
                size: 40,
              ),
            ),
          ),
          // Градиент для лучшей читаемости текста
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Количество видео
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${playlist.videoCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistInfo(ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              playlist.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (playlist.description != null) ...[
              const SizedBox(height: 4),
              Text(
                playlist.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Модель плейлиста (должна быть в models/playlist.dart)
