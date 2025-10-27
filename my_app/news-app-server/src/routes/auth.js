const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Регистрация
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    // Проверяем обязательные поля
    if (!email || !password || !name) {
      return res.status(400).json({
        error: 'Все поля обязательны для заполнения'
      });
    }

    // Проверяем, существует ли пользователь
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({
        error: 'Пользователь с таким email уже существует'
      });
    }

    // Создаем пользователя
    const user = await User.create({ email, password, name });

    // Генерируем токен
    const token = User.generateToken(user);

    res.status(201).json({
      message: 'Пользователь успешно зарегистрирован',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      error: 'Ошибка при регистрации пользователя'
    });
  }
});

// Логин
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        error: 'Email и пароль обязательны'
      });
    }

    // Ищем пользователя
    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(401).json({
        error: 'Неверный email или пароль'
      });
    }

    // Проверяем пароль
    const isPasswordValid = await User.checkPassword(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        error: 'Неверный email или пароль'
      });
    }

    // Генерируем токен
    const token = User.generateToken(user);

    res.json({
      message: 'Вход выполнен успешно',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        avatar_url: user.avatar_url,
        cover_url: user.cover_url
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'Ошибка при входе в систему'
    });
  }
});

module.exports = router;