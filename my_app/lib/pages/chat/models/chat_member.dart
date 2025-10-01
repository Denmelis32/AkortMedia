import 'enums.dart';

class ChatMember {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final MemberRole role;
  final DateTime lastSeen;

  ChatMember({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isOnline,
    required this.role,
    required this.lastSeen,
  });
}