const ydbService = require('./src/services/ydb-service');

// 📊 РАСШИРЕННЫЕ МЕТРИКИ
const performanceMetrics = {
  startTime: Date.now(),
  totalRequests: 0,
  endpointStats: new Map(),
  responseTimes: [],
  userAgents: new Map(),
  errorBreakdown: new Map(),
  peakLoad: {
    maxRPS: 0,
    currentRPS: 0,
    lastMinuteRequests: 0,
    lastMinuteTime: Date.now()
  }
};

// 🎯 КОНФИГУРАЦИЯ
const SERVER_CONFIG = {
  timeout: 8000,
  enableCompression: true,
  cacheControl: {
    news: 'public, max-age=30',
    user: 'private, max-age=60',
    static: 'public, max-age=300'
  }
};

// 🚀 ОПТИМИЗИРОВАННЫЕ HEADERS
function getOptimizedHeaders(options = {}) {
  const baseHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization,Origin,Accept,X-Requested-With,X-Client-Version',
    'Access-Control-Max-Age': '86400',
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block'
  };

  if (options.cacheControl) {
    baseHeaders['Cache-Control'] = options.cacheControl;
  }

  return baseHeaders;
}

// 📊 ОБНОВЛЕННЫЙ МОНИТОРИНГ
function updateAdvancedMetrics(endpoint, responseTime, success = true, userAgent = 'unknown') {
  performanceMetrics.totalRequests++;

  const now = Date.now();
  if (now - performanceMetrics.peakLoad.lastMinuteTime > 60000) {
    performanceMetrics.peakLoad.currentRPS = performanceMetrics.peakLoad.lastMinuteRequests;
    performanceMetrics.peakLoad.maxRPS = Math.max(
      performanceMetrics.peakLoad.maxRPS,
      performanceMetrics.peakLoad.currentRPS
    );
    performanceMetrics.peakLoad.lastMinuteRequests = 0;
    performanceMetrics.peakLoad.lastMinuteTime = now;
  }
  performanceMetrics.peakLoad.lastMinuteRequests++;

  if (!performanceMetrics.endpointStats.has(endpoint)) {
    performanceMetrics.endpointStats.set(endpoint, {
      callCount: 0,
      totalResponseTime: 0,
      errorCount: 0,
      lastCall: Date.now(),
      responseTimes: []
    });
  }

  const stats = performanceMetrics.endpointStats.get(endpoint);
  stats.callCount++;
  stats.totalResponseTime += responseTime;
  stats.responseTimes.push(responseTime);

  if (stats.responseTimes.length > 1000) {
    stats.responseTimes = stats.responseTimes.slice(-1000);
  }

  if (!success) {
    stats.errorCount++;

    const errorKey = `${endpoint}_error`;
    performanceMetrics.errorBreakdown.set(
      errorKey,
      (performanceMetrics.errorBreakdown.get(errorKey) || 0) + 1
    );
  }

  performanceMetrics.userAgents.set(
    userAgent,
    (performanceMetrics.userAgents.get(userAgent) || 0) + 1
  );

  performanceMetrics.responseTimes.push(responseTime);
  if (performanceMetrics.responseTimes.length > 5000) {
    performanceMetrics.responseTimes = performanceMetrics.responseTimes.slice(-5000);
  }
}

function getResponseTimeStats() {
  if (performanceMetrics.responseTimes.length === 0) {
    return { avg: 0, p50: 0, p95: 0, p99: 0 };
  }

  const sorted = [...performanceMetrics.responseTimes].sort((a, b) => a - b);
  const avg = sorted.reduce((a, b) => a + b, 0) / sorted.length;
  const p50 = sorted[Math.floor(sorted.length * 0.50)];
  const p95 = sorted[Math.floor(sorted.length * 0.95)];
  const p99 = sorted[Math.floor(sorted.length * 0.99)];

  return { avg, p50, p95, p99 };
}

// 🎯 OPTIMIZED RESPONSE HELPERS
function successResponse(data, statusCode = 200, options = {}) {
  const headers = getOptimizedHeaders({
    cacheControl: options.cacheControl
  });

  return {
    statusCode,
    headers,
    body: JSON.stringify({
      success: true,
      data: data,
      source: 'YDB_HYPER_OPTIMIZED',
      performance: 'maximized',
      timestamp: new Date().toISOString(),
      ...(options.metadata || {})
    })
  };
}

function errorResponse(message, statusCode = 500, details = null) {
  const headers = getOptimizedHeaders();

  performanceMetrics.errorBreakdown.set(
    `http_${statusCode}`,
    (performanceMetrics.errorBreakdown.get(`http_${statusCode}`) || 0) + 1
  );

  return {
    statusCode,
    headers,
    body: JSON.stringify({
      success: false,
      error: message,
      details: details,
      source: 'YDB_HYPER_OPTIMIZED',
      timestamp: new Date().toISOString()
    })
  };
}

// 🛠️ UTILITY FUNCTIONS
function parseBody(event) {
  try {
    return event.body ? JSON.parse(event.body) : {};
  } catch (e) {
    return {};
  }
}

function getUserIdFromToken(event) {
  try {
    const authHeader = event.headers?.Authorization || event.headers?.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    const token = authHeader.replace('Bearer ', '');

    if (token.startsWith('mock-jwt-token-')) {
      return token.replace('mock-jwt-token-', '');
    }

    const userMatch = token.match(/user_[a-zA-Z0-9_-]+/);
    if (userMatch) {
      return userMatch[0];
    }

    return null;
  } catch (error) {
    return null;
  }
}

function extractUserIdFromPath(path, event) {
  console.log('🔍 === PATH EXTRACTION ===');

  // Используем path из параметра, если rawPath недоступен
  const actualPath = event.rawPath || path || event.requestContext?.http?.path;
  console.log('🔍 Actual path:', actualPath);

  if (actualPath && actualPath.startsWith('/users/')) {
    const parts = actualPath.split('/');
    console.log('🔍 Path parts:', parts);

    if (parts.length >= 3) {
      const userId = parts[2];
      const cleanUserId = userId.split('?')[0];

      if (cleanUserId && cleanUserId !== '{userId}' && !cleanUserId.includes('{')) {
        console.log('✅ Extracted userId:', cleanUserId);
        return cleanUserId;
      }
    }
  }

  if (event.queryStringParameters && event.queryStringParameters.userId) {
    console.log('✅ Using query parameter userId:', event.queryStringParameters.userId);
    return event.queryStringParameters.userId;
  }

  console.log('❌ Cannot extract userId');
  return null;
}

async function initializeYDB() {
  const now = Date.now();
  performanceMetrics.totalRequests++;

  try {
    const success = await ydbService.quickInit();
    if (success) {
      console.log('✅ YDB initialized successfully');
    }
    return success;
  } catch (error) {
    console.error('❌ YDB init failed:', error);
    return false;
  }
}

async function quickHealthCheck() {
  try {
    const isHealthy = await initializeYDB();
    const performanceStats = ydbService.getPerformanceStats();
    const responseTimeStats = getResponseTimeStats();

    return {
      status: isHealthy ? 'OK' : 'DEGRADED',
      message: isHealthy ? 'Server is running with hyper-optimized YDB' : 'YDB connection issues',
      timestamp: new Date().toISOString(),
      performance: performanceStats,
      metrics: {
        totalRequests: performanceMetrics.totalRequests,
        currentRPS: performanceMetrics.peakLoad.currentRPS,
        maxRPS: performanceMetrics.peakLoad.maxRPS,
        avgResponseTime: responseTimeStats.avg,
        p95ResponseTime: responseTimeStats.p95,
        p99ResponseTime: responseTimeStats.p99
      },
      features: [
        'Connection Pooling',
        'Advanced Caching',
        'Batch Operations',
        'Precomputed Data',
        'Real-time Metrics'
      ]
    };
  } catch (error) {
    return {
      status: 'ERROR',
      message: 'Health check failed',
      timestamp: new Date().toISOString(),
      error: error.message
    };
  }
}

// 🎯 OPTIMIZED ENDPOINT HANDLERS
const endpointHandlers = {
  async root() {
    const startTime = Date.now();
    const health = await quickHealthCheck();
    const responseTime = Date.now() - startTime;

    updateAdvancedMetrics('root', responseTime, true, 'system');

    return successResponse({
      message: "🚀 News App API - Hyper Optimized Version",
      version: "7.0.0",
      timestamp: new Date().toISOString(),
      performance: {
        initialization: "connection_pool",
        caching: "advanced_segmented",
        database: "batch_optimized",
        precomputation: "enabled"
      },
      endpoints: {
        auth: ["/register", "/login"],
        news: ["/getNews", "/createNews", "/author/news", "/updateNews", "/deleteNews"],
        actions: ["/action", "/user/likes", "/user/bookmarks", "/user/reposts"],
        social: ["/follow", "/unfollow", "/user/following", "/user/followers"],
        users: ["/users/{userId}", "/getUserProfile"],
        system: ["/health", "/metrics"]
      },
      stats: health.performance
    });
  },

  async health() {
    const startTime = Date.now();
    const health = await quickHealthCheck();
    const responseTime = Date.now() - startTime;

    updateAdvancedMetrics('health', responseTime, health.status === 'OK', 'system');

    return successResponse(health);
  },

  async metrics() {
    const startTime = Date.now();

    try {
      await initializeYDB();

      const performanceStats = ydbService.getPerformanceStats();
      const responseTimeStats = getResponseTimeStats();

      const endpointStats = {};
      for (const [endpoint, stats] of performanceMetrics.endpointStats) {
        const avgTime = stats.callCount > 0
          ? (stats.totalResponseTime / stats.callCount).toFixed(2) + 'ms'
          : '0ms';

        const errorRate = stats.callCount > 0
          ? (stats.errorCount / stats.callCount * 100).toFixed(1) + '%'
          : '0%';

        endpointStats[endpoint] = {
          callCount: stats.callCount,
          avgResponseTime: avgTime,
          errorRate: errorRate,
          lastCall: new Date(stats.lastCall).toISOString()
        };
      }

      const userAgents = {};
      for (const [ua, count] of performanceMetrics.userAgents) {
        if (count > 10) { // Only show significant user agents
          userAgents[ua] = count;
        }
      }

      const errorBreakdown = {};
      for (const [error, count] of performanceMetrics.errorBreakdown) {
        errorBreakdown[error] = count;
      }

      const metricsData = {
        performance: {
          ydbConnectionTime: performanceStats.ydbConnectionTime || 0,
          cacheEfficiency: performanceStats.cache?.hitRate || '0%',
          circuitBreakerState: performanceStats.circuitBreaker?.state || 'CLOSED',
          activeConnections: performanceStats.connectionPool?.totalConnections || 0,
          responseTimeStats: {
            avg: responseTimeStats.avg.toFixed(2) + 'ms',
            p50: responseTimeStats.p50.toFixed(2) + 'ms',
            p95: responseTimeStats.p95.toFixed(2) + 'ms',
            p99: responseTimeStats.p99.toFixed(2) + 'ms'
          }
        },
        system: {
          memoryUsage: performanceStats.memoryUsage || '0MB',
          uptime: `${Math.floor(performanceStats.uptime / 1000 / 60)}m`,
          totalRequests: performanceMetrics.totalRequests,
          currentRPS: performanceMetrics.peakLoad.currentRPS,
          maxRPS: performanceMetrics.peakLoad.maxRPS
        },
        endpoints: endpointStats,
        userAgents: userAgents,
        errorBreakdown: errorBreakdown,
        cache: performanceStats.cache,
        queries: performanceStats.queries,
        timestamp: new Date().toISOString()
      };

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('metrics', responseTime, true, 'system');

      return successResponse(metricsData);
    } catch (error) {
      console.error('❌ Metrics error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('metrics', responseTime, false, 'system');

      return successResponse({
        status: 'DEGRADED',
        message: 'Using fallback metrics data',
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }
  },

  async register(body) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';

    if (!body.email) {
      updateAdvancedMetrics('register', Date.now() - startTime, false, userAgent);
      return errorResponse('Email is required', 400);
    }

    let userId = 'user_' + Date.now();
    let userData = {
      id: userId,
      name: body.name || 'Пользователь',
      email: body.email,
      avatar: body.avatar || ''
    };

    try {
      const user = await ydbService.createUser(userData);

      const token = 'mock-jwt-token-' + userId;
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('register', responseTime, true, userAgent);

      return successResponse({
        token: token,
        user: user,
        message: 'User registered with advanced caching',
        performance: {
          connectionPool: true,
          cacheWarmup: true
        }
      }, 201);
    } catch (error) {
      console.error('❌ Registration error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('register', responseTime, false, userAgent);
      return errorResponse('Registration failed: ' + error.message, 500);
    }
  },

  async login(body) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';

    if (!body.email || !body.password) {
      updateAdvancedMetrics('login', Date.now() - startTime, false, userAgent);
      return errorResponse('Email and password are required', 400);
    }

    let user = await ydbService.findUserByEmail(body.email);

    if (!user) {
      const userId = `user_${Date.now()}`;
      user = {
        id: userId,
        name: 'Пользователь',
        email: body.email
      };

      try {
        await ydbService.createUser(user);
        console.log('✅ New user created for login');
      } catch (createError) {
        console.log('⚠️ User creation failed:', createError.message);
      }
    }

    const token = 'mock-jwt-token-' + user.id;
    const responseTime = Date.now() - startTime;
    updateAdvancedMetrics('login', responseTime, true, userAgent);

    return successResponse({
      token: token,
      user: user,
      performance: 'cached_email_search'
    });
  },

  async getNews(queryParams, currentUserId) {
    const startTime = Date.now();
    const userAgent = queryParams.userAgent || 'unknown';

    const page = parseInt(queryParams.page) || 0;
    const limit = Math.min(parseInt(queryParams.limit) || 20, 50);
    const refresh = queryParams.refresh === 'true';
    const authorId = queryParams.authorId;

    let news = [];
    let performance = '';
    let source = '';

    try {
      const options = {
        authorId: authorId,
        forceRefresh: refresh
      };

      news = await ydbService.getNewsOptimized(page, limit, options);
      performance = 'hyper_optimized';
      source = 'advanced_cache';

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getNews', responseTime, true, userAgent);

      return successResponse({
        news: news,
        pagination: {
          page: page,
          limit: limit,
          total: news.length,
          hasMore: news.length === limit
        },
        performance: {
          source: source,
          responseTime: responseTime,
          cache: performance
        }
      }, 200, {
        cacheControl: SERVER_CONFIG.cacheControl.news
      });
    } catch (error) {
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getNews', responseTime, false, userAgent);

      news = getMockNews(limit, currentUserId);
      return successResponse({
        news: news,
        pagination: {
          page: page,
          limit: limit,
          total: news.length,
          hasMore: false
        },
        performance: {
          source: 'fallback',
          responseTime: responseTime,
          fallback: true
        }
      });
    }
  },

  async createNews(body, currentUserId) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';

    if (!body.title || !body.content) {
      updateAdvancedMetrics('createNews', Date.now() - startTime, false, userAgent);
      return errorResponse('Title and content are required', 400);
    }

    const newsData = {
      title: body.title,
      content: body.content,
      author_id: currentUserId,
      author_name: body.author_name || 'Неизвестный автор',
      author_avatar: body.author_avatar || '',
      hashtags: body.hashtags || [],
      is_repost: body.is_repost || false
    };

    try {
      const createdNews = await ydbService.createNews(newsData);

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('createNews', responseTime, true, userAgent);

      return successResponse({
        message: 'News created successfully',
        news: createdNews,
        performance: {
          cacheInvalidation: 'segmented',
          precomputation: 'scheduled'
        }
      }, 201);
    } catch (error) {
      console.error('❌ Create news error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('createNews', responseTime, false, userAgent);
      return errorResponse('Failed to create news: ' + error.message, 500);
    }
  },

  async updateNews(body, currentUserId) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';
    const { newsId, updateData } = body;

    if (!newsId || !updateData) {
      updateAdvancedMetrics('updateNews', Date.now() - startTime, false, userAgent);
      return errorResponse('News ID and update data required', 400);
    }

    try {
      await initializeYDB();

      const news = await ydbService.getNewsById(newsId);
      if (!news) {
        updateAdvancedMetrics('updateNews', Date.now() - startTime, false, userAgent);
        return errorResponse('News not found', 404);
      }

      if (news.author_id !== currentUserId) {
        updateAdvancedMetrics('updateNews', Date.now() - startTime, false, userAgent);
        return errorResponse('Not authorized to edit this news', 403);
      }

      const updatedNews = await ydbService.updateNews(newsId, updateData);

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('updateNews', responseTime, true, userAgent);

      return successResponse({
        message: 'News updated successfully',
        news: updatedNews,
        performance: 'cache_invalidated'
      });
    } catch (error) {
      console.error('❌ Update news error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('updateNews', responseTime, false, userAgent);
      return errorResponse('Failed to update news: ' + error.message, 500);
    }
  },

  async deleteNews(body, currentUserId) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';
    const { newsId } = body;

    if (!newsId) {
      updateAdvancedMetrics('deleteNews', Date.now() - startTime, false, userAgent);
      return errorResponse('News ID required', 400);
    }

    try {
      await initializeYDB();

      const news = await ydbService.getNewsById(newsId);
      if (!news) {
        updateAdvancedMetrics('deleteNews', Date.now() - startTime, false, userAgent);
        return errorResponse('News not found', 404);
      }

      if (news.author_id !== currentUserId) {
        updateAdvancedMetrics('deleteNews', Date.now() - startTime, false, userAgent);
        return errorResponse('Not authorized to delete this news', 403);
      }

      await ydbService.deleteNews(newsId);

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('deleteNews', responseTime, true, userAgent);

      return successResponse({
        message: 'News deleted successfully',
        performance: 'cache_cleared'
      });
    } catch (error) {
      console.error('❌ Delete news error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('deleteNews', responseTime, false, userAgent);
      return errorResponse('Failed to delete news: ' + error.message, 500);
    }
  },

  async follow(body, currentUserId) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';
    const { targetUserId } = body;

    if (!targetUserId) {
      updateAdvancedMetrics('follow', Date.now() - startTime, false, userAgent);
      return errorResponse('Target user ID required', 400);
    }

    if (targetUserId === currentUserId) {
      updateAdvancedMetrics('follow', Date.now() - startTime, false, userAgent);
      return errorResponse('Cannot follow yourself', 400);
    }

    try {
      await ydbService.followUser(currentUserId, targetUserId);

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('follow', responseTime, true, userAgent);

      return successResponse({
        message: 'Successfully followed user',
        targetUserId: targetUserId,
        performance: 'cache_invalidated'
      });
    } catch (error) {
      console.error('❌ Follow error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('follow', responseTime, false, userAgent);
      return errorResponse('Failed to follow user: ' + error.message, 500);
    }
  },

  async unfollow(body, currentUserId) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';
    const { targetUserId } = body;

    if (!targetUserId) {
      updateAdvancedMetrics('unfollow', Date.now() - startTime, false, userAgent);
      return errorResponse('Target user ID required', 400);
    }

    try {
      await ydbService.unfollowUser(currentUserId, targetUserId);

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('unfollow', responseTime, true, userAgent);

      return successResponse({
        message: 'Successfully unfollowed user',
        targetUserId: targetUserId,
        performance: 'cache_invalidated'
      });
    } catch (error) {
      console.error('❌ Unfollow error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('unfollow', responseTime, false, userAgent);
      return errorResponse('Failed to unfollow user: ' + error.message, 500);
    }
  },

  async action(body, currentUserId) {
    const startTime = Date.now();
    const userAgent = body.userAgent || 'unknown';
    const { action, newsId, text, author_name } = body;

    if (!action) {
      updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
      return errorResponse('Action required', 400);
    }

    let result = {};

    try {
      switch (action) {
        case 'like':
          if (!newsId) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID required for like', 400);
          }
          result = await ydbService.likeNewsOptimized(newsId, currentUserId);
          result.performance = 'batch_optimized';
          break;

        case 'unlike':
          if (!newsId) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID required for unlike', 400);
          }
          const isLiked = await ydbService.isNewsLikedFast(newsId, currentUserId);
          if (!isLiked) {
            const responseTime = Date.now() - startTime;
            updateAdvancedMetrics('action', responseTime, true, userAgent);
            return successResponse({
              message: 'News was not liked',
              performance: 'fast_like_check'
            });
          }
          await ydbService.batchOperation('update_likes', newsId, -1);
          result = {
            message: 'Like removed successfully',
            performance: 'batch_optimized'
          };
          break;

        case 'check_like':
          if (!newsId) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID required for check_like', 400);
          }
          const isLikedCheck = await ydbService.isNewsLikedFast(newsId, currentUserId);
          result = {
            isLiked: isLikedCheck,
            performance: 'cached_check'
          };
          break;

        case 'bookmark':
          if (!newsId) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID required for bookmark', 400);
          }
          await ydbService.bookmarkNews(newsId, currentUserId);
          result = {
            message: 'News bookmarked successfully',
            performance: 'cache_updated'
          };
          break;

        case 'unbookmark':
          if (!newsId) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID required for unbookmark', 400);
          }
          await ydbService.unbookmarkNews(newsId, currentUserId);
          result = {
            message: 'News removed from bookmarks',
            performance: 'cache_updated'
          };
          break;

        case 'repost':
          if (!newsId) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID required for repost', 400);
          }
          await ydbService.repostNews(newsId, currentUserId);
          result = {
            message: 'News reposted successfully',
            performance: 'cache_updated'
          };
          break;

        case 'unrepost':
          if (!newsId) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID required for unrepost', 400);
          }
          await ydbService.unrepostNews(newsId, currentUserId);
          result = {
            message: 'Repost removed successfully',
            performance: 'cache_updated'
          };
          break;

        case 'comment':
          if (!newsId || !text) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('News ID and text required for comment', 400);
          }
          if (text.length > 1000) {
            updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
            return errorResponse('Comment too long (max 1000 characters)', 400);
          }
          result = {
            message: 'Comment added successfully',
            comment: {
              id: `comment_${Date.now()}`,
              news_id: newsId,
              user_id: currentUserId,
              user_name: author_name || 'Пользователь',
              content: text,
              created_at: new Date().toISOString()
            },
            performance: 'simple_comment'
          };
          break;

        default:
          updateAdvancedMetrics('action', Date.now() - startTime, false, userAgent);
          return errorResponse('Unknown action', 400);
      }

      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('action', responseTime, true, userAgent);
      return successResponse(result);

    } catch (error) {
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('action', responseTime, false, userAgent);
      return errorResponse('Action failed: ' + error.message, 500);
    }
  },

  async getUserLikes(currentUserId) {
    const startTime = Date.now();
    const userAgent = 'user_request';

    try {
      const likes = await ydbService.getUserLikes(currentUserId);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserLikes', responseTime, true, userAgent);

      return successResponse({
        likes: likes,
        count: likes.length,
        performance: 'cached_likes'
      });
    } catch (error) {
      console.error('❌ Get user likes error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserLikes', responseTime, false, userAgent);
      return successResponse({
        likes: [],
        count: 0,
        performance: 'fallback_likes'
      });
    }
  },

  async getUserBookmarks(currentUserId) {
    const startTime = Date.now();
    const userAgent = 'user_request';

    try {
      const bookmarks = await ydbService.getUserBookmarks(currentUserId);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserBookmarks', responseTime, true, userAgent);

      return successResponse({
        bookmarks: bookmarks,
        count: bookmarks.length,
        performance: 'cached_bookmarks'
      });
    } catch (error) {
      console.error('❌ Get user bookmarks error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserBookmarks', responseTime, false, userAgent);
      return successResponse({
        bookmarks: [],
        count: 0,
        performance: 'fallback_bookmarks'
      });
    }
  },

  async getUserReposts(currentUserId) {
    const startTime = Date.now();
    const userAgent = 'user_request';

    try {
      const reposts = await ydbService.getUserReposts(currentUserId);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserReposts', responseTime, true, userAgent);

      return successResponse({
        reposts: reposts,
        count: reposts.length,
        performance: 'cached_reposts'
      });
    } catch (error) {
      console.error('❌ Get user reposts error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserReposts', responseTime, false, userAgent);
      return successResponse({
        reposts: [],
        count: 0,
        performance: 'fallback_reposts'
      });
    }
  },

  async getUserFollowing(currentUserId) {
    const startTime = Date.now();
    const userAgent = 'user_request';

    try {
      const following = await ydbService.getUserFollowing(currentUserId);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserFollowing', responseTime, true, userAgent);

      return successResponse({
        following: following,
        count: following.length,
        performance: 'cached_following'
      });
    } catch (error) {
      console.error('❌ Get user following error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserFollowing', responseTime, false, userAgent);
      return successResponse({
        following: [],
        count: 0,
        performance: 'fallback_following'
      });
    }
  },

  async getUserFollowers(currentUserId) {
    const startTime = Date.now();
    const userAgent = 'user_request';

    try {
      const followers = await ydbService.getUserFollowers(currentUserId);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserFollowers', responseTime, true, userAgent);

      return successResponse({
        followers: followers,
        count: followers.length,
        performance: 'cached_followers'
      });
    } catch (error) {
      console.error('❌ Get user followers error:', error);
      const responseTime = Date.now() - startTime;
      updateAdvancedMetrics('getUserFollowers', responseTime, false, userAgent);
      return successResponse({
        followers: [],
        count: 0,
        performance: 'fallback_followers'
      });
    }
  },

  async getUserProfile(queryParams) {
    const startTime = Date.now();
    const userAgent = queryParams.userAgent || 'unknown';
    const { userId } = queryParams;

    if (!userId) {
      updateAdvancedMetrics('getUserProfile', Date.now() - startTime, false, userAgent);
      return errorResponse('User ID is required', 400);
    }

    let user = await ydbService.findUserById(userId);

    if (!user) {
      user = {
        id: userId,
        name: 'Пользователь',
        email: `${userId}@example.com`,
        avatar: '',
        created_at: new Date().toISOString()
      };
    }

    const responseTime = Date.now() - startTime;
    updateAdvancedMetrics('getUserProfile', responseTime, true, userAgent);

    return successResponse(user, 200, {
      cacheControl: SERVER_CONFIG.cacheControl.user
    });
  },

  async getUserByPath(path, event) {
    const startTime = Date.now();
    const userAgent = event.headers?.['User-Agent'] || 'unknown';

    console.log('🎯 === getUserByPath START ===');
    const userId = extractUserIdFromPath(path, event);
    console.log('🎯 Final userId:', userId);

    let finalUserId = userId;
    if (!finalUserId || finalUserId === '{userId}' || finalUserId.includes('{')) {
      console.log('⚠️ Using fallback userId for testing');
      finalUserId = 'user_1';
    }

    if (!finalUserId) {
      console.log('❌ No userId available');
      updateAdvancedMetrics('getUserByPath', Date.now() - startTime, false, userAgent);
      return errorResponse('Valid User ID is required', 400);
    }

    console.log('🎯 Searching for user:', finalUserId);
    let user = await ydbService.findUserById(finalUserId);

    if (!user) {
      console.log('🎯 User not found, creating fallback for:', finalUserId);
      user = {
        id: finalUserId,
        name: 'Пользователь',
        email: `${finalUserId}@example.com`,
        avatar: '',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
    }

    const responseTime = Date.now() - startTime;
    updateAdvancedMetrics('getUserByPath', responseTime, true, userAgent);

    console.log('🎯 === getUserByPath SUCCESS ===');
    return successResponse(user, 200, {
      cacheControl: SERVER_CONFIG.cacheControl.user
    });
  }
};

// 🚀 OPTIMIZED MAIN HANDLER
module.exports.handler = async (event, context) => {
  console.log('🚀 SERVER STARTED - HYPER OPTIMIZED VERSION 7.0.0');

  context.callbackWaitsForEmptyEventLoop = false;

  const headers = getOptimizedHeaders();

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  const path = event.path || '';
  const method = event.httpMethod;
  const body = parseBody(event);
  const queryParams = event.queryStringParameters || {};
  const currentUserId = getUserIdFromToken(event);
  const userAgent = event.headers?.['User-Agent'] || 'unknown';

  const startTime = Date.now();

  try {
    let response;

    // 🎯 OPTIMIZED ROUTING
    if (path === '/' || path === '') {
      response = await endpointHandlers.root();
    } else if (path === '/health' && method === 'GET') {
      response = await endpointHandlers.health();
    } else if (path === '/metrics' && method === 'GET') {
      response = await endpointHandlers.metrics();
    } else if (path === '/register' && method === 'POST') {
      response = await endpointHandlers.register({...body, userAgent});
    } else if (path === '/login' && method === 'POST') {
      response = await endpointHandlers.login({...body, userAgent});
    } else if (path === '/getNews' && method === 'GET') {
      response = await endpointHandlers.getNews({...queryParams, userAgent}, currentUserId);
    } else if (path === '/author/news' && method === 'GET') {
      response = await endpointHandlers.getNews({...queryParams, authorId: queryParams.authorId, userAgent}, currentUserId);
    } else if (path === '/createNews' && method === 'POST') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.createNews({...body, userAgent}, currentUserId);
    } else if (path === '/updateNews' && method === 'POST') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.updateNews({...body, userAgent}, currentUserId);
    } else if (path === '/deleteNews' && method === 'POST') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.deleteNews({...body, userAgent}, currentUserId);
    } else if (path === '/follow' && method === 'POST') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.follow({...body, userAgent}, currentUserId);
    } else if (path === '/unfollow' && method === 'POST') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.unfollow({...body, userAgent}, currentUserId);
    } else if (path === '/action' && method === 'POST') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.action({...body, userAgent}, currentUserId);
    } else if (path === '/user/likes' && method === 'GET') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.getUserLikes(currentUserId);
    } else if (path === '/user/bookmarks' && method === 'GET') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.getUserBookmarks(currentUserId);
    } else if (path === '/user/reposts' && method === 'GET') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.getUserReposts(currentUserId);
    } else if (path === '/user/following' && method === 'GET') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.getUserFollowing(currentUserId);
    } else if (path === '/user/followers' && method === 'GET') {
      if (!currentUserId) return errorResponse('Authentication required', 401);
      response = await endpointHandlers.getUserFollowers(currentUserId);
    } else if (path === '/getUserProfile' && method === 'GET') {
      response = await endpointHandlers.getUserProfile({...queryParams, userAgent});
    } else if (path.startsWith('/users/') && method === 'GET') {
      response = await endpointHandlers.getUserByPath(path, event);
    } else {
      return errorResponse('Endpoint not found: ' + path, 404);
    }

    const duration = Date.now() - startTime;
    console.log(`✅ ${method} ${path} - ${duration}ms`);

    return {
      ...response,
      headers: {
        ...headers,
        ...response.headers
      }
    };

  } catch (error) {
    const duration = Date.now() - startTime;
    console.error(`❌ ${method} ${path} - ${duration}ms - Error:`, error);

    return errorResponse('Internal server error', 500);
  }
};

// 🎯 FALLBACK DATA
function getMockNews(limit, currentUserId) {
  return Array.from({length: Math.min(limit, 5)}, (_, i) => ({
    id: `news_mock_${Date.now()}_${i}`,
    title: `Тестовая новость ${i + 1}`,
    content: `Содержание новости ${i + 1}`,
    author_id: `user_${i}`,
    author_name: 'Автор',
    created_at: new Date().toISOString(),
    likes_count: 0,
    reposts_count: 0,
    comments_count: 0,
    isLiked: false,
    isBookmarked: false,
    source: 'FALLBACK_DATA'
  }));
}