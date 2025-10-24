const ydbService = require('./src/services/ydb-service');

// Инициализируем YDB при старте функции
let ydbInitialized = false;

module.exports.handler = async (event, context) => {
  console.log('📨 Received request:', JSON.stringify(event, null, 2));

  // Инициализация YDB (только при первом вызове)
  if (!ydbInitialized) {
    try {
      await ydbService.init();
      ydbInitialized = true;
      console.log('✅ YDB initialized successfully');
    } catch (error) {
      console.error('❌ YDB initialization failed:', error);
    }
  }

  // CORS headers
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization,Origin,Accept,X-Requested-With',
    'Access-Control-Allow-Credentials': 'true',
    'Access-Control-Max-Age': '86400'
  };

  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: headers,
      body: '',
    };
  }

  // Получаем путь и метод
  const path = event.path || '';
  const method = event.httpMethod;
  const body = event.body ? JSON.parse(event.body) : {};

  console.log(`🔄 Processing path: ${path}, method: ${method}`);

  // Исправляем пути
  let cleanPath = path;
  if (cleanPath.includes('{proxy+}')) {
    cleanPath = cleanPath.replace('/{proxy+}', '');
  }

  if (cleanPath === '' || cleanPath === '/') {
    cleanPath = '/health';
  }

  console.log(`🎯 Clean path: ${cleanPath}`);

  try {
    // Routes based on clean path
    if (cleanPath === '/health') {
      return {
        statusCode: 200,
        headers: headers,
        body: JSON.stringify({
          status: 'OK',
          server: 'Cloud Functions + YDB',
          timestamp: new Date().toISOString(),
          ydb_initialized: ydbInitialized,
          message: 'Сервер работает с Yandex Database! 🚀'
        }),
      };
    }

    if (cleanPath === '/getNews' && method === 'GET') {
      let news = [];

      try {
        // Получаем новости из YDB
        news = await ydbService.getNews(20);
        console.log(`✅ Loaded ${news.length} news from YDB`);

        // Исправленный парсинг данных
        const enrichedNews = news.map((newsItem) => {
          // Парсим JSON поля если они в строковом формате
          const hashtags = typeof newsItem.hashtags === 'string'
            ? JSON.parse(newsItem.hashtags)
            : (newsItem.hashtags || []);

          const user_tags = typeof newsItem.user_tags === 'string'
            ? JSON.parse(newsItem.user_tags)
            : (newsItem.user_tags || {});

          // Форматируем дату
          let createdAt = newsItem.created_at;
          if (createdAt instanceof Date) {
            createdAt = createdAt.toISOString();
          } else if (typeof createdAt === 'number') {
            createdAt = new Date(createdAt).toISOString();
          } else if (!createdAt) {
            createdAt = new Date().toISOString();
          }

          // Форматируем автора
          const authorName = newsItem.author_name || 'Неизвестный автор';
          const authorId = newsItem.author_id || 'unknown';
          const authorAvatar = newsItem.author_avatar || '';

          return {
            id: newsItem.id || `news_${Date.now()}`,
            title: newsItem.title || 'Без названия',
            description: newsItem.description || 'Нет описания',
            content: newsItem.content || newsItem.description || 'Нет содержимого',
            author_id: authorId,
            author_name: authorName,
            author_avatar: authorAvatar,
            likes: Number.isInteger(newsItem.likes) ? newsItem.likes : 0,
            reposts: Number.isInteger(newsItem.reposts) ? newsItem.reposts : 0,
            hashtags: hashtags,
            user_tags: user_tags,
            is_repost: Boolean(newsItem.is_repost),
            is_channel_post: Boolean(newsItem.is_channel_post),
            original_news_id: newsItem.original_news_id || null,
            created_at: createdAt,
            updated_at: newsItem.updated_at ? (
              newsItem.updated_at instanceof Date ?
                newsItem.updated_at.toISOString() :
                new Date(newsItem.updated_at).toISOString()
            ) : createdAt,
            // Добавляем поля для Flutter
            isLiked: false,
            isBookmarked: false,
            isReposted: false,
            isFollowing: false,
            comments: []
          };
        });

        // Сортируем по дате создания (новые сначала)
        enrichedNews.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        news = enrichedNews;

        console.log('📊 Processed news:', enrichedNews.map(n => ({
          id: n.id,
          title: n.title,
          author: n.author_name,
          likes: n.likes
        })));

      } catch (dbError) {
        console.error('❌ YDB news load failed, using mock data:', dbError);
        // Fallback to mock data
        news = getMockNews();
      }

      // Возвращаем правильный формат для Flutter
      return {
        statusCode: 200,
        headers: headers,
        body: JSON.stringify({
          success: true,
          data: news
        }),
      };
    }

    if (cleanPath === '/login' && method === 'POST') {
      if (body.email && body.password) {
        try {
          // Поиск пользователя в YDB
          let user = await ydbService.findUserByEmail(body.email);

          if (!user) {
            // Создаем нового пользователя если не найден
            user = {
              id: 'user_' + Date.now(),
              name: body.email.split('@')[0],
              email: body.email,
              password_hash: 'hashed_' + body.password,
              avatar: '',
              created_at: new Date(),
              updated_at: new Date()
            };

            await ydbService.createUser(user);
            console.log('✅ New user created in YDB:', user.id);
          }

          return {
            statusCode: 200,
            headers: headers,
            body: JSON.stringify({
              success: true,
              token: 'mock-jwt-token-for-cloud-functions',
              user: {
                id: user.id,
                name: user.name,
                email: user.email,
                avatar: user.avatar
              }
            }),
          };
        } catch (dbError) {
          console.error('❌ YDB auth error:', dbError);
          return {
            statusCode: 500,
            headers: headers,
            body: JSON.stringify({
              success: false,
              error: 'Database error'
            }),
          };
        }
      } else {
        return {
          statusCode: 400,
          headers: headers,
          body: JSON.stringify({
            success: false,
            error: 'Email and password required'
          }),
        };
      }
    }

    // 🎯 ДОБАВЛЯЕМ РЕГИСТРАЦИЮ
    if (cleanPath === '/register' && method === 'POST') {
      if (body.email && body.password && body.name) {
        try {
          // Проверяем, есть ли уже пользователь
          let existingUser = await ydbService.findUserByEmail(body.email);

          if (existingUser) {
            return {
              statusCode: 400,
              headers: headers,
              body: JSON.stringify({
                success: false,
                error: 'User already exists'
              }),
            };
          }

          // Создаем нового пользователя
          const user = {
            id: 'user_' + Date.now(),
            name: body.name,
            email: body.email,
            password_hash: 'hashed_' + body.password,
            avatar: '',
            created_at: new Date(),
            updated_at: new Date()
          };

          await ydbService.createUser(user);
          console.log('✅ New user registered in YDB:', user.id);

          return {
            statusCode: 201,
            headers: headers,
            body: JSON.stringify({
              success: true,
              token: 'mock-jwt-token-for-' + user.id,
              user: {
                id: user.id,
                name: user.name,
                email: user.email,
                avatar: user.avatar
              }
            }),
          };
        } catch (dbError) {
          console.error('❌ YDB registration error:', dbError);
          return {
            statusCode: 500,
            headers: headers,
            body: JSON.stringify({
              success: false,
              error: 'Database error'
            }),
          };
        }
      } else {
        return {
          statusCode: 400,
          headers: headers,
          body: JSON.stringify({
            success: false,
            error: 'Name, email and password required'
          }),
        };
      }
    }

    if (cleanPath === '/createNews' && method === 'POST') {
      try {
        const newsData = {
          id: 'news_' + Date.now(),
          title: body.title || 'Новая новость',
          description: body.description || 'Описание новости',
          content: body.content || body.description || 'Содержимое новости',
          author_id: body.author_id || 'unknown',
          author_name: body.author_name || 'Пользователь',
          author_avatar: body.author_avatar || '',
          likes: 0,
          reposts: 0,
          hashtags: body.hashtags || [],
          user_tags: body.user_tags || {},
          is_repost: body.is_repost || false,
          is_channel_post: body.is_channel_post || false,
          created_at: new Date(),
          updated_at: new Date()
        };

        await ydbService.createNews(newsData);

        // Возвращаем правильный формат с news полем
        return {
          statusCode: 201,
          headers: headers,
          body: JSON.stringify({
            success: true,
            message: 'News created successfully in YDB',
            news: {
              id: newsData.id,
              title: newsData.title,
              description: newsData.description,
              author_name: newsData.author_name,
              author_id: newsData.author_id,
              author_avatar: newsData.author_avatar,
              likes: newsData.likes,
              reposts: newsData.reposts,
              hashtags: newsData.hashtags,
              user_tags: newsData.user_tags,
              comments: [],
              created_at: newsData.created_at.toISOString(),
              isLiked: false,
              isBookmarked: false,
              isReposted: false,
              isFollowing: false
            }
          }),
        };
      } catch (error) {
        console.error('❌ YDB create news error:', error);
        return {
          statusCode: 500,
          headers: headers,
          body: JSON.stringify({
            success: false,
            error: 'Failed to create news: ' + error.message
          }),
        };
      }
    }

    // Default response for unknown paths
    return {
      statusCode: 404,
      headers: headers,
      body: JSON.stringify({
        success: false,
        error: 'Route not found: ' + cleanPath,
        original_path: path,
        available_routes: ['/health', '/getNews', '/createNews', '/login', '/register']
      }),
    };

  } catch (error) {
    console.error('❌ Handler error:', error);
    return {
      statusCode: 500,
      headers: headers,
      body: JSON.stringify({
        success: false,
        error: 'Internal server error: ' + error.message
      }),
    };
  }
};

// Mock data fallback
function getMockNews() {
  return [
    {
      id: 'mock-1',
      title: 'Сервер запущен в облаке с YDB! 🎉',
      description: 'Ваш News App сервер успешно работает с Yandex Database',
      author_name: 'Система',
      author_id: 'system',
      author_avatar: '',
      likes: 5,
      reposts: 2,
      comments: [],
      hashtags: ['облако', 'ydb', 'успех'],
      created_at: new Date().toISOString(),
      isLiked: false,
      isBookmarked: false,
      isReposted: false,
      isFollowing: false
    }
  ];
}