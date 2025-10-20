// 🏗️ ОСНОВНЫЕ МОДЕЛИ ДАННЫХ ДЛЯ КОМПОНЕНТА НОВОСТЕЙ

import 'package:flutter/material.dart';
import 'news_card_enums.dart';

/// 🎨 МОДЕЛЬ ДИЗАЙНА КАРТОЧКИ
/// Определяет визуальное оформление карточки: цвета, градиенты, стили
/// Используется для согласованного дизайна across всех компонентов
class CardDesign {
  final List<Color> gradient;      // 🌈 Градиентные цвета карточки [начальный, конечный]
  final PatternStyle pattern;      // 🔷 Стиль паттерна фона
  final DecorationStyle decoration; // 🎭 Стиль декорации карточки
  final Color accentColor;         // 🎨 Акцентный цвет для кнопок, тегов, иконок
  final Color backgroundColor;     // 🖼️ Основной цвет фона карточки

  const CardDesign({
    required this.gradient,
    required this.pattern,
    required this.decoration,
    required this.accentColor,
    required this.backgroundColor,
  });

  /// 🔄 Создает копию с обновленными полями
  CardDesign copyWith({
    List<Color>? gradient,
    PatternStyle? pattern,
    DecorationStyle? decoration,
    Color? accentColor,
    Color? backgroundColor,
  }) {
    return CardDesign(
      gradient: gradient ?? this.gradient,
      pattern: pattern ?? this.pattern,
      decoration: decoration ?? this.decoration,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CardDesign &&
              runtimeType == other.runtimeType &&
              gradient == other.gradient &&
              pattern == other.pattern &&
              decoration == other.decoration &&
              accentColor == other.accentColor &&
              backgroundColor == other.backgroundColor;

  @override
  int get hashCode =>
      gradient.hashCode ^
      pattern.hashCode ^
      decoration.hashCode ^
      accentColor.hashCode ^
      backgroundColor.hashCode;
}

/// 💫 МОДЕЛЬ СОСТОЯНИЯ ВЗАИМОДЕЙСТВИЙ С ПОСТОМ
/// Хранит состояние лайков, репостов, комментариев для конкретного поста
/// Синхронизируется с InteractionManager
class PostInteractionState {
  final String postId;             // 🆔 Уникальный идентификатор поста
  final bool isLiked;              // ❤️ Статус лайка текущего пользователя
  final bool isBookmarked;         // 🔖 Статус закладки текущего пользователя
  final bool isReposted;           // 🔄 Статус репоста текущего пользователя
  final int likesCount;            // 🔢 Общее количество лайков
  final int repostsCount;          // 🔢 Общее количество репостов
  final List<Map<String, dynamic>> comments; // 💬 Список комментариев к посту

  const PostInteractionState({
    required this.postId,
    required this.isLiked,
    required this.isBookmarked,
    required this.isReposted,
    required this.likesCount,
    required this.repostsCount,
    required this.comments,
  });

  /// 🔄 Создает копию с обновленными полями
  PostInteractionState copyWith({
    String? postId,
    bool? isLiked,
    bool? isBookmarked,
    bool? isReposted,
    int? likesCount,
    int? repostsCount,
    List<Map<String, dynamic>>? comments,
  }) {
    return PostInteractionState(
      postId: postId ?? this.postId,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isReposted: isReposted ?? this.isReposted,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      comments: comments ?? this.comments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PostInteractionState &&
              runtimeType == other.runtimeType &&
              postId == other.postId &&
              isLiked == other.isLiked &&
              isBookmarked == other.isBookmarked &&
              isReposted == other.isReposted &&
              likesCount == other.likesCount &&
              repostsCount == other.repostsCount &&
              comments == other.comments;

  @override
  int get hashCode =>
      postId.hashCode ^
      isLiked.hashCode ^
      isBookmarked.hashCode ^
      isReposted.hashCode ^
      likesCount.hashCode ^
      repostsCount.hashCode ^
      comments.hashCode;
}

/// 👤 МОДЕЛЬ ДАННЫХ ПОЛЬЗОВАТЕЛЯ/АВТОРА
/// Содержит информацию об авторе поста или канале
class UserData {
  final String id;                 // 🆔 Уникальный идентификатор пользователя/канала
  final String name;               // 📛 Отображаемое имя
  final String avatarUrl;          // 🖼️ URL аватарки
  final bool isChannel;            // 📢 Флаг является ли каналом
  final int? subscribersCount;     // 👥 Количество подписчиков (для каналов)
  final bool isVerified;           // ✅ Флаг верификации

  const UserData({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isChannel = false,
    this.subscribersCount,
    this.isVerified = false,
  });

  /// 🔧 Создает из данных новости
  factory UserData.fromNews(Map<String, dynamic> news, {bool isOriginal = false}) {
    final prefix = isOriginal ? 'original_' : '';

    return UserData(
      id: news['${prefix}author_id']?.toString() ?? news['${prefix}channel_id']?.toString() ?? '',
      name: news['${prefix}author_name']?.toString() ?? news['${prefix}channel_name']?.toString() ?? 'Неизвестный',
      avatarUrl: news['${prefix}author_avatar']?.toString() ?? news['${prefix}channel_avatar']?.toString() ?? '',
      isChannel: news['${prefix}is_channel_post'] == true || news['${prefix}channel_id'] != null,
      subscribersCount: news['${prefix}channel_subscribers']?.toInt(),
      isVerified: news['${prefix}is_verified'] == true,
    );
  }
}

/// 🏷️ МОДЕЛЬ ПЕРСОНАЛЬНОГО ТЕГА
/// Представляет пользовательский тег для категоризации постов
class PersonalTag {
  final String id;                 // 🆔 Уникальный идентификатор тега
  final String name;               // 📛 Отображаемое название тега
  final Color color;               // 🎨 Цвет тега
  final TagType type;              // 🏷️ Тип тега
  final DateTime createdAt;        // 📅 Дата создания
  final DateTime updatedAt;        // 🔄 Дата последнего обновления
  final bool isGlobal;             // 🌍 Флаг глобального применения

  const PersonalTag({
    required this.id,
    required this.name,
    required this.color,
    this.type = TagType.personal,
    required this.createdAt,
    required this.updatedAt,
    this.isGlobal = false,
  });

  /// 🔄 Создает копию с обновленными полями
  PersonalTag copyWith({
    String? id,
    String? name,
    Color? color,
    TagType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isGlobal,
  }) {
    return PersonalTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }
}

/// 💬 МОДЕЛЬ КОММЕНТАРИЯ
/// Представляет комментарий к посту
class Comment {
  final String id;                 // 🆔 Уникальный идентификатор комментария
  final String authorId;           // 👤 ID автора комментария
  final String authorName;         // 📛 Имя автора комментария
  final String authorAvatar;       // 🖼️ Аватар автора комментария
  final String text;               // 📝 Текст комментария
  final DateTime createdAt;        // 📅 Дата создания
  final CommentType type;          // 💬 Тип комментария
  final int likesCount;            // ❤️ Количество лайков
  final bool isLiked;              // 👍 Лайкнут ли текущим пользователем

  const Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.text,
    required this.createdAt,
    this.type = CommentType.regular,
    this.likesCount = 0,
    this.isLiked = false,
  });

  /// 🔧 Создает из данных Map
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id']?.toString() ?? '',
      authorId: map['author_id']?.toString() ?? '',
      authorName: map['author']?.toString() ?? 'Неизвестный',
      authorAvatar: map['author_avatar']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toString()),
      type: CommentType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => CommentType.regular,
      ),
      likesCount: map['likes_count']?.toInt() ?? 0,
      isLiked: map['is_liked'] == true,
    );
  }

  /// 🔄 Конвертирует в Map для сохранения
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author_id': authorId,
      'author': authorName,
      'author_avatar': authorAvatar,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'type': type.name,
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }
}

/// 📊 МОДЕЛЬ ДАННЫХ НОВОСТИ ДЛЯ ОТОБРАЖЕНИЯ
/// Содержит все необходимые данные для отображения карточки новости
class NewsCardData {
  final String id;                         // 🆔 Уникальный идентификатор новости
  final String title;                      // 📰 Заголовок новости
  final String description;                // 📝 Текст новости
  final UserData author;                   // 👤 Данные автора
  final DateTime createdAt;                // 📅 Дата создания
  final bool isChannelPost;                // 📢 Флаг канального поста
  final bool isRepost;                     // 🔄 Флаг репоста
  final UserData? repostedBy;              // 🔄 Кто репостнул (для репостов)
  final UserData? originalAuthor;          // 👤 Оригинальный автор (для репостов)
  final String? repostComment;             // 💬 Комментарий репоста
  final List<String> hashtags;             //#️⃣ Список хештегов
  final List<PersonalTag> personalTags;    // 🏷️ Персональные теги пользователя
  final ContentType contentType;           // 📊 Тип контента
  final CardDesign cardDesign;             // 🎨 Дизайн карточки
  final PostInteractionState interactions; // 💫 Состояние взаимодействий

  const NewsCardData({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.createdAt,
    this.isChannelPost = false,
    this.isRepost = false,
    this.repostedBy,
    this.originalAuthor,
    this.repostComment,
    this.hashtags = const [],
    this.personalTags = const [],
    required this.contentType,
    required this.cardDesign,
    required this.interactions,
  });

  /// 🔧 Создает из сырых данных Map
  factory NewsCardData.fromMap(Map<String, dynamic> map, {CardDesign? customDesign}) {
    final isRepost = map['is_repost'] == true;
    final author = UserData.fromNews(map);
    final originalAuthor = isRepost ? UserData.fromNews(map, isOriginal: true) : null;
    final repostedBy = isRepost ? UserData(
      id: map['reposted_by_id']?.toString() ?? '',
      name: map['reposted_by_name']?.toString() ?? '',
      avatarUrl: map['reposted_by_avatar']?.toString() ?? '',
    ) : null;

    return NewsCardData(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      author: author,
      createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toString()),
      isChannelPost: map['is_channel_post'] == true,
      isRepost: isRepost,
      repostedBy: repostedBy,
      originalAuthor: originalAuthor,
      repostComment: map['repost_comment']?.toString(),
      hashtags: List<String>.from(map['hashtags'] ?? []),
      personalTags: [], // Заполняется из UserTagsProvider
      contentType: _determineContentType(map),
      cardDesign: customDesign ?? _getCardDesign(map),
      interactions: PostInteractionState(
        postId: map['id']?.toString() ?? '',
        isLiked: map['isLiked'] == true,
        isBookmarked: map['isBookmarked'] == true,
        isReposted: map['isReposted'] == true,
        likesCount: (map['likes'] as num?)?.toInt() ?? 0,
        repostsCount: (map['reposts'] as num?)?.toInt() ?? 0,
        comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
      ),
    );
  }

  /// 🎯 Определяет тип контента на основе текста
  static ContentType _determineContentType(Map<String, dynamic> map) {
    final title = (map['title']?.toString() ?? '').toLowerCase();
    final description = (map['description']?.toString() ?? '').toLowerCase();

    if (title.contains('важн') || title.contains('срочн')) return ContentType.important;
    if (title.contains('новость') || description.contains('новость')) return ContentType.news;
    if (title.contains('спорт') || description.contains('спорт')) return ContentType.sports;
    if (title.contains('техн') || description.contains('техн')) return ContentType.tech;
    if (title.contains('развлеч') || description.contains('развлеч')) return ContentType.entertainment;
    if (title.contains('образован') || description.contains('образован')) return ContentType.education;

    return ContentType.general;
  }

  /// 🎨 Получает дизайн карточки на основе ID
  static CardDesign _getCardDesign(Map<String, dynamic> map) {
    // TODO: Реализовать логику выбора дизайна на основе данных
    return _defaultCardDesigns[0];
  }

  /// 🔄 Создает копию с обновленными полями
  NewsCardData copyWith({
    String? id,
    String? title,
    String? description,
    UserData? author,
    DateTime? createdAt,
    bool? isChannelPost,
    bool? isRepost,
    UserData? repostedBy,
    UserData? originalAuthor,
    String? repostComment,
    List<String>? hashtags,
    List<PersonalTag>? personalTags,
    ContentType? contentType,
    CardDesign? cardDesign,
    PostInteractionState? interactions,
  }) {
    return NewsCardData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      isChannelPost: isChannelPost ?? this.isChannelPost,
      isRepost: isRepost ?? this.isRepost,
      repostedBy: repostedBy ?? this.repostedBy,
      originalAuthor: originalAuthor ?? this.originalAuthor,
      repostComment: repostComment ?? this.repostComment,
      hashtags: hashtags ?? this.hashtags,
      personalTags: personalTags ?? this.personalTags,
      contentType: contentType ?? this.contentType,
      cardDesign: cardDesign ?? this.cardDesign,
      interactions: interactions ?? this.interactions,
    );
  }
}

/// 🎨 ДЕФОЛТНЫЕ ДИЗАЙНЫ КАРТОЧЕК
const List<CardDesign> _defaultCardDesigns = [
  CardDesign(
    gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
    pattern: PatternStyle.minimal,
    decoration: DecorationStyle.modern,
    accentColor: Color(0xFF667eea),
    backgroundColor: Color(0xFFFAFBFF),
  ),
  CardDesign(
    gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    pattern: PatternStyle.geometric,
    decoration: DecorationStyle.modern,
    accentColor: Color(0xFF4facfe),
    backgroundColor: Color(0xFFF7FDFF),
  ),
  CardDesign(
    gradient: [Color(0xFFfa709a), Color(0xFFfee140)],
    pattern: PatternStyle.geometric,
    decoration: DecorationStyle.modern,
    accentColor: Color(0xFFfa709a),
    backgroundColor: Color(0xFFFFFBF9),
  ),
];