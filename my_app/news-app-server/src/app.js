const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const newsRoutes = require('./routes/news');

const app = express();

// Расширенные CORS настройки для Flutter Web
const allowedOrigins = [
  'http://localhost:3000',
  'http://127.0.0.1:3000',
  'http://localhost:8080',
  'http://127.0.0.1:8080',
  'http://localhost:53589',
  'http://127.0.0.1:53589',
  'http://localhost:65279',
  'http://127.0.0.1:65279',
  'http://localhost:51034',
  'http://127.0.0.1:51034',
  'http://localhost:9102',
  'http://127.0.0.1:9102',
  // Динамические порты Flutter
  /http:\/\/localhost:\d+/,
  /http:\/\/127\.0\.0\.1:\d+/
];

app.use(cors({
  origin: function (origin, callback) {
    // Разрешаем запросы без origin (например, из curl)
    if (!origin) return callback(null, true);

    // Проверяем разрешенные origins
    if (allowedOrigins.some(allowed => {
      if (typeof allowed === 'string') {
        return allowed === origin;
      } else if (allowed instanceof RegExp) {
        return allowed.test(origin);
      }
      return false;
    })) {
      return callback(null, true);
    } else {
      console.log('🚫 CORS blocked for origin:', origin);
      return callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH', 'HEAD'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Origin',
    'Access-Control-Request-Method',
    'Access-Control-Request-Headers',
    'X-API-Key'
  ],
  exposedHeaders: [
    'Content-Length',
    'Content-Type',
    'Authorization'
  ],
  preflightContinue: false,
  optionsSuccessStatus: 204,
  maxAge: 86400 // 24 часа
}));

// Явная обработка preflight запросов
app.options('*', cors());

// Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Логирование запросов (упрощенное для разработки)
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  if (req.method === 'POST' || req.method === 'PUT') {
    console.log('Body:', JSON.stringify(req.body).substring(0, 200) + '...');
  }
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/news', newsRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    cors: {
      origin: req.headers.origin || 'No origin header',
      allowed: true
    }
  });
});

// CORS test endpoint
app.get('/api/cors-test', (req, res) => {
  res.json({
    message: 'CORS test successful',
    origin: req.headers.origin || 'No origin header',
    userAgent: req.headers['user-agent'],
    timestamp: new Date().toISOString(),
    allowedOrigins: allowedOrigins.filter(o => typeof o === 'string')
  });
});

// Test endpoint для Flutter
app.get('/api/flutter-test', (req, res) => {
  res.json({
    message: 'Flutter connection test successful',
    server: 'Node.js + Express',
    database: 'PostgreSQL',
    status: 'operational',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  console.log(`404 - Route not found: ${req.method} ${req.originalUrl}`);
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method,
    availableEndpoints: [
      'GET /api/health',
      'GET /api/cors-test',
      'GET /api/flutter-test',
      'GET /api/news',
      'POST /api/news',
      'POST /api/auth/login',
      'POST /api/auth/register'
    ]
  });
});

// Error handler
app.use((error, req, res, next) => {
  console.error('🚨 Server error:', error);

  // CORS ошибки
  if (error.message === 'Not allowed by CORS') {
    return res.status(403).json({
      error: 'CORS Error',
      message: 'Origin not allowed',
      yourOrigin: req.headers.origin,
      details: 'Make sure your Flutter app is using an allowed origin'
    });
  }

  // Ошибки базы данных
  if (error.code && error.code.startsWith('23')) {
    return res.status(400).json({
      error: 'Database Error',
      message: error.detail || error.message,
      code: error.code
    });
  }

  // Общие ошибки
  res.status(500).json({
    error: 'Internal server error',
    message: error.message,
    ...(process.env.NODE_ENV === 'development' && {
      stack: error.stack,
      fullError: error
    })
  });
});

module.exports = app;