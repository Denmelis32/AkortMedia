const { query } = require('../config/database');

class News {
  // Создание новости
  static async create(newsData) {
    const {
      title,
      description,
      image_url,
      author_id,
      hashtags = [],
      user_tags = {},
      is_repost = false,
      original_post_id = null,
      repost_comment = null,
      is_channel_post = false
    } = newsData;

    const result = await query(
      `INSERT INTO news
       (title, description, image_url, author_id, hashtags, user_tags,
        is_repost, original_post_id, repost_comment, is_channel_post)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        title, description, image_url, author_id, hashtags, user_tags,
        is_repost, original_post_id, repost_comment, is_channel_post
      ]
    );

    return result.rows[0];
  }

  // Получение всех новостей с пагинацией
  static async findAll(page = 1, limit = 20) {
    const offset = (page - 1) * limit;

    const result = await query(
      `SELECT
         n.*,
         u.name as author_name,
         u.avatar_url as author_avatar,
         EXISTS(SELECT 1 FROM likes l WHERE l.news_id = n.id AND l.user_id = $3) as is_liked,
         EXISTS(SELECT 1 FROM bookmarks b WHERE b.news_id = n.id AND b.user_id = $3) as is_bookmarked,
         (SELECT COUNT(*) FROM likes WHERE news_id = n.id) as likes_count,
         (SELECT COUNT(*) FROM comments WHERE news_id = n.id) as comments_count
       FROM news n
       LEFT JOIN users u ON n.author_id = u.id
       ORDER BY n.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset, 1] // user_id = 1 для примера
    );

    return result.rows;
  }

  // Поиск новости по ID
  static async findById(id) {
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
    return result.rows[0];
  }

  // Обновление новости
  static async update(id, updateData) {
    const { title, description, hashtags, user_tags } = updateData;

    const result = await query(
      `UPDATE news
       SET title = $1, description = $2, hashtags = $3, user_tags = $4, updated_at = CURRENT_TIMESTAMP
       WHERE id = $5
       RETURNING *`,
      [title, description, hashtags, user_tags, id]
    );

    return result.rows[0];
  }

  // Удаление новости
  static async delete(id) {
    await query('DELETE FROM news WHERE id = $1', [id]);
    return true;
  }
}

module.exports = News;