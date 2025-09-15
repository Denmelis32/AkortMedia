import '../pages/rooms_pages/models_room/channel.dart';
import '../pages/rooms_pages/models_room/discussion_topic.dart';

class ChannelService {
  // Хранилище подписок: userId -> Set<channelId>
  static final Map<String, Set<String>> _userSubscriptions = {};

  // Хранилище участников каналов: channelId -> List<Map<String, dynamic>>
  static final Map<String, List<Map<String, dynamic>>> _channelMembers = {};

  // Основные методы работы с каналами
  static List<Channel> getChannelsByCategory(String categoryId, List<Channel> allChannels) {
    return allChannels.where((channel) => channel.categoryId == categoryId).toList();
  }

  static List<DiscussionTopic> getRecentTopicsForChannel(
      String channelId,
      List<DiscussionTopic> allTopics,
      int limit
      ) {
    final channelTopics = allTopics.where((topic) => topic.channelId == channelId).toList();
    channelTopics.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return channelTopics.take(limit).toList();
  }

  static List<Channel> getPopularChannels(List<Channel> channels, int limit) {
    final sorted = List<Channel>.from(channels);
    sorted.sort((a, b) => b.subscribersCount.compareTo(a.subscribersCount));
    return sorted.take(limit).toList();
  }

  static List<Channel> searchChannels(List<Channel> channels, String query) {
    if (query.isEmpty) return channels;

    return channels.where((channel) =>
    channel.name.toLowerCase().contains(query.toLowerCase()) ||
        channel.description.toLowerCase().contains(query.toLowerCase()) ||
        channel.ownerName.toLowerCase().contains(query.toLowerCase()) ||
        channel.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  static List<Channel> getChannelsByOwner(String ownerId, List<Channel> allChannels) {
    return allChannels.where((channel) => channel.ownerId == ownerId).toList();
  }

  static void addChannel(List<Channel> channels, Channel newChannel) {
    channels.add(newChannel);
    // Инициализируем хранилище участников для нового канала
    _channelMembers[newChannel.id] = [];
  }

  // Методы для работы с подписками
  static bool isUserSubscribed(Channel channel, String userId) {
    return _userSubscriptions[userId]?.contains(channel.id) ?? false;
  }

  static void subscribe(Channel channel, String userId) {
    if (!isUserSubscribed(channel, userId)) {
      _userSubscriptions.putIfAbsent(userId, () => Set<String>()).add(channel.id);
      channel.subscribersCount++;

      // Добавляем пользователя в участники канала
      _addUserToChannelMembers(channel.id, userId);
    }
  }

  static void unsubscribe(Channel channel, String userId) {
    if (isUserSubscribed(channel, userId)) {
      _userSubscriptions[userId]?.remove(channel.id);
      channel.subscribersCount = channel.subscribersCount > 0
          ? channel.subscribersCount - 1
          : 0;

      // Удаляем пользователя из участников канала
      _removeUserFromChannelMembers(channel.id, userId);
    }
  }

  static void toggleSubscription(Channel channel, String userId) {
    if (isUserSubscribed(channel, userId)) {
      unsubscribe(channel, userId);
    } else {
      subscribe(channel, userId);
    }
  }

  static List<Channel> getSubscribedChannels(List<Channel> allChannels, String userId) {
    final subscribedIds = _userSubscriptions[userId] ?? Set<String>();
    return allChannels.where((channel) => subscribedIds.contains(channel.id)).toList();
  }

  static int getSubscribedChannelsCount(String userId) {
    return _userSubscriptions[userId]?.length ?? 0;
  }

  // НОВЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С УЧАСТНИКАМИ КАНАЛА
  static List<Map<String, dynamic>> getChannelMembers(Channel channel) {
    // Если участники уже есть в хранилище, возвращаем их
    if (_channelMembers[channel.id]?.isNotEmpty ?? false) {
      return _channelMembers[channel.id]!;
    }

    // Иначе создаем демо-данные
    return _createDemoMembers(channel);
  }

  static int getMembersCount(Channel channel) {
    return getChannelMembers(channel).length;
  }

  // Приватные методы для работы с участниками
  static void _addUserToChannelMembers(String channelId, String userId) {
    final members = _channelMembers[channelId] ?? [];
    final userInfo = _createUserInfo(userId, members.length);

    // Проверяем, нет ли уже такого пользователя
    if (!members.any((member) => member['id'] == userId)) {
      members.add(userInfo);
      _channelMembers[channelId] = members;
    }
  }

  static void _removeUserFromChannelMembers(String channelId, String userId) {
    final members = _channelMembers[channelId] ?? [];
    _channelMembers[channelId] = members.where((member) => member['id'] != userId).toList();
  }

  static List<Map<String, dynamic>> _createDemoMembers(Channel channel) {
    final members = <Map<String, dynamic>>[];

    // Добавляем владельца канала
    members.add({
      'id': channel.ownerId,
      'name': channel.ownerName,
      'avatarUrl': channel.ownerAvatarUrl,
      'role': 'owner',
      'joinedAt': channel.createdAt,
      'isVerified': channel.isVerified,
    });

    // Добавляем демо-подписчиков
    final demoCount = channel.subscribersCount.clamp(0, 10);
    for (int i = 0; i < demoCount; i++) {
      members.add(_createUserInfo('demo_user_$i', i));
    }

    // Сохраняем демо-данные для будущего использования
    _channelMembers[channel.id] = members;

    return members;
  }

  static Map<String, dynamic> _createUserInfo(String userId, int index) {
    final names = [
      'Алексей Подписчик',
      'Мария Любитель',
      'Дмитрий Активный',
      'Ольга Новичок',
      'Сергей Постоянный',
      'Елена Энтузиаст',
      'Иван Исследователь',
      'Анна Участница',
      'Михаил Общительный',
      'Юлия Любознательная'
    ];

    final avatars = [
      'https://ui-avatars.com/api/?name=АП&background=FF2D55',
      'https://ui-avatars.com/api/?name=МЛ&background=34C759',
      'https://ui-avatars.com/api/?name=ДА&background=FF9500',
      'https://ui-avatars.com/api/?name=ОН&background=AF52DE',
      'https://ui-avatars.com/api/?name=СП&background=007AFF',
      'https://ui-avatars.com/api/?name=ЕЭ&background=FF2D55',
      'https://ui-avatars.com/api/?name=ИИ&background=34C759',
      'https://ui-avatars.com/api/?name=АУ&background=FF9500',
      'https://ui-avatars.com/api/?name=МО&background=AF52DE',
      'https://ui-avatars.com/api/?name=ЮЛ&background=007AFF'
    ];

    final nameIndex = index % names.length;

    return {
      'id': userId,
      'name': names[nameIndex],
      'avatarUrl': avatars[nameIndex],
      'role': 'subscriber',
      'joinedAt': DateTime.now().subtract(Duration(days: (index + 1) * 7)),
      'isVerified': false,
    };
  }

  // Дополнительные полезные методы
  static List<Map<String, dynamic>> searchChannelMembers(
      Channel channel,
      String query
      ) {
    final members = getChannelMembers(channel);
    if (query.isEmpty) return members;

    final lowercaseQuery = query.toLowerCase();
    return members.where((member) =>
    member['name']?.toString().toLowerCase().contains(lowercaseQuery) ?? false
    ).toList();
  }

  static Map<String, dynamic>? getMemberInfo(Channel channel, String userId) {
    final members = getChannelMembers(channel);
    return members.firstWhere(
          (member) => member['id'] == userId,
      orElse: () => _createUserInfo(userId, 0),
    );
  }

  // Метод для инициализации демо-данных (для тестирования)
  static void initializeDemoData(List<Channel> channels) {
    clearAllData();

    for (final channel in channels) {
      _channelMembers[channel.id] = _createDemoMembers(channel);

      // Добавляем несколько демо-подписчиков
      for (int i = 0; i < channel.subscribersCount.clamp(0, 5); i++) {
        final demoUserId = 'demo_user_${channel.id}_$i';
        _userSubscriptions.putIfAbsent(demoUserId, () => Set<String>()).add(channel.id);
      }
    }
  }

  // Метод для очистки всех данных (для тестирования)
  static void clearAllData() {
    _userSubscriptions.clear();
    _channelMembers.clear();
  }

  // Метод для очистки только подписок
  static void clearSubscriptions() {
    _userSubscriptions.clear();
  }
}