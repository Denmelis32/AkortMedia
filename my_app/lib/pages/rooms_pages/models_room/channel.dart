class Channel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String ownerName;
  final String ownerAvatarUrl;
  final String categoryId;
  final DateTime createdAt;
  int subscribersCount; // Изменяем на не-final для обновления
  final List<String> tags;
  final List<String> recentTopicIds;
  final String? bannerImageUrl;
  final bool isVerified;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.ownerAvatarUrl,
    required this.categoryId,
    required this.createdAt,
    this.subscribersCount = 0,
    this.tags = const [],
    this.recentTopicIds = const [],
    this.bannerImageUrl,
    this.isVerified = false,
  });

  Channel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? ownerName,
    String? ownerAvatarUrl,
    String? categoryId,
    DateTime? createdAt,
    int? subscribersCount,
    List<String>? tags,
    List<String>? recentTopicIds,
    String? bannerImageUrl,
    bool? isVerified,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      subscribersCount: subscribersCount ?? this.subscribersCount,
      tags: tags ?? this.tags,
      recentTopicIds: recentTopicIds ?? this.recentTopicIds,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}