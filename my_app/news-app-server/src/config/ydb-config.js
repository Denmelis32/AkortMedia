const { Driver, getCredentialsFromEnv } = require('ydb-sdk');

class YDBConfig {
  constructor() {
    this.driver = null;
    this.database = '/ru-central1/b1gt6fjmjnejpscls6e8/etng2uemrr7ivj80tldm';
    this.endpoint = 'grpcs://ydb.serverless.yandexcloud.net:2135';
    this.initialized = false;
  }

  async init() {
    if (this.initialized) {
      return this.driver;
    }

    try {
      console.log('🔌 Initializing YDB connection...');

      this.driver = new Driver({
        endpoint: this.endpoint,
        database: this.database,
        authService: getCredentialsFromEnv(),
      });

      const ready = await this.driver.ready(10000);
      if (!ready) {
        throw new Error('YDB driver is not ready');
      }

      this.initialized = true;
      console.log('✅ YDB connection established successfully');
      return this.driver;
    } catch (error) {
      console.error('❌ YDB connection failed:', error);
      throw error;
    }
  }

  getDriver() {
    if (!this.initialized) {
      throw new Error('YDB driver not initialized. Call init() first.');
    }
    return this.driver;
  }
}

module.exports = new YDBConfig();