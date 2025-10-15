// event_model.dart
import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime endDate;
  final Color color;
  final String category;
  final String? location;
  final String? address;
  final double? price;
  final String organizer;
  final String? imageUrl;
  final List<String> tags;
  final int maxAttendees;
  final int currentAttendees;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final String? onlineLink;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> imageUrls;
  final String? website;
  final String? phone;
  final String? email;
  final List<EventSchedule> schedule;
  final EventAccessibility? accessibility;
  final EventSocial? social;
  final EventStatistics statistics;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.endDate,
    required this.color,
    required this.category,
    this.location,
    this.address,
    this.price,
    required this.organizer,
    this.imageUrl,
    this.tags = const [],
    this.maxAttendees = 100,
    this.currentAttendees = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isOnline = false,
    this.onlineLink,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls = const [],
    this.website,
    this.phone,
    this.email,
    this.schedule = const [],
    this.accessibility,
    this.social,
    this.statistics = const EventStatistics(),
  });

  // Метод для копирования с обновленными значениями
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDate,
    Color? color,
    String? category,
    String? location,
    String? address,
    double? price,
    String? organizer,
    String? imageUrl,
    List<String>? tags,
    int? maxAttendees,
    int? currentAttendees,
    double? rating,
    int? reviewCount,
    bool? isOnline,
    String? onlineLink,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imageUrls,
    String? website,
    String? phone,
    String? email,
    List<EventSchedule>? schedule,
    EventAccessibility? accessibility,
    EventSocial? social,
    EventStatistics? statistics,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      color: color ?? this.color,
      category: category ?? this.category,
      location: location ?? this.location,
      address: address ?? this.address,
      price: price ?? this.price,
      organizer: organizer ?? this.organizer,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isOnline: isOnline ?? this.isOnline,
      onlineLink: onlineLink ?? this.onlineLink,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrls: imageUrls ?? this.imageUrls,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      schedule: schedule ?? this.schedule,
      accessibility: accessibility ?? this.accessibility,
      social: social ?? this.social,
      statistics: statistics ?? this.statistics,
    );
  }

  // Геттер для проверки, бесплатное ли событие
  bool get isFree => price == 0 || price == null;

  // Геттер для проверки, полностью ли заполнено событие
  bool get isFullyBooked => currentAttendees >= maxAttendees;

  // Геттер для получения процента заполненности
  double get attendancePercentage => maxAttendees > 0 ? currentAttendees / maxAttendees : 0.0;

  // Геттер для получения длительности события в часах
  double get durationInHours => endDate.difference(date).inMinutes / 60.0;

  // Геттер для проверки, является ли событие прошедшим
  bool get isPast => date.isBefore(DateTime.now());

  // Геттер для проверки, является ли событие текущим (идет прямо сейчас)
  bool get isOngoing => date.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());

  // Геттер для получения времени до начала события
  Duration get timeUntilStart => date.difference(DateTime.now());

  // Геттер для получения оставшегося времени события
  Duration get remainingTime => endDate.difference(DateTime.now());

  // Геттер для форматированной цены
  String get formattedPrice {
    if (isFree) return 'Бесплатно';
    return '${price?.toStringAsFixed(0)} ₽';
  }

  // Геттер для форматированного рейтинга
  String get formattedRating => rating.toStringAsFixed(1);

  // Геттер для получения основного изображения
  String? get mainImage => imageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

  // Геттер для получения количества доступных мест
  int get availableSpots => maxAttendees - currentAttendees;

  // Метод для добавления участника
  Event addAttendee() {
    return copyWith(
      currentAttendees: currentAttendees + 1,
      updatedAt: DateTime.now(),
    );
  }

  // Метод для удаления участника
  Event removeAttendee() {
    return copyWith(
      currentAttendees: currentAttendees - 1,
      updatedAt: DateTime.now(),
    );
  }

  // Метод для обновления рейтинга
  Event updateRating(double newRating, String review) {
    final newReviewCount = reviewCount + 1;
    final newAverageRating = ((rating * reviewCount) + newRating) / newReviewCount;

    return copyWith(
      rating: double.parse(newAverageRating.toStringAsFixed(1)),
      reviewCount: newReviewCount,
      updatedAt: DateTime.now(),
    );
  }

  // Метод для проверки доступности события
  bool isAvailableForBooking() {
    return !isPast && !isFullyBooked;
  }

  // Метод для получения ближайшего расписания
  EventSchedule? getNextSchedule() {
    final now = DateTime.now();
    return schedule.firstWhere(
          (s) => s.startTime.isAfter(now),
      orElse: () => schedule.isNotEmpty ? schedule.last : EventSchedule(startTime: date, endTime: endDate),
    );
  }

  // Преобразование в Map для сохранения
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'color': color.value,
      'category': category,
      'location': location,
      'address': address,
      'price': price,
      'organizer': organizer,
      'imageUrl': imageUrl,
      'tags': tags,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'rating': rating,
      'reviewCount': reviewCount,
      'isOnline': isOnline,
      'onlineLink': onlineLink,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrls': imageUrls,
      'website': website,
      'phone': phone,
      'email': email,
      'schedule': schedule.map((s) => s.toMap()).toList(),
      'accessibility': accessibility?.toMap(),
      'social': social?.toMap(),
      'statistics': statistics.toMap(),
    };
  }

  // Создание из Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      endDate: DateTime.parse(map['endDate']),
      color: Color(map['color']),
      category: map['category'] ?? '',
      location: map['location'],
      address: map['address'],
      price: map['price'],
      organizer: map['organizer'] ?? '',
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      maxAttendees: map['maxAttendees'] ?? 100,
      currentAttendees: map['currentAttendees'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      onlineLink: map['onlineLink'],
      isFeatured: map['isFeatured'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      website: map['website'],
      phone: map['phone'],
      email: map['email'],
      schedule: List<EventSchedule>.from(
        (map['schedule'] ?? []).map((s) => EventSchedule.fromMap(s)),
      ),
      accessibility: map['accessibility'] != null
          ? EventAccessibility.fromMap(map['accessibility'])
          : null,
      social: map['social'] != null
          ? EventSocial.fromMap(map['social'])
          : null,
      statistics: map['statistics'] != null
          ? EventStatistics.fromMap(map['statistics'])
          : const EventStatistics(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Event &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, category: $category}';
  }
}

// Класс для расписания события (для повторяющихся событий)
class EventSchedule {
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final bool isRecurring;
  final RecurrencePattern? recurrence;

  const EventSchedule({
    required this.startTime,
    required this.endTime,
    this.description,
    this.isRecurring = false,
    this.recurrence,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'description': description,
      'isRecurring': isRecurring,
      'recurrence': recurrence?.toMap(),
    };
  }

  factory EventSchedule.fromMap(Map<String, dynamic> map) {
    return EventSchedule(
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      description: map['description'],
      isRecurring: map['isRecurring'] ?? false,
      recurrence: map['recurrence'] != null
          ? RecurrencePattern.fromMap(map['recurrence'])
          : null,
    );
  }
}

// Паттерн повторения события
class RecurrencePattern {
  final RecurrenceType type;
  final int interval;
  final List<int> daysOfWeek;
  final int dayOfMonth;
  final int weekOfMonth;
  final DateTime? endDate;
  final int? occurrenceCount;

  const RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth = 1,
    this.weekOfMonth = 1,
    this.endDate,
    this.occurrenceCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'weekOfMonth': weekOfMonth,
      'endDate': endDate?.toIso8601String(),
      'occurrenceCount': occurrenceCount,
    };
  }

  factory RecurrencePattern.fromMap(Map<String, dynamic> map) {
    return RecurrencePattern(
      type: RecurrenceType.values[map['type']],
      interval: map['interval'] ?? 1,
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      dayOfMonth: map['dayOfMonth'] ?? 1,
      weekOfMonth: map['weekOfMonth'] ?? 1,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      occurrenceCount: map['occurrenceCount'],
    );
  }
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

// Класс для информации о доступности
class EventAccessibility {
  final bool isWheelchairAccessible;
  final bool hasAudioDescription;
  final bool hasSignLanguage;
  final bool hasBraille;
  final bool isChildFriendly;
  final bool isPetFriendly;
  final List<String> specialNeeds;

  const EventAccessibility({
    this.isWheelchairAccessible = false,
    this.hasAudioDescription = false,
    this.hasSignLanguage = false,
    this.hasBraille = false,
    this.isChildFriendly = false,
    this.isPetFriendly = false,
    this.specialNeeds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'isWheelchairAccessible': isWheelchairAccessible,
      'hasAudioDescription': hasAudioDescription,
      'hasSignLanguage': hasSignLanguage,
      'hasBraille': hasBraille,
      'isChildFriendly': isChildFriendly,
      'isPetFriendly': isPetFriendly,
      'specialNeeds': specialNeeds,
    };
  }

  factory EventAccessibility.fromMap(Map<String, dynamic> map) {
    return EventAccessibility(
      isWheelchairAccessible: map['isWheelchairAccessible'] ?? false,
      hasAudioDescription: map['hasAudioDescription'] ?? false,
      hasSignLanguage: map['hasSignLanguage'] ?? false,
      hasBraille: map['hasBraille'] ?? false,
      isChildFriendly: map['isChildFriendly'] ?? false,
      isPetFriendly: map['isPetFriendly'] ?? false,
      specialNeeds: List<String>.from(map['specialNeeds'] ?? []),
    );
  }
}

// Класс для социальной информации
class EventSocial {
  final String? facebookUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? telegramUrl;
  final String? vkUrl;
  final String? hashtag;
  final int shares;
  final int likes;

  const EventSocial({
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.telegramUrl,
    this.vkUrl,
    this.hashtag,
    this.shares = 0,
    this.likes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'twitterUrl': twitterUrl,
      'telegramUrl': telegramUrl,
      'vkUrl': vkUrl,
      'hashtag': hashtag,
      'shares': shares,
      'likes': likes,
    };
  }

  factory EventSocial.fromMap(Map<String, dynamic> map) {
    return EventSocial(
      facebookUrl: map['facebookUrl'],
      instagramUrl: map['instagramUrl'],
      twitterUrl: map['twitterUrl'],
      telegramUrl: map['telegramUrl'],
      vkUrl: map['vkUrl'],
      hashtag: map['hashtag'],
      shares: map['shares'] ?? 0,
      likes: map['likes'] ?? 0,
    );
  }
}

// Класс для статистики события
class EventStatistics {
  final int views;
  final int uniqueVisitors;
  final int bookings;
  final int cancellations;
  final double revenue;
  final int shares;
  final int comments;

  const EventStatistics({
    this.views = 0,
    this.uniqueVisitors = 0,
    this.bookings = 0,
    this.cancellations = 0,
    this.revenue = 0.0,
    this.shares = 0,
    this.comments = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'views': views,
      'uniqueVisitors': uniqueVisitors,
      'bookings': bookings,
      'cancellations': cancellations,
      'revenue': revenue,
      'shares': shares,
      'comments': comments,
    };
  }

  factory EventStatistics.fromMap(Map<String, dynamic> map) {
    return EventStatistics(
      views: map['views'] ?? 0,
      uniqueVisitors: map['uniqueVisitors'] ?? 0,
      bookings: map['bookings'] ?? 0,
      cancellations: map['cancellations'] ?? 0,
      revenue: (map['revenue'] ?? 0.0).toDouble(),
      shares: map['shares'] ?? 0,
      comments: map['comments'] ?? 0,
    );
  }

  EventStatistics copyWith({
    int? views,
    int? uniqueVisitors,
    int? bookings,
    int? cancellations,
    double? revenue,
    int? shares,
    int? comments,
  }) {
    return EventStatistics(
      views: views ?? this.views,
      uniqueVisitors: uniqueVisitors ?? this.uniqueVisitors,
      bookings: bookings ?? this.bookings,
      cancellations: cancellations ?? this.cancellations,
      revenue: revenue ?? this.revenue,
      shares: shares ?? this.shares,
      comments: comments ?? this.comments,
    );
  }
}

// Класс для отзыва о событии
class EventReview {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final bool isVerified;

  const EventReview({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
      'isVerified': isVerified,
    };
  }

  factory EventReview.fromMap(Map<String, dynamic> map) {
    return EventReview(
      id: map['id'],
      eventId: map['eventId'],
      userId: map['userId'],
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      isVerified: map['isVerified'] ?? false,
    );
  }
}

// Класс для категории события
class EventCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final int count;
  final bool isActive;
  final int sortOrder;

  const EventCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.count = 0,
    this.isActive = true,
    this.sortOrder = 0,
  });

  EventCategory copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    int? count,
    bool? isActive,
    int? sortOrder,
  }) {
    return EventCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      count: count ?? this.count,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// Класс для уведомлений о событиях
class EventNotification {
  final String id;
  final String eventId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const EventNotification({
    required this.id,
    required this.eventId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });
}

enum NotificationType {
  eventReminder,
  bookingConfirmation,
  eventUpdate,
  eventCancellation,
  newReview,
  priceDrop,
}

// Класс для системы билетов
class EventTicket {
  final String id;
  final String eventId;
  final String type;
  final String name;
  final double price;
  final int quantity;
  final int sold;
  final DateTime? saleStart;
  final DateTime? saleEnd;
  final String? description;
  final List<String> benefits;
  final bool isActive;

  const EventTicket({
    required this.id,
    required this.eventId,
    required this.type,
    required this.name,
    required this.price,
    required this.quantity,
    this.sold = 0,
    this.saleStart,
    this.saleEnd,
    this.description,
    this.benefits = const [],
    this.isActive = true,
  });

  bool get isAvailable {
    final now = DateTime.now();
    final isOnSale = saleStart == null || now.isAfter(saleStart!);
    final isNotSoldOut = saleEnd == null || now.isBefore(saleEnd!);
    return isActive && isOnSale && isNotSoldOut && sold < quantity;
  }

  int get availableQuantity => quantity - sold;
}