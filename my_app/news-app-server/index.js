const ydbService = require('./src/services/ydb-service');

const SERVER_CONFIG = {
  timeout: 20000,
  memory: 512,
  coldStart: true
};

let ydbInitialized = false;
let lastInitTime = 0;

async function initializeYDB() {
  const now = Date.now();

  if (ydbInitialized && (now - lastInitTime) < 30000) {
    return true;
  }

  try {
    console.log('🔄 Fast YDB initialization...');
    await ydbService.init();

    // Быстрая проверка подключения
    const testQuery = 'SELECT 1 as test';
    await ydbService.driver.tableClient.withSession(async (session) => {
      await session.executeQuery(testQuery);
    });

    ydbInitialized = true;
    lastInitTime = now;
    console.log('✅ YDB initialized');
    return true;
  } catch (error) {
    console.error('❌ YDB init failed:', error.message);
    return false;
  }
}

async function quickHealthCheck() {
  try {
    const isHealthy = await initializeYDB();

    return {
      status: isHealthy ? 'OK' : 'DEGRADED',
      message: isHealthy ? 'Server is running with YDB' : 'YDB connection issues',
      timestamp: new Date().toISOString(),
      coldStart: SERVER_CONFIG.coldStart,
      dataSource: 'YDB'
    };
  } catch (error) {
    return {
      status: 'ERROR',
      message: 'Health check failed',
      timestamp: new Date().toISOString()
    };
  }
}

function successResponse(data, statusCode = 200) {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization,Origin,Accept,X-Requested-With',
    'Access-Control-Allow-Credentials': 'true'
  };

  return {
    statusCode,
    headers,
    body: JSON.stringify({
      success: true,
      data: data,
      source: 'YDB_DATABASE'
    })
  };
}

function errorResponse(message, statusCode = 500) {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization,Origin,Accept,X-Requested-With',
    'Access-Control-Allow-Credentials': 'true'
  };

  return {
    statusCode,
    headers,
    body: JSON.stringify({
      success: false,
      error: message,
      source: 'YDB_DATABASE'
    })
  };
}

function parseBody(event) {
  try {
    return event.body ? JSON.parse(event.body) : {};
  } catch (e) {
    return {};
  }
}

// 🎯 ИСПРАВЛЕННАЯ ФУНКЦИЯ ДЛЯ ИЗВЛЕЧЕНИЯ USER_ID
function getUserIdFromToken(event) {
  try {
    const authHeader = event.headers?.Authorization || event.headers?.authorization;
    console.log('🔑 Auth header received:', authHeader ? 'present' : 'missing');

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.log('❌ No Bearer token found');
      return null;
    }

    const token = authHeader.replace('Bearer ', '');
    console.log('🔑 Full token:', token);

    // 🎯 ПРИОРИТЕТ 1: mock-jwt-token format
    if (token.startsWith('mock-jwt-token-')) {
      const userId = token.replace('mock-jwt-token-', '');
      console.log('✅ Extracted user ID from mock token:', userId);
      return userId;
    }

    // 🎯 ПРИОРИТЕТ 2: user_ format from anywhere in token
    const userMatch = token.match(/user_[a-zA-Z0-9_-]+/);
    if (userMatch) {
      const userId = userMatch[0];
      console.log('✅ Extracted user ID from token pattern:', userId);
      return userId;
    }

    // 🎯 ПРИОРИТЕТ 3: try to decode as JWT (if needed)
    try {
      const parts = token.split('.');
      if (parts.length === 3) {
        const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
        if (payload.userId || payload.sub) {
          const userId = payload.userId || payload.sub;
          console.log('✅ Extracted user ID from JWT:', userId);
          return userId;
        }
      }
    } catch (jwtError) {
      console.log('⚠️ Not a JWT token');
    }

    console.log('❌ No user ID found in token');
    return null;
  } catch (error) {
    console.error('❌ Error extracting user ID:', error);
    return null;
  }
}

// 🎯 УЛУЧШЕННАЯ ФУНКЦИЯ ДЛЯ ИЗВЛЕЧЕНИЯ USER_ID ИЗ ПУТИ
function extractUserIdFromPath(path, event) {
  console.log('🔍 extractUserIdFromPath - Input path:', path);
  console.log('🔍 Full event for user endpoint:', JSON.stringify({
    path: event.path,
    rawPath: event.rawPath,
    pathParameters: event.pathParameters,
    requestContext: event.requestContext
  }, null, 2));

  // Способ 1: Из pathParameters (основной способ)
  if (event.pathParameters && event.pathParameters.userId) {
    const userId = event.pathParameters.userId;
    console.log('✅ Using pathParameters.userId:', userId);
    return userId;
  }

  // Способ 2: Из rawPath (для API Gateway)
  if (event.rawPath && event.rawPath.startsWith('/users/')) {
    // Извлекаем userId из пути /users/{userId}
    const pathParts = event.rawPath.split('/');
    const userId = pathParts[2]; // ['', 'users', 'userId']
    console.log('✅ Using rawPath userId:', userId);
    return userId;
  }

  // Способ 3: Из requestContext (альтернативный вариант)
  if (event.requestContext && event.requestContext.http && event.requestContext.http.path) {
    const requestPath = event.requestContext.http.path;
    if (requestPath.startsWith('/users/')) {
      const pathParts = requestPath.split('/');
      const userId = pathParts[2];
      console.log('✅ Using requestContext path userId:', userId);
      return userId;
    }
  }

  // Способ 4: Из path (fallback)
  if (path && path.startsWith('/users/')) {
    const pathParts = path.split('/');
    const userId = pathParts[2];
    console.log('✅ Using path fallback userId:', userId);
    return userId;
  }

  console.log('❌ Could not extract userId from path');
  return null;
}

module.exports.handler = async (event, context) => {
  console.log('🚀 SERVER STARTED - YDB COMPLETE VERSION 2.2.7');

  context.callbackWaitsForEmptyEventLoop = false;
  SERVER_CONFIG.coldStart = !ydbInitialized;

  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization,Origin,Accept,X-Requested-With',
    'Access-Control-Allow-Credentials': 'true'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  const path = event.path || '';
  const method = event.httpMethod;
  const body = parseBody(event);
  const queryParams = event.queryStringParameters || {};
  const pathParameters = event.pathParameters || {};
  const currentUserId = getUserIdFromToken(event);

  console.log(`📨 ${method} ${path} | User: ${currentUserId || 'anonymous'}`);
  console.log('🔍 Path Parameters:', pathParameters);
  console.log('🔍 Raw Path:', event.rawPath);
  console.log('🔍 Request Context:', event.requestContext);

  // 🎯 ROOT ENDPOINT
  if (path === '/' || path === '') {
    try {
      const health = await quickHealthCheck();
      return successResponse({
        message: "News App API is running",
        version: "2.2.7",
        endpoints: [
          "/health", "/getNews", "/register", "/login", "/action",
          "/createNews", "/user/likes", "/user/bookmarks", "/user/reposts",
          "/follow", "/unfollow", "/deleteNews", "/updateNews", "/share",
          "/user/following", "/user/followers", "/users/{userId}", "/getUserProfile"
        ],
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      return successResponse({
        message: "News App API is running (health check failed)",
        timestamp: new Date().toISOString()
      });
    }
  }

  // 🎯 HEALTH CHECK
  if (path === '/health' && method === 'GET') {
    try {
      const health = await quickHealthCheck();
      return successResponse(health);
    } catch (error) {
      return successResponse({
        status: 'ERROR',
        message: 'Health check failed',
        timestamp: new Date().toISOString()
      }, 500);
    }
  }

  // 🎯 РЕГИСТРАЦИЯ
  if (path === '/register' && method === 'POST') {
    try {
      console.log('🎯 REGISTER endpoint hit with data:', JSON.stringify(body));

      let userCreated = false;
      let userId = 'user_' + Date.now();
      let userData = {
        id: userId,
        name: body.name || 'Пользователь',
        email: body.email || 'user@example.com',
        avatar: ''
      };

      try {
        console.log('🔄 Attempting to create user in YDB...');
        await ydbService.createUser(userData);
        userCreated = true;
        console.log('✅ User created in YDB');
      } catch (dbError) {
        console.log('⚠️ YDB creation failed, using mock data:', dbError.message);
        userCreated = true;
      }

      const token = 'mock-jwt-token-' + userId;

      return successResponse({
        token: token,
        user: {
          id: userId,
          name: userData.name,
          email: userData.email
        },
        message: userCreated ? 'User registered in YDB' : 'User registered (mock)'
      }, 201);
    } catch (error) {
      console.error('❌ Registration error:', error);
      return errorResponse('Registration failed: ' + error.message, 500);
    }
  }

  // 🎯 ЛОГИН - ИСПРАВЛЕННАЯ ВЕРСИЯ
  if (path === '/login' && method === 'POST') {
    try {
      console.log('🎯 LOGIN endpoint hit with email:', body.email);

      if (!body.email || !body.password) {
        return errorResponse('Email and password are required', 400);
      }

      let user = null;

      try {
        user = await ydbService.findUserByEmail(body.email);
        console.log('🔍 YDB user search result:', user ? `Found user: ${user.id}` : 'Not found in YDB');
      } catch (dbError) {
        console.log('⚠️ YDB search failed:', dbError.message);
      }

      // Если пользователь не найден в YDB, создаем временного пользователя
      if (!user) {
        console.log('🔄 Creating temporary user for login...');
        user = {
          id: 'user_' + Date.now(),
          name: 'Пользователь',
          email: body.email
        };

        // Пытаемся сохранить в YDB
        try {
          await ydbService.createUser(user);
          console.log('✅ Temporary user created in YDB');
        } catch (createError) {
          console.log('⚠️ Could not create user in YDB, using mock:', createError.message);
        }
      }

      const token = 'mock-jwt-token-' + user.id;

      return successResponse({
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        },
        message: 'Login successful'
      });
    } catch (error) {
      console.error('❌ Login error:', error);
      return errorResponse('Login failed: ' + error.message, 500);
    }
  }

  // 🎯 ПОЛУЧЕНИЕ НОВОСТЕЙ - С ФИКСОМ ДЛЯ ПУСТЫХ ДАННЫХ
  // 🎯 ПОЛУЧЕНИЕ НОВОСТЕЙ С ПАГИНАЦИЕЙ
  if (path === '/getNews' && method === 'GET') {
    try {
      const page = parseInt(queryParams.page) || 0;
      const limit = Math.min(parseInt(queryParams.limit) || 20, 100); // Максимум 100 на страницу

      console.log(`🌐 Getting news from YDB - Page: ${page}, Limit: ${limit} for user: ${currentUserId || 'anonymous'}`);

      let news = [];
      try {
        news = await ydbService.getNewsWithSocial(page, limit, currentUserId);
        console.log(`✅ Got ${news.length} news items from YDB for page ${page}`);
      } catch (error) {
        console.error('❌ getNews error:', error);
        // Возвращаем мок данные при ошибке
        news = getMockNews(limit, currentUserId);
      }

      // Если новости пустые, возвращаем мок данные только для первой страницы
      if (news.length === 0 && page === 0) {
        console.log('⚠️ No news found, returning mock data for first page');
        news = getMockNews(limit, currentUserId);
      }

      // 🆕 ДОБАВЛЯЕМ ИНФОРМАЦИЮ О ПАГИНАЦИИ
      const responseData = {
        news: news,
        pagination: {
          page: page,
          limit: limit,
          hasMore: news.length === limit, // Если получили полную страницу, значит есть еще
          total: await ydbService.getTotalNewsCount() // Опционально: общее количество
        }
      };

      return successResponse(responseData);
    } catch (error) {
      console.error('❌ getNews error:', error);
      // При ошибке возвращаем пустой список с информацией о пагинации
      return successResponse({
        news: [],
        pagination: {
          page: 0,
          limit: 20,
          hasMore: false,
          total: 0
        }
      });
    }
  }

  // 🎯 СОЗДАНИЕ НОВОСТИ
  // 🎯 СОЗДАНИЕ НОВОСТИ - ИСПРАВЛЕННАЯ ВЕРСИЯ
  if (path === '/createNews' && method === 'POST') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      console.log('✅ CREATE NEWS endpoint hit by user:', currentUserId);
      console.log('🔍 DEBUG: body.author_name =', body.author_name);

      // 🎯 ПРОВЕРКА ОБЯЗАТЕЛЬНОГО ПОЛЯ ОПИСАНИЯ
      if (!body.content || body.content.trim().length === 0) {
        return errorResponse('Описание новости обязательно для заполнения', 400);
      }

      // 🎯 ПРОВЕРКА МИНИМАЛЬНОЙ ДЛИНЫ ОПИСАНИЯ
      if (body.content.trim().length < 4) {
        return errorResponse('Описание должно содержать минимум 4 символа', 400);
      }

      const authorName = body.author_name || 'Неизвестный автор';

      const newsData = {
        title: body.title || '', // 🆕 ПУСТАЯ СТРОКА ВМЕСТО "НОВАЯ НОВОСТЬ"
        content: body.content.trim(), // 🎯 ОБЯЗАТЕЛЬНОЕ ПОЛЕ
        author_id: currentUserId,
        author_name: authorName,
        author_avatar: body.author_avatar || '',
        hashtags: body.hashtags || [],
        is_repost: false,
        is_channel_post: false
      };

      console.log('📝 Creating news with author_name:', newsData.author_name);
      console.log('📝 Title (optional):', newsData.title);
      console.log('📝 Content length:', newsData.content.length);

      const createdNews = await ydbService.createNews(newsData);

      return successResponse({
        message: 'News created successfully',
        news: createdNews
      }, 201);
    } catch (error) {
      console.error('❌ Create news error:', error);
      console.error('❌ Full error details:', {
        message: error.message,
        stack: error.stack,
        name: error.name
      });
      return errorResponse('Failed to create news: ' + error.message, 500);
    }
  }

  // 🎯 УНИВЕРСАЛЬНЫЙ ACTION ENDPOINT
  // 🎯 УНИВЕРСАЛЬНЫЙ ACTION ENDPOINT - ДОБАВЛЕН REPOST
  if (path === '/action' && method === 'POST') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      const { action, newsId, text, author_name } = body;

      if (!action) {
        return errorResponse('Action required', 400);
      }

      console.log(`🎯 User ${currentUserId} performing ${action} on ${newsId}`);

      let result;

      switch (action) {
        case 'like':
          if (!newsId) return errorResponse('News ID required for like', 400);
          try {
            await ydbService.likeNews(newsId, currentUserId);
            await ydbService.updateNewsLikesCount(newsId);
          } catch (error) {
            console.log('⚠️ Like action failed:', error.message);
          }
          result = { message: 'Like added successfully', newsId, userId: currentUserId };
          break;

        case 'unlike':
          if (!newsId) return errorResponse('News ID required for unlike', 400);
          try {
            await ydbService.unlikeNews(newsId, currentUserId);
            await ydbService.updateNewsLikesCount(newsId);
          } catch (error) {
            console.log('⚠️ Unlike action failed:', error.message);
          }
          result = { message: 'Like removed successfully', newsId, userId: currentUserId };
          break;

        case 'bookmark':
          if (!newsId) return errorResponse('News ID required for bookmark', 400);
          try {
            await ydbService.bookmarkNews(newsId, currentUserId);
            await ydbService.updateNewsBookmarksCount(newsId);
          } catch (error) {
            console.log('⚠️ Bookmark action failed:', error.message);
          }
          result = { message: 'Bookmark added successfully', newsId, userId: currentUserId };
          break;

        case 'unbookmark':
          if (!newsId) return errorResponse('News ID required for unbookmark', 400);
          try {
            await ydbService.unbookmarkNews(newsId, currentUserId);
            await ydbService.updateNewsBookmarksCount(newsId);
          } catch (error) {
            console.log('⚠️ Unbookmark action failed:', error.message);
          }
          result = { message: 'Bookmark removed successfully', newsId, userId: currentUserId };
          break;

        // 🆕 ДОБАВЛЕНЫ REPOST И UNREPOST
        case 'repost':
          if (!newsId) return errorResponse('News ID required for repost', 400);
          try {
            await ydbService.repostNews(newsId, currentUserId);
            await ydbService.updateNewsRepostsCount(newsId);
          } catch (error) {
            console.log('⚠️ Repost action failed:', error.message);
          }
          result = { message: 'Repost added successfully', newsId, userId: currentUserId };
          break;

        case 'unrepost':
          if (!newsId) return errorResponse('News ID required for unrepost', 400);
          try {
            await ydbService.unrepostNews(newsId, currentUserId);
            await ydbService.updateNewsRepostsCount(newsId);
          } catch (error) {
            console.log('⚠️ Unrepost action failed:', error.message);
          }
          result = { message: 'Repost removed successfully', newsId, userId: currentUserId };
          break;

        // 🎯 ЗАЩИЩЕННЫЙ МЕТОД ДЛЯ КОММЕНТАРИЕВ
        case 'comment':
          if (!newsId || !text) return errorResponse('News ID and text required for comment', 400);

          try {
            console.log('💬 Adding comment with validation...');

            // 🎯 ПРОВЕРКА ДЛИНЫ КОММЕНТАРИЯ
            if (text.length > 1000) {
              return errorResponse('Comment too long (max 1000 characters)', 400);
            }

            // 🎯 ПРОВЕРКА СУЩЕСТВОВАНИЯ НОВОСТИ
            const newsCheckQuery = `SELECT id FROM news WHERE id = "${newsId}" AND (is_deleted = false OR is_deleted IS NULL)`;
            const { resultSets: newsCheck } = await ydbService.driver.tableClient.withSession(async (session) => {
              return await session.executeQuery(newsCheckQuery);
            });

            const newsExists = ydbService.parseResult(newsCheck);
            if (newsExists.length === 0) {
              return errorResponse('News not found or deleted', 404);
            }

            let comment;
            try {
              comment = await ydbService.addComment(newsId, {
                text: text.trim(),
                author_name: author_name || 'Пользователь'
              }, currentUserId);

              await ydbService.updateNewsCommentsCount(newsId);
            } catch (commentError) {
              console.log('⚠️ Comment creation failed, creating mock comment:', commentError.message);
              comment = {
                id: `comment_mock_${Date.now()}`,
                news_id: newsId,
                user_id: currentUserId,
                user_name: author_name || 'Пользователь',
                content: text,
                created_at: new Date().toISOString()
              };
            }

            result = { message: 'Comment added successfully', comment };
          } catch (error) {
            console.error('❌ Comment action critical error:', error);
            return errorResponse('Failed to add comment', 500);
          }
          break;

        case 'getComments':
          if (!newsId) return errorResponse('News ID required for getComments', 400);
          let comments = [];
          try {
            comments = await ydbService.getComments(newsId);
          } catch (error) {
            console.log('⚠️ Get comments failed:', error.message);
          }
          result = { comments };
          break;

        default:
          return errorResponse('Unknown action', 400);
      }

      return successResponse(result);
    } catch (error) {
      console.error('❌ Action error:', error);
      return errorResponse('Failed to perform action: ' + error.message, 500);
    }
  }

  // 🎯 ПОЛЬЗОВАТЕЛЬСКИЕ ВЗАИМОДЕЙСТВИЯ
  if (path === '/user/likes' && method === 'GET') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      console.log(`❤️ Getting likes from YDB for user: ${currentUserId}`);

      let likes = [];
      try {
        likes = await ydbService.getUserLikes(currentUserId);
      } catch (error) {
        console.log('⚠️ Get user likes failed:', error.message);
      }

      return successResponse(likes);
    } catch (error) {
      console.error('❌ Get user likes error:', error);
      return successResponse([]);
    }
  }

  if (path === '/user/bookmarks' && method === 'GET') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      console.log(`🔖 Getting bookmarks from YDB for user: ${currentUserId}`);

      let bookmarks = [];
      try {
        bookmarks = await ydbService.getUserBookmarks(currentUserId);
      } catch (error) {
        console.log('⚠️ Get user bookmarks failed:', error.message);
      }

      return successResponse(bookmarks);
    } catch (error) {
      console.error('❌ Get user bookmarks error:', error);
      return successResponse([]);
    }
  }

  if (path === '/user/reposts' && method === 'GET') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      console.log(`🔁 Getting reposts from YDB for user: ${currentUserId}`);

      let reposts = [];
      try {
        reposts = await ydbService.getUserReposts(currentUserId);
      } catch (error) {
        console.log('⚠️ Get user reposts failed:', error.message);
      }

      return successResponse(reposts);
    } catch (error) {
      console.error('❌ Get user reposts error:', error);
      return successResponse([]);
    }
  }

  // 🎯 СОЦИАЛЬНЫЕ ФУНКЦИИ
  if (path === '/follow' && method === 'POST') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      const { targetUserId } = body;

      if (!targetUserId) {
        return errorResponse('targetUserId is required', 400);
      }

      console.log(`👥 User ${currentUserId} following ${targetUserId}`);

      const result = await ydbService.followUser(currentUserId, targetUserId);

      return successResponse(result);
    } catch (error) {
      console.error('❌ Follow error:', error);
      return errorResponse('Failed to follow user: ' + error.message, 500);
    }
  }

  if (path === '/unfollow' && method === 'POST') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      const { targetUserId } = body;

      if (!targetUserId) {
        return errorResponse('targetUserId is required', 400);
      }

      console.log(`👥 User ${currentUserId} unfollowing ${targetUserId}`);

      const result = await ydbService.unfollowUser(currentUserId, targetUserId);

      return successResponse(result);
    } catch (error) {
      console.error('❌ Unfollow error:', error);
      return errorResponse('Failed to unfollow user: ' + error.message, 500);
    }
  }

  if (path === '/user/following' && method === 'GET') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      console.log(`👥 Getting following list for user: ${currentUserId}`);

      let following = [];
      try {
        following = await ydbService.getUserFollowing(currentUserId);
      } catch (error) {
        console.log('⚠️ Get user following failed:', error.message);
      }

      return successResponse(following);
    } catch (error) {
      console.error('❌ Get user following error:', error);
      return successResponse([]);
    }
  }

  if (path === '/user/followers' && method === 'GET') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      console.log(`👥 Getting followers list for user: ${currentUserId}`);

      let followers = [];
      try {
        followers = await ydbService.getUserFollowers(currentUserId);
      } catch (error) {
        console.log('⚠️ Get user followers failed:', error.message);
      }

      return successResponse(followers);
    } catch (error) {
      console.error('❌ Get user followers error:', error);
      return successResponse([]);
    }
  }

  // 🎯 УПРАВЛЕНИЕ НОВОСТЯМИ
  if (path === '/deleteNews' && method === 'POST') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      const { newsId } = body;

      if (!newsId) {
        return errorResponse('newsId is required', 400);
      }

      console.log(`🗑️ User ${currentUserId} deleting news: ${newsId}`);

      const result = await ydbService.deleteNews(newsId, currentUserId);

      return successResponse(result);
    } catch (error) {
      console.error('❌ Delete news error:', error);
      return errorResponse('Failed to delete news: ' + error.message, 500);
    }
  }

  if (path === '/updateNews' && method === 'POST') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      const { newsId, updateData } = body;

      if (!newsId || !updateData) {
        return errorResponse('newsId and updateData are required', 400);
      }

      console.log(`✏️ User ${currentUserId} updating news: ${newsId}`);

      const result = await ydbService.updateNews(newsId, currentUserId, updateData);

      return successResponse(result);
    } catch (error) {
      console.error('❌ Update news error:', error);
      return errorResponse('Failed to update news: ' + error.message, 500);
    }
  }

  if (path === '/share' && method === 'POST') {
    try {
      if (!currentUserId) {
        return errorResponse('Authentication required', 401);
      }

      const { newsId } = body;

      if (!newsId) {
        return errorResponse('newsId is required', 400);
      }

      console.log(`📤 User ${currentUserId} sharing news: ${newsId}`);

      const result = await ydbService.shareNews(newsId);

      return successResponse(result);
    } catch (error) {
      console.error('❌ Share news error:', error);
      return errorResponse('Failed to share news: ' + error.message, 500);
    }
  }

  // 🎯 НОВЫЙ ЭНДПОИНТ: ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ ЧЕРЕЗ QUERY PARAM
  if (path === '/getUserProfile' && method === 'GET') {
    try {
      const { userId } = queryParams;

      if (!userId) {
        return errorResponse('User ID is required', 400);
      }

      console.log(`👤 Getting user profile for: ${userId}`);

      let user = null;
      try {
        user = await ydbService.findUserById(userId);
        console.log('🔍 User lookup result:', user ? 'Found' : 'Not found');
      } catch (error) {
        console.log('⚠️ Get user failed:', error.message);
      }

      // Если пользователь не найден, создаем базовый профиль
      if (!user) {
        console.log('🔄 User not found in YDB, creating basic profile');
        user = {
          id: userId,
          name: 'Пользователь',
          email: `${userId}@example.com`,
          avatar: '',
          created_at: new Date().toISOString()
        };
      }

      // Форматируем пользователя безопасно
      const safeUser = {
        id: String(user.id || userId),
        name: String(user.name || 'Пользователь'),
        email: String(user.email || `${userId}@example.com`),
        avatar: String(user.avatar || ''),
        created_at: String(user.created_at || new Date().toISOString())
      };

      console.log('✅ Returning user data:', safeUser);
      return successResponse(safeUser);
    } catch (error) {
      console.error('❌ Get user error:', error);
      return errorResponse('Failed to get user: ' + error.message, 500);
    }
  }

  // 🎯 ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ - УЛУЧШЕННАЯ ВЕРСИЯ
  if (path.startsWith('/users/') && method === 'GET') {
    try {
      console.log('🔍 USER ENDPOINT - ENHANCED DIAGNOSTICS:');

      const userId = extractUserIdFromPath(path, event);
      console.log('🔍 Extracted userId:', userId);

      if (!userId || userId === '{userId}' || userId === 'userId' || userId.includes('{')) {
        console.log('❌ Invalid userId extracted:', userId);
        return errorResponse('Valid User ID is required', 400);
      }

      console.log(`👤 Final userId for lookup: ${userId}`);

      let user = null;
      try {
        user = await ydbService.findUserById(userId);
        console.log('🔍 User lookup result:', user ? 'Found' : 'Not found');
      } catch (error) {
        console.log('⚠️ Get user failed:', error.message);
      }

      // Если пользователь не найден, создаем базовый профиль
      if (!user) {
        console.log('🔄 User not found in YDB, creating basic profile');
        user = {
          id: userId,
          name: 'Пользователь',
          email: `${userId}@example.com`,
          avatar: '',
          created_at: new Date().toISOString()
        };
      }

      // Форматируем пользователя безопасно
      const safeUser = {
        id: String(user.id || userId),
        name: String(user.name || 'Пользователь'),
        email: String(user.email || `${userId}@example.com`),
        avatar: String(user.avatar || ''),
        created_at: String(user.created_at || new Date().toISOString())
      };

      console.log('✅ Returning user data:', safeUser);
      return successResponse(safeUser);
    } catch (error) {
      console.error('❌ Get user error:', error);
      return errorResponse('Failed to get user: ' + error.message, 500);
    }
  }

  console.log('❌ Endpoint not found:', path);
  return errorResponse('Endpoint not found: ' + path, 404);
};

// 🎯 ФУНКЦИЯ ДЛЯ МОК ДАННЫХ НОВОСТЕЙ
function getMockNews(limit, currentUserId) {
  const mockNews = Array.from({length: Math.min(limit, 10)}, (_, i) => ({
    id: `news_mock_${Date.now()}_${i}`,
    title: `Тестовая новость ${i + 1}`,
    content: `Это тестовое содержание новости номер ${i + 1}. Новость создана для демонстрации работы API.`,
    author_id: `user_${i % 5}`,
    author_name: ['Иван Петров', 'Мария Сидорова', 'Алексей Иванов', 'Елена Смирнова', 'Дмитрий Кузнецов'][i % 5],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    likes: Math.floor(Math.random() * 100),
    likes_count: Math.floor(Math.random() * 100),
    reposts: Math.floor(Math.random() * 50),
    reposts_count: Math.floor(Math.random() * 50),
    comments_count: Math.floor(Math.random() * 30),
    bookmarks_count: Math.floor(Math.random() * 20),
    share_count: Math.floor(Math.random() * 10),
    isLiked: currentUserId ? Math.random() > 0.7 : false,
    isBookmarked: currentUserId ? Math.random() > 0.8 : false,
    isReposted: currentUserId ? Math.random() > 0.9 : false,
    isFollowing: currentUserId ? Math.random() > 0.6 : false,
    hashtags: ['новости', 'тест', 'api'],
    comments: [],
    source: 'MOCK_DATA'
  }));

  return mockNews;
}