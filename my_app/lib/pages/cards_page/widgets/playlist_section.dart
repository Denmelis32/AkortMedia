// lib/pages/cards_page/widgets/playlist_section.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';

class PlaylistSection extends StatelessWidget {
  final Channel channel;

  const PlaylistSection({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    // Заглушка данных плейлистов
    final playlists = [
      _Playlist(
        title: 'Лучшие видео',
        videoCount: 24,
        imageUrl: 'https://picsum.photos/300/200?1',
      ),
      _Playlist(
        title: 'Обучение',
        videoCount: 15,
        imageUrl: 'https://picsum.photos/300/200?2',
      ),
      _Playlist(
        title: 'Интервью',
        videoCount: 8,
        imageUrl: 'https://picsum.photos/300/200?3',
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Изображение плейлиста
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: playlist.imageUrl,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          height: 90,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          height: 90,
                          child: const Icon(Icons.video_library, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${playlist.videoCount} видео',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Название плейлиста
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      playlist.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Playlist {
  final String title;
  final int videoCount;
  final String imageUrl;

  _Playlist({
    required this.title,
    required this.videoCount,
    required this.imageUrl,
  });
}