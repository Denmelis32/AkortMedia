// lib/pages/cards_page/models/media_item.dart
enum MediaType { video, image, audio }

class MediaItem {
  final String id;
  final String title;
  final MediaType type;
  final String thumbnail;
  final String? duration;
  final int views;

  MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.thumbnail,
    this.duration,
    required this.views,
  });
}