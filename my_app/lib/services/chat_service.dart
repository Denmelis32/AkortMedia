// services/chat_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../pages/chat/models/chat_member.dart';
import '../pages/chat/models/chat_message.dart';
import '../pages/chat/models/chat_session.dart';
import '../pages/chat/models/chat_settings.dart';
import '../pages/chat/models/enums.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Random _random = Random();
  final Map<String, List<ChatMessage>> _roomMessages = {};
  final Map<String, List<ChatMember>> _roomMembers = {};
  final Map<String, ChatSession> _chatSessions = {};
  final Map<String, ChatSettings> _chatSettings = {};
  final Map<String, String> _translationCache = {};

  // Контекст и боты
  final Map<String, List<String>> _conversationContext = {};
  final Map<String, String> _lastUserMessage = {};
  final List<ChatBot> _availableBots = [];
  final Map<String, StreamController<List<ChatMessage>>> _roomControllers = {};

  // Инициализация сервиса
  Future<void> initialize() async {
    _initializeBots();
    await _loadDefaultSettings();
  }

  void _initializeBots() {
    _availableBots.addAll([
      ChatBot(
        id: 'sports_analyst',
        name: 'Алексей Аналитиков',
        avatar: '🧠',
        description: 'Бывший тренер, теперь аналитик',
        isActive: true,
        personality: 'analytical',
        responseStyle: 'detailed',
        color: Colors.blue,
        expertise: ['тактика', 'стратегия', 'техника', 'анализ', 'тренер'],
        favoriteTeams: ['Зенит', 'Барселона', 'Манчестер Юнайтед'],
        memory: {},
        responseDelay: 1500,
      ),
      ChatBot(
        id: 'funny_commentator',
        name: 'Михаил Юмористинский',
        avatar: '😂',
        description: 'Комментатор с отличным чувством юмора',
        isActive: true,
        personality: 'funny',
        responseStyle: 'entertaining',
        color: Colors.orange,
        expertise: ['юмор', 'интересные факты', 'истории', 'комментарии'],
        favoriteTeams: ['Спартак', 'Ливерпуль', 'Боруссия Дортмунд'],
        memory: {},
        responseDelay: 2000,
      ),
      ChatBot(
        id: 'stats_expert',
        name: 'Дмитрий Статистиков',
        avatar: '📈',
        description: 'Профессиональный статистик',
        isActive: true,
        personality: 'professional',
        responseStyle: 'factual',
        color: Colors.green,
        expertise: ['цифры', 'рекорды', 'тенденции', 'анализ данных'],
        favoriteTeams: ['ЦСКА', 'Бавария', 'Ювентус'],
        memory: {},
        responseDelay: 1200,
      ),
      ChatBot(
        id: 'historian',
        name: 'Сергей Историков',
        avatar: '📚',
        description: 'Спортивный историк и архивариус',
        isActive: true,
        personality: 'knowledgeable',
        responseStyle: 'storytelling',
        color: Colors.purple,
        expertise: ['история', 'легенды', 'эволюция', 'архивы'],
        favoriteTeams: ['Динамо', 'Реал Мадрид', 'Милан'],
        memory: {},
        responseDelay: 1800,
      ),
    ]);
  }

  Future<void> _loadDefaultSettings() async {
    _chatSettings['default'] = ChatSettings(
      id: 'default',
      enableBotResponses: true,
      translationEnabled: false,
      soundEnabled: true,
      vibrationEnabled: true,
      fontSize: 16.0,
      theme: ThemeMode.light,
    );
  }

  // === ОСНОВНЫЕ МЕТОДЫ ЧАТА ===

  Future<List<ChatMessage>> loadMessages(String roomId, {int limit = 50, int offset = 0}) async {
    await _simulateNetworkDelay();

    if (!_roomMessages.containsKey(roomId)) {
      _roomMessages[roomId] = await _generateSampleMessages(roomId);
    }

    final allMessages = _roomMessages[roomId]!;
    final startIndex = max(0, allMessages.length - offset - limit);
    final endIndex = allMessages.length - offset;

    if (startIndex >= endIndex) return [];

    return allMessages.sublist(startIndex, endIndex).reversed.toList();
  }

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
    _notifyMessageUpdate(message.roomId);

    // Обновляем контекст разговора
    _updateConversationContext(message.roomId, message.text, message.sender);

    // Автоматические ответы ботов
    final settings = _chatSettings[message.roomId] ?? _chatSettings['default']!;
    if (settings.enableBotResponses &&
        message.messageType == MessageType.text &&
        !message.sender.contains('Бот') &&
        !message.isBot) {
      _triggerBotResponses(message.roomId, message.text, message.sender);
    }

    return sentMessage;
  }

  void _updateConversationContext(String roomId, String message, String sender) {
    _conversationContext[roomId] ??= [];
    _conversationContext[roomId]!.add('$sender: $message');

    // Ограничиваем размер контекста
    if (_conversationContext[roomId]!.length > 10) {
      _conversationContext[roomId]!.removeAt(0);
    }

    _lastUserMessage[roomId] = message;
  }

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
    _notifyMessageUpdate(roomId);

    return updatedMessage;
  }

  Future<bool> deleteMessage(String messageId, String roomId) async {
    await _simulateNetworkDelay();

    final messages = _roomMessages[roomId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) return false;

    messages.removeAt(messageIndex);
    _notifyMessageUpdate(roomId);

    return true;
  }

  // === УЛУЧШЕННАЯ СИСТЕМА БОТОВ ===

  void _triggerBotResponses(String roomId, String userMessage, String userName) async {
    final activeBots = _getActiveBotsForRoom(roomId);

    for (final bot in activeBots) {
      if (_shouldBotRespond(bot, userMessage, roomId)) {
        // Случайная задержка для естественности
        final delay = bot.responseDelay + _random.nextInt(2000);
        await Future.delayed(Duration(milliseconds: delay));

        final response = await _generateBotResponse(bot, userMessage, roomId, userName);
        if (response.isNotEmpty) {
          final botMessage = ChatMessage(
            id: 'bot-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(1000)}',
            roomId: roomId,
            text: response,
            sender: bot.name,
            time: DateTime.now().add(Duration(milliseconds: delay)),
            isMe: false,
            messageType: MessageType.text,
            status: MessageStatus.sent,
            userColor: bot.color,
            userAvatar: bot.avatar,
            isBot: true,
            botId: bot.id,
            botPersonality: bot.personality,
          );

          _roomMessages[roomId]!.add(botMessage);
          _notifyMessageUpdate(roomId);

          // Обновляем контекст ответом бота
          _updateConversationContext(roomId, response, bot.name);
        }
      }
    }
  }

  List<ChatBot> _getActiveBotsForRoom(String roomId) {
    return _availableBots.where((bot) => bot.isActive).toList();
  }

  bool _shouldBotRespond(ChatBot bot, String userMessage, String roomId) {
    final message = userMessage.toLowerCase();
    final responseChance = _random.nextDouble();

    // Боты запоминают контекст и активнее реагируют на "свои" темы
    final context = _conversationContext[roomId] ?? [];
    final hasRelevantContext = context.any((ctx) =>
        _isTopicRelevantForBot(bot, ctx.toLowerCase()));

    // Повышаем шанс ответа если тема релевантна
    double baseChance = hasRelevantContext ? 0.6 : 0.3;

    // Дополнительные триггеры для каждого бота
    switch (bot.id) {
      case 'sports_analyst':
        if (message.contains('тактик') || message.contains('анализ') ||
            message.contains('стратеги') || message.contains('расстановк') ||
            message.contains('тренер') || message.contains('замен')) {
          return responseChance < 0.85;
        }
        if (message.contains('схем') || message.contains('позицион') ||
            message.contains('построен')) {
          return responseChance < 0.8;
        }
        break;

      case 'funny_commentator':
        if (message.contains('смех') || message.contains('юмор') ||
            message.contains('шутка') || message.contains('забавн') ||
            message.contains('прикол') || message.contains('комментатор')) {
          return responseChance < 0.9;
        }
        if (message.contains('смешн') || message.contains('умора') ||
            message.contains('эфир')) {
          return responseChance < 0.75;
        }
        break;

      case 'stats_expert':
        if (message.contains('статистик') || message.contains('цифр') ||
            message.contains('данн') || message.contains('процент') ||
            message.contains('рекорд') || message.contains('топ')) {
          return responseChance < 0.95;
        }
        if (message.contains('показател') || message.contains('результат') ||
            message.contains('эффективн')) {
          return responseChance < 0.8;
        }
        break;

      case 'historian':
        if (message.contains('истори') || message.contains('прошл') ||
            message.contains('рекорд') || message.contains('лет назад') ||
            message.contains('легенд') || message.contains('классик')) {
          return responseChance < 0.9;
        }
        if (message.contains('архив') || message.contains('в прошлом') ||
            message.contains('вспомн')) {
          return responseChance < 0.7;
        }
        break;
    }

    // Общие спортивные триггеры для всех ботов
    if (message.contains('гол') || message.contains('счет') || message.contains('матч') ||
        message.contains('игр') || message.contains('футбол') || message.contains('команда')) {
      return responseChance < baseChance + 0.2;
    }

    return responseChance < baseChance;
  }

  bool _isTopicRelevantForBot(ChatBot bot, String topic) {
    return bot.expertise.any((expertise) => topic.contains(expertise)) ||
        bot.favoriteTeams.any((team) => topic.contains(team.toLowerCase()));
  }

  Future<String> _generateBotResponse(ChatBot bot, String userMessage, String roomId, String userName) async {
    await _simulateNetworkDelay(1000, 2000);

    final message = userMessage.toLowerCase();
    final context = _conversationContext[roomId] ?? [];

    // Обновляем память бота
    _updateBotMemory(bot, roomId, userMessage, userName);

    switch (bot.id) {
      case 'sports_analyst':
        return _generateSportsAnalystResponse(bot, message, context, userName, roomId);
      case 'funny_commentator':
        return _generateFunnyCommentatorResponse(bot, message, context, userName, roomId);
      case 'stats_expert':
        return _generateStatsExpertResponse(bot, message, context, userName, roomId);
      case 'historian':
        return _generateHistorianResponse(bot, message, context, userName, roomId);
      default:
        return '';
    }
  }

  void _updateBotMemory(ChatBot bot, String roomId, String message, String userName) {
    bot.memory[roomId] ??= {};
    bot.memory[roomId]!['last_interaction'] = DateTime.now().toString();
    bot.memory[roomId]!['last_user'] = userName;
    bot.memory[roomId]!['interaction_count'] =
        (bot.memory[roomId]!['interaction_count'] ?? 0) + 1;

    // Запоминаем ключевые моменты из сообщения
    if (message.toLowerCase().contains('любим')) {
      bot.memory[roomId]!['user_preference_$userName'] = 'упомянул предпочтения';
    }

    if (message.toLowerCase().contains('команда')) {
      bot.memory[roomId]!['last_team_mention'] = DateTime.now().toString();
    }
  }

  // === УЛУЧШЕННЫЕ ГЕНЕРАТОРЫ ОТВЕТОВ ===

  String _generateSportsAnalystResponse(ChatBot bot, String message, List<String> context, String userName, String roomId) {
    final memory = bot.memory[roomId] ?? {};
    final lastUser = memory['last_user'] ?? userName;
    final interactionCount = memory['interaction_count'] ?? 0;

    // Анализ контекста для более релевантного ответа
    final hasGoalContext = context.any((msg) => msg.toLowerCase().contains('гол'));
    final hasTacticContext = context.any((msg) => msg.toLowerCase().contains('тактик'));
    final hasDefenseContext = context.any((msg) => msg.toLowerCase().contains('защит'));
    final hasAttackContext = context.any((msg) => msg.toLowerCase().contains('атак'));

    // Персонализированное обращение
    final personalization = interactionCount > 3 ? ', друг' : '';

    if (hasGoalContext) {
      final goalResponses = [
        '🥅 Интересно разобрать этот гол детально$personalization. Вижу, как $lastUser обратил внимание на ключевой момент. По-моему, решающим была работа крайнего защитника - он создал пространство для паса.',
        '📊 Анализируя голевую ситуацию$personalization: команда использовала классическую схему "стенка в два касания". $lastUser, вы заметили, как сместился центр атаки перед ударом?',
        '🎯 Этот гол напомнил мне матч 2018 года$personalization. Тактически все было построено на быстром переходе. $lastUser, как вам реализация в сравнении с прошлыми сезонами?',
        '💫 Прекрасный гол$personalization! Если анализировать момент: игра в одно касание, смещение защитной линии... $lastUser, вы видели, как организовано движение без мяча?',
      ];
      return goalResponses[_random.nextInt(goalResponses.length)];
    }

    if (hasTacticContext) {
      final tacticResponses = [
        '🧩 Говоря о тактике$personalization, сейчас наблюдаю интересный тренд - многие команды переходят на гибридную защиту. $lastUser, как вы думаете, это работает против современных атак?',
        '⚙️ В тактическом плане сегодняшний матч показал эволюцию прессинга$personalization. Команды стали действовать умнее, а не агрессивнее. Ваше мнение, $lastUser?',
        '🔧 Интересная тактическая расстановка$personalization. Заметил, как изменилась плотность в центре поля. $lastUser, вы следили за перемещениями опорных полузащитников?',
      ];
      return tacticResponses[_random.nextInt(tacticResponses.length)];
    }

    if (hasDefenseContext) {
      final defenseResponses = [
        '🛡️ Анализ оборонительных действий$personalization показывает прогресс в организации. $lastUser, вы обратили внимание на синхронность перемещений защитной линии?',
        '📏 В защите сегодня интересно строилась линия офсайда$personalization. $lastUser, как вам работа крайних защитников в страховке?',
      ];
      return defenseResponses[_random.nextInt(defenseResponses.length)];
    }

    // Умные ответы с персонализацией
    final personalizedResponses = [
      '🔍 $lastUser, вы подняли интересный вопрос$personalization. Если анализировать последние матчи, то видна четкая тенденция к увеличению контр-атакующих действий. Как вам такая эволюция игры?',
      '📈 На основе вашего комментария$personalization, хочу добавить: современный футбол требует универсальности. Игроки теперь должны уметь работать в разных схемах. Согласны?',
      '💭 Мне нравится ваш подход к анализу$personalization. Кстати, вчера пересматривал матч и заметил интересную деталь в построении атаки... Хотите обсудить?',
      '🎓 Профессиональный взгляд$personalization, $lastUser! Добавлю, что важна не только техника, но и тактическая дисциплина. Вы согласны с этим утверждением?',
      '⚽ Интересная мысль$personalization! Если углубиться в анализ, то можно заметить...',
    ];

    return personalizedResponses[_random.nextInt(personalizedResponses.length)];
  }

  String _generateFunnyCommentatorResponse(ChatBot bot, String message, List<String> context, String userName, String roomId) {
    final memory = bot.memory[roomId] ?? {};
    final lastUser = memory['last_user'] ?? userName;
    final interactionCount = memory['interaction_count'] ?? 0;

    final personalization = interactionCount > 2 ? ', дружище' : '';

    // Анализ юмористического контекста
    final hasFunnyContext = context.any((msg) =>
    msg.toLowerCase().contains('смех') ||
        msg.toLowerCase().contains('шутк') ||
        msg.toLowerCase().contains('прикол'));

    final hasMistakeContext = context.any((msg) =>
    msg.toLowerCase().contains('ошибк') ||
        msg.toLowerCase().contains('промах'));

    final hasDramaContext = context.any((msg) =>
    msg.toLowerCase().contains('драм') ||
        msg.toLowerCase().contains('эмоци'));

    if (hasMistakeContext) {
      final mistakeJokes = [
        '🤦‍♂️ Этот момент был смешнее$personalization, чем моя попытка сыграть в футбол после новогоднего стола! $lastUser, вы тоже заметили, как игрок пытался поймать мяч, словно это была горячая картошка? 😄',
        '🎪 Если бы это было цирковое представление$personalization, то клоуны бы аплодировали! $lastUser, признавайтесь, вы тоже сначала подумали, что это специальный трюк? 🤡',
        '🍌 Этот промах достоин отдельного юмористического обзора$personalization! $lastUser, мне кажется, мяч сегодня решил пошутить над всеми нами!',
        '🎭 Настоящий театр абсурда$personalization! $lastUser, иногда кажется, что мы на комедийном шоу, а не на футболе! 😂',
      ];
      return mistakeJokes[_random.nextInt(mistakeJokes.length)];
    }

    if (hasFunnyContext) {
      final funnyResponses = [
        '😂 Ох, $lastUser$personalization, вы знаете, это напомнило мне один забавный случай на тренировке... Как-то раз наш вратарь перепутал свои ворота с чужими! Представляете? 🤪',
        '🎭 $lastUser, ваш юмор просто великолепен$personalization! Кстати, знаете, почему футболисты носят трусы? Потому что шорты звучало бы не так солидно! 😄',
        '🤣 Смех продлевает жизнь$personalization, как и хороший футбол! $lastUser, давайте вместе посмеемся над этим великолепным моментом!',
      ];
      return funnyResponses[_random.nextInt(funnyResponses.length)];
    }

    if (hasDramaContext) {
      final dramaJokes = [
        '🎬 Эта драма достойна "Оскара"$personalization! $lastUser, мне кажется, мы наблюдаем не футбол, а настоящий сериал! 📺',
        '💔 Ох уж эти футбольные страсти$personalization! $lastUser, иногда кажется, что эмоций здесь больше, чем в мыльной опере! 😅',
      ];
      return dramaJokes[_random.nextInt(dramaJokes.length)];
    }

    // Умные шутки с спортивным контекстом
    final smartJokes = [
      '😄 $lastUser, отличное замечание$personalization! Это напомнило мне, как один тренер сказал: "Футбол - это как шахматы, только фигуры бегают, а иногда падают красиво!" Как вам такое сравнение?',
      '🤣 Говоря о сегодняшней игре$personalization, мне кажется, VAR сегодня работал дольше, чем я ищу свои ключи по утрам! Шучу, конечно... Или нет? 😉',
      '🎤 $lastUser, знаете$personalization, комментаторская работа - это когда ты пытаешься объяснить, почему 22 человека бегают за одним мячом, и делаешь вид, что это самое важное событие в мире! Люблю свою работу!',
      '⚽ Футбол - это жизнь$personalization, $lastUser! Иногда смешная, иногда драматичная, но всегда непредсказуемая! 😄',
      '🌟 $lastUser$personalization, ваш комментарий просто блестящий! Надо бы мне его в свою копилку юмора добавить! 😊',
    ];

    return smartJokes[_random.nextInt(smartJokes.length)];
  }

  String _generateStatsExpertResponse(ChatBot bot, String message, List<String> context, String userName, String roomId) {
    final memory = bot.memory[roomId] ?? {};
    final lastUser = memory['last_user'] ?? userName;
    final interactionCount = memory['interaction_count'] ?? 0;

    final personalization = interactionCount > 3 ? ', коллега' : '';

    // Генерация реалистичных статистических данных
    final possession = '${_random.nextInt(20) + 40}%';
    final passes = _random.nextInt(300) + 500;
    final shots = _random.nextInt(15) + 8;
    final goals = _random.nextInt(4) + 1;
    final passAccuracy = '${_random.nextInt(15) + 80}%';
    final distance = _random.nextInt(50) + 110;

    // Контекстный анализ
    final hasStatsContext = context.any((msg) =>
    msg.toLowerCase().contains('статистик') ||
        msg.toLowerCase().contains('цифр'));

    final hasComparisonContext = context.any((msg) =>
    msg.toLowerCase().contains('сравнен') ||
        msg.toLowerCase().contains('лучш'));

    final hasEfficiencyContext = context.any((msg) =>
    msg.toLowerCase().contains('эффектив') ||
        msg.toLowerCase().contains('результат'));

    if (hasStatsContext) {
      final statsResponses = [
        '📊 $lastUser$personalization, по последним данным: владение мячом $possession, точность передач $passAccuracy. Интересно, что эти цифры на 15% выше среднего по лиге. Как вам такая динамика?',
        '🔢 Глубокий анализ показывает$personalization: команда совершила $passes передач, из которых $passAccuracy были точными. $lastUser, вы заметили корреляцию между количеством передач и созданными моментами?',
        '📈 Статистика впечатляет$personalization: $shots ударов, $goals голов, дистанция пробега $distance км. $lastUser, какие показатели вас удивили больше всего?',
      ];
      return statsResponses[_random.nextInt(statsResponses.length)];
    }

    if (hasComparisonContext) {
      final comparisonResponses = [
        '📈 $lastUser$personalization, для сравнения: в прошлом сезоне показатель был на 8% ниже. Сейчас команда демонстрирует прогресс в завершающих действиях - $shots ударов, $goals голов.',
        '⚖️ Интересное сравнение$personalization! Если анализировать статистику, то нынешний состав на 12% эффективнее в атаке, но на 5% слабее в обороне по сравнению с прошлым годом.',
        '🔍 Сравнительный анализ$personalization показывает рост на 7% по ключевым показателям. $lastUser, как вам такие темпы прогресса?',
      ];
      return comparisonResponses[_random.nextInt(comparisonResponses.length)];
    }

    if (hasEfficiencyContext) {
      final efficiency = ((goals/shots)*100).toStringAsFixed(1);
      final efficiencyResponses = [
        '🎯 Эффективность атаки$personalization: $efficiency% против средних 9.2% по лиге. $lastUser, впечатляющий результат, не находите?',
        '💫 Показатели результативности$personalization на высоте! $lastUser, команда демонстрирует отличную реализацию моментов.',
      ];
      return efficiencyResponses[_random.nextInt(efficiencyResponses.length)];
    }

    // Умные статистические инсайты
    final insightResponses = [
      '💡 $lastUser$personalization, на основе сегодняшней статистики хочу отметить: команда показывает лучшие результаты при владении мячом около 55%. Сейчас у них $possession - очень близко к идеалу!',
      '🎯 $lastUser, вы обратили внимание на статистику$personalization? $shots ударов, $goals голов - это эффективность около ${((goals/shots)*100).toStringAsFixed(1)}%. Для сравнения, средний показатель лиги - 9.2%.',
      '📋 Анализируя цифры$personalization: команда делает акцент на комбинационную игру. $passes передач за матч - это на 18% выше среднего. Как вам такой стиль?',
      '🔬 Глубокое погружение в статистику$personalization открывает интересные детали. $lastUser, хотите обсудить конкретные показатели?',
      '📊 $lastUser$personalization, статистика - это не просто цифры, это история игры! Сегодня мы видели отличные показатели по всем фронтам.',
    ];

    return insightResponses[_random.nextInt(insightResponses.length)];
  }

  String _generateHistorianResponse(ChatBot bot, String message, List<String> context, String userName, String roomId) {
    final memory = bot.memory[roomId] ?? {};
    final lastUser = memory['last_user'] ?? userName;
    final interactionCount = memory['interaction_count'] ?? 0;

    final personalization = interactionCount > 2 ? ', знаток' : '';

    // Исторические данные и факты
    final yearsAgo = _random.nextInt(20) + 5;
    final recordYears = _random.nextInt(30) + 10;
    final historicalScore = '${_random.nextInt(4) + 1}:${_random.nextInt(3)}';
    final decade = 1990 + _random.nextInt(3) * 10;

    // Анализ исторического контекста
    final hasHistoryContext = context.any((msg) =>
    msg.toLowerCase().contains('истори') ||
        msg.toLowerCase().contains('прошл'));

    final hasRecordContext = context.any((msg) =>
    msg.toLowerCase().contains('рекорд') ||
        msg.toLowerCase().contains('достижен'));

    final hasLegendContext = context.any((msg) =>
    msg.toLowerCase().contains('легенд') ||
        msg.toLowerCase().contains('звезд'));

    if (hasRecordContext) {
      final recordResponses = [
        '🏆 $lastUser$personalization, говоря о рекордах, текущая серия побед напоминает мне достижение ${recordYears}-летней давности. Тогда команда выиграла ${_random.nextInt(10) + 15} матчей подряд!',
        '📜 Интересный факт$personalization: нынешний бомбардир повторил рекорд клуба, установленный еще в 90-х. 25 голов за сезон - впечатляющее достижение!',
        '🥇 Историческое сравнение$personalization показывает: эта команда приближается к рекорду сезона ${2000 + _random.nextInt(20)} года. $lastUser, верите в новую историю?',
      ];
      return recordResponses[_random.nextInt(recordResponses.length)];
    }

    if (hasHistoryContext) {
      final historyResponses = [
        '🕰️ $lastUser$personalization, вы затронули интересную тему! Ровно $yearsAgo лет назад в такой же день команда сыграла со счетом $historicalScore. История любит повторяться, не находите?',
        '📖 Изучая исторические параллели$personalization, вижу много общего с тактикой ${decade}-х годов. Те же принципы, но современное исполнение.',
        '🏛️ Погружаясь в историю$personalization: этот стадион видел много великих матчей. $lastUser, какая историческая встреча вам запомнилась больше всего?',
      ];
      return historyResponses[_random.nextInt(historyResponses.length)];
    }

    if (hasLegendContext) {
      final legendResponses = [
        '⭐ Говоря о легендах$personalization, нельзя не вспомнить великих игроков прошлого. $lastUser, у вас есть любимый футболист из прошлой эпохи?',
        '🎖️ Исторические личности$personalization формировали этот вид спорта. $lastUser, интересно, чья карьера вас вдохновляет больше всего?',
      ];
      return legendResponses[_random.nextInt(legendResponses.length)];
    }

    // Умные исторические сравнения
    final historicalInsights = [
      '🎭 $lastUser$personalization, знаете, что меня всегда восхищает? Как эволюционировала тактика за последние 30 лет. От катанья мяча до сложных прессинговых схем. И ведь основы остались теми же!',
      '💭 Люблю проводить исторические параллели$personalization. Сегодняшний матч напомнил мне игру $yearsAgo-летней давности - та же страсть, те же эмоции, только технологии изменились.',
      '📚 $lastUser$personalization, как историк отмечу: современный футбол унаследовал лучшие черты разных эпох. Комбинационная игра 80-х, физическая готовность 2000-х и тактическая гибкость сегодняшнего дня.',
      '🌍 Футбол - это живая история$personalization. $lastUser, каждая игра пишет новую страницу в летописи этого прекрасного спорта!',
      '🕰️ Оглядываясь в прошлое$personalization, понимаешь, как далеко мы продвинулись. $lastUser, интересно, что скажут о нашем времени через 20 лет?',
    ];

    return historicalInsights[_random.nextInt(historicalInsights.length)];
  }

  // === УПРАВЛЕНИЕ БОТАМИ ===

  List<ChatBot> getAvailableBots() => List.from(_availableBots);

  Future<void> toggleBot(String botId, bool active) async {
    final botIndex = _availableBots.indexWhere((b) => b.id == botId);
    if (botIndex != -1) {
      _availableBots[botIndex] = _availableBots[botIndex].copyWith(isActive: active);
    }
  }

  Future<List<ChatBot>> getActiveBots(String roomId) async {
    await _simulateNetworkDelay(200, 500);
    return _availableBots.where((bot) => bot.isActive).toList();
  }

  // === УЛУЧШЕННЫЕ AI ОТВЕТЫ С КОНТЕКСТОМ ===

  Future<String> getAIResponse(String userMessage, String roomId, {String? context}) async {
    await _simulateNetworkDelay(800, 2000);

    _lastUserMessage[roomId] = userMessage;
    _conversationContext[roomId] ??= [];
    _conversationContext[roomId]!.add(userMessage);

    if (_conversationContext[roomId]!.length > 5) {
      _conversationContext[roomId]!.removeAt(0);
    }

    final responses = await _getEnhancedResponses(userMessage, roomId, context);
    final selectedResponse = responses[_random.nextInt(responses.length)];

    _conversationContext[roomId]!.add(selectedResponse);

    return selectedResponse;
  }

  Future<List<String>> _getEnhancedResponses(String message, String roomId, String? context) async {
    message = message.toLowerCase();
    final contextMessages = _conversationContext[roomId] ?? [];
    final lastUserMessage = _lastUserMessage[roomId] ?? '';

    // Анализ контекста разговора
    final hasGreetingContext = contextMessages.any((msg) =>
    msg.toLowerCase().contains('привет') ||
        msg.toLowerCase().contains('здравств'));

    final hasQuestionContext = message.contains('?') ||
        contextMessages.any((msg) => msg.contains('?'));

    final hasThanksContext = message.contains('спас') || message.contains('благодар');

    // Умные приветствия с учетом контекста
    if (hasGreetingContext || message.contains('привет') || message.contains('hi')) {
      final timeOfDay = _getTimeOfDay();
      return [
        'Привет! $timeOfDay Рад вас видеть! Как вам последние спортивные события? 📅',
        'Здравствуйте! $timeOfDay Только что анализировал вчерашние матчи - есть о чем поговорить! ⚽',
        'Приветствую! $timeOfDay Готов к обсуждению футбола? Сегодня были интересные трансферные слухи! 🔄',
        '$timeOfDay Коллега! Как настроение? Готовы к обсуждению футбольных страстей? 🎯',
      ];
    }

    // Ответы на благодарности
    if (hasThanksContext) {
      return [
        'Всегда рад помочь! Футбол объединяет, а обсуждение делает его еще интереснее! 🤝',
        'Не стоит благодарностей! Обсуждать футбол с такими энтузиастами - одно удовольствие! ⚽',
        'Рад, что смог быть полезен! Давайте продолжать делиться мнениями о нашей любимой игре! 💫',
      ];
    }

    // Ответы на вопросы
    if (hasQuestionContext) {
      return [
        'Отличный вопрос! Если анализировать последние тенденции, то могу сказать... 📈',
        'Интересный вопрос! Давайте разберем по пунктам... 🔍',
        'Хорошо, что спросили! На основе статистики и анализа... 📊',
        'Вопрос по делу! Позвольте мне поделиться своим взглядом на эту тему... 💭',
      ];
    }

    // Умные ответы с продолжением темы
    if (lastUserMessage.isNotEmpty) {
      return [
        'Продолжая вашу мысль, хочу добавить... 💭',
        'Вы подняли важную тему! Если углубиться в детали... 🎯',
        'Интересный взгляд! А если посмотреть с другой стороны... 🔄',
        'Развивая вашу идею... Что вы думаете о... 💫',
      ];
    }

    // Универсальные умные ответы
    final smartResponses = [
      'Интересная мысль! А вы заметили, как изменилась тактика за последние годы? 🕰️',
      'Согласен с вами! Кстати, сегодня читал статистику - очень показательные цифры. 📈',
      'Хорошее замечание! Это напомнило мне один исторический матч... 📚',
      'Отличная точка зрения! Добавлю, что важна не только техника, но и психология. 🧠',
      'Глубокомысленно! А как вам современные тенденции в футболе? 🔄',
      'Интересный ракурс! Хочу добавить кое-что с аналитической точки зрения... 📊',
    ];

    return smartResponses;
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи!';
    if (hour < 12) return 'Доброе утро!';
    if (hour < 18) return 'Добрый день!';
    return 'Добрый вечер!';
  }

  // === УЧАСТНИКИ И СЕССИИ ===

  Future<List<ChatMember>> loadRoomMembers(String roomId) async {
    await _simulateNetworkDelay(500, 1500);

    if (!_roomMembers.containsKey(roomId)) {
      _roomMembers[roomId] = await _generateSampleMembers();
    }

    return _roomMembers[roomId]!;
  }

  Future<ChatSession> getChatSession(String roomId) async {
    await _simulateNetworkDelay(300, 800);

    final messages = _roomMessages[roomId] ?? [];
    final members = _roomMembers[roomId] ?? [];
    final membersMap = <String, ChatMember>{};
    for (final member in members) {
      membersMap[member.id] = member;
    }

    final stats = await getRoomStats(roomId);

    if (!_chatSessions.containsKey(roomId)) {
      _chatSessions[roomId] = ChatSession(
        roomId: roomId,
        messages: messages,
        members: membersMap,
        settings: _chatSettings[roomId] ?? _chatSettings['default']!,
        lastUpdate: DateTime.now(),
        title: 'Спортивный Чат',
        description: 'Обсуждение последних матчей и спортивных событий',
        createdAt: DateTime.now().subtract(Duration(days: 7)),
        totalMemberCount: members.length,
        totalMessageCount: messages.length,
        onlineMembers: stats['onlineMembers'] as int,
        todayMessages: stats['todayMessages'] as int,
        pinnedMessages: stats['pinnedMessages'] as int,
        activeBots: stats['activeBots'] as int,
      );
    }

    return _chatSessions[roomId]!;
  }

  // === НАСТРОЙКИ ===

  Future<ChatSettings> getChatSettings(String roomId) async {
    await _simulateNetworkDelay(200, 500);
    return _chatSettings[roomId] ?? _chatSettings['default']!;
  }

  Future<void> updateChatSettings(String roomId, ChatSettings settings) async {
    await _simulateNetworkDelay(300, 700);
    _chatSettings[roomId] = settings;
  }

  // === ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ ===

  Future<String?> translateMessage(String text, String targetLanguage) async {
    final cacheKey = '${text.hashCode}_$targetLanguage';

    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey];
    }

    await _simulateNetworkDelay(500, 2000);

    final translations = {
      'Привет всем! Рад присоединиться к обсуждению! 👋':
      'Hello everyone! Glad to join the discussion! 👋',
      'Отличная игра была! Особенно понравилась стратегия команды в защите.':
      'It was a great game! I especially liked the team\'s defensive strategy.',
      'Как вам сегодняшний матч?':
      'What do you think about today\'s match?',
      'Этот игрок просто великолепен!':
      'This player is just magnificent!',
    };

    final translation = translations[text] ?? '$text [Translated]';
    _translationCache[cacheKey] = translation;

    return translation;
  }

  Future<Map<String, Set<String>>?> addReaction(
      String messageId, String roomId, String reaction, String userName) async {
    await _simulateNetworkDelay(100, 300);

    final messages = _roomMessages[roomId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) return null;

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
    _notifyMessageUpdate(roomId);

    return currentReactions;
  }

  Future<bool> toggleMessagePin(String messageId, String roomId) async {
    await _simulateNetworkDelay(200, 500);

    final messages = _roomMessages[roomId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) return false;

    final message = messages[messageIndex];
    messages[messageIndex] = message.copyWith(isPinned: !message.isPinned);
    _notifyMessageUpdate(roomId);

    return true;
  }

  Future<List<ChatMessage>> searchMessages(String roomId, String query) async {
    await _simulateNetworkDelay(300, 1000);

    final messages = _roomMessages[roomId] ?? [];

    return messages.where((message) {
      return message.text.toLowerCase().contains(query.toLowerCase()) &&
          message.messageType == MessageType.text;
    }).toList();
  }

  Future<List<ChatMessage>> getPinnedMessages(String roomId) async {
    await _simulateNetworkDelay(200, 600);

    final messages = _roomMessages[roomId] ?? [];

    return messages.where((message) => message.isPinned).toList();
  }

  // === СТАТИСТИКА И АНАЛИТИКА ===

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
      'activeBots': _availableBots.where((bot) => bot.isActive).length,
    };
  }

  // === STREAM И ОБНОВЛЕНИЯ ===

  Stream<List<ChatMessage>> watchRoomMessages(String roomId) {
    _roomControllers[roomId] ??= StreamController<List<ChatMessage>>.broadcast();
    return _roomControllers[roomId]!.stream;
  }

  void _notifyMessageUpdate(String roomId) {
    if (_roomControllers.containsKey(roomId) && !_roomControllers[roomId]!.isClosed) {
      final messages = _roomMessages[roomId] ?? [];
      _roomControllers[roomId]!.add(List.from(messages));
    }
  }

  // === УТИЛИТЫ ===

  Future<void> _simulateNetworkDelay([int minMs = 300, int maxMs = 1000]) async {
    await Future.delayed(Duration(milliseconds: minMs + _random.nextInt(maxMs - minMs)));
  }

  Future<List<ChatMessage>> _generateSampleMessages(String roomId) async {
    return [
      ChatMessage(
        id: '1',
        roomId: roomId,
        text: 'Добро пожаловать в спортивный чат! 🎉\nОбсуждаем матчи, тактику и все что связано с футболом!',
        sender: 'Система',
        time: DateTime.now().subtract(Duration(hours: 2)),
        isMe: false,
        messageType: MessageType.system,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: '2',
        roomId: roomId,
        text: 'Привет всем! Как вам вчерашний матч? 👋',
        sender: 'Алексей Петров',
        time: DateTime.now().subtract(Duration(hours: 1, minutes: 45)),
        isMe: false,
        status: MessageStatus.sent,
        userColor: Colors.blue,
        userAvatar: 'https://i.pravatar.cc/150?img=1',
      ),
    ];
  }

  Future<List<ChatMember>> _generateSampleMembers() async {
    return [
      ChatMember(
        id: '1',
        name: 'Алексей Петров',
        avatar: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
        role: MemberRole.admin,
        lastSeen: DateTime.now(),
        joinDate: DateTime.now().subtract(Duration(days: 30)),
      ),
      ChatMember(
        id: '2',
        name: 'Мария Иванова',
        avatar: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
        role: MemberRole.moderator,
        lastSeen: DateTime.now(),
        joinDate: DateTime.now().subtract(Duration(days: 25)),
      ),
    ];
  }

  void clearTranslationCache() {
    _translationCache.clear();
  }

  void dispose() {
    for (final controller in _roomControllers.values) {
      controller.close();
    }
    _roomControllers.clear();
  }
}

// Улучшенная модель бота с памятью и характеристиками
class ChatBot {
  final String id;
  final String name;
  final String avatar;
  final String description;
  final bool isActive;
  final String personality;
  final String responseStyle;
  final Color color;
  final List<String> expertise;
  final List<String> favoriteTeams;
  final Map<String, Map<String, dynamic>> memory; // Память бота по комнатам
  final int responseDelay; // Базовая задержка ответа

  ChatBot({
    required this.id,
    required this.name,
    required this.avatar,
    required this.description,
    required this.isActive,
    required this.personality,
    required this.responseStyle,
    required this.color,
    required this.expertise,
    required this.favoriteTeams,
    required this.memory,
    required this.responseDelay,
  });

  ChatBot copyWith({
    String? id,
    String? name,
    String? avatar,
    String? description,
    bool? isActive,
    String? personality,
    String? responseStyle,
    Color? color,
    List<String>? expertise,
    List<String>? favoriteTeams,
    Map<String, Map<String, dynamic>>? memory,
    int? responseDelay,
  }) {
    return ChatBot(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      personality: personality ?? this.personality,
      responseStyle: responseStyle ?? this.responseStyle,
      color: color ?? this.color,
      expertise: expertise ?? this.expertise,
      favoriteTeams: favoriteTeams ?? this.favoriteTeams,
      memory: memory ?? this.memory,
      responseDelay: responseDelay ?? this.responseDelay,
    );
  }
}