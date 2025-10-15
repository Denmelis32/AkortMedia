import 'package:flutter/material.dart';

class Community {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String coverImageUrl;
  final Color cardColor;
  final List<String> tags;
  final int membersCount;
  final int postsCount;
  final bool isPrivate;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.cardColor,
    required this.tags,
    required this.membersCount,
    required this.postsCount,
    required this.isPrivate,
    required this.createdAt,
  });

  // Метод для копирования с обновленными полями
  Community copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? coverImageUrl,
    Color? cardColor,
    List<String>? tags,
    int? membersCount,
    int? postsCount,
    bool? isPrivate,
    DateTime? createdAt,
  }) {
    return Community(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      cardColor: cardColor ?? this.cardColor,
      tags: tags ?? this.tags,
      membersCount: membersCount ?? this.membersCount,
      postsCount: postsCount ?? this.postsCount,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Метод для создания тестовых данных
  static List<Community> get testCommunities {
    return [
      Community(
        id: 1,
        title: 'Flutter Developers',
        description: 'Сообщество разработчиков на Flutter. Делимся опытом, помогаем новичкам, обсуждаем новые фичи и пакеты.',
        imageUrl: 'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500&h=300&fit=crop',
        cardColor: Colors.blue,
        tags: ['flutter', 'dart', 'mobile', 'programming'],
        membersCount: 12500,
        postsCount: 3421,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Community(
        id: 2,
        title: 'UI/UX Design',
        description: 'Все о дизайне интерфейсов: тренды, инструменты, кейсы и советы по созданию удобных продуктов.',
        imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500&h=300&fit=crop',
        cardColor: Colors.purple,
        tags: ['design', 'ui', 'ux', 'figma', 'adobe'],
        membersCount: 8900,
        postsCount: 2156,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 280)),
      ),
      Community(
        id: 3,
        title: 'Startup Founders',
        description: 'Закрытое сообщество основателей стартапов. Обмен опытом, нетворкинг и поддержка.',
        imageUrl: 'https://images.unsplash.com/photo-1551434678-e076c223a692?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=500&h=300&fit=crop',
        cardColor: Colors.green,
        tags: ['startup', 'business', 'entrepreneurship', 'investment'],
        membersCount: 3400,
        postsCount: 892,
        isPrivate: true,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      Community(
        id: 4,
        title: 'Data Science',
        description: 'Машинное обучение, анализ данных, визуализация и все что связано с Data Science.',
        imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&h=300&fit=crop',
        cardColor: Colors.orange,
        tags: ['datascience', 'python', 'ml', 'ai', 'analytics'],
        membersCount: 15600,
        postsCount: 4231,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 420)),
      ),
      Community(
        id: 5,
        title: 'Web Development',
        description: 'Современная веб-разработка: React, Vue, Angular, Node.js и другие технологии.',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1547658719-da2b51169166?w=500&h=300&fit=crop',
        cardColor: Colors.red,
        tags: ['web', 'javascript', 'react', 'vue', 'node'],
        membersCount: 21800,
        postsCount: 5890,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
      ),
      Community(
        id: 6,
        title: 'Digital Marketing',
        description: 'Продвижение в digital: SMM, SEO, контекстная реклама, аналитика и контент-маркетинг.',
        imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500&h=300&fit=crop',
        cardColor: Colors.teal,
        tags: ['marketing', 'seo', 'smm', 'analytics', 'content'],
        membersCount: 11200,
        postsCount: 2987,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 320)),
      ),
      Community(
        id: 7,
        title: 'Mobile Gaming',
        description: 'Разработка и продвижение мобильных игр. Unity, Unreal Engine, монетизация и аналитика.',
        imageUrl: 'https://images.unsplash.com/photo-1511882150382-421056c89033?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500&h=300&fit=crop',
        cardColor: Colors.pink,
        tags: ['gaming', 'unity', 'mobile', 'games', 'development'],
        membersCount: 6700,
        postsCount: 1567,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 190)),
      ),
      Community(
        id: 8,
        title: 'AI & Machine Learning',
        description: 'Искусственный интеллект и машинное обучение. Исследования, разработка и применение AI.',
        imageUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=500&h=300&fit=crop',
        cardColor: Colors.indigo,
        tags: ['ai', 'machinelearning', 'neuralnetworks', 'deeplearning'],
        membersCount: 18900,
        postsCount: 5123,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 450)),
      ),
      Community(
        id: 9,
        title: 'DevOps & Cloud',
        description: 'DevOps практики, облачные технологии, контейнеризация и автоматизация процессов.',
        imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=500&h=300&fit=crop',
        cardColor: Colors.blueGrey,
        tags: ['devops', 'cloud', 'docker', 'kubernetes', 'aws'],
        membersCount: 9400,
        postsCount: 2345,
        isPrivate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 270)),
      ),
      Community(
        id: 10,
        title: 'Cybersecurity',
        description: 'Безопасность информации, защита данных, этичный хакинг и практики кибербезопасности.',
        imageUrl: 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=150&h=150&fit=crop&crop=face',
        coverImageUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&h=300&fit=crop',
        cardColor: Colors.deepOrange,
        tags: ['security', 'cybersecurity', 'hacking', 'privacy'],
        membersCount: 7200,
        postsCount: 1876,
        isPrivate: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
    ];
  }

  // Метод для преобразования в Map (для сохранения/загрузки)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'cardColor': cardColor.value,
      'tags': tags,
      'membersCount': membersCount,
      'postsCount': postsCount,
      'isPrivate': isPrivate,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Метод для создания из Map
  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      coverImageUrl: map['coverImageUrl'],
      cardColor: Color(map['cardColor']),
      tags: List<String>.from(map['tags']),
      membersCount: map['membersCount'],
      postsCount: map['postsCount'],
      isPrivate: map['isPrivate'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Community && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Community(id: $id, title: $title, members: $membersCount)';
  }
}