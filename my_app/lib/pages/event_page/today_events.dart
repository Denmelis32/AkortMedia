import 'package:flutter/material.dart';
import 'event_model.dart';

class TodayEvents {
  static List<Event> getEvents() {
    final now = DateTime.now();

    return [
      Event(
        id: 'today-1',
        title: 'Бесплатный йога-урок в парке',
        description: 'Утренняя йога для всех желающих на свежем воздухе. Подходит для любого уровня подготовки. Приносите свои коврики и хорошее настроение!',
        date: DateTime(now.year, now.month, now.day, 8, 0),
        endDate: DateTime(now.year, now.month, now.day, 9, 0),
        color: Colors.green,
        category: 'Спорт',
        location: 'Центральный парк',
        address: 'ул. Парковая, 1',
        price: 0,
        organizer: 'Йога-студия "Гармония"',
        imageUrl: 'https://avatars.mds.yandex.net/i?id=0e8e8f4350c9cdca02479a40acc5ad36_l-4875004-images-thumbs&n=13',
        tags: ['йога', 'здоровье', 'бесплатно', 'утро', 'спорт', 'на свежем воздухе'],
        maxAttendees: 100,
        currentAttendees: 78,
        rating: 4.5,
        reviewCount: 67,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Event(
        id: 'today-2',
        title: 'Утренний кофе-митап для IT специалистов',
        description: 'Неформальная встреча разработчиков и IT специалистов. Обсуждаем тренды, обмениваемся опытом и находим новых партнеров.',
        date: DateTime(now.year, now.month, now.day, 9, 30),
        endDate: DateTime(now.year, now.month, now.day, 11, 0),
        color: Colors.teal,
        category: 'Встречи',
        location: 'Кофейня "Digital Brew"',
        address: 'ул. Технологическая, 15',
        price: 0,
        organizer: 'IT Сообщество города',
        imageUrl: 'https://avatars.mds.yandex.net/get-zen_doc/1589393/pub_5d7720fe35c8d800ae268e0f_5d7721c198930900ad3b4a69/scale_1200',
        tags: ['IT', 'митап', 'кофе', 'нетворкинг', 'технологии', 'бесплатно'],
        maxAttendees: 50,
        currentAttendees: 42,
        rating: 4.7,
        reviewCount: 34,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Event(
        id: 'today-3',
        title: 'Мастер-класс по акварельной живописи',
        description: 'Учимся создавать красивые акварельные скетчи. Все материалы предоставляются. Подходит для начинающих.',
        date: DateTime(now.year, now.month, now.day, 12, 0),
        endDate: DateTime(now.year, now.month, now.day, 14, 0),
        color: Colors.blue,
        category: 'Образование',
        location: 'Арт-студия "Краски"',
        address: 'пр. Художественный, 23',
        price: 1200,
        organizer: 'Студия творчества',
        imageUrl: 'https://avatars.mds.yandex.net/get-altay/4337412/2a0000017a3a8e3b6d5a7c8e9c8f2e3a8a2e/orig',
        tags: ['рисование', 'акварель', 'мастер-класс', 'творчество', 'искусство'],
        maxAttendees: 15,
        currentAttendees: 12,
        rating: 4.8,
        reviewCount: 28,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Event(
        id: 'today-4',
        title: 'Бизнес-ланч с инвестором',
        description: 'Встреча с успешным инвестором. Обсуждение стартапов и инвестиционных возможностей. Только по предварительной регистрации.',
        date: DateTime(now.year, now.month, now.day, 13, 0),
        endDate: DateTime(now.year, now.month, now.day, 15, 0),
        color: Colors.orange,
        category: 'Встречи',
        location: 'Ресторан "Бизнес-класс"',
        address: 'ул. Деловая, 8',
        price: 2500,
        organizer: 'Клуб предпринимателей',
        imageUrl: 'https://avatars.mds.yandex.net/get-zen_doc/1589393/pub_5d7720fe35c8d800ae268e0f_5d7721c198930900ad3b4a69/scale_1200',
        tags: ['бизнес', 'инвестиции', 'ланч', 'нетворкинг', 'стартапы'],
        maxAttendees: 20,
        currentAttendees: 18,
        rating: 4.9,
        reviewCount: 15,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Event(
        id: 'today-5',
        title: 'Онлайн-лекция по цифровому маркетингу',
        description: 'Современные тренды в digital marketing. Кейсы успешных кампаний. Ответы на вопросы.',
        date: DateTime(now.year, now.month, now.day, 15, 0),
        endDate: DateTime(now.year, now.month, now.day, 16, 30),
        color: Colors.indigo,
        category: 'Образование',
        location: 'Онлайн',
        address: 'Zoom конференция',
        price: 0,
        organizer: 'Академия маркетинга',
        imageUrl: 'https://avatars.mds.yandex.net/get-music-content/3807445/2e6f1e84.p.123456/s400x400',
        tags: ['маркетинг', 'онлайн', 'лекция', 'digital', 'бесплатно', 'образование'],
        maxAttendees: 200,
        currentAttendees: 156,
        rating: 4.6,
        reviewCount: 89,
        isOnline: true,
        onlineLink: 'https://zoom.us/j/123456789',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Event(
        id: 'today-6',
        title: 'Вечерний джазовый концерт',
        description: 'Живые выступления местных джазовых коллективов. Уютная атмосфера, отличная музыка и вкусные напитки.',
        date: DateTime(now.year, now.month, now.day, 19, 0),
        endDate: DateTime(now.year, now.month, now.day, 22, 0),
        color: Colors.purple,
        category: 'Концерты',
        location: 'Джаз-клуб "Блюз"',
        address: 'ул. Музыкальная, 56',
        price: 800,
        organizer: 'Джазовое сообщество',
        imageUrl: 'https://avatars.mds.yandex.net/get-music-content/3807445/2e6f1e84.p.123456/s400x400',
        tags: ['джаз', 'музыка', 'живое выступление', 'клуб', 'вечер'],
        maxAttendees: 80,
        currentAttendees: 72,
        rating: 4.9,
        reviewCount: 45,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Event(
        id: 'today-7',
        title: 'Тренировка по баскетболу',
        description: 'Открытая тренировка для всех желающих. Разминка, упражнения и товарищеский матч. Приносите спортивную форму.',
        date: DateTime(now.year, now.month, now.day, 18, 0),
        endDate: DateTime(now.year, now.month, now.day, 20, 0),
        color: Colors.red,
        category: 'Спорт',
        location: 'Спортивный комплекс "Олимп"',
        address: 'пр. Спортивный, 25',
        price: 300,
        organizer: 'Баскетбольный клуб "Старт"',
        imageUrl: 'https://avatars.mds.yandex.net/i?id=b92c10245d6516454cb0d2e8d8bec4ef_l-5334622-images-thumbs&n=13',
        tags: ['баскетбол', 'спорт', 'тренировка', 'командная игра', 'фитнес'],
        maxAttendees: 30,
        currentAttendees: 24,
        rating: 4.7,
        reviewCount: 32,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Event(
        id: 'today-8',
        title: 'Кулинарный мастер-класс "Итальянская паста"',
        description: 'Учимся готовить три вида итальянской пасты от шеф-повара. Дегустация и рецепты в подарок.',
        date: DateTime(now.year, now.month, now.day, 17, 0),
        endDate: DateTime(now.year, now.month, now.day, 19, 30),
        color: Colors.orange,
        category: 'Образование',
        location: 'Кулинарная студия "Вкусно"',
        address: 'пр. Гастрономический, 12',
        price: 2000,
        organizer: 'Школа кулинарии',
        imageUrl: 'https://avatars.mds.yandex.net/i?id=91644e3209ae52f649fd184ab5db8491_l-5234681-images-thumbs&n=13',
        tags: ['кулинария', 'итальянская кухня', 'паста', 'мастер-класс', 'еда'],
        maxAttendees: 12,
        currentAttendees: 10,
        rating: 4.9,
        reviewCount: 23,
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  // Метод для получения событий по времени (прошедшие, текущие, будущие)
  static Map<String, List<Event>> getCategorizedEvents() {
    final now = DateTime.now();
    final allTodayEvents = getEvents();

    final pastEvents = allTodayEvents.where((event) => event.endDate.isBefore(now)).toList();
    final currentEvents = allTodayEvents.where((event) =>
    event.date.isBefore(now) && event.endDate.isAfter(now)
    ).toList();
    final upcomingEvents = allTodayEvents.where((event) => event.date.isAfter(now)).toList();

    return {
      'past': pastEvents,
      'current': currentEvents,
      'upcoming': upcomingEvents,
    };
  }

  // Метод для получения ближайших событий (следующие 3 часа)
  static List<Event> getUpcomingEvents({int hours = 3}) {
    final now = DateTime.now();
    final endTime = now.add(Duration(hours: hours));

    return getEvents().where((event) =>
    event.date.isAfter(now) && event.date.isBefore(endTime)
    ).toList();
  }

  // Метод для получения событий по категории
  static List<Event> getEventsByCategory(String category) {
    return getEvents().where((event) => event.category == category).toList();
  }

  // Метод для получения бесплатных событий
  static List<Event> getFreeEvents() {
    return getEvents().where((event) => event.price == 0).toList();
  }

  // Метод для получения онлайн событий
  static List<Event> getOnlineEvents() {
    return getEvents().where((event) => event.isOnline).toList();
  }
}