// lib/data/mock_authors.dart
class MockAuthors {
  // Основные авторы
  static const String system = "Система";
  static const String admin = "Администратор";
  static const String sportsReviewer = "Спортивный обозреватель";
  static const String technologist = "Технолог";
  static const String foodBlogger = "Кулинарный блогер";

  // Аватарки авторов
  static const Map<String, String> authorAvatars = {
    system: 'https://avatars.mds.yandex.net/i?id=ea857d137721d0ce737826525f482ca81aada1cc-6191070-images-thumbs&n=13',
    admin: 'https://avatars.mds.yandex.net/i?id=ea857d137721d0ce737826525f482ca81aada1cc-6191070-images-thumbs&n=13',
    sportsReviewer: 'https://avatars.mds.yandex.net/i?id=ea857d137721d0ce737826525f482ca81aada1cc-6191070-images-thumbs&n=13',
    technologist: 'https://avatars.mds.yandex.net/i?id=ea857d137721d0ce737826525f482ca81aada1cc-6191070-images-thumbs&n=13',
    foodBlogger: 'https://avatars.mds.yandex.net/i?id=ea857d137721d0ce737826525f482ca81aada1cc-6191070-images-thumbs&n=13',
  };

  static List<String> getAllAuthors() {
    return authorAvatars.keys.toList();
  }

  static String? getAvatarForAuthor(String authorName) {
    return authorAvatars[authorName];
  }
}