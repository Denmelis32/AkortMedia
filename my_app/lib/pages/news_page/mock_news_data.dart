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
    'Tech_Pro': _ava1,
    'Quantum_Geek': _ava2,
    'Sport_Lover': _ava3,
    'Auto_Expert': _ava4,
    'Travel_Buddy': _ava5,
    'Backpacker_Joe': _ava6,
    'Chef_Master': _ava7,
    'Baking_Queen': _ava8,
    'Art_Lover': _ava9,
    'Edu_Guru': _ava10,
    'SelfTaught_Dev': _ava11,
    'Space_Explorer': _ava12,
    'System_Admin': _ava13,
    'Dev_Girl': _ava14,
    'Fit_Life': _ava15,
    'Philosophy_Geek': _ava16,
    'Coffee_Lover': _ava17,
    'Cat_Mom': _ava18,
    'Tech_Explainer': _ava19,
    'City_News': _ava20,
    'Relax_Seeker': _ava21,
    'Book_Worm': _ava22,
    'Flutter_Dev': _ava23,
    'Monday_Hater': _ava24,
    'Nostalgia_Man': _ava25,
    'Remote_Dev': _ava26,
    'Office_Life': _ava27,
    'Student_Life': _ava28,
    'Book_Explorer': _ava29,
    'Cooking_Newbie': _ava30,
  };

  // СЛОВАРЬ ДЛЯ КОММЕНТАТОРОВ
  static final Map<String, String> _commenterAvatars = {
    'Tech_Pro': _ava1,
    'Quantum_Geek': _ava2,
    'Sport_Lover': _ava3,
    'Auto_Expert': _ava4,
    'Travel_Buddy': _ava5,
    'Science_Nerd': _ava6,
    'Doctor_Who': _ava7,
    'AI_Developer': _ava8,
    'Med_Student': _ava9,
    'Physics_Pro': _ava10,
    'IT_Guy': _ava11,
    'Researcher_X': _ava12,
    'City_Fan': _ava13,
    'Real_Madrid_Fan': _ava14,
    'Football_Analyst': _ava15,
    'Dev_Girl': _ava16,
    'Fit_Life': _ava17,
    'Philosophy_Geek': _ava18,
    'Coffee_Lover': _ava19,
    'Cat_Mom': _ava20,
    'Tech_Explainer': _ava21,
    'City_News': _ava22,
    'Relax_Seeker': _ava23,
    'Book_Worm': _ava24,
    'Flutter_Dev': _ava25,
    'Monday_Hater': _ava26,
    'Nostalgia_Man': _ava27,
    'Remote_Dev': _ava28,
    'Office_Life': _ava29,
    'Student_Life': _ava30,
  };

  // МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ АВТОРА
  static String getAuthorAvatar(String authorName) {
    final avatar = _authorAvatars[authorName];
    if (avatar != null) {
      return avatar;
    }
    return _ava1;
  }

  // МЕТОД ДЛЯ ПОЛУЧЕНИЯ АВАТАРКИ КОММЕНТАТОРА
  static String getCommenterAvatar(String commenterName) {
    return _commenterAvatars[commenterName] ?? _getFallbackAvatarUrl(commenterName);
  }

  static List<dynamic> getMockNews() {
    final now = DateTime.now();

    return [
      // ТЕХНОЛОГИЧЕСКИЕ ПОСТЫ
      ..._getTechPosts(now),
      // СПОРТИВНЫЕ ПОСТЫ
      ..._getSportPosts(now),
      // ПУТЕШЕСТВИЯ
      ..._getTravelPosts(now),
      // ЕДА И КУЛИНАРИЯ
      ..._getFoodPosts(now),
      // ЛИЧНЫЕ МЫСЛИ
      ..._getPersonalThoughts(now),
      // РАБОЧИЕ МОМЕНТЫ
      ..._getWorkPosts(now),
      // УЧЕБА И САМОРАЗВИТИЕ
      ..._getStudyPosts(now),
      // ИГРЫ И РАЗВЛЕЧЕНИЯ
      ..._getGamesPosts(now),
      // МУЗЫКА И ТВОРЧЕСТВО
      ..._getMusicPosts(now),
      // СПОРТ И ЗДОРОВЬЕ
      ..._getHealthPosts(now),
      // ХОББИ И УВЛЕЧЕНИЯ
      ..._getHobbyPosts(now),
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
        "created_at": now.subtract(Duration(hours: 2)).toIso8601String(),
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
        "created_at": now.subtract(Duration(hours: 4)).toIso8601String(),
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
        "description": "Только что обновил все зависимости в проекте и всё сломалось 😅 Теперь понимаю, почему senior разработчики так не любят мажорные обновления...",
        "image": "",
        "likes": 11,
        "author_name": "Dev_Girl",
        "created_at": now.subtract(Duration(hours: 1)).toIso8601String(),
        "comments": _generateTechComments3(),
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
        "title": "Манчестер Сити выиграл Лигу Чемпионов",
        "description": "В невероятном матче против Реала Манчестер Сити одержал победу 2:1. Решающий гол на 89-й минуте забил Эрлинг Холанн!",
        "image": _postImage3,
        "likes": 15,
        "author_name": "Sport_Lover",
        "created_at": now.subtract(Duration(hours: 3)).toIso8601String(),
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
        "description": "Сегодня пробежал свои первые 10 км без остановки! 🏃‍♂️ Чувствую себя настоящим марафонцем, хотя знаю, что это только начало 😂",
        "image": "",
        "likes": 7,
        "author_name": "Fit_Life",
        "created_at": now.subtract(Duration(hours: 5)).toIso8601String(),
        "comments": _generateSportComments2(),
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

  static List<dynamic> _getTravelPosts(DateTime now) {
    return [
      {
        "id": "travel-1",
        "title": "Открытие нового маршрута в Японию",
        "description": "Авиакомпания запускает прямые рейсы в Токио! Теперь добраться до Страны восходящего солнца стало еще проще. Кто уже планирует поездку? ✈️",
        "image": _postImage4,
        "likes": 12,
        "author_name": "Travel_Buddy",
        "created_at": now.subtract(Duration(hours: 6)).toIso8601String(),
        "comments": _generateTravelComments1(),
        "hashtags": ["путешествия", "япония", "токио", "авиаперелеты"],
        "user_tags": {"tag1": "Путешествия", "tag2": "Фотограф", "tag3": "Природа"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.teal.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Travel_Buddy"),
      },
      {
        "id": "travel-2",
        "title": "",
        "description": "Нашел самый уютный книжный магазин в городе! Провел там 3 часа и не заметил 📚✨",
        "image": _postImage5,
        "likes": 9,
        "author_name": "Book_Explorer",
        "created_at": now.subtract(Duration(hours: 8)).toIso8601String(),
        "comments": _generateTravelComments2(),
        "hashtags": ["книги", "город", "воспоминания"],
        "user_tags": {"tag1": "Книги", "tag2": "Чтение", "tag3": "Образование"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.amber.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Book_Explorer"),
      },
    ];
  }

  static List<dynamic> _getFoodPosts(DateTime now) {
    return [
      {
        "id": "food-1",
        "title": "Секрет идеальной пасты",
        "description": "Научился готовить пасту как в лучших ресторанах Италии! Секрет в качестве макарон и правильном соусе. Делюсь рецептом в комментариях 🍝",
        "image": _postImage6,
        "likes": 14,
        "author_name": "Chef_Master",
        "created_at": now.subtract(Duration(hours: 7)).toIso8601String(),
        "comments": _generateFoodComments1(),
        "hashtags": ["кулинария", "рецепты", "италия", "паста"],
        "user_tags": {"tag1": "Кулинария", "tag2": "Рецепты", "tag3": "Италия"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.orange.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Chef_Master"),
      },
      {
        "id": "food-2",
        "title": "",
        "description": "Попробовал готовить рамен впервые... Получилось нечто среднее между супом и макаронами 😅",
        "image": "",
        "likes": 8,
        "author_name": "Cooking_Newbie",
        "created_at": now.subtract(Duration(hours: 9)).toIso8601String(),
        "comments": _generateFoodComments2(),
        "hashtags": ["опыт", "советы", "юмор"],
        "user_tags": {"tag1": "Кулинария", "tag2": "Рецепты", "tag3": "Италия"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.orange.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Cooking_Newbie"),
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
        "likes": 25,
        "author_name": "Philosophy_Geek",
        "created_at": now.subtract(Duration(hours: 10)).toIso8601String(),
        "comments": _generateThoughtComments1(),
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
        "likes": 18,
        "author_name": "Coffee_Lover",
        "created_at": now.subtract(Duration(hours: 11)).toIso8601String(),
        "comments": _generateThoughtComments2(),
        "hashtags": ["кофе", "утро", "ритуал"],
        "user_tags": {"tag1": "Кофе", "tag2": "Утро", "tag3": "Настроение"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.brown.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Coffee_Lover"),
      },
      {
        "id": "thought-3",
        "title": "",
        "description": "Мой кот сегодня утром смотрел на меня так, будто я должен ему денег. До сих пор не понимаю за что 😼",
        "image": "",
        "likes": 32,
        "author_name": "Cat_Mom",
        "created_at": now.subtract(Duration(hours: 12)).toIso8601String(),
        "comments": _generateThoughtComments3(),
        "hashtags": ["коты", "юмор", "животные"],
        "user_tags": {"tag1": "Котики", "tag2": "Юмор", "tag3": "Домашние"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.orange.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Cat_Mom"),
      },
    ];
  }

  static List<dynamic> _getWorkPosts(DateTime now) {
    return [
      {
        "id": "work-1",
        "title": "",
        "description": "Удаленный день в кофейне > офис. Кофе льется рекой, код пишется сам собой ☕️💻",
        "image": "",
        "likes": 14,
        "author_name": "Remote_Dev",
        "created_at": now.subtract(Duration(hours: 13)).toIso8601String(),
        "comments": _generateWorkComments1(),
        "hashtags": ["программирование", "кофе", "успех"],
        "user_tags": {"tag1": "Разработчик", "tag2": "Flutter", "tag3": "IT"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.brown.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Remote_Dev"),
      },
      {
        "id": "work-2",
        "title": "",
        "description": "Совещание которое можно было бы провести сообщением в чате... ⌛️",
        "image": "",
        "likes": 28,
        "author_name": "Office_Life",
        "created_at": now.subtract(Duration(hours: 14)).toIso8601String(),
        "comments": _generateWorkComments2(),
        "hashtags": ["опыт", "вопрос", "работа"],
        "user_tags": {"tag1": "Бизнес", "tag2": "Карьера", "tag3": "Финансы"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blueGrey.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Office_Life"),
      },
    ];
  }

  static List<dynamic> _getStudyPosts(DateTime now) {
    return [
      {
        "id": "study-1",
        "title": "",
        "description": "На 5-й чашке кофе и 3-й главе учебника по алгоритмам... Мозг плавится, но я не сдамся! 📚💪",
        "image": "",
        "likes": 16,
        "author_name": "Student_Life",
        "created_at": now.subtract(Duration(hours: 15)).toIso8601String(),
        "comments": _generateStudyComments1(),
        "hashtags": ["наука", "достижение", "книги"],
        "user_tags": {"tag1": "Студент", "tag2": "Наука", "tag3": "Технологии"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.deepPurple.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Student_Life"),
      },
      {
        "id": "study-2",
        "title": "",
        "description": "Какую книгу прочитать следующей? Заканчиваю '451 по Фаренгейту' и в поисках новой захватывающей истории 📚",
        "image": "",
        "likes": 9,
        "author_name": "Book_Worm",
        "created_at": now.subtract(Duration(hours: 16)).toIso8601String(),
        "comments": _generateStudyComments2(),
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

  static List<dynamic> _getGamesPosts(DateTime now) {
    return [
      {
        "id": "games-1",
        "title": "",
        "description": "Прошел новую Elden Ring без единой смерти! ...Шучу, умер 157 раз 😂",
        "image": "",
        "likes": 22,
        "author_name": "Tech_Pro",
        "created_at": now.subtract(Duration(hours: 17)).toIso8601String(),
        "comments": _generateGamesComments1(),
        "hashtags": ["игры", "достижение", "юмор"],
        "user_tags": {"tag1": "Программист", "tag2": "Геймер", "tag3": "Технологии"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.purple.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Tech_Pro"),
      },
    ];
  }

  static List<dynamic> _getMusicPosts(DateTime now) {
    return [
      {
        "id": "music-1",
        "title": "",
        "description": "Написал новый трек под дождливую погоду. Кажется, грусть может быть продуктивной 🎵☔️",
        "image": "",
        "likes": 13,
        "author_name": "Art_Lover",
        "created_at": now.subtract(Duration(hours: 18)).toIso8601String(),
        "comments": _generateMusicComments1(),
        "hashtags": ["творчество", "настроение", "вдохновение"],
        "user_tags": {"tag1": "Искусство", "tag2": "Выставка", "tag3": "Культура"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.indigo.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Art_Lover"),
      },
    ];
  }

  static List<dynamic> _getHealthPosts(DateTime now) {
    return [
      {
        "id": "health-1",
        "title": "",
        "description": "Утренняя йога с видом на город - лучший способ начать день! 🧘‍♀️🌇",
        "image": "",
        "likes": 11,
        "author_name": "Fit_Life",
        "created_at": now.subtract(Duration(hours: 19)).toIso8601String(),
        "comments": _generateHealthComments1(),
        "hashtags": ["зож", "утро", "спорт"],
        "user_tags": {"tag1": "Спорт", "tag2": "Бег", "tag3": "ЗОЖ"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.green.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Fit_Life"),
      },
      {
        "id": "health-2",
        "title": "",
        "description": "Ребята, какой ваш любимый способ расслабиться после тяжелого дня? Нужны идеи! 🧘‍♀️",
        "image": "",
        "likes": 8,
        "author_name": "Relax_Seeker",
        "created_at": now.subtract(Duration(hours: 20)).toIso8601String(),
        "comments": _generateHealthComments2(),
        "hashtags": ["вопрос", "отдых", "релакс", "советы"],
        "user_tags": {"tag1": "Вопрос", "tag2": "Отдых", "tag3": "Сообщество"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.cyan.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Relax_Seeker"),
      },
    ];
  }

  static List<dynamic> _getHobbyPosts(DateTime now) {
    return [
      {
        "id": "hobby-1",
        "title": "",
        "description": "Купил новую механическую клавиатуру... Теперь соседи думают, что у меня дома работает строительная бригада ⌨️😂",
        "image": "",
        "likes": 19,
        "author_name": "Tech_Explainer",
        "created_at": now.subtract(Duration(hours: 21)).toIso8601String(),
        "comments": _generateHobbyComments1(),
        "hashtags": ["технологии", "опыт", "юмор"],
        "user_tags": {"tag1": "Юмор", "tag2": "Семья", "tag3": "IT"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.blue.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Tech_Explainer"),
      },
      {
        "id": "hobby-2",
        "title": "",
        "description": "Начал собирать пазл на 5000 деталей... Кажется, это займет больше времени, чем обучение в университете 🧩😅",
        "image": "",
        "likes": 12,
        "author_name": "Nostalgia_Man",
        "created_at": now.subtract(Duration(hours: 22)).toIso8601String(),
        "comments": _generateHobbyComments2(),
        "hashtags": ["вопрос", "достижение", "воспоминания"],
        "user_tags": {"tag1": "Воспоминания", "tag2": "Друзья", "tag3": "Фото"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.orange.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Nostalgia_Man"),
      },
      {
        "id": "hobby-3",
        "title": "",
        "description": "Провел выходные в лесу без интернета... Оказывается, птицы поют громче уведомлений в телефоне 🌳🐦",
        "image": "",
        "likes": 17,
        "author_name": "Travel_Buddy",
        "created_at": now.subtract(Duration(hours: 23)).toIso8601String(),
        "comments": _generateHobbyComments3(),
        "hashtags": ["отдых", "природа", "релакс"],
        "user_tags": {"tag1": "Путешествия", "tag2": "Фотограф", "tag3": "Природа"},
        "isLiked": false,
        "isBookmarked": false,
        "tag_color": Colors.lightGreen.value,
        "is_channel_post": false,
        "author_avatar": getAuthorAvatar("Travel_Buddy"),
      },
    ];
  }

  // КОММЕНТАРИИ ДЛЯ РАЗНЫХ КАТЕГОРИЙ
  static List<dynamic> _generateTechComments1() {
    return [
      {
        "author": "Science_Nerd",
        "text": "Это революция в медицине! ИИ действительно меняет правила игры. Невероятные перспективы!",
        "time": "1 час назад",
        "author_avatar": getCommenterAvatar("Science_Nerd")
      },
      {
        "author": "Doctor_Who",
        "text": "Как специалист могу сказать - это прорыв. Устойчивые бактерии становятся реальной проблемой.",
        "time": "45 минут назад",
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

  static List<dynamic> _generateTechComments3() {
    return [
      {
        "author": "Remote_Dev",
        "text": "Знакомо! Теперь понял, почему в проектах есть package-lock.json 😅",
        "time": "45 минут назад",
        "author_avatar": getCommenterAvatar("Remote_Dev")
      },
    ];
  }

  static List<dynamic> _generateSportComments1() {
    return [
      {
        "author": "City_Fan",
        "text": "КАКОЙ МАТЧ! Холанн - бог! Мы заслужили эту победу! 💙",
        "time": "2 часа назад",
        "author_avatar": getCommenterAvatar("City_Fan")
      },
      {
        "author": "Real_Madrid_Fan",
        "text": "Обидно, но играли лучше вы. Поздравляю с заслуженной победой.",
        "time": "1 час 45 минут назад",
        "author_avatar": getCommenterAvatar("Real_Madrid_Fan")
      },
    ];
  }

  static List<dynamic> _generateSportComments2() {
    return [
      {
        "author": "Fit_Life",
        "text": "Это отличный результат! Следующая цель - полумарафон? 🏃‍♂️",
        "time": "4 часа назад",
        "author_avatar": getCommenterAvatar("Fit_Life")
      },
    ];
  }

  static List<dynamic> _generateTravelComments1() {
    return [
      {
        "author": "Backpacker_Joe",
        "text": "Отличные новости! Уже забронировал билеты на ноябрь. Кто со мной? ✈️",
        "time": "5 часов назад",
        "author_avatar": getCommenterAvatar("Backpacker_Joe")
      },
    ];
  }

  static List<dynamic> _generateTravelComments2() {
    return [
      {
        "author": "Art_Lover",
        "text": "Выглядит волшебно! Где это место? Хочу тоже посетить!",
        "time": "6 часов назад",
        "author_avatar": getCommenterAvatar("Art_Lover")
      },
    ];
  }

  static List<dynamic> _generateFoodComments1() {
    return [
      {
        "author": "Cooking_Newbie",
        "text": "Жду рецепт! Особенно интересно про соус 👀",
        "time": "6 часов назад",
        "author_avatar": getCommenterAvatar("Cooking_Newbie")
      },
    ];
  }

  static List<dynamic> _generateFoodComments2() {
    return [
      {
        "author": "Chef_Master",
        "text": "Главное - пробовать! С первого раза редко у кого получается идеально",
        "time": "8 часов назад",
        "author_avatar": getCommenterAvatar("Chef_Master")
      },
    ];
  }

  static List<dynamic> _generateThoughtComments1() {
    return [
      {
        "author": "Office_Life",
        "text": "Так точно! Еще бы найти баланс между 'хочу есть' и 'лень готовить' 😂",
        "time": "9 часов назад",
        "author_avatar": getCommenterAvatar("Office_Life")
      },
    ];
  }

  static List<dynamic> _generateThoughtComments2() {
    return [
      {
        "author": "Remote_Dev",
        "text": "Не могу представить утро без этого ритуала! ☕️",
        "time": "10 часов назад",
        "author_avatar": getCommenterAvatar("Remote_Dev")
      },
    ];
  }

  static List<dynamic> _generateThoughtComments3() {
    return [
      {
        "author": "Cat_Mom",
        "text": "Мой кот тоже постоянно смотрит с укором... Наверное, мы им должны всю зарплату 😸",
        "time": "11 часов назад",
        "author_avatar": getCommenterAvatar("Cat_Mom")
      },
    ];
  }

  static List<dynamic> _generateWorkComments1() {
    return [
      {
        "author": "Coffee_Lover",
        "text": "Какую кофейню выбрал? Ищу новые места для работы!",
        "time": "12 часов назад",
        "author_avatar": getCommenterAvatar("Coffee_Lover")
      },
    ];
  }

  static List<dynamic> _generateWorkComments2() {
    return [
      {
        "author": "Monday_Hater",
        "text": "Знакомо! У нас вчера час обсуждали цвет кнопки...",
        "time": "13 часов назад",
        "author_avatar": getCommenterAvatar("Monday_Hater")
      },
    ];
  }

  static List<dynamic> _generateStudyComments1() {
    return [
      {
        "author": "Book_Worm",
        "text": "Какой учебник читаешь? Может, посоветуешь что-то по алгоритмам?",
        "time": "14 часов назад",
        "author_avatar": getCommenterAvatar("Book_Worm")
      },
    ];
  }

  static List<dynamic> _generateStudyComments2() {
    return [
      {
        "author": "Philosophy_Geek",
        "text": "Рекомендую '1984' Оруэлла! После '451 по Фаренгейту' будет в тему 📚",
        "time": "15 часов назад",
        "author_avatar": getCommenterAvatar("Philosophy_Geek")
      },
    ];
  }

  static List<dynamic> _generateGamesComments1() {
    return [
      {
        "author": "Quantum_Geek",
        "text": "Всего 157? Неплохо! Я на первом боссе столько раз умер 😂",
        "time": "16 часов назад",
        "author_avatar": getCommenterAvatar("Quantum_Geek")
      },
    ];
  }

  static List<dynamic> _generateMusicComments1() {
    return [
      {
        "author": "Music_Lover",
        "text": "Обязательно поделись, когда будет готов! Люблю атмосферную музыку",
        "time": "17 часов назад",
        "author_avatar": getCommenterAvatar("Music_Lover")
      },
    ];
  }

  static List<dynamic> _generateHealthComments1() {
    return [
      {
        "author": "Relax_Seeker",
        "text": "Поддерживаю! А какими практиками занимаешься?",
        "time": "18 часов назад",
        "author_avatar": getCommenterAvatar("Relax_Seeker")
      },
    ];
  }

  static List<dynamic> _generateHealthComments2() {
    return [
      {
        "author": "Fit_Life",
        "text": "Горячая ванна с книгой - мой идеальный способ расслабиться! 🛁📖",
        "time": "19 часов назад",
        "author_avatar": getCommenterAvatar("Fit_Life")
      },
    ];
  }

  static List<dynamic> _generateHobbyComments1() {
    return [
      {
        "author": "Tech_Pro",
        "text": "Какой свитч взял? Сам недавно перешел на механику - жизнь разделилась на до и после!",
        "time": "20 часов назад",
        "author_avatar": getCommenterAvatar("Tech_Pro")
      },
    ];
  }

  static List<dynamic> _generateHobbyComments2() {
    return [
      {
        "author": "Student_Life",
        "text": "Ох, помню свои мучения с пазлами! Совет: начинай с углов!",
        "time": "21 час назад",
        "author_avatar": getCommenterAvatar("Student_Life")
      },
    ];
  }

  static List<dynamic> _generateHobbyComments3() {
    return [
      {
        "author": "Nature_Lover",
        "text": "Обязательно попробую! Как нашел такое место?",
        "time": "22 часа назад",
        "author_avatar": getCommenterAvatar("Nature_Lover")
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

  // Метод для получения демо-данных по типу
  static List<dynamic> getNewsByType(String type) {
    final allNews = getMockNews();

    switch (type) {
      case 'tech':
        return allNews.where((news) => news['id'].toString().contains('tech')).toList();
      case 'sports':
        return allNews.where((news) => news['id'].toString().contains('sport')).toList();
      case 'travel':
        return allNews.where((news) => news['id'].toString().contains('travel')).toList();
      case 'food':
        return allNews.where((news) => news['id'].toString().contains('food')).toList();
      case 'thoughts':
        return allNews.where((news) => news['id'].toString().contains('thought')).toList();
      case 'work':
        return allNews.where((news) => news['id'].toString().contains('work')).toList();
      case 'study':
        return allNews.where((news) => news['id'].toString().contains('study')).toList();
      case 'popular':
        return allNews.where((news) => (news['likes'] ?? 0) > 15).toList();
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
      case 'Travel_Buddy':
        return {"tag1": "Путешествия", "tag2": "Фотограф", "tag3": "Природа"};
      case 'Chef_Master':
        return {"tag1": "Кулинария", "tag2": "Рецепты", "tag3": "Италия"};
      case 'Dev_Girl':
        return {"tag1": "Разработчик", "tag2": "Flutter", "tag3": "IT"};
      case 'Fit_Life':
        return {"tag1": "Спорт", "tag2": "Бег", "tag3": "ЗОЖ"};
      case 'Philosophy_Geek':
        return {"tag1": "Философия", "tag2": "Книги", "tag3": "Мысли"};
      case 'Coffee_Lover':
        return {"tag1": "Кофе", "tag2": "Утро", "tag3": "Настроение"};
      case 'Cat_Mom':
        return {"tag1": "Котики", "tag2": "Юмор", "tag3": "Домашние"};
      case 'Book_Explorer':
        return {"tag1": "Книги", "tag2": "Чтение", "tag3": "Образование"};
      case 'Remote_Dev':
        return {"tag1": "Разработчик", "tag2": "Flutter", "tag3": "IT"};
      case 'Office_Life':
        return {"tag1": "Бизнес", "tag2": "Карьера", "tag3": "Финансы"};
      case 'Student_Life':
        return {"tag1": "Студент", "tag2": "Наука", "tag3": "Технологии"};
      case 'Art_Lover':
        return {"tag1": "Искусство", "tag2": "Выставка", "tag3": "Культура"};
      case 'Relax_Seeker':
        return {"tag1": "Вопрос", "tag2": "Отдых", "tag3": "Сообщество"};
      case 'Book_Worm':
        return {"tag1": "Книги", "tag2": "Чтение", "tag3": "Образование"};
      case 'Tech_Explainer':
        return {"tag1": "Юмор", "tag2": "Семья", "tag3": "IT"};
      case 'Nostalgia_Man':
        return {"tag1": "Воспоминания", "tag2": "Друзья", "tag3": "Фото"};
      default:
        return {"tag1": "Программист", "tag2": "Котики", "tag3": "Геймер"};
    }
  }
}