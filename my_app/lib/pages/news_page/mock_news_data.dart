// lib/data/mock_news_data.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class MockNewsData {
  // Локальные аватарки
  static const String _ava1 = 'assets/images/ava_news/ava1.png';
  static const String _ava2 = 'assets/images/ava_news/ava2.png';
  static const String _ava3 = 'assets/images/ava_news/ava3.png';
  static const String _ava4 = 'assets/images/ava_news/ava4.png';
  static const String _ava5 = 'assets/images/ava_news/ava5.png';
  static const String _ava6 = 'assets/images/ava_news/ava6.png';
  static const String _ava7 = 'assets/images/ava_news/ava7.png';
  static const String _ava8 = 'assets/images/ava_news/ava8.png';
  static const String _ava9 = 'assets/images/ava_news/ava9.png';
  static const String _ava10 = 'assets/images/ava_news/ava10.png';
  static const String _ava11 = 'assets/images/ava_news/ava11.png';
  static const String _ava12 = 'assets/images/ava_news/ava12.png';

  // Локальные изображения для постов
  static const String _postImage1 = 'assets/images/ava_news/ava1.png';
  static const String _postImage2 = 'assets/images/ava_news/ava2.png';
  static const String _postImage3 = 'assets/images/ava_news/ava3.png';
  static const String _postImage4 = 'assets/images/ava_news/ava4.png';
  static const String _postImage5 = 'assets/images/ava_news/ava5.png';
  static const String _postImage6 = 'assets/images/ava_news/ava6.png';

  static List<dynamic> getMockNews() {
    final now = DateTime.now();
    return [
      // ТЕХНОЛОГИИ
      {
        "id": "tech-1",
        "title": "Искусственный интеллект создал новый лекарственный препарат",
        "description": "Исследователи из MIT использовали ИИ для разработки препарата, способного бороться с устойчивыми к антибиотикам бактериями. Алгоритм проанализировал миллионы соединений за 48 часов!",
        "image": _postImage1,
        "likes": 234,
        "author_name": "Технолог",
        "created_at": now.subtract(Duration(hours: 2)).toIso8601String(),
        "comments": _generateComments(5),
        "hashtags": ["ии", "медицина", "инновации", "наука"],
        "user_tags": {
          "tag1": "Технологии",
          "tag2": "ИИ",
          "tag3": "Будущее"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.purple.value,
        "is_channel_post": false,
        "author_avatar": _ava1,
      },
      {
        "id": "tech-2",
        "title": "Квантовый компьютер побил рекорд вычислений",
        "description": "Новый квантовый процессор выполнил расчет за 200 секунд, который обычному суперкомпьютеру потребовал бы 10 000 лет. Прорыв в области квантовых технологий!",
        "image": _postImage2,
        "likes": 189,
        "author_name": "Квантовый физик",
        "created_at": now.subtract(Duration(hours: 5)).toIso8601String(),
        "comments": _generateComments(3),
        "hashtags": ["квант", "компьютеры", "наука", "технологии"],
        "user_tags": {
          "tag1": "Наука",
          "tag2": "Квант",
          "tag3": "Рекорд"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.indigo.value,
        "is_channel_post": false,
        "author_avatar": _ava2,
      },

      // СПОРТ
      {
        "id": "sport-1",
        "title": "Манчестер Сити выиграл Лигу Чемпионов в драматичном финале",
        "description": "В невероятном матче против Реала Манчестер Сити одержал победу 2:1. Решающий гол на 89-й минуте забил Эрлинг Холанн!",
        "image": _postImage3,
        "likes": 567,
        "author_name": "Спортивный обозреватель",
        "created_at": now.subtract(Duration(hours: 8)).toIso8601String(),
        "comments": _generateComments(12),
        "hashtags": ["футбол", "лигачемпионов", "манчестер", "победа"],
        "user_tags": {
          "tag1": "Фанат Манчестера",
          "tag2": "Спорт",
          "tag3": "Футбол"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.green.value,
        "is_channel_post": false,
        "author_avatar": _ava3,
      },
      {
        "id": "sport-2",
        "title": "Новый сезон Formula 1: революционные изменения в правилах",
        "description": "Сезон 2024 обещает быть самым зрелищным: новые аэродинамические правила, более быстрые машины и возвращение классических трасс!",
        "image": _postImage4,
        "likes": 321,
        "author_name": "Автоэксперт",
        "created_at": now.subtract(Duration(hours: 12)).toIso8601String(),
        "comments": _generateComments(7),
        "hashtags": ["formula1", "автоспорт", "гонки", "2024"],
        "user_tags": {
          "tag1": "Гонки",
          "tag2": "Автоспорт",
          "tag3": "Formula 1"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.red.value,
        "is_channel_post": false,
        "author_avatar": _ava4,
      },

      // ПУТЕШЕСТВИЯ
      {
        "id": "travel-1",
        "title": "Открытие нового маршрута: Япония за 10 дней",
        "description": "Разработал идеальный маршрут по Японии: от неоновых улиц Токио до древних храмов Киото и горячих источников Хаконе. Все самое важное за полторы недели!",
        "image": _postImage5,
        "likes": 156,
        "author_name": "Путешественник",
        "created_at": now.subtract(Duration(hours: 16)).toIso8601String(),
        "comments": _generateComments(9),
        "hashtags": ["путешествия", "япония", "маршрут", "советы"],
        "user_tags": {
          "tag1": "Путешествия",
          "tag2": "Япония",
          "tag3": "Советы"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.teal.value,
        "is_channel_post": false,
        "author_avatar": _ava5,
      },
      {
        "id": "travel-2",
        "title": "Скрытые пляжи Бали: куда поехать, чтобы избежать толп",
        "description": "Открыл для себя потрясающие пляжи на юге Бали, где почти нет туристов. Кристально чистая вода, белый песок и полное уединение!",
        "image": _postImage6,
        "likes": 98,
        "author_name": "Бэкпекер",
        "created_at": now.subtract(Duration(hours: 20)).toIso8601String(),
        "comments": _generateComments(6),
        "hashtags": ["бали", "пляжи", "отдых", "тайныеместа"],
        "user_tags": {
          "tag1": "Бали",
          "tag2": "Пляжи",
          "tag3": "Приключения"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": false,
        "author_avatar": _ava6,
      },

      // КУЛИНАРИЯ
      {
        "id": "food-1",
        "title": "Секреты идеальной пасты карбонара от римского шефа",
        "description": "Научился готовить настоящую карбонару в Риме. Секрет в использовании гуанчиале, пекорино романо и отсутствии сливок!",
        "image": _postImage1,
        "likes": 278,
        "author_name": "Шеф-повар",
        "created_at": now.subtract(Duration(hours: 24)).toIso8601String(),
        "comments": _generateComments(15),
        "hashtags": ["паста", "италия", "рецепт", "кулинария"],
        "user_tags": {
          "tag1": "Кулинария",
          "tag2": "Италия",
          "tag3": "Рецепты"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.orange.value,
        "is_channel_post": false,
        "author_avatar": _ava7,
      },
      {
        "id": "food-2",
        "title": "Домашний хлеб на закваске: полное руководство для начинающих",
        "description": "После 3 месяцев экспериментов нашел идеальную формулу домашнего хлеба. Делюсь пошаговым рецептом и советами по уходу за закваской!",
        "image": _postImage2,
        "likes": 145,
        "author_name": "Пекарь-любитель",
        "created_at": now.subtract(Duration(days: 1, hours: 4)).toIso8601String(),
        "comments": _generateComments(8),
        "hashtags": ["хлеб", "закваска", "выпечка", "рецепт"],
        "user_tags": {
          "tag1": "Выпечка",
          "tag2": "Хлеб",
          "tag3": "Дом"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.amber.value,
        "is_channel_post": false,
        "author_avatar": _ava8,
      },

      // ИСКУССТВО И КУЛЬТУРА
      {
        "id": "art-1",
        "title": "Выставка Ван Гога в Москве: впечатления от посещения",
        "description": "Уникальная возможность увидеть 50 оригинальных работ Ван Гога в Пушкинском музее. Особенно впечатлили 'Звездная ночь' и 'Подсолнухи'!",
        "image": _postImage3,
        "likes": 189,
        "author_name": "Искусствовед",
        "created_at": now.subtract(Duration(days: 1, hours: 8)).toIso8601String(),
        "comments": _generateComments(11),
        "hashtags": ["вангог", "выставка", "искусство", "москва"],
        "user_tags": {
          "tag1": "Искусство",
          "tag2": "Выставка",
          "tag3": "Культура"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.deepPurple.value,
        "is_channel_post": false,
        "author_avatar": _ava9,
      },

      // ОБРАЗОВАНИЕ
      {
        "id": "edu-1",
        "title": "Бесплатные курсы от ведущих университетов мира",
        "description": "Подборка из 20+ бесплатных онлайн-курсов от Stanford, MIT, Harvard. От программирования до философии - учитесь у лучших!",
        "image": _postImage4,
        "likes": 312,
        "author_name": "Образовательный эксперт",
        "created_at": now.subtract(Duration(days: 1, hours: 12)).toIso8601String(),
        "comments": _generateComments(18),
        "hashtags": ["образование", "курсы", "онлайн", "учеба"],
        "user_tags": {
          "tag1": "Образование",
          "tag2": "Курсы",
          "tag3": "Развитие"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.cyan.value,
        "is_channel_post": false,
        "author_avatar": _ava10,
      },

      // КАНАЛЬНЫЕ ПОСТЫ
      {
        "id": "channel-1",
        "title": "Важное обновление платформы - новые функции!",
        "description": "Добавили темную тему, улучшили производительность и исправили основные ошибки. Теперь приложение работает еще быстрее и стабильнее!",
        "image": _postImage5,
        "likes": 432,
        "author_name": "Система",
        "channel_name": "Официальные новости",
        "created_at": now.subtract(Duration(days: 2)).toIso8601String(),
        "comments": _generateComments(23),
        "hashtags": ["обновление", "новости", "фичи", "платформа"],
        "user_tags": {
          "tag1": "Официально",
          "tag2": "Обновление",
          "tag3": "Важно"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": true,
        "author_avatar": _ava1,
      },
      {
        "id": "channel-2",
        "title": "Конкурс для создателей контента - призовой фонд 10,000",
        "description": "Запускаем ежегодный конкурс на лучший контент. Победители получат денежные призы и промо-поддержку на нашей платформе!",
        "image": _postImage6,
        "likes": 298,
        "author_name": "Система",
        "channel_name": "События и конкурсы",
        "created_at": now.subtract(Duration(days: 3)).toIso8601String(),
        "comments": _generateComments(34),
        "hashtags": ["конкурс", "призы", "контент", "события"],
        "user_tags": {
          "tag1": "Конкурс",
          "tag2": "События",
          "tag3": "Призы"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.pink.value,
        "is_channel_post": true,
        "author_avatar": _ava2,
      },

      // ЛИЧНЫЕ ИСТОРИИ
      {
        "id": "story-1",
        "title": "Как я научился программировать за 6 месяцев и нашел работу",
        "description": "Прошел путь от полного новичка до junior-разработчика. Делюсь ресурсами, советами и личным опытом. Все реально, главное - начать!",
        "image": _postImage1,
        "likes": 567,
        "author_name": "Самоучка",
        "created_at": now.subtract(Duration(days: 4)).toIso8601String(),
        "comments": _generateComments(45),
        "hashtags": ["программирование", "карьера", "обучение", "история"],
        "user_tags": {
          "tag1": "История",
          "tag2": "Обучение",
          "tag3": "Успех"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.green.value,
        "is_channel_post": false,
        "author_avatar": _ava11,
      },

      // НАУЧПОП
      {
        "id": "science-1",
        "title": "Космический телескоп James Webb обнаружил новую галактику",
        "description": "Уникальное открытие: найдена галактика, существовавшая всего через 300 миллионов лет после Большого взрыва!",
        "image": _postImage2,
        "likes": 421,
        "author_name": "Астроном",
        "created_at": now.subtract(Duration(days: 5)).toIso8601String(),
        "comments": _generateComments(27),
        "hashtags": ["космос", "наука", "галактика", "открытие"],
        "user_tags": {
          "tag1": "Наука",
          "tag2": "Космос",
          "tag3": "Открытие"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.deepOrange.value,
        "is_channel_post": false,
        "author_avatar": _ava12,
      }
    ];
  }

  // Генерация реалистичных комментариев
  static List<dynamic> _generateComments(int count) {
    final comments = [
      {"author": "Алексей", "text": "Отличный пост!", "time": "2 часа назад", "author_avatar": _ava1},
      {"author": "Мария", "text": "Спасибо за информацию!", "time": "3 часа назад", "author_avatar": _ava2},
      {"author": "Дмитрий", "text": "Интересная тема, жду продолжения", "time": "5 часов назад", "author_avatar": _ava3},
      {"author": "Екатерина", "text": "Полностью согласен с автором", "time": "6 часов назад", "author_avatar": _ava4},
      {"author": "Сергей", "text": "Есть вопросы по этой теме", "time": "7 часов назад", "author_avatar": _ava5},
      {"author": "Ольга", "text": "Отличная работа!", "time": "8 часов назад", "author_avatar": _ava6},
      {"author": "Иван", "text": "Полезная информация, спасибо", "time": "9 часов назад", "author_avatar": _ava7},
      {"author": "Анна", "text": "Жду новых постов от вас", "time": "10 часов назад", "author_avatar": _ava8},
      {"author": "Павел", "text": "Интересная точка зрения", "time": "11 часов назад", "author_avatar": _ava9},
      {"author": "Наталья", "text": "Отлично написано!", "time": "12 часов назад", "author_avatar": _ava10},
    ];

    return comments.take(count).toList();
  }

  // Методы для получения конкретных демо-данных
  static Map<String, dynamic> getWelcomeMessage() {
    return getMockNews()[0] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getSportsNews() {
    return getMockNews()[2] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getTechNews() {
    return getMockNews()[0] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getTravelNews() {
    return getMockNews()[4] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getFoodNews() {
    return getMockNews()[6] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getChannelPost() {
    return getMockNews()[10] as Map<String, dynamic>;
  }

  // Метод для получения демо-данных по типу
  static List<dynamic> getNewsByType(String type) {
    final allNews = getMockNews();

    switch (type) {
      case 'channel':
        return allNews.where((news) => news['is_channel_post'] == true).toList();
      case 'regular':
        return allNews.where((news) => news['is_channel_post'] != true).toList();
      case 'tech':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final userTags = news['user_tags']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();
          return title.contains('ии') || title.contains('техн') || title.contains('компьютер') ||
              userTags.contains('технологии') || userTags.contains('ии') || userTags.contains('наука') ||
              hashtags.contains('технологии') || hashtags.contains('ии') || hashtags.contains('наука');
        }).toList();
      case 'sports':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final userTags = news['user_tags']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();
          return title.contains('спорт') || title.contains('футбол') || title.contains('гонк') ||
              userTags.contains('спорт') || userTags.contains('футбол') || userTags.contains('гонки') ||
              hashtags.contains('спорт') || hashtags.contains('футбол') || hashtags.contains('гонки');
        }).toList();
      case 'travel':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final userTags = news['user_tags']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();
          return title.contains('путешествие') || title.contains('пляж') || title.contains('маршрут') ||
              userTags.contains('путешествия') || userTags.contains('бали') || userTags.contains('япония') ||
              hashtags.contains('путешествия') || hashtags.contains('бали') || hashtags.contains('япония');
        }).toList();
      case 'food':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final userTags = news['user_tags']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();
          return title.contains('паста') || title.contains('хлеб') || title.contains('рецепт') ||
              userTags.contains('кулинария') || userTags.contains('рецепты') || userTags.contains('выпечка') ||
              hashtags.contains('кулинария') || hashtags.contains('рецепты') || hashtags.contains('выпечка');
        }).toList();
      case 'education':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final userTags = news['user_tags']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();
          return title.contains('курс') || title.contains('обучение') || title.contains('образование') ||
              userTags.contains('образование') || userTags.contains('курсы') || userTags.contains('обучение') ||
              hashtags.contains('образование') || hashtags.contains('курсы') || hashtags.contains('обучение');
        }).toList();
      case 'art':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final userTags = news['user_tags']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();
          return title.contains('выставка') || title.contains('искусство') || title.contains('ван гог') ||
              userTags.contains('искусство') || userTags.contains('выставка') || userTags.contains('культура') ||
              hashtags.contains('искусство') || hashtags.contains('выставка') || hashtags.contains('культура');
        }).toList();
      case 'science':
        return allNews.where((news) {
          final title = news['title']?.toString().toLowerCase() ?? '';
          final userTags = news['user_tags']?.toString().toLowerCase() ?? '';
          final hashtags = (news['hashtags'] as List).join(' ').toLowerCase();
          return title.contains('космос') || title.contains('наука') || title.contains('открытие') ||
              userTags.contains('наука') || userTags.contains('космос') || userTags.contains('открытие') ||
              hashtags.contains('наука') || hashtags.contains('космос') || hashtags.contains('открытие');
        }).toList();
      case 'popular':
        return allNews.where((news) => (news['likes'] ?? 0) > 300).toList();
      case 'recent':
        final now = DateTime.now();
        return allNews.where((news) {
          final createdAt = DateTime.tryParse(news['created_at'] ?? '');
          if (createdAt == null) return false;
          return now.difference(createdAt).inHours < 24;
        }).toList();
      default:
        return allNews;
    }
  }

  // Метод для получения случайного демо-сообщения
  static Map<String, dynamic> getRandomNews() {
    final allNews = getMockNews();
    final random = DateTime.now().millisecond % allNews.length;
    return allNews[random] as Map<String, dynamic>;
  }

  // Вспомогательный метод для fallback аватарок
  static String _getFallbackAvatarUrl(String userName) {
    final avatars = [
      _ava1, _ava2, _ava3, _ava4, _ava5, _ava6,
      _ava7, _ava8, _ava9, _ava10, _ava11, _ava12
    ];
    final index = userName.hashCode.abs() % avatars.length;
    return avatars[index];
  }

  // НОВЫЙ МЕТОД: Получение цвета тега на основе ID пользователя
  static Color getTagColorForUser(String userName) {
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red,
      Colors.teal, Colors.pink, Colors.indigo, Colors.amber, Colors.cyan,
      Colors.deepOrange, Colors.deepPurple, Colors.lightBlue, Colors.lightGreen,
    ];
    final index = userName.hashCode.abs() % colors.length;
    return colors[index];
  }

  // НОВЫЙ МЕТОД: Получение тегов для конкретного пользователя
  static Map<String, String> getUserTagsForAuthor(String authorName) {
    switch (authorName) {
      case 'Спортивный обозреватель':
        return {"tag1": "Фанат Манчестера", "tag2": "Спорт", "tag3": "Футбол"};
      case 'Автоэксперт':
        return {"tag1": "Гонки", "tag2": "Автоспорт", "tag3": "Formula 1"};
      case 'Технолог':
        return {"tag1": "Технологии", "tag2": "ИИ", "tag3": "Будущее"};
      case 'Квантовый физик':
        return {"tag1": "Наука", "tag2": "Квант", "tag3": "Рекорд"};
      case 'Путешественник':
        return {"tag1": "Путешествия", "tag2": "Япония", "tag3": "Советы"};
      case 'Бэкпекер':
        return {"tag1": "Бали", "tag2": "Пляжи", "tag3": "Приключения"};
      case 'Шеф-повар':
        return {"tag1": "Кулинария", "tag2": "Италия", "tag3": "Рецепты"};
      case 'Пекарь-любитель':
        return {"tag1": "Выпечка", "tag2": "Хлеб", "tag3": "Дом"};
      case 'Искусствовед':
        return {"tag1": "Искусство", "tag2": "Выставка", "tag3": "Культура"};
      case 'Образовательный эксперт':
        return {"tag1": "Образование", "tag2": "Курсы", "tag3": "Развитие"};
      case 'Самоучка':
        return {"tag1": "История", "tag2": "Обучение", "tag3": "Успех"};
      case 'Астроном':
        return {"tag1": "Наука", "tag2": "Космос", "tag3": "Открытие"};
      case 'Система':
        return {"tag1": "Официально", "tag2": "Обновление", "tag3": "Важно"};
      default:
        return {"tag1": "Пользователь", "tag2": "Активность", "tag3": "Контент"};
    }
  }

  // НОВЫЙ МЕТОД: Получение тегов для конкретного поста из мок данных
  static Map<String, String> getMockTagsForPost(String postId) {
    final mockTags = {
      'tech-1': {'tag1': 'Технологии', 'tag2': 'ИИ', 'tag3': 'Будущее'},
      'tech-2': {'tag1': 'Наука', 'tag2': 'Квант', 'tag3': 'Рекорд'},
      'sport-1': {'tag1': 'Фанат Манчестера', 'tag2': 'Спорт', 'tag3': 'Футбол'},
      'sport-2': {'tag1': 'Гонки', 'tag2': 'Автоспорт', 'tag3': 'Formula 1'},
      'travel-1': {'tag1': 'Путешествия', 'tag2': 'Япония', 'tag3': 'Советы'},
      'travel-2': {'tag1': 'Бали', 'tag2': 'Пляжи', 'tag3': 'Приключения'},
      'food-1': {'tag1': 'Кулинария', 'tag2': 'Италия', 'tag3': 'Рецепты'},
      'food-2': {'tag1': 'Выпечка', 'tag2': 'Хлеб', 'tag3': 'Дом'},
      'art-1': {'tag1': 'Искусство', 'tag2': 'Выставка', 'tag3': 'Культура'},
      'edu-1': {'tag1': 'Образование', 'tag2': 'Курсы', 'tag3': 'Развитие'},
      'channel-1': {'tag1': 'Официально', 'tag2': 'Обновление', 'tag3': 'Важно'},
      'channel-2': {'tag1': 'Конкурс', 'tag2': 'События', 'tag3': 'Призы'},
      'story-1': {'tag1': 'История', 'tag2': 'Обучение', 'tag3': 'Успех'},
      'science-1': {'tag1': 'Наука', 'tag2': 'Космос', 'tag3': 'Открытие'},
    };

    return mockTags[postId] ?? {'tag1': 'Интересное', 'tag2': 'Контент', 'tag3': 'Обсуждение'};
  }

  // НОВЫЙ МЕТОД: Получение цвета для конкретного поста из мок данных
  static Color getMockTagColorForPost(String postId) {
    final mockColors = {
      'tech-1': Colors.purple,
      'tech-2': Colors.indigo,
      'sport-1': Colors.green,
      'sport-2': Colors.red,
      'travel-1': Colors.teal,
      'travel-2': Colors.blue,
      'food-1': Colors.orange,
      'food-2': Colors.amber,
      'art-1': Colors.deepPurple,
      'edu-1': Colors.cyan,
      'channel-1': Colors.blue,
      'channel-2': Colors.pink,
      'story-1': Colors.green,
      'science-1': Colors.deepOrange,
    };

    return mockColors[postId] ?? Colors.blue;
  }
}