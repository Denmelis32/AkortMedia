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
  final List<String> subscriberIds;

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
    this.subscriberIds = const [],
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
    List<String>? subscriberIds,
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
      subscriberIds: subscriberIds ?? this.subscriberIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerAvatarUrl': ownerAvatarUrl,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'subscribersCount': subscribersCount,
      'tags': tags,
      'recentTopicIds': recentTopicIds,
      'subscriberIds': subscriberIds,
    };
  }

  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      ownerId: map['ownerId'],
      ownerName: map['ownerName'],
      ownerAvatarUrl: map['ownerAvatarUrl'],
      categoryId: map['categoryId'],
      createdAt: DateTime.parse(map['createdAt']),
      subscribersCount: map['subscribersCount'],
      tags: List<String>.from(map['tags']),
      recentTopicIds: List<String>.from(map['recentTopicIds']),
      subscriberIds: List<String>.from(map['subscriberIds'] ?? []),
    );
  }
}




