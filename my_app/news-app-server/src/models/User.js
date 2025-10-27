const { query } = require('../config/database');
const jwt = require('jsonwebtoken');

class User {
  // Регистрация пользователя
  static async create(userData) {
    try {
      const { email, password, name } = userData;

      console.log('👤 Creating user:', { email, name });

      // Проверяем, существует ли пользователь
      const existingUser = await query(
        'SELECT id FROM users WHERE email = $1',
        [email]
      );

      if (existingUser.rows.length > 0) {
        throw new Error('Пользователь с таким email уже существует');
      }

      // Сохраняем пароль как есть (для тестирования)
      const result = await query(
        `INSERT INTO users (email, password, name)
         VALUES ($1, $2, $3) RETURNING id, email, name, created_at`,
        [email, password, name]
      );

      console.log('✅ User created with ID:', result.rows[0].id);
      return result.rows[0];
    } catch (error) {
      console.error('❌ User creation error:', error);
      throw error;
    }
  }

  // Поиск пользователя по email
  static async findByEmail(email) {
    try {
      const result = await query(
        'SELECT * FROM users WHERE email = $1',
        [email]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Find user error:', error);
      throw error;
    }
  }

  // Поиск пользователя по ID
  static async findById(id) {
    const result = await query(
      `SELECT id, email, name, avatar_url, cover_url, created_at
       FROM users WHERE id = $1`,
      [id]
    );
    return result.rows[0];
  }

  // Проверка пароля
  static async checkPassword(plainPassword, storedPassword) {
    // Простое сравнение для тестирования
    return plainPassword === storedPassword;
  }

  // Генерация JWT токена
  static generateToken(user) {
    return jwt.sign(
      {
        userId: user.id,
        email: user.email
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
  }

  // Обновление профиля
  static async updateProfile(userId, updateData) {
    const { name, avatar_url, cover_url } = updateData;

    const result = await query(
      `UPDATE users
       SET name = $1, avatar_url = $2, cover_url = $3, updated_at = CURRENT_TIMESTAMP
       WHERE id = $4
       RETURNING id, email, name, avatar_url, cover_url`,
      [name, avatar_url, cover_url, userId]
    );

    return result.rows[0];
  }
}

module.exports = User;
