class UserPermissions {
  final bool isSeniorDeveloper;
  final bool isLongTermFan;
  final DateTime joinDate;
  final String? avatarUrl;

  UserPermissions({
    required this.isSeniorDeveloper,
    required this.isLongTermFan,
    required this.joinDate,
    this.avatarUrl,
  });
}