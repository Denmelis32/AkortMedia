const express = require('express');
const cors = require('cors');
require('dotenv').config();
const pool = require('./config/database');

// Импорты роутов
const newsRoutes = require('./routes/news');

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
// app.use(cors({
//   origin: /http:\/\/localhost:\d+$/,
//   credentials: true
// }));
app.use(cors());
app.use(express.json());

// Подключение роутов
app.use('/api/news', newsRoutes);

// Basic route
app.get('/', (req, res) => {
  res.json({
    message: 'Football Server API is working!',
    status: 'success',
    timestamp: new Date().toISOString(),
    endpoints: [
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
  console.log(`   - GET /`);
  console.log(`   - GET /api/news`);
  console.log(`   - GET /api/news/:id`);
  console.log(`   - POST /api/news`);
  console.log(`   - PUT /api/news/:id`);
  console.log(`   - DELETE /api/news/:id`);
  console.log(`   - POST /api/news/:id/like`);
  console.log(`   - POST /api/news/:id/unlike`);
  console.log(`   - GET /api/test`);
  console.log(`   - GET /api/health`);
  console.log(`   - GET /api/status`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Server shutting down...');
  process.exit(0);
});