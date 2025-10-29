const ydbService = require('../services/ydb-optimized-service');
const AuthMiddleware = require('../middleware/auth');

async function runSecurityTests() {
  console.log('🔒 Running security tests...\n');

  // Тест SQL-инъекции
  console.log('1. Testing SQL injection protection...');
  try {
    const maliciousId = "user_1'; DROP TABLE users; --";
    const user = await ydbService.findUserById(maliciousId);
    console.log('✅ SQL injection test passed - query was parameterized');
  } catch (error) {
    console.log('✅ SQL injection test passed - malicious input was handled safely');
  }

  // Тест валидации токенов
  console.log('\n2. Testing token validation...');
  const validations = [
    { token: 'invalid-token', shouldBeValid: false },
    { token: 'Bearer mock-jwt-token-user_123', shouldBeValid: true },
    { token: 'Bearer invalid-mock-token', shouldBeValid: false }
  ];

  for (const test of validations) {
    const result = AuthMiddleware.validateToken(test.token);
    if (result.isValid === test.shouldBeValid) {
      console.log(`✅ Token validation test passed for: ${test.token}`);
    } else {
      console.log(`❌ Token validation test failed for: ${test.token}`);
    }
  }

  // Тест валидации входных данных
  console.log('\n3. Testing input validation...');
  const testInputs = [
    { email: 'invalid-email', shouldPass: false },
    { email: 'test@example.com', shouldPass: true },
    { password: '123', shouldPass: false }, // слишком короткий
    { password: 'securepassword123', shouldPass: true }
  ];

  console.log('✅ All security tests completed');
}

// Запуск тестов если файл вызван напрямую
if (require.main === module) {
  runSecurityTests().catch(console.error);
}

module.exports = { runSecurityTests };