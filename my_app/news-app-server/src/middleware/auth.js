const jwt = require('jsonwebtoken');
const { SECURITY_CONFIG } = require('../config/security');

class AuthMiddleware {
  // Валидация JWT токена
  static validateToken(token) {
    try {
      if (!token) {
        return { isValid: false, error: 'Token is required' };
      }

      // Удаляем 'Bearer ' префикс если есть
      const actualToken = token.replace(/^Bearer\s+/i, '');

      // Проверяем mock токены для тестирования
      if (actualToken.startsWith('mock-jwt-token-')) {
        const userId = actualToken.replace('mock-jwt-token-', '');
        if (userId && userId.startsWith('user_')) {
          return { isValid: true, userId, isMock: true };
        }
        return { isValid: false, error: 'Invalid mock token format' };
      }

      // Валидация реального JWT
      const decoded = jwt.verify(actualToken, SECURITY_CONFIG.jwt.secret, {
        issuer: SECURITY_CONFIG.jwt.issuer,
        audience: SECURITY_CONFIG.jwt.audience
      });

      return {
        isValid: true,
        userId: decoded.userId,
        isMock: false,
        payload: decoded
      };
    } catch (error) {
      return {
        isValid: false,
        error: `Token validation failed: ${error.message}`
      };
    }
  }

  // Middleware для защиты роутов
  static authenticate(req, res, next) {
    const authHeader = req.headers.authorization || req.headers.Authorization;

    if (!authHeader) {
      return res.status(401).json({
        success: false,
        error: 'Authorization header is required',
        code: 'MISSING_TOKEN'
      });
    }

    const validationResult = AuthMiddleware.validateToken(authHeader);

    if (!validationResult.isValid) {
      return res.status(401).json({
        success: false,
        error: validationResult.error,
        code: 'INVALID_TOKEN'
      });
    }

    req.user = {
      id: validationResult.userId,
      isMock: validationResult.isMock
    };

    next();
  }

  // Генерация JWT токена
  static generateToken(userId, additionalPayload = {}) {
    const payload = {
      userId,
      ...additionalPayload,
      iss: SECURITY_CONFIG.jwt.issuer,
      aud: SECURITY_CONFIG.jwt.audience,
      iat: Math.floor(Date.now() / 1000)
    };

    return jwt.sign(payload, SECURITY_CONFIG.jwt.secret, {
      expiresIn: SECURITY_CONFIG.jwt.expiresIn
    });
  }
}

module.exports = AuthMiddleware;