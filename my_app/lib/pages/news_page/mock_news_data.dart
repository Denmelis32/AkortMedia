// lib/pages/news_page/mock_news_data.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class MockNewsData {
  // Локальные аватарки (30 штук)
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
  static const String _ava13 = 'assets/images/ava_news/ava13.png';
  static const String _ava14 = 'assets/images/ava_news/ava14.png';
  static const String _ava15 = 'assets/images/ava_news/ava15.png';
  static const String _ava16 = 'assets/images/ava_news/ava16.png';
  static const String _ava17 = 'assets/images/ava_news/ava17.png';
  static const String _ava18 = 'assets/images/ava_news/ava18.png';
  static const String _ava19 = 'assets/images/ava_news/ava19.png';
  static const String _ava20 = 'assets/images/ava_news/ava20.png';
  static const String _ava21 = 'assets/images/ava_news/ava21.png';
  static const String _ava22 = 'assets/images/ava_news/ava22.png';
  static const String _ava23 = 'assets/images/ava_news/ava23.png';
  static const String _ava24 = 'assets/images/ava_news/ava24.png';
  static const String _ava25 = 'assets/images/ava_news/ava25.png';
  static const String _ava26 = 'assets/images/ava_news/ava26.png';
  static const String _ava27 = 'assets/images/ava_news/ava27.png';
  static const String _ava28 = 'assets/images/ava_news/ava28.png';
  static const String _ava29 = 'assets/images/ava_news/ava29.png';
  static const String _ava30 = 'assets/images/ava_news/ava30.png';

  // Локальные изображения для постов
  static const String _postImage1 = 'assets/images/ava_news/ava1.png';
  static const String _postImage2 = 'assets/images/ava_news/ava2.png';
  static const String _postImage3 = 'assets/images/ava_news/ava3.png';
  static const String _postImage4 = 'assets/images/ava_news/ava4.png';
  static const String _postImage5 = 'assets/images/ava_news/ava5.png';
  static const String _postImage6 = 'assets/images/ava_news/ava6.png';

  // СЛОВАРЬ СОПОСТАВЛЕНИЯ АВТОРОВ С АВАТАРКАМИ
  static final Map<String, String> _authorAvatars = {
    // Молодые люди с английскими никнеймами
    'Chloe_Bright': _ava1,
    'Alex_Spark': _ava2,
    'Emma_Star': _ava3,
    'Mike_Jet': _ava4,
    'Lily_Glimmer': _ava5,
    'Jake_Flash': _ava6,
    'Sophie_Ray': _ava7,
    'Ryan_Beam': _ava8,
    'Zoe_Shine': _ava9,
    'Tyler_Blaze': _ava10,
    'Maya_Sun': _ava11,
    'Leo_Moon': _ava12,
    'Ruby_Sky': _ava13,
    'Max_Thunder': _ava14,
    'Ivy_Dream': _ava15,
    'Sam_Fire': _ava16,
    'Nova_Light': _ava17,
    'Kai_Storm': _ava18,
    'Luna_Glow': _ava19,
    'Finn_Wave': _ava20,

    // Авторы обычных новостей
    'Tech_Pro': _ava21,
    'Quantum_Geek': _ava22,
    'Sport_Lover': _ava23,
    'Auto_Expert': _ava24,
    'Travel_Buddy': _ava25,
    'Backpacker_Joe': _ava26,
    'Chef_Master': _ava27,
    'Baking_Queen': _ava28,
    'Art_Lover': _ava29,
    'Edu_Guru': _ava30,
    'SelfTaught_Dev': _ava1,
    'Space_Explorer': _ava2,
    'System_Admin': _ava3,
    'Dev_Girl': _ava4,
    'Fit_Life': _ava5,
    'Philosophy_Geek': _ava6,
    'Coffee_Lover': _ava7,
    'Cat_Mom': _ava8,
    'Tech_Explainer': _ava9,
    'City_News': _ava10,
    'Relax_Seeker': _ava11,
    'Book_Worm': _ava12,
    'Flutter_Dev': _ava13,
    'Monday_Hater': _ava14,
    'Nostalgia_Man': _ava15,
  };

  // СЛОВАРЬ ДЛЯ КОММЕНТАТОРОВ
  static final Map<String, String> _commenterAvatars = {
    'Chloe_Bright': _ava1,
    'Alex_Spark': _ava2,
    'Emma_Star': _ava3,
    'Mike_Jet': _ava4,
    'Lily_Glimmer': _ava5,
    'Jake_Flash': _ava6,
    'Sophie_Ray': _ava7,
    'Ryan_Beam': _ava8,
    'Zoe_Shine': _ava9,
    'Tyler_Blaze': _ava10,
    'Maya_Sun': _ava11,
    'Leo_Moon': _ava12,
    'Ruby_Sky': _ava13,
    'Max_Thunder': _ava14,
    'Ivy_Dream': _ava15,
    'Sam_Fire': _ava16,
    'Nova_Light': _ava17,
    'Kai_Storm': _ava18,
    'Luna_Glow': _ava19,
    'Finn_Wave': _ava20,
    'Science_Nerd': _ava21,
    'Doctor_Who': _ava22,
    'AI_Developer': _ava23,
    'Med_Student': _ava24,
    'Physics_Pro': _ava25,
    'IT_Guy': _ava26,
    'Researcher_X': _ava27,
    'City_Fan': _ava28,
    'Real_Madrid_Fan': _ava29,
    'Football_Analyst': _ava30,
    'Sports_Journalist': _ava1,
    'Football_Lover': _ava2,
    'Ex_Player': _ava3,
    'Dev_Girl': _ava21,
    'Fit_Life': _ava22,
    'Philosophy_Geek': _ava23,
    'Coffee_Lover': _ava24,
    'Cat_Mom': _ava25,
    'Tech_Explainer': _ava26,
    'City_News': _ava27,
    'Relax_Seeker': _ava28,
    'Book_Worm': _ava29,
    'Flutter_Dev': _ava30,
    'Monday_Hater': _ava1,
    'Nostalgia_Man': _ava2,
  };

  // МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ АВТОРА
  static String getAuthorAvatar(String authorName) {
    final avatar = _authorAvatars[authorName];
    if (avatar != null) {
      print('✅ Найден аватар для $authorName: $avatar');
      return avatar;
    }

    // Fallback на первую аватарку
    print('⚠️ Аватар не найден для $authorName, используем fallback');
    return _ava1;
  }

  // МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ КОММЕНТАТОРА
  static String getCommenterAvatar(String commenterName) {
    return _commenterAvatars[commenterName] ?? _getFallbackAvatarUrl(commenterName);
  }

  static List<dynamic> getMockNews() {
    final now = DateTime.now();

    // Собираем ВСЕ посты в один список
    return [
      // ПОЗДРАВЛЕНИЯ С ДНЕМ РОЖДЕНИЯ
      ..._getBirthdayPosts(now),
      // ТЕХНОЛОГИЧЕСКИЕ ПОСТЫ
      ..._getTechPosts(now),
      // СПОРТИВНЫЕ ПОСТЫ
      ..._getSportPosts(now),
      // ЛИЧНЫЕ МЫСЛИ
      ..._getPersonalThoughts(now),
      // ЮМОРИСТИЧЕСКИЕ ПОСТЫ
      ..._getFunnyPosts(now),
      // НОВОСТИ ГОРОДА
      ..._getNewsPosts(now),
      // ВОПРОСЫ
      ..._getQuestionPosts(now),
      // ДОСТИЖЕНИЯ
      ..._getAchievementPosts(now),
      // ПОВСЕДНЕВНЫЕ ПОСТЫ
      ..._getDailyPosts(now),
    ];
  }

  static List<dynamic> _getBirthdayPosts(DateTime now) {
    return [
      {
        "id": "bday-1",
        "title": "С Днем Рождения, Анастасия! 🎉",
        "description": "Настя, желаю тебе самого крутого дня рождения! Пусть твой день будет наполнен классными эмоциями, верными друзьями и незабываемыми моментами!🔥 Сори, что задержался с поздравлением. Я пытался как мог быстрее собрать проект и успеть 🔥",
        "image": _ava1,
        "likes": 15,
        "author_name": "Marincev",
        "created_at": now.subtract(Duration(minutes: 10)).toIso8601String(),
        "comments": _generateBirthdayComments1(),
        "hashtags": ["деньрождения", "праздник", "настя", "вечеринка"],
        "user_tags": {
          "tag1": "Программист",
          "tag2": "Котики",
          "tag3": "Геймер"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.pink.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Chloe_Bright"),
      },
      {
        "id": "bday-2",
        "title": "С Днем Рождения, Королева! 👑",
        "description": "Настя, ты просто нереальная! Еще один год твоей крутости! Желаю тебе успехов во всем, что ты делаешь, и пусть все твои мечты сбудутся в этом году! Давай оторвемся! 🥳",
        "image": _ava2,
        "likes": 12,
        "author_name": "Alex_Spark",
        "created_at": now.subtract(Duration(minutes: 25)).toIso8601String(),
        "comments": _generateBirthdayComments2(),
        "hashtags": ["сдр", "королева", "цели", "успех"],
        "user_tags": {
          "tag1": "Фотограф",
          "tag2": "Путешественник",
          "tag3": "Кофе"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Alex_Spark"),
      },
      {
        "id": "bday-3",
        "title": "С Днем Рождения, Красотка! ✨",
        "description": "Настя, ты просто сияешь! Горжусь всем, чего ты достигла. Не могу дождаться, чтобы увидеть, что принесет тебе этот год! Продолжай сиять! 🌟",
        "image": _ava3,
        "likes": 18,
        "author_name": "Emma_Star",
        "created_at": now.subtract(Duration(minutes: 45)).toIso8601String(),
        "comments": _generateBirthdayComments3(),
        "hashtags": ["сдр", "красота", "успех", "сияние"],
        "user_tags": {
          "tag1": "Художник",
          "tag2": "Книголюб",
          "tag3": "Растения"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.purple.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Emma_Star"),
      },
      {
        "id": "bday-4",
        "title": "Давай праздновать! 🎊",
        "description": "Настя! Компания готова оторваться на твоем дне рождения! Желаю тебе бесконечного смеха, сумасшедших приключений и воспоминаний, которые останутся навсегда! Ты этого заслуживаешь! 💫",
        "image": _ava4,
        "likes": 9,
        "author_name": "Mike_Jet",
        "created_at": now.subtract(Duration(hours: 1)).toIso8601String(),
        "comments": _generateBirthdayComments4(),
        "hashtags": ["праздник", "компания", "веселье", "воспоминания"],
        "user_tags": {
          "tag1": "Музыкант",
          "tag2": "Спортсмен",
          "tag3": "Психология"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.green.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Mike_Jet"),
      },
      {
        "id": "bday-5",
        "title": "Поздравляю с Днем Рождения! 🌈",
        "description": "С днем рождения самого искреннего человека, которого я знаю! Твоя энергия заразительна, а сердце чистое золото. Пусть этот год принесет тебе все, о чем ты мечтаешь! ✨",
        "image": _ava5,
        "likes": 14,
        "author_name": "Lily_Glimmer",
        "created_at": now.subtract(Duration(hours: 1, minutes: 15)).toIso8601String(),
        "comments": _generateBirthdayComments5(),
        "hashtags": ["энергия", "мечты", "позитив", "чистота"],
        "user_tags": {
          "tag1": "Йога",
          "tag2": "Медитация",
          "tag3": "Веган"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.orange.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Lily_Glimmer"),
      },
      {
        "id": "bday-6",
        "title": "С Днем Рождения, Суперзвезда! ⭐",
        "description": "Настя, ты просто идеальна во всем! От сдачи экзаменов до того, чтобы быть прекрасным другом - ты все успеваешь! За больше побед и меньше стресса! У тебя все получится! 💪",
        "image": _ava6,
        "likes": 11,
        "author_name": "Jake_Flash",
        "created_at": now.subtract(Duration(hours: 2)).toIso8601String(),
        "comments": _generateBirthdayComments6(),
        "hashtags": ["суперзвезда", "победы", "цели", "успех"],
        "user_tags": {
          "tag1": "Студент",
          "tag2": "Наука",
          "tag3": "Технологии"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.red.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Jake_Flash"),
      },
      {
        "id": "bday-7",
        "title": "С Днем Рождения, Красотка! 💖",
        "description": "Настя! Еще один год твоей невероятной красоты внутри и снаружи! Твоя доброта вдохновляет всех вокруг. Пусть твой особенный день будет таким же замечательным, как и ты! 🌸",
        "image": _ava7,
        "likes": 16,
        "author_name": "Sophie_Ray",
        "created_at": now.subtract(Duration(hours: 2, minutes: 30)).toIso8601String(),
        "comments": _generateBirthdayComments7(),
        "hashtags": ["красота", "доброта", "вдохновение", "замечательно"],
        "user_tags": {
          "tag1": "Бьюти",
          "tag2": "Мода",
          "tag3": "Танцы"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.pinkAccent.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Sophie_Ray"),
      },
      {
        "id": "bday-8",
        "title": "С Днем Рождения, Королева! 👸",
        "description": "Настя, ты настоящая королева! Желаю тебе дня, наполненного любовью, смехом и всеми твоими любимыми вещами. Не могу дождаться празднования с тобой! 🥂",
        "image": _ava8,
        "likes": 13,
        "author_name": "Ryan_Beam",
        "created_at": now.subtract(Duration(hours: 3)).toIso8601String(),
        "comments": _generateBirthdayComments8(),
        "hashtags": ["королева", "праздник", "любовь", "любимое"],
        "user_tags": {
          "tag1": "Кино",
          "tag2": "Игры",
          "tag3": "IT"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blueAccent.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Ryan_Beam"),
      },
      {
        "id": "bday-9",
        "title": "С Днем Рождения, Солнышко! ☀️",
        "description": "Настя, твоя позитивность освещает каждую комнату! Желаю тебе дня рождения таким же ярким и красивым, как твоя улыбка! Продолжай распространять эти хорошие вибрации! 🌞",
        "image": _ava9,
        "likes": 10,
        "author_name": "Zoe_Shine",
        "created_at": now.subtract(Duration(hours: 4)).toIso8601String(),
        "comments": _generateBirthdayComments9(),
        "hashtags": ["солнышко", "позитив", "хорошиевибрации", "улыбка"],
        "user_tags": {
          "tag1": "Психология",
          "tag2": "ЗОЖ",
          "tag3": "Природа"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.yellow.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Zoe_Shine"),
      },
      {
        "id": "bday-10",
        "title": "С Днем Рождения, Легенда! 🏆",
        "description": "Настя, ты просто убиваешь в этой игре! От твоих карьерных достижений до личностного роста - ты во всем преуспеваешь! Продолжай в том же духе, мы все тобой гордимся! 🚀",
        "image": _ava10,
        "likes": 17,
        "author_name": "Tyler_Blaze",
        "created_at": now.subtract(Duration(hours: 5)).toIso8601String(),
        "comments": _generateBirthdayComments10(),
        "hashtags": ["легенда", "успех", "рост", "гордость"],
        "user_tags": {
          "tag1": "Бизнес",
          "tag2": "Карьера",
          "tag3": "Финансы"
        },
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.amber.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Tyler_Blaze"),
      },
    ];
  }

  static List<dynamic> _getTechPosts(DateTime now) {
    return [
      {
        "id": "tech-1",
        "title": "Искусственный интеллект создал новый лекарственный препарат",
        "description": "Исследователи из MIT использовали ИИ для разработки препарата, способного бороться с устойчивыми к антибиотикам бактериями. Алгоритм проанализировал миллионы соединений за 48 часов!",
        "image": _postImage1,
        "likes": 23,
        "author_name": "Tech_Pro",
        "created_at": now.subtract(Duration(hours: 18)).toIso8601String(),
        "comments": _generateTechComments1(),
        "hashtags": ["ии", "медицина", "инновации", "наука"],
        "user_tags": {"tag1": "Программист", "tag2": "Геймер", "tag3": "Технологии"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.purple.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Tech_Pro"),
      },
      {
        "id": "tech-2",
        "title": "Квантовый компьютер побил рекорд вычислений",
        "description": "Новый квантовый процессор выполнил расчет за 200 секунд, который обычному суперкомпьютеру потребовал бы 10 000 лет. Прорыв в области квантовых технологий!",
        "image": _postImage2,
        "likes": 18,
        "author_name": "Quantum_Geek",
        "created_at": now.subtract(Duration(hours: 20)).toIso8601String(),
        "comments": _generateTechComments2(),
        "hashtags": ["квант", "компьютеры", "наука", "технологии"],
        "user_tags": {"tag1": "Физика", "tag2": "Наука", "tag3": "IT"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.indigo.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Quantum_Geek"),
      },
      {
        "id": "tech-3",
        "title": "",
        "description": "Только что обновил все зависимости в проекте и всё сломалось 😅 Теперь понимаю, почему senior разработчики так не любят мажорные обновления... #программирование #опыт",
        "image": "",
        "likes": 11,
        "author_name": "Dev_Girl",
        "created_at": now.subtract(Duration(hours: 2)).toIso8601String(),
        "comments": [],
        "hashtags": ["программирование", "опыт", "разработка"],
        "user_tags": {"tag1": "Разработчик", "tag2": "Flutter", "tag3": "IT"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Dev_Girl"),
      },
    ];
  }

  static List<dynamic> _getSportPosts(DateTime now) {
    return [
      {
        "id": "sport-1",
        "title": "Манчестер Сити выиграл Лигу Чемпионов в драматичном финале",
        "description": "В невероятном матче против Реала Манчестер Сити одержал победу 2:1. Решающий гол на 89-й минуте забил Эрлинг Холанн!",
        "image": _postImage3,
        "likes": 5,
        "author_name": "Sport_Lover",
        "created_at": now.subtract(Duration(hours: 22)).toIso8601String(),
        "comments": _generateSportComments1(),
        "hashtags": ["футбол", "лигачемпионов", "манчестер", "победа"],
        "user_tags": {"tag1": "Спорт", "tag2": "Фитнес", "tag3": "ЗОЖ"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.green.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Sport_Lover"),
      },
      {
        "id": "sport-2",
        "title": "",
        "description": "Сегодня пробежал свои первые 10 км без остановки! 🏃‍♂️ Чувствую себя настоящим марафонцем, хотя знаю, что это только начало 😂 #бег #спорт #достижение",
        "image": "",
        "likes": 7,
        "author_name": "Fit_Life",
        "created_at": now.subtract(Duration(hours: 5)).toIso8601String(),
        "comments": [],
        "hashtags": ["бег", "спорт", "достижение", "зож"],
        "user_tags": {"tag1": "Спорт", "tag2": "Бег", "tag3": "ЗОЖ"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.red.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Fit_Life"),
      },
    ];
  }

  static List<dynamic> _getPersonalThoughts(DateTime now) {
    return [
      {
        "id": "thought-1",
        "title": "",
        "description": "Иногда кажется, что взрослая жизнь - это просто поиск баланса между 'хочу спать' и 'надо работать' 😴💼",
        "image": "",
        "likes": 15,
        "author_name": "Philosophy_Geek",
        "created_at": now.subtract(Duration(hours: 3)).toIso8601String(),
        "comments": [],
        "hashtags": ["жизнь", "мысли", "взросление"],
        "user_tags": {"tag1": "Философия", "tag2": "Книги", "tag3": "Мысли"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.deepPurple.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Philosophy_Geek"),
      },
      {
        "id": "thought-2",
        "title": "",
        "description": "Кофе утром - это не напиток, это ритуал пробуждения души ☕️",
        "image": "",
        "likes": 8,
        "author_name": "Coffee_Lover",
        "created_at": now.subtract(Duration(hours: 1)).toIso8601String(),
        "comments": [],
        "hashtags": ["кофе", "утро", "ритуал"],
        "user_tags": {"tag1": "Кофе", "tag2": "Утро", "tag3": "Настроение"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.brown.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Coffee_Lover"),
      },
    ];
  }

  static List<dynamic> _getFunnyPosts(DateTime now) {
    return [
      {
        "id": "funny-1",
        "title": "",
        "description": "Мой кот сегодня утром смотрел на меня так, будто я должен ему денег. До сих пор не понимаю за что 😼 #коты #юмор",
        "image": "",
        "likes": 23,
        "author_name": "Cat_Mom",
        "created_at": now.subtract(Duration(hours: 4)).toIso8601String(),
        "comments": [],
        "hashtags": ["коты", "юмор", "животные"],
        "user_tags": {"tag1": "Котики", "tag2": "Юмор", "tag3": "Домашние"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.orange.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Cat_Mom"),
      },
      {
        "id": "funny-2",
        "title": "",
        "description": "Пытался объяснить бабушке, что такое 'облачные технологии'. В итоге она спросила: 'А дождь из этого облака будет?' 😂",
        "image": "",
        "likes": 18,
        "author_name": "Tech_Explainer",
        "created_at": now.subtract(Duration(hours: 6)).toIso8601String(),
        "comments": [],
        "hashtags": ["юмор", "технологии", "бабушка"],
        "user_tags": {"tag1": "Юмор", "tag2": "Семья", "tag3": "IT"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.amber.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Tech_Explainer"),
      },
    ];
  }

  static List<dynamic> _getNewsPosts(DateTime now) {
    return [
      {
        "id": "news-1",
        "title": "В городе открылся новый парк",
        "description": "Сегодня состоялось торжественное открытие нового центрального парка с велодорожками, спортивными площадками и зонами для отдыха! 🏞️",
        "image": _postImage4,
        "likes": 12,
        "author_name": "City_News",
        "created_at": now.subtract(Duration(hours: 8)).toIso8601String(),
        "comments": [],
        "hashtags": ["новости", "парк", "город", "благоустройство"],
        "user_tags": {"tag1": "Новости", "tag2": "Город", "tag3": "События"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.teal.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("City_News"),
      },
    ];
  }

  static List<dynamic> _getQuestionPosts(DateTime now) {
    return [
      {
        "id": "question-1",
        "title": "",
        "description": "Ребята, какой ваш любимый способ расслабиться после тяжелого дня? Нужны идеи! 🧘‍♀️",
        "image": "",
        "likes": 6,
        "author_name": "Relax_Seeker",
        "created_at": now.subtract(Duration(hours: 7)).toIso8601String(),
        "comments": [],
        "hashtags": ["вопрос", "отдых", "релакс", "советы"],
        "user_tags": {"tag1": "Вопрос", "tag2": "Отдых", "tag3": "Сообщество"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.cyan.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Relax_Seeker"),
      },
      {
        "id": "question-2",
        "title": "",
        "description": "Какую книгу прочитать следующей? Заканчиваю '451 по Фаренгейту' и в поисках новой захватывающей истории 📚",
        "image": "",
        "likes": 4,
        "author_name": "Book_Worm",
        "created_at": now.subtract(Duration(hours: 9)).toIso8601String(),
        "comments": [],
        "hashtags": ["книги", "чтение", "советы", "литература"],
        "user_tags": {"tag1": "Книги", "tag2": "Чтение", "tag3": "Образование"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.deepOrange.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Book_Worm"),
      },
    ];
  }

  static List<dynamic> _getAchievementPosts(DateTime now) {
    return [
      {
        "id": "achieve-1",
        "title": "",
        "description": "ГОТОВО! 🎉 Завершил свой первый большой коммерческий проект на Flutter. 6 месяцев работы, тысячи строк кода и вот он - работающий продукт! 💻",
        "image": "",
        "likes": 2,
        "author_name": "Flutter_Dev",
        "created_at": now.subtract(Duration(hours: 12)).toIso8601String(),
        "comments": [],
        "hashtags": ["достижение", "flutter", "разработка", "успех"],
        "user_tags": {"tag1": "Разработка", "tag2": "Flutter", "tag3": "Успех"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blueAccent.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Flutter_Dev"),
      },
    ];
  }

  static List<dynamic> _getDailyPosts(DateTime now) {
    return [
      {
        "id": "daily-1",
        "title": "",
        "description": "Утро начинается не с кофе, а с осознания, что сегодня понедельник... Но кофе тоже будет! ☕️",
        "image": "",
        "likes": 16,
        "author_name": "Monday_Hater",
        "created_at": now.subtract(Duration(hours: 15)).toIso8601String(),
        "comments": [],
        "hashtags": ["понедельник", "утро", "кофе", "настроение"],
        "user_tags": {"tag1": "Будни", "tag2": "Настроение", "tag3": "Юмор"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.grey.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Monday_Hater"),
      },
      {
        "id": "daily-2",
        "title": "",
        "description": "Нашел старые фотографии с друзьями... Как же быстро летит время! Надо чаще встречаться 📸",
        "image": "",
        "likes": 9,
        "author_name": "Nostalgia_Man",
        "created_at": now.subtract(Duration(hours: 10)).toIso8601String(),
        "comments": [],
        "hashtags": ["воспоминания", "друзья", "фотографии", "время"],
        "user_tags": {"tag1": "Воспоминания", "tag2": "Друзья", "tag3": "Фото"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.pinkAccent.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Nostalgia_Man"),
      },
    ];
  }

  // УНИКАЛЬНЫЕ КОММЕНТАРИИ С КОНКРЕТНЫМИ АВАТАРКАМИ
  static List<dynamic> _generateBirthdayComments1() {
    return [
      {
        "author": "Alex_Spark",
        "text": "Как мило! Настя действительно заслуживает всего самого лучшего! 🥰",
        "time": "8 минут назад",
        "author_avatar": getCommenterAvatar("Alex_Spark")
      },
      {
        "author": "Emma_Star",
        "text": "Полностью согласна с каждым словом! Настенька, с Днем Рождения! 💕",
        "time": "5 минут назад",
        "author_avatar": getCommenterAvatar("Emma_Star")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments2() {
    return [
      {
        "author": "Chloe_Bright",
        "text": "Как трогательно! Настя будет в восторге от таких слов! 🌟",
        "time": "20 минут назад",
        "author_avatar": getCommenterAvatar("Chloe_Bright")
      },
      {
        "author": "Mike_Jet",
        "text": "Хорошо сказал! Настя действительно заслуживает яркой жизни! ✨",
        "time": "15 минут назад",
        "author_avatar": getCommenterAvatar("Mike_Jet")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments3() {
    return [
      {
        "author": "Lily_Glimmer",
        "text": "Как всегда нашла самые нужные слова! Настенька, будь счастлива! 💖",
        "time": "35 минут назад",
        "author_avatar": getCommenterAvatar("Lily_Glimmer")
      },
      {
        "author": "Jake_Flash",
        "text": "Прекрасные пожелания! Настя, принимай поздравления! 🥳",
        "time": "28 минут назад",
        "author_avatar": getCommenterAvatar("Jake_Flash")
      },
      {
        "author": "Sophie_Ray",
        "text": "Настя заслуживает всей любви вселенной! 🌈",
        "time": "22 минут назад",
        "author_avatar": getCommenterAvatar("Sophie_Ray")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments4() {
    return [
      {
        "author": "Ryan_Beam",
        "text": "С Праздником Настя 🎉",
        "time": "50 минут назад",
        "author_avatar": getCommenterAvatar("Ryan_Beam")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments5() {
    return [
      {
        "author": "Zoe_Shine",
        "text": "Как прекрасно! Настя действительно излучает свет! ☀️",
        "time": "1 час 10 минут назад",
        "author_avatar": getCommenterAvatar("Zoe_Shine")
      },
      {
        "author": "Tyler_Blaze",
        "text": "Хорошие пожелания! Настя, пусть все мечты сбываются! 🌠",
        "time": "55 минут назад",
        "author_avatar": getCommenterAvatar("Tyler_Blaze")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments6() {
    return [
      {
        "author": "Maya_Sun",
        "text": "Как верно подмечено! Настя действительно суперзвезда! ⭐",
        "time": "1 час 40 минут назад",
        "author_avatar": getCommenterAvatar("Maya_Sun")
      },
      {
        "author": "Leo_Moon",
        "text": "Согласен! Учеба и друзья - Настя успевает все! 📚",
        "time": "1 час 25 минут назад",
        "author_avatar": getCommenterAvatar("Leo_Moon")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments7() {
    return [
      {
        "author": "Ruby_Sky",
        "text": "Софи, как трогательно! Настенька, пусть твоя доброта возвращается к тебе! 💝",
        "time": "2 часа 15 минут назад",
        "author_avatar": getCommenterAvatar("Ruby_Sky")
      },
      {
        "author": "Max_Thunder",
        "text": "Прекрасные слова! Настя действительно вдохновляет! 🌟",
        "time": "2 часа назад",
        "author_avatar": getCommenterAvatar("Max_Thunder")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments8() {
    return [
      {
        "author": "Ivy_Dream",
        "text": "Как весело! Настя заслуживает королевского праздника! 👑",
        "time": "2 часа 40 минут назад",
        "author_avatar": getCommenterAvatar("Ivy_Dream")
      },
      {
        "author": "Sam_Fire",
        "text": "Не могу дождаться празднования! Это будет эпично! 🥂",
        "time": "2 часа 20 минут назад",
        "author_avatar": getCommenterAvatar("Sam_Fire")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments9() {
    return [
      {
        "author": "Nova_Light",
        "text": "Как солнечно! Настя действительно заряжает позитивом! 🌞",
        "time": "3 часа 30 минут назад",
        "author_avatar": getCommenterAvatar("Nova_Light")
      },
      {
        "author": "Kai_Storm",
        "text": "Согласен! Ее улыбка освещает все вокруг! ✨",
        "time": "3 часа 15 минут назад",
        "author_avatar": getCommenterAvatar("Kai_Storm")
      },
    ];
  }

  static List<dynamic> _generateBirthdayComments10() {
    return [
      {
        "author": "Luna_Glow",
        "text": "Как гордо! Настя действительно легенда нашего времени! 🏆",
        "time": "4 часа 20 минут назад",
        "author_avatar": getCommenterAvatar("Luna_Glow")
      },
      {
        "author": "Finn_Wave",
        "text": "Полностью согласен! Ее успехи вдохновляют! 🚀",
        "time": "4 часа 5 минут назад",
        "author_avatar": getCommenterAvatar("Finn_Wave")
      },
      {
        "author": "Chloe_Bright",
        "text": "Мы все тобой гордимся, Настя! Продолжай в том же духе! 💪",
        "time": "3 часа 50 минут назад",
        "author_avatar": getCommenterAvatar("Chloe_Bright")
      },
    ];
  }

  static List<dynamic> _generateTechComments1() {
    return [
      {
        "author": "Science_Nerd",
        "text": "Это революция в медицине! ИИ действительно меняет правила игры. Невероятные перспективы!",
        "time": "2 часа назад",
        "author_avatar": getCommenterAvatar("Science_Nerd")
      },
      {
        "author": "Doctor_Who",
        "text": "Как специалист могу сказать - это прорыв. Устойчивые бактерии становятся реальной проблемой.",
        "time": "1 час 45 минут назад",
        "author_avatar": getCommenterAvatar("Doctor_Who")
      },
    ];
  }

  static List<dynamic> _generateTechComments2() {
    return [
      {
        "author": "Physics_Pro",
        "text": "Это меняет всё! Квантовое превосходство достигнуто по-настоящему. Жду peer-review.",
        "time": "3 часа назад",
        "author_avatar": getCommenterAvatar("Physics_Pro")
      },
      {
        "author": "IT_Guy",
        "text": "10000 лет против 200 секунд - это невероятно! Какие практические применения у этого расчета?",
        "time": "2 часа 30 минут назад",
        "author_avatar": getCommenterAvatar("IT_Guy")
      },
    ];
  }

  static List<dynamic> _generateSportComments1() {
    return [
      {
        "author": "City_Fan",
        "text": "КАКОЙ МАТЧ! Холанн - бог! Мы заслужили эту победу! 💙",
        "time": "4 часа назад",
        "author_avatar": getCommenterAvatar("City_Fan")
      },
      {
        "author": "Real_Madrid_Fan",
        "text": "Обидно, но играли лучше вы. Поздравляю с заслуженной победой.",
        "time": "3 часа 45 минут назад",
        "author_avatar": getCommenterAvatar("Real_Madrid_Fan")
      },
    ];
  }

  // Вспомогательный метод для fallback аватарок
  static String _getFallbackAvatarUrl(String userName) {
    final avatars = [
      _ava1, _ava2, _ava3, _ava4, _ava5, _ava6, _ava7, _ava8, _ava9, _ava10,
      _ava11, _ava12, _ava13, _ava14, _ava15, _ava16, _ava17, _ava18, _ava19, _ava20,
      _ava21, _ava22, _ava23, _ava24, _ava25, _ava26, _ava27, _ava28, _ava29, _ava30
    ];
    final index = userName.hashCode.abs() % avatars.length;
    return avatars[index];
  }

  // Остальные методы класса...
  static Map<String, dynamic> getWelcomeMessage() {
    return getMockNews()[0] as Map<String, dynamic>;
  }

  static Map<String, dynamic> getSportsNews() {
    return getMockNews().firstWhere((news) => news['id'].toString().contains('sport')) as Map<String, dynamic>;
  }

  static Map<String, dynamic> getTechNews() {
    return getMockNews().firstWhere((news) => news['id'].toString().contains('tech')) as Map<String, dynamic>;
  }

  static Map<String, dynamic> getTravelNews() {
    return getMockNews().firstWhere((news) => news['id'].toString().contains('travel')) as Map<String, dynamic>;
  }

  static Map<String, dynamic> getFoodNews() {
    return getMockNews().firstWhere((news) => news['id'].toString().contains('food')) as Map<String, dynamic>;
  }

  static Map<String, dynamic> getChannelPost() {
    return getMockNews().firstWhere((news) => news['id'].toString().contains('channel')) as Map<String, dynamic>;
  }

  // Метод для получения демо-данных по типу
  static List<dynamic> getNewsByType(String type) {
    final allNews = getMockNews();

    switch (type) {
      case 'birthday':
        return allNews.where((news) => news['id'].toString().contains('bday')).toList();
      case 'channel':
        return allNews.where((news) => news['is_channel_post'] == true).toList();
      case 'regular':
        return allNews.where((news) => news['is_channel_post'] != true && !news['id'].toString().contains('bday')).toList();
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

  // Метод для получения случайного поздравления
  static Map<String, dynamic> getRandomBirthdayWish() {
    final birthdayNews = getNewsByType('birthday');
    final random = DateTime.now().millisecond % birthdayNews.length;
    return birthdayNews[random] as Map<String, dynamic>;
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
      case 'Sport_Lover':
        return {"tag1": "Спорт", "tag2": "Фитнес", "tag3": "ЗОЖ"};
      case 'Tech_Pro':
        return {"tag1": "Программист", "tag2": "Геймер", "tag3": "Технологии"};
      case 'Quantum_Geek':
        return {"tag1": "Физика", "tag2": "Наука", "tag3": "IT"};
      case 'Chloe_Bright':
        return {"tag1": "Программист", "tag2": "Котики", "tag3": "Геймер"};
      case 'Alex_Spark':
        return {"tag1": "Фотограф", "tag2": "Путешественник", "tag3": "Кофе"};
      case 'Emma_Star':
        return {"tag1": "Художник", "tag2": "Книголюб", "tag3": "Растения"};
      case 'Mike_Jet':
        return {"tag1": "Музыкант", "tag2": "Спортсмен", "tag3": "Психология"};
      case 'Lily_Glimmer':
        return {"tag1": "Йога", "tag2": "Медитация", "tag3": "Веган"};
      case 'Jake_Flash':
        return {"tag1": "Студент", "tag2": "Наука", "tag3": "Технологии"};
      case 'Sophie_Ray':
        return {"tag1": "Бьюти", "tag2": "Мода", "tag3": "Танцы"};
      case 'Ryan_Beam':
        return {"tag1": "Кино", "tag2": "Игры", "tag3": "IT"};
      case 'Zoe_Shine':
        return {"tag1": "Психология", "tag2": "ЗОЖ", "tag3": "Природа"};
      case 'Tyler_Blaze':
        return {"tag1": "Бизнес", "tag2": "Карьера", "tag3": "Финансы"};
      default:
        return {"tag1": "Программист", "tag2": "Котики", "tag3": "Геймер"};
    }
  }

  // НОВЫЙ МЕТОД: Получение тегов для конкретного поста из мок данных
  static Map<String, String> getMockTagsForPost(String postId) {
    final mockTags = {
      'tech-1': {'tag1': 'Программист', 'tag2': 'Геймер', 'tag3': 'Технологии'},
      'tech-2': {'tag1': 'Физика', 'tag2': 'Наука', 'tag3': 'IT'},
      'sport-1': {'tag1': 'Спорт', 'tag2': 'Фитнес', 'tag3': 'ЗОЖ'},
      'sport-2': {'tag1': 'Автоспорт', 'tag2': 'Гонки', 'tag3': 'Скорость'},
      'travel-1': {'tag1': 'Путешествия', 'tag2': 'Фотограф', 'tag3': 'Природа'},
      'travel-2': {'tag1': 'Пляжи', 'tag2': 'Отдых', 'tag3': 'Приключения'},
      'food-1': {'tag1': 'Кулинария', 'tag2': 'Рецепты', 'tag3': 'Италия'},
      'food-2': {'tag1': 'Выпечка', 'tag2': 'Хлеб', 'tag3': 'Дом'},
      'art-1': {'tag1': 'Искусство', 'tag2': 'Выставка', 'tag3': 'Культура'},
      'edu-1': {'tag1': 'Образование', 'tag2': 'Курсы', 'tag3': 'Развитие'},
      'channel-1': {'tag1': 'Официально', 'tag2': 'Обновление', 'tag3': 'Важно'},
      'channel-2': {'tag1': 'Конкурс', 'tag2': 'События', 'tag3': 'Призы'},
      'story-1': {'tag1': 'История', 'tag2': 'Обучение', 'tag3': 'Успех'},
      'science-1': {'tag1': 'Наука', 'tag2': 'Космос', 'tag3': 'Открытие'},
    };

    // Для поздравлений
    if (postId.contains('bday')) {
      return {'tag1': 'Программист', 'tag2': 'Котики', 'tag3': 'Геймер'};
    }

    return mockTags[postId] ?? {'tag1': 'Программист', 'tag2': 'Котики', 'tag3': 'Геймер'};
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

    // Для поздравлений используем праздничные цвета
    if (postId.contains('bday')) {
      final birthdayColors = [
        Colors.pink, Colors.purple, Colors.blue, Colors.green, Colors.orange,
        Colors.red, Colors.pinkAccent, Colors.purpleAccent, Colors.blueAccent,
        Colors.amber, Colors.cyan, Colors.deepOrange, Colors.lightGreen, Colors.indigo,
        Colors.teal, Colors.yellow, Colors.blueGrey, Colors.deepPurple, Colors.pink,
        Colors.orangeAccent
      ];
      final index = postId.hashCode.abs() % birthdayColors.length;
      return birthdayColors[index];
    }

    return mockColors[postId] ?? Colors.blue;
  }
}