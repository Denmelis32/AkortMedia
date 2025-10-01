// enums.dart
enum MessageType {
  text,
  image,
  video,
  voice,
  sticker,
  system,
  file,
}

enum MessageStatus {
  sending,    // Отправляется
  sent,       // Отправлено
  delivered,  // Доставлено
  read,       // Прочитано
  error,      // Ошибка
}

enum MemberRole {
  admin,
  moderator,
  member,
  guest,
}

enum MessageFilter {
  all,
  media,
  links,
  files,
  voice,
}

enum MessageSort {
  newestFirst,
  oldestFirst,
  mostReactions,
}

// Новые enum'ы для комнат
enum RoomType {
  direct,
  group,
  channel,
  forum,
}

enum RoomAction {
  sendMessages,
  deleteMessages,
  manageUsers,
  pinMessages,
  reactToMessages,
  inviteUsers,
  changeSettings,
}