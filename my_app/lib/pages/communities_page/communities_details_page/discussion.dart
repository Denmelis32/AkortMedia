class Discussion {
  final String id; // ИЗМЕНЕНО: с int на String
  final String title;
  final String content;
  final String? imageUrl;
  final String authorName;
  final String authorAvatarUrl;
  final String communityId; // ИЗМЕНЕНО: с int на String
  final String communityName;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isPinned;
  final bool allowComments;
  final bool? isLiked;
  final bool? isBookmarked;
  final bool? isSubscribed; // ДОБАВЛЕНО: поле подписки
  final DateTime createdAt;
  final DateTime updatedAt;

  Discussion({
    required this.id, // ИЗМЕНЕНО: с int на String
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.communityId, // ИЗМЕНЕНО: с int на String
    required this.communityName,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isPinned,
    required this.allowComments,
    this.isLiked,
    this.isBookmarked,
    this.isSubscribed, // ДОБАВЛЕНО: поле подписки
    required this.createdAt,
    required this.updatedAt,
  });

  // Метод copyWith с обновленными типами
  Discussion copyWith({
    String? id, // ИЗМЕНЕНО: с int на String
    String? title,
    String? content,
    String? imageUrl,
    String? authorName,
    String? authorAvatarUrl,
    String? communityId, // ИЗМЕНЕНО: с int на String
    String? communityName,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isPinned,
    bool? allowComments,
    bool? isLiked,
    bool? isBookmarked,
    bool? isSubscribed, // ДОБАВЛЕНО: поле подписки
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Discussion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isPinned: isPinned ?? this.isPinned,
      allowComments: allowComments ?? this.allowComments,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isSubscribed: isSubscribed ?? this.isSubscribed, // ДОБАВЛЕНО
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Дополнительные полезные методы
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'communityId': communityId,
      'communityName': communityName,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'isPinned': isPinned,
      'allowComments': allowComments,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'isSubscribed': isSubscribed, // ДОБАВЛЕНО
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Discussion.fromMap(Map<String, dynamic> map) {
    return Discussion(
      id: map['id']?.toString() ?? '', // ИЗМЕНЕНО: преобразование в String
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      authorName: map['authorName'] ?? '',
      authorAvatarUrl: map['authorAvatarUrl'] ?? '',
      communityId: map['communityId']?.toString() ?? '0', // ИЗМЕНЕНО: преобразование в String
      communityName: map['communityName'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      viewsCount: map['viewsCount'] ?? 0,
      isPinned: map['isPinned'] ?? false,
      allowComments: map['allowComments'] ?? true,
      isLiked: map['isLiked'],
      isBookmarked: map['isBookmarked'],
      isSubscribed: map['isSubscribed'], // ДОБАВЛЕНО
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Discussion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Вспомогательные методы
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get formattedLikes => _formatNumber(likesCount);

  String get formattedComments => _formatNumber(commentsCount);

  String get formattedViews => _formatNumber(viewsCount);

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  // Метод для проверки, находится ли обсуждение в избранном (с обработкой null)
  bool get isInBookmarks => isBookmarked ?? false;

  // Метод для проверки, лайкнуто ли обсуждение (с обработкой null)
  bool get isLikedByUser => isLiked ?? false;

  // ДОБАВЛЕНО: Метод для проверки, подписан ли пользователь (с обработкой null)
  bool get isSubscribedByUser => isSubscribed ?? false;
}