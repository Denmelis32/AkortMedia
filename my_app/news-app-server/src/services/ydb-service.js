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

  // 🎯 ФИНАЛЬНЫЙ ИСПРАВЛЕННЫЙ ПАРСЕР
  parseResult(resultSets) {
    if (!resultSets || !resultSets[0] || !resultSets[0].rows) return [];

    const rows = [];
    const columns = resultSets[0].columns;

    for (const row of resultSets[0].rows) {
      const obj = {};
      for (let i = 0; i < columns.length; i++) {
        const column = columns[i];
        const item = row.items[i];
        obj[column.name] = this.smartParse(item, column.name);
      }
      rows.push(obj);
    }

    console.log('✅ FINAL PARSED ROWS:', rows);
    return rows;
  }

  // 🎯 ИСПРАВЛЕННЫЙ ПАРСЕР ДЛЯ COUNT ЗАПРОСОВ
  smartParse(item, columnName) {
    if (!item) return null;

    // Optional type
    if (item.optionalType) return this.smartParse(item.optionalType.value, columnName);

    // 🎯 ВАЖНО: Специальная обработка для COUNT запросов
    if (columnName === 'count' || columnName === 'column0') {
      console.log(`🔢 COUNT column detected: ${columnName}`, item);

      if (item.uint64Value !== undefined) {
        if (item.uint64Value && typeof item.uint64Value === 'object') {
          const value = item.uint64Value.low || 0;
          console.log(`🎯 EXTRACTED COUNT from Long: ${value}`);
          return value;
        } else {
          const value = Number(item.uint64Value) || 0;
          console.log(`🎯 EXTRACTED COUNT from primitive: ${value}`);
          return value;
        }
      }
    }

    // 🎯 Для числовых колонок
    const isNumberColumn = columnName.includes('_count') ||
                          columnName === 'likes' ||
                          columnName === 'reposts' ||
                          columnName === 'bookmarks_count';

    const isTextColumn = columnName.includes('id') ||
                        columnName.includes('title') ||
                        columnName.includes('content') ||
                        columnName.includes('author') ||
                        columnName.includes('name') ||
                        columnName === 'hashtags';

    // 🎯 Для числовых колонок
    if (isNumberColumn && item.uint64Value !== undefined) {
      console.log(`🔢 Number column ${columnName}:`, item.uint64Value);

      if (item.uint64Value && typeof item.uint64Value === 'object') {
        if (item.uint64Value.low !== undefined) {
          const value = item.uint64Value.low;
          console.log(`🎯 EXTRACTED NUMBER for ${columnName}: ${value}`);
          return value;
        }
      } else {
        const value = Number(item.uint64Value);
        console.log(`🎯 PRIMITIVE NUMBER for ${columnName}: ${value}`);
        return value;
      }
    }

    // 🎯 Для текстовых колонок (включая content и hashtags)
    if (isTextColumn && item.textValue !== undefined) {
      const value = String(item.textValue);
      if (value === 'null') {
        console.log(`📭 NULL text for ${columnName}`);
        return null;
      }
      console.log(`📝 Text for ${columnName}: "${value}"`);
      return value;
    }

    // Boolean
    if (item.boolValue !== undefined) {
      const value = Boolean(item.boolValue);
      console.log(`🔘 Boolean for ${columnName}: ${value}`);
      return value;
    }

    // 🎯 Fallback для любых колонок
    if (item.uint64Value !== undefined) {
      console.log(`🔢 Fallback Uint64 for ${columnName}:`, item.uint64Value);
      if (item.uint64Value && typeof item.uint64Value === 'object') {
        return item.uint64Value.low || 0;
      }
      return Number(item.uint64Value) || 0;
    }

    if (item.textValue !== undefined) {
      const value = String(item.textValue);
      return value === 'null' ? null : value;
    }

    return null;
  }

  // 🎯 ОСНОВНЫЕ МЕТОДЫ ДЛЯ НОВОСТЕЙ - ИСПРАВЛЕННАЯ ВЕРСИЯ
  async getNewsWithSocial(limit = 50, currentUserId = null) {
    try {
      await this.init();
      console.log('🚀 [FINAL_PARSER] Getting news from YDB');

      const query = `
        SELECT
          id, title, content, author_id, author_name,
          hashtags, likes_count, reposts_count, comments_count, bookmarks_count,
          created_at, updated_at
        FROM news
        ORDER BY created_at DESC
        LIMIT ${limit}
      `;

      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const newsItems = this.parseResult(resultSets);
      console.log(`📊 Found ${newsItems.length} news items`);

      // 🎯 ИСПРАВЛЕННЫЙ ПАРСЕР ДЛЯ ХЕШТЕГОВ И КОНТЕНТА
      const processedNews = newsItems.map(item => {
        // Парсим хештеги из JSON строки
        let hashtags = [];
        try {
          if (item.hashtags && typeof item.hashtags === 'string') {
            hashtags = JSON.parse(item.hashtags);
          } else if (Array.isArray(item.hashtags)) {
            hashtags = item.hashtags;
          }
        } catch (e) {
          console.log('❌ Error parsing hashtags:', e);
          hashtags = [];
        }

        return {
          ...item,
          hashtags: hashtags,
          content: item.content || '' // Гарантируем что content всегда есть
        };
      });

      console.log('🎯 Processed news with content and hashtags:', {
        content: processedNews[0]?.content,
        hashtags: processedNews[0]?.hashtags
      });

      // Получаем взаимодействия пользователя
      const userLikes = currentUserId ? await this.getUserLikes(currentUserId) : [];
      const userBookmarks = currentUserId ? await this.getUserBookmarks(currentUserId) : [];
      const userReposts = currentUserId ? await this.getUserReposts(currentUserId) : [];

      // Форматируем результат
      const formattedNews = processedNews.map(item => {
        return {
          id: String(item.id || ''),
          title: String(item.title || 'Без названия'),
          content: String(item.content || ''),
          author_id: String(item.author_id || 'unknown'),
          author_name: String(item.author_name || 'Неизвестный автор'),
          hashtags: Array.isArray(item.hashtags) ? item.hashtags : [],
          created_at: item.created_at || new Date().toISOString(),
          updated_at: item.updated_at || new Date().toISOString(),

          // 🎯 ЧИСЛА из базы
          likes: Number(item.likes_count) || 0,
          likes_count: Number(item.likes_count) || 0,
          reposts: Number(item.reposts_count) || 0,
          reposts_count: Number(item.reposts_count) || 0,
          comments_count: Number(item.comments_count) || 0,
          bookmarks_count: Number(item.bookmarks_count) || 0,

          // Статусы взаимодействий
          isLiked: userLikes.includes(String(item.id)),
          isBookmarked: userBookmarks.includes(String(item.id)),
          isReposted: userReposts.includes(String(item.id)),

          comments: [],
          source: 'YDB'
        };
      });

      console.log(`✅ Returning ${formattedNews.length} news items with content and hashtags`);
      return formattedNews;

    } catch (error) {
      console.error('❌ getNewsWithSocial error:', error);
      return [];
    }
  }

  // 🎯 МЕТОДЫ ДЛЯ ВЗАИМОДЕЙСТВИЙ

  // Поиск пользователя по ID
  async findUserById(userId) {
    try {
      await this.init();
      const query = `SELECT * FROM users WHERE id = "${userId}" LIMIT 1`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const users = this.parseResult(resultSets);
      return users[0] || null;
    } catch (error) {
      console.error('❌ findUserById error:', error);
      return null;
    }
  }

  // Поиск пользователя по email
  async findUserByEmail(email) {
    try {
      await this.init();
      const query = `SELECT * FROM users WHERE email = "${email}" LIMIT 1`;
      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const users = this.parseResult(resultSets);
      return users[0] || null;
    } catch (error) {
      console.error('❌ findUserByEmail error:', error);
      return null;
    }
  }

  // Создание пользователя
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

  // 🎯 СОЗДАНИЕ НОВОСТИ - ИСПРАВЛЕННАЯ ВЕРСИЯ С ПРАВИЛЬНЫМ ИМЕНЕМ АВТОРА
  // 🎯 СОЗДАНИЕ НОВОСТИ - ИСПРАВЛЕННАЯ ВЕРСИЯ С ЭКРАНИРОВАНИЕМ
  // 🎯 СОЗДАНИЕ НОВОСТИ - ИСПРАВЛЕННАЯ ВЕРСИЯ БЕЗ РУССКИХ КОММЕНТАРИЕВ
  async createNews(newsData) {
    try {
      await this.init();
      const newsId = `news_${Date.now()}`;

      // Экранирование данных
      const escapeValue = (value) => {
        if (!value) return '';
        return String(value).replace(/"/g, '\\"').replace(/'/g, "\\'");
      };

      const title = escapeValue(newsData.title);
      const content = escapeValue(newsData.content);
      const authorName = escapeValue(newsData.author_name || 'Неизвестный автор');

      const hashtags = Array.isArray(newsData.hashtags)
        ? JSON.stringify(newsData.hashtags)
        : '[]';

      // 🚨 ВАЖНО: УБРАТЬ ВСЕ РУССКИЕ КОММЕНТАРИИ ИЗ SQL!
      const query = `
        UPSERT INTO news (
          id, title, content, author_id, author_name,
          hashtags, likes_count, reposts_count, comments_count, bookmarks_count,
          created_at, updated_at
        ) VALUES (
          "${newsId}",
          "${title}",
          "${content}",
          "${newsData.author_id}",
          "${authorName}",
          '${hashtags}',
          0, 0, 0, 0,
          CurrentUtcTimestamp(),
          CurrentUtcTimestamp()
        )
      `;

      console.log('Creating news with query:', query);

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      return {
        id: newsId,
        ...newsData,
        author_name: authorName,
        hashtags: newsData.hashtags || [],
        likes_count: 0,
        reposts_count: 0,
        comments_count: 0,
        bookmarks_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
    } catch (error) {
      console.error('createNews error:', error);
      throw error;
    }
  }

  // 🎯 ЛАЙКИ
  async likeNews(newsId, userId) {
    try {
      await this.init();

      // Проверяем, не лайкал ли уже
      const checkQuery = `SELECT * FROM news_likes WHERE news_id = "${newsId}" AND user_id = "${userId}"`;
      const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      const existing = this.parseResult(checkResults);
      if (existing.length > 0) {
        return { success: true, action: 'already_liked' };
      }

      // Добавляем лайк
      const likeQuery = `
        UPSERT INTO news_likes (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(likeQuery);
      });

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

      // Обновляем счетчик
      await this.updateNewsLikesCount(newsId);

      return { success: true, action: 'unliked' };
    } catch (error) {
      console.error('❌ unlikeNews error:', error);
      throw error;
    }
  }

  async updateNewsLikesCount(newsId) {
    try {
      console.log(`🎯 [UPDATE_LIKES] START for: ${newsId}`);

      // 1. Получаем реальное количество лайков из news_likes
      const countQuery = `SELECT COUNT(*) as count FROM news_likes WHERE news_id = "${newsId}"`;
      console.log(`📋 [UPDATE_LIKES] Count query: ${countQuery}`);

      const { resultSets } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(countQuery);
      });

      console.log('🔍 [UPDATE_LIKES] Raw COUNT result:', JSON.stringify(resultSets, null, 2));

      // 2. Упрощенный парсинг COUNT результата
      let realCount = 0;
      if (resultSets && resultSets[0] && resultSets[0].rows && resultSets[0].rows[0]) {
        const row = resultSets[0].rows[0];
        const item = row.items[0];

        console.log('🎯 [UPDATE_LIKES] COUNT item to parse:', item);

        // Прямое извлечение значения
        if (item.uint64Value !== undefined) {
          if (item.uint64Value && typeof item.uint64Value === 'object') {
            realCount = item.uint64Value.low || 0;
          } else {
            realCount = Number(item.uint64Value) || 0;
          }
        }
      }

      console.log(`📈 [UPDATE_LIKES] Real likes count from news_likes: ${realCount}`);

      // 3. Обновляем счетчик в таблице news
      const updateQuery = `
        UPDATE news
        SET likes_count = ${realCount}, updated_at = CurrentUtcTimestamp()
        WHERE id = "${newsId}"
      `;
      console.log(`📋 [UPDATE_LIKES] Update query: ${updateQuery}`);

      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateQuery);
      });

      console.log(`✅ [UPDATE_LIKES] SUCCESS: Updated likes_count for ${newsId} to ${realCount}`);
      return realCount;

    } catch (error) {
      console.error('❌ [UPDATE_LIKES] ERROR:', error);
      return 0;
    }
  }

  // 🎯 РЕПОСТЫ
  async repostNews(newsId, userId) {
    try {
      await this.init();

      // Проверяем, не репостил ли уже
      const checkQuery = `SELECT * FROM news_reposts WHERE news_id = "${newsId}" AND user_id = "${userId}"`;
      const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      const existing = this.parseResult(checkResults);
      if (existing.length > 0) {
        return { success: true, action: 'already_reposted' };
      }

      // Добавляем репост
      const repostQuery = `
        UPSERT INTO news_reposts (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(repostQuery);
      });

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

      const query = `
        DELETE FROM news_reposts
        WHERE news_id = "${newsId}" AND user_id = "${userId}"
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

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
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(updateQuery);
      });

      return count;
    } catch (error) {
      console.error('❌ updateNewsRepostsCount error:', error);
      return 0;
    }
  }

  // 🎯 ЗАКЛАДКИ
  async bookmarkNews(newsId, userId) {
    try {
      await this.init();

      // Проверяем, не в закладках ли уже
      const checkQuery = `SELECT * FROM news_bookmarks WHERE news_id = "${newsId}" AND user_id = "${userId}"`;
      const { resultSets: checkResults } = await this.driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(checkQuery);
      });

      const existing = this.parseResult(checkResults);
      if (existing.length > 0) {
        return { success: true, action: 'already_bookmarked' };
      }

      // Добавляем в закладки
      const bookmarkQuery = `
        UPSERT INTO news_bookmarks (news_id, user_id, created_at)
        VALUES ("${newsId}", "${userId}", CurrentUtcTimestamp())
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(bookmarkQuery);
      });

      // Обновляем счетчик
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

      // Обновляем счетчик
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

  // 🎯 КОММЕНТАРИИ
  async addComment(newsId, commentData, userId) {
    try {
      await this.init();
      const commentId = `comment_${Date.now()}`;

      const query = `
        UPSERT INTO news_comments (id, news_id, user_id, user_name, content, created_at)
        VALUES (
          "${commentId}",
          "${newsId}",
          "${userId}",
          "${commentData.author_name}",
          "${commentData.text}",
          CurrentUtcTimestamp()
        )
      `;
      await this.driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      // Обновляем счетчик комментариев
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

  // 🎯 ПОЛУЧЕНИЕ ВЗАИМОДЕЙСТВИЙ ПОЛЬЗОВАТЕЛЯ
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
}

module.exports = new YDBService();