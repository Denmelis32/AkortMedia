// src/controllers/newsController.js
const News = require('../models/News');

const newsController = {
  // Получить все новости
  async getAll(req, res) {
    try {
      const news = await News.getAll();
      res.json(news);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Получить новость по ID
  async getById(req, res) {
    try {
      const news = await News.getById(req.params.id);
      if (!news) {
        return res.status(404).json({ error: 'News not found' });
      }
      res.json(news);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Создать новость
  async create(req, res) {
    try {
      const { title, description, image } = req.body;

      // Временное решение - используем author_id = 1 для теста
      // Позже заменим на реального пользователя из JWT токена
      const author_id = 1;

      if (!title || !description || !image) {
        return res.status(400).json({ error: 'Title, description and image are required' });
      }

      const news = await News.create({ title, description, image, author_id });
      res.status(201).json(news);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Обновить новость
  async update(req, res) {
    try {
      const { title, description, image } = req.body;
      const news = await News.update(req.params.id, { title, description, image });

      if (!news) {
        return res.status(404).json({ error: 'News not found' });
      }

      res.json(news);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Удалить новость
  async delete(req, res) {
    try {
      const news = await News.delete(req.params.id);

      if (!news) {
        return res.status(404).json({ error: 'News not found' });
      }

      res.json({ message: 'News deleted successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Добавить лайк
  async like(req, res) {
    try {
      const news = await News.like(req.params.id);

      if (!news) {
        return res.status(404).json({ error: 'News not found' });
      }

      res.json(news);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Убрать лайк
  async unlike(req, res) {
    try {
      const news = await News.unlike(req.params.id);

      if (!news) {
        return res.status(404).json({ error: 'News not found' });
      }

      res.json(news);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = newsController;