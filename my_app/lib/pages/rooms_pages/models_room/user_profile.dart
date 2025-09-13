class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime joinDate;
  final List<String> subscribedChannels;
  final List<String> ownedChannels;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.joinDate,
    this.subscribedChannels = const [],
    this.ownedChannels = const [],
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? joinDate,
    List<String>? subscribedChannels,
    List<String>? ownedChannels,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinDate: joinDate ?? this.joinDate,
      subscribedChannels: subscribedChannels ?? this.subscribedChannels,
      ownedChannels: ownedChannels ?? this.ownedChannels,
    );
  }
}