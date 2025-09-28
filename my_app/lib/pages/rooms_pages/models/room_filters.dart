// models/room_filters.dart
class RoomFilters {
  final Set<String> tags;
  final int minParticipants;
  final int maxParticipants;
  final double minRating;
  final DateTime? createdAfter;
  final bool hasMedia;
  final bool isVerified;
  final bool isPinned;
  final bool isJoined;

  const RoomFilters({
    this.tags = const {},
    this.minParticipants = 0,
    this.maxParticipants = 1000,
    this.minRating = 0.0,
    this.createdAfter,
    this.hasMedia = false,
    this.isVerified = false,
    this.isPinned = false,
    this.isJoined = false,
  });

  RoomFilters copyWith({
    Set<String>? tags,
    int? minParticipants,
    int? maxParticipants,
    double? minRating,
    DateTime? createdAfter,
    bool? hasMedia,
    bool? isVerified,
    bool? isPinned,
    bool? isJoined,
  }) {
    return RoomFilters(
      tags: tags ?? this.tags,
      minParticipants: minParticipants ?? this.minParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minRating: minRating ?? this.minRating,
      createdAfter: createdAfter ?? this.createdAfter,
      hasMedia: hasMedia ?? this.hasMedia,
      isVerified: isVerified ?? this.isVerified,
      isPinned: isPinned ?? this.isPinned,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  bool get hasActiveFilters {
    return tags.isNotEmpty ||
        minParticipants > 0 ||
        maxParticipants < 1000 ||
        minRating > 0.0 ||
        createdAfter != null ||
        hasMedia ||
        isVerified ||
        isPinned ||
        isJoined;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomFilters &&
        other.tags.length == tags.length &&
        other.tags.containsAll(tags) &&
        other.minParticipants == minParticipants &&
        other.maxParticipants == maxParticipants &&
        other.minRating == minRating &&
        other.createdAfter == createdAfter &&
        other.hasMedia == hasMedia &&
        other.isVerified == isVerified &&
        other.isPinned == isPinned &&
        other.isJoined == isJoined;
  }

  @override
  int get hashCode {
    return Object.hash(
      tags.length,
      minParticipants,
      maxParticipants,
      minRating,
      createdAfter,
      hasMedia,
      isVerified,
      isPinned,
      isJoined,
    );
  }

  @override
  String toString() {
    return 'RoomFilters(tags: $tags, minParticipants: $minParticipants, maxParticipants: $maxParticipants, minRating: $minRating, createdAfter: $createdAfter, hasMedia: $hasMedia, isVerified: $isVerified, isPinned: $isPinned, isJoined: $isJoined)';
  }
}