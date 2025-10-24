const ydbConfig = require('../config/ydb-config');

class YDBService {
  constructor() {
    this.initialized = false;
  }

  async init() {
    if (this.initialized) return;

    try {
      console.log('🔄 Initializing YDB service...');
      await ydbConfig.init();
      this.initialized = true;
      console.log('✅ YDB service initialized');
    } catch (error) {
      console.error('❌ Failed to initialize YDB service:', error);
      throw error;
    }
  }

  async getNews(limit = 20) {
    console.log('🚀 START getNews - reading from YDB');

    try {
      await this.init();
      const driver = ydbConfig.getDriver();

      const query = `SELECT * FROM news ORDER BY created_at DESC LIMIT ${limit}`;
      console.log('📤 Executing query:', query);

      const { resultSets } = await driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      console.log('🔍 Raw resultSets structure:', {
        hasResultSets: !!resultSets,
        resultSetsCount: resultSets?.length || 0,
        firstResultSet: resultSets?.[0] ? {
          columns: resultSets[0].columns?.map(c => c.name) || [],
          rowsCount: resultSets[0].rows?.length || 0
        } : 'No result sets'
      });

      if (!resultSets || !resultSets[0] || !resultSets[0].rows) {
        console.log('📭 No data found in YDB');
        return [];
      }

      const news = [];
      const columns = resultSets[0].columns;

      for (let i = 0; i < resultSets[0].rows.length; i++) {
        const row = resultSets[0].rows[i];
        const newsItem = {};

        columns.forEach((column, colIndex) => {
          const value = this.parseValue(row.items[colIndex]);
          newsItem[column.name] = value;

          // Логируем важные поля для диагностики
          if (column.name === 'id' || column.name === 'title' || column.name === 'author_name') {
            console.log(`📊 Row ${i} - ${column.name}:`, value);
          }
        });

        news.push(newsItem);
      }

      console.log(`✅ SUCCESS: Loaded ${news.length} real news from YDB`);
      console.log('📋 News sample:', news.slice(0, 2).map(item => ({
        id: item.id,
        title: item.title,
        author: item.author_name,
        likes: item.likes
      })));

      return news;

    } catch (error) {
      console.error('❌ FAILED to load news from YDB:', error.message);
      console.error('Full error:', error);
      return [];
    }
  }

  parseValue(item) {
    if (!item) {
      return null;
    }

    // Простой и надежный парсинг
    if (item.textValue !== undefined) return item.textValue;
    if (item.int32Value !== undefined) return item.int32Value;
    if (item.boolValue !== undefined) return item.boolValue;
    if (item.jsonValue !== undefined) {
      try {
        return JSON.parse(item.jsonValue);
      } catch (e) {
        console.log('❌ JSON parse error:', e.message);
        return item.jsonValue;
      }
    }
    if (item.timestampValue !== undefined) {
      try {
        return new Date(Number(item.timestampValue) / 1000);
      } catch (e) {
        console.log('❌ Date parse error:', e.message);
        return new Date();
      }
    }

    console.log('🔍 Unknown value type:', Object.keys(item));
    return null;
  }

  async createNews(data) {
    console.log('🚀 START createNews - writing to YDB');

    try {
      await this.init();
      const driver = ydbConfig.getDriver();

      const newsId = data.id || `news_${Date.now()}`;

      const query = `
        UPSERT INTO news (
          id, title, description, content, author_id, author_name,
          author_avatar, likes, reposts, hashtags, user_tags,
          is_repost, is_channel_post, created_at, updated_at
        ) VALUES (
          "${newsId}",
          "${this.escapeString(data.title)}",
          "${this.escapeString(data.description)}",
          "${this.escapeString(data.content || data.description)}",
          "${data.author_id || 'unknown'}",
          "${this.escapeString(data.author_name || 'Пользователь')}",
          "${data.author_avatar || ''}",
          ${data.likes || 0},
          ${data.reposts || 0},
          '${JSON.stringify(data.hashtags || [])}',
          '${JSON.stringify(data.user_tags || {})}',
          ${data.is_repost || false},
          ${data.is_channel_post || false},
          CurrentUtcTimestamp(),
          CurrentUtcTimestamp()
        )
      `;

      console.log('📝 Executing create query:', query);

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      console.log('✅ SUCCESS: News created in YDB:', newsId);
      return true;

    } catch (error) {
      console.error('❌ FAILED to create news:', error.message);
      throw error;
    }
  }

  escapeString(str) {
    return String(str).replace(/"/g, '\\"').replace(/'/g, "\\'");
  }

  async findUserByEmail(email) {
    try {
      await this.init();
      const driver = ydbConfig.getDriver();

      const query = `SELECT * FROM users WHERE email = "${this.escapeString(email)}" LIMIT 1`;
      const { resultSets } = await driver.tableClient.withSession(async (session) => {
        return await session.executeQuery(query);
      });

      const users = this.parseResult(resultSets);
      return users[0] || null;
    } catch (error) {
      console.error('❌ Failed to find user:', error.message);
      return null;
    }
  }

  async createUser(userData) {
    try {
      await this.init();
      const driver = ydbConfig.getDriver();

      const query = `
        UPSERT INTO users (
          id, email, name, password_hash, avatar, created_at, updated_at
        ) VALUES (
          "${userData.id}",
          "${this.escapeString(userData.email)}",
          "${this.escapeString(userData.name)}",
          "${this.escapeString(userData.password_hash)}",
          "${userData.avatar || ''}",
          CurrentUtcTimestamp(),
          CurrentUtcTimestamp()
        )
      `;

      await driver.tableClient.withSession(async (session) => {
        await session.executeQuery(query);
      });

      console.log('✅ User created successfully in YDB');
      return true;
    } catch (error) {
      console.error('❌ Failed to create user:', error.message);
      throw error;
    }
  }

  parseResult(resultSets) {
    if (!resultSets || !resultSets[0] || !resultSets[0].rows) return [];
    const rows = [];
    for (const row of resultSets[0].rows) {
      const obj = {};
      resultSets[0].columns.forEach((column, index) => {
        obj[column.name] = this.parseValue(row.items[index]);
      });
      rows.push(obj);
    }
    return rows;
  }
}

module.exports = new YDBService();