const ydbService = require('../services/ydb-service');

async function seedDatabase() {
  try {
    console.log('🌱 Seeding YDB with sample data...');

    // Добавляем тестовых пользователей
    const users = [
      {
        id: 'user_1',
        name: 'Анна Петрова',
        email: 'anna@example.com',
        password_hash: 'hashed_password_1',
        avatar: '',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'user_2',
        name: 'Иван Сидоров',
        email: 'ivan@example.com',
        password_hash: 'hashed_password_2',
        avatar: '',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: 'user_3',
        name: 'Мария Иванова',
        email: 'maria@example.com',
        password_hash: 'hashed_password_3',
        avatar: '',
        created_at: new Date(),
        updated_at: new Date()
      }
    ];

    for (const user of users) {
      try {
        await ydbService.insert('users', user);
        console.log(`✅ User added: ${user.name}`);
      } catch (error) {
        if (!error.message.includes('already exists')) {
          console.error(`❌ Error adding user ${user.name}:`, error);
        }
      }
    }

    // Добавляем тестовые новости
    const news = [
      {
        id: 'news_1',
        title: 'Flutter 3.0 вышел с новыми возможностями! 🚀',
        description: 'Google выпустил Flutter 3.0 с поддержкой macOS и Linux, улучшенной производительностью и новыми виджетами.',
        content: 'Flutter 3.0 представляет собой крупнейшее обновление за последние годы. Добавлена нативная поддержка macOS и Linux, что позволяет разрабатывать приложения для 6 платформ из единой кодовой базы. Производительность увеличена на 20% благодаря оптимизации движка Dart.',
        author_id: 'user_1',
        author_name: 'Анна Петрова',
        author_avatar: '',
        likes: 15,
        reposts: 3,
        hashtags: JSON.stringify(['flutter', 'разработка', 'мобильные']),
        user_tags: JSON.stringify({}),
        is_repost: false,
        is_channel_post: false,
        created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 дня назад
        updated_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000)
      },
      {
        id: 'news_2',
        title: 'Yandex Cloud теперь с автоматическим масштабированием',
        description: 'Yandex Cloud Functions теперь поддерживают автоматическое масштабирование до 1000 одновременных экземпляров.',
        content: 'Обновление Yandex Cloud Functions позволяет автоматически масштабировать приложения в зависимости от нагрузки. Это особенно полезно для мобильных приложений с переменной нагрузкой. Стоимость остается прежней - оплата только за фактическое использование ресурсов.',
        author_id: 'user_2',
        author_name: 'Иван Сидоров',
        author_avatar: '',
        likes: 8,
        reposts: 1,
        hashtags: JSON.stringify(['облако', 'yandex', 'масштабирование']),
        user_tags: JSON.stringify({}),
        is_repost: false,
        is_channel_post: false,
        created_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1 день назад
        updated_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000)
      },
      {
        id: 'news_3',
        title: 'Dart 3.0 - полная поддержка null safety',
        description: 'Вышел Dart 3.0 с полной поддержкой null safety и новыми возможностями языка.',
        content: 'Dart 3.0 завершил переход к полной null safety, что делает код более безопасным и производительным. Добавлены records и patterns для более выразительного кода. Производительность увеличена на 15% по сравнению с предыдущей версией.',
        author_id: 'user_3',
        author_name: 'Мария Иванова',
        author_avatar: '',
        likes: 12,
        reposts: 2,
        hashtags: JSON.stringify(['dart', 'программирование', 'null-safety']),
        user_tags: JSON.stringify({}),
        is_repost: false,
        is_channel_post: false,
        created_at: new Date(),
        updated_at: new Date()
      }
    ];

    for (const newsItem of news) {
      try {
        await ydbService.insert('news', newsItem);
        console.log(`✅ News added: ${newsItem.title}`);
      } catch (error) {
        if (!error.message.includes('already exists')) {
          console.error(`❌ Error adding news ${newsItem.title}:`, error);
        }
      }
    }

    // Добавляем лайки
    const likes = [
      { user_id: 'user_2', news_id: 'news_1', created_at: new Date() },
      { user_id: 'user_3', news_id: 'news_1', created_at: new Date() },
      { user_id: 'user_1', news_id: 'news_2', created_at: new Date() },
      { user_id: 'user_1', news_id: 'news_3', created_at: new Date() },
      { user_id: 'user_2', news_id: 'news_3', created_at: new Date() }
    ];

    for (const like of likes) {
      try {
        await ydbService.insert('likes', like);
      } catch (error) {
        // Игнорируем ошибки дубликатов
      }
    }

    console.log('✅ Database seeding completed!');
    return true;

  } catch (error) {
    console.error('❌ Database seeding failed:', error);
    return false;
  }
}

module.exports = { seedDatabase };