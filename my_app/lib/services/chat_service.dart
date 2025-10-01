// services/chat_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../pages/chat/models/chat_member.dart';
import '../pages/chat/models/chat_message.dart';
import '../pages/chat/models/enums.dart';

class ChatService {
  final Random _random = Random();
  final Map<String, List<ChatMessage>> _roomMessages = {};
  final Map<String, List<ChatMember>> _roomMembers = {};
  final Map<String, String> _translationCache = {};

  // Симуляция задержки сети
  Future<void> _simulateNetworkDelay([int minMs = 300, int maxMs = 1000]) async {
    await Future.delayed(Duration(milliseconds: minMs + _random.nextInt(maxMs - minMs)));
  }

  // Загрузка сообщений с пагинацией
  Future<List<ChatMessage>> loadMessages(String roomId, {int limit = 50, int offset = 0}) async {
    await _simulateNetworkDelay();

    if (!_roomMessages.containsKey(roomId)) {
      _roomMessages[roomId] = await _generateSampleMessages(roomId);
    }

    final allMessages = _roomMessages[roomId]!;
    final startIndex = max(0, allMessages.length - offset - limit);
    final endIndex = allMessages.length - offset;

    if (startIndex >= endIndex) {
      return [];
    }

    return allMessages.sublist(startIndex, endIndex).reversed.toList();
  }

  // Отправка сообщения
  Future<ChatMessage> sendMessage(ChatMessage message) async {
    await _simulateNetworkDelay(200, 500);

    if (!_roomMessages.containsKey(message.roomId)) {
      _roomMessages[message.roomId] = [];
    }

    final sentMessage = message.copyWith(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(1000)}',
      status: MessageStatus.sent,
      time: DateTime.now(),
    );

    _roomMessages[message.roomId]!.add(sentMessage);

    return sentMessage;
  }

  // Редактирование сообщения
  Future<ChatMessage> editMessage(String messageId, String newText, String roomId) async {
    await _simulateNetworkDelay();

    final messages = _roomMessages[roomId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) {
      throw Exception('Message not found');
    }

    final updatedMessage = messages[messageIndex].copyWith(
      text: newText,
      isEdited: true,
      editTime: DateTime.now(),
    );

    messages[messageIndex] = updatedMessage;
    return updatedMessage;
  }

  // Удаление сообщения
  Future<bool> deleteMessage(String messageId, String roomId) async {
    await _simulateNetworkDelay();

    final messages = _roomMessages[roomId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) {
      return false;
    }

    messages.removeAt(messageIndex);
    return true;
  }

  // Получение ответа AI
  Future<String> getAIResponse(String userMessage, String roomId, {String? context}) async {
    await _simulateNetworkDelay(1000, 3000);

    final responses = await _getEnhancedResponses(userMessage, roomId, context);
    return responses[_random.nextInt(responses.length)];
  }

  // Расширенная логика ответов AI
  Future<List<String>> _getEnhancedResponses(String message, String roomId, String? context) async {
    message = message.toLowerCase();

    // Спортивная тематика
    if (message.contains('матч') || message.contains('игра') || message.contains('game')) {
      return [
        'Да, это был потрясающий матч! Как вам игра команд? ⚽',
        'Какой захватывающий матч! Особенно впечатлила игра во втором тайме. 🏆',
        'Отличная игра! Кто на ваш взгляд был лучшим игроком? 🥅',
        'Матч был просто незабываемый! Надеюсь, следующая игра будет такой же интересной. ⚽',
      ];
    }

    if (message.contains('гол') || message.contains('счет') || message.contains('score')) {
      return [
        'Великолепный гол! Техника исполнения была на высшем уровне! 🥅',
        'Как вам этот гол? По-моему, это один из лучших в сезоне! ⚽',
        'Счет полностью отражает игру. Команды показали отличную борьбу! 🔥',
        'Этот гол решил исход матча! Невероятный момент! 🎯',
      ];
    }

    if (message.contains('команда') || message.contains('team') || message.contains('игрок') || message.contains('player')) {
      return [
        'Команда показала отличный характер! Особенно в защите. 🛡️',
        'Какой игрок произвел на вас наибольшее впечатление? Для меня это был номер 10! ⭐',
        'Командная работа была просто на высоте! Заметили как они взаимодействуют? 🤝',
        'Интересно, а как вы думаете, какие замены стоило сделать тренеру? 🧠',
      ];
    }

    if (message.contains('тренер') || message.contains('coach') || message.contains('стратеги')) {
      return [
        'Тренерская работа была великолепна! Отличные решения по ходу матча. 👨‍💼',
        'Стратегия команды полностью оправдала себя. Что вы думаете о тактических решениях? 🎯',
        'Замены во втором тайме кардинально изменили игру. Гениальное решение тренера! 🔄',
        'Как вам работа тренерского штаба в этом матче? По-моему, они отлично справились! 💪',
      ];
    }

    if (message.contains('время') || message.contains('when') || message.contains('когда')) {
      return [
        'Следующий матч начинается завтра в 20:00. Не пропустите! 🕗',
        'Расписание матчей можно посмотреть на официальном сайте лиги. Календарь очень насыщенный! 📅',
        'Трансляция начнется в 19:30, не опаздывайте! 📺',
        'Предстоящие игры будут в эти выходные. Готовьтесь к интересным противостояниям! 🏆',
      ];
    }

    if (message.contains('погод') || message.contains('weather') || message.contains('дожд')) {
      return [
        'Погода действительно повлияла на игру. Заметили как ветер мешал дальним передачам? 🌬️',
        'Дождь добавил остроты игре! Мяч скользил совсем по-другому. 🌧️',
        'Игра в таких условиях требует особой подготовки. Команды справились достойно! 💪',
        'Погодные условия проверяют настоящий характер команд! ☀️🌧️',
      ];
    }

    if (message.contains('привет') || message.contains('hi') || message.contains('hello')) {
      return [
        'Привет! Рад видеть вас в нашем спортивном чате! 😊',
        'Здравствуйте! Готовы обсуждать последние спортивные события? ⚽',
        'Приветствую! Как ваша любимая команда выступает в этом сезоне? 🏆',
        'Привет! Отличный матч только что закончился, не правда ли? 👋',
      ];
    }

    if (message.contains('как дела') || message.contains('how are you')) {
      return [
        'Отлично! Обсуждаем последние спортивные события. А у вас как дела? ⚽',
        'Прекрасно! Только что пересматривал highlights вчерашнего матча. А вы смотрели? 📺',
        'Замечательно! Спорт всегда поднимает настроение. Как ваши дела? 😊',
        'Отлично! Готовлю аналитику к следующему матчу. А у вас как новости? 📊',
      ];
    }

    if (message.contains('спасибо') || message.contains('thank you')) {
      return [
        'Всегда пожалуйста! Рад быть полезным в обсуждении спорта! 🎉',
        'Не за что! Продолжаем наслаждаться великолепной игрой! ⚽',
        'Пожалуйста! Если будут еще вопросы - обращайтесь! 😊',
        'Рад помочь! Давайте вместе следить за спортивными событиями! 👏',
      ];
    }

    // Общие ответы с учетом контекста
    final generalResponses = [
      'Интересная мысль! Что еще думаете по этому поводу? 🤔',
      'Согласен с вами! Добавлю, что важна также командная работа. 💪',
      'Хороший вопрос! Давайте обсудим это подробнее. 🗣️',
      'Отличное замечание! Полностью поддерживаю вашу точку зрения. 👍',
      'Интересно! А что вы думаете о тактике команды в этом сезоне? 🎯',
      'Спасибо, что поделились мнением! Это действительно важная тема. 🙏',
      'Полностью с вами согласен! Добавлю, что ключевым был момент на 65-й минуте. ⏱️',
      'Отличная тема для обсуждения! Как вы думаете, что решило исход матча? 🏅',
      'Интересный взгляд! А как вы оцениваете игру вратаря? 🥅',
      'Замечательно сказано! Полностью разделяю ваше мнение о матче. 👌',
      'Отличный анализ! Что вы думаете о перспективах команды в этом сезоне? 📈',
      'Интересная точка зрения! А как вам работа судей в этом матче? 👨‍⚖️',
    ];

    return generalResponses;
  }

  // Загрузка участников комнаты
  Future<List<ChatMember>> loadRoomMembers(String roomId) async {
    await _simulateNetworkDelay(500, 1500);

    if (!_roomMembers.containsKey(roomId)) {
      _roomMembers[roomId] = await _generateSampleMembers();
    }

    return _roomMembers[roomId]!;
  }

  // Перевод сообщения
  Future<String?> translateMessage(String text, String targetLanguage) async {
    final cacheKey = '${text.hashCode}_$targetLanguage';

    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey];
    }

    await _simulateNetworkDelay(500, 2000);

    final translations = {
      'Привет всем! Рад присоединиться к обсуждению! 👋':
      'Hello everyone! Glad to join the discussion! 👋',
      'Кто уже смотрел последний матч? Какие мысли? ⚽':
      'Who has already watched the last match? Any thoughts? ⚽',
      'Отличная игра была! Особенно понравилась стратегия команды в защите.':
      'It was a great game! I especially liked the team\'s defensive strategy.',
      'А как вам гол на 89-й минуте? Просто великолепно! 🥅':
      'What about the goal at the 89th minute? Just great! 🥅',
      'Кстати, не пропустите завтрашний матч! Начинается в 20:00 по московскому времени.':
      'By the way, don\'t miss tomorrow\'s match! Starts at 20:00 Moscow time.',
      'Добро пожаловать в чат! 🎉':
      'Welcome to the chat! 🎉',
      'Что думаете о составе на следующий матч?':
      'What do you think about the lineup for the next match?',
      'Отличный пас и завершение!':
      'Great pass and finish!',
      'Команда показала характер сегодня.':
      'The team showed character today.',
      'Как вам судейство в этом матче?':
      'How do you like the refereeing in this match?',
    };

    final translation = translations[text] ?? '$text [Translated]';
    _translationCache[cacheKey] = translation;

    return translation;
  }

  // Добавление реакции к сообщению
  Future<Map<String, Set<String>>?> addReaction(
      String messageId,
      String roomId,
      String reaction,
      String userName,
      ) async {
    await _simulateNetworkDelay(100, 300);

    final messages = _roomMessages[roomId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) {
      return null;
    }

    final message = messages[messageIndex];
    final currentReactions = Map<String, Set<String>>.from(message.reactions ?? {});
    final usersWhoReacted = currentReactions[reaction] ?? <String>{};

    if (usersWhoReacted.contains(userName)) {
      usersWhoReacted.remove(userName);
      if (usersWhoReacted.isEmpty) {
        currentReactions.remove(reaction);
      }
    } else {
      usersWhoReacted.add(userName);
      currentReactions[reaction] = usersWhoReacted;
    }

    messages[messageIndex] = message.copyWith(reactions: currentReactions);

    return currentReactions;
  }

  // Закрепление/открепление сообщения
  Future<bool> toggleMessagePin(String messageId, String roomId) async {
    await _simulateNetworkDelay(200, 500);

    final messages = _roomMessages[roomId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) {
      return false;
    }

    final message = messages[messageIndex];
    messages[messageIndex] = message.copyWith(isPinned: !message.isPinned);

    return true;
  }

  // Поиск по сообщениям
  Future<List<ChatMessage>> searchMessages(String roomId, String query) async {
    await _simulateNetworkDelay(300, 1000);

    final messages = _roomMessages[roomId] ?? [];

    return messages.where((message) {
      return message.text.toLowerCase().contains(query.toLowerCase()) &&
          message.messageType == MessageType.text;
    }).toList();
  }

  // Получение закрепленных сообщений
  Future<List<ChatMessage>> getPinnedMessages(String roomId) async {
    await _simulateNetworkDelay(200, 600);

    final messages = _roomMessages[roomId] ?? [];

    return messages.where((message) => message.isPinned).toList();
  }

  // Генерация sample сообщений
  Future<List<ChatMessage>> _generateSampleMessages(String roomId) async {
    final sampleMessages = [
      ChatMessage(
        id: '1',
        roomId: roomId,
        text: 'Добро пожаловать в чат! 🎉\nЗдесь обсуждаем последние спортивные события и матчи. Не стесняйтесь задавать вопросы и делиться мнениями!',
        sender: 'Система',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: false,
        messageType: MessageType.system,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: '2',
        roomId: roomId,
        text: 'Привет всем! Рад присоединиться к обсуждению! 👋',
        sender: 'Алексей Петров',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isMe: false,
        reactions: {'👍': {'Алексей Петров', 'Мария Иванова'}, '❤️': {'Иван Сидоров'}},
        status: MessageStatus.sent,
        userColor: Colors.blue,
        userAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
      ChatMessage(
        id: '3',
        roomId: roomId,
        text: 'Кто уже смотрел последний матч? Какие мысли? ⚽',
        sender: 'Мария Иванова',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isMe: false,
        reactions: {'❤️': {'Алексей Петров'}, '🔥': {'Иван Сидоров'}},
        status: MessageStatus.sent,
        userColor: Colors.pink,
        userAvatar: 'https://i.pravatar.cc/150?img=2',
      ),
      ChatMessage(
        id: '4',
        roomId: roomId,
        text: 'Отличная игра была! Особенно понравилась стратегия команды в защите. На мой взгляд, ключевым моментом стала замена на 70-й минуте.',
        sender: 'Иван Сидоров',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        isMe: false,
        status: MessageStatus.sent,
        userColor: Colors.green,
        userAvatar: 'https://i.pravatar.cc/150?img=3',
      ),
      ChatMessage(
        id: '5',
        roomId: roomId,
        text: 'А как вам гол на 89-й минуте? Просто великолепно! 🥅',
        sender: 'Алексей Петров',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: false,
        isEdited: true,
        editTime: DateTime.now().subtract(const Duration(minutes: 55)),
        status: MessageStatus.sent,
        userColor: Colors.blue,
        userAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
      ChatMessage(
        id: '6',
        roomId: roomId,
        text: 'Кстати, не пропустите завтрашний матч! Начинается в 20:00 по московскому времени. Будет очень интересно! 🏆',
        sender: 'Мария Иванова',
        time: DateTime.now().subtract(const Duration(minutes: 45)),
        isMe: false,
        isPinned: true,
        status: MessageStatus.sent,
        userColor: Colors.pink,
        userAvatar: 'https://i.pravatar.cc/150?img=2',
      ),
      ChatMessage(
        id: '7',
        roomId: roomId,
        text: '🎵 Голосовое сообщение',
        sender: 'Алексей Петров',
        time: DateTime.now().subtract(const Duration(minutes: 30)),
        isMe: false,
        messageType: MessageType.voice,
        status: MessageStatus.sent,
        userColor: Colors.blue,
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        voiceDuration: 30,
      ),
    ];

    return sampleMessages;
  }

  // Генерация sample участников
  Future<List<ChatMember>> _generateSampleMembers() async {
    return [
      ChatMember(
        id: '1',
        name: 'Алексей Петров',
        avatar: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
        role: MemberRole.admin,
        lastSeen: DateTime.now(),
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ChatMember(
        id: '2',
        name: 'Мария Иванова',
        avatar: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
        role: MemberRole.moderator,
        lastSeen: DateTime.now(),
        joinDate: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ChatMember(
        id: '3',
        name: 'Иван Сидоров',
        avatar: 'https://i.pravatar.cc/150?img=3',
        isOnline: true,
        role: MemberRole.member,
        lastSeen: DateTime.now(),
        joinDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ChatMember(
        id: '4',
        name: 'Екатерина Смирнова',
        avatar: 'https://i.pravatar.cc/150?img=4',
        isOnline: false,
        role: MemberRole.member,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        joinDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ChatMember(
        id: '5',
        name: 'Дмитрий Козлов',
        avatar: 'https://i.pravatar.cc/150?img=5',
        isOnline: false,
        role: MemberRole.member,
        lastSeen: DateTime.now().subtract(const Duration(days: 1)),
        joinDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Очистка кэша переводов
  void clearTranslationCache() {
    _translationCache.clear();
  }

  // Получение статистики комнаты
  Future<Map<String, dynamic>> getRoomStats(String roomId) async {
    await _simulateNetworkDelay(500, 1500);

    final messages = _roomMessages[roomId] ?? [];
    final members = _roomMembers[roomId] ?? [];

    final today = DateTime.now();
    final todayMessages = messages.where((msg) =>
    msg.time.year == today.year &&
        msg.time.month == today.month &&
        msg.time.day == today.day
    ).length;

    final onlineMembers = members.where((member) => member.isOnline).length;

    return {
      'totalMessages': messages.length,
      'totalMembers': members.length,
      'onlineMembers': onlineMembers,
      'todayMessages': todayMessages,
      'pinnedMessages': messages.where((msg) => msg.isPinned).length,
    };
  }

  // Подписка на обновления комнаты (для real-time функциональности)
  Stream<List<ChatMessage>> watchRoomMessages(String roomId) {
    final controller = StreamController<List<ChatMessage>>();

    // Симуляция real-time обновлений
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!controller.isClosed && _roomMessages.containsKey(roomId)) {
        controller.add(_roomMessages[roomId]!);
      }
    });

    return controller.stream;
  }
}