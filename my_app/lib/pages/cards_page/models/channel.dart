// models/channel.dart
import 'dart:ui' show Color;

import 'package:my_app/pages/cards_page/models/playlist.dart';

import '../widgets/page_sections/playlist_section.dart';

class Channel {
  final int id;
  final String title;
  late final String description;
  final String imageUrl;
  final int subscribers;
  final int videos;
  final bool isSubscribed;
  final bool isFavorite;
  final Color cardColor;
  final String categoryId;
  final DateTime createdAt;
  final bool isVerified;
  final double rating;
  final int views;
  final int likes;
  final int comments;
  final String owner;
  final List<String> tags;
  final bool isLive;
  final int liveViewers;
  final String websiteUrl;
  final String socialMedia;
  final String author;
  final String authorImageUrl;
  final int commentsCount;
  final bool isPinned;
  final List<Playlist> playlists;
  final String? coverImageUrl; // Добавленное поле

  Channel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.subscribers,
    required this.videos,
    required this.isSubscribed,
    required this.isFavorite,
    required this.cardColor,
    required this.categoryId,
    required this.createdAt,
    required this.isVerified,
    required this.rating,
    required this.author,
    required this.authorImageUrl,
    required this.commentsCount,
    required this.likes,
    this.views = 0,
    this.comments = 0,
    this.owner = 'Неизвестный автор',
    this.tags = const [],
    this.isLive = false,
    this.liveViewers = 0,
    this.websiteUrl = '',
    this.socialMedia = '',
    this.isPinned = false,
    this.playlists = const [],
    this.coverImageUrl, // Значение по умолчанию - пустой список
  });

  Channel copyWith({
    int? id,
    String? coverImageUrl,
    String? title,
    String? description,
    String? imageUrl,
    int? subscribers,
    int? videos,
    bool? isSubscribed,
    bool? isFavorite,
    Color? cardColor,
    String? categoryId,
    DateTime? createdAt,
    bool? isVerified,
    double? rating,
    int? views,
    int? likes,
    int? comments,
    String? owner,
    List<String>? tags,
    bool? isLive,
    int? liveViewers,
    String? websiteUrl,
    String? socialMedia,
    String? author,
    String? authorImageUrl,
    int? commentsCount,
    bool? isPinned,
    List<Playlist>? playlists, // Добавлен в copyWith
  }) {
    return Channel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      subscribers: subscribers ?? this.subscribers,
      videos: videos ?? this.videos,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isFavorite: isFavorite ?? this.isFavorite,
      cardColor: cardColor ?? this.cardColor,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      owner: owner ?? this.owner,
      tags: tags ?? this.tags,
      isLive: isLive ?? this.isLive,
      liveViewers: liveViewers ?? this.liveViewers,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      socialMedia: socialMedia ?? this.socialMedia,
      author: author ?? this.author,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      commentsCount: commentsCount ?? this.commentsCount,
      isPinned: isPinned ?? this.isPinned,
      playlists: playlists ?? this.playlists,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,// Добавлено
    );
  }

  // Новый метод для получения количества плейлистов
  int get playlistCount => playlists.length;

  // Метод для проверки наличия плейлистов
  bool get hasPlaylists => playlists.isNotEmpty;

  // Метод для получения общего количества видео во всех плейлистах
  int get totalVideosInPlaylists {
    return playlists.fold(0, (sum, playlist) => sum + playlist.videoCount);
  }

  // Метод для получения самого популярного плейлиста (по количеству видео)
  Playlist? get mostPopularPlaylist {
    if (playlists.isEmpty) return null;
    return playlists.reduce((a, b) => a.videoCount > b.videoCount ? a : b);
  }

  // Метод для получения последнего плейлиста (по дате создания)
  Playlist? get latestPlaylist {
    if (playlists.isEmpty) return null;
    return playlists.reduce((a, b) {
      final aDate = a.createdAt ?? DateTime(0);
      final bDate = b.createdAt ?? DateTime(0);
      return aDate.isAfter(bDate) ? a : b;
    });
  }

  // Метод для вычисления engagement rate
  double get engagementRate {
    if (subscribers == 0) return 0.0;
    return ((likes + comments) / subscribers) * 100;
  }

  // Метод для проверки, является ли канал популярным
  bool get isPopular => subscribers > 10000;

  // Метод для получения времени существования канала
  Duration get age => DateTime.now().difference(createdAt);

  // Метод для форматирования времени существования
  String get formattedAge {
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years ${_getRussianWord(years, ['год', 'года', 'лет'])}';
    } else if (months > 0) {
      return '$months ${_getRussianWord(months, ['месяц', 'месяца', 'месяцев'])}';
    } else {
      return '${age.inDays} ${_getRussianWord(age.inDays, ['день', 'дня', 'дней'])}';
    }
  }

  // Вспомогательный метод для склонения русских слов
  String _getRussianWord(int number, List<String> words) {
    if (number % 10 == 1 && number % 100 != 11) {
      return words[0];
    } else if (number % 10 >= 2 && number % 10 <= 4 && (number % 100 < 10 || number % 100 >= 20)) {
      return words[1];
    } else {
      return words[2];
    }
  }

  // Метод для получения формата подписчиков
  String get formattedSubscribers {
    if (subscribers >= 1000000) {
      return '${(subscribers / 1000000).toStringAsFixed(1)}M';
    } else if (subscribers >= 1000) {
      return '${(subscribers / 1000).toStringAsFixed(1)}K';
    }
    return subscribers.toString();
  }

  // Метод для получения формата просмотров
  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M просмотров';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K просмотров';
    }
    return '$views просмотров';
  }

  // Метод для получения основного цвета в hex
  String get colorHex {
    return '#${cardColor.value.toRadixString(16).substring(2, 8)}';
  }

  // Метод для проверки активности канала
  bool get isActive => videos > 0 && createdAt.isAfter(
      DateTime.now().subtract(const Duration(days: 30))
  );

  // Метод для получения категории в читаемом формате
  String get categoryName {
    const categoryMap = {
      'youtube': 'YouTube',
      'business': 'Бизнес',
      'games': 'Игры',
      'programming': 'Программирование',
      'sport': 'Спорт',
      'communication': 'Общение',
    };
    return categoryMap[categoryId] ?? categoryId;
  }

  // Метод для получения формата даты создания
  String get formattedCreatedAt {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }

  // Метод для проверки, является ли канал новым (создан менее 7 дней назад)
  bool get isNew => age.inDays < 7;

  // Метод для преобразования в Map (для Firebase или других БД)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'subscribers': subscribers,
      'videos': videos,
      'isSubscribed': isSubscribed,
      'isFavorite': isFavorite,
      'cardColor': cardColor.value,
      'categoryId': categoryId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'rating': rating,
      'views': views,
      'likes': likes,
      'comments': comments,
      'owner': owner,
      'tags': tags,
      'isLive': isLive,
      'liveViewers': liveViewers,
      'websiteUrl': websiteUrl,
      'socialMedia': socialMedia,
      'author': author,
      'authorImageUrl': authorImageUrl,
      'commentsCount': commentsCount,
      'isPinned': isPinned,
      'playlists': playlists.map((playlist) => playlist.toMap()).toList(), // Добавлено
    };
  }

  // Фабричный метод для создания из Map
  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      subscribers: map['subscribers'],
      videos: map['videos'],
      isSubscribed: map['isSubscribed'],
      isFavorite: map['isFavorite'] ?? false,
      cardColor: Color(map['cardColor']),
      categoryId: map['categoryId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isVerified: map['isVerified'],
      rating: map['rating'].toDouble(),
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      owner: map['owner'] ?? 'Неизвестный автор',
      tags: List<String>.from(map['tags'] ?? []),
      isLive: map['isLive'] ?? false,
      liveViewers: map['liveViewers'] ?? 0,
      websiteUrl: map['websiteUrl'] ?? '',
      socialMedia: map['socialMedia'] ?? '',
      author: map['author'] ?? 'Неизвестный автор',
      authorImageUrl: map['authorImageUrl'] ?? '',
      commentsCount: map['commentsCount'] ?? 0,
      isPinned: map['isPinned'] ?? false,
      playlists: (map['playlists'] as List<dynamic>? ?? []) // Добавлено
          .map((playlistMap) => Playlist.fromMap(playlistMap))
          .toList(),
    );
  }

  // Фабричный метод для создания упрощенного канала (совместимость)
  factory Channel.simple({
    required int id,
    required String title,
    required String description,
    required String imageUrl,
    required Color cardColor,
    int subscribers = 0,
    int videos = 0,
    double rating = 0.0,
    bool isSubscribed = false,
    bool isFavorite = false,
    String author = 'Неизвестный автор',
    String authorImageUrl = '',
    int commentsCount = 0,
    int likes = 0,
    List<Playlist> playlists = const [], // Добавлено
  }) {
    return Channel(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      subscribers: subscribers,
      videos: videos,
      isSubscribed: isSubscribed,
      isFavorite: isFavorite,
      cardColor: cardColor,
      categoryId: 'general',
      createdAt: DateTime.now(),
      isVerified: false,
      rating: rating,
      author: author,
      authorImageUrl: authorImageUrl,
      commentsCount: commentsCount,
      likes: likes,
      views: 0,
      comments: 0,
      playlists: playlists, // Добавлено
    );
  }

  @override
  String toString() {
    return 'Channel{id: $id, title: $title, subscribers: $subscribers, isSubscribed: $isSubscribed, isFavorite: $isFavorite, rating: $rating, isVerified: $isVerified, isPinned: $isPinned, playlists: $playlistCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Channel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Метод для сравнения по дате создания (для сортировки)
  int compareByDate(Channel other) => createdAt.compareTo(other.createdAt);

  // Метод для сравнения по популярности (для сортировки)
  int compareByPopularity(Channel other) => subscribers.compareTo(other.subscribers);

  // Метод для сравнения по рейтингу (для сортировки)
  int compareByRating(Channel other) => rating.compareTo(other.rating);

  // Метод для сравнения по количеству плейлистов (для сортировки)
  int compareByPlaylistCount(Channel other) => playlistCount.compareTo(other.playlistCount);
}