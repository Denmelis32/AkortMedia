const { query } = require('./database');

async function createTables() {
  try {
    console.log('🔄 Creating database tables...');

    // Таблица пользователей
    await query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        avatar_url VARCHAR(500),
        cover_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Таблица новостей
    await query(`
      CREATE TABLE IF NOT EXISTS news (
        id SERIAL PRIMARY KEY,
        title VARCHAR(500) NOT NULL,
        description TEXT,
        image_url VARCHAR(500),
        author_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        hashtags TEXT[] DEFAULT '{}',
        user_tags JSONB DEFAULT '{}',
        likes_count INTEGER DEFAULT 0,
        reposts_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        is_repost BOOLEAN DEFAULT FALSE,
        original_post_id INTEGER REFERENCES news(id),
        repost_comment TEXT,
        is_channel_post BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Таблица лайков
    await query(`
      CREATE TABLE IF NOT EXISTS likes (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        news_id INTEGER REFERENCES news(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, news_id)
      )
    `);

    // Таблица закладок
    await query(`
      CREATE TABLE IF NOT EXISTS bookmarks (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        news_id INTEGER REFERENCES news(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, news_id)
      )
    `);

    // Таблица комментариев
    await query(`
      CREATE TABLE IF NOT EXISTS comments (
        id SERIAL PRIMARY KEY,
        content TEXT NOT NULL,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        news_id INTEGER REFERENCES news(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    console.log('✅ Database tables created successfully!');
  } catch (error) {
    console.error('❌ Error creating tables:', error);
  }
}

// Запуск миграций
createTables().then(() => {
  console.log('🎉 Migration completed!');
  process.exit(0);
});