const ydbConfig = require('../config/ydb-config');

class YDBService {
  constructor() {
    this.initialized = false;
    this.driver = null;
  }

  async init() {
    if (this.initialized) return;
    try {
      console.log('🔄 Initializing YDB service...');
      await ydbConfig.init();
      this.driver = ydbConfig.getDriver();
      this.initialized = true;
      console.log('✅ YDB service initialized');
    } catch (error) {
      console.error('❌ Failed to initialize YDB service:', error);
      throw error;
    }
  }

  // 🆕 МЕТОД ПАГИНАЦИИ ДЛЯ НОВОСТЕЙ
  async getNewsWithSocial(page = 0, limit = 20, currentUserId = null) {
    try {
      await this.init();
      const offset = page * limit;

      console.log(`📄 YDB Pagination - Page: ${page}, Limit: ${limit}, Offset: ${offset}`);

      const query = `
        SELECT
          id, title, content, author_id, author_name,
          hashtags, likes_count, reposts_count, comments_count, bookmarks_count,
          share_count, is_deleted, is_repost, original_author_id,
          created_at, updated_at
        FROM news
        WHERE (is_deleted = false OR is_deleted IS NULL)
        AND id != ""
        ORDER BY created_at DESC
        LIMIT ${limit}
        OFFSET ${offset}
      `;

      console.log('🔍 Executing paginated news query...');
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      console.log('🔍 Starting YDB data parsing...');
      const newsItems = this.parseResult(resultSets);

      console.log(`✅ YDB returned ${newsItems.length} items for page ${page}`);

      // Обработка хештегов и контента
      const processedNews = newsItems.map(item => {
        let hashtags = [];
        try {
          if (item.hashtags && typeof item.hashtags === 'string') {
            hashtags = JSON.parse(item.hashtags);
          } else if (Array.isArray(item.hashtags)) {
            hashtags = item.hashtags;
          }
        } catch (e) {
          hashtags = [];
        }

        return {
          ...item,
          hashtags: hashtags,
          content: item.content || ''
        };
      });

      // Получаем взаимодействия пользователя
      const userLikes = currentUserId ? await this.getUserLikes(currentUserId) : [];
      const userBookmarks = currentUserId ? await this.getUserBookmarks(currentUserId) : [];
      const userReposts = currentUserId ? await this.getUserReposts(currentUserId) : [];
      const userFollows = currentUserId ? await this.getUserFollowing(currentUserId) : [];

      // Форматируем результат
      const formattedNews = processedNews.map(item => {
        const title = String(item.title || '');
        const authorName = item.author_name || 'Автор';

        return {
          id: String(item.id || ''),
          title: title,
          content: String(item.content || ''),
          author_id: String(item.author_id || 'unknown'),
          author_name: authorName,
          hashtags: Array.isArray(item.hashtags) ? item.hashtags : [],
          created_at: item.created_at || new Date().toISOString(),
          updated_at: item.updated_at || new Date().toISOString(),
          likes: Number(item.likes_count) || 0,
          likes_count: Number(item.likes_count) || 0,
          reposts: Number(item.reposts_count) || 0,
          reposts_count: Number(item.reposts_count) || 0,
          comments_count: Number(item.comments_count) || 0,
          bookmarks_count: Number(item.bookmarks_count) || 0,
          share_count: Number(item.share_count) || 0,
          is_deleted: Boolean(item.is_deleted) || false,
          is_repost: Boolean(item.is_repost) || false,
          original_author_id: String(item.original_author_id || item.author_id),
          isLiked: userLikes.includes(String(item.id)),
          isBookmarked: userBookmarks.includes(String(item.id)),
          isReposted: userReposts.includes(String(item.id)),
          isFollowing: userFollows.includes(String(item.author_id)),
          comments: [],
          source: 'YDB'
        };
      });

      console.log(`✅ Returning ${formattedNews.length} formatted news items for page ${page}`);
      return formattedNews;

    } catch (error) {
      console.error('❌ getNewsWithSocial error:', error);
      return [];
    }
  }

  // 🆕 МЕТОД ДЛЯ ПРОВЕРКИ ОБЩЕГО КОЛИЧЕСТВА НОВОСТЕЙ
  async getTotalNewsCount() {
    try {
      await this.init();

      const query = `
        SELECT COUNT(*) as total_count
        FROM news
        WHERE (is_deleted = false OR is_deleted IS NULL)
        AND id != ""
      `;

      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const result = this.parseResult(resultSets);
      const totalCount = result[0]?.total_count || 0;

      console.log(`📊 Total news count in YDB: ${totalCount}`);
      return totalCount;
    } catch (error) {
      console.error('❌ getTotalNewsCount error:', error);
      return 0;
    }
  }

  // 🎯 ИСПРАВЛЕННЫЙ ПАРСЕР ДАННЫХ
  parseResult(resultSets) {
    if (!resultSets || !resultSets[0] || !resultSets[0].rows) return [];

    const rows = [];
    const columns = resultSets[0].columns;

    console.log(`🔍 Rows count: ${resultSets[0].rows.length}`);
    console.log(`🔍 Columns: [${columns.map(col => col.name).join(', ')}]`);

    for (let rowIndex = 0; rowIndex < resultSets[0].rows.length; rowIndex++) {
      const row = resultSets[0].rows[rowIndex];
      const obj = {};

      for (let i = 0; i < columns.length; i++) {
        const column = columns[i];
        const item = row.items[i];

        obj[column.name] = this.smartParse(item, column.name);
      }

      // 🎯 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: ВСЕГДА ДОБАВЛЯЕМ СТРОКУ
      rows.push(obj);
      console.log(`✅ Added row ${rowIndex}:`, JSON.stringify(obj));
    }

    console.log(`✅ Parsed ${rows.length} rows from YDB`);
    return rows;
  }

  // 🎯 ИСПРАВЛЕННЫЙ ПАРСЕР ДЛЯ ВСЕХ ТИПОВ ДАННЫХ
  smartParse(item, columnName) {
    if (!item) return null;

    // Optional type
    if (item.optionalType) return this.smartParse(item.optionalType.value, columnName);

    // 🎯 ТЕКСТОВЫЕ ПОЛЯ
    if (item.textValue !== undefined && item.textValue !== null) {
      return String(item.textValue);
    }

    // 🎯 ЧИСЛОВЫЕ ПОЛЯ (uint64Value)
    if (item.uint64Value !== undefined) {
      let numericValue;

      if (item.uint64Value && typeof item.uint64Value === 'object') {
        // Объект с low/high полями (YDB специфика)
        numericValue = item.uint64Value.low || 0;
        if (item.uint64Value.high) {
          // Для больших чисел
          numericValue += item.uint64Value.high * 4294967296;
        }
      } else {
        // Простое число
        numericValue = Number(item.uint64Value) || 0;
      }

      // 🎯 TIMESTAMP ПОЛЯ - УПРОЩЕННАЯ ЛОГИКА
      if (columnName === 'created_at' || columnName === 'updated_at' || columnName === 'timestamp') {
        try {
          // YDB хранит время в микросекундах
          const milliseconds = Math.floor(numericValue / 1000);
          const date = new Date(milliseconds);

          // Проверяем реалистичную дату
          if (date.getFullYear() > 2000 && date.getFullYear() < 2030) {
            return date.toISOString();
          } else {
            // Если дата нереалистичная, используем текущее время
            console.log(`⚠️ Invalid timestamp ${numericValue}, using current time`);
            return new Date().toISOString();
          }
        } catch (error) {
          return new Date().toISOString();
        }
      }

      return numericValue;
    }

    // 🎯 BOOLEAN ПОЛЯ
    if (item.boolValue !== undefined) {
      return Boolean(item.boolValue);
    }

    return null;
  }

  // ... остальные методы остаются без изменений
  async findUserById(userId) {
    try {
      await this.init();
      console.log('🔍 Searching user by ID:', userId);

      const query = `SELECT * FROM users WHERE id = "${userId}" LIMIT 1`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const users = this.parseResult(resultSets);
      console.log('🔍 User by ID result count:', users.length);

      if (users.length > 0) {
        const user = users[0];
        console.log('🔍 Found user data:', {
          id: user.id,
          name: user.name,
          email: user.email,
          avatar: user.avatar,
          created_at: user.created_at
        });
        return user;
      }

      return null;
    } catch (error) {
      console.error('❌ findUserById error:', error);
      return null;
    }
  }

  async findUserByEmail(email) {
    try {
      await this.init();
      console.log('🔍 Searching user by email:', email);

      const query = `SELECT * FROM users WHERE email = "${email}" LIMIT 1`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const users = this.parseResult(resultSets);
      console.log('🔍 User search result:', users.length ? 'Found' : 'Not found');

      return users[0] || null;
    } catch (error) {
      console.error('❌ findUserByEmail error:', error);
      return {
        id: 'user_' + Date.now(),
        name: 'Пользователь',
        email: email
      };
    }
  }

  async createUser(userData) {
    try {
      await this.init();
      const query = `
        UPSERT INTO users (id, name, email, avatar, created_at)
        VALUES ("${userData.id}", "${userData.name}", "${userData.email}", "${userData.avatar || ''}", CurrentUtcTimestamp())
      `;

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      return userData;
    } catch (error) {
      console.error('❌ createUser error:', error);
      throw error;
    }
  }

  // 🎯 СОЗДАНИЕ НОВОСТИ
  // 🎯 СОЗДАНИЕ НОВОСТИ - ИСПРАВЛЕННАЯ ВЕРСИЯ С ПРАВИЛЬНЫМ ВРЕМЕНЕМ
  async createNews(newsData) {
    try {
      await this.init();
      const newsId = `news_${Date.now()}`;

      const escapeValue = (value) => {
        if (!value) return '';
        return String(value).replace(/"/g, '\\"').replace(/'/g, "\\'");
      };

      const title = escapeValue(newsData.title || '');
      const content = escapeValue(newsData.content);
      const authorName = escapeValue(newsData.author_name || 'Автор');

      const hashtags = Array.isArray(newsData.hashtags)
        ? JSON.stringify(newsData.hashtags)
        : '[]';

      // 🆕 ИСПОЛЬЗУЕМ ВРЕМЯ ОТ КЛИЕНТА ИЛИ ТЕКУЩЕЕ СЕРВЕРНОЕ ВРЕМЯ
      const createdAt = newsData.created_at ?
        `CAST("${newsData.created_at}" AS Timestamp)` :
        'CurrentUtcTimestamp()';

      const updatedAt = newsData.updated_at ?
        `CAST("${newsData.updated_at}" AS Timestamp)` :
        'CurrentUtcTimestamp()';

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
          ${createdAt},
          ${updatedAt}
        )
      `;

      console.log('📝 Creating news with query:', query);

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      // 🆕 ВОЗВРАЩАЕМ ДАННЫЕ С ПРАВИЛЬНЫМ ВРЕМЕНЕМ
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
        // 🆕 ВОЗВРАЩАЕМ ТО ЖЕ ВРЕМЯ, ЧТО И СОХРАНИЛИ
        created_at: newsData.created_at || new Date().toISOString(),
        updated_at: newsData.updated_at || new Date().toISOString()
      };
    } catch (error) {
      console.error('createNews error:', error);
      throw error;
    }
  }

  // 🎯 ЛАЙКИ
 // 🎯 ИСПРАВЛЕННЫЙ МЕТОД LIKE NEWS
 async likeNews(newsId, userId) {
   try {
     await this.init();
     console.log(`❤️ LIKE: User ${userId} liking news ${newsId}`);

     // Проверяем, не лайкал ли уже
     const checkQuery = `SELECT * FROM news_likes WHERE news_id = "${newsId}" AND user_id = "${userId}"`;
     const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
       return await session.executeQuery(checkQuery);
     });

     const existing = this.parseResult(checkResults);
     if (existing.length > 0) {
       console.log('ℹ️ User already liked this news');
       return { success: true, action: 'already_liked' };
     }

     // 🎯 ИСПРАВЛЕНИЕ: ПРАВИЛЬНЫЙ INSERT
     const likeQuery = `
       INSERT INTO news_likes (news_id, user_id, created_at)
       VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
     `;

     console.log(`📝 Executing: ${likeQuery}`);

     await this.driver.tableClient.withSession(async (session) => {
       await session.executeQuery(likeQuery);
     });

     console.log('✅ Like saved to YDB');

     // Обновляем счетчик
     await this.updateNewsLikesCount(newsId);

     return { success: true, action: 'liked' };
   } catch (error) {
     console.error('❌ likeNews error:', error);
     throw error;
   }
 }

  async unlikeNews(newsId, userId) {
    try {
      await this.init();

      const query = `
        DELETE FROM news_likes
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      await this.updateNewsLikesCount(newsId);

      return { success: true, action: 'unliked' };
    } catch (error) {
      console.error('❌ unlikeNews error:', error);
      throw error;
    }
  }

  async updateNewsLikesCount(newsId) {
    try {
      const countQuery = `SELECT COUNT(*) as count FROM news_likes WHERE news_id = "${newsId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
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
        SET likes_count = ${realCount}, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateQuery);
      });

      return realCount;
    } catch (error) {
      console.error('❌ [UPDATE_LIKES] ERROR:', error);
      return 0;
    }
  }

  // 🎯 ЗАКЛАДКИ
  async bookmarkNews(newsId, userId) {
    try {
      await this.init();

      const checkQuery = `SELECT * FROM news_bookmarks WHERE news_id = "${newsId}" AND user_id = "${userId}"`;
      const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      const existing = this.parseResult(checkResults);
      if (existing.length > 0) {
        return { success: true, action: 'already_bookmarked' };
      }

      const bookmarkQuery = `
        UPSERT INTO news_bookmarks (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(bookmarkQuery);
      });

      await this.updateNewsBookmarksCount(newsId);

      return { success: true, action: 'bookmarked' };
    } catch (error) {
      console.error('❌ bookmarkNews error:', error);
      throw error;
    }
  }

  async unbookmarkNews(newsId, userId) {
    try {
      await this.init();

      const query = `
        DELETE FROM news_bookmarks
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      await this.updateNewsBookmarksCount(newsId);

      return { success: true, action: 'unbookmarked' };
    } catch (error) {
      console.error('❌ unbookmarkNews error:', error);
      throw error;
    }
  }

  async updateNewsBookmarksCount(newsId) {
    try {
      const countQuery = `SELECT COUNT(*) as count FROM news_bookmarks WHERE news_id = "${newsId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(countQuery);
      });

      const result = this.parseResult(resultSets);
      const count = result[0]?.count || 0;

      const updateQuery = `
        UPDATE news
        SET bookmarks_count = ${count}, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateQuery);
      });

      return count;
    } catch (error) {
      console.error('❌ updateNewsBookmarksCount error:', error);
      return 0;
    }
  }

  // 🎯 РЕПОСТЫ
  async repostNews(newsId, userId) {
    try {
      await this.init();
      console.log(`🔁 REPOST: User ${userId} reposting news ${newsId}`);

      // Проверяем, не репостил ли уже
      const checkQuery = `SELECT * FROM news_reposts WHERE news_id = "${newsId}" AND user_id = "${userId}"`;
      const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      const existing = this.parseResult(checkResults);
      if (existing.length > 0) {
        console.log('ℹ️ User already reposted this news');
        return { success: true, action: 'already_reposted' };
      }

      // Добавляем репост
      const repostQuery = `
        INSERT INTO news_reposts (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;

      console.log(`📝 Executing: ${repostQuery}`);

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(repostQuery);
      });

      console.log('✅ Repost saved to YDB');

      // Обновляем счетчик
      await this.updateNewsRepostsCount(newsId);

      return { success: true, action: 'reposted' };
    } catch (error) {
      console.error('❌ repostNews error:', error);
      throw error;
    }
  }

  async unrepostNews(newsId, userId) {
    try {
      await this.init();
      console.log(`🔁 UNREPOST: User ${userId} unreposting news ${newsId}`);

      const query = `
        DELETE FROM news_reposts
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
      `;

      console.log(`📝 Executing: ${query}`);

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      console.log('✅ Repost removed from YDB');

      // Обновляем счетчик
      await this.updateNewsRepostsCount(newsId);

      return { success: true, action: 'unreposted' };
    } catch (error) {
      console.error('❌ unrepostNews error:', error);
      throw error;
    }
  }

  async updateNewsRepostsCount(newsId) {
    try {
      const countQuery = `SELECT COUNT(*) as count FROM news_reposts WHERE news_id = "${newsId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(countQuery);
      });

      const result = this.parseResult(resultSets);
      const count = result[0]?.count || 0;

      const updateQuery = `
        UPDATE news
        SET reposts_count = ${count}, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;

      console.log(`📝 Updating reposts count to ${count} for news: ${newsId}`);

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateQuery);
      });

      return count;
    } catch (error) {
      console.error('❌ updateNewsRepostsCount error:', error);
      return 0;
    }
  }

  // 🎯 КОММЕНТАРИИ
  // 🎯 УЛУЧШЕННЫЙ МЕТОД ДОБАВЛЕНИЯ КОММЕНТАРИЯ
  async addComment(newsId, commentData, userId) {
    try {
      await this.init();
      const commentId = `comment_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      // 🎯 ЭКРАНИРОВАНИЕ ДАННЫХ
      const escapeValue = (value) => {
        if (!value) return '';
        return String(value).replace(/"/g, '\\"').replace(/'/g, "\\'");
      };

      const userName = escapeValue(commentData.author_name);
      const content = escapeValue(commentData.text);

      const query = `
        UPSERT INTO news_comments (id, news_id, user_id, user_name, content, created_at)
        VALUES (
          "${commentId}",
          "${newsId}",
          "${userId}",
          "${userName}",
          "${content}",
          CurrentUtcTimestamp()
        )
      `;

      console.log('📝 Executing comment query...');
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      // 🎯 ОБНОВЛЯЕМ СЧЕТЧИК КОММЕНТАРИЕВ
      await this.updateNewsCommentsCount(newsId);

      return {
        id: commentId,
        news_id: newsId,
        user_id: userId,
        user_name: commentData.author_name,
        content: commentData.text,
        created_at: new Date().toISOString()
      };
    } catch (error) {
      console.error('❌ addComment error:', error);
      throw error;
    }
  }

  async getComments(newsId) {
    try {
      await this.init();
      const query = `SELECT * FROM news_comments WHERE news_id = "${newsId}" ORDER BY created_at DESC LIMIT 50`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      return this.parseResult(resultSets);
    } catch (error) {
      console.error('❌ getComments error:', error);
      return [];
    }
  }

  async updateNewsCommentsCount(newsId) {
    try {
      const countQuery = `SELECT COUNT(*) as count FROM news_comments WHERE news_id = "${newsId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(countQuery);
      });

      const result = this.parseResult(resultSets);
      const count = result[0]?.count || 0;

      const updateQuery = `
        UPDATE news
        SET comments_count = ${count}, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateQuery);
      });

      return count;
    } catch (error) {
      console.error('❌ updateNewsCommentsCount error:', error);
      return 0;
    }
  }

  // 🎯 ПОЛЬЗОВАТЕЛЬСКИЕ ДАННЫЕ
  async getUserLikes(userId) {
    try {
      await this.init();
      const query = `SELECT news_id FROM news_likes WHERE user_id = "${userId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const likes = this.parseResult(resultSets);
      return likes.map(like => like.news_id).filter(id => id);
    } catch (error) {
      console.error('❌ getUserLikes error:', error);
      return [];
    }
  }

  async getUserBookmarks(userId) {
    try {
      await this.init();
      const query = `SELECT news_id FROM news_bookmarks WHERE user_id = "${userId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const bookmarks = this.parseResult(resultSets);
      return bookmarks.map(bookmark => bookmark.news_id).filter(id => id);
    } catch (error) {
      console.error('❌ getUserBookmarks error:', error);
      return [];
    }
  }

  async getUserReposts(userId) {
    try {
      await this.init();
      const query = `SELECT news_id FROM news_reposts WHERE user_id = "${userId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const reposts = this.parseResult(resultSets);
      return reposts.map(repost => repost.news_id).filter(id => id);
    } catch (error) {
      console.error('❌ getUserReposts error:', error);
      return [];
    }
  }

  // 🎯 ПОДПИСКИ
  async followUser(followerId, followingId) {
    try {
      await this.init();

      // Проверяем, не подписан ли уже
      const checkQuery = `SELECT * FROM user_follows WHERE follower_id = "${followerId}" AND following_id = "${followingId}"`;
      const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      const existing = this.parseResult(checkResults);
      if (existing.length > 0) {
        return { success: true, action: 'already_following' };
      }

      // Добавляем подписку
      const followQuery = `
        UPSERT INTO user_follows (follower_id, following_id, created_at)
        VALUES ("${followerId}", "${followingId}", CurrentUtcTimestamp())
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(followQuery);
      });

      return { success: true, action: 'followed' };
    } catch (error) {
      console.error('❌ followUser error:', error);
      throw error;
    }
  }

  async unfollowUser(followerId, followingId) {
    try {
      await this.init();

      const query = `
        DELETE FROM user_follows
        WHERE follower_id = "${followerId}" AND following_id = "${followingId}"
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      return { success: true, action: 'unfollowed' };
    } catch (error) {
      console.error('❌ unfollowUser error:', error);
      throw error;
    }
  }

  async getUserFollowing(userId) {
    try {
      await this.init();
      const query = `SELECT following_id FROM user_follows WHERE follower_id = "${userId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const follows = this.parseResult(resultSets);
      return follows.map(follow => follow.following_id).filter(id => id);
    } catch (error) {
      console.error('❌ getUserFollowing error:', error);
      return [];
    }
  }

  async getUserFollowers(userId) {
    try {
      await this.init();
      const query = `SELECT follower_id FROM user_follows WHERE following_id = "${userId}"`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const followers = this.parseResult(resultSets);
      return followers.map(follower => follower.follower_id).filter(id => id);
    } catch (error) {
      console.error('❌ getUserFollowers error:', error);
      return [];
    }
  }

  // 🎯 УДАЛЕНИЕ ПОСТА (soft delete)
 // 🎯 УДАЛЕНИЕ ПОСТА (soft delete) - ИСПРАВЛЕННАЯ ВЕРСИЯ
 async deleteNews(newsId, userId) {
   try {
     await this.init();
     console.log(`🗑️ DELETE: User ${userId} deleting news ${newsId}`);

     // Проверяем, принадлежит ли пост пользователю - ВКЛЮЧАЕМ ID В ЗАПРОС
     const checkQuery = `SELECT id, author_id, is_deleted FROM news WHERE id = "${newsId}"`;
     console.log(`🔍 Executing: ${checkQuery}`);

     const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
       return await session.executeQuery(checkQuery);
     });

     const newsItems = this.parseResult(checkResults);
     console.log(`🔍 Found ${newsItems.length} news items after parsing`);

     // 🎯 ИСПРАВЛЕНИЕ: Проверяем данные даже если парсер вернул 0 строк
     if (checkResults[0] && checkResults[0].rows && checkResults[0].rows.length > 0) {
       console.log(`🔍 Raw rows count: ${checkResults[0].rows.length}`);

       // Ручной парсинг для диагностики
       const rawRow = checkResults[0].rows[0];
       const rawData = {};
       for (let i = 0; i < checkResults[0].columns.length; i++) {
         const column = checkResults[0].columns[i];
         const item = rawRow.items[i];
         rawData[column.name] = this.smartParse(item, column.name);
       }
       console.log(`🔍 Raw row data:`, JSON.stringify(rawData));

       // Используем ручные данные если парсер не сработал
       if (newsItems.length === 0 && rawData.author_id) {
         console.log(`🔄 Using manually parsed data`);
         if (rawData.author_id !== userId) {
           throw new Error('Not authorized to delete this news');
         }
         if (rawData.is_deleted) {
           return { success: true, action: 'already_deleted' };
         }
       }
     }

     if (newsItems.length === 0) {
       console.log(`❌ News not found: ${newsId}`);
       throw new Error('News not found');
     }

     const newsItem = newsItems[0];
     console.log(`🔍 News item data:`, JSON.stringify(newsItem));

     if (newsItem.author_id !== userId) {
       throw new Error('Not authorized to delete this news');
     }

     if (newsItem.is_deleted) {
       return { success: true, action: 'already_deleted' };
     }

     // Soft delete - помечаем как удаленное
     const deleteQuery = `
       UPDATE news
       SET is_deleted = true, updated_at = CurrentUtcTimestamp()
       WHERE id = "${newsId}"
     `;

     console.log(`📝 Executing: ${deleteQuery}`);

     await this.driver.tableClient.withSession(async (session) => {
       await session.executeQuery(deleteQuery);
     });

     console.log(`✅ News marked as deleted: ${newsId}`);
     return { success: true, action: 'deleted' };
   } catch (error) {
     console.error('❌ deleteNews error:', error);
     throw error;
   }
 }

  // 🎯 РЕДАКТИРОВАНИЕ ПОСТА
  // 🎯 РЕДАКТИРОВАНИЕ ПОСТА - ИСПРАВЛЕННАЯ ВЕРСИЯ
  async updateNews(newsId, userId, updateData) {
    try {
      await this.init();

      // Проверяем права на редактирование - ВКЛЮЧАЕМ ID В ЗАПРОС
      const checkQuery = `SELECT id, author_id, is_deleted FROM news WHERE id = "${newsId}"`;
      console.log(`🔍 Executing: ${checkQuery}`);

      const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      const newsItems = this.parseResult(checkResults);
      console.log(`🔍 Found ${newsItems.length} news items after parsing`);

      // 🎯 ИСПРАВЛЕНИЕ: Проверяем данные даже если парсер вернул 0 строк
      let newsItem = null;

      if (checkResults[0] && checkResults[0].rows && checkResults[0].rows.length > 0) {
        console.log(`🔍 Raw rows count: ${checkResults[0].rows.length}`);

        // Ручной парсинг для диагностики
        const rawRow = checkResults[0].rows[0];
        const rawData = {};
        for (let i = 0; i < checkResults[0].columns.length; i++) {
          const column = checkResults[0].columns[i];
          const item = rawRow.items[i];
          rawData[column.name] = this.smartParse(item, column.name);
        }
        console.log(`🔍 Raw row data:`, JSON.stringify(rawData));

        // Используем ручные данные если парсер не сработал
        if (newsItems.length === 0 && rawData.author_id) {
          console.log(`🔄 Using manually parsed data`);
          newsItem = rawData;
        }
      }

      if (!newsItem && newsItems.length === 0) {
        throw new Error('News not found');
      }

      if (!newsItem) {
        newsItem = newsItems[0];
      }

      console.log(`🔍 Final news item:`, JSON.stringify(newsItem));

      if (newsItem.author_id !== userId) {
        throw new Error('Not authorized to edit this news');
      }

      if (newsItem.is_deleted) {
        throw new Error('Cannot edit deleted news');
      }

      // Формируем SET часть запроса
      const updates = [];
      if (updateData.title !== undefined) updates.push(`title = "${this.escapeValue(updateData.title)}"`);
      if (updateData.content !== undefined) updates.push(`content = "${this.escapeValue(updateData.content)}"`);
      if (updateData.hashtags !== undefined) {
        const hashtagsJson = JSON.stringify(updateData.hashtags || []);
        updates.push(`hashtags = '${hashtagsJson}'`);
      }

      if (updates.length === 0) {
        return { success: true, action: 'no_changes' };
      }

      updates.push('updated_at = CurrentUtcTimestamp()');

      const updateQuery = `
        UPDATE news
        SET ${updates.join(', ')}
        WHERE id = "${newsId}"
      `;

      console.log(`📝 Executing: ${updateQuery}`);

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateQuery);
      });

      return { success: true, action: 'updated' };
    } catch (error) {
      console.error('❌ updateNews error:', error);
      throw error;
    }
  }

  // 🎯 ПОДЕЛИТЬСЯ (ШАРИНГ)
  async shareNews(newsId) {
    try {
      await this.init();

      const shareQuery = `
        UPDATE news
        SET share_count = IF(share_count IS NULL, 1, share_count + 1),
            updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(shareQuery);
      });

      return { success: true, action: 'shared' };
    } catch (error) {
      console.error('❌ shareNews error:', error);
      throw error;
    }
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  escapeValue(value) {
    if (!value) return '';
    return String(value).replace(/"/g, '\\"').replace(/'/g, "\\'");
  }
}

module.exports = new YDBService();