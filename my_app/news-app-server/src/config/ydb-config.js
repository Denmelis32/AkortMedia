// src/config/ydb-config.js
const { Driver, getCredentialsFromEnv } = require('ydb-sdk');

class YDBConfig {
  constructor() {
    this.driver = null;
    this.initialized = false;
  }

  async init() {
    if (this.initialized) return;

    try {
      console.log('🔄 Initializing YDB driver...');

      const authService = getCredentialsFromEnv();

      this.driver = new Driver({
        endpoint: process.env.YDB_ENDPOINT || 'grpcs://ydb.serverless.yandexcloud.net:2135',
        database: process.env.YDB_DATABASE || '/ru-central1/b1gt6fjmjnejpscls6e8/etng2uemrr7ivj80tldm',
        authService,
      });

      console.log('🔄 Connecting to YDB...');
      const ready = await this.driver.ready(10000);

      if (!ready) {
        throw new Error('YDB driver not ready');
      }

      this.initialized = true;
      console.log('✅ YDB driver initialized successfully');
    } catch (error) {
      console.error('❌ YDB driver initialization failed:', error);
      throw error;
    }
  }

  getDriver() {
    if (!this.initialized) {
      throw new Error('YDB driver not initialized. Call init() first.');
    }
    return this.driver;
  }

  async destroy() {
    if (this.driver) {
      await this.driver.destroy();
      this.initialized = false;
      console.log('✅ YDB driver destroyed');
    }
  }
}

module.exports = new YDBConfig();