const express = require('express');
const cors = require('cors');
require('dotenv').config();
const pool = require('./config/database');

// Импорты роутов и middleware
const authRoutes = require('./routes/auth');
const newsRoutes = require('./routes/news');
const auth = require('./middleware/auth');

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware ДОЛЖНЫ быть в правильном порядке!
app.use(cors({
  origin: true, // Разрешаем все origin для разработки
  credentials: true
}));
app.use(express.json()); // Важно: ДО роутов!

// Подключение роутов
app.use('/api/auth', authRoutes);
app.use('/api/news', newsRoutes); // Пока без auth

// Basic route
app.get('/', (req, res) => {
  res.json({
    message: 'Football Server API is working!',
    status: 'success',
    timestamp: new Date().toISOString(),
    endpoints: [
      '/api/auth/register',
      '/api/auth/login',
      '/api/auth/me',
      '/api/news',
      '/api/news/:id',
      '/api/test',
      '/api/health',
      '/api/status'
    ]
  });
});

// Test API endpoint
app.get('/api/test', (req, res) => {
  res.json({
    message: 'API test endpoint is working!',
    database: {
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      name: process.env.DB_NAME,
      user: process.env.DB_USER
    }
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    server: 'running',
    timestamp: new Date().toISOString()
  });
});

// Status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    server: 'Football API Server',
    version: '1.0.0',
    environment: process.env.NODE_ENV,
    port: PORT,
    uptime: process.uptime()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
  console.log(`🌐 API URL: http://localhost:${PORT}`);
  console.log(`📋 Available endpoints:`);
  console.log(`   - POST /api/auth/register`);
  console.log(`   - POST /api/auth/login`);
  console.log(`   - GET /api/auth/me`);
  console.log(`   - GET /api/news`);
  console.log(`   - POST /api/news`);
  console.log(`   - GET /api/test`);
  console.log(`   - GET /api/health`);
  console.log(`   - GET /api/status`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Server shutting down...');
  process.exit(0);
});