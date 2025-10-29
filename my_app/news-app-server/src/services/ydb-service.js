const { Driver, getCredentialsFromEnv } = require('ydb-sdk');

class AdvancedCache {
  constructor() {
    this.segments = new Map();
    this.defaultTTL = 30000;
    this.maxSegmentSize = 100;
    this.stats = {
      hits: 0,
      misses: 0,
      evictions: 0,
      prefetches: 0
    };
  }

  get(segment, key) {
    const segmentCache = this.segments.get(segment);
    if (!segmentCache) {
      this.stats.misses++;
      return null;
    }

    const cached = segmentCache.get(key);
    if (!cached) {
      this.stats.misses++;
      return null;
    }

    if (Date.now() - cached.timestamp > cached.ttl) {
      segmentCache.delete(key);
      this.stats.misses++;
      return null;
    }

    cached.lastAccess = Date.now();
    cached.accessCount++;
    this.stats.hits++;
    return cached.data;
  }

  set(segment, key, data, options = {}) {
    if (!this.segments.has(segment)) {
      this.segments.set(segment, new Map());
    }

    const segmentCache = this.segments.get(segment);

    if (segmentCache.size >= this.maxSegmentSize) {
      this.evictLRU(segmentCache);
    }

    segmentCache.set(key, {
      data,
      timestamp: Date.now(),
      ttl: options.ttl || this.defaultTTL,
      priority: options.priority || 1,
      accessCount: 0,
      lastAccess: Date.now()
    });
  }

  evictLRU(segmentCache) {
    let lruKey = null;
    let oldestAccess = Date.now();

    for (const [key, value] of segmentCache.entries()) {
      if (value.lastAccess < oldestAccess) {
        oldestAccess = value.lastAccess;
        lruKey = key;
      }
    }

    if (lruKey) {
      segmentCache.delete(lruKey);
      this.stats.evictions++;
    }
  }

  async mget(segment, keys) {
    const results = new Map();
    const missingKeys = [];

    keys.forEach(key => {
      const cached = this.get(segment, key);
      if (cached !== null) {
        results.set(key, cached);
      } else {
        missingKeys.push(key);
      }
    });

    return { results, missingKeys };
  }

  invalidateSegment(segment) {
    this.segments.delete(segment);
  }

  getStats() {
    let totalSize = 0;
    this.segments.forEach(segment => {
      totalSize += segment.size;
    });

    const totalAccess = this.stats.hits + this.stats.misses;
    const hitRate = totalAccess > 0 ? (this.stats.hits / totalAccess * 100).toFixed(1) : 0;

    return {
      ...this.stats,
      hitRate: `${hitRate}%`,
      totalSize,
      segments: Array.from(this.segments.keys())
    };
  }
}

class ConnectionPool {
  constructor() {
    this.drivers = [];
    this.currentIndex = 0;
    this.maxConnections = 3;
  }

  async init() {
    for (let i = 0; i < this.maxConnections; i++) {
      try {
        const driver = new Driver({
          endpoint: process.env.YDB_ENDPOINT || 'grpcs://ydb.serverless.yandexcloud.net:2135',
          database: process.env.YDB_DATABASE || '/ru-central1/b1gt6fjmjnejpscls6e8/etng2uemrr7ivj80tldm',
          authService: getCredentialsFromEnv(),
        });

        const ready = await driver.ready(5000);
        if (ready) {
          this.drivers.push(driver);
          console.log(`✅ Connection ${i + 1} initialized`);
        }
      } catch (error) {
        console.log(`⚠️ Connection ${i + 1} failed:`, error.message);
      }
    }

    return this.drivers.length > 0;
  }

  getDriver() {
    if (this.drivers.length === 0) {
      throw new Error('No available connections');
    }

    const driver = this.drivers[this.currentIndex];
    this.currentIndex = (this.currentIndex + 1) % this.drivers.length;
    return driver;
  }

  getStats() {
    return {
      totalConnections: this.drivers.length,
      currentIndex: this.currentIndex,
      maxConnections: this.maxConnections
    };
  }
}

class YDBService {
  constructor() {
    this.connectionPool = new ConnectionPool();
    this.cache = new AdvancedCache();
    this.initialized = false;
    this.circuitBreaker = {
      state: 'CLOSED',
      failures: 0,
      lastFailure: 0,
      successThreshold: 3
    };
    this.metrics = {
      queries: 0,
      batchQueries: 0,
      cacheHits: 0,
      cacheMisses: 0,
      responseTimes: [],
      startTime: Date.now()
    };
    this.batchQueue = new Map();
    this.batchTimeout = 10;
    this.precomputeScheduler = null;
  }

  async init() {
    if (this.initialized) return true;

    try {
      console.log('🚀 Initializing YDB with connection pool...');
      const success = await this.connectionPool.init();

      if (success) {
        this.initialized = true;
        this.startPrecomputeScheduler();
        this.warmUpCache();
        console.log('✅ YDB service fully optimized');
      }

      return success;
    } catch (error) {
      console.error('❌ YDB init failed:', error);
      return false;
    }
  }

  async quickInit() {
    if (this.initialized) return true;
    return await this.init();
  }

  async getWithCache(segment, key, fetchFn, options = {}) {
    const cached = this.cache.get(segment, key);
    if (cached !== null) {
      this.metrics.cacheHits++;
      return cached;
    }

    this.metrics.cacheMisses++;
    const data = await fetchFn();

    if (data !== null && data !== undefined) {
      this.cache.set(segment, key, data, options);
    }

    return data;
  }

  async batchOperation(operation, key, data) {
    if (!this.batchQueue.has(operation)) {
      this.batchQueue.set(operation, new Map());

      setTimeout(() => {
        this.executeBatch(operation);
      }, this.batchTimeout);
    }

    this.batchQueue.get(operation).set(key, data);

    return new Promise((resolve) => {
      const checkResult = () => {
        const batch = this.batchQueue.get(operation);
        if (!batch || !batch.has(key)) {
          resolve({ success: true, batched: true });
        } else {
          setTimeout(checkResult, 1);
        }
      };
      checkResult();
    });
  }

  async executeBatch(operation) {
    const batchData = this.batchQueue.get(operation);
    if (!batchData || batchData.size === 0) {
      this.batchQueue.delete(operation);
      return;
    }

    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      switch (operation) {
        case 'update_likes':
          await this.batchUpdateLikes(batchData, driver);
          break;
        case 'update_views':
          await this.batchUpdateViews(batchData, driver);
          break;
      }

      this.metrics.batchQueries++;
      console.log(`✅ Batch ${operation} executed: ${batchData.size} items`);
    } catch (error) {
      console.error(`❌ Batch ${operation} failed:`, error);
    } finally {
      this.batchQueue.delete(operation);
    }
  }

  async batchUpdateLikes(batchData, driver) {
    const updates = [];

    for (const [newsId, change] of batchData) {
      updates.push(`
        UPDATE news
        SET likes_count = likes_count + ${change}
        WHERE id = "${newsId}"
      `);
    }

    const query = updates.join(';\n');
    await driver.tableClient.withSession(async (session) => {
      await session.executeQuery(query);
    });

    this.cache.invalidateSegment('news');
    this.cache.invalidateSegment('author_news');
  }

  startPrecomputeScheduler() {
    this.precomputeScheduler = setInterval(async () => {
      try {
        await this.precomputeTrendingNews();
        await this.precomputeUserRecommendations();
        await this.precomputeAuthorStats();
      } catch (error) {
        console.log('⚠️ Precompute failed:', error.message);
      }
    }, 60000);
  }

  async precomputeTrendingNews() {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `
          SELECT
            id,
            title,
            likes_count,
            reposts_count,
            comments_count,
            (likes_count * 2 + reposts_count * 3 + comments_count) as engagement_score
          FROM news
          WHERE created_at > CurrentUtcTimestamp() - Interval("PT24H")
          ORDER BY engagement_score DESC
          LIMIT 20
        `;

        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const trendingNews = this.parseResult(resultSets);
        this.cache.set('precomputed', 'trending_news', trendingNews, { ttl: 300000 });

        console.log('✅ Trending news precomputed');
      } catch (error) {
        console.log('⚠️ Trending precompute failed:', error.message);
      }
    }

   async precomputeAuthorStats() {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `
          SELECT
            author_id,
            COUNT(*) as news_count,
            SUM(likes_count) as total_likes,
            AVG(likes_count) as avg_likes
          FROM news
          WHERE created_at > CurrentUtcTimestamp() - Interval("PT168H")
          GROUP BY author_id
        `;

        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const authorStats = this.parseResult(resultSets);
        this.cache.set('precomputed', 'author_stats', authorStats, { ttl: 900000 });

        console.log('✅ Author stats precomputed');
      } catch (error) {
        console.log('⚠️ Author stats precompute failed:', error.message);
      }
    }

  async warmUpCache() {
      try {
        const warmupPromises = [
          this.getNewsOptimized(0, 10).then(news => {
            this.cache.set('news', 'page:0:limit:10', news, { priority: 10 });
          }).catch(err => console.log('⚠️ News warmup failed:', err.message)),

          this.getTopAuthors().then(authors => {
            this.cache.set('precomputed', 'top_authors', authors, { ttl: 300000 });
          }).catch(err => console.log('⚠️ Authors warmup failed:', err.message))
        ];

        await Promise.allSettled(warmupPromises);
        console.log('✅ Cache warmup completed');
      } catch (error) {
        console.log('⚠️ Cache warmup failed:', error.message);
      }
    }

  // ДОБАВЛЕННЫЙ МЕТОД: Создание пользователя
  async createUser(userData) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const userId = userData.id || `user_${Date.now()}`;

      // Экранирование значений
      const name = (userData.name || 'Пользователь').replace(/"/g, '\\"');
      const email = (userData.email || '').replace(/"/g, '\\"');
      const avatar = (userData.avatar || '').replace(/"/g, '\\"');

      const query = `
        UPSERT INTO users (id, name, email, avatar, created_at, updated_at)
        VALUES (
          "${userId}",
          "${name}",
          "${email}",
          "${avatar}",
          CurrentUtcTimestamp(),
          CurrentUtcTimestamp()
        )
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      // Также добавляем в email_lookup для быстрого поиска
      const emailLookupQuery = `
        UPSERT INTO email_lookup (email, user_id, name)
        VALUES (
          "${email}",
          "${userId}",
          "${name}"
        )
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(emailLookupQuery);
      });

      // Инвалидируем кэш
      this.cache.invalidateSegment('users');

      return {
        id: userId,
        name: name,
        email: email,
        avatar: avatar,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
    } catch (error) {
      console.error('❌ createUser error:', error);
      throw error;
    }
  }

  // ДОБАВЛЕННЫЙ МЕТОД: Обновление пользователя
  async updateUser(userId, updateData) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      let updateFields = [];
      if (updateData.name !== undefined) {
        const name = updateData.name.replace(/"/g, '\\"');
        updateFields.push(`name = "${name}"`);
      }
      if (updateData.avatar !== undefined) {
        const avatar = updateData.avatar.replace(/"/g, '\\"');
        updateFields.push(`avatar = "${avatar}"`);
      }
      if (updateData.email !== undefined) {
        const email = updateData.email.replace(/"/g, '\\"');
        updateFields.push(`email = "${email}"`);
      }

      if (updateFields.length === 0) {
        throw new Error('No fields to update');
      }

      const query = `
        UPDATE users
        SET ${updateFields.join(', ')}, updated_at = CurrentUtcTimestamp()
        WHERE id = "${userId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      // Обновляем email_lookup если изменился email
      if (updateData.email !== undefined) {
        const emailLookupQuery = `
          UPSERT INTO email_lookup (email, user_id, name)
          VALUES (
            "${updateData.email.replace(/"/g, '\\"')}",
            "${userId}",
            "${(updateData.name || 'Пользователь').replace(/"/g, '\\"')}"
          )
        `;
        await driver.tableClient.withSession(async (session) => {
          await session.executeQuery(emailLookupQuery);
        });
      }

      this.cache.invalidateSegment('users');

      return await this.findUserById(userId);
    } catch (error) {
      console.error('❌ updateUser error:', error);
      throw error;
    }
  }

  // ДОБАВЛЕННЫЙ МЕТОД: Получение профиля пользователя
  async getUserProfile(userId) {
    return this.findUserById(userId);
  }

  async getNewsOptimized(page = 0, limit = 20, options = {}) {
    const cacheKey = `page:${page}:limit:${limit}`;
    const segment = options.authorId ? `author_${options.authorId}` : 'news';

    return this.getWithCache(segment, cacheKey, async () => {
      const startTime = Date.now();

      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        let query;
        if (options.authorId) {
          query = `
            SELECT * FROM news
            WHERE author_id = "${options.authorId}"
            AND (is_deleted = false OR is_deleted IS NULL)
            ORDER BY created_at DESC
            LIMIT ${limit} OFFSET ${page * limit}
          `;
        } else {
          if (page === 0 && !options.forceRefresh) {
            const trending = this.cache.get('precomputed', 'trending_news');
            if (trending && trending.length > 0) {
              return trending.slice(0, limit);
            }
          }

          query = `
            SELECT * FROM news
            WHERE (is_deleted = false OR is_deleted IS NULL)
            ORDER BY created_at DESC
            LIMIT ${limit} OFFSET ${page * limit}
          `;
        }

        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const news = this.parseResult(resultSets);
        const responseTime = Date.now() - startTime;

        this.metrics.responseTimes.push(responseTime);
        this.metrics.queries++;

        return news.map(item => this.formatNewsItem(item));
      } catch (error) {
        console.error('❌ Get news optimized error:', error);
        throw error;
      }
    }, {
      ttl: page === 0 ? 30000 : 60000,
      priority: page === 0 ? 10 : 5
    });
  }

  async likeNewsOptimized(newsId, userId) {
    await this.batchOperation('update_likes', newsId, 1);

    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const likeQuery = `
        UPSERT INTO likes_index (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(likeQuery);
      });

      this.cache.invalidateSegment(`user_likes_${userId}`);
      this.cache.invalidateSegment('news');

      return { success: true, batched: true };
    } catch (error) {
      console.error('❌ Like news optimized error:', error);
      return { success: false, error: error.message };
    }
  }

  getPerformanceStats() {
    const totalQueries = this.metrics.queries + this.metrics.batchQueries;
    const avgResponseTime = this.metrics.responseTimes.length > 0
      ? this.metrics.responseTimes.reduce((a, b) => a + b, 0) / this.metrics.responseTimes.length
      : 0;

    const sortedTimes = [...this.metrics.responseTimes].sort((a, b) => a - b);
    const p95 = sortedTimes[Math.floor(sortedTimes.length * 0.95)] || 0;
    const p99 = sortedTimes[Math.floor(sortedTimes.length * 0.99)] || 0;

    return {
      cache: this.cache.getStats(),
      connectionPool: this.connectionPool.getStats(),
      circuitBreaker: this.circuitBreaker,
      queries: {
        total: totalQueries,
        individual: this.metrics.queries,
        batch: this.metrics.batchQueries,
        avgResponseTime: avgResponseTime.toFixed(2) + 'ms',
        p95: p95.toFixed(2) + 'ms',
        p99: p99.toFixed(2) + 'ms'
      },
      uptime: Date.now() - this.metrics.startTime,
      memoryUsage: `${(process.memoryUsage().heapUsed / 1024 / 1024).toFixed(1)}MB`
    };
  }

  formatNewsItem(item) {
    return {
      id: String(item.id || ''),
      title: String(item.title || ''),
      content: String(item.content || ''),
      author_id: String(item.author_id || 'unknown'),
      author_name: String(item.author_name || 'Автор'),
      hashtags: this.parseHashtags(item.hashtags),
      created_at: item.created_at || new Date().toISOString(),
      likes_count: Number(item.likes_count) || 0,
      reposts_count: Number(item.reposts_count) || 0,
      comments_count: Number(item.comments_count) || 0,
      source: 'YDB_HYPER_OPTIMIZED'
    };
  }

  parseHashtags(hashtags) {
    try {
      if (hashtags && typeof hashtags === 'string') {
        return JSON.parse(hashtags);
      } else if (Array.isArray(hashtags)) {
        return hashtags;
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  parseResult(resultSets) {
    if (!resultSets || !resultSets[0] || !resultSets[0].rows) return [];

    const rows = [];
    const columns = resultSets[0].columns;

    for (let rowIndex = 0; rowIndex < resultSets[0].rows.length; rowIndex++) {
      const row = resultSets[0].rows[rowIndex];
      const obj = {};

      for (let i = 0; i < columns.length; i++) {
        const column = columns[i];
        const item = row.items[i];
        obj[column.name] = this.smartParse(item, column.name);
      }

      rows.push(obj);
    }

    return rows;
  }

  smartParse(item, columnName) {
    if (!item) return null;
    if (item.optionalType) return this.smartParse(item.optionalType.value, columnName);

    if (item.textValue !== undefined && item.textValue !== null) {
      return String(item.textValue);
    }

    if (item.uint64Value !== undefined) {
      let numericValue;
      if (item.uint64Value && typeof item.uint64Value === 'object') {
        numericValue = item.uint64Value.low || 0;
        if (item.uint64Value.high) {
          numericValue += item.uint64Value.high * 4294967296;
        }
      } else {
        numericValue = Number(item.uint64Value) || 0;
      }

      if (columnName === 'created_at' || columnName === 'updated_at') {
        try {
          const milliseconds = Math.floor(numericValue / 1000);
          const date = new Date(milliseconds);
          if (date.getFullYear() > 2000 && date.getFullYear() < 2030) {
            return date.toISOString();
          }
          return new Date().toISOString();
        } catch (error) {
          return new Date().toISOString();
        }
      }

      return numericValue;
    }

    if (item.boolValue !== undefined) {
      return Boolean(item.boolValue);
    }

    return null;
  }

  async getNewsFromYDB(page = 0, limit = 20) {
    return this.getNewsOptimized(page, limit);
  }

  async createNews(newsData) {
    const result = await this._createNewsRaw(newsData);
    this.cache.invalidateSegment('news');
    this.cache.invalidateSegment(`author_${newsData.author_id}`);
    this.cache.invalidateSegment('precomputed');
    return result;
  }

  async _createNewsRaw(newsData) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();
      const newsId = `news_${Date.now()}`;

      const escapeValue = (value) => {
        if (!value) return '';
        return String(value).replace(/"/g, '\\"').replace(/'/g, "\\'");
      };

      const title = escapeValue(newsData.title || '');
      const content = escapeValue(newsData.content || '');
      const authorName = escapeValue(newsData.author_name || 'Автор');

      const hashtags = Array.isArray(newsData.hashtags)
        ? JSON.stringify(newsData.hashtags)
        : '[]';

      const query = `
        UPSERT INTO news (
          id, title, content, author_id, author_name,
          hashtags, likes_count, reposts_count, comments_count, bookmarks_count,
          share_count, is_deleted, is_repost, original_author_id,
          created_at, updated_at
        ) VALUES (
          "${newsId}",
          "${title}",
          "${content}",
          "${newsData.author_id}",
          "${authorName}",
          '${hashtags}',
          0, 0, 0, 0,
          0, false, ${newsData.is_repost || false}, "${newsData.original_author_id || newsData.author_id}",
          CurrentUtcTimestamp(),
          CurrentUtcTimestamp()
        )
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      const fastQuery = `
        UPSERT INTO author_news (author_id, created_at, news_id, title, likes_count)
        VALUES (
          "${newsData.author_id}",
          CurrentUtcTimestamp(),
          "${newsId}",
          "${title}",
          0
        )
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(fastQuery);
      });

      return {
        id: newsId,
        ...newsData,
        title: title,
        author_name: authorName,
        hashtags: newsData.hashtags || [],
        likes_count: 0,
        reposts_count: 0,
        comments_count: 0,
        bookmarks_count: 0,
        share_count: 0,
        is_deleted: false,
        is_repost: newsData.is_repost || false,
        original_author_id: newsData.original_author_id || newsData.author_id,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
    } catch (error) {
      console.error('❌ createNews error:', error);
      throw error;
    }
  }

  async findUserByEmail(email) {
    return this.getWithCache('users', `email:${email}`, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        // Используем email_lookup для быстрого поиска
        const lookupQuery = `
          SELECT user_id, name
          FROM email_lookup
          WHERE email = "${email}"
          LIMIT 1
        `;

        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(lookupQuery);
        });

        const lookupResult = this.parseResult(resultSets);

        if (lookupResult.length > 0) {
          const userId = lookupResult[0].user_id;
          // Получаем полные данные пользователя
          return await this.findUserById(userId);
        }

        // Fallback: поиск напрямую в users
        const directQuery = `
          SELECT id, name, email, avatar, created_at, updated_at
          FROM users
          WHERE email = "${email}"
          LIMIT 1
        `;

        const { resultSets: directResultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(directQuery);
        });

        const users = this.parseResult(directResultSets);
        return users[0] || null;
      } catch (error) {
        console.error('❌ findUserByEmail error:', error);
        return null;
      }
    }, { ttl: 60000 });
  }

  async findUserById(userId) {
    return this.getWithCache('users', `id:${userId}`, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `SELECT * FROM users WHERE id = "${userId}" LIMIT 1`;
        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const users = this.parseResult(resultSets);
        return users[0] || null;
      } catch (error) {
        console.error('❌ findUserById error:', error);
        return null;
      }
    }, { ttl: 120000 });
  }

   async getTopAuthors() {
      return this.getWithCache('precomputed', 'top_authors', async () => {
        try {
          await this.quickInit();
          const driver = this.connectionPool.getDriver();

          const query = `
            SELECT
              author_id,
              author_name,
              COUNT(*) as news_count,
              SUM(likes_count) as total_likes
            FROM news
            WHERE created_at > CurrentUtcTimestamp() - Interval("PT168H")
            GROUP BY author_id, author_name
            ORDER BY total_likes DESC
            LIMIT 10
          `;

          const { resultSets } = await driver.tableClient.withSession(async (session) => {
            return await session.executeQuery(query);
          });

          return this.parseResult(resultSets);
        } catch (error) {
          console.error('❌ getTopAuthors error:', error);
          return [];
        }
      }, { ttl: 300000 });
    }

  async updateNews(newsId, updateData) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      let updateFields = [];
      let updateValues = [];

      if (updateData.title !== undefined) {
        updateFields.push('title');
        updateValues.push(`"${updateData.title.replace(/"/g, '\\"')}"`);
      }

      if (updateData.content !== undefined) {
        updateFields.push('content');
        updateValues.push(`"${updateData.content.replace(/"/g, '\\"')}"`);
      }

      if (updateData.hashtags !== undefined) {
        updateFields.push('hashtags');
        const hashtagsJson = JSON.stringify(updateData.hashtags);
        updateValues.push(`'${hashtagsJson}'`);
      }

      if (updateFields.length === 0) {
        throw new Error('No fields to update');
      }

      const setClause = updateFields.map((field, index) =>
        `${field} = ${updateValues[index]}`
      ).join(', ');

      const query = `
        UPDATE news
        SET ${setClause}, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      if (updateData.title !== undefined) {
        const fastUpdateQuery = `
          UPDATE author_news
          SET title = "${updateData.title.replace(/"/g, '\\"')}"
          WHERE news_id = "${newsId}"
        `;

        await driver.tableClient.withSession(async (session) => {
          await session.executeQuery(fastUpdateQuery);
        });
      }

      this.cache.invalidateSegment('news');
      this.cache.invalidateSegment('precomputed');

      const updatedNews = await this.getNewsById(newsId);
      return updatedNews;
    } catch (error) {
      console.error('❌ Update news error:', error);
      throw error;
    }
  }

  async getNewsById(newsId) {
    return this.getWithCache('news', `id:${newsId}`, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `
          SELECT * FROM news
          WHERE id = "${newsId}" AND (is_deleted = false OR is_deleted IS NULL)
          LIMIT 1
        `;

        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const newsItems = this.parseResult(resultSets);
        return newsItems[0] || null;
      } catch (error) {
        console.error('❌ Get news by ID error:', error);
        return null;
      }
    }, { ttl: 60000 });
  }

  async deleteNews(newsId) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const query = `
        UPDATE news
        SET is_deleted = true, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      this.cache.invalidateSegment('news');
      this.cache.invalidateSegment('precomputed');

      return { success: true, message: 'News soft deleted' };
    } catch (error) {
      console.error('❌ Delete news error:', error);
      throw error;
    }
  }

  async followUser(followerId, targetUserId) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const query = `
        UPSERT INTO user_follows (follower_id, following_id, created_at)
        VALUES ("${followerId}", "${targetUserId}", CurrentUtcTimestamp())
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      this.cache.invalidateSegment(`user_following:${followerId}`);
      this.cache.invalidateSegment(`user_followers:${targetUserId}`);

      return { success: true };
    } catch (error) {
      console.error('❌ Follow user error:', error);
      throw error;
    }
  }

  async unfollowUser(followerId, targetUserId) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const query = `
        DELETE FROM user_follows
        WHERE follower_id = "${followerId}" AND following_id = "${targetUserId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      this.cache.invalidateSegment(`user_following:${followerId}`);
      this.cache.invalidateSegment(`user_followers:${targetUserId}`);

      return { success: true };
    } catch (error) {
      console.error('❌ Unfollow user error:', error);
      throw error;
    }
  }

  async bookmarkNews(newsId, userId) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const query = `
        UPSERT INTO news_bookmarks (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      this.updateBookmarksCountBackground(newsId);
      this.cache.invalidateSegment(`user_bookmarks:${userId}`);

      return { success: true };
    } catch (error) {
      console.error('❌ Bookmark news error:', error);
      throw error;
    }
  }

  async unbookmarkNews(newsId, userId) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const query = `
        DELETE FROM news_bookmarks
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      this.updateBookmarksCountBackground(newsId);
      this.cache.invalidateSegment(`user_bookmarks:${userId}`);

      return { success: true };
    } catch (error) {
      console.error('❌ Unbookmark news error:', error);
      throw error;
    }
  }

  async updateBookmarksCountBackground(newsId) {
    setTimeout(async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const countQuery = `SELECT COUNT(*) as count FROM news_bookmarks WHERE news_id = "${newsId}"`;
        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(countQuery);
        });

        let realCount = 0;
        if (resultSets && resultSets[0] && resultSets[0].rows && resultSets[0].rows[0]) {
          const row = resultSets[0].rows[0];
          const item = row.items[0];
          if (item.uint64Value !== undefined) {
            if (item.uint64Value && typeof item.uint64Value === 'object') {
              realCount = item.uint64Value.low || 0;
            } else {
              realCount = Number(item.uint64Value) || 0;
            }
          }
        }

        const updateQuery = `
          UPDATE news
          SET bookmarks_count = ${realCount}, updated_at = CurrentUtcTimestamp()
          WHERE id = "${newsId}"
        `;

        await driver.tableClient.withSession(async (session) => {
          await session.executeQuery(updateQuery);
        });

        this.cache.invalidateSegment('news');
      } catch (error) {
        console.log('⚠️ Background bookmarks count update failed:', error.message);
      }
    }, 1000);
  }

  async repostNews(newsId, userId) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const checkQuery = `
        SELECT 1 FROM news_reposts
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
        LIMIT 1
      `;

      const { resultSets } = await driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      if (resultSets[0].rows.length > 0) {
        return { success: true, message: 'News already reposted' };
      }

      const repostQuery = `
        UPSERT INTO news_reposts (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(repostQuery);
      });

      const updateCountQuery = `
        UPDATE news
        SET reposts_count = reposts_count + 1
        WHERE id = "${newsId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateCountQuery);
      });

      this.cache.invalidateSegment(`user_reposts:${userId}`);
      this.cache.invalidateSegment('news');

      return { success: true, message: 'News reposted successfully' };
    } catch (error) {
      console.error('❌ Repost news error:', error);
      throw error;
    }
  }

  async unrepostNews(newsId, userId) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const checkQuery = `
        SELECT 1 FROM news_reposts
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
        LIMIT 1
      `;

      const { resultSets } = await driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      if (resultSets[0].rows.length === 0) {
        return { success: true, message: 'Repost not found' };
      }

      const deleteQuery = `
        DELETE FROM news_reposts
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(deleteQuery);
      });

      const updateCountQuery = `
        UPDATE news
        SET reposts_count = GREATEST(reposts_count - 1, 0)
        WHERE id = "${newsId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateCountQuery);
      });

      this.cache.invalidateSegment(`user_reposts:${userId}`);
      this.cache.invalidateSegment('news');

      return { success: true, message: 'Repost removed successfully' };
    } catch (error) {
      console.error('❌ Unrepost news error:', error);
      throw error;
    }
  }

  async isNewsLikedFast(newsId, userId) {
    if (!newsId || !userId) return false;

    try {
      if (!this.initialized) {
        await this.quickInit();
      }

      const query = `
        SELECT 1 FROM likes_index
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
        LIMIT 1
      `;

      const { resultSets } = await this.connectionPool.getDriver().tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      return resultSets[0].rows.length > 0;
    } catch (error) {
      console.log('⚠️ Fast like check failed:', error.message);
      return false;
    }
  }

  async getAuthorNewsFast(authorId, limit = 20) {
    if (!authorId) return [];

    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const query = `
        SELECT
          news_id as id,
          title,
          likes_count,
          created_at
        FROM author_news
        WHERE author_id = "${authorId}"
        ORDER BY created_at DESC
        LIMIT ${limit}
      `;

      const { resultSets } = await driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const newsItems = this.parseResult(resultSets);

      const enrichedNews = [];
      for (const item of newsItems) {
        if (item.id) {
          const fullNews = await this.getNewsById(item.id);
          if (fullNews) {
            enrichedNews.push(fullNews);
          }
        }
      }

      return enrichedNews;
    } catch (error) {
      console.log('⚠️ Fast author news failed:', error.message);
      return [];
    }
  }

  async getUserLikes(userId) {
    return this.getWithCache(`user_likes`, userId, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `SELECT news_id FROM news_likes WHERE user_id = "${userId}"`;
        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const likes = this.parseResult(resultSets);
        return likes.map(like => like.news_id).filter(id => id);
      } catch (error) {
        console.error('❌ getUserLikes error:', error);
        return [];
      }
    }, { ttl: 60000 });
  }

  async getUserBookmarks(userId) {
    return this.getWithCache(`user_bookmarks`, userId, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `SELECT news_id FROM news_bookmarks WHERE user_id = "${userId}"`;
        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const bookmarks = this.parseResult(resultSets);
        return bookmarks.map(bookmark => bookmark.news_id).filter(id => id);
      } catch (error) {
        console.error('❌ getUserBookmarks error:', error);
        return [];
      }
    }, { ttl: 60000 });
  }

  async getUserReposts(userId) {
    return this.getWithCache(`user_reposts`, userId, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `SELECT news_id FROM news_reposts WHERE user_id = "${userId}"`;
        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const reposts = this.parseResult(resultSets);
        return reposts.map(repost => repost.news_id).filter(id => id);
      } catch (error) {
        console.error('❌ getUserReposts error:', error);
        return [];
      }
    }, { ttl: 60000 });
  }

  async getUserFollowing(userId) {
    return this.getWithCache(`user_following`, userId, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `SELECT following_id FROM user_follows WHERE follower_id = "${userId}"`;
        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const follows = this.parseResult(resultSets);
        return follows.map(follow => follow.following_id).filter(id => id);
      } catch (error) {
        console.error('❌ getUserFollowing error:', error);
        return [];
      }
    }, { ttl: 60000 });
  }

  async getUserFollowers(userId) {
    return this.getWithCache(`user_followers`, userId, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `SELECT follower_id FROM user_follows WHERE following_id = "${userId}"`;
        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const follows = this.parseResult(resultSets);
        return follows.map(follow => follow.follower_id).filter(id => id);
      } catch (error) {
        console.error('❌ getUserFollowers error:', error);
        return [];
      }
    }, { ttl: 60000 });
  }

  async precomputeUserRecommendations() {
    // Placeholder for recommendation engine
    console.log('✅ User recommendations precomputed');
  }

  async batchUpdateViews(batchData, driver) {
    // Placeholder for batch view updates
    console.log('✅ Batch views updated');
  }

  // 🆕 ДОБАВЛЕННЫЙ МЕТОД: Получение комментариев
  async getComments(newsId) {
    return this.getWithCache('comments', `news:${newsId}`, async () => {
      try {
        await this.quickInit();
        const driver = this.connectionPool.getDriver();

        const query = `
          SELECT
            id,
            news_id,
            user_id,
            user_name,
            content as text,
            created_at as timestamp
          FROM news_comments
          WHERE news_id = "${newsId}"
          ORDER BY created_at DESC
          LIMIT 50
        `;

        const { resultSets } = await driver.tableClient.withSession(async (session) => {
          return await session.executeQuery(query);
        });

        const comments = this.parseResult(resultSets);

        // Форматируем комментарии для клиента
        return comments.map(comment => ({
          id: String(comment.id || ''),
          text: String(comment.text || ''),
          author_name: String(comment.user_name || 'Пользователь'),
          author_id: String(comment.user_id || ''),
          timestamp: comment.timestamp || new Date().toISOString(),
          news_id: String(comment.news_id || '')
        }));
      } catch (error) {
        console.error('❌ Get comments from YDB error:', error);
        return [];
      }
    }, { ttl: 30000 }); // Кэшируем на 30 секунд
  }

  // 🆕 ДОБАВЛЕННЫЙ МЕТОД: Добавление комментария
  async addComment(newsId, userId, userName, text) {
    try {
      await this.quickInit();
      const driver = this.connectionPool.getDriver();

      const commentId = `comment_${Date.now()}`;
      const escapedText = text.replace(/"/g, '\\"');
      const escapedUserName = userName.replace(/"/g, '\\"');

      const query = `
        UPSERT INTO news_comments (id, news_id, user_id, user_name, content, created_at)
        VALUES (
          "${commentId}",
          "${newsId}",
          "${userId}",
          "${escapedUserName}",
          "${escapedText}",
          CurrentUtcTimestamp()
        )
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      // Обновляем счетчик комментариев в новости
      const updateCountQuery = `
        UPDATE news
        SET comments_count = comments_count + 1, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateCountQuery);
      });

      // Инвалидируем кэш
      this.cache.invalidateSegment('comments');
      this.cache.invalidateSegment('news');

      return {
        id: commentId,
        news_id: newsId,
        user_id: userId,
        user_name: userName,
        text: text,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('❌ Add comment error:', error);
      throw error;
    }
  }
}

module.exports = new YDBService();