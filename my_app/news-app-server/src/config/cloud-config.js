require('dotenv').config();

module.exports = {
  // Настройки Yandex Database
  ydb: {
    endpoint: process.env.YDB_ENDPOINT || 'grpcs://ydb.serverless.yandexcloud.net:2135',
    database: process.env.YDB_DATABASE || '/ru-central1/b1gt6fjmjnejpscls6e8/etng2uemrr7ivj80tldm',
  },

  // Настройки Object Storage
  objectStorage: {
    bucket: process.env.YANDEX_CLOUD_BUCKET || 'news-app-media',
    region: 'ru-central1',
    endpoint: 'https://storage.yandexcloud.net'
  },

  // Настройки сервера
  server: {
    port: process.env.PORT || 3000,
    jwtSecret: process.env.JWT_SECRET || 'your-secret-key'
  }
};