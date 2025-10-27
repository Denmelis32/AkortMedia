const express = require('express');
const router = express.Router();
const { query } = require('../config/database');

// Получение всех новостей
router.get('/', async (req, res) => {
  try {
    console.log('📰 Getting all news...');
    
    const result = await query(`
      SELECT 
        n.*,
        u.name as author_name,
        u.avatar_url as author_avatar,
        (SELECT COUNT(*)::integer FROM likes WHERE news_id = n.id) as likes_count,
        (SELECT COUNT(*)::integer FROM comments WHERE news_id = n.id) as comments_count
      FROM news n
      LEFT JOIN users u ON n.author_id = u.id
      ORDER BY n.created_at DESC
    `);

    console.log(`✅ Found ${result.rows.length} news`);
    res.json(result.rows);
  } catch (error) {
    console.error('❌ Get news error:', error);
    res.status(500).json({ error: 'Ошибка при получении новостей: ' + error.message });
  }
});

// Создание новости
router.post('/', async (req, res) => {
  try {
    const { title, description, author_id, hashtags = [], user_tags = {} } = req.body;

    console.log('📝 Creating news:', { title, author_id });

    const result = await query(
      `INSERT INTO news (title, description, author_id, hashtags, user_tags)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [title, description, author_id, hashtags, JSON.stringify(user_tags)]
    );

    const newNews = result.rows[0];
    console.log('✅ News created:', newNews.id);

    res.status(201).json(newNews);
  } catch (error) {
    console.error('❌ Create news error:', error);
    res.status(500).json({ error: 'Ошибка при создании новости: ' + error.message });
  }
});

// Получение новости по ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await query(
      `SELECT
         n.*,
         u.name as author_name,
         u.avatar_url as author_avatar
       FROM news n
       LEFT JOIN users u ON n.author_id = u.id
       WHERE n.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Новость не найдена' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get news by id error:', error);
    res.status(500).json({ error: 'Ошибка при получении новости: ' + error.message });
  }
});

module.exports = router;